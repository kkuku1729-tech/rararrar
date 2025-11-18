-- RAGE MOD V2.0 - АДМИН ПАНЕЛЬ С УПРАВЛЕНИЕМ КЛЮЧАМИ
-- Автор: Gothbreach

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer
local HttpService = game:GetService("HttpService")

-- Основные переменные
local GUI = nil
local MainFrame = nil
local ToggleButtons = {}
local Connections = {}
local Enabled = {
    Fly = false,
    ESP = false,
    ESPBox = true,
    GodMode = false,
    Speed = false,
    NoClip = false
}

-- РАСШИРЕННАЯ СИСТЕМА КЛЮЧЕЙ
local KeySystem = {
    ValidKeys = {
        {
            Key = "RAGEV2-PREMIUM-2024",
            CreatedBy = "SYSTEM",
            CreatedAt = os.time(),
            ExpiresAt = nil, -- nil = бессрочный
            Activated = true,
            UsedBy = {}
        },
        {
            Key = "GOTHBREACH-SPECIAL", 
            CreatedBy = "SYSTEM",
            CreatedAt = os.time(),
            ExpiresAt = nil,
            Activated = true,
            UsedBy = {}
        },
        {
            Key = "EXPENSIVEMODS-TEAM",
            CreatedBy = "SYSTEM", 
            CreatedAt = os.time(),
            ExpiresAt = nil,
            Activated = true,
            UsedBy = {}
        }
    },
    AdminPassword = "svaston22313",
    CurrentUserKey = nil,
    LastAdTime = 0,
    AdInterval = 15
}

-- Настройки ESP
local ESPConfig = {
    BoxColor = Color3.fromRGB(0, 255, 0),
    NameColor = Color3.fromRGB(255, 255, 255),
    HealthColor = Color3.fromRGB(255, 0, 0),
    MaxDistance = 500
}

local ESPObjects = {}
local OriginalWalkSpeed = 16

-- Функции для работы с ключами
local function GenerateKey()
    local key = "RAGE-" .. string.upper(HttpService:GenerateGUID(false)):sub(1, 8)
    return key
end

local function CheckKey(key)
    for i, keyData in ipairs(KeySystem.ValidKeys) do
        if keyData.Key:upper() == key:upper() then
            if not keyData.Activated then
                return false, "Ключ деактивирован!"
            end
            if keyData.ExpiresAt and os.time() > keyData.ExpiresAt then
                return false, "Срок действия ключа истек!"
            end
            return true, keyData
        end
    end
    return false, "Неверный ключ!"
end

local function AddKey(key, expiresInHours, createdBy)
    local expiresAt = nil
    if expiresInHours and expiresInHours > 0 then
        expiresAt = os.time() + (expiresInHours * 3600)
    end
    
    table.insert(KeySystem.ValidKeys, {
        Key = key,
        CreatedBy = createdBy or "ADMIN",
        CreatedAt = os.time(),
        ExpiresAt = expiresAt,
        Activated = true,
        UsedBy = {}
    })
    
    return true
end

local function DeactivateKey(key)
    for i, keyData in ipairs(KeySystem.ValidKeys) do
        if keyData.Key:upper() == key:upper() then
            keyData.Activated = false
            return true
        end
    end
    return false
end

local function RemoveKey(key)
    for i, keyData in ipairs(KeySystem.ValidKeys) do
        if keyData.Key:upper() == key:upper() then
            table.remove(KeySystem.ValidKeys, i)
            return true
        end
    end
    return false
end

-- Функция рассылки рекламы
local function SendAdvertisement()
    if not KeySystem.CurrentUserKey then return end
    
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

-- Анимации
local function TweenObject(obj, properties, duration, style)
    local tweenInfo = TweenInfo.new(duration, style or Enum.EasingStyle.Quad)
    local tween = TweenService:Create(obj, tweenInfo, properties)
    tween:Play()
    return tween
end

