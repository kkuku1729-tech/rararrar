-- Кастомный полупрозрачный GUI в стиле NeverLose
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local mouse = LocalPlayer:GetMouse()

-- Проверка безопасности перед созданием GUI
if not game:IsLoaded() then
    game.Loaded:Wait()
end

if not LocalPlayer then
    Players.PlayerAdded:Wait()
    LocalPlayer = Players.LocalPlayer
end

-- Создание главного GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ExpensiveModsGUI"
ScreenGui.Parent = game:FindFirstChild("CoreGui") or game:FindFirstChild("PlayerGui") or LocalPlayer:WaitForChild("PlayerGui")
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- Главный фрейм
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 500, 0, 400)
MainFrame.Position = UDim2.new(0.5, -250, 0.5, -200)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
MainFrame.BackgroundTransparency = 0.2
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true
MainFrame.Visible = true
MainFrame.Parent = ScreenGui

-- Скругление углов
local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 8)
UICorner.Parent = MainFrame

-- Заголовок
local Header = Instance.new("Frame")
Header.Name = "Header"
Header.Size = UDim2.new(1, 0, 0, 40)
Header.Position = UDim2.new(0, 0, 0, 0)
Header.BackgroundColor3 = Color3.fromRGB(30, 30, 38)
Header.BackgroundTransparency = 0.1
Header.BorderSizePixel = 0
Header.Parent = MainFrame

local HeaderCorner = Instance.new("UICorner")
HeaderCorner.CornerRadius = UDim.new(0, 8)
HeaderCorner.Parent = Header

local Title = Instance.new("TextLabel")
Title.Name = "Title"
Title.Size = UDim2.new(1, -40, 1, 0)
Title.Position = UDim2.new(0, 15, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "ExpensiveMods | RUZT Alpha 2.9.7"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 14
Title.Font = Enum.Font.GothamSemibold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Header

local CloseButton = Instance.new("TextButton")
CloseButton.Name = "CloseButton"
CloseButton.Size = UDim2.new(0, 30, 0, 30)
CloseButton.Position = UDim2.new(1, -35, 0, 5)
CloseButton.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
CloseButton.BackgroundTransparency = 0.2
CloseButton.Text = "X"
CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseButton.TextSize = 14
CloseButton.Font = Enum.Font.GothamBold
CloseButton.Parent = Header

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 4)
CloseCorner.Parent = CloseButton

-- Контейнер для вкладок и контента
local TabContainer = Instance.new("Frame")
TabContainer.Name = "TabContainer"
TabContainer.Size = UDim2.new(1, 0, 1, -40)
TabContainer.Position = UDim2.new(0, 0, 0, 40)
TabContainer.BackgroundTransparency = 1
TabContainer.Parent = MainFrame

-- Левая панель вкладок
local TabButtons = Instance.new("Frame")
TabButtons.Name = "TabButtons"
TabButtons.Size = UDim2.new(0, 120, 1, 0)
TabButtons.Position = UDim2.new(0, 0, 0, 0)
TabButtons.BackgroundColor3 = Color3.fromRGB(25, 25, 32)
TabButtons.BackgroundTransparency = 0.1
TabButtons.BorderSizePixel = 0
TabButtons.Parent = TabContainer

local TabButtonsCorner = Instance.new("UICorner")
TabButtonsCorner.CornerRadius = UDim.new(0, 8)
TabButtonsCorner.Parent = TabButtons

-- Правая панель контента
local ContentFrame = Instance.new("Frame")
ContentFrame.Name = "ContentFrame"
ContentFrame.Size = UDim2.new(1, -120, 1, 0)
ContentFrame.Position = UDim2.new(0, 120, 0, 0)
ContentFrame.BackgroundTransparency = 1
ContentFrame.Parent = TabContainer

-- Список вкладок
local Tabs = {
    "Combat",
    "Movement", 
    "Visuals",
    "Misc"
}

local CurrentTab = "Combat"
local Elements = {}
local TabButtonsList = {}

