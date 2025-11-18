-- RAGE MOD Fly Hack UI для Roblox (Neverlose стиль)
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer

-- Fly Hack переменные
local Flying = false
local FlySpeed = 50
local BodyVelocity
local BodyGyro
local MenuVisible = false
local Dragging = false
local DragStart, StartPosition

-- Цветовая схема Neverlose
local COLOR_BACKGROUND = Color3.fromRGB(20, 20, 25)
local COLOR_ACCENT = Color3.fromRGB(0, 150, 255)
local COLOR_SECONDARY = Color3.fromRGB(30, 35, 45)
local COLOR_TEXT = Color3.fromRGB(240, 240, 240)
local COLOR_SUCCESS = Color3.fromRGB(0, 200, 83)
local COLOR_WARNING = Color3.fromRGB(255, 193, 7)
local COLOR_ERROR = Color3.fromRGB(255, 50, 50)

-- Создание GUI в стиле Neverlose
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "RAGENeverloseUI"
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

-- Основной контейнер
local MainContainer = Instance.new("Frame")
MainContainer.Name = "MainContainer"
MainContainer.Size = UDim2.new(0, 400, 0, 500)
MainContainer.Position = UDim2.new(0.1, 0, 0.2, 0)
MainContainer.BackgroundColor3 = COLOR_BACKGROUND
MainContainer.BackgroundTransparency = 0.05
MainContainer.BorderSizePixel = 0
MainContainer.ClipsDescendants = true
MainContainer.Visible = false
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
Title.Text = "RAGE MOD | FLY HACK"
Title.TextColor3 = COLOR_TEXT
Title.TextSize = 16
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

-- Секция Fly Hack
local FlySection = Instance.new("Frame")
FlySection.Name = "FlySection"
FlySection.Size = UDim2.new(1, 0, 0, 120)
FlySection.BackgroundColor3 = COLOR_SECONDARY
FlySection.BackgroundTransparency = 0.9
FlySection.Parent = Content

local FlyCorner = Instance.new("UICorner")
FlyCorner.CornerRadius = UDim.new(0, 8)
FlyCorner.Parent = FlySection

local FlyStroke = Instance.new("UIStroke")
FlyStroke.Color = COLOR_ACCENT
FlyStroke.Thickness = 1
FlyStroke.Transparency = 0.5
FlyStroke.Parent = FlySection

local FlyTitle = Instance.new("TextLabel")
FlyTitle.Name = "FlyTitle"
FlyTitle.Size = UDim2.new(1, 0, 0, 30)
FlyTitle.BackgroundTransparency = 1
FlyTitle.Text = "FLY HACK"
FlyTitle.TextColor3 = COLOR_ACCENT
FlyTitle.TextSize = 14
FlyTitle.Font = Enum.Font.GothamBold
FlyTitle.Parent = FlySection

-- Кнопка переключения Fly
local FlyToggle = Instance.new("TextButton")
FlyToggle.Name = "FlyToggle"
FlyToggle.Size = UDim2.new(1, -20, 0, 40)
FlyToggle.Position = UDim2.new(0, 10, 0, 35)
FlyToggle.BackgroundColor3 = COLOR_ERROR
FlyToggle.Text = "FLY: DISABLED"
FlyToggle.TextColor3 = COLOR_TEXT
FlyToggle.TextSize = 12
FlyToggle.Font = Enum.Font.GothamBold
FlyToggle.Parent = FlySection

local ToggleCorner = Instance.new("UICorner")
ToggleCorner.CornerRadius = UDim.new(0, 6)
ToggleCorner.Parent = FlyToggle

-- Секция настроек скорости
local SpeedSection = Instance.new("Frame")
SpeedSection.Name = "SpeedSection"
SpeedSection.Size = UDim2.new(1, 0, 0, 150)
SpeedSection.Position = UDim2.new(0, 0, 0, 130)
SpeedSection.BackgroundColor3 = COLOR_SECONDARY
SpeedSection.BackgroundTransparency = 0.9
SpeedSection.Parent = Content

local SpeedCorner = Instance.new("UICorner")
SpeedCorner.CornerRadius = UDim.new(0, 8)
SpeedCorner.Parent = SpeedSection

