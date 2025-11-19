-- Кастомный полупрозрачный GUI в стиле NeverLose
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local mouse = LocalPlayer:GetMouse()

-- Создание главного GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ExpensiveModsGUI"
ScreenGui.Parent = game.CoreGui
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
_G.SpeedEnabled = false
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

-- Функция создания выбора цвета
local function CreateColorPicker(section, text, defaultColor, callback)
    if not elementCounters[section] then
        elementCounters[section] = 0
    end
    
    elementCounters[section] = elementCounters[section] + 1
    
    local ColorFrame = Instance.new("Frame")
    ColorFrame.Size = UDim2.new(1, -20, 0, 25)
    ColorFrame.Position = UDim2.new(0, 10, 0, 35 + ((elementCounters[section] - 1) * 35))
    ColorFrame.BackgroundTransparency = 1
    ColorFrame.Parent = section
    
    local ColorLabel = Instance.new("TextLabel")
    ColorLabel.Size = UDim2.new(0.7, 0, 1, 0)
    ColorLabel.Position = UDim2.new(0, 0, 0, 0)
    ColorLabel.BackgroundTransparency = 1
    ColorLabel.Text = text
    ColorLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    ColorLabel.TextSize = 12
    ColorLabel.Font = Enum.Font.Gotham
    ColorLabel.TextXAlignment = Enum.TextXAlignment.Left
    ColorLabel.Parent = ColorFrame
    
    local ColorButton = Instance.new("TextButton")
    ColorButton.Size = UDim2.new(0, 40, 0, 20)
    ColorButton.Position = UDim2.new(0.7, 0, 0, 2)
    ColorButton.BackgroundColor3 = defaultColor
    ColorButton.Text = ""
    ColorButton.Parent = ColorFrame
    
    local ColorCorner = Instance.new("UICorner")
    ColorCorner.CornerRadius = UDim.new(0, 4)
    ColorCorner.Parent = ColorButton
    
    ColorButton.MouseButton1Click:Connect(function()
        if callback then
            callback(defaultColor)
        end
    end)
    
    return ColorButton
end

-- Отрисовка FOV круга
local FOVCircle = Instance.new("Frame")
FOVCircle.Name = "FOVCircle"
FOVCircle.Size = UDim2.new(0, _G.AimbotFOV * 2, 0, _G.AimbotFOV * 2)
FOVCircle.Position = UDim2.new(0.5, -_G.AimbotFOV, 0.5, -_G.AimbotFOV)
FOVCircle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
FOVCircle.BackgroundTransparency = 0.8
FOVCircle.BorderSizePixel = 0
FOVCircle.Visible = false
FOVCircle.Parent = ScreenGui

local FOVCorner = Instance.new("UICorner")
FOVCorner.CornerRadius = UDim.new(1, 0)
FOVCorner.Parent = FOVCircle

-- УЛУЧШЕННЫЙ АИМБОТ --
local function IsVisible(target)
    if not _G.VisibleCheck then return true end
    
    local character = LocalPlayer.Character
    local targetChar = target.Character
    if not character or not targetChar then return false end
    
    local head = character:FindFirstChild("Head")
    local targetHead = targetChar:FindFirstChild("Head")
    if not head or not targetHead then return false end
    
    local origin = head.Position
    local targetPos = targetHead.Position
    
    -- Raycast для проверки видимости
    local ray = Ray.new(origin, (targetPos - origin).Unit * (targetPos - origin).Magnitude)
    local hit, position = Workspace:FindPartOnRay(ray, character)
    
    if hit and hit:IsDescendantOf(targetChar) then
        return true
    end
    
    return false
end