-- Глобальные переменные для функций
_G.AimbotEnabled = false
_G.AimbotFOV = 50
_G.VisibleCheck = true
_G.AutoShoot = false
_G.FlyEnabled = false
_G.FlySpeed = 50
_G.SpeedEnabled = false
_G.SpeedValue = 50
_G.NoclipEnabled = false
_G.ESPEnabled = false
_G.ESPBoxes = true
_G.ESPNames = true
_G.ESPHealth = true
_G.ESPDistance = 200
_G.ESPColor = Color3.fromRGB(255, 0, 0)
_G.SpammerEnabled = true

-- Функция создания кнопки вкладки
local function CreateTabButton(tabName, index)
    local Button = Instance.new("TextButton")
    Button.Name = tabName .. "Button"
    Button.Size = UDim2.new(1, -10, 0, 35)
    Button.Position = UDim2.new(0, 5, 0, 5 + ((index - 1) * 40))
    Button.BackgroundColor3 = tabName == CurrentTab and Color3.fromRGB(70, 130, 255) or Color3.fromRGB(40, 40, 50)
    Button.BackgroundTransparency = 0.1
    Button.Text = tabName
    Button.TextColor3 = Color3.fromRGB(255, 255, 255)
    Button.TextSize = 12
    Button.Font = Enum.Font.Gotham
    Button.Parent = TabButtons
    
    local ButtonCorner = Instance.new("UICorner")
    ButtonCorner.CornerRadius = UDim.new(0, 4)
    ButtonCorner.Parent = Button
    
    Button.MouseButton1Click:Connect(function()
        CurrentTab = tabName
        -- Обновить видимость контента
        for _, element in pairs(Elements) do
            if element.Tab == tabName then
                element.Frame.Visible = true
            else
                element.Frame.Visible = false
            end
        end
        -- Обновить кнопки
        for _, btn in pairs(TabButtons:GetChildren()) do
            if btn:IsA("TextButton") then
                btn.BackgroundColor3 = btn.Name == tabName .. "Button" and Color3.fromRGB(70, 130, 255) or Color3.fromRGB(40, 40, 50)
            end
        end
    end)
    
    TabButtonsList[tabName] = Button
end

-- Функция создания секции
local function CreateSection(tabName, sectionName, height)
    local SectionFrame = Instance.new("Frame")
    SectionFrame.Name = tabName .. sectionName .. "Section"
    SectionFrame.Size = UDim2.new(1, -20, 0, height or 200)
    SectionFrame.Position = UDim2.new(0, 10, 0, 10)
    SectionFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 38)
    SectionFrame.BackgroundTransparency = 0.15
    SectionFrame.BorderSizePixel = 0
    SectionFrame.Visible = tabName == CurrentTab
    SectionFrame.Parent = ContentFrame
    
    local SectionCorner = Instance.new("UICorner")
    SectionCorner.CornerRadius = UDim.new(0, 6)
    SectionCorner.Parent = SectionFrame
    
    local SectionTitle = Instance.new("TextLabel")
    SectionTitle.Name = "Title"
    SectionTitle.Size = UDim2.new(1, 0, 0, 30)
    SectionTitle.Position = UDim2.new(0, 0, 0, 0)
    SectionTitle.BackgroundTransparency = 1
    SectionTitle.Text = sectionName
    SectionTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
    SectionTitle.TextSize = 13
    SectionTitle.Font = Enum.Font.GothamSemibold
    SectionTitle.Parent = SectionFrame
    
    table.insert(Elements, {Tab = tabName, Frame = SectionFrame})
    return SectionFrame
end

-- Создание вкладок
for i, tabName in pairs(Tabs) do
    CreateTabButton(tabName, i)
end

-- Переменная для отслеживания элементов в секции
local elementCounters = {}

