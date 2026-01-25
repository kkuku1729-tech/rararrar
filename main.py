#!/usr/bin/env python3
"""
MUSIC SHARING BOT - Создание плейлистов и обмен музыкой
"""

import os
import sys
import json
import uuid
import shutil
import sqlite3
import hashlib
import random
from datetime import datetime
from pathlib import Path
from typing import Dict, List, Optional, Tuple
import warnings

# Отключаем предупреждения
warnings.filterwarnings("ignore")

print("=" * 60)
print("🎵 MUSIC SHARING BOT v1.2")
print("📁 Создание плейлистов и обмен музыкой")
print("=" * 60)

# Токен бота
TOKEN = "8369697873:AAGp7Zz-TSX16IJj-G1ehijP_IsdQVJJbiQ"

try:
    from telegram import Update, InlineKeyboardButton, InlineKeyboardMarkup, InputFile
    from telegram.ext import (
        Application,
        CommandHandler,
        MessageHandler,
        CallbackQueryHandler,
        filters,
        ContextTypes,
        ConversationHandler,
    )
    print("✅ Библиотеки загружены")
except ImportError as e:
    print(f"❌ Ошибка импорта: {e}")
    print("Установите: pip3 install python-telegram-bot")
    sys.exit(1)

# Состояния для ConversationHandler
UPLOAD, PLAYLIST_NAME, PLAYLIST_DESC, PLAYLIST_PRIVACY, SEARCH_PLAYLIST = range(5)

# Типы приватности
PRIVACY_PUBLIC = "public"
PRIVACY_PRIVATE = "private"

# Пути для файлов
BASE_DIR = Path(__file__).parent
DATA_DIR = BASE_DIR / "music_data"
DB_FILE = DATA_DIR / "music_bot.db"
MUSIC_DIR = DATA_DIR / "music_files"
PLAYLISTS_DIR = DATA_DIR / "playlists"
USERS_DIR = DATA_DIR / "users"

# Создаем директории
for directory in [DATA_DIR, MUSIC_DIR, PLAYLISTS_DIR, USERS_DIR]:
    directory.mkdir(parents=True, exist_ok=True)

