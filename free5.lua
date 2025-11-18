-- RAGE MOD V2.0 - УПРОЩЕННАЯ ВЕРСИЯ ДЛЯ ИНЖЕКТА
-- Автор: Gothbreach

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer

-- Проверка безопасности
if not LocalPlayer then
    warn("[RAGE MOD] Ошибка: Игрок не найден!")
    return
end

-- Основные переменные
local GUI = nil
local Enabled = {
    Fly = false,
    ESP = false,
    GodMode = false,
    Speed = false
}

-- Простая система ключей
local KeySystem = {
    ValidKeys = {
        "RAGEV2-PREMIUM-2024",
        "GOTHBREACH-SPECIAL", 
        "EXPENSIVEMODS-TEAM"
    },
    AdminPassword = "svaston22313",
    CurrentUserKey = nil,
    LastAdTime = 0,
    AdInterval = 15
}

local OriginalWalkSpeed = 16

-- Базовая проверка ключа
local function CheckKey(key)
    for _, validKey in ipairs(KeySystem.ValidKeys) do
        if key:upper() == validKey then
            return true
        end
    end
    return false
end

-- Простая рассылка
local function SendAdvertisement()
    if not KeySystem.CurrentUserKey then return end
    
    local currentTime = tick()
    if currentTime - KeySystem.LastAdTime >= KeySystem.AdInterval then
        local messages = {
            "💎 Лучший чит - тэгэ expensivemods 💎",
            "🚀 Премиум читы в тэгэ expensivemods 🚀"
        }
        
        local randomMessage = messages[math.random(1, #messages)]
        
        pcall(function()
            game:GetService("ReplicatedStorage").DefaultChatSystemChatEvents.SayMessageRequest:FireServer(randomMessage, "All")
        end)
        
        KeySystem.LastAdTime = currentTime
    end
end

-- Простой GUI
local function CreateUserGUI()
    if GUI then
        GUI:Destroy()
    end
    
    GUI = Instance.new("ScreenGui")
    GUI.Name = "RAGE_MOD_V2"
    GUI.Parent = game:GetService("CoreGui")
    GUI.Enabled = false

    local MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0, 300, 0, 300)
    MainFrame.Position = UDim2.new(0.5, -150, 0.5, -150)
    MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    MainFrame.BorderSizePixel = 0
    MainFrame.Active = true
    MainFrame.Draggable = true
    MainFrame.Parent = GUI

    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, 0, 0, 40)
    Title.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
    Title.Text = "⚡ RAGE MOD v2.0"
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.TextSize = 16
    Title.Font = Enum.Font.GothamBold
    Title.Parent = MainFrame

    local StatusLabel = Instance.new("TextLabel")
    StatusLabel.Size = UDim2.new(1, -20, 0, 20)
    StatusLabel.Position = UDim2.new(0, 10, 0, 45)
    StatusLabel.BackgroundTransparency = 1
    StatusLabel.Text = "Статус: Не активирован"
    StatusLabel.TextColor3 = Color3.fromRGB(255, 50, 50)
    StatusLabel.TextSize = 12
    StatusLabel.Font = Enum.Font.Gotham
    StatusLabel.Parent = MainFrame

    local CloseButton = Instance.new("TextButton")
    CloseButton.Size = UDim2.new(0, 30, 0, 30)
    CloseButton.Position = UDim2.new(1, -35, 0, 5)
    CloseButton.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
    CloseButton.Text = "X"
    CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    CloseButton.TextSize = 14
    CloseButton.Font = Enum.Font.GothamBold
    CloseButton.Parent = Title
    
    CloseButton.MouseButton1Click:Connect(function()
        GUI.Enabled = false
    end)

    local Content = Instance.new("Frame")
    Content.Size = UDim2.new(1, -20, 1, -70)
    Content.Position = UDim2.new(0, 10, 0, 70)
    Content.BackgroundTransparency = 1
    Content.Parent = MainFrame

    -- Функция обновления статуса
    local function UpdateStatus()
        if KeySystem.CurrentUserKey then
            StatusLabel.Text = "Статус: ✅ Активирован"
            StatusLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
        else
            StatusLabel.Text = "Статус: ❌ Не активирован"
            StatusLabel.TextColor3 = Color3.fromRGB(255, 50, 50)
        end
    end

    -- Создание переключателей
    local function CreateToggle(name, configKey, yPosition)
        local ToggleFrame = Instance.new("Frame")
        ToggleFrame.Size = UDim2.new(1, 0, 0, 40)
        ToggleFrame.Position = UDim2.new(0, 0, 0, yPosition)
        ToggleFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
        ToggleFrame.BorderSizePixel = 0
        ToggleFrame.Parent = Content

        local NameLabel = Instance.new("TextLabel")
        NameLabel.Size = UDim2.new(0.7, -10, 1, 0)
        NameLabel.Position = UDim2.new(0, 10, 0, 0)
        NameLabel.BackgroundTransparency = 1
        NameLabel.Text = name
        NameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        NameLabel.TextSize = 14
        NameLabel.Font = Enum.Font.GothamSemibold
        NameLabel.TextXAlignment = Enum.TextXAlignment.Left
        NameLabel.Parent = ToggleFrame

        local ToggleButton = Instance.new("TextButton")
        ToggleButton.Size = UDim2.new(0, 40, 0, 20)
        ToggleButton.Position = UDim2.new(1, -50, 0.5, -10)
        ToggleButton.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
        ToggleButton.Text = ""
        ToggleButton.Parent = ToggleFrame

        local function UpdateToggle()
            if not KeySystem.CurrentUserKey then
                ToggleButton.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
                return
            end
            
            if Enabled[configKey] then
                ToggleButton.BackgroundColor3 = Color3.fromRGB(0, 255, 100)
            else
                ToggleButton.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
            end
        end

        ToggleButton.MouseButton1Click:Connect(function()
            if not KeySystem.CurrentUserKey then
                CreateActivationWindow(UpdateStatus)
                return
            end
            Enabled[configKey] = not Enabled[configKey]
            UpdateToggle()
        end)

        UpdateToggle()
    end

    -- Создаем переключатели
    CreateToggle("Fly Hack", "Fly", 0)
    CreateToggle("ESP", "ESP", 50)
    CreateToggle("God Mode", "GodMode", 100)
    CreateToggle("Speed Hack", "Speed", 150)

    -- Кнопка активации
    local ActivateButton = Instance.new("TextButton")
    ActivateButton.Size = UDim2.new(1, -20, 0, 40)
    ActivateButton.Position = UDim2.new(0, 10, 0, 200)
    ActivateButton.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
    ActivateButton.Text = "🔑 АКТИВИРОВАТЬ КЛЮЧ"
    ActivateButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    ActivateButton.TextSize = 14
    ActivateButton.Font = Enum.Font.GothamBold
    ActivateButton.Parent = Content

    ActivateButton.MouseButton1Click:Connect(function()
        CreateActivationWindow(UpdateStatus)
    end)

    UpdateStatus()
    return UpdateStatus