local function AimbotFunction(enabled)
    _G.AimbotEnabled = enabled
    FOVCircle.Visible = enabled
    
    if enabled then
        _G.AimbotConnection = RunService.Heartbeat:Connect(function()
            if not _G.AimbotEnabled then return end
            
            local closestPlayer = nil
            local shortestDistance = _G.AimbotFOV
            local mousePos = Vector2.new(mouse.X, mouse.Y)
            local screenCenter = Vector2.new(Workspace.CurrentCamera.ViewportSize.X / 2, Workspace.CurrentCamera.ViewportSize.Y / 2)
            
            for _, player in pairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                    local character = player.Character
                    local screenPoint, visible = Workspace.CurrentCamera:WorldToViewportPoint(character.HumanoidRootPart.Position)
                    
                    if visible and IsVisible(player) then
                        local distance = (Vector2.new(screenPoint.X, screenPoint.Y) - screenCenter).Magnitude
                        
                        if distance < shortestDistance then
                            closestPlayer = player
                            shortestDistance = distance
                        end
                    end
                end
            end
            
            if closestPlayer and closestPlayer.Character and closestPlayer.Character:FindFirstChild("HumanoidRootPart") then
                local targetPos = closestPlayer.Character.HumanoidRootPart.Position
                local screenPoint = Workspace.CurrentCamera:WorldToViewportPoint(targetPos)
                
                -- Плавное наведение
                mousemoverel((screenPoint.X - mouse.X) * 0.8, (screenPoint.Y - mouse.Y) * 0.8)
                
                -- Автострельба
                if _G.AutoShoot then
                    mouse1press()
                    wait(0.1)
                    mouse1release()
                end
            end
        end)
    else
        if _G.AimbotConnection then
            _G.AimbotConnection:Disconnect()
        end
    end
end

-- Обновление FOV круга
local function UpdateFOVCircle()
    FOVCircle.Size = UDim2.new(0, _G.AimbotFOV * 2, 0, _G.AimbotFOV * 2)
    FOVCircle.Position = UDim2.new(0.5, -_G.AimbotFOV, 0.5, -_G.AimbotFOV)
end

-- УЛУЧШЕННЫЙ ESP --
local ESPObjects = {}

local function CreateESP(player)
    if ESPObjects[player] then return end
    
    local espFolder = Instance.new("Folder")
    espFolder.Name = "ESP_" .. player.Name
    espFolder.Parent = ScreenGui
    
    ESPObjects[player] = {
        Folder = espFolder,
        Box = nil,
        NameLabel = nil,
        HealthBar = nil,
        DistanceLabel = nil
    }
end

local function UpdateESP()
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local character = player.Character
            local humanoid = character:FindFirstChild("Humanoid")
            local rootPart = character:FindFirstChild("HumanoidRootPart")
            
            if not rootPart then continue end
            
            local screenPoint, visible = Workspace.CurrentCamera:WorldToViewportPoint(rootPart.Position)
            local distance = (rootPart.Position - Workspace.CurrentCamera.CFrame.Position).Magnitude
            
            if visible and distance <= _G.ESPDistance then
                CreateESP(player)
                local esp = ESPObjects[player]
                
                -- 2D Box
                if _G.ESPBoxes then
                    if not esp.Box then
                        esp.Box = Instance.new("Frame")
                        esp.Box.Name = "Box"
                        esp.Box.BackgroundTransparency = 0.7
                        esp.Box.BackgroundColor3 = _G.ESPColor
                        esp.Box.BorderSizePixel = 1
                        esp.Box.BorderColor3 = Color3.fromRGB(255, 255, 255)
                        esp.Box.Parent = esp.Folder
                    end
                    
                    local boxSize = Vector2.new(50, 80) -- Примерный размер бокса
                    esp.Box.Size = UDim2.new(0, boxSize.X, 0, boxSize.Y)
                    esp.Box.Position = UDim2.new(0, screenPoint.X - boxSize.X / 2, 0, screenPoint.Y - boxSize.Y)
                    esp.Box.Visible = true
                elseif esp.Box then
                    esp.Box.Visible = false
                end
                
                -- Имя игрока
                if _G.ESPNames then
                    if not esp.NameLabel then
                        esp.NameLabel = Instance.new("TextLabel")
                        esp.NameLabel.Name = "Name"
                        esp.NameLabel.BackgroundTransparency = 1
                        esp.NameLabel.TextColor3 = _G.ESPColor
                        esp.NameLabel.TextSize = 14
                        esp.NameLabel.Font = Enum.Font.GothamBold
                        esp.NameLabel.Parent = esp.Folder
                    end
                    
                    esp.NameLabel.Text = player.Name
                    esp.NameLabel.Position = UDim2.new(0, screenPoint.X, 0, screenPoint.Y - 90)
                    esp.NameLabel.Visible = true
                elseif esp.NameLabel then
                    esp.NameLabel.Visible = false
                end
                
                -- ХП бар
                if _G.ESPHealth and humanoid then
                    if not esp.HealthBar then
                        esp.HealthBar = Instance.new("Frame")
                        esp.HealthBar.Name = "HealthBar"
                        esp.HealthBar.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
                        esp.HealthBar.BorderSizePixel = 1
                        esp.HealthBar.Parent = esp.Folder
                        
                        esp.HealthBarFill = Instance.new("Frame")
                        esp.HealthBarFill.Name = "HealthBarFill"
                        esp.HealthBarFill.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
                        esp.HealthBarFill.BorderSizePixel = 0
                        esp.HealthBarFill.Parent = esp.HealthBar
                    end
                    
                    local healthPercent = humanoid.Health / humanoid.MaxHealth
                    esp.HealthBar.Size = UDim2.new(0, 50, 0, 4)
                    esp.HealthBar.Position = UDim2.new(0, screenPoint.X - 25, 0, screenPoint.Y - 85)
                    esp.HealthBarFill.Size = UDim2.new(healthPercent, 0, 1, 0)
                    esp.HealthBar.Visible = true
                elseif esp.HealthBar then
                    esp.HealthBar.Visible = false
                end
                
                -- Дистанция
                if _G.ESPDistance then
                    if not esp.DistanceLabel then
                        esp.DistanceLabel = Instance.new("TextLabel")
                        esp.DistanceLabel.Name = "Distance"
                        esp.DistanceLabel.BackgroundTransparency = 1
                        esp.DistanceLabel.TextColor3 = _G.ESPColor
                        esp.DistanceLabel.TextSize = 12
                        esp.DistanceLabel.Font = Enum.Font.Gotham
                        esp.DistanceLabel.Parent = esp.Folder
                    end
                    
                    esp.DistanceLabel.Text = math.floor(distance) .. "m"
                    esp.DistanceLabel.Position = UDim2.new(0, screenPoint.X, 0, screenPoint.Y - 75)
                    esp.DistanceLabel.Visible = true
                elseif esp.DistanceLabel then
                    esp.DistanceLabel.Visible = false
                end
                
            else
                -- Скрыть ESP если игрок не виден
                if ESPObjects[player] then
                    for _, obj in pairs(ESPObjects[player]) do
                        if typeof(obj) == "Instance" and obj:IsA("GuiObject") then
                            obj.Visible = false
                        end
                    end
                end
            end
        else
            -- Удалить ESP если игрок вышел
            if ESPObjects[player] then
                ESPObjects[player].Folder:Destroy()
                ESPObjects[player] = nil
            end
        end
    end