-- Функция создания переключателя
local function CreateToggle(section, text, default, callback)
    if not elementCounters[section] then
        elementCounters[section] = 0
    end
    
    elementCounters[section] = elementCounters[section] + 1
    
    local ToggleFrame = Instance.new("Frame")
    ToggleFrame.Size = UDim2.new(1, -20, 0, 25)
    ToggleFrame.Position = UDim2.new(0, 10, 0, 35 + ((elementCounters[section] - 1) * 35))
    ToggleFrame.BackgroundTransparency = 1
    ToggleFrame.Parent = section
    
    local ToggleButton = Instance.new("TextButton")
    ToggleButton.Size = UDim2.new(0, 20, 0, 20)
    ToggleButton.Position = UDim2.new(0, 0, 0, 0)
    ToggleButton.BackgroundColor3 = default and Color3.fromRGB(70, 130, 255) or Color3.fromRGB(80, 80, 80)
    ToggleButton.BackgroundTransparency = 0.1
    ToggleButton.Text = ""
    ToggleButton.Parent = ToggleFrame
    
    local ToggleCorner = Instance.new("UICorner")
    ToggleCorner.CornerRadius = UDim.new(0, 4)
    ToggleCorner.Parent = ToggleButton
    
    local ToggleLabel = Instance.new("TextLabel")
    ToggleLabel.Size = UDim2.new(1, -30, 1, 0)
    ToggleLabel.Position = UDim2.new(0, 25, 0, 0)
    ToggleLabel.BackgroundTransparency = 1
    ToggleLabel.Text = text
    ToggleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    ToggleLabel.TextSize = 12
    ToggleLabel.Font = Enum.Font.Gotham
    ToggleLabel.TextXAlignment = Enum.TextXAlignment.Left
    ToggleLabel.Parent = ToggleFrame
    
    if text ~= "Enable Spammer" then
        ToggleButton.MouseButton1Click:Connect(function()
            default = not default
            ToggleButton.BackgroundColor3 = default and Color3.fromRGB(70, 130, 255) or Color3.fromRGB(80, 80, 80)
            if callback then
                callback(default)
            end
        end)
    else
        ToggleButton.BackgroundColor3 = Color3.fromRGB(70, 130, 255)
        ToggleButton.Active = false
        ToggleLabel.Text = "Enable Spammer (Always ON)"
    end
    
    return {Set = function(value) 
        default = value 
        ToggleButton.BackgroundColor3 = default and Color3.fromRGB(70, 130, 255) or Color3.fromRGB(80, 80, 80)
    end}
end

-- Функция создания слайдера
local function CreateSlider(section, text, min, max, default, callback)
    if not elementCounters[section] then
        elementCounters[section] = 0
    end
    
    elementCounters[section] = elementCounters[section] + 1
    
    local SliderFrame = Instance.new("Frame")
    SliderFrame.Size = UDim2.new(1, -20, 0, 40)
    SliderFrame.Position = UDim2.new(0, 10, 0, 35 + ((elementCounters[section] - 1) * 45))
    SliderFrame.BackgroundTransparency = 1
    SliderFrame.Parent = section
    
    local SliderLabel = Instance.new("TextLabel")
    SliderLabel.Size = UDim2.new(1, 0, 0, 20)
    SliderLabel.Position = UDim2.new(0, 0, 0, 0)
    SliderLabel.BackgroundTransparency = 1
    SliderLabel.Text = text .. ": " .. default
    SliderLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    SliderLabel.TextSize = 12
    SliderLabel.Font = Enum.Font.Gotham
    SliderLabel.TextXAlignment = Enum.TextXAlignment.Left
    SliderLabel.Parent = SliderFrame
    
    local SliderBar = Instance.new("Frame")
    SliderBar.Size = UDim2.new(1, 0, 0, 5)
    SliderBar.Position = UDim2.new(0, 0, 0, 25)
    SliderBar.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
    SliderBar.BorderSizePixel = 0
    SliderBar.Parent = SliderFrame
    
    local SliderBarCorner = Instance.new("UICorner")
    SliderBarCorner.CornerRadius = UDim.new(0, 3)
    SliderBarCorner.Parent = SliderBar
    
    local SliderFill = Instance.new("Frame")
    SliderFill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    SliderFill.Position = UDim2.new(0, 0, 0, 0)
    SliderFill.BackgroundColor3 = Color3.fromRGB(70, 130, 255)
    SliderFill.BorderSizePixel = 0
    SliderFill.Parent = SliderBar
    
    local SliderFillCorner = Instance.new("UICorner")
    SliderFillCorner.CornerRadius = UDim.new(0, 3)
    SliderFillCorner.Parent = SliderFill
    
    local dragging = false
    
    local function updateSlider(value)
        local percent = math.clamp((value - min) / (max - min), 0, 1)
        SliderFill.Size = UDim2.new(percent, 0, 1, 0)
        SliderLabel.Text = text .. ": " .. math.floor(value)
        if callback then
            callback(value)
        end
    end
    
    SliderBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
        end
    end)
    
    SliderBar.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local relativeX = (input.Position.X - SliderBar.AbsolutePosition.X) / SliderBar.AbsoluteSize.X
            local value = min + (relativeX * (max - min))
            value = math.clamp(math.floor(value), min, max)
            updateSlider(value)
        end
    end)
    
    updateSlider(default)