-- АДМИН ПАНЕЛЬ
local function CreateAdminPanel()
    local AdminGUI = Instance.new("ScreenGui")
    AdminGUI.Name = "RAGE_ADMIN_PANEL"
    AdminGUI.Parent = game:GetService("CoreGui")
    AdminGUI.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    local AdminFrame = Instance.new("Frame")
    AdminFrame.Size = UDim2.new(0, 500, 0, 600)
    AdminFrame.Position = UDim2.new(0.5, -250, 0.5, -300)
    AdminFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
    AdminFrame.BackgroundTransparency = 0.05
    AdminFrame.BorderSizePixel = 0
    AdminFrame.Active = true
    AdminFrame.Draggable = true
    AdminFrame.Parent = AdminGUI
    
    local Stroke = Instance.new("UIStroke")
    Stroke.Color = Color3.fromRGB(255, 0, 0)
    Stroke.Thickness = 3
    Stroke.Parent = AdminFrame

    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, 0, 0, 50)
    Title.Position = UDim2.new(0, 0, 0, 0)
    Title.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
    Title.BackgroundTransparency = 0.2
    Title.Text = "🔧 RAGE MOD - АДМИН ПАНЕЛЬ"
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.TextSize = 18
    Title.Font = Enum.Font.GothamBold
    Title.Parent = AdminFrame

    local CloseButton = Instance.new("TextButton")
    CloseButton.Size = UDim2.new(0, 30, 0, 30)
    CloseButton.Position = UDim2.new(1, -35, 0, 10)
    CloseButton.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
    CloseButton.Text = "X"
    CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    CloseButton.TextSize = 16
    CloseButton.Font = Enum.Font.GothamBold
    CloseButton.Parent = Title
    
    CloseButton.MouseButton1Click:Connect(function()
        AdminGUI:Destroy()
    end)

    local Content = Instance.new("ScrollingFrame")
    Content.Size = UDim2.new(1, -20, 1, -60)
    Content.Position = UDim2.new(0, 10, 0, 60)
    Content.BackgroundTransparency = 1
    Content.ScrollBarThickness = 6
    Content.CanvasSize = UDim2.new(0, 0, 0, 0)
    Content.Parent = AdminFrame

    -- Секция создания ключей
    local CreateKeySection = Instance.new("Frame")
    CreateKeySection.Size = UDim2.new(1, 0, 0, 150)
    CreateKeySection.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    CreateKeySection.BackgroundTransparency = 0.2
    CreateKeySection.Parent = Content

    local CreateTitle = Instance.new("TextLabel")
    CreateTitle.Size = UDim2.new(1, 0, 0, 30)
    CreateTitle.BackgroundTransparency = 1
    CreateTitle.Text = "Создание ключа"
    CreateTitle.TextColor3 = Color3.fromRGB(0, 255, 255)
    CreateTitle.TextSize = 16
    CreateTitle.Font = Enum.Font.GothamBold
    CreateTitle.Parent = CreateKeySection

    local HoursInput = Instance.new("TextBox")
    HoursInput.Size = UDim2.new(0.6, -10, 0, 30)
    HoursInput.Position = UDim2.new(0, 10, 0, 40)
    HoursInput.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    HoursInput.TextColor3 = Color3.fromRGB(255, 255, 255)
    HoursInput.PlaceholderText = "Срок действия в часах (0 = бессрочно)"
    HoursInput.PlaceholderColor3 = Color3.fromRGB(150, 150, 150)
    HoursInput.Text = ""
    HoursInput.Parent = CreateKeySection

    local GenerateButton = Instance.new("TextButton")
    GenerateButton.Size = UDim2.new(0.35, -10, 0, 30)
    GenerateButton.Position = UDim2.new(0.65, 10, 0, 40)
    GenerateButton.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
    GenerateButton.Text = "Сгенерировать"
    GenerateButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    GenerateButton.Font = Enum.Font.GothamBold
    GenerateButton.Parent = CreateKeySection

    local KeyResult = Instance.new("TextLabel")
    KeyResult.Size = UDim2.new(1, -20, 0, 40)
    KeyResult.Position = UDim2.new(0, 10, 0, 80)
    KeyResult.BackgroundTransparency = 1
    KeyResult.Text = "Ключ появится здесь..."
    KeyResult.TextColor3 = Color3.fromRGB(255, 255, 255)
    KeyResult.TextSize = 14
    KeyResult.Font = Enum.Font.Gotham
    KeyResult.TextWrapped = true
    KeyResult.Parent = CreateKeySection

    GenerateButton.MouseButton1Click:Connect(function()
        local hours = tonumber(HoursInput.Text) or 0
        local newKey = GenerateKey()
        AddKey(newKey, hours, "ADMIN")
        KeyResult.Text = "✅ Создан ключ: " .. newKey .. "\nСрок: " .. (hours > 0 and hours .. " часов" or "Бессрочно")
    end)

    -- Секция управления ключами
    local ManageSection = Instance.new("Frame")
    ManageSection.Size = UDim2.new(1, 0, 0, 200)
    ManageSection.Position = UDim2.new(0, 0, 0, 160)
    ManageSection.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    ManageSection.BackgroundTransparency = 0.2
    ManageSection.Parent = Content

    local ManageTitle = Instance.new("TextLabel")
    ManageTitle.Size = UDim2.new(1, 0, 0, 30)
    ManageTitle.BackgroundTransparency = 1
    ManageTitle.Text = "Управление ключами"
    ManageTitle.TextColor3 = Color3.fromRGB(255, 255, 0)
    ManageTitle.TextSize = 16
    ManageTitle.Font = Enum.Font.GothamBold
    ManageTitle.Parent = ManageSection

    local KeyInput = Instance.new("TextBox")
    KeyInput.Size = UDim2.new(0.6, -10, 0, 30)
    KeyInput.Position = UDim2.new(0, 10, 0, 40)
    KeyInput.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    KeyInput.TextColor3 = Color3.fromRGB(255, 255, 255)
    KeyInput.PlaceholderText = "Введите ключ для управления"
    KeyInput.PlaceholderColor3 = Color3.fromRGB(150, 150, 150)
    KeyInput.Parent = ManageSection

    local DeactivateButton = Instance.new("TextButton")
    DeactivateButton.Size = UDim2.new(0.35, -10, 0, 30)
    DeactivateButton.Position = UDim2.new(0.65, 10, 0, 40)
    DeactivateButton.BackgroundColor3 = Color3.fromRGB(255, 100, 0)
    DeactivateButton.Text = "Деактивировать"
    DeactivateButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    DeactivateButton.Font = Enum.Font.GothamBold
    DeactivateButton.Parent = ManageSection

    local RemoveButton = Instance.new("TextButton")
    RemoveButton.Size = UDim2.new(0.35, -10, 0, 30)
    RemoveButton.Position = UDim2.new(0.65, 10, 0, 80)
    RemoveButton.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
    RemoveButton.Text = "Удалить"
    RemoveButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    RemoveButton.Font = Enum.Font.GothamBold
    RemoveButton.Parent = ManageSection

    local ActivateButton = Instance.new("TextButton")
    ActivateButton.Size = UDim2.new(0.35, -10, 0, 30)
    ActivateButton.Position = UDim2.new(0.65, 10, 0, 120)
    ActivateButton.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
    ActivateButton.Text = "Активировать"
    ActivateButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    ActivateButton.Font = Enum.Font.GothamBold
    ActivateButton.Parent = ManageSection

    local ManageResult = Instance.new("TextLabel")
    ManageResult.Size = UDim2.new(1, -20, 0, 40)
    ManageResult.Position = UDim2.new(0, 10, 0, 160)
    ManageResult.BackgroundTransparency = 1
    ManageResult.Text = "Результат управления..."
    ManageResult.TextColor3 = Color3.fromRGB(255, 255, 255)
    ManageResult.TextSize = 12
    ManageResult.Font = Enum.Font.Gotham
    ManageResult.TextWrapped = true
    ManageResult.Parent = ManageSection

    DeactivateButton.MouseButton1Click:Connect(function()
        local key = KeyInput.Text
        if DeactivateKey(key) then
            ManageResult.Text = "✅ Ключ " .. key .. " деактивирован!"
            ManageResult.TextColor3 = Color3.fromRGB(0, 255, 0)
        else
            ManageResult.Text = "❌ Ключ не найден!"
            ManageResult.TextColor3 = Color3.fromRGB(255, 50, 50)
        end
    end)

    RemoveButton.MouseButton1Click:Connect(function()
        local key = KeyInput.Text
        if RemoveKey(key) then
            ManageResult.Text = "✅ Ключ " .. key .. " удален!"
            ManageResult.TextColor3 = Color3.fromRGB(0, 255, 0)
        else
            ManageResult.Text = "❌ Ключ не найден!"
            ManageResult.TextColor3 = Color3.fromRGB(255, 50, 50)
        end
    end)

    ActivateButton.MouseButton1Click:Connect(function()
        local key = KeyInput.Text
        for i, keyData in ipairs(KeySystem.ValidKeys) do
            if keyData.Key:upper() == key:upper() then
                keyData.Activated = true
                ManageResult.Text = "✅ Ключ " .. key .. " активирован!"
                ManageResult.TextColor3 = Color3.fromRGB(0, 255, 0)
                return
            end
        end
        ManageResult.Text = "❌ Ключ не найден!"
        ManageResult.TextColor3 = Color3.fromRGB(255, 50, 50)
    end)

    -- Секция списка ключей
    local ListSection = Instance.new("Frame")
    ListSection.Size = UDim2.new(1, 0, 0, 200)
    ListSection.Position = UDim2.new(0, 0, 0, 370)
    ListSection.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    ListSection.BackgroundTransparency = 0.2
    ListSection.Parent = Content

    local ListTitle = Instance.new("TextLabel")
    ListTitle.Size = UDim2.new(1, 0, 0, 30)
    ListTitle.BackgroundTransparency = 1
    ListTitle.Text = "Список ключей"
    ListTitle.TextColor3 = Color3.fromRGB(0, 255, 100)
    ListTitle.TextSize = 16
    ListTitle.Font = Enum.Font.GothamBold
    ListTitle.Parent = ListSection

    local KeysList = Instance.new("ScrollingFrame")
    KeysList.Size = UDim2.new(1, -20, 1, -40)
    KeysList.Position = UDim2.new(0, 10, 0, 40)
    KeysList.BackgroundTransparency = 1
    KeysList.ScrollBarThickness = 4
    KeysList.CanvasSize = UDim2.new(0, 0, 0, 0)
    KeysList.Parent = ListSection

    local function UpdateKeysList()
        KeysList:ClearAllChildren()
        KeysList.CanvasSize = UDim2.new(0, 0, 0, 0)
        
        for i, keyData in ipairs(KeySystem.ValidKeys) do
            local keyFrame = Instance.new("Frame")
            keyFrame.Size = UDim2.new(1, 0, 0, 40)
            keyFrame.Position = UDim2.new(0, 0, 0, KeysList.CanvasSize.Y.Offset)
            keyFrame.BackgroundColor3 = keyData.Activated and Color3.fromRGB(40, 60, 40) or Color3.fromRGB(60, 40, 40)
            keyFrame.BackgroundTransparency = 0.5
            keyFrame.Parent = KeysList
            
            local keyText = keyData.Key
            if keyData.ExpiresAt then
                local timeLeft = keyData.ExpiresAt - os.time()
                if timeLeft > 0 then
                    keyText = keyText .. " (" .. math.floor(timeLeft/3600) .. "ч)"
                else
                    keyText = keyText .. " (ИСТЕК)"
                end
            else
                keyText = keyText .. " (Бессрочно)"
            end
            
            if not keyData.Activated then
                keyText = keyText .. " [ВЫКЛ]"
            end
            
            local label = Instance.new("TextLabel")
            label.Size = UDim2.new(1, -10, 1, 0)
            label.Position = UDim2.new(0, 5, 0, 0)
            label.BackgroundTransparency = 1
            label.Text = keyText
            label.TextColor3 = Color3.fromRGB(255, 255, 255)
            label.TextSize = 12
            label.Font = Enum.Font.Gotham
            label.TextXAlignment = Enum.TextXAlignment.Left
            label.Parent = keyFrame
            
            KeysList.CanvasSize = UDim2.new(0, 0, 0, KeysList.CanvasSize.Y.Offset + 45)
        end
    end

    UpdateKeysList()
    
    -- Обновление списка каждые 5 секунд
    spawn(function()
        while AdminGUI.Parent do
            wait(5)
            UpdateKeysList()
        end
    end)

    Content.CanvasSize = UDim2.new(0, 0, 0, 580)
    
    return AdminGUI