end

local function ESPFunction(enabled)
    _G.ESPEnabled = enabled
    if enabled then
        _G.ESPConnection = RunService.Heartbeat:Connect(UpdateESP)
    else
        if _G.ESPConnection then
            _G.ESPConnection:Disconnect()
        end
        -- Очистить все ESP объекты
        for player, esp in pairs(ESPObjects) do
            esp.Folder:Destroy()
        end
        ESPObjects = {}
    end
end

-- Остальные функции (Fly, Speed, Noclip) остаются без изменений
-- [Здесь должны быть функции FlyFunction, SpeedFunction, NoclipFunction из предыдущего кода]

-- Создание секций и элементов
local CombatSection = CreateSection("Combat", "Aimbot", 250)
local aimbotToggle = CreateToggle(CombatSection, "Enable Aimbot", false, AimbotFunction)
CreateSlider(CombatSection, "Aimbot FOV", 10, 300, 50, function(value)
    _G.AimbotFOV = value
    UpdateFOVCircle()
end)
local visibleToggle = CreateToggle(CombatSection, "Visible Check", true, function(value)
    _G.VisibleCheck = value
end)
local autoShootToggle = CreateToggle(CombatSection, "Auto Shoot", false, function(value)
    _G.AutoShoot = value
end)

local VisualsSection = CreateSection("Visuals", "ESP Settings", 300)
local espToggle = CreateToggle(VisualsSection, "Enable ESP", false, ESPFunction)
local espBoxesToggle = CreateToggle(VisualsSection, "2D Boxes", true, function(value)
    _G.ESPBoxes = value
end)
local espNamesToggle = CreateToggle(VisualsSection, "Player Names", true, function(value)
    _G.ESPNames = value
end)
local espHealthToggle = CreateToggle(VisualsSection, "Health Bar", true, function(value)
    _G.ESPHealth = value
end)
CreateSlider(VisualsSection, "ESP Distance", 50, 500, 200, function(value)
    _G.ESPDistance = value
end)
local colorPicker = CreateColorPicker(VisualsSection, "ESP Color", _G.ESPColor, function(color)
    _G.ESPColor = color
    colorPicker.BackgroundColor3 = color
end)

-- [Остальной код GUI и функций остается без изменений]