local SpeedStroke = Instance.new("UIStroke")
SpeedStroke.Color = COLOR_ACCENT
SpeedStroke.Thickness = 1
SpeedStroke.Transparency = 0.5
SpeedStroke.Parent = SpeedSection

local SpeedTitle = Instance.new("TextLabel")
SpeedTitle.Name = "SpeedTitle"
SpeedTitle.Size = UDim2.new(1, 0, 0, 30)
SpeedTitle.BackgroundTransparency = 1
SpeedTitle.Text = "SPEED SETTINGS"
SpeedTitle.TextColor3 = COLOR_ACCENT
SpeedTitle.TextSize = 14
SpeedTitle.Font = Enum.Font.GothamBold
SpeedTitle.Parent = SpeedSection

-- Поле ввода скорости
local SpeedInputLabel = Instance.new("TextLabel")
SpeedInputLabel.Name = "SpeedInputLabel"
SpeedInputLabel.Size = UDim2.new(1, -20, 0, 20)
SpeedInputLabel.Position = UDim2.new(0, 10, 0, 35)
SpeedInputLabel.BackgroundTransparency = 1
SpeedInputLabel.Text = "FLY SPEED"
SpeedInputLabel.TextColor3 = COLOR_TEXT
SpeedInputLabel.TextSize = 11
SpeedInputLabel.Font = Enum.Font.Gotham
SpeedInputLabel.TextXAlignment = Enum.TextXAlignment.Left
SpeedInputLabel.Parent = SpeedSection

local SpeedInputBox = Instance.new("TextBox")
SpeedInputBox.Name = "SpeedInputBox"
SpeedInputBox.Size = UDim2.new(1, -20, 0, 35)
SpeedInputBox.Position = UDim2.new(0, 10, 0, 55)
SpeedInputBox.BackgroundColor3 = COLOR_BACKGROUND
SpeedInputBox.BackgroundTransparency = 0.2
SpeedInputBox.TextColor3 = COLOR_TEXT
SpeedInputBox.Text = tostring(FlySpeed)
SpeedInputBox.TextSize = 12
SpeedInputBox.Font = Enum.Font.Gotham
SpeedInputBox.PlaceholderText = "Enter speed value..."
SpeedInputBox.PlaceholderColor3 = Color3.fromRGB(150, 150, 150)
SpeedInputBox.Parent = SpeedSection

local InputCorner = Instance.new("UICorner")
InputCorner.CornerRadius = UDim.new(0, 6)
InputCorner.Parent = SpeedInputBox

local InputStroke = Instance.new("UIStroke")
InputStroke.Color = COLOR_ACCENT
InputStroke.Thickness = 1
InputStroke.Transparency = 0.7
InputStroke.Parent = SpeedInputBox

-- Кнопка применения скорости
local ApplyButton = Instance.new("TextButton")
ApplyButton.Name = "ApplyButton"
ApplyButton.Size = UDim2.new(1, -20, 0, 35)
ApplyButton.Position = UDim2.new(0, 10, 0, 100)
ApplyButton.BackgroundColor3 = COLOR_ACCENT
ApplyButton.Text = "APPLY SPEED"
ApplyButton.TextColor3 = COLOR_TEXT
ApplyButton.TextSize = 12
ApplyButton.Font = Enum.Font.GothamBold
ApplyButton.Parent = SpeedSection

local ApplyCorner = Instance.new("UICorner")
ApplyCorner.CornerRadius = UDim.new(0, 6)
ApplyCorner.Parent = ApplyButton

-- Секция информации
local InfoSection = Instance.new("Frame")
InfoSection.Name = "InfoSection"
InfoSection.Size = UDim2.new(1, 0, 0, 80)
InfoSection.Position = UDim2.new(0, 0, 0, 290)
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
InfoText.Text = "HOME - Toggle Menu\nF - Toggle Fly Hack\nDrag header to move"
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