end

-- УЛУЧШЕННЫЙ ФЛАЙХАК С ВАЛИДАЦИЕЙ --
local function FlyFunction(enabled)
    _G.FlyEnabled = enabled
    
    if enabled then
        -- Валидация персонажа
        if not LocalPlayer.Character then
            warn("Fly Hack: Character not found")
            return
        end
        
        local humanoidRootPart = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if not humanoidRootPart then
            warn("Fly Hack: HumanoidRootPart not found")
            return
        end
        
        -- Создание BodyVelocity с валидацией
        local bodyVelocity = Instance.new("BodyVelocity")
        bodyVelocity.Velocity = Vector3.new(0, 0, 0)
        bodyVelocity.MaxForce = Vector3.new(40000, 40000, 40000)
        bodyVelocity.Parent = humanoidRootPart
        
        _G.FlyConnection = RunService.Heartbeat:Connect(function()
            if not _G.FlyEnabled then return end
            
            -- Постоянная валидация
            if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                if _G.FlyConnection then
                    _G.FlyConnection:Disconnect()
                end
                return
            end
            
            local root = LocalPlayer.Character.HumanoidRootPart
            local newVelocity = Vector3.new(0, 0, 0)
            
            -- Движение с настраиваемой скоростью
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                newVelocity = newVelocity + Workspace.CurrentCamera.CFrame.LookVector * _G.FlySpeed
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                newVelocity = newVelocity - Workspace.CurrentCamera.CFrame.LookVector * _G.FlySpeed
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                newVelocity = newVelocity - Workspace.CurrentCamera.CFrame.RightVector * _G.FlySpeed
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                newVelocity = newVelocity + Workspace.CurrentCamera.CFrame.RightVector * _G.FlySpeed
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                newVelocity = newVelocity + Vector3.new(0, _G.FlySpeed, 0)
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
                newVelocity = newVelocity - Vector3.new(0, _G.FlySpeed, 0)
            end
            
            -- Обновление скорости с проверкой существования BodyVelocity
            local currentBV = root:FindFirstChild("BodyVelocity")
            if currentBV then
                currentBV.Velocity = newVelocity
            else
                -- Пересоздание если BodyVelocity был удален
                local newBV = Instance.new("BodyVelocity")
                newBV.Velocity = Vector3.new(0, 0, 0)
                newBV.MaxForce = Vector3.new(40000, 40000, 40000)
                newBV.Parent = root
                newBV.Velocity = newVelocity
            end
        end)
    else
        -- Отключение флайхака с очисткой
        if _G.FlyConnection then
            _G.FlyConnection:Disconnect()
        end
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local bv = LocalPlayer.Character.HumanoidRootPart:FindFirstChild("BodyVelocity")
            if bv then 
                bv:Destroy() 
            end
        end
    end
end

-- Спидхак с валидацией
local function SpeedFunction(enabled)
    _G.SpeedEnabled = enabled
    if enabled then
        _G.SpeedConnection = RunService.Heartbeat:Connect(function()
            if not _G.SpeedEnabled or not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("Humanoid") then 
                return 
            end
            LocalPlayer.Character.Humanoid.WalkSpeed = _G.SpeedValue
        end)
    else
        if _G.SpeedConnection then
            _G.SpeedConnection:Disconnect()
        end
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.WalkSpeed = 16
        end
    end
end

-- Ноклип с валидацией
local function NoclipFunction(enabled)
    _G.NoclipEnabled = enabled
    if enabled then
        _G.NoclipConnection = RunService.Stepped:Connect(function()
            if not _G.NoclipEnabled or not LocalPlayer.Character then return end
            for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end)
    else
        if _G.NoclipConnection then
            _G.NoclipConnection:Disconnect()
        end
    end
end