class MusicDatabase:
    """Класс для работы с базой данных"""
    
    def __init__(self):
        self.conn = sqlite3.connect(DB_FILE, check_same_thread=False)
        self.create_tables()
        self.update_tables()
    
    def create_tables(self):
        """Создание таблиц в базе данных"""
        cursor = self.conn.cursor()
        
        # Таблица пользователей
        cursor.execute('''
            CREATE TABLE IF NOT EXISTS users (
                user_id INTEGER PRIMARY KEY,
                username TEXT,
                first_name TEXT,
                join_date TIMESTAMP
            )
        ''')
        
        # Таблица музыки
        cursor.execute('''
            CREATE TABLE IF NOT EXISTS music (
                file_id TEXT PRIMARY KEY,
                user_id INTEGER,
                title TEXT,
                performer TEXT,
                duration INTEGER,
                file_size INTEGER,
                file_hash TEXT,
                upload_date TIMESTAMP,
                FOREIGN KEY (user_id) REFERENCES users (user_id)
            )
        ''')
        
        # Таблица плейлистов (базовая версия)
        cursor.execute('''
            CREATE TABLE IF NOT EXISTS playlists (
                playlist_id TEXT PRIMARY KEY,
                user_id INTEGER,
                name TEXT,
                description TEXT,
                is_public BOOLEAN DEFAULT 1,
                created_date TIMESTAMP,
                FOREIGN KEY (user_id) REFERENCES users (user_id)
            )
        ''')
        
        # Таблица связей плейлист-музыка
        cursor.execute('''
            CREATE TABLE IF NOT EXISTS playlist_music (
                playlist_id TEXT,
                file_id TEXT,
                added_date TIMESTAMP,
                PRIMARY KEY (playlist_id, file_id),
                FOREIGN KEY (playlist_id) REFERENCES playlists (playlist_id),
                FOREIGN KEY (file_id) REFERENCES music (file_id)
            )
        ''')
        
        # Таблица лайков
        cursor.execute('''
            CREATE TABLE IF NOT EXISTS likes (
                user_id INTEGER,
                playlist_id TEXT,
                like_date TIMESTAMP,
                PRIMARY KEY (user_id, playlist_id),
                FOREIGN KEY (playlist_id) REFERENCES playlists (playlist_id)
            )
        ''')
        
        self.conn.commit()
    
    def update_tables(self):
        """Обновление структуры таблиц для новой версии"""
        cursor = self.conn.cursor()
        
        # Проверяем существование колонок и добавляем их если нужно
        try:
            # Проверяем существует ли колонка privacy_type
            cursor.execute("PRAGMA table_info(playlists)")
            columns = [column[1] for column in cursor.fetchall()]
            
            if 'privacy_type' not in columns:
                print("🔄 Добавляю колонку privacy_type в таблицу playlists...")
                cursor.execute('ALTER TABLE playlists ADD COLUMN privacy_type TEXT DEFAULT "public"')
            
            if 'display_name' not in columns:
                print("🔄 Добавляю колонку display_name в таблицу playlists...")
                cursor.execute('ALTER TABLE playlists ADD COLUMN display_name TEXT')
                
                # Обновляем существующие записи
                cursor.execute('UPDATE playlists SET display_name = name WHERE display_name IS NULL')
            
            self.conn.commit()
            print("✅ Структура базы данных обновлена")
            
        except Exception as e:
            print(f"⚠️ Ошибка при обновлении таблиц: {e}")
            # Если не удалось добавить колонки, создаем таблицу заново
            self.recreate_tables()
    
    def recreate_tables(self):
        """Пересоздание таблиц с новой структурой"""
        print("🔄 Пересоздаю таблицы с новой структурой...")
        
        cursor = self.conn.cursor()
        
        # Создаем временную таблицу для сохранения данных
        cursor.execute('''
            CREATE TABLE IF NOT EXISTS playlists_new (
                playlist_id TEXT PRIMARY KEY,
                user_id INTEGER,
                name TEXT,
                display_name TEXT,
                description TEXT,
                is_public BOOLEAN DEFAULT 1,
                privacy_type TEXT DEFAULT "public",
                created_date TIMESTAMP,
                FOREIGN KEY (user_id) REFERENCES users (user_id)
            )
        ''')
        
        # Копируем данные из старой таблицы
        cursor.execute('''
            INSERT INTO playlists_new 
            SELECT 
                playlist_id, 
                user_id, 
                name,
                name as display_name,  -- Используем name как display_name
                description,
                is_public,
                CASE 
                    WHEN is_public = 1 THEN 'public'
                    ELSE 'private'
                END as privacy_type,
                created_date
            FROM playlists
        ''')
        
        # Удаляем старую таблицу
        cursor.execute('DROP TABLE IF EXISTS playlists')
        
        # Переименовываем новую таблицу
        cursor.execute('ALTER TABLE playlists_new RENAME TO playlists')
        
        self.conn.commit()
        print("✅ Таблицы успешно пересозданы")
    
    def add_user(self, user_id: int, username: str, first_name: str):
        """Добавление пользователя"""
        cursor = self.conn.cursor()
        cursor.execute('''
            INSERT OR REPLACE INTO users (user_id, username, first_name, join_date)
            VALUES (?, ?, ?, ?)
        ''', (user_id, username, first_name, datetime.now()))
        self.conn.commit()
    
    def save_music_info(self, file_id: str, user_id: int, title: str, 
                       performer: str, duration: int, file_size: int, file_hash: str):
        """Сохранение информации о музыке"""
        cursor = self.conn.cursor()
        cursor.execute('''
            INSERT OR REPLACE INTO music (file_id, user_id, title, performer, 
                             duration, file_size, file_hash, upload_date)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?)
        ''', (file_id, user_id, title, performer, duration, 
              file_size, file_hash, datetime.now()))
        self.conn.commit()
    
    def check_public_playlist_name_exists(self, name: str) -> bool:
        """Проверяет, существует ли уже публичный плейлист с таким именем"""
        cursor = self.conn.cursor()
        cursor.execute('''
            SELECT 1 FROM playlists 
            WHERE display_name = ? AND privacy_type = 'public'
        ''', (name,))
        return cursor.fetchone() is not None
    
    def create_playlist(self, user_id: int, name: str, description: str = "", 
                       privacy_type: str = "public") -> str:
        """Создание плейлиста"""
        playlist_id = str(uuid.uuid4())[:8]
        is_public = 1 if privacy_type == "public" else 0
        
        # Для публичных плейлистов создаем уникальное отображаемое имя
        if privacy_type == "public":
            # Проверяем уникальность имени
            base_name = name
            counter = 1
            display_name = base_name
            
            while self.check_public_playlist_name_exists(display_name):
                display_name = f"{base_name}_{counter}"
                counter += 1
        else:
            # Для приватных плейлистов display_name не важен
            display_name = f"private_{playlist_id}"
        
        cursor = self.conn.cursor()
        cursor.execute('''
            INSERT INTO playlists (playlist_id, user_id, name, display_name,
                                 description, is_public, privacy_type, created_date)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?)
        ''', (playlist_id, user_id, name, display_name, description, 
              is_public, privacy_type, datetime.now()))
        self.conn.commit()
        return playlist_id
    
    def update_playlist_privacy(self, playlist_id: str, privacy_type: str):
        """Обновление приватности плейлиста"""
        is_public = 1 if privacy_type == "public" else 0
        
        cursor = self.conn.cursor()
        
        # Если меняем на публичный, нужно проверить уникальность имени
        if privacy_type == "public":
            # Получаем текущее имя плейлиста
            cursor.execute('SELECT name FROM playlists WHERE playlist_id = ?', (playlist_id,))
            result = cursor.fetchone()
            if result:
                base_name = result[0]
                counter = 1
                display_name = base_name
                
                while self.check_public_playlist_name_exists(display_name):
                    display_name = f"{base_name}_{counter}"
                    counter += 1
                
                cursor.execute('''
                    UPDATE playlists 
                    SET is_public = ?, privacy_type = ?, display_name = ?
                    WHERE playlist_id = ?
                ''', (is_public, privacy_type, display_name, playlist_id))
        else:
            # Для приватного плейлиста display_name не важен
            cursor.execute('''
                UPDATE playlists 
                SET is_public = ?, privacy_type = ?, display_name = ?
                WHERE playlist_id = ?
            ''', (is_public, privacy_type, f"private_{playlist_id}", playlist_id))
        
        self.conn.commit()
    
    def add_to_playlist(self, playlist_id: str, file_id: str):
        """Добавление трека в плейлист"""
        cursor = self.conn.cursor()
        cursor.execute('''
            INSERT OR IGNORE INTO playlist_music (playlist_id, file_id, added_date)
            VALUES (?, ?, ?)
        ''', (playlist_id, file_id, datetime.now()))
        self.conn.commit()
    
    def delete_playlist(self, playlist_id: str):
        """Удаление плейлиста"""
        cursor = self.conn.cursor()
        # Сначала удаляем связи с музыкой
        cursor.execute('DELETE FROM playlist_music WHERE playlist_id = ?', (playlist_id,))
        # Удаляем лайки
        cursor.execute('DELETE FROM likes WHERE playlist_id = ?', (playlist_id,))
        # Удаляем сам плейлист
        cursor.execute('DELETE FROM playlists WHERE playlist_id = ?', (playlist_id,))
        self.conn.commit()
    
    def get_user_playlists(self, user_id: int) -> List[Dict]:
        """Получение плейлистов пользователя"""
        cursor = self.conn.cursor()
        cursor.execute('''
            SELECT playlist_id, name, description, created_date, 
                   is_public, privacy_type
            FROM playlists 
            WHERE user_id = ?
            ORDER BY created_date DESC
        ''', (user_id,))
        
        playlists = []
        for row in cursor.fetchall():
            playlist_id, name, description, created_date, is_public, privacy_type = row
            
            # Если privacy_type не установлен, определяем по is_public
            if privacy_type is None:
                privacy_type = "public" if is_public else "private"
            
            # Получаем количество треков
            cursor.execute('''
                SELECT COUNT(*) FROM playlist_music WHERE playlist_id = ?
            ''', (playlist_id,))
            track_count = cursor.fetchone()[0]
            
            playlists.append({
                'id': playlist_id,
                'name': name,
                'description': description,
                'created': created_date,
                'is_public': bool(is_public),
                'privacy_type': privacy_type,
                'track_count': track_count
            })
        
        return playlists
    
    def get_public_playlists(self, limit: int = 20) -> List[Dict]:
        """Получение публичных плейлистов"""
        cursor = self.conn.cursor()
        cursor.execute('''
            SELECT p.playlist_id, p.name, p.display_name, p.description, 
                   u.username, p.created_date, COUNT(pm.file_id) as track_count
            FROM playlists p
            LEFT JOIN users u ON p.user_id = u.user_id
            LEFT JOIN playlist_music pm ON p.playlist_id = pm.playlist_id
            WHERE p.privacy_type = 'public' OR (p.privacy_type IS NULL AND p.is_public = 1)
            GROUP BY p.playlist_id
            ORDER BY p.created_date DESC
            LIMIT ?
        ''', (limit,))
        
        playlists = []
        for row in cursor.fetchall():
            playlist_id, name, display_name, description, username, created_date, track_count = row
            playlists.append({
                'id': playlist_id,
                'name': name,
                'display_name': display_name or name,
                'description': description,
                'username': username or "Аноним",
                'created': created_date,
                'track_count': track_count
            })
        
        return playlists
    
    def get_playlist_tracks(self, playlist_id: str) -> List[Dict]:
        """Получение треков из плейлиста"""
        cursor = self.conn.cursor()
        cursor.execute('''
            SELECT m.file_id, m.title, m.performer, m.duration, m.file_size
            FROM music m
            JOIN playlist_music pm ON m.file_id = pm.file_id
            WHERE pm.playlist_id = ?
            ORDER BY pm.added_date
        ''', (playlist_id,))
        
        tracks = []
        for row in cursor.fetchall():
            file_id, title, performer, duration, file_size = row
            tracks.append({
                'file_id': file_id,
                'title': title,
                'performer': performer,
                'duration': duration,
                'file_size': file_size
            })
        
        return tracks
    
    def search_public_playlists(self, query: str) -> List[Dict]:
        """Поиск публичных плейлистов"""
        cursor = self.conn.cursor()
        cursor.execute('''
            SELECT p.playlist_id, p.name, p.display_name, p.description, 
                   u.username, p.created_date, COUNT(pm.file_id) as track_count
            FROM playlists p
            LEFT JOIN users u ON p.user_id = u.user_id
            LEFT JOIN playlist_music pm ON p.playlist_id = pm.playlist_id
            WHERE (p.privacy_type = 'public' OR (p.privacy_type IS NULL AND p.is_public = 1))
              AND (p.display_name LIKE ? OR p.description LIKE ? OR p.name LIKE ?)
            GROUP BY p.playlist_id
            ORDER BY p.created_date DESC
            LIMIT 10
        ''', (f'%{query}%', f'%{query}%', f'%{query}%'))
        
        playlists = []
        for row in cursor.fetchall():
            playlist_id, name, display_name, description, username, created_date, track_count = row
            playlists.append({
                'id': playlist_id,
                'name': name,
                'display_name': display_name or name,
                'description': description,
                'username': username or "Аноним",
                'created': created_date,
                'track_count': track_count
            })
        
        return playlists
    
    def get_playlist_info(self, playlist_id: str) -> Optional[Dict]:
        """Получение информации о плейлисте"""
        cursor = self.conn.cursor()
        cursor.execute('''
            SELECT p.playlist_id, p.name, p.display_name, p.description, p.user_id, 
                   u.username, p.created_date, p.is_public, p.privacy_type
            FROM playlists p
            LEFT JOIN users u ON p.user_id = u.user_id
            WHERE p.playlist_id = ?
        ''', (playlist_id,))
        
        row = cursor.fetchone()
        if not row:
            return None
        
        playlist_id, name, display_name, description, user_id, username, created_date, is_public, privacy_type = row
        
        # Если privacy_type не установлен, определяем по is_public
        if privacy_type is None:
            privacy_type = "public" if is_public else "private"
        
        # Если display_name не установлен, используем name
        if display_name is None:
            display_name = name
        
        # Получаем количество треков
        cursor.execute('''
            SELECT COUNT(*) FROM playlist_music WHERE playlist_id = ?
        ''', (playlist_id,))
        track_count = cursor.fetchone()[0]
        
        return {
            'id': playlist_id,
            'name': name,
            'display_name': display_name,
            'description': description,
            'user_id': user_id,
            'username': username or "Аноним",
            'created': created_date,
            'is_public': bool(is_public),
            'privacy_type': privacy_type,
            'track_count': track_count
        }
    
    def get_user_music(self, user_id: int) -> List[Dict]:
        """Получение музыки пользователя"""
        cursor = self.conn.cursor()
        cursor.execute('''
            SELECT file_id, title, performer, duration, file_size, upload_date
            FROM music 
            WHERE user_id = ?
            ORDER BY upload_date DESC
        ''', (user_id,))
        
        music = []
        for row in cursor.fetchall():
            file_id, title, performer, duration, file_size, upload_date = row
            music.append({
                'file_id': file_id,
                'title': title,
                'performer': performer,
                'duration': duration,
                'file_size': file_size,
                'upload_date': upload_date
            })
        
        return music
    
    def get_music_info(self, file_id: str) -> Optional[Dict]:
        """Получение информации о музыке по file_id"""
        cursor = self.conn.cursor()
        cursor.execute('''
            SELECT file_id, user_id, title, performer, duration, file_size, file_hash
            FROM music 
            WHERE file_id = ?
        ''', (file_id,))
        
        row = cursor.fetchone()
        if not row:
            return None
        
        file_id, user_id, title, performer, duration, file_size, file_hash = row
        return {
            'file_id': file_id,
            'user_id': user_id,
            'title': title,
            'performer': performer,
            'duration': duration,
            'file_size': file_size,
            'file_hash': file_hash
        }

# Создаем базу данных
print("📊 Инициализация базы данных...")
db = MusicDatabase()