end

-- Окно ввода пароля для админ панели
local function CreateAdminLogin()
    local LoginGUI = Instance.new("ScreenGui")
    LoginGUI.Name = "RAGE_ADMIN_LOGIN"
    LoginGUI.Parent = game:GetService("CoreGui")
    LoginGUI.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    local LoginFrame = Instance.new("Frame")
    LoginFrame.Size = UDim2.new(0, 350, 0, 200)
    LoginFrame.Position = UDim2.new(0.5, -175, 0.5, -100)
    LoginFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    LoginFrame.BackgroundTransparency = 0.1
    LoginFrame.BorderSizePixel = 0
    LoginFrame.Parent = LoginGUI
    
    local Stroke = Instance.new("UIStroke")
    Stroke.Color = Color3.fromRGB(255, 0, 0)
    Stroke.Thickness = 3
    Stroke.Parent = LoginFrame

    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, 0, 0, 50)
    Title.Position = UDim2.new(0, 0, 0, 0)
    Title.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
    Title.BackgroundTransparency = 0.2
    Title.Text = "🔐 АДМИН ДОСТУП"
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.TextSize = 18
    Title.Font = Enum.Font.GothamBold
    Title.Parent = LoginFrame

    local PasswordInput = Instance.new("TextBox")
    PasswordInput.Size = UDim2.new(1, -40, 0, 40)
    PasswordInput.Position = UDim2.new(0, 20, 0, 70)
    PasswordInput.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    PasswordInput.TextColor3 = Color3.fromRGB(255, 255, 255)
    PasswordInput.PlaceholderText = "Введите пароль администратора..."
    PasswordInput.PlaceholderColor3 = Color3.fromRGB(150, 150, 150)
    PasswordInput.Text = ""
    PasswordInput.TextSize = 16
    PasswordInput.Font = Enum.Font.Gotham
    PasswordInput.ClearTextOnFocus = false
    PasswordInput.Parent = LoginFrame

    local LoginButton = Instance.new("TextButton")
    LoginButton.Size = UDim2.new(1, -40, 0, 40)
    LoginButton.Position = UDim2.new(0, 20, 0, 120)
    LoginButton.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
    LoginButton.Text = "ВОЙТИ"
    LoginButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    LoginButton.TextSize = 16
    LoginButton.Font = Enum.Font.GothamBold
    LoginButton.Parent = LoginFrame

    local StatusLabel = Instance.new("TextLabel")
    StatusLabel.Size = UDim2.new(1, -20, 0, 20)
    StatusLabel.Position = UDim2.new(0, 10, 1, -25)
    StatusLabel.BackgroundTransparency = 1
    StatusLabel.Text = "Ожидание ввода пароля..."
    StatusLabel.TextColor3 = Color3.fromRGB(255, 255, 0)
    StatusLabel.TextSize = 12
    StatusLabel.Font = Enum.Font.Gotham
    StatusLabel.Parent = LoginFrame

    LoginButton.MouseButton1Click:Connect(function()
        local password = PasswordInput.Text
        if password == KeySystem.AdminPassword then
            StatusLabel.Text = "✅ Доступ разрешен!"
            StatusLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
            
            TweenObject(LoginButton, {BackgroundColor3 = Color3.fromRGB(0, 255, 100)}, 0.3)
            LoginButton.Text = "✅ УСПЕХ"
            
            wait(1)
            LoginGUI:Destroy()
            CreateAdminPanel()
        else
            StatusLabel.Text = "❌ Неверный пароль!"
            StatusLabel.TextColor3 = Color3.fromRGB(255, 50, 50)
            
            TweenObject(LoginButton, {BackgroundColor3 = Color3.fromRGB(255, 50, 50)}, 0.3)
            wait(0.5)
            TweenObject(LoginButton, {BackgroundColor3 = Color3.fromRGB(0, 150, 255)}, 0.3)
        end
    end)

    PasswordInput.FocusLost:Connect(function(enterPressed)
        if enterPressed then
            LoginButton:
                    LoginButton:Activate()
        end
    end)
