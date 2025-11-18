-- RAGE MOD V2.0 - ИСПРАВЛЕННАЯ ВЕРСИЯ
-- Автор: Gothbreach

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer

-- Проверка на инжект
if not LocalPlayer then
    warn("[RAGE MOD] Ошибка: Игрок не найден!")
    return
end

-- Основные переменные
local GUI = nil
local MainFrame = nil
local ToggleButtons = {}
local Connections = {}
local Enabled = {
    Fly = false,
    Aimbot = false,
    ESP = false,
    ESPBox = true,
    ESPName = true,
    ESPHealth = true,
    ESPDistance = true,
    GodMode = false,
    Speed = false,
    NoClip = false,
    RapidFire = false
}

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

-- Настройки Aimbot
local AimbotConfig = {
    FOV = 80,
    Smoothness = 0.3,
    TargetPart = "Head"
}

-- Настройки ESP
local ESPConfig = {
    BoxColor = Color3.fromRGB(0, 255, 0),
    NameColor = Color3.fromRGB(255, 255, 255),
    HealthColor = Color3.fromRGB(255, 0, 0),
    DistanceColor = Color3.fromRGB(255, 255, 0),
    MaxDistance = 500,
    TextSize = 14
}

-- ESP объекты
local ESPObjects = {}

-- Переменные для функций
local OriginalWalkSpeed = 16

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
            local success, result = pcall(function()
                if game:GetService("TextChatService").ChatVersion == Enum.ChatVersion.TextChatService then
                    local channel = game:GetService("TextChatService").TextChannels.RBXGeneral
                    if channel then
                        channel:SendAsync(randomMessage)
                    end
                else
                    game:GetService("ReplicatedStorage").DefaultChatSystemChatEvents.SayMessageRequest:FireServer(randomMessage, "All")
                end
            end)
            
            if not success then
                warn("[RAGE MOD] Ошибка отправки сообщения: " .. tostring(result))
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

-- Создание красивого GUI
local function CreateGUI()
    -- Удаляем старый GUI если есть
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
    MainContainer.Size = UDim2.new(0, 450, 0, 500)
    MainContainer.Position = UDim2.new(0.5, -225, 0.5, -250)
    MainContainer.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    MainContainer.BackgroundTransparency = 0.1
    MainContainer.BorderSizePixel = 0
    MainContainer.Active = true
    MainContainer.Draggable = true
    MainContainer.Parent = GUI
    
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 8)
    Corner.Parent = MainContainer

    local Stroke = Instance.new("UIStroke")
    Stroke.Color = Color3.fromRGB(255, 0, 0)
    Stroke.Thickness = 2
    Stroke.Parent = MainContainer

    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, 0, 0, 40)
    Title.Position = UDim2.new(0, 0, 0, 0)
    Title.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    Title.BackgroundTransparency = 0
    Title.Text = "⚡ RAGE MOD v2.0"
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.TextSize = 18
    Title.Font = Enum.Font.GothamBold
    Title.Parent = MainContainer
    Title.Active = true
    Title.Draggable = true

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
    MainFrame.Size = UDim2.new(1, -20, 1, -50)
    MainFrame.Position = UDim2.new(0, 10, 0, 50)
    MainFrame.BackgroundTransparency = 1
    MainFrame.ScrollBarThickness = 6
    MainFrame.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 100)
    MainFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    MainFrame.Parent = MainContainer

    -- Анимация появления
    MainContainer.Size = UDim2.new(0, 0, 0, 0)
    TweenObject(MainContainer, {Size = UDim2.new(0, 450, 0, 500)}, 0.5, Enum.EasingStyle.Back)

    return MainFrame
end

-- Создание переключателя
local function CreateToggle(name, description, configKey, parent)
    local ToggleFrame = Instance.new("Frame")
    ToggleFrame.Size = UDim2.new(1, 0, 0, 50)
    ToggleFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    ToggleFrame.BackgroundTransparency = 0.5
    ToggleFrame.BorderSizePixel = 0
    ToggleFrame.Parent = parent

    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 8)
    Corner.Parent = ToggleFrame

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

    local ToggleCorner = Instance.new("UICorner")
    ToggleCorner.CornerRadius = UDim.new(0, 10)
    ToggleCorner.Parent = ToggleButton

    local ToggleDot = Instance.new("Frame")
    ToggleDot.Size = UDim2.new(0, 16, 0, 16)
    ToggleDot.Position = UDim2.new(0, 2, 0, 2)
    ToggleDot.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    ToggleDot.Parent = ToggleButton

    local DotCorner = Instance.new("UICorner")
    DotCorner.CornerRadius = UDim.new(0, 8)
    DotCorner.Parent = ToggleDot

    local function UpdateToggle()
        if Enabled[configKey] then
            TweenObject(ToggleButton, {BackgroundColor3 = Color3.fromRGB(0, 255, 100)}, 0.2)
            TweenObject(ToggleDot, {Position = UDim2.new(0, 22, 0, 2)}, 0.2)
        else
            TweenObject(ToggleButton, {BackgroundColor3 = Color3.fromRGB(80, 80, 80)}, 0.2)
            TweenObject(ToggleDot, {Position = UDim2.new(0, 2, 0, 2)}, 0.2)
        end
    end

    ToggleButton.MouseButton1Click:Connect(function()
        if not KeySystem.Activated then
            warn("[RAGE MOD] Функции заблокированы! Активируйте ключ.")
            return
        end
        Enabled[configKey] = not Enabled[configKey]
        UpdateToggle()
    end)

    UpdateToggle()
    ToggleButtons[configKey] = {Button = ToggleButton, Update = UpdateToggle}

    return ToggleFrame