class MusicBot:
    def __init__(self):
        self.user_data = {}
    
    def format_duration(self, seconds: int) -> str:
        """Форматирование длительности"""
        if not seconds:
            return "0:00"
        minutes = seconds // 60
        seconds = seconds % 60
        return f"{minutes}:{seconds:02d}"
    
    def format_size(self, bytes_size: int) -> str:
        """Форматирование размера файла"""
        if bytes_size < 1024:
            return f"{bytes_size} B"
        elif bytes_size < 1024 * 1024:
            return f"{bytes_size/1024:.1f} KB"
        else:
            return f"{bytes_size/(1024*1024):.1f} MB"
    
    def get_privacy_emoji(self, privacy_type: str) -> str:
        """Получить эмодзи для типа приватности"""
        if privacy_type == "public":
            return "🌍"
        elif privacy_type == "private":
            return "🔒"
        return "❓"
    
    def get_privacy_text(self, privacy_type: str) -> str:
        """Получить текст для типа приватности"""
        if privacy_type == "public":
            return "Публичный"
        elif privacy_type == "private":
            return "Приватный"
        return "Неизвестно"
    
    def create_main_keyboard(self) -> InlineKeyboardMarkup:
        """Главное меню"""
        keyboard = [
            [InlineKeyboardButton("🎵 Моя музыка", callback_data="my_music")],
            [InlineKeyboardButton("📁 Мои плейлисты", callback_data="my_playlists")],
            [InlineKeyboardButton("🌍 Публичные плейлисты", callback_data="public_playlists")],
            [InlineKeyboardButton("🔍 Поиск плейлистов", callback_data="search_playlists")],
            [InlineKeyboardButton("➕ Создать плейлист", callback_data="create_playlist")],
            [InlineKeyboardButton("📤 Загрузить музыку", callback_data="upload_music")]
        ]
        return InlineKeyboardMarkup(keyboard)
    
    def create_music_keyboard(self, page: int = 0, total_pages: int = 1) -> InlineKeyboardMarkup:
        """Клавиатура для музыки"""
        keyboard = []
        
        # Кнопки навигации
        nav_buttons = []
        if page > 0:
            nav_buttons.append(InlineKeyboardButton("⬅️ Назад", callback_data=f"music_page_{page-1}"))
        if page < total_pages - 1:
            nav_buttons.append(InlineKeyboardButton("Далее ➡️", callback_data=f"music_page_{page+1}"))
        
        if nav_buttons:
            keyboard.append(nav_buttons)
        
        keyboard.append([
            InlineKeyboardButton("🔙 Главное меню", callback_data="main_menu")
        ])
        
        return InlineKeyboardMarkup(keyboard)
    
    def create_playlists_keyboard(self, playlists: List[Dict], page: int = 0, 
                                 total_pages: int = 1, prefix: str = "playlist") -> InlineKeyboardMarkup:
        """Клавиатура для плейлистов"""
        keyboard = []
        
        for playlist in playlists:
            if prefix == "public":
                # Для публичных плейлистов показываем display_name (уникальное)
                name = playlist.get('display_name', playlist['name'])
            else:
                name = playlist['name']
            
            if len(name) > 25:
                name = name[:22] + "..."
            
            privacy_emoji = self.get_privacy_emoji(playlist.get('privacy_type', 'public'))
            button_text = f"{privacy_emoji} {name}"
            if 'track_count' in playlist:
                button_text += f" ({playlist['track_count']})"
            
            keyboard.append([
                InlineKeyboardButton(button_text, callback_data=f"{prefix}_{playlist['id']}")
            ])
        
        # Кнопки навигации
        nav_buttons = []
        if page > 0:
            nav_buttons.append(InlineKeyboardButton("⬅️ Назад", callback_data=f"{prefix}s_page_{page-1}"))
        if page < total_pages - 1:
            nav_buttons.append(InlineKeyboardButton("Далее ➡️", callback_data=f"{prefix}s_page_{page+1}"))
        
        if nav_buttons:
            keyboard.append(nav_buttons)
        
        keyboard.append([
            InlineKeyboardButton("🔙 Главное меню", callback_data="main_menu")
        ])
        
        return InlineKeyboardMarkup(keyboard)
    
    def create_playlist_detail_keyboard(self, playlist_id: str, user_id: int, 
                                      is_owner: bool = False) -> InlineKeyboardMarkup:
        """Клавиатура для детального просмотра плейлиста"""
        playlist_info = db.get_playlist_info(playlist_id)
        if not playlist_info:
            return self.create_main_keyboard()
        
        keyboard = []
        
        # Кнопка "Прослушать" для всех
        keyboard.append([
            InlineKeyboardButton("🎵 Прослушать плейлист", callback_data=f"play_{playlist_id}_0")
        ])
        
        if is_owner:
            # Владелец может редактировать плейлист
            keyboard.append([
                InlineKeyboardButton("➕ Добавить трек", callback_data=f"add_{playlist_id}"),
                InlineKeyboardButton("⚙️ Настройки", callback_data=f"settings_{playlist_id}")
            ])
            keyboard.append([
                InlineKeyboardButton("❌ Удалить", callback_data=f"del_{playlist_id}")
            ])
        else:
            # Не владелец - только просмотр
            keyboard.append([
                InlineKeyboardButton("📋 Список треков", callback_data=f"tracks_{playlist_id}_0")
            ])
        
        # Кнопка "Поделиться" только для публичных плейлистов
        if playlist_info['privacy_type'] == "public":
            keyboard.append([
                InlineKeyboardButton("🔗 Поделиться", callback_data=f"share_{playlist_id}")
            ])
        
        if is_owner:
            keyboard.append([
                InlineKeyboardButton("🔙 Назад к плейлистам", callback_data="my_playlists")
            ])
        else:
            keyboard.append([
                InlineKeyboardButton("🔙 Назад к плейлистам", callback_data="public_playlists")
            ])
        
        return InlineKeyboardMarkup(keyboard)
    
    def create_playlist_settings_keyboard(self, playlist_id: str, current_privacy: str) -> InlineKeyboardMarkup:
        """Клавиатура настроек приватности плейлиста"""
        keyboard = []
        
        # Кнопки выбора приватности
        privacy_options = [
            ("🌍 Публичный", "public"),
            ("🔒 Приватный", "private")
        ]
        
        for text, privacy_type in privacy_options:
            if privacy_type == current_privacy:
                text = f"✅ {text}"
            
            keyboard.append([
                InlineKeyboardButton(text, callback_data=f"setpriv_{playlist_id}_{privacy_type}")
            ])
        
        keyboard.append([
            InlineKeyboardButton("🔙 Назад", callback_data=f"playlist_{playlist_id}")
        ])
        
        return InlineKeyboardMarkup(keyboard)
    
    def create_track_selection_keyboard(self, music_list: List[Dict], playlist_id: str, 
                                       selected_tracks: List[str] = None) -> InlineKeyboardMarkup:
        """Клавиатура для выбора треков"""
        if selected_tracks is None:
            selected_tracks = []
        
        keyboard = []
        
        for music in music_list:
            title = music['title']
            if len(title) > 25:
                title = title[:22] + "..."
            
            is_selected = music['file_id'] in selected_tracks
            emoji = "✅" if is_selected else "🎵"
            
            # Укорачиваем file_id для callback_data (первые 20 символов)
            short_file_id = music['file_id'][:20]
            
            keyboard.append([
                InlineKeyboardButton(
                    f"{emoji} {title}", 
                    callback_data=f"select_{short_file_id}_{playlist_id}"
                )
            ])
        
        if selected_tracks:
            keyboard.append([
                InlineKeyboardButton("➕ Добавить выбранные", callback_data=f"finish_add_{playlist_id}")
            ])
        
        keyboard.append([
            InlineKeyboardButton("🔙 Назад", callback_data=f"playlist_{playlist_id}")
        ])
        
        return InlineKeyboardMarkup(keyboard)
    
    def create_privacy_selection_keyboard(self) -> InlineKeyboardMarkup:
        """Клавиатура выбора приватности при создании плейлиста"""
        keyboard = [
            [
                InlineKeyboardButton("🌍 Публичный", callback_data="privacy_public"),
                InlineKeyboardButton("🔒 Приватный", callback_data="privacy_private")
            ],
            [
                InlineKeyboardButton("❓ Что это?", callback_data="privacy_help")
            ],
            [
                InlineKeyboardButton("🔙 Главное меню", callback_data="main_menu")
            ]
        ]
        return InlineKeyboardMarkup(keyboard)
    
    def create_playlist_player_keyboard(self, playlist_id: str, track_index: int, total_tracks: int) -> InlineKeyboardMarkup:
        """Клавиатура для прослушивания плейлиста"""
        keyboard = []
        
        # Кнопки навигации
        nav_buttons = []
        
        # Кнопка "Назад" если не первый трек
        if track_index > 0:
            nav_buttons.append(
                InlineKeyboardButton("⏮ Назад", callback_data=f"play_{playlist_id}_{track_index-1}")
            )
        else:
            nav_buttons.append(
                InlineKeyboardButton("⏮", callback_data="#")
            )
        
        # Кнопка "Слушать" для текущего трека
        nav_buttons.append(
            InlineKeyboardButton("▶️ Слушать", callback_data=f"listen_{playlist_id}_{track_index}")
        )
        
        # Кнопка "Вперед" если не последний трек
        if track_index < total_tracks - 1:
            nav_buttons.append(
                InlineKeyboardButton("Вперед ⏭", callback_data=f"play_{playlist_id}_{track_index+1}")
            )
        else:
            nav_buttons.append(
                InlineKeyboardButton("⏭", callback_data="#")
            )
        
        if nav_buttons:
            keyboard.append(nav_buttons)
        
        # Быстрые кнопки навигации (если много треков)
        if total_tracks > 5:
            quick_nav = []
            # Показываем кнопки вокруг текущего трека
            start_nav = max(0, track_index - 2)
            end_nav = min(total_tracks, track_index + 3)
            
            for i in range(start_nav, end_nav):
                if i == track_index:
                    quick_nav.append(
                        InlineKeyboardButton(f"•{i+1}•", callback_data="#")
                    )
                else:
                    quick_nav.append(
                        InlineKeyboardButton(f"{i+1}", callback_data=f"play_{playlist_id}_{i}")
                    )
            
            if quick_nav:
                keyboard.append(quick_nav)
        
        # Дополнительные кнопки
        keyboard.append([
            InlineKeyboardButton("📋 Список треков", callback_data=f"tracks_{playlist_id}_0"),
            InlineKeyboardButton("🔁 Перемешать", callback_data=f"shuffle_{playlist_id}")
        ])
        
        # Кнопка возврата
        keyboard.append([
            InlineKeyboardButton("🔙 К плейлисту", callback_data=f"playlist_{playlist_id}")
        ])
        
        return InlineKeyboardMarkup(keyboard)
    
    def create_track_list_keyboard(self, playlist_id: str, tracks: List[Dict], page: int = 0, total_pages: int = 1) -> InlineKeyboardMarkup:
        """Клавиатура для списка треков с пагинацией"""
        keyboard = []
        
        # Показываем треки текущей страницы
        items_per_page = 8
        start_idx = page * items_per_page
        end_idx = min(start_idx + items_per_page, len(tracks))
        
        for i in range(start_idx, end_idx):
            track = tracks[i]
            title = track['title']
            if len(title) > 20:
                title = title[:17] + "..."
            
            keyboard.append([
                InlineKeyboardButton(
                    f"▶️ {i+1}. {title}", 
                    callback_data=f"play_{playlist_id}_{i}"
                )
            ])
        
        # Кнопки навигации по страницам
        nav_buttons = []
        if page > 0:
            nav_buttons.append(
                InlineKeyboardButton("⬅️ Назад", callback_data=f"tracks_{playlist_id}_{page-1}")
            )
        
        nav_buttons.append(
            InlineKeyboardButton(f"📄 {page+1}/{total_pages}", callback_data="#")
        )
        
        if page < total_pages - 1:
            nav_buttons.append(
                InlineKeyboardButton("Далее ➡️", callback_data=f"tracks_{playlist_id}_{page+1}")
            )
        
        if nav_buttons:
            keyboard.append(nav_buttons)
        
        # Основные кнопки
        keyboard.append([
            InlineKeyboardButton("🎵 Начать прослушивание", callback_data=f"play_{playlist_id}_0"),
            InlineKeyboardButton("🔙 Назад", callback_data=f"playlist_{playlist_id}")
        ])
        
        return InlineKeyboardMarkup(keyboard)