end

-- ОСНОВНОЙ GUI ДЛЯ ПОЛЬЗОВАТЕЛЕЙ (упрощенный)
local function CreateUserGUI()
    if GUI then
        GUI:Destroy()
        GUI = nil
    end
    
    GUI = Instance.new("ScreenGui")
    GUI.Name = "RAGE_MOD_V2_" .. tostring(math.random(1, 10000))
    GUI.Parent = game:GetService("CoreGui")
    GUI.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    GUI.Enabled = false

    local MainContainer = Instance.new("Frame")
    MainContainer.Size = UDim2.new(0, 400, 0, 400)
    MainContainer.Position = UDim2.new(0.5, -200, 0.5, -200)
    MainContainer.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    MainContainer.BackgroundTransparency = 0.1
    MainContainer.BorderSizePixel = 0
    MainContainer.Active = true
    MainContainer.Draggable = true
    MainContainer.Parent = GUI
    
    local Stroke = Instance.new("UIStroke")
    Stroke.Color = Color3.fromRGB(255, 0, 0)
    Stroke.Thickness = 2
    Stroke.Parent = MainContainer

    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, 0, 0, 40)
    Title.Position = UDim2.new(0, 0, 0, 0)
    Title.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    Title.Text = "⚡ RAGE MOD v2.0"
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.TextSize = 18
    Title.Font = Enum.Font.GothamBold
    Title.Parent = MainContainer

    local StatusLabel = Instance.new("TextLabel")
    StatusLabel.Size = UDim2.new(1, -20, 0, 20)
    StatusLabel.Position = UDim2.new(0, 10, 0, 45)
    StatusLabel.BackgroundTransparency = 1
    StatusLabel.Text = "Статус: Не активирован"
    StatusLabel.TextColor3 = Color3.fromRGB(255, 50, 50)
    StatusLabel.TextSize = 12
    StatusLabel.Font = Enum.Font.Gotham
    StatusLabel.Parent = MainContainer

    local CloseButton = Instance.new("TextButton")
    CloseButton.Size = UDim2.new(0, 30, 0, 30)
    CloseButton.Position = UDim2.new(1, -35, 0, 5)
    CloseButton.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
    CloseButton.Text = "X"
    CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    CloseButton.TextSize = 16
    CloseButton.Font = Enum.Font.GothamBold
    CloseButton.Parent = Title
    
    CloseButton.MouseButton1Click:Connect(function()
        GUI.Enabled = false
    end)

    MainFrame = Instance.new("ScrollingFrame")
    MainFrame.Size = UDim2.new(1, -20, 1, -70)
    MainFrame.Position = UDim2.new(0, 10, 0, 70)
    MainFrame.BackgroundTransparency = 1
    MainFrame.ScrollBarThickness = 6
    MainFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    MainFrame.Parent = MainContainer

    -- Функция обновления статуса
    local function UpdateStatus()
        if KeySystem.CurrentUserKey then
            StatusLabel.Text = "Статус: ✅ Активирован (" .. KeySystem.CurrentUserKey .. ")"
            StatusLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
        else
            StatusLabel.Text = "Статус: ❌ Не активирован"
            StatusLabel.TextColor3 = Color3.fromRGB(255, 50, 50)
        end
    end

    UpdateStatus()

    return MainFrame, UpdateStatus
