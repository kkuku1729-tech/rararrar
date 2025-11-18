-- RAGE MOD Fly Hack UI для Roblox режим ruzt
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

-- Создание красивого GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "RAGEModFlyUI"
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 400, 0, 300)
MainFrame.Position = UDim2.new(0.5, -200, 0.5, -150)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
MainFrame.BorderSizePixel = 0
MainFrame.BackgroundTransparency = 0.1
MainFrame.Parent = ScreenGui

-- Анимация появления
MainFrame.Size = UDim2.new(0, 0, 0, 0)
MainFrame:TweenSize(UDim2.new(0, 400, 0, 300), "Out", "Quad", 1, true)

-- Эффект свечения
local Glow = Instance.new("UIStroke")
Glow.Name = "Glow"
Glow.Color = Color3.fromRGB(255, 0, 0)
Glow.Thickness = 3
Glow.Transparency = 0.3
Glow.Parent = MainFrame

-- Заголовок
local Title = Instance.new("TextLabel")
Title.Name = "Title"
Title.Size = UDim2.new(1, 0, 0, 50)
Title.Position = UDim2.new(0, 0, 0, 0)
Title.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
Title.BackgroundTransparency = 0.2
Title.Text = "[⚡] RAGE MOD FLY HACK"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextScaled = true
Title.Font = Enum.Font.GothamBold
Title.Parent = MainFrame

-- Кнопка Fly Hack
local FlyButton = Instance.new("TextButton")
FlyButton.Name = "FlyButton"
FlyButton.Size = UDim2.new(0.8, 0, 0, 60)
FlyButton.Position = UDim2.new(0.1, 0, 0.3, 0)
FlyButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
FlyButton.Text = "FLY HACK: OFF"
FlyButton.TextColor3 = Color3.fromRGB(255, 255, 255)
FlyButton.TextScaled = true
FlyButton.Font = Enum.Font.GothamBold
FlyButton.Parent = MainFrame

-- Слайдер скорости
local SpeedSlider = Instance.new("TextLabel")
SpeedSlider.Name = "SpeedSlider"
SpeedSlider.Size = UDim2.new(0.8, 0, 0, 30)
SpeedSlider.Position = UDim2.new(0.1, 0, 0.6, 0)
SpeedSlider.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
SpeedSlider.Text = "Скорость полета: " .. FlySpeed
SpeedSlider.TextColor3 = Color3.fromRGB(255, 255, 255)
SpeedSlider.TextScaled = true
SpeedSlider.Font = Enum.Font.Gotham
SpeedSlider.Parent = MainFrame

-- Кнопка закрытия
local CloseButton = Instance.new("TextButton")
CloseButton.Name = "CloseButton"
CloseButton.Size = UDim2.new(0, 30, 0, 30)
CloseButton.Position = UDim2.new(1, -35, 0, 5)
CloseButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
CloseButton.Text = "X"
CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseButton.TextScaled = true
CloseButton.Font = Enum.Font.GothamBold
CloseButton.Parent = MainFrame

-- Анимация кнопок
local function animateButton(button)
    local originalSize = button.Size
    local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    
    local mouseEnter = button.MouseEnter:Connect(function()
        local tween = TweenService:Create(button, tweenInfo, {Size = originalSize + UDim2.new(0, 10, 0, 10)})
        tween:Play()
    end)
    
    local mouseLeave = button.MouseLeave:Connect(function()
        local tween = TweenService:Create(button, tweenInfo, {Size = originalSize})
        tween:Play()
    end)
end

animateButton(FlyButton)
animateButton(CloseButton)

-- Функция Fly Hack
local function toggleFly()
    Flying = not Flying
    
    if Flying then
        FlyButton.Text = "FLY HACK: ON"
        FlyButton.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
        
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
        
        -- Анимация полета
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
        FlyButton.Text = "FLY HACK: OFF"
        FlyButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
        
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
FlyButton.MouseButton1Click:Connect(toggleFly)

CloseButton.MouseButton1Click:Connect(function()
    local tween = TweenService:Create(MainFrame, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
        Size = UDim2.new(0, 0, 0, 0)
    })
    tween:Play()
    tween.Completed:Wait()
    ScreenGui:Destroy()
end)

-- Горячие клавиши
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.KeyCode == Enum.KeyCode.F then
        toggleFly()
    elseif input.KeyCode == Enum.KeyCode.Equals then
        FlySpeed = FlySpeed + 10
        SpeedSlider.Text = "Скорость полета: " .. FlySpeed
    elseif input.KeyCode == Enum.KeyCode.Minus then
        FlySpeed = math.max(10, FlySpeed - 10)
        SpeedSlider.Text = "Скорость полета: " .. FlySpeed
    end
end)

-- Анимация свечения
coroutine.wrap(function()
    while ScreenGui.Parent do
        for i = 1, 10 do
            if Glow then
                Glow.Transparency = 0.3 + (i * 0.07)
                wait(0.1)
            end
        end
        for i = 1, 10 do
            if Glow then
                Glow.Transparency = 1 - (i * 0.07)
                wait(0.1)
            end
        end
    end
end)()

warn("[⚡] RAGE MOD Fly Hack загружен!")
warn("Горячие клавиши:")
warn("F - Вкл/Выкл Fly Hack")
warn("+ - Увеличить скорость")
warn("- - Уменьшить скорость")