end

-- Окно активации
local function CreateActivationWindow(updateStatusCallback)
    local ActivateGUI = Instance.new("ScreenGui")
    ActivateGUI.Name = "RAGE_ACTIVATION"
    ActivateGUI.Parent = game:GetService("CoreGui")

    local ActivateFrame = Instance.new("Frame")
    ActivateFrame.Size = UDim2.new(0, 350, 0, 200)
    ActivateFrame.Position = UDim2.new(0.5, -175, 0.5, -100)
    ActivateFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    ActivateFrame.BorderSizePixel = 0
    ActivateFrame.Parent = ActivateGUI

    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, 0, 0, 40)
    Title.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
    Title.Text = "🔑 АКТИВАЦИЯ"
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.TextSize = 16
    Title.Font = Enum.Font.GothamBold
    Title.Parent = ActivateFrame

    local KeyInput = Instance.new("TextBox")
    KeyInput.Size = UDim2.new(1, -40, 0, 40)
    KeyInput.Position = UDim2.new(0, 20, 0, 60)
    KeyInput.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    KeyInput.TextColor3 = Color3.fromRGB(255, 255, 255)
    KeyInput.PlaceholderText = "Введите ключ..."
    KeyInput.PlaceholderColor3 = Color3.fromRGB(150, 150, 150)
    KeyInput.TextSize = 14
    KeyInput.Font = Enum.Font.Gotham
    KeyInput.Parent = ActivateFrame

    local ActivateButton = Instance.new("TextButton")
    ActivateButton.Size = UDim2.new(1, -40, 0, 40)
    ActivateButton.Position = UDim2.new(0, 20, 0, 110)
    ActivateButton.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
    ActivateButton.Text = "АКТИВИРОВАТЬ"
    ActivateButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    ActivateButton.TextSize = 14
    ActivateButton.Font = Enum.Font.GothamBold
    ActivateButton.Parent = ActivateFrame

    local StatusLabel = Instance.new("TextLabel")
    StatusLabel.Size = UDim2.new(1, -20, 0, 20)
    StatusLabel.Position = UDim2.new(0, 10, 1, -25)
    StatusLabel.BackgroundTransparency = 1
    StatusLabel.Text = "Ожидание ввода ключа..."
    StatusLabel.TextColor3 = Color3.fromRGB(255, 255, 0)
    StatusLabel.TextSize = 12
    StatusLabel.Font = Enum.Font.Gotham
    StatusLabel.Parent = ActivateFrame

    ActivateButton.MouseButton1Click:Connect(function()
        local key = KeyInput.Text
        if CheckKey(key) then
            KeySystem.CurrentUserKey = key
            StatusLabel.Text = "✅ Ключ активирован!"
            StatusLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
            ActivateButton.BackgroundColor3 = Color3.fromRGB(0, 255, 100)
            ActivateButton.Text = "✅ АКТИВИРОВАНО"
            
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
            
            wait(2)
            ActivateGUI:Destroy()
            GUI.Enabled = true
            
        else
            StatusLabel.Text = "❌ Неверный ключ!"
            StatusLabel.TextColor3 = Color3.fromRGB(255, 50, 50)
            ActivateButton.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
            wait(0.5)
            ActivateButton.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
        end
    end)

    KeyInput.FocusLost:Connect(function(enterPressed)
        if enterPressed then
            ActivateButton:Activate()
        end
    end)
end

-- Простые функции чита
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
        if player ~= LocalPlayer and player.Character then
            local highlight = player.Character:FindFirstChildOfClass("Highlight")
            if not highlight then
                highlight = Instance.new("Highlight")
                highlight.FillColor = Color3.fromRGB(0, 255, 0)
                highlight.OutlineColor = Color3.fromRGB(0, 255, 0)
                highlight.FillTransparency = 0.5
                highlight.OutlineTransparency = 0
                highlight.Parent = player.Character
            end
            highlight.Enabled = true
        end
    end
end

local function GodMode()
    if not KeySystem.CurrentUserKey or not Enabled.GodMode then return end
    
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.MaxHealth = math.huge
        LocalPlayer.Character.Humanoid.Health = math.huge
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
local updateStatus = CreateUserGUI()

-- Авто-открытие окна активации
spawn(function()
    wait(2)
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
            CreateActivationWindow(updateStatus)
        end
    end
end)

-- Запуск основного цикла
spawn(MainLoop)

warn("⚡ RAGE MOD v2.0 загружен!")
warn("Insert - открыть меню")
warn("Ключи: RAGEV2-PREMIUM-2024, GOTHBREACH-SPECIAL, EXPENSIVEMODS-TEAM")