end

-- Окно активации для пользователей
local function CreateActivationWindow(updateStatusCallback)
    local ActivateGUI = Instance.new("ScreenGui")
    ActivateGUI.Name = "RAGE_ACTIVATION"
    ActivateGUI.Parent = game:GetService("CoreGui")
    ActivateGUI.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    local ActivateFrame = Instance.new("Frame")
    ActivateFrame.Size = UDim2.new(0, 400, 0, 250)
    ActivateFrame.Position = UDim2.new(0.5, -200, 0.5, -125)
    ActivateFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    ActivateFrame.BackgroundTransparency = 0.1
    ActivateFrame.BorderSizePixel = 0
    ActivateFrame.Parent = ActivateGUI
    
    local Stroke = Instance.new("UIStroke")
    Stroke.Color = Color3.fromRGB(255, 0, 0)
    Stroke.Thickness = 3
    Stroke.Parent = ActivateFrame

    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, 0, 0, 50)
    Title.Position = UDim2.new(0, 0, 0, 0)
    Title.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
    Title.BackgroundTransparency = 0.2
    Title.Text = "🔑 АКТИВАЦИЯ RAGE MOD"
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.TextSize = 18
    Title.Font = Enum.Font.GothamBold
    Title.Parent = ActivateFrame

    local InfoLabel = Instance.new("TextLabel")
    InfoLabel.Size = UDim2.new(1, -20, 0, 40)
    InfoLabel.Position = UDim2.new(0, 10, 0, 60)
    InfoLabel.BackgroundTransparency = 1
    InfoLabel.Text = "Введите ключ активации для доступа к функциям"
    InfoLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    InfoLabel.TextSize = 14
    InfoLabel.Font = Enum.Font.Gotham
    InfoLabel.TextWrapped = true
    InfoLabel.Parent = ActivateFrame

    local KeyInputBox = Instance.new("TextBox")
    KeyInputBox.Size = UDim2.new(1, -40, 0, 40)
    KeyInputBox.Position = UDim2.new(0, 20, 0, 110)
    KeyInputBox.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    KeyInputBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    KeyInputBox.PlaceholderText = "Введите ключ активации..."
    KeyInputBox.PlaceholderColor3 = Color3.fromRGB(150, 150, 150)
    KeyInputBox.TextSize = 16
    KeyInputBox.Font = Enum.Font.Gotham
    KeyInputBox.ClearTextOnFocus = false
    KeyInputBox.Parent = ActivateFrame

    local ActivateButton = Instance.new("TextButton")
    ActivateButton.Size = UDim2.new(1, -40, 0, 40)
    ActivateButton.Position = UDim2.new(0, 20, 0, 160)
    ActivateButton.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
    ActivateButton.Text = "АКТИВИРОВАТЬ"
    ActivateButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    ActivateButton.TextSize = 16
    ActivateButton.Font = Enum.Font.GothamBold
    ActivateButton.Parent = ActivateFrame

    local StatusLabel = Instance.new("TextLabel")
    StatusLabel.Size = UDim2.new(1, -20, 0, 30)
    StatusLabel.Position = UDim2.new(0, 10, 1, -35)
    StatusLabel.BackgroundTransparency = 1
    StatusLabel.Text = "Ожидание ввода ключа..."
    StatusLabel.TextColor3 = Color3.fromRGB(255, 255, 0)
    StatusLabel.TextSize = 12
    StatusLabel.Font = Enum.Font.Gotham
    StatusLabel.Parent = ActivateFrame

    ActivateButton.MouseButton1Click:Connect(function()
        local key = KeyInputBox.Text
        local success, result = CheckKey(key)
        
        if success then
            KeySystem.CurrentUserKey = key
            StatusLabel.Text = "✅ Ключ активирован! Доступ открыт."
            StatusLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
            
            -- Добавляем пользователя в список использовавших ключ
            for i, keyData in ipairs(KeySystem.ValidKeys) do
                if keyData.Key:upper() == key:upper() then
                    table.insert(keyData.UsedBy, {
                        UserId = LocalPlayer.UserId,
                        UserName = LocalPlayer.Name,
                        ActivatedAt = os.time()
                    })
                    break
                end
            end
            
            TweenObject(ActivateButton, {BackgroundColor3 = Color3.fromRGB(0, 255, 100)}, 0.3)
            ActivateButton.Text = "✅ АКТИВИРОВАНО"
            
            -- Обновляем статус в основном GUI
            if updateStatusCallback then
                updateStatusCallback()
            end
            
            -- Запускаем рассылку
            spawn(function()
                while KeySystem.CurrentUserKey do
                    SendAdvertisement()
                    wait(1)
                end
            end)
            
            -- Закрываем окно через 2 секунды
            wait(2)
            TweenObject(ActivateFrame, {Size = UDim2.new(0, 0, 0, 0)}, 0.5)
            wait(0.5)
            ActivateGUI:Destroy()
            
            -- Включаем основное меню
            GUI.Enabled = true
            
        else
            StatusLabel.Text = "❌ " .. result
            StatusLabel.TextColor3 = Color3.fromRGB(255, 50, 50)
            
            TweenObject(ActivateButton, {BackgroundColor3 = Color3.fromRGB(255, 50, 50)}, 0.3)
            wait(0.5)
            TweenObject(ActivateButton, {BackgroundColor3 = Color3.fromRGB(0, 150, 255)}, 0.3)
        end
    end)

    KeyInputBox.FocusLost:Connect(function(enterPressed)
        if enterPressed then
            ActivateButton:Activate()
        end
    end)

    return ActivateGUI