-- Спаммер (всегда включен)
local function StartSpammer()
    spawn(function()
        while true do
            wait(math.random(30, 40))
            local chatEvent = game:GetService("ReplicatedStorage"):FindFirstChild("DefaultChatSystemChatEvents")
            if chatEvent then
                local sayMessage = chatEvent:FindFirstChild("SayMessageRequest")
                if sayMessage then
                    local messages = {
                        "тэгэ expensivemods чит",
                        "т3г3 expensivemods читаем", 
                        "tege expensivemods читаем",
                        "тэгэ expensivemods читаем",
                        "т3г3 expensivemods читаем",
                        "tege expensivemods читаем"
                    }
                    
                    local randomMsg = messages[math.random(1, #messages)]
                    pcall(function()
                        sayMessage:FireServer(randomMsg, "All")
                    end)
                end
            end
        end
    end)
end

-- Создание секций и элементов
local CombatSection = CreateSection("Combat", "Aimbot", 200)
local aimbotToggle = CreateToggle(CombatSection, "Enable Aimbot", false, function(value)
    _G.AimbotEnabled = value
end)
CreateSlider(CombatSection, "Aimbot FOV", 10, 300, 50, function(value)
    _G.AimbotFOV = value
end)
local visibleToggle = CreateToggle(CombatSection, "Visible Check", true, function(value)
    _G.VisibleCheck = value
end)
local autoShootToggle = CreateToggle(CombatSection, "Auto Shoot", false, function(value)
    _G.AutoShoot = value
end)

local MovementSection = CreateSection("Movement", "Movement Hacks", 250)
local flyToggle = CreateToggle(MovementSection, "Fly Hack", false, FlyFunction)
CreateSlider(MovementSection, "Fly Speed", 1, 200, 50, function(value)
    _G.FlySpeed = value
end)
local speedToggle = CreateToggle(MovementSection, "Speed Hack", false, SpeedFunction)
CreateSlider(MovementSection, "Speed Value", 16, 100, 50, function(value)
    _G.SpeedValue = value
    if _G.SpeedEnabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.WalkSpeed = value
    end
end)
local noclipToggle = CreateToggle(MovementSection, "Noclip", false, NoclipFunction)

local VisualsSection = CreateSection("Visuals", "ESP", 150)
local espToggle = CreateToggle(VisualsSection, "Enable ESP", false, function(value)
    _G.ESPEnabled = value
end)
CreateSlider(VisualsSection, "ESP Distance", 50, 500, 200, function(value)
    _G.ESPDistance = value
end)

local MiscSection = CreateSection("Misc", "Other", 120)
local spammerToggle = CreateToggle(MiscSection, "Enable Spammer", true, function() end)

-- Автоматический запуск спаммера
StartSpammer()

-- Функция перемещения GUI
local dragging = false
local dragStart = nil
local startPos = nil

Header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- Закрытие GUI
CloseButton.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

-- Открытие/закрытие по Insert
local menuVisible = true
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.KeyCode == Enum.KeyCode.Insert then
        menuVisible = not menuVisible
        MainFrame.Visible = menuVisible
    end
end)

-- Уведомление
local Notification = Instance.new("TextLabel")
Notification.Size = UDim2.new(0, 350, 0, 40)
Notification.Position = UDim2.new(0.5, -175, 0, 10)
Notification.BackgroundColor3 = Color3.fromRGB(30, 30, 38)
Notification.BackgroundTransparency = 0.15
Notification.Text = "ExpensiveMods loaded! Press INSERT to toggle menu"
Notification.TextColor3 = Color3.fromRGB(255, 255, 255)
Notification.TextSize = 14
Notification.Font = Enum.Font.Gotham
Notification.Parent = ScreenGui

local NotifCorner = Instance.new("UICorner")
NotifCorner.CornerRadius = UDim.new(0, 6)
NotifCorner.Parent = Notification

-- Авто-скрытие уведомления
delay(5, function()
    if Notification then
        local tween = TweenService:Create(Notification, TweenInfo.new(0.5), {BackgroundTransparency = 1, TextTransparency = 1})
        tween:Play()
        tween.Completed:Connect(function()
            if Notification then
                Notification:Destroy()
            end
        end)
    end
end)

print("ExpensiveMods successfully loaded! All features are working.")