# Создаем бота
bot = MusicBot()

async def start_command(update: Update, context: ContextTypes.DEFAULT_TYPE):
    """Команда /start"""
    user = update.effective_user
    
    # Регистрируем пользователя
    db.add_user(user.id, user.username, user.first_name)
    
    welcome_text = (
        f"🎵 *Добро пожаловать, {user.first_name}!*\n\n"
        f"*Music Sharing Bot* - создавай плейлисты и делись музыкой!\n\n"
        f"🎯 *Возможности:*\n"
        f"• 📤 Загружай музыку файлами\n"
        f"• 📁 Создавай свои плейлисты (публичные/приватные)\n"
        f"• 🎵 Прослушивай плейлисты с удобной навигацией\n"
        f"• 🌍 Делись публичными плейлистами\n"
        f"• 🔍 Ищи публичные плейлисты по уникальному имени\n\n"
        f"🔒 *Уровни приватности:*\n"
        f"• 🌍 *Публичный* - уникальное имя, виден всем в поиске\n"
        f"• 🔒 *Приватный* - только для вас, не виден другим\n\n"
        f"🎧 *Прослушивание плейлистов:*\n"
        f"• Удобная навигация между треками\n"
        f"• Возможность выбирать конкретный трек\n"
        f"• Функция перемешивания\n"
        f"• Просмотр списка всех треков\n\n"
        f"🚀 *Выберите действие из меню ниже:*"
    )
    
    await update.message.reply_text(
        welcome_text,
        parse_mode='Markdown',
        reply_markup=bot.create_main_keyboard()
    )

async def main_menu(update: Update, context: ContextTypes.DEFAULT_TYPE):
    """Главное меню"""
    query = update.callback_query
    await query.answer()
    
    await query.edit_message_text(
        "🎵 *Главное меню*\n\nВыберите действие:",
        parse_mode='Markdown',
        reply_markup=bot.create_main_keyboard()
    )

async def show_my_music(update: Update, context: ContextTypes.DEFAULT_TYPE):
    """Показать музыку пользователя"""
    query = update.callback_query
    await query.answer()
    
    user_id = update.effective_user.id
    
    # Получаем музыку пользователя
    music_list = db.get_user_music(user_id)
    
    if not music_list:
        await query.edit_message_text(
            "🎵 *Ваша музыка*\n\nУ вас пока нет загруженной музыки.\nНажмите 'Загрузить музыку' чтобы добавить треки!",
            parse_mode='Markdown',
            reply_markup=InlineKeyboardMarkup([
                [InlineKeyboardButton("📤 Загрузить музыку", callback_data="upload_music")],
                [InlineKeyboardButton("🔙 Главное меню", callback_data="main_menu")]
            ])
        )
        return
    
    # Пагинация
    page = 0
    if query.data.startswith("music_page_"):
        page = int(query.data.split("_")[2])
    
    items_per_page = 5
    start_idx = page * items_per_page
    end_idx = start_idx + items_per_page
    total_pages = (len(music_list) + items_per_page - 1) // items_per_page
    
    # Формируем сообщение
    message_text = f"🎵 *Ваша музыка* (страница {page + 1}/{total_pages})\n\n"
    
    for i, music in enumerate(music_list[start_idx:end_idx], start=start_idx+1):
        duration = bot.format_duration(music['duration'])
        size = bot.format_size(music['file_size'])
        
        message_text += f"*{i}. {music['title']}*\n"
        message_text += f"👤 {music['performer']}\n"
        message_text += f"⏱ {duration} | 📊 {size}\n\n"
    
    await query.edit_message_text(
        message_text,
        parse_mode='Markdown',
        reply_markup=bot.create_music_keyboard(page, total_pages)
    )

async def show_my_playlists(update: Update, context: ContextTypes.DEFAULT_TYPE):
    """Показать плейлисты пользователя"""
    query = update.callback_query
    await query.answer()
    
    user_id = update.effective_user.id
    
    # Получаем плейлисты пользователя
    playlists = db.get_user_playlists(user_id)
    
    if not playlists:
        await query.edit_message_text(
            "📁 *Мои плейлисты*\n\nУ вас пока нет плейлистов.\nСоздайте первый плейлист!",
            parse_mode='Markdown',
            reply_markup=InlineKeyboardMarkup([
                [InlineKeyboardButton("➕ Создать плейлист", callback_data="create_playlist")],
                [InlineKeyboardButton("🔙 Главное меню", callback_data="main_menu")]
            ])
        )
        return
    
    # Пагинация
    page = 0
    if query.data.startswith("playlists_page_"):
        page = int(query.data.split("_")[2])
    
    items_per_page = 5
    start_idx = page * items_per_page
    end_idx = start_idx + items_per_page
    total_pages = (len(playlists) + items_per_page - 1) // items_per_page
    
    current_playlists = playlists[start_idx:end_idx]
    
    message_text = f"📁 *Мои плейлисты* (страница {page + 1}/{total_pages})\n\n"
    
    for playlist in current_playlists:
        privacy_emoji = bot.get_privacy_emoji(playlist['privacy_type'])
        privacy_text = bot.get_privacy_text(playlist['privacy_type'])
        
        message_text += f"{privacy_emoji} *{playlist['name']}* ({privacy_text})\n"
        if playlist['description']:
            message_text += f"📝 {playlist['description'][:50]}...\n"
        message_text += f"🎵 Треков: {playlist['track_count']}\n\n"
    
    await query.edit_message_text(
        message_text,
        parse_mode='Markdown',
        reply_markup=bot.create_playlists_keyboard(current_playlists, page, total_pages, "playlist")
    )

async def show_public_playlists(update: Update, context: ContextTypes.DEFAULT_TYPE):
    """Показать публичные плейлисты"""
    query = update.callback_query
    await query.answer()
    
    # Получаем публичные плейлисты
    playlists = db.get_public_playlists()
    
    if not playlists:
        await query.edit_message_text(
            "🌍 *Публичные плейлисты*\n\nПока нет публичных плейлистов.\nСоздайте первый публичный плейлист!",
            parse_mode='Markdown',
            reply_markup=InlineKeyboardMarkup([
                [InlineKeyboardButton("➕ Создать плейлист", callback_data="create_playlist")],
                [InlineKeyboardButton("🔙 Главное меню", callback_data="main_menu")]
            ])
        )
        return
    
    # Пагинация
    page = 0
    if query.data.startswith("publics_page_"):
        page = int(query.data.split("_")[2])
    
    items_per_page = 5
    start_idx = page * items_per_page
    end_idx = start_idx + items_per_page
    total_pages = (len(playlists) + items_per_page - 1) // items_per_page
    
    current_playlists = playlists[start_idx:end_idx]
    
    message_text = f"🌍 *Публичные плейлисты* (страница {page + 1}/{total_pages})\n\n"
    
    for playlist in current_playlists:
        message_text += f"📁 *{playlist['display_name']}*\n"
        message_text += f"👤 Автор: {playlist['username']}\n"
        if playlist['description']:
            message_text += f"📝 {playlist['description'][:50]}...\n"
        message_text += f"🎵 Треков: {playlist['track_count']}\n\n"
    
    await query.edit_message_text(
        message_text,
        parse_mode='Markdown',
        reply_markup=bot.create_playlists_keyboard(current_playlists, page, total_pages, "public")
    )

async def search_playlists_start(update: Update, context: ContextTypes.DEFAULT_TYPE):
    """Начать поиск плейлистов"""
    query = update.callback_query
    await query.answer()
    
    await query.edit_message_text(
        "🔍 *Поиск публичных плейлистов*\n\nВведите уникальное имя плейлиста для поиска:",
        parse_mode='Markdown',
        reply_markup=InlineKeyboardMarkup([
            [InlineKeyboardButton("🔙 Главное меню", callback_data="main_menu")]
        ])
    )
    
    return SEARCH_PLAYLIST

async def search_playlists(update: Update, context: ContextTypes.DEFAULT_TYPE):
    """Выполнить поиск плейлистов"""
    query = update.message.text.strip()
    
    if not query:
        await update.message.reply_text(
            "❌ Пожалуйста, введите поисковый запрос.",
            reply_markup=InlineKeyboardMarkup([
                [InlineKeyboardButton("🔙 Главное меню", callback_data="main_menu")]
            ])
        )
        return SEARCH_PLAYLIST
    
    # Ищем публичные плейлисты
    playlists = db.search_public_playlists(query)
    
    if not playlists:
        await update.message.reply_text(
            f"🔍 *Результаты поиска: '{query}'*\n\nНичего не найдено.",
            parse_mode='Markdown',
            reply_markup=InlineKeyboardMarkup([
                [InlineKeyboardButton("🔄 Новый поиск", callback_data="search_playlists")],
                [InlineKeyboardButton("🔙 Главное меню", callback_data="main_menu")]
            ])
        )
        return ConversationHandler.END
    
    message_text = f"🔍 *Результаты поиска: '{query}'*\n\n"
    
    for i, playlist in enumerate(playlists[:10], 1):
        message_text += f"{i}. 📁 *{playlist['display_name']}*\n"
        message_text += f"   👤 {playlist['username']}\n"
        if playlist['description']:
            message_text += f"   📝 {playlist['description'][:50]}...\n"
        message_text += f"   🎵 {playlist['track_count']} треков\n\n"
    
    # Создаем клавиатуру с результатами
    keyboard = []
    for playlist in playlists[:5]:
        keyboard.append([
            InlineKeyboardButton(
                f"📁 {playlist['display_name'][:20]}...", 
                callback_data=f"public_{playlist['id']}"
            )
        ])
    
    keyboard.append([
        InlineKeyboardButton("🔄 Новый поиск", callback_data="search_playlists"),
        InlineKeyboardButton("🔙 Главное меню", callback_data="main_menu")
    ])
    
    await update.message.reply_text(
        message_text,
        parse_mode='Markdown',
        reply_markup=InlineKeyboardMarkup(keyboard)
    )
    
    return ConversationHandler.END