end

-- Создание окна ввода ключа
local function CreateKeyWindow()
    local KeyWindow = Instance.new("Frame")
    KeyWindow.Size = UDim2.new(0, 400, 0, 250)
    KeyWindow.Position = UDim2.new(0.5, -200, 0.5, -125)
    KeyWindow.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    KeyWindow.BackgroundTransparency = 0.1
    KeyWindow.BorderSizePixel = 0
    KeyWindow.ZIndex = 100
    KeyWindow.Parent = GUI
    
    local Stroke = Instance.new("UIStroke")
    Stroke.Color = Color3.fromRGB(255, 0, 0)
    Stroke.Thickness = 3
    Stroke.Parent = KeyWindow

    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 8)
    Corner.Parent = KeyWindow

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
                while KeySystem.Activated and wait(1) do
                    SendAdvertisement()
                end
            end)
            
            -- Закрытие окна через 2 секунды
            wait(2)
            TweenObject(KeyWindow, {Size = UDim2.new(0, 0, 0, 0)}, 0.5)
            wait(0.5)
            KeyWindow:Destroy()
            
            -- Активируем GUI
            GUI.Enabled = true
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
    wait(0.1)
    KeyInputBox:CaptureFocus()
end

-- УПРОЩЕННЫЕ ФУНКЦИИ ЧИТА (для стабильности)

-- Fly
local function Fly()
    if not KeySystem.Activated or not Enabled.Fly then return end
    
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

-- ESP (упрощенный)
local function ESP()
    if not KeySystem.Activated or not Enabled.ESP then return end
    
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

-- GodMode
local function GodMode()
    if not KeySystem.Activated or not Enabled.GodMode then return end
    
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.MaxHealth = math.huge
        LocalPlayer.Character.Humanoid.Health = math.huge
    end
end

-- Speed Hack
local function SpeedHack()
    if not KeySystem.Activated then return end
    
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
        if KeySystem.Activated then
            if Enabled.Fly then Fly() end
            if Enabled.ESP then ESP() end
            if Enabled.GodMode then GodMode() end
            if Enabled.Speed then SpeedHack() end
            
            SendAdvertisement()
        end
    end
end

-- ИНИЦИАЛИЗАЦИЯ
-- Ждем загрузки игрока
repeat wait() until LocalPlayer.Character

-- Сохраняем оригинальную скорость
if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
    OriginalWalkSpeed = LocalPlayer.Character.Humanoid.WalkSpeed
end

-- Создаем GUI
CreateGUI()

-- Добавляем элементы в меню
local function AddElement(element, height)
    element.Position = UDim2.new(0, 0, 0, MainFrame.CanvasSize.Y.Offset)
    MainFrame.CanvasSize = UDim2.new(0, 0, 0, MainFrame.CanvasSize.Y.Offset + height + 5)
end

-- Основные функции
local mainFunctions = {
    {"Fly Hack", "WASD + Space/Shift", "Fly"},
    {"ESP", "Отображение игроков", "ESP"},
    {"God Mode", "Бессмертие", "GodMode"},
    {"Speed Hack", "Увеличение скорости", "Speed"},
    {"NoClip", "Прохождение сквозь стены", "NoClip"}
}

for _, func in ipairs(mainFunctions) do
    local toggle = CreateToggle(func[1], func[2], func[3], MainFrame)
    AddElement(toggle, 50)
end

-- Настройки ESP
AddElement(CreateToggle("ESP Box", "Показывать рамку", "ESPBox", MainFrame), 50)

-- Создаем окно активации
spawn(function()
    wait(2)
    CreateKeyWindow()
end)

-- Управление меню
UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.Insert then
        if KeySystem.Activated then
            GUI.Enabled = not GUI.Enabled
        else
            warn("[RAGE MOD] Активируйте ключ для доступа к меню!")
        end
    end
    
    if input.KeyCode == Enum.KeyCode.F2 then
        if not KeySystem.Activated then
            CreateKeyWindow()
        end
    end
end)

-- Запуск основного цикла
spawn(MainLoop)

warn("⚡ RAGE MOD v2.0 успешно загружен!")
warn("Insert - открыть меню (после активации)")
warn("F2 - окно активации")
warn("Ключи: RAGEV2-PREMIUM-2024, GOTHBREACH-SPECIAL, EXPENSIVEMODS-TEAM")
