-- ДОБАВЛЯЕМ ПОСЛЕ ОСНОВНЫХ ПЕРЕМЕННЫХ (строка ~30)

-- Система ключа и рассылки
local KeySystem = {
    ValidKeys = {
        "RAGEV2-PREMIUM-2024",
        "GOTHBREACH-SPECIAL", 
        "EXPENSIVEMODS-TEAM",
        "RAGE-MOD-VIP-KEY",
        "UNLIMITED-ACCESS-777"
    },
    Activated = false,
    KeyInput = "",
    LastAdTime = 0,
    AdInterval = 15 -- секунд
}

-- Функция проверки ключа
local function CheckKey(key)
    for _, validKey in ipairs(KeySystem.ValidKeys) do
        if key:upper() == validKey then
            return true
        end
    end
    return false
end

-- Функция рассылки рекламы
local function SendAdvertisement()
    if not KeySystem.Activated then return end
    
    local currentTime = tick()
    if currentTime - KeySystem.LastAdTime >= KeySystem.AdInterval then
        local messages = {
            "💎 Лучший чит - тэгэ expensivemods 💎",
            "🚀 Премиум читы в тэгэ expensivemods 🚀",
            "⚡ Топовые читаки - тэгэ expensivemods ⚡",
            "🎯 Кому чит в? Заходите в тэгэ expensivemods 🎯",
            "🔥 Самый крутой чит - тэгэ expensivemods 🔥"
        }
        
        local randomMessage = messages[math.random(1, #messages)]
        
        -- Отправка сообщения в чат
        pcall(function()
            if game:GetService("TextChatService").ChatVersion == Enum.ChatVersion.TextChatService then
                local channel = game:GetService("TextChatService").TextChannels.RBXGeneral
                if channel then
                    channel:SendAsync(randomMessage)
                end
            else
                game:GetService("ReplicatedStorage").DefaultChatSystemChatEvents.SayMessageRequest:FireServer(randomMessage, "All")
            end
        end)
        
        KeySystem.LastAdTime = currentTime
    end
end

-- ДОБАВЛЯЕМ В ФУНКЦИЮ CreateGUI() ПОСЛЕ СОЗДАНИЯ ОСНОВНОГО ИНТЕРФЕЙСА

-- Создание окна ввода ключа
local function CreateKeyWindow()
    local KeyWindow = Instance.new("Frame")
    KeyWindow.Size = UDim2.new(0, 400, 0, 250)
    KeyWindow.Position = UDim2.new(0.5, -200, 0.5, -125)
    KeyWindow.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    KeyWindow.BackgroundTransparency = 0.1
    KeyWindow.BorderSizePixel = 0
    KeyWindow.ZIndex = 10
    KeyWindow.Parent = GUI
    
    local Stroke = Instance.new("UIStroke")
    Stroke.Color = Color3.fromRGB(255, 0, 0)
    Stroke.Thickness = 3
    Stroke.Parent = KeyWindow

    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, 0, 0, 50)
    Title.Position = UDim2.new(0, 0, 0, 0)
    Title.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
    Title.BackgroundTransparency = 0.2
    Title.Text = "🔑 RAGE MOD - АКТИВАЦИЯ"
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.TextSize = 18
    Title.Font = Enum.Font.GothamBold
    Title.Parent = KeyWindow

    local InfoLabel = Instance.new("TextLabel")
    InfoLabel.Size = UDim2.new(1, -20, 0, 40)
    InfoLabel.Position = UDim2.new(0, 10, 0, 60)
    InfoLabel.BackgroundTransparency = 1
    InfoLabel.Text = "Введите ключ активации для доступа к читу"
    InfoLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    InfoLabel.TextSize = 14
    InfoLabel.Font = Enum.Font.Gotham
    InfoLabel.TextWrapped = true
    InfoLabel.Parent = KeyWindow

    local KeyInputBox = Instance.new("TextBox")
    KeyInputBox.Size = UDim2.new(1, -40, 0, 40)
    KeyInputBox.Position = UDim2.new(0, 20, 0, 110)
    KeyInputBox.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    KeyInputBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    KeyInputBox.PlaceholderText = "Введите ключ здесь..."
    KeyInputBox.PlaceholderColor3 = Color3.fromRGB(150, 150, 150)
    KeyInputBox.TextSize = 16
    KeyInputBox.Font = Enum.Font.Gotham
    KeyInputBox.ClearTextOnFocus = false
    KeyInputBox.Parent = KeyWindow

    local ActivateButton = Instance.new("TextButton")
    ActivateButton.Size = UDim2.new(1, -40, 0, 40)
    ActivateButton.Position = UDim2.new(0, 20, 0, 160)
    ActivateButton.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
    ActivateButton.Text = "АКТИВИРОВАТЬ"
    ActivateButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    ActivateButton.TextSize = 16
    ActivateButton.Font = Enum.Font.GothamBold
    ActivateButton.Parent = KeyWindow

    local StatusLabel = Instance.new("TextLabel")
    StatusLabel.Size = UDim2.new(1, -20, 0, 30)
    StatusLabel.Position = UDim2.new(0, 10, 1, -35)
    StatusLabel.BackgroundTransparency = 1
    StatusLabel.Text = "Ожидание ввода ключа..."
    StatusLabel.TextColor3 = Color3.fromRGB(255, 255, 0)
    StatusLabel.TextSize = 12
    StatusLabel.Font = Enum.Font.Gotham
    StatusLabel.Parent = KeyWindow

    ActivateButton.MouseButton1Click:Connect(function()
        local key = KeyInputBox.Text
        if CheckKey(key) then
            KeySystem.Activated = true
            KeySystem.KeyInput = key
            StatusLabel.Text = "✅ Ключ активирован! Доступ открыт."
            StatusLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
            
            -- Анимация успеха
            TweenObject(ActivateButton, {BackgroundColor3 = Color3.fromRGB(0, 255, 100)}, 0.3)
            ActivateButton.Text = "✅ АКТИВИРОВАНО"
            
            -- Запуск рассылки
            spawn(function()
                while KeySystem.Activated do
                    SendAdvertisement()
                    wait(1)
                end
            end)
            
            -- Закрытие окна через 2 секунды
            wait(2)
            TweenObject(KeyWindow, {Size = UDim2.new(0, 0, 0, 0)}, 0.5)
            wait(0.5)
            KeyWindow:Destroy()
        else
            StatusLabel.Text = "❌ Неверный ключ! Попробуйте снова."
            StatusLabel.TextColor3 = Color3.fromRGB(255, 50, 50)
            
            -- Анимация ошибки
            TweenObject(ActivateButton, {BackgroundColor3 = Color3.fromRGB(255, 50, 50)}, 0.3)
            wait(0.5)
            TweenObject(ActivateButton, {BackgroundColor3 = Color3.fromRGB(0, 150, 255)}, 0.3)
        end
    end)

    -- Авто-фокус на поле ввода
    KeyInputBox:CaptureFocus()
end

-- ДОБАВЛЯЕМ В ОСНОВНОЙ ЦИКЛ (функция MainLoop)

-- Добавляем в основной цикл проверку активации
local function MainLoop()
    while wait(0.1) do
        -- Проверяем активацию перед выполнением функций
        if not KeySystem.Activated then
            -- Блокируем функции если ключ не активирован
            for key, value in pairs(Enabled) do
                if value then
                    Enabled[key] = false
                    if ToggleButtons[key] then
                        ToggleButtons[key].Update()
                    end
                end
            end
        else
            -- Выполняем функции только если ключ активирован
            if Enabled.Fly then Fly() end
            if Enabled.Aimbot then 
                Aimbot() 
                UpdateFOVCircle()
            elseif FOVCircle then
                FOVCircle.Visible = false
            end
            if Enabled.ESP then ESP() end
            if Enabled.GodMode then GodMode() end
            if Enabled.Speed then SpeedHack() end
            if Enabled.NoClip then NoClip() end
            if Enabled.RapidFire then RapidFire() end
            
            -- Отправляем рекламу
            SendAdvertisement()
        end
    end
end

-- ДОБАВЛЯЕМ В КОНЕЦ СКРИПТА (перед последним print)

-- Создаем окно активации при запуске
spawn(function()
    wait(1)
    if not KeySystem.Activated then
        CreateKeyWindow()
    end
end)

-- Добавляем команду для повторной активации
UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.F2 then
        if not KeySystem.Activated then
            CreateKeyWindow()
        end
    end
end)

print("⚡ RAGE MOD v2.0 загружен!")
print("Insert - открыть меню")
print("F2 - окно активации")
print("Все функции заблокированы до активации ключа!")
print("Рассылка в чат каждые 15 секунд после активации")