async def create_playlist_start(update: Update, context: ContextTypes.DEFAULT_TYPE):
    """Начать создание плейлиста"""
    query = update.callback_query
    await query.answer()
    
    await query.edit_message_text(
        "➕ *Создание плейлиста*\n\nВведите название плейлиста:",
        parse_mode='Markdown',
        reply_markup=InlineKeyboardMarkup([
            [InlineKeyboardButton("🔙 Главное меню", callback_data="main_menu")]
        ])
    )
    
    return PLAYLIST_NAME

async def playlist_name_handler(update: Update, context: ContextTypes.DEFAULT_TYPE):
    """Обработчик названия плейлиста"""
    playlist_name = update.message.text.strip()
    
    if not playlist_name:
        await update.message.reply_text(
            "❌ Пожалуйста, введите название плейлиста.",
            reply_markup=InlineKeyboardMarkup([
                [InlineKeyboardButton("🔙 Главное меню", callback_data="main_menu")]
            ])
        )
        return PLAYLIST_NAME
    
    context.user_data['new_playlist_name'] = playlist_name
    
    await update.message.reply_text(
        "📝 *Описание плейлиста*\n\nВведите описание плейлиста (или пропустите, нажав /skip):",
        parse_mode='Markdown',
        reply_markup=InlineKeyboardMarkup([
            [InlineKeyboardButton("🔙 Главное меню", callback_data="main_menu")]
        ])
    )
    
    return PLAYLIST_DESC

async def playlist_desc_handler(update: Update, context: ContextTypes.DEFAULT_TYPE):
    """Обработчик описания плейлиста"""
    playlist_desc = update.message.text.strip()
    context.user_data['new_playlist_desc'] = playlist_desc
    
    await update.message.reply_text(
        "🔒 *Выберите уровень приватности:*\n\n🌍 *Публичный* - уникальное имя, виден всем в поиске\n🔒 *Приватный* - только для вас, не виден другим\n\nНажмите на кнопку для выбора:",
        parse_mode='Markdown',
        reply_markup=bot.create_privacy_selection_keyboard()
    )
    
    return PLAYLIST_PRIVACY

async def skip_playlist_desc(update: Update, context: ContextTypes.DEFAULT_TYPE):
    """Пропустить описание плейлиста"""
    context.user_data['new_playlist_desc'] = ""
    
    await update.message.reply_text(
        "🔒 *Выберите уровень приватности:*\n\n🌍 *Публичный* - уникальное имя, виден всем в поиске\n🔒 *Приватный* - только для вас, не виден другим\n\nНажмите на кнопку для выбора:",
        parse_mode='Markdown',
        reply_markup=bot.create_privacy_selection_keyboard()
    )
    
    return PLAYLIST_PRIVACY

async def privacy_help_handler(update: Update, context: ContextTypes.DEFAULT_TYPE):
    """Показать справку о типах приватности"""
    query = update.callback_query
    await query.answer()
    
    help_text = (
        "🔒 *Типы приватности плейлистов:*\n\n"
        "🌍 *Публичный:*\n"
        "• Уникальное имя (как username)\n"
        "• Виден всем пользователям в поиске\n"
        "• Отображается в списке публичных плейлистов\n"
        "• Любой пользователь может прослушать\n"
        "• Можно делиться ссылкой\n\n"
        "🔒 *Приватный:*\n"
        "• Виден только вам\n"
        "• Не отображается в поиске\n"
        "• Нельзя поделиться ссылкой\n"
        "• Только вы можете добавлять/редактировать треки\n\n"
        "💡 *Важно:*\n"
        "• Имена публичных плейлистов уникальны\n"
        "• Если имя уже занято, бот добавит номер (Например: 'МояМузыка_1')\n"
        "• Приватные плейлисты видны только вам\n\n"
        "Выберите тип приватности:"
    )
    
    await query.edit_message_text(
        help_text,
        parse_mode='Markdown',
        reply_markup=bot.create_privacy_selection_keyboard()
    )

async def privacy_selection_handler(update: Update, context: ContextTypes.DEFAULT_TYPE):
    """Обработчик выбора приватности"""
    query = update.callback_query
    await query.answer()
    
    privacy_type = query.data.split("_")[1]
    
    # Сохраняем выбранный тип приватности
    context.user_data['new_playlist_privacy'] = privacy_type
    
    # Завершаем создание плейлиста
    return await finish_playlist_creation(update, context)

async def finish_playlist_creation(update: Update, context: ContextTypes.DEFAULT_TYPE):
    """Завершить создание плейлиста"""
    user_id = update.effective_user.id
    playlist_name = context.user_data.get('new_playlist_name', '')
    playlist_desc = context.user_data.get('new_playlist_desc', '')
    privacy_type = context.user_data.get('new_playlist_privacy', 'public')
    
    # Создаем плейлист
    playlist_id = db.create_playlist(user_id, playlist_name, playlist_desc, privacy_type)
    
    # Получаем информацию о созданном плейлисте
    playlist_info = db.get_playlist_info(playlist_id)
    
    # Очищаем временные данные
    context.user_data.pop('new_playlist_name', None)
    context.user_data.pop('new_playlist_desc', None)
    context.user_data.pop('new_playlist_privacy', None)
    
    privacy_emoji = bot.get_privacy_emoji(privacy_type)
    privacy_text = bot.get_privacy_text(privacy_type)
    
    message_text = f"✅ *Плейлист создан!*\n\n📁 *Название:* {playlist_name}\n"
    
    if privacy_type == "public":
        message_text += f"🌍 *Публичное имя:* {playlist_info['display_name']}\n"
    
    message_text += f"📝 *Описание:* {playlist_desc or 'Нет описания'}\n"
    message_text += f"{privacy_emoji} *Приватность:* {privacy_text}\n\n"
    
    if privacy_type == "public":
        message_text += "💡 *Это публичный плейлист:*\n"
        message_text += "• Виден всем в поиске\n"
        message_text += "• Уникальное имя нельзя изменить\n"
        message_text += "• Можно делиться ссылкой\n"
    
    message_text += "\nТеперь вы можете добавлять музыку в этот плейлист."
    
    # Используем правильный метод в зависимости от типа обновления
    if update.callback_query:
        await update.callback_query.message.reply_text(
            message_text,
            parse_mode='Markdown',
            reply_markup=InlineKeyboardMarkup([
                [
                    InlineKeyboardButton("➕ Добавить треки", callback_data=f"add_{playlist_id}"),
                    InlineKeyboardButton("📁 Мои плейлисты", callback_data="my_playlists")
                ],
                [InlineKeyboardButton("🔙 Главное меню", callback_data="main_menu")]
            ])
        )
    else:
        await update.message.reply_text(
            message_text,
            parse_mode='Markdown',
            reply_markup=InlineKeyboardMarkup([
                [
                    InlineKeyboardButton("➕ Добавить треки", callback_data=f"add_{playlist_id}"),
                    InlineKeyboardButton("📁 Мои плейлисты", callback_data="my_playlists")
                ],
                [InlineKeyboardButton("🔙 Главное меню", callback_data="main_menu")]
            ])
        )
    
    return ConversationHandler.END

async def upload_music_start(update: Update, context: ContextTypes.DEFAULT_TYPE):
    """Начать загрузку музыки"""
    query = update.callback_query
    await query.answer()
    
    await query.edit_message_text(
        "📤 *Загрузка музыки*\n\nОтправьте аудиофайл (MP3, M4A, WAV и другие форматы).\nМаксимальный размер: 50MB",
        parse_mode='Markdown',
        reply_markup=InlineKeyboardMarkup([
            [InlineKeyboardButton("🔙 Главное меню", callback_data="main_menu")]
        ])
    )
    
    return UPLOAD

async def handle_audio_upload(update: Update, context: ContextTypes.DEFAULT_TYPE):
    """Обработчик загрузки аудио"""
    user_id = update.effective_user.id
    
    # Проверяем, что сообщение содержит аудио
    if update.message.audio:
        audio = update.message.audio
    elif update.message.document:
        # Проверяем MIME type документа
        mime_type = update.message.document.mime_type
        if mime_type and mime_type.startswith('audio/'):
            audio = update.message.document
        else:
            await update.message.reply_text(
                "❌ Пожалуйста, отправьте аудиофайл.",
                reply_markup=InlineKeyboardMarkup([
                    [InlineKeyboardButton("🔙 Главное меню", callback_data="main_menu")]
                ])
            )
            return UPLOAD
    else:
        await update.message.reply_text(
            "❌ Пожалуйста, отправьте аудиофайл.",
            reply_markup=InlineKeyboardMarkup([
                [InlineKeyboardButton("🔙 Главное меню", callback_data="main_menu")]
            ])
        )
        return UPLOAD
    
    # Проверяем размер файла
    if audio.file_size > 50 * 1024 * 1024:  # 50MB
        await update.message.reply_text(
            "❌ Файл слишком большой. Максимальный размер: 50MB",
            reply_markup=InlineKeyboardMarkup([
                [InlineKeyboardButton("🔄 Попробовать еще", callback_data="upload_music")],
                [InlineKeyboardButton("🔙 Главное меню", callback_data="main_menu")]
            ])
        )
        return UPLOAD
    
    # Получаем информацию о файле
    file_id = audio.file_id
    title = audio.title or "Без названия"
    performer = audio.performer or "Неизвестен"
    duration = audio.duration or 0
    file_size = audio.file_size
    
    # Генерируем хэш файла
    file_hash = hashlib.md5(f"{file_id}_{user_id}".encode()).hexdigest()
    
    # Сохраняем информацию в БД
    db.save_music_info(file_id, user_id, title, performer, duration, file_size, file_hash)
    
    duration_formatted = bot.format_duration(duration)
    size_formatted = bot.format_size(file_size)
    
    # УДАЛЯЕМ СООБЩЕНИЕ С ТРЕКОМ
    try:
        await context.bot.delete_message(
            chat_id=update.effective_chat.id,
            message_id=update.message.message_id
        )
    except Exception as e:
        print(f"Не удалось удалить сообщение: {e}")
    
    await update.message.reply_text(
        f"✅ *Музыка загружена и удалена из чата!*\n\n"
        f"🎵 *Название:* {title}\n"
        f"👤 *Исполнитель:* {performer}\n"
        f"⏱ *Длительность:* {duration_formatted}\n"
        f"📊 *Размер:* {size_formatted}\n\n"
        f"*Трек сохранен в базе данных и может быть добавлен в плейлисты.*\n"
        f"*При открытии плейлиста трек будет отправлен заново.*",
        parse_mode='Markdown',
        reply_markup=InlineKeyboardMarkup([
            [
                InlineKeyboardButton("🎵 Моя музыка", callback_data="my_music"),
                InlineKeyboardButton("📁 Мои плейлисты", callback_data="my_playlists")
            ],
            [InlineKeyboardButton("🔙 Главное меню", callback_data="main_menu")]
        ])
    )
    
    return ConversationHandler.END

