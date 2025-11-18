-- RAGE MOD Chat Spammer для пиара тг канала (Neverlose стиль)
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TextChatService = game:GetService("TextChatService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

-- Настройки спама
local SpamEnabled = false
local SpamDelay = 2.0 -- Увеличенная задержка между сообщениями
local LastMessageTime = 0

-- Цветовая схема Neverlose
local COLOR_BACKGROUND = Color3.fromRGB(20, 20, 25)
local COLOR_ACCENT = Color3.fromRGB(0, 150, 255)
local COLOR_SECONDARY = Color3.fromRGB(30, 35, 45)
local COLOR_TEXT = Color3.fromRGB(240, 240, 240)
local COLOR_SUCCESS = Color3.fromRGB(0, 200, 83)
local COLOR_WARNING = Color3.fromRGB(255, 193, 7)
local COLOR_ERROR = Color3.fromRGB(255, 50, 50)

-- Разрешенные слова с вариациями (анти-фильтр)
local WordVariations = {
    -- Вариации "тэгэ"
    {"тэгэ", "теге", "тэге", "тегэ"},
    
    -- "expensivemods" без изменений
    {"expensivemods"},
    
    -- Вариации "заходим"
    {"заходим", "заходи", "заходьте", "заходите"},
    
    -- Вариации "в канал"
    {"в канал", "в канальчик", "в группу", "в паблик", "в сообщество"},
    
    -- Новые слова: "лучший чит"
    {"лучший чит", "топ чит", "крутой чит", "самый лучший чит", "лучший читинг"},
    
    -- Новые слова: "кому чит в"
    {"кому чит в", "кто хочет чит", "кому нужен чит", "кто ищет чит", "кому чит для"}
}

-- Дополнительные символы для обхода фильтра
local SpecialChars = {"", ".", "-", "•", "⚡", "✨", "💎", "🔥"}

-- Переменные для перемещения меню
local Dragging = false
local DragStart, StartPosition

-- Функция для создания вариаций текста с пробелами
local function createVariation()
    local random = Random.new()
    
    -- Выбираем случайный шаблон сообщения (с пробелами)
    local templates = {
        "{tag} {channel} {action} {invite}",
        "{best} {who} {tag} {channel}",
        "{channel} {best} {action} {invite}",
        "{who} {channel} {best} {tag}",
        "{best} {tag} {channel} {who}",
        "{action} {channel} {best} {who}",
        "{who} {best} {channel} {action}"
    }
    
    local template = templates[random:NextInteger(1, #templates)]
    
    -- Заменяем части сообщения
    local parts = {
        tag = WordVariations[1][random:NextInteger(1, #WordVariations[1])],
        channel = WordVariations[2][random:NextInteger(1, #WordVariations[2])],
        action = WordVariations[3][random:NextInteger(1, #WordVariations[3])],
        invite = WordVariations[4][random:NextInteger(1, #WordVariations[4])],
        best = WordVariations[5][random:NextInteger(1, #WordVariations[5])],
        who = WordVariations[6][random:NextInteger(1, #WordVariations[6])]
    }
    
    local message = template
    for key, value in pairs(parts) do
        message = string.gsub(message, "{"..key.."}", value)
    end
    
    -- Добавляем случайные специальные символы в начале или конце
    if random:NextNumber() > 0.5 then
        local char = SpecialChars[random:NextInteger(1, #SpecialChars)]
        if random:NextNumber() > 0.5 then
            message = char .. " " .. message
        else
            message = message .. " " .. char
        end
    end
    
    -- Гарантируем пробелы между словами
    message = string.gsub(message, "%s+", " ") -- Заменяем множественные пробелы на один
    message = string.gsub(message, "^%s*(.-)%s*$", "%1") -- Убираем пробелы в начале и конце
    
    return message
end

-- Функция для отправки сообщения
local function sendMessage(message)
    local success, result = pcall(function()
        if game:GetService("TextChatService").ChatVersion == Enum.ChatVersion.TextChatService then
            -- New chat system
            local channel = TextChatService.TextChannels.RBXGeneral
            if channel then
                channel:SendAsync(message)
            end
        else
            -- Legacy chat system
            ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:FireServer(message, "All")
        end
    end)
    
    if not success then
        warn("[RAGE MOD] Ошибка отправки: " .. tostring(result))
    end
end

-- Основной цикл спама
local spamConnection
local function startSpam()
    if spamConnection then
        spamConnection:Disconnect()
    end
    
    spamConnection = RunService.Heartbeat:Connect(function()
        if SpamEnabled and tick() - LastMessageTime >= SpamDelay then
            local message = createVariation()
            sendMessage(message)
            LastMessageTime = tick()
            
            -- Случайная задержка для обхода анти-спама (медленнее)
            SpamDelay = 1.5 + math.random() * 1.0
        end
    end)
end

-- Создание GUI в стиле Neverlose
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "RAGESpamUI"
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

-- Основной контейнер
local MainContainer = Instance.new("Frame")
MainContainer.Name = "MainContainer"
MainContainer.Size = UDim2.new(0, 400, 0, 300)
MainContainer.Position = UDim2.new(0.1, 0, 0.2, 0)
MainContainer.BackgroundColor3 = COLOR_BACKGROUND
MainContainer.BackgroundTransparency = 0.05
MainContainer.BorderSizePixel = 0
MainContainer.ClipsDescendants = true
MainContainer.Parent = ScreenGui

-- Внешняя обводка
local OuterStroke = Instance.new("UIStroke")
OuterStroke.Name = "OuterStroke"
OuterStroke.Color = COLOR_ACCENT
OuterStroke.Thickness = 2
OuterStroke.Transparency = 0.3
OuterStroke.Parent = MainContainer

-- Внутренняя тень
local InnerShadow = Instance.new("ImageLabel")
InnerShadow.Name = "InnerShadow"
InnerShadow.Size = UDim2.new(1, 0, 1, 0)
InnerShadow.BackgroundTransparency = 1
InnerShadow.Image = "rbxassetid://8577638923"
InnerShadow.ImageColor3 = Color3.new(0, 0, 0)
InnerShadow.ImageTransparency = 0.8
InnerShadow.ScaleType = Enum.ScaleType.Slice
InnerShadow.SliceCenter = Rect.new(10, 10, 118, 118)
InnerShadow.Parent = MainContainer

-- Заголовок (draggable)
local Header = Instance.new("Frame")
Header.Name = "Header"
Header.Size = UDim2.new(1, 0, 0, 40)
Header.Position = UDim2.new(0, 0, 0, 0)
Header.BackgroundColor3 = COLOR_SECONDARY
Header.BorderSizePixel = 0
Header.Parent = MainContainer

local HeaderGradient = Instance.new("UIGradient")
HeaderGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, COLOR_SECONDARY),
    ColorSequenceKeypoint.new(1, COLOR_ACCENT)
})
HeaderGradient.Rotation = 90
HeaderGradient.Parent = Header

-- Текст заголовка
local Title = Instance.new("TextLabel")
Title.Name = "Title"
Title.Size = UDim2.new(1, -80, 1, 0)
Title.Position = UDim2.new(0, 10, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "RAGE MOD | CHAT SPAMMER"
Title.TextColor3 = COLOR_TEXT
Title.TextSize = 14
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Header

-- Кнопка закрытия
local CloseButton = Instance.new("TextButton")
CloseButton.Name = "CloseButton"
CloseButton.Size = UDim2.new(0, 30, 0, 30)
CloseButton.Position = UDim2.new(1, -35, 0, 5)
CloseButton.BackgroundColor3 = COLOR_ERROR
CloseButton.BackgroundTransparency = 0.8
CloseButton.Text = "×"
CloseButton.TextColor3 = COLOR_TEXT
CloseButton.TextSize = 20
CloseButton.Font = Enum.Font.GothamBlack
CloseButton.Parent = Header

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 6)
CloseCorner.Parent = CloseButton

-- Основное содержимое
local Content = Instance.new("Frame")
Content.Name = "Content"
Content.Size = UDim2.new(1, -20, 1, -60)
Content.Position = UDim2.new(0, 10, 0, 50)
Content.BackgroundTransparency = 1
Content.Parent = MainContainer

-- Секция управления спамом
local SpamSection = Instance.new("Frame")
SpamSection.Name = "SpamSection"
SpamSection.Size = UDim2.new(1, 0, 0, 120)
SpamSection.BackgroundColor3 = COLOR_SECONDARY
SpamSection.BackgroundTransparency = 0.9
SpamSection.Parent = Content

local SpamCorner = Instance.new("UICorner")
SpamCorner.CornerRadius = UDim.new(0, 8)
SpamCorner.Parent = SpamSection

local SpamStroke = Instance.new("UIStroke")
SpamStroke.Color = COLOR_ACCENT
SpamStroke.Thickness = 1
SpamStroke.Transparency = 0.5
SpamStroke.Parent = SpamSection

local SpamTitle = Instance.new("TextLabel")
SpamTitle.Name = "SpamTitle"
SpamTitle.Size = UDim2.new(1, 0, 0, 30)
SpamTitle.BackgroundTransparency = 1
SpamTitle.Text = "SPAM CONTROL"
SpamTitle.TextColor3 = COLOR_ACCENT
SpamTitle.TextSize = 14
SpamTitle.Font = Enum.Font.GothamBold
SpamTitle.Parent = SpamSection

-- Кнопка переключения спама
local SpamToggle = Instance.new("TextButton")
SpamToggle.Name = "SpamToggle"
SpamToggle.Size = UDim2.new(1, -20, 0, 40)
SpamToggle.Position = UDim2.new(0, 10, 0, 35)
SpamToggle.BackgroundColor3 = COLOR_ERROR
SpamToggle.Text = "SPAM: DISABLED"
SpamToggle.TextColor3 = COLOR_TEXT
SpamToggle.TextSize = 12
SpamToggle.Font = Enum.Font.GothamBold
SpamToggle.Parent = SpamSection

local ToggleCorner = Instance.new("UICorner")
ToggleCorner.CornerRadius = UDim.new(0, 6)
ToggleCorner.Parent = SpamToggle

-- Секция информации
local InfoSection = Instance.new("Frame")
InfoSection.Name = "InfoSection"
InfoSection.Size = UDim2.new(1, 0, 0, 100)
InfoSection.Position = UDim2.new(0, 0, 0, 130)
InfoSection.BackgroundColor3 = COLOR_SECONDARY
InfoSection.BackgroundTransparency = 0.9
InfoSection.Parent = Content

local InfoCorner = Instance.new("UICorner")
InfoCorner.CornerRadius = UDim.new(0, 8)
InfoCorner.Parent = InfoSection

local InfoStroke = Instance.new("UIStroke")
InfoStroke.Color = COLOR_WARNING
InfoStroke.Thickness = 1
InfoStroke.Transparency = 0.5
InfoStroke.Parent = InfoSection

local InfoText = Instance.new("TextLabel")
InfoText.Name = "InfoText"
InfoText.Size = UDim2.new(1, -20, 1, -10)
InfoText.Position = UDim2.new(0, 10, 0, 5)
InfoText.BackgroundTransparency = 1
InfoText.Text = "RightShift - Toggle Spam\nDrag header to move\nSpam: Slow mode\nChannel: expensivemods"
InfoText.TextColor3 = COLOR_WARNING
InfoText.TextSize = 11
InfoText.Font = Enum.Font.Gotham
InfoText.TextXAlignment = Enum.TextXAlignment.Left
InfoText.TextYAlignment = Enum.TextYAlignment.Top
InfoText.Parent = InfoSection

-- Функции для перемещения меню
local function startDrag(input)
    Dragging = true
    DragStart = input.Position
    StartPosition = MainContainer.Position
    input.Changed:Connect(function()
        if input.UserInputState == Enum.UserInputState.End then
            Dragging = false
        end
    end)
end

local function updateDrag(input)
    if Dragging then
        local delta = input.Position - DragStart
        MainContainer.Position = UDim2.new(
            StartPosition.X.Scale,
            StartPosition.X.Offset + delta.X,
            StartPosition.Y.Scale,
            StartPosition.Y.Offset + delta.Y
        )
    end
end

-- Подписка на события перемещения
Header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        startDrag(input)
    end
end)

Header.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then
        updateDrag(input)
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then
        updateDrag(input)
    end
end)

-- Функция переключения спама
local function toggleSpam()
    SpamEnabled = not SpamEnabled
    
    if SpamEnabled then
        SpamToggle.Text = "SPAM: ENABLED"
        SpamToggle.BackgroundColor3 = COLOR_SUCCESS
        startSpam()
        warn("[RAGE MOD] Медленный спам запущен!")
    else
        SpamToggle.Text = "SPAM: DISABLED"
        SpamToggle.BackgroundColor3 = COLOR_ERROR
        if spamConnection then
            spamConnection:Disconnect()
        end
        warn("[RAGE MOD] Спам остановлен!")
    end
end

-- Обработчики событий
SpamToggle.MouseButton1Click:Connect(toggleSpam)
CloseButton.MouseButton1Click:Connect(function()
    MainContainer.Visible = false
end)

-- Горячие клавиши
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.KeyCode == Enum.KeyCode.RightShift then
        toggleSpam()
    end
end)

-- Функция для тестирования вариаций
local function testVariations()
    warn("[RAGE MOD] Тест вариаций (с пробелами):")
    for i = 1, 3 do
        local variation = createVariation()
        warn("Сообщение " .. i .. ": " .. variation)
    end
end

-- Анимация свечения
coroutine.wrap(function()
    while ScreenGui.Parent do
        for i = 1, 10 do
            if OuterStroke then
                OuterStroke.Transparency = 0.3 + (i * 0.07)
                wait(0.1)
            end
        end
        for i = 1, 10 do
            if OuterStroke then
                OuterStroke.Transparency = 1 - (i * 0.07)
                wait(0.1)
            end
        end
    end
end)()

-- Авто-тест при запуске
testVariations()

warn("[⚡] RAGE MOD Neverlose Spammer загружен!")
warn("Стиль: Neverlose с перемещаемым меню")
warn("Новые слова: 'лучший чит', 'кому чит в'")
warn("Скорость: Медленный спам (1.5-2.5 сек)")
warn("Формат: Четкие сообщения с пробелами")
warn("Горячие клавиши: RightShift - вкл/выкл спам")
warn("Перетаскивание: Дергайте за заголовок для перемещения")
