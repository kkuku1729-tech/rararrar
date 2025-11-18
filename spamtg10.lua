-- RAGE MOD Chat Spammer для пиара тг канала
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TextChatService = game:GetService("TextChatService")
local RunService = game:GetService("RunService")

-- Настройки спама
local SpamEnabled = false
local SpamDelay = 0.5 -- Задержка между сообщениями
local LastMessageTime = 0

-- Разрешенные слова с вариациями (анти-фильтр)
local WordVariations = {
    -- Вариации "тэгэ"
    {"тэгэ", "теге", "тэге", "тегэ", "тэгэ", "т е г э", "т-э-г-э"},
    
    -- "expensivemods" без изменений
    {"expensivemods"},
    
    -- Вариации "заходим"
    {"заходим", "заходи", "заходьте", "заходите", "з а х о д и м", "з-а-х-о-д-и-м"},
    
    -- Вариации "в канал" (замена "в тэгэшку")
    {"в канал", "в канальчик", "в группу", "в паблик", "в сообщество", "в каналчик"}
}

-- Дополнительные символы для обхода фильтра
local SpecialChars = {"", ".", "-", "_", " ", "  ", "   ", "•", "⚡", "✨", "💎", "🔥"}

-- Функция для создания вариаций текста
local function createVariation()
    local random = Random.new()
    
    -- Выбираем случайный шаблон сообщения
    local templates = {
        "{tag} {channel} {action} {invite}",
        "{action} {invite} {tag} {channel}",
        "{channel} {tag} {invite} {action}",
        "{invite} {action} {channel} {tag}",
        "{action} {channel} {invite}",
        "{channel} {action} {invite}",
        "{invite} {channel} {action}"
    }
    
    local template = templates[random:NextInteger(1, #templates)]
    
    -- Заменяем части сообщения
    local parts = {
        tag = WordVariations[1][random:NextInteger(1, #WordVariations[1])],
        channel = WordVariations[2][random:NextInteger(1, #WordVariations[2])],
        action = WordVariations[3][random:NextInteger(1, #WordVariations[3])],
        invite = WordVariations[4][random:NextInteger(1, #WordVariations[4])]
    }
    
    local message = template
    for key, value in pairs(parts) do
        message = string.gsub(message, "{"..key.."}", value)
    end
    
    -- Добавляем случайные специальные символы
    if random:NextNumber() > 0.7 then
        local char = SpecialChars[random:NextInteger(1, #SpecialChars)]
        message = char .. message .. char
    end
    
    -- Случайно меняем регистр некоторых букв (кроме expensivemods)
    if random:NextNumber() > 0.5 then
        local tempMessage = ""
        local inWord = false
        local currentWord = ""
        
        for i = 1, #message do
            local char = message:sub(i, i)
            
            if char:match("%S") then
                currentWord = currentWord .. char
                inWord = true
            else
                if inWord then
                    -- Если это не expensivemods, применяем случайный регистр
                    if currentWord ~= "expensivemods" and random:NextNumber() > 0.8 then
                        local newWord = ""
                        for j = 1, #currentWord do
                            local letter = currentWord:sub(j, j)
                            if random:NextNumber() > 0.5 then
                                letter = string.upper(letter)
                            end
                            newWord = newWord .. letter
                        end
                        tempMessage = tempMessage .. newWord
                    else
                        tempMessage = tempMessage .. currentWord
                    end
                    currentWord = ""
                    inWord = false
                end
                tempMessage = tempMessage .. char
            end
        end
        
        -- Обработка последнего слова
        if currentWord ~= "" and currentWord ~= "expensivemods" and random:NextNumber() > 0.8 then
            local newWord = ""
            for j = 1, #currentWord do
                local letter = currentWord:sub(j, j)
                if random:NextNumber() > 0.5 then
                    letter = string.upper(letter)
                end
                newWord = newWord .. letter
            end
            tempMessage = tempMessage .. newWord
        else
            tempMessage = tempMessage .. currentWord
        end
        
        message = tempMessage
    end
    
    -- Добавляем случайные пробелы (кроме expensivemods)
    if random:NextNumber() > 0.6 then
        local words = {}
        for word in message:gmatch("%S+") do
            if word ~= "expensivemods" and random:NextNumber() > 0.8 then
                word = word .. " "
            end
            table.insert(words, word)
        end
        message = table.concat(words)
    end
    
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
            
            -- Случайная задержка для обхода анти-спама
            SpamDelay = 0.3 + math.random() * 0.4
        end
    end)
end

-- GUI для управления спамом
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "RAGESpamUI"
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 350, 0, 200)
MainFrame.Position = UDim2.new(0, 10, 0, 10)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
MainFrame.BackgroundTransparency = 0.1
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui

local Stroke = Instance.new("UIStroke")
Stroke.Color = Color3.fromRGB(255, 0, 0)
Stroke.Thickness = 2
Stroke.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Name = "Title"
Title.Size = UDim2.new(1, 0, 0, 40)
Title.Position = UDim2.new(0, 0, 0, 0)
Title.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
Title.BackgroundTransparency = 0.2
Title.Text = "[⚡] RAGE MOD SPAMMER"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextScaled = true
Title.Font = Enum.Font.GothamBold
Title.Parent = MainFrame

local ToggleButton = Instance.new("TextButton")
ToggleButton.Name = "ToggleButton"
ToggleButton.Size = UDim2.new(0.8, 0, 0, 50)
ToggleButton.Position = UDim2.new(0.1, 0, 0.3, 0)
ToggleButton.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
ToggleButton.Text = "🚀 START SPAM"
ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleButton.TextScaled = true
ToggleButton.Font = Enum.Font.GothamBold
ToggleButton.Parent = MainFrame

local StatusLabel = Instance.new("TextLabel")
StatusLabel.Name = "StatusLabel"
StatusLabel.Size = UDim2.new(0.8, 0, 0, 30)
StatusLabel.Position = UDim2.new(0.1, 0, 0.7, 0)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = "Статус: Остановлен"
StatusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
StatusLabel.TextScaled = true
StatusLabel.Font = Enum.Font.Gotham
StatusLabel.Parent = MainFrame

local InfoLabel = Instance.new("TextLabel")
InfoLabel.Name = "InfoLabel"
InfoLabel.Size = UDim2.new(0.8, 0, 0, 40)
InfoLabel.Position = UDim2.new(0.1, 0, 0.85, 0)
InfoLabel.BackgroundTransparency = 1
InfoLabel.Text = "Пиар канала: expensivemods"
InfoLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
InfoLabel.TextScaled = true
InfoLabel.Font = Enum.Font.Gotham
InfoLabel.Parent = MainFrame

-- Обработчик кнопки
ToggleButton.MouseButton1Click:Connect(function()
    SpamEnabled = not SpamEnabled
    
    if SpamEnabled then
        ToggleButton.Text = "🛑 STOP SPAM"
        ToggleButton.BackgroundColor3 = Color3.fromRGB(50, 255, 50)
        StatusLabel.Text = "Статус: Работает"
        StatusLabel.TextColor3 = Color3.fromRGB(50, 255, 50)
        startSpam()
        warn("[RAGE MOD] Спам запущен!")
    else
        ToggleButton.Text = "🚀 START SPAM"
        ToggleButton.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
        StatusLabel.Text = "Статус: Остановлен"
        StatusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        if spamConnection then
            spamConnection:Disconnect()
        end
        warn("[RAGE MOD] Спам остановлен!")
    end
end)

-- Горячие клавиши
local UserInputService = game:GetService("UserInputService")
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.KeyCode == Enum.KeyCode.RightShift then
        SpamEnabled = not SpamEnabled
        
        if SpamEnabled then
            ToggleButton.Text = "🛑 STOP SPAM"
            ToggleButton.BackgroundColor3 = Color3.fromRGB(50, 255, 50)
            StatusLabel.Text = "Статус: Работает"
            StatusLabel.TextColor3 = Color3.fromRGB(50, 255, 50)
            startSpam()
        else
            ToggleButton.Text = "🚀 START SPAM"
            ToggleButton.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
            StatusLabel.Text = "Статус: Остановлен"
            StatusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
            if spamConnection then
                spamConnection:Disconnect()
            end
        end
    end
end)

-- Функция для тестирования вариаций
local function testVariations()
    warn("[RAGE MOD] Тест вариаций:")
    for i = 1, 5 do
        local variation = createVariation()
        warn("Вариация " .. i .. ": " .. variation)
    end
end

-- Авто-тест при запуске
testVariations()

warn("[⚡] RAGE MOD Spammer загружен!")
warn("Назначение: Пиар канала expensivemods")
warn("Горячие клавиши:")
warn("RightShift - Вкл/Выкл спам")
warn("Интерфейс расположен в левом верхнем углу")
warn("Сообщения автоматически меняются для обхода фильтра")
warn("Слово 'expensivemods' защищено от изменений")