async def show_playlist_detail(update: Update, context: ContextTypes.DEFAULT_TYPE):
    """Показать детали плейлиста"""
    query = update.callback_query
    await query.answer()
    
    prefix = query.data.split("_")[0]
    playlist_id = query.data.split("_")[1]
    playlist_info = db.get_playlist_info(playlist_id)
    
    if not playlist_info:
        await query.edit_message_text(
            "❌ Плейлист не найден.",
            reply_markup=bot.create_main_keyboard()
        )
        return
    
    user_id = update.effective_user.id
    is_owner = playlist_info['user_id'] == user_id
    
    # Для публичных плейлистов проверяем, что они действительно публичные
    if prefix == "public" and playlist_info['privacy_type'] != "public":
        await query.edit_message_text(
            "🔒 *Этот плейлист больше не публичный*\n\nВладелец изменил его приватность на приватный.",
            parse_mode='Markdown',
            reply_markup=InlineKeyboardMarkup([
                [InlineKeyboardButton("🔙 Назад к плейлистам", callback_data="public_playlists")]
            ])
        )
        return
    
    privacy_emoji = bot.get_privacy_emoji(playlist_info['privacy_type'])
    privacy_text = bot.get_privacy_text(playlist_info['privacy_type'])
    
    message_text = f"{privacy_emoji} *{playlist_info['name']}*\n\n"
    
    if playlist_info['privacy_type'] == "public":
        message_text += f"🌍 *Публичное имя:* {playlist_info['display_name']}\n\n"
    
    if playlist_info['description']:
        message_text += f"📝 {playlist_info['description']}\n\n"
    
    message_text += f"👤 *Автор:* {playlist_info['username']}\n"
    message_text += f"📅 *Создан:* {playlist_info['created'][:10]}\n"
    message_text += f"🎵 *Треков:* {playlist_info['track_count']}\n"
    message_text += f"🔒 *Приватность:* {privacy_text}\n\n"
    
    if is_owner:
        message_text += "*Вы владелец этого плейлиста*\n"
    
    await query.edit_message_text(
        message_text,
        parse_mode='Markdown',
        reply_markup=bot.create_playlist_detail_keyboard(playlist_id, user_id, is_owner)
    )

async def show_playlist_settings(update: Update, context: ContextTypes.DEFAULT_TYPE):
    """Показать настройки плейлиста"""
    query = update.callback_query
    await query.answer()
    
    playlist_id = query.data.split("_")[1]
    user_id = update.effective_user.id
    
    # Проверяем права доступа
    playlist_info = db.get_playlist_info(playlist_id)
    if not playlist_info or playlist_info['user_id'] != user_id:
        await query.edit_message_text(
            "❌ У вас нет прав для редактирования этого плейлиста.",
            reply_markup=bot.create_main_keyboard()
        )
        return
    
    privacy_emoji = bot.get_privacy_emoji(playlist_info['privacy_type'])
    privacy_text = bot.get_privacy_text(playlist_info['privacy_type'])
    
    message_text = f"⚙️ *Настройки плейлиста*\n\n📁 *{playlist_info['name']}*\n"
    
    if playlist_info['privacy_type'] == "public":
        message_text += f"🌍 *Публичное имя:* {playlist_info['display_name']}\n"
        message_text += f"💡 Это уникальное имя нельзя изменить\n\n"
    
    message_text += f"{privacy_emoji} *Текущая приватность:* {privacy_text}\n\n"
    message_text += "Выберите новый уровень приватности:"
    
    await query.edit_message_text(
        message_text,
        parse_mode='Markdown',
        reply_markup=bot.create_playlist_settings_keyboard(playlist_id, playlist_info['privacy_type'])
    )

async def set_playlist_privacy(update: Update, context: ContextTypes.DEFAULT_TYPE):
    """Установить новый уровень приватности плейлиста"""
    query = update.callback_query
    await query.answer()
    
    parts = query.data.split("_")
    playlist_id = parts[1]
    new_privacy = parts[2]
    user_id = update.effective_user.id
    
    # Проверяем права доступа
    playlist_info = db.get_playlist_info(playlist_id)
    if not playlist_info or playlist_info['user_id'] != user_id:
        await query.edit_message_text(
            "❌ У вас нет прав для редактирования этого плейлиста.",
            reply_markup=bot.create_main_keyboard()
        )
        return
    
    # Обновляем приватность
    db.update_playlist_privacy(playlist_id, new_privacy)
    
    # Получаем обновленную информацию
    playlist_info = db.get_playlist_info(playlist_id)
    
    privacy_emoji = bot.get_privacy_emoji(new_privacy)
    privacy_text = bot.get_privacy_text(new_privacy)
    
    message_text = f"✅ *Приватность обновлена!*\n\n📁 *{playlist_info['name']}*\n"
    
    if new_privacy == "public":
        message_text += f"🌍 *Публичное имя:* {playlist_info['display_name']}\n"
        message_text += f"💡 Это уникальное имя теперь видно всем\n\n"
    
    message_text += f"{privacy_emoji} *Новая приватность:* {privacy_text}\n\n"
    
    if new_privacy == "public":
        message_text += "🔗 Теперь вы можете делиться ссылкой на плейлист"
    else:
        message_text += "🔒 Плейлист теперь виден только вам"
    
    await query.edit_message_text(
        message_text,
        parse_mode='Markdown',
        reply_markup=InlineKeyboardMarkup([
            [InlineKeyboardButton("⚙️ Вернуться к настройкам", callback_data=f"settings_{playlist_id}")],
            [InlineKeyboardButton("🔙 К плейлисту", callback_data=f"playlist_{playlist_id}")]
        ])
    )

async def add_track_to_playlist(update: Update, context: ContextTypes.DEFAULT_TYPE):
    """Начать добавление треков в плейлист"""
    query = update.callback_query
    await query.answer()
    
    playlist_id = query.data.split("_")[1]
    user_id = update.effective_user.id
    
    # Проверяем права доступа (только владелец может добавлять треки)
    playlist_info = db.get_playlist_info(playlist_id)
    if not playlist_info or playlist_info['user_id'] != user_id:
        await query.edit_message_text(
            "❌ У вас нет прав для редактирования этого плейлиста.",
            reply_markup=bot.create_main_keyboard()
        )
        return
    
    # Получаем музыку пользователя
    music_list = db.get_user_music(user_id)
    
    if not music_list:
        await query.edit_message_text(
            "🎵 *Добавление треков*\n\nУ вас пока нет загруженной музыки.\nСначала загрузите музыку!",
            parse_mode='Markdown',
            reply_markup=InlineKeyboardMarkup([
                [InlineKeyboardButton("📤 Загрузить музыку", callback_data="upload_music")],
                [InlineKeyboardButton("🔙 Назад", callback_data=f"playlist_{playlist_id}")]
            ])
        )
        return
    
    # Инициализируем выбранные треки
    context.user_data['selected_tracks'] = []
    context.user_data['current_playlist'] = playlist_id
    
    await query.edit_message_text(
        f"➕ *Добавление в '{playlist_info['name']}'*\n\nВыберите треки для добавления (нажмите для выбора):",
        parse_mode='Markdown',
        reply_markup=bot.create_track_selection_keyboard(music_list, playlist_id)
    )

async def toggle_track_selection(update: Update, context: ContextTypes.DEFAULT_TYPE):
    """Переключить выбор трека"""
    query = update.callback_query
    await query.answer()
    
    parts = query.data.split("_")
    short_file_id = parts[1]
    playlist_id = parts[2]
    
    # Находим полный file_id
    user_id = update.effective_user.id
    music_list = db.get_user_music(user_id)
    
    full_file_id = None
    for music in music_list:
        if music['file_id'].startswith(short_file_id):
            full_file_id = music['file_id']
            break
    
    if not full_file_id:
        await query.answer("❌ Трек не найден", show_alert=True)
        return
    
    selected_tracks = context.user_data.get('selected_tracks', [])
    
    if full_file_id in selected_tracks:
        selected_tracks.remove(full_file_id)
    else:
        selected_tracks.append(full_file_id)
    
    context.user_data['selected_tracks'] = selected_tracks
    
    await query.edit_message_reply_markup(
        reply_markup=bot.create_track_selection_keyboard(
            music_list, playlist_id, selected_tracks
        )
    )