-- Функция переключения меню
local function toggleMenu()
    MenuVisible = not MenuVisible
    
    if MenuVisible then
        MainContainer.Visible = true
        MainContainer.Size = UDim2.new(0, 0, 0, 0)
        local tween = TweenService:Create(MainContainer, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
            Size = UDim2.new(0, 400, 0, 500)
        })
        tween:Play()
    else
        local tween = TweenService:Create(MainContainer, TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
            Size = UDim2.new(0, 0, 0, 0)
        })
        tween:Play()
        tween.Completed:Connect(function()
            MainContainer.Visible = false
        end)
    end
end

-- Функция применения скорости
local function applySpeed()
    local newSpeed = tonumber(SpeedInputBox.Text)
    if newSpeed and newSpeed > 0 and newSpeed <= 1000 then
        FlySpeed = newSpeed
        SpeedInputBox.Text = tostring(FlySpeed)
        
        ApplyButton.Text = "✓ APPLIED"
        ApplyButton.BackgroundColor3 = COLOR_SUCCESS
        wait(1)
        ApplyButton.Text = "APPLY SPEED"
        ApplyButton.BackgroundColor3 = COLOR_ACCENT
    else
        ApplyButton.Text = "✗ INVALID"
        ApplyButton.BackgroundColor3 = COLOR_ERROR
        wait(1)
        ApplyButton.Text = "APPLY SPEED"
        ApplyButton.BackgroundColor3 = COLOR_ACCENT
        SpeedInputBox.Text = tostring(FlySpeed)
    end
end

-- Функция Fly Hack
local function toggleFly()
    Flying = not Flying
    
    if Flying then
        FlyToggle.Text = "FLY: ENABLED"
        FlyToggle.BackgroundColor3 = COLOR_SUCCESS
        
        local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
        local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
        
        BodyVelocity = Instance.new("BodyVelocity")
        BodyGyro = Instance.new("BodyGyro")
        
        BodyVelocity.Velocity = Vector3.new(0, 0, 0)
        BodyVelocity.MaxForce = Vector3.new(400000, 400000, 400000)
        BodyVelocity.Parent = HumanoidRootPart
        
        BodyGyro.MaxTorque = Vector3.new(400000, 400000, 400000)
        BodyGyro.P = 100000
        BodyGyro.D = 1000
        BodyGyro.Parent = HumanoidRootPart
        
        local flyConnection
        flyConnection = RunService.Heartbeat:Connect(function()
            if not Flying then
                flyConnection:Disconnect()
                return
            end
            
            local camera = workspace.CurrentCamera
            BodyGyro.CFrame = camera.CFrame
            
            local direction = Vector3.new()
            
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                direction = direction + camera.CFrame.LookVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                direction = direction - camera.CFrame.LookVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                direction = direction - camera.CFrame.RightVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                direction = direction + camera.CFrame.RightVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                direction = direction + Vector3.new(0, 1, 0)
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
                direction = direction - Vector3.new(0, 1, 0)
            end
            
            BodyVelocity.Velocity = direction * FlySpeed
        end)
        
    else
        FlyToggle.Text = "FLY: DISABLED"
        FlyToggle.BackgroundColor3 = COLOR_ERROR
        
        if BodyVelocity then
            BodyVelocity:Destroy()
            BodyVelocity = nil
        end
        if BodyGyro then
            BodyGyro:Destroy()
            BodyGyro = nil
        end
    end
end

-- Обработчики событий
FlyToggle.MouseButton1Click:Connect(toggleFly)
ApplyButton.MouseButton1Click:Connect(applySpeed)
CloseButton.MouseButton1Click:Connect(function()
    toggleMenu()
end)

SpeedInputBox.FocusLost:Connect(function(enterPressed)
    if enterPressed then
        applySpeed()
    end
end)

-- Горячие клавиши
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.KeyCode == Enum.KeyCode.Home then
        toggleMenu()
    elseif input.KeyCode == Enum.KeyCode.F then
        toggleFly()
    end
end)

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

warn("[⚡] RAGE MOD Neverlose Style загружен!")
warn("Стиль: Neverlose")
warn("Горячие клавиши:")
warn("HOME - Открыть/Закрыть меню")
warn("F - Вкл/Выкл Fly Hack")
warn("Перетаскивайте заголовок для перемещения меню")
