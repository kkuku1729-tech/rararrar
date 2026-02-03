import requests
from bs4 import BeautifulSoup
import re
from datetime import datetime
import time

class TagilNewsParser:
    def __init__(self):
        self.news = []
        # ОТБОРНЫЕ рабочие сайты Тагила
        self.sources = [
            {"name": "TagilCity.ru", "url": "https://tagilcity.ru", "type": "news_page"},
            {"name": "NTAGIL.org", "url": "https://ntagil.org", "type": "news_page"},
            {"name": "В-Тагиле.ру", "url": "https://v-tagile.ru", "type": "news_page"},
            {"name": "Tagil-Press.ru", "url": "https://tagil-press.ru", "type": "news_page"},
        ]
        
        self.headers = {
            'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36'
        }
    
    def is_valid_news_page(self, html):
        """Проверяет, что страница является настоящей новостью, а не ошибкой"""
        if not html:
            return False
        
        soup = BeautifulSoup(html, 'html.parser')
        text = soup.get_text().lower()
        
        # Проверяем на ошибки 404
        error_indicators = [
            'страница не найдена',
            '404',
            'ошибка 404',
            'не существует',
            'не найдена',
            'not found',
            'error 404'
        ]
        
        for indicator in error_indicators:
            if indicator in text:
                return False
        
        # Проверяем, что есть нормальный контент
        if len(text) < 200:  # Слишком короткая страница
            return False
        
        # Проверяем наличие заголовка
        title = soup.find('h1') or soup.find('title')
        if not title:
            return False
        
        title_text = title.get_text(strip=True).lower()
        
        # Исключаем служебные заголовки
        bad_titles = [
            'главная',
            'ошибка',
            'страница 404',
            'not found',
            'при использовании информации',
            'copyright',
            'все права защищены'
        ]
        
        for bad in bad_titles:
            if bad in title_text:
                return False
        
        # Проверяем, что заголовок имеет нормальную длину
        if len(title_text) < 10 or len(title_text) > 150:
            return False
        
        return True
    
    def get_news_from_tagilcity(self):
        """Получает новости с TagilCity.ru"""
        try:
            print("🔍 Парсим TagilCity.ru...")
            url = "https://tagilcity.ru/news"
            
            response = requests.get(url, headers=self.headers, timeout=10)
            soup = BeautifulSoup(response.text, 'html.parser')
            
            # Ищем ссылки на новости
            news_links = []
            
            # Способ 1: Ищем по структуре сайта
            news_items = soup.find_all(['article', 'div'], class_=lambda x: x and ('news' in x.lower() or 'article' in x.lower()))
            
            for item in news_items:
                link_tag = item.find('a', href=True)
                if link_tag:
                    href = link_tag['href']
                    if not href.startswith('http'):
                        href = 'https://tagilcity.ru' + href if href.startswith('/') else f'https://tagilcity.ru/{href}'
                    
                    title = link_tag.get_text(strip=True)
                    if title and len(title) > 20:
                        news_links.append((title, href))
            
            # Способ 2: Ищем все ссылки, содержащие /news/
            all_links = soup.find_all('a', href=True)
            for link in all_links:
                href = link['href']
                if '/news/' in href and 'tagilcity.ru' in href:
                    title = link.get_text(strip=True)
                    if title and len(title) > 10:
                        if not href.startswith('http'):
                            href = 'https://tagilcity.ru' + href
                        news_links.append((title, href))
            
            # Обрабатываем найденные ссылки
            for title, link in news_links[:10]:  # Берем первые 10
                news_details = self.get_news_details(link, 'TagilCity.ru')
                if news_details and news_details['title'] != 'Страница 404':
                    self.news.append(news_details)
                    print(f"   ✓ Найдена: {news_details['title'][:50]}...")
            
            print(f"   Всего валидных новостей: {len([n for n in self.news if n['source'] == 'TagilCity.ru'])}")
            
        except Exception as e:
            print(f"   ❌ Ошибка: {str(e)[:50]}")
    
    def get_news_from_ntagil(self):
        """Получает новости с NTAGIL.org"""
        try:
            print("🔍 Парсим NTAGIL.org...")
            url = "https://ntagil.org/news"
            
            response = requests.get(url, headers=self.headers, timeout=10)
            soup = BeautifulSoup(response.text, 'html.parser')
            
            # Простой поиск по ссылкам
            news_links = []
            all_links = soup.find_all('a', href=True)
            
            for link in all_links:
                href = link['href']
                title = link.get_text(strip=True)
                
                # Фильтруем нормальные новости
                if (title and len(title) > 15 and 
                    not any(word in title.lower() for word in ['главная', 'поиск', 'о нас', 'контакты'])):
                    
                    if href.startswith('/'):
                        href = 'https://ntagil.org' + href
                    elif not href.startswith('http'):
                        href = f'https://ntagil.org/{href}'
                    
                    # Проверяем, что это похоже на новость
                    if 'news' in href.lower() or 'novosti' in href.lower():
                        news_links.append((title, href))
            
            # Обрабатываем найденные ссылки
            for title, link in news_links[:10]:
                news_details = self.get_news_details(link, 'NTAGIL.org')
                if news_details and news_details['title'] != 'Страница 404':
                    self.news.append(news_details)
            
            print(f"   Всего валидных новостей: {len([n for n in self.news if n['source'] == 'NTAGIL.org'])}")
            
        except Exception as e:
            print(f"   ❌ Ошибка: {str(e)[:50]}")
    
    def get_news_from_vtagile(self):
        """Получает новости с В-Тагиле.ру"""
        try:
            print("🔍 Парсим В-Тагиле.ру...")
            url = "https://v-tagile.ru/novosti"
            
            response = requests.get(url, headers=self.headers, timeout=10)
            soup = BeautifulSoup(response.text, 'html.parser')
            
            # Ищем заголовки и ссылки
            news_items = []
            
            # Ищем заголовки h2-h4
            for tag in ['h2', 'h3', 'h4']:
                for heading in soup.find_all(tag):
                    title = heading.get_text(strip=True)
                    if title and len(title) > 20:
                        # Ищем ближайшую ссылку
                        link_tag = heading.find_parent('a') or heading.find_next('a')
                        if link_tag and link_tag.get('href'):
                            href = link_tag['href']
                            if not href.startswith('http'):
                                href = 'https://v-tagile.ru' + href if href.startswith('/') else f'https://v-tagile.ru/{href}'
                            news_items.append((title, href))
            
            # Обрабатываем
            for title, link in news_items[:8]:
                news_details = self.get_news_details(link, 'В-Тагиле.ру')
                if news_details and news_details['title'] != 'Страница 404':
                    self.news.append(news_details)
            
            print(f"   Всего валидных новостей: {len([n for n in self.news if n['source'] == 'В-Тагиле.ру'])}")
            
        except Exception as e:
            print(f"   ❌ Ошибка: {str(e)[:50]}")
    
    def get_news_details(self, url, source_name):
        """Получает детали новости с проверкой валидности"""
        try:
            # Получаем страницу
            response = requests.get(url, headers=self.headers, timeout=5)
            
            # Проверяем, что страница существует и не ошибка 404
            if response.status_code != 200:
                return None
            
            soup = BeautifulSoup(response.text, 'html.parser')
            
            # Проверяем на ошибки 404
            page_text = soup.get_text().lower()
            if any(error in page_text for error in ['404', 'страница не найдена', 'not found']):
                return None
            
            # Ищем заголовок
            title = None
            for tag in ['h1', 'h2', 'h3', 'title']:
                element = soup.find(tag)
                if element:
                    candidate = element.get_text(strip=True)
                    # Фильтруем плохие заголовки
                    if (candidate and len(candidate) > 10 and 
                        not any(bad in candidate.lower() for bad in ['404', 'ошибка', 'страница не найдена',
                                                                    'при использовании информации',
                                                                    'copyright', 'все права защищены'])):
                        title = candidate
                        break
            
            if not title:
                return None
            
            # Ищем дату
            date_text = self.extract_date(soup)
            
            # Ищем описание
            description = self.extract_description(soup, title)
            
            # Проверяем, что описание не содержит ошибок
            if description and any(error in description.lower() for error in ['404', 'страница не найдена']):
                description = ""
            
            return {
                'title': title[:150],
                'link': url,
                'source': source_name,
                'date': date_text,
                'time': datetime.now().strftime("%H:%M"),
                'description': description[:200] + '...' if len(description) > 200 else description
            }
            
        except Exception as e:
            return None
    
    def extract_date(self, soup):
        """Извлекает дату"""
        # Ищем разные варианты даты
        date_patterns = [
            'time',
            '.date',
            '.datetime',
            '.post-date',
            '.news-date',
            '[class*="date"]',
            '[class*="time"]'
        ]
        
        for pattern in date_patterns:
            element = soup.select_one(pattern)
            if element:
                date_text = element.get_text(strip=True)
                if date_text and len(date_text) > 5:
                    # Убираем лишнее
                    date_text = re.sub(r'[^\w\s\.\-\/:]', '', date_text)
                    return date_text[:30]
        
        return datetime.now().strftime("%d.%m.%Y")
    
    def extract_description(self, soup, title):
        """Извлекает описание новости"""
        # Ищем основной контент
        content_selectors = [
            'article',
            '.content',
            '.article-content',
            '.post-content',
            '.news-content',
            '.text',
            '[class*="content"]',
            '[class*="text"]'
        ]
        
        for selector in content_selectors:
            element = soup.select_one(selector)
            if element:
                text = element.get_text(strip=True)
                # Убираем заголовок из текста
                text = text.replace(title, '').strip()
                if text and len(text) > 50:
                    # Убираем мусор
                    text = re.sub(r'\s+', ' ', text)
                    return text
        
        # Если не нашли, берем первые абзацы
        paragraphs = soup.find_all('p')
        text_parts = []
        for p in paragraphs[:3]:
            text = p.get_text(strip=True)
            if text and len(text) > 20 and text != title:
                text_parts.append(text)
        
        if text_parts:
            return ' '.join(text_parts)
        
        return ""
    
    def remove_duplicates(self):
        """Удаляет дубликаты новостей"""
        seen = set()
        unique_news = []
        
        for news in self.news:
            # Создаем ключ из заголовка и источника
            key = (news['title'].lower(), news['source'])
            if key not in seen:
                seen.add(key)
                unique_news.append(news)
        
        self.news = unique_news
    
    def get_all_news(self):
        """Получает все новости"""
        print("="*70)
        print("🔍 ПОИСК АКТУАЛЬНЫХ НОВОСТЕЙ НИЖНЕГО ТАГИЛА")
        print("="*70)
        print("Проверяю только рабочие сайты...\n")
        
        # Получаем новости с каждого сайта
        self.get_news_from_tagilcity()
        time.sleep(1)
        
        self.get_news_from_ntagil()
        time.sleep(1)
        
        self.get_news_from_vtagile()
        
        # Удаляем дубликаты
        self.remove_duplicates()
        
        print(f"\n✅ Поиск завершен! Найдено: {len(self.news)} валидных новостей")
        return self.news
    
    def save_to_file(self, filename="tagil_news.txt"):
        """Сохраняет новости в файл"""
        if not self.news:
            print("⚠️ Нет валидных новостей для сохранения")
            return
        
        with open(filename, 'w', encoding='utf-8') as f:
            f.write("="*70 + "\n")
            f.write(f"НОВОСТИ НИЖНЕГО ТАГИЛА (проверенные)\n")
            f.write(f"Дата сбора: {datetime.now().strftime('%d.%m.%Y %H:%M')}\n")
            f.write(f"Всего новостей: {len(self.news)}\n")
            f.write("="*70 + "\n\n")
            
            # Группируем по источникам
            sources_dict = {}
            for news in self.news:
                source = news['source']
                if source not in sources_dict:
                    sources_dict[source] = []
                sources_dict[source].append(news)
            
            # Записываем по источникам
            for source, news_list in sorted(sources_dict.items()):
                f.write(f"\n📍 {source} ({len(news_list)} новостей):\n")
                f.write("-"*60 + "\n\n")
                
                for i, news in enumerate(news_list, 1):
                    f.write(f"{i}. {news['title']}\n")
                    f.write(f"   📅 Дата: {news['date']}\n")
                    if news['description']:
                        f.write(f"   📝 {news['description']}\n")
                    f.write(f"   🔗 Ссылка: {news['link']}\n")
                    f.write("-"*40 + "\n\n")
        
        print(f"💾 Новости сохранены в файл: {filename}")
    
    def print_news(self):
        """Печатает найденные новости"""
        if not self.news:
            print("\n⚠️ Не найдено валидных новостей")
            print("\nПроверьте сайты вручную:")
            print("• https://tagilcity.ru/news")
            print("• https://ntagil.org/news")
            print("• https://v-tagile.ru/novosti")
            return
        
        print(f"\n{'='*70}")
        print(f"📰 НАЙДЕННЫЕ НОВОСТИ ({len(self.news)} шт.)")
        print(f"{'='*70}\n")
        
        for i, news in enumerate(self.news, 1):
            print(f"{i}. {news['title']}")
            print(f"   📍 {news['source']}")
            print(f"   📅 {news['date']}")
            if news['description']:
                print(f"   📝 {news['description'][:100]}...")
            print(f"   🔗 {news['link']}")
            print()

# Основная программа
def main():
    print("""
    ╔══════════════════════════════════════════════╗
    ║    ПАРСЕР НОВОСТЕЙ НИЖНЕГО ТАГИЛА           ║
    ║    (только рабочие новости, без ошибок)     ║
    ╚══════════════════════════════════════════════╝
    """)
    
    parser = TagilNewsParser()
    
    # Получаем новости
    news = parser.get_all_news()
    
    if news:
        # Показываем
        parser.print_news()
        
        # Сохраняем
        parser.save_to_file()
        
        print(f"✅ Готово! Проверено 3 основных сайта.")
        print(f"   Сохранено {len(news)} валидных новостей без ошибок 404.")
    else:
        print("\n⚠️ В данный момент не удалось найти новости.")
        print("   Попробуйте позже или проверьте сайты вручную.")

# Запуск
if __name__ == "__main__":
    main()
    input("\nНажмите Enter для выхода...")