async def finish_add_tracks(update: Update, context: ContextTypes.DEFAULT_TYPE):
    """Завершить добавление выбранных треков"""
    query = update.callback_query
    await query.answer()
    
    playlist_id = query.data.split("_")[2]
    selected_tracks = context.user_data.get('selected_tracks', [])
    
    if not selected_tracks:
        await query.edit_message_text(
            "❌ Вы не выбрали ни одного трека.",
            reply_markup=InlineKeyboardMarkup([
                [InlineKeyboardButton("🔙 Назад", callback_data=f"playlist_{playlist_id}")]
            ])
        )
        return
    
    # Добавляем треки в плейлист
    added_count = 0
    for file_id in selected_tracks:
        try:
            db.add_to_playlist(playlist_id, file_id)
            added_count += 1
        except Exception as e:
            print(f"Ошибка при добавлении трека {file_id}: {e}")
    
    # Очищаем выбранные треки
    if 'selected_tracks' in context.user_data:
        context.user_data.pop('selected_tracks', None)
    
    playlist_info = db.get_playlist_info(playlist_id)
    
    await query.edit_message_text(
        f"✅ *Добавлено {added_count} треков в '{playlist_info['name']}'*\n\nТеперь в плейлисте {playlist_info['track_count']} треков.",
        parse_mode='Markdown',
        reply_markup=InlineKeyboardMarkup([
            [InlineKeyboardButton("🎵 Прослушать", callback_data=f"play_{playlist_id}_0")],
            [InlineKeyboardButton("🔙 К плейлисту", callback_data=f"playlist_{playlist_id}")]
        ])
    )

async def delete_playlist_handler(update: Update, context: ContextTypes.DEFAULT_TYPE):
    """Удалить плейлист"""
    query = update.callback_query
    await query.answer()
    
    playlist_id = query.data.split("_")[1]
    user_id = update.effective_user.id
    
    # Проверяем права доступа
    playlist_info = db.get_playlist_info(playlist_id)
    if not playlist_info or playlist_info['user_id'] != user_id:
        await query.edit_message_text(
            "❌ У вас нет прав для удаления этого плейлиста.",
            reply_markup=bot.create_main_keyboard()
        )
        return
    
    # Удаляем плейлист
    db.delete_playlist(playlist_id)
    
    await query.edit_message_text(
        f"✅ *Плейлист '{playlist_info['name']}' удален!*",
        parse_mode='Markdown',
        reply_markup=InlineKeyboardMarkup([
            [InlineKeyboardButton("📁 Мои плейлисты", callback_data="my_playlists")],
            [InlineKeyboardButton("🔙 Главное меню", callback_data="main_menu")]
        ])
    )

async def play_playlist(update: Update, context: ContextTypes.DEFAULT_TYPE):
    """Воспроизвести плейлист"""
    query = update.callback_query
    await query.answer()
    
    parts = query.data.split("_")
    playlist_id = parts[1]
    track_index = int(parts[2])
    user_id = update.effective_user.id
    
    # Получаем информацию о плейлисте
    playlist_info = db.get_playlist_info(playlist_id)
    
    # Проверяем доступ
    if not playlist_info:
        await query.edit_message_text(
            "❌ Плейлист не найден.",
            reply_markup=bot.create_main_keyboard()
        )
        return
    
    is_owner = playlist_info['user_id'] == user_id
    
    # Для не-владельцев: только публичные плейлисты
    if not is_owner and playlist_info['privacy_type'] != "public":
        await query.edit_message_text(
            "🔒 *Доступ запрещен*\n\nЭто приватный плейлист.",
            parse_mode='Markdown',
            reply_markup=InlineKeyboardMarkup([
                [InlineKeyboardButton("🔙 Назад к плейлистам", callback_data="public_playlists")]
            ])
        )
        return
    
    # Получаем треки из плейлиста
    tracks = db.get_playlist_tracks(playlist_id)
    
    if not tracks:
        await query.edit_message_text(
            "❌ В плейлисте нет треков.",
            reply_markup=InlineKeyboardMarkup([
                [InlineKeyboardButton("➕ Добавить треки", callback_data=f"add_{playlist_id}")],
                [InlineKeyboardButton("🔙 Назад", callback_data=f"playlist_{playlist_id}")]
            ])
        )
        return
    
    if track_index >= len(tracks):
        track_index = 0
    elif track_index < 0:
        track_index = len(tracks) - 1
    
    current_track = tracks[track_index]
    
    # Создаем сообщение с информацией о текущем треке
    message_text = (
        f"🎵 *Сейчас играет:*\n\n"
        f"📁 *Плейлист:* {playlist_info['name']}\n"
        f"🎵 *Трек {track_index + 1}/{len(tracks)}:* {current_track['title']}\n"
        f"👤 *Исполнитель:* {current_track['performer']}\n"
        f"⏱ *Длительность:* {bot.format_duration(current_track['duration'])}\n"
        f"📊 *Размер:* {bot.format_size(current_track['file_size'])}\n\n"
        f"Нажмите '▶️ Слушать' чтобы отправить этот трек."
    )
    
    # Создаем клавиатуру для управления воспроизведением
    keyboard = bot.create_playlist_player_keyboard(playlist_id, track_index, len(tracks))
    
    await query.edit_message_text(
        message_text,
        parse_mode='Markdown',
        reply_markup=keyboard
    )

async def send_track(update: Update, context: ContextTypes.DEFAULT_TYPE):
    """Отправить трек пользователю и показать следующий"""
    query = update.callback_query
    await query.answer()
    
    parts = query.data.split("_")
    playlist_id = parts[1]
    track_index = int(parts[2])
    user_id = update.effective_user.id
    
    # Получаем треки из плейлиста
    tracks = db.get_playlist_tracks(playlist_id)
    
    if not tracks or track_index >= len(tracks):
        await query.answer("❌ Трек не найден", show_alert=True)
        return
    
    current_track = tracks[track_index]
    playlist_info = db.get_playlist_info(playlist_id)
    
    try:
        # Отправляем аудиофайл из плейлиста
        await context.bot.send_audio(
            chat_id=update.effective_chat.id,
            audio=current_track['file_id'],
            caption=f"🎵 {current_track['title']}\n👤 {current_track['performer']}\n📁 {playlist_info['name']}\n\n💡 Используйте кнопки ниже для навигации по плейлисту.",
            parse_mode='Markdown'
        )
        
        # После отправки трека показываем сообщение с навигацией
        message_text = (
            f"✅ *Трек отправлен!*\n\n"
            f"📁 *Плейлист:* {playlist_info['name']}\n"
            f"🎵 *Трек {track_index + 1}/{len(tracks)}:* {current_track['title']}\n\n"
            f"Используйте кнопки для навигации:"
        )
        
        keyboard = bot.create_playlist_player_keyboard(playlist_id, track_index, len(tracks))
        
        await query.edit_message_text(
            message_text,
            parse_mode='Markdown',
            reply_markup=keyboard
        )
        
    except Exception as e:
        print(f"Ошибка при отправке трека: {e}")
        await query.answer("❌ Не удалось отправить трек", show_alert=True)

async def shuffle_playlist(update: Update, context: ContextTypes.DEFAULT_TYPE):
    """Перемешать плейлист"""
    query = update.callback_query
    await query.answer("🎲 Плейлист перемешан!")
    
    playlist_id = query.data.split("_")[1]
    user_id = update.effective_user.id
    
    # Получаем информацию о плейлисте
    playlist_info = db.get_playlist_info(playlist_id)
    
    if not playlist_info:
        await query.edit_message_text(
            "❌ Плейлист не найден.",
            reply_markup=bot.create_main_keyboard()
        )
        return
    
    is_owner = playlist_info['user_id'] == user_id
    
    # Для не-владельцев: только публичные плейлисты
    if not is_owner and playlist_info['privacy_type'] != "public":
        await query.edit_message_text(
            "🔒 *Доступ запрещен*\n\nЭто приватный плейлист.",
            parse_mode='Markdown',
            reply_markup=InlineKeyboardMarkup([
                [InlineKeyboardButton("🔙 Назад к плейлистам", callback_data="public_playlists")]
            ])
        )
        return
    
    # Получаем треки из плейлиста
    tracks = db.get_playlist_tracks(playlist_id)
    
    if not tracks:
        await query.edit_message_text(
            "❌ В плейлисте нет треков.",
            reply_markup=InlineKeyboardMarkup([
                [InlineKeyboardButton("➕ Добавить треки", callback_data=f"add_{playlist_id}")],
                [InlineKeyboardButton("🔙 Назад", callback_data=f"playlist_{playlist_id}")]
            ])
        )
        return
    
    # Выбираем случайный трек
    random_track_index = random.randint(0, len(tracks) - 1)
    
    # Переходим к случайному треку
    await play_playlist(update, context)

async def view_playlist_tracks(update: Update, context: ContextTypes.DEFAULT_TYPE):
    """Показать список треков в плейлисте с возможностью выбора"""
    query = update.callback_query
    await query.answer()
    
    parts = query.data.split("_")
    playlist_id = parts[1]
    page = int(parts[2]) if len(parts) > 2 else 0
    user_id = update.effective_user.id
    
    # Получаем информацию о плейлисте
    playlist_info = db.get_playlist_info(playlist_id)
    
    if not playlist_info:
        await query.edit_message_text(
            "❌ Плейлист не найден.",
            reply_markup=bot.create_main_keyboard()
        )
        return
    
    is_owner = playlist_info['user_id'] == user_id
    
    # Для не-владельцев: только публичные плейлисты
    if not is_owner and playlist_info['privacy_type'] != "public":
        await query.edit_message_text(
            "🔒 *Доступ запрещен*\n\nЭто приватный плейлист.",
            parse_mode='Markdown',
            reply_markup=InlineKeyboardMarkup([
                [InlineKeyboardButton("🔙 Назад к плейлистам", callback_data="public_playlists")]
            ])
        )
        return
    
    tracks = db.get_playlist_tracks(playlist_id)
    
    if not tracks:
        await query.edit_message_text(
            "❌ В плейлисте нет треков.",
            reply_markup=InlineKeyboardMarkup([
                [InlineKeyboardButton("➕ Добавить треки", callback_data=f"add_{playlist_id}")],
                [InlineKeyboardButton("🔙 Назад", callback_data=f"playlist_{playlist_id}")]
            ])
        )
        return
    
    # Пагинация
    items_per_page = 8
    total_pages = (len(tracks) + items_per_page - 1) // items_per_page
    
    if page >= total_pages:
        page = total_pages - 1
    if page < 0:
        page = 0
    
    start_idx = page * items_per_page
    end_idx = min(start_idx + items_per_page, len(tracks))
    
    message_text = f"📋 *Треки в плейлисте '{playlist_info['name']}':*\n"
    message_text += f"🎵 Всего треков: {len(tracks)} | Страница {page + 1}/{total_pages}\n\n"
    
    for i in range(start_idx, end_idx):
        track = tracks[i]
        duration = bot.format_duration(track['duration'])
        message_text += f"{i+1}. *{track['title']}*\n"
        message_text += f"   👤 {track['performer']} | ⏱ {duration}\n\n"
    
    # Создаем клавиатуру
    keyboard = bot.create_track_list_keyboard(playlist_id, tracks, page, total_pages)
    
    await query.edit_message_text(
        message_text,
        parse_mode='Markdown',
        reply_markup=keyboard
    )