end

-- Создание переключателя для пользовательского GUI
local function CreateUserToggle(name, description, configKey, parent)
    local ToggleFrame = Instance.new("Frame")
    ToggleFrame.Size = UDim2.new(1, 0, 0, 50)
    ToggleFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    ToggleFrame.BackgroundTransparency = 0.5
    ToggleFrame.BorderSizePixel = 0
    ToggleFrame.Parent = parent

    local NameLabel = Instance.new("TextLabel")
    NameLabel.Size = UDim2.new(0.7, -10, 0, 25)
    NameLabel.Position = UDim2.new(0, 10, 0, 5)
    NameLabel.BackgroundTransparency = 1
    NameLabel.Text = name
    NameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    NameLabel.TextSize = 14
    NameLabel.Font = Enum.Font.GothamSemibold
    NameLabel.TextXAlignment = Enum.TextXAlignment.Left
    NameLabel.Parent = ToggleFrame

    local DescLabel = Instance.new("TextLabel")
    DescLabel.Size = UDim2.new(0.7, -10, 0, 20)
    DescLabel.Position = UDim2.new(0, 10, 0, 30)
    DescLabel.BackgroundTransparency = 1
    DescLabel.Text = description
    DescLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    DescLabel.TextSize = 11
    DescLabel.Font = Enum.Font.Gotham
    DescLabel.TextXAlignment = Enum.TextXAlignment.Left
    DescLabel.Parent = ToggleFrame

    local ToggleButton = Instance.new("TextButton")
    ToggleButton.Size = UDim2.new(0, 40, 0, 20)
    ToggleButton.Position = UDim2.new(1, -50, 0.5, -10)
    ToggleButton.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
    ToggleButton.Text = ""
    ToggleButton.Parent = ToggleFrame

    local ToggleDot = Instance.new("Frame")
    ToggleDot.Size = UDim2.new(0, 16, 0, 16)
    ToggleDot.Position = UDim2.new(0, 2, 0, 2)
    ToggleDot.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    ToggleDot.Parent = ToggleButton

    local function UpdateToggle()
        if not KeySystem.CurrentUserKey then
            ToggleButton.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
            ToggleDot.Position = UDim2.new(0, 2, 0, 2)
            return
        end
        
        if Enabled[configKey] then
            TweenObject(ToggleButton, {BackgroundColor3 = Color3.fromRGB(0, 255, 100)}, 0.2)
            TweenObject(ToggleDot, {Position = UDim2.new(0, 22, 0, 2)}, 0.2)
        else
            TweenObject(ToggleButton, {BackgroundColor3 = Color3.fromRGB(80, 80, 80)}, 0.2)
            TweenObject(ToggleDot, {Position = UDim2.new(0, 2, 0, 2)}, 0.2)
        end
    end

    ToggleButton.MouseButton1Click:Connect(function()
        if not KeySystem.CurrentUserKey then
            warn("[RAGE MOD] Активируйте ключ для использования функций!")
            CreateActivationWindow(UpdateStatus)
            return
        end
        Enabled[configKey] = not Enabled[configKey]
        UpdateToggle()
    end)

    UpdateToggle()
    return ToggleFrame