async def share_playlist(update: Update, context: ContextTypes.DEFAULT_TYPE):
    """Поделиться плейлистом"""
    query = update.callback_query
    await query.answer()
    
    playlist_id = query.data.split("_")[1]
    playlist_info = db.get_playlist_info(playlist_id)
    user_id = update.effective_user.id
    
    # Проверяем права доступа и что плейлист публичный
    is_owner = playlist_info['user_id'] == user_id
    if not is_owner and playlist_info['privacy_type'] != "public":
        await query.edit_message_text(
            "🔒 *Доступ запрещен*\n\nУ вас нет доступа к этому плейлисту.",
            parse_mode='Markdown',
            reply_markup=InlineKeyboardMarkup([
                [InlineKeyboardButton("🔙 Назад к плейлистам", callback_data="public_playlists")]
            ])
        )
        return
    
    # Приватные плейлисты нельзя делиться
    if playlist_info['privacy_type'] != "public":
        await query.edit_message_text(
            "🔒 *Этот плейлист не публичный*\n\nТолько публичными плейлистами можно делиться.\nИзмените тип приватности в настройках плейлиста.",
            parse_mode='Markdown',
            reply_markup=InlineKeyboardMarkup([
                [InlineKeyboardButton("⚙️ Настройки", callback_data=f"settings_{playlist_id}")],
                [InlineKeyboardButton("🔙 Назад", callback_data=f"playlist_{playlist_id}")]
            ])
        )
        return
    
    share_link = f"https://t.me/{(await context.bot.get_me()).username}?start=playlist_{playlist_id}"
    
    message_text = (
        f"🔗 *Поделиться плейлистом*\n\n"
        f"📁 *{playlist_info['name']}*\n"
        f"🌍 *Публичное имя:* {playlist_info['display_name']}\n"
        f"👤 Автор: {playlist_info['username']}\n"
        f"🎵 Треков: {playlist_info['track_count']}\n\n"
        f"*Ссылка:*\n`{share_link}`\n\n"
        f"Отправьте эту ссылку друзьям!"
    )
    
    keyboard = [
        [InlineKeyboardButton("🔙 Назад", callback_data=f"playlist_{playlist_id}")]
    ]
    
    await query.edit_message_text(
        message_text,
        parse_mode='Markdown',
        reply_markup=InlineKeyboardMarkup(keyboard)
    )

async def like_playlist(update: Update, context: ContextTypes.DEFAULT_TYPE):
    """Добавить плейлист в избранное"""
    query = update.callback_query
    await query.answer("✅ Добавлено в избранное!")
    
    playlist_id = query.data.split("_")[1]
    user_id = update.effective_user.id
    
    # Получаем информацию о плейлисте
    playlist_info = db.get_playlist_info(playlist_id)
    
    if not playlist_info:
        await query.answer("❌ Плейлист не найден", show_alert=True)
        return
    
    is_owner = playlist_info['user_id'] == user_id
    
    # Для не-владельцев: только публичные плейлисты
    if not is_owner and playlist_info['privacy_type'] != "public":
        await query.answer("❌ Нет доступа к плейлисту", show_alert=True)
        return
    
    # Здесь можно добавить логику для добавления в избранное
    # Пока просто обновляем интерфейс
    await query.edit_message_reply_markup(
        reply_markup=bot.create_playlist_detail_keyboard(playlist_id, user_id, is_owner)
    )

async def cancel(update: Update, context: ContextTypes.DEFAULT_TYPE):
    """Отмена текущего действия"""
    await update.message.reply_text(
        "❌ Действие отменено.",
        reply_markup=bot.create_main_keyboard()
    )
    return ConversationHandler.END

async def error_handler(update: Update, context: ContextTypes.DEFAULT_TYPE):
    """Обработчик ошибок"""
    print(f"⚠️ Ошибка: {context.error}")

def main():
    """Запуск бота"""
    print("🤖 Запускаю Music Sharing Bot v1.2...")
    print(f"📁 Данные хранятся в: {DATA_DIR}")
    
    try:
        app = Application.builder().token(TOKEN).build()
        
        # Conversation Handler для создания плейлиста
        playlist_conv_handler = ConversationHandler(
            entry_points=[CallbackQueryHandler(create_playlist_start, pattern="^create_playlist$")],
            states={
                PLAYLIST_NAME: [MessageHandler(filters.TEXT & ~filters.COMMAND, playlist_name_handler)],
                PLAYLIST_DESC: [
                    MessageHandler(filters.TEXT & ~filters.COMMAND, playlist_desc_handler),
                    CommandHandler("skip", skip_playlist_desc)
                ],
                PLAYLIST_PRIVACY: [
                    CallbackQueryHandler(privacy_selection_handler, pattern="^privacy_(public|private)$"),
                    CallbackQueryHandler(privacy_help_handler, pattern="^privacy_help$")
                ],
            },
            fallbacks=[CommandHandler("cancel", cancel)],
        )
        
        # Conversation Handler для загрузки музыки
        upload_conv_handler = ConversationHandler(
            entry_points=[CallbackQueryHandler(upload_music_start, pattern="^upload_music$")],
            states={
                UPLOAD: [
                    MessageHandler(filters.AUDIO, handle_audio_upload),
                    MessageHandler(filters.Document.MimeType("audio/mpeg") | 
                                  filters.Document.MimeType("audio/mp4") |
                                  filters.Document.MimeType("audio/wav") |
                                  filters.Document.MimeType("audio/x-wav") |
                                  filters.Document.MimeType("audio/ogg"), 
                                  handle_audio_upload)
                ],
            },
            fallbacks=[CommandHandler("cancel", cancel)],
        )
        
        # Conversation Handler для поиска плейлистов
        search_conv_handler = ConversationHandler(
            entry_points=[
                CallbackQueryHandler(search_playlists_start, pattern="^search_playlists$")
            ],
            states={
                SEARCH_PLAYLIST: [
                    MessageHandler(filters.TEXT & ~filters.COMMAND, search_playlists),
                ],
            },
            fallbacks=[CommandHandler("cancel", cancel)],
        )
        
        # Добавляем обработчики
        app.add_handler(CommandHandler("start", start_command))
        app.add_handler(playlist_conv_handler)
        app.add_handler(upload_conv_handler)
        app.add_handler(search_conv_handler)
        
        # Обработчики кнопок
        app.add_handler(CallbackQueryHandler(main_menu, pattern="^main_menu$"))
        app.add_handler(CallbackQueryHandler(show_my_music, pattern="^my_music$"))
        app.add_handler(CallbackQueryHandler(show_my_music, pattern="^music_page_"))
        app.add_handler(CallbackQueryHandler(show_my_playlists, pattern="^my_playlists$"))
        app.add_handler(CallbackQueryHandler(show_my_playlists, pattern="^playlists_page_"))
        app.add_handler(CallbackQueryHandler(show_public_playlists, pattern="^public_playlists$"))
        app.add_handler(CallbackQueryHandler(show_public_playlists, pattern="^publics_page_"))
        
        # Обработчики плейлистов
        app.add_handler(CallbackQueryHandler(show_playlist_detail, pattern="^playlist_"))
        app.add_handler(CallbackQueryHandler(show_playlist_detail, pattern="^public_"))
        app.add_handler(CallbackQueryHandler(add_track_to_playlist, pattern="^add_"))
        app.add_handler(CallbackQueryHandler(toggle_track_selection, pattern="^select_"))
        app.add_handler(CallbackQueryHandler(finish_add_tracks, pattern="^finish_add_"))
        app.add_handler(CallbackQueryHandler(delete_playlist_handler, pattern="^del_"))
        app.add_handler(CallbackQueryHandler(play_playlist, pattern="^play_"))
        app.add_handler(CallbackQueryHandler(send_track, pattern="^listen_"))
        app.add_handler(CallbackQueryHandler(view_playlist_tracks, pattern="^tracks_"))
        app.add_handler(CallbackQueryHandler(shuffle_playlist, pattern="^shuffle_"))
        app.add_handler(CallbackQueryHandler(share_playlist, pattern="^share_"))
        app.add_handler(CallbackQueryHandler(like_playlist, pattern="^like_"))
        
        # Обработчики настроек приватности
        app.add_handler(CallbackQueryHandler(show_playlist_settings, pattern="^settings_"))
        app.add_handler(CallbackQueryHandler(set_playlist_privacy, pattern="^setpriv_"))
        
        app.add_error_handler(error_handler)
        
        print("✅ Бот готов к работе!")
        print("📱 Отправьте /start в Telegram")
        print("🎵 Загружайте музыку и создавайте плейлисты!")
        print("🎧 Прослушивайте плейлисты с удобной навигацией!")
        print("🌍 У публичных плейлистов уникальные имена (как username)")
        print("=" * 60)
        
        app.run_polling(allowed_updates=Update.ALL_TYPES, drop_pending_updates=True)
        
    except Exception as e:
        print(f"❌ Критическая ошибка: {e}")
        import traceback
        traceback.print_exc()
        input("Нажмите Enter для выхода...")

if __name__ == "__main__":
    main()