end

-- УПРОЩЕННЫЕ ФУНКЦИИ ЧИТА
local function Fly()
    if not KeySystem.CurrentUserKey or not Enabled.Fly then return end
    
    local character = LocalPlayer.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return end
    
    local bodyVelocity = character.HumanoidRootPart:FindFirstChildOfClass("BodyVelocity")
    if not bodyVelocity then
        bodyVelocity = Instance.new("BodyVelocity")
        bodyVelocity.Velocity = Vector3.new(0, 0, 0)
        bodyVelocity.MaxForce = Vector3.new(4000, 4000, 4000)
        bodyVelocity.Parent = character.HumanoidRootPart
    end
    
    local cam = workspace.CurrentCamera.CFrame
    local move = Vector3.new()
    
    if UserInputService:IsKeyDown(Enum.KeyCode.W) then move = move + cam.LookVector end
    if UserInputService:IsKeyDown(Enum.KeyCode.S) then move = move - cam.LookVector end
    if UserInputService:IsKeyDown(Enum.KeyCode.A) then move = move - cam.RightVector end
    if UserInputService:IsKeyDown(Enum.KeyCode.D) then move = move + cam.RightVector end
    if UserInputService:IsKeyDown(Enum.KeyCode.Space) then move = move + Vector3.new(0, 1, 0) end
    if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then move = move - Vector3.new(0, 1, 0) end
    
    bodyVelocity.Velocity = move * 50
end

local function ESP()
    if not KeySystem.CurrentUserKey or not Enabled.ESP then return end
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            if not ESPObjects[player] then
                local highlight = Instance.new("Highlight")
                highlight.FillColor = ESPConfig.BoxColor
                highlight.OutlineColor = ESPConfig.BoxColor
                highlight.FillTransparency = 0.5
                highlight.OutlineTransparency = 0
                highlight.Enabled = Enabled.ESPBox
                highlight.Adornee = player.Character
                highlight.Parent = player.Character
                
                ESPObjects[player] = {Highlight = highlight}
            end
            
            local espData = ESPObjects[player]
            if espData then
                espData.Highlight.Enabled = Enabled.ESP and Enabled.ESPBox
                espData.Highlight.FillColor = ESPConfig.BoxColor
                espData.Highlight.OutlineColor = ESPConfig.BoxColor
            end
        else
            if ESPObjects[player] then
                ESPObjects[player].Highlight:Destroy()
                ESPObjects[player] = nil
            end
        end
    end
end

local function SpeedHack()
    if not KeySystem.CurrentUserKey then return end
    
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        if Enabled.Speed then
            LocalPlayer.Character.Humanoid.WalkSpeed = 50
        else
            LocalPlayer.Character.Humanoid.WalkSpeed = OriginalWalkSpeed
        end
    end
end

-- Основной цикл
local function MainLoop()
    while wait(0.1) do
        if KeySystem.CurrentUserKey then
            if Enabled.Fly then Fly() end
            if Enabled.ESP then ESP() end
            if Enabled.Speed then SpeedHack() end
            
            SendAdvertisement()
        end
    end
end

-- ИНИЦИАЛИЗАЦИЯ
repeat wait() until LocalPlayer.Character

if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
    OriginalWalkSpeed = LocalPlayer.Character.Humanoid.WalkSpeed
end

-- Создаем пользовательский GUI
local mainFrame, updateStatus = CreateUserGUI()

-- Добавляем функции в меню
local userFunctions = {
    {"Fly Hack", "WASD + Space/Shift", "Fly"},
    {"ESP", "Отображение игроков", "ESP"},
    {"Speed Hack", "Увеличение скорости", "Speed"},
    {"God Mode", "Бессмертие", "GodMode"},
    {"NoClip", "Прохождение сквозь стен", "NoClip"}
}

local function AddUserElement(element, height)
    element.Position = UDim2.new(0, 0, 0, mainFrame.CanvasSize.Y.Offset)
    mainFrame.CanvasSize = UDim2.new(0, 0, 0, mainFrame.CanvasSize.Y.Offset + height + 5)
end

for _, func in ipairs(userFunctions) do
    local toggle = CreateUserToggle(func[1], func[2], func[3], mainFrame)
    AddUserElement(toggle, 50)
end

-- Кнопка активации
local ActivateBtnFrame = Instance.new("Frame")
ActivateBtnFrame.Size = UDim2.new(1, 0, 0, 60)
ActivateBtnFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
ActivateBtnFrame.BackgroundTransparency = 0.5
ActivateBtnFrame.Parent = mainFrame

local ActivateButton = Instance.new("TextButton")
ActivateButton.Size = UDim2.new(1, -20, 0, 40)
ActivateButton.Position = UDim2.new(0, 10, 0, 10)
ActivateButton.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
ActivateButton.Text = "🔑 АКТИВИРОВАТЬ КЛЮЧ"
ActivateButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ActivateButton.TextSize = 14
ActivateButton.Font = Enum.Font.GothamBold
ActivateButton.Parent = ActivateBtnFrame

ActivateButton.MouseButton1Click:Connect(function()
    CreateActivationWindow(updateStatus)
end)

AddUserElement(ActivateBtnFrame, 60)

-- Авто-открытие окна активации при первом запуске
spawn(function()
    wait(3)
    if not KeySystem.CurrentUserKey then
        CreateActivationWindow(updateStatus)
    end
end)

-- Горячие клавиши
UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.Insert then
        if KeySystem.CurrentUserKey then
            GUI.Enabled = not GUI.Enabled
        else
            warn("[RAGE MOD] Активируйте ключ для доступа к меню!")
            CreateActivationWindow(updateStatus)
        end
    end
    
    if input.KeyCode == Enum.KeyCode.F4 then
        CreateAdminLogin()
    end
end)

-- Запуск основного цикла
spawn(MainLoop)

warn("⚡ RAGE MOD v2.0 с админ панелью загружен!")
warn("Insert - основное меню")
warn("F4 - админ панель (пароль: svaston22313)")
warn("Система ключей активна - требуется активация!")
