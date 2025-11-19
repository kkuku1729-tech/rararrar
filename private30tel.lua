-- Простая ключ-система
local Keys = {
    ["RAGE-7X9F-2K8M-4P6Q"] = true,
    ["RAGE-3B5D-8H2J-9N1M"] = true
}

local AdminPassword = "svaston231211"

-- Экран ввода ключа
local KeyGUI = Instance.new("ScreenGui")
KeyGUI.Parent = game.CoreGui

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 350, 0, 200)
MainFrame.Position = UDim2.new(0.5, -175, 0.5, -100)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
MainFrame.Parent = KeyGUI

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 40)
Title.Position = UDim2.new(0, 0, 0, 0)
Title.BackgroundColor3 = Color3.fromRGB(30, 30, 38)
Title.Text = "ExpensiveMods - Key Access"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 16
Title.Font = Enum.Font.GothamBold
Title.Parent = MainFrame

local KeyBox = Instance.new("TextBox")
KeyBox.Size = UDim2.new(0.8, 0, 0, 30)
KeyBox.Position = UDim2.new(0.1, 0, 0.3, 0)
KeyBox.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
KeyBox.PlaceholderText = "Enter key..."
KeyBox.Text = ""
KeyBox.TextColor3 = Color3.fromRGB(255, 255, 255)
KeyBox.TextSize = 14
KeyBox.Parent = MainFrame

local SubmitBtn = Instance.new("TextButton")
SubmitBtn.Size = UDim2.new(0.6, 0, 0, 30)
SubmitBtn.Position = UDim2.new(0.2, 0, 0.5, 0)
SubmitBtn.BackgroundColor3 = Color3.fromRGB(70, 130, 255)
SubmitBtn.Text = "SUBMIT"
SubmitBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
SubmitBtn.TextSize = 14
SubmitBtn.Parent = MainFrame

local Status = Instance.new("TextLabel")
Status.Size = UDim2.new(0.8, 0, 0, 30)
Status.Position = UDim2.new(0.1, 0, 0.7, 0)
Status.BackgroundTransparency = 1
Status.Text = "Enter key: @expensivemods тг"
Status.TextColor3 = Color3.fromRGB(255, 255, 255)
Status.TextSize = 12
Status.Parent = MainFrame

local function LoadMainScript()
    KeyGUI:Destroy()
    
    -- Создаем значок меню
    local MenuIcon = Instance.new("TextButton")
    MenuIcon.Size = UDim2.new(0, 50, 0, 50)
    MenuIcon.Position = UDim2.new(0, 20, 0, 20)
    MenuIcon.BackgroundColor3 = Color3.fromRGB(70, 130, 255)
    MenuIcon.Text = "EM"
    MenuIcon.TextColor3 = Color3.fromRGB(255, 255, 255)
    MenuIcon.TextSize = 14
    MenuIcon.Font = Enum.Font.GothamBold
    MenuIcon.Parent = game.CoreGui

    -- Основные сервисы
    local UserInputService = game:GetService("UserInputService")
    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local Workspace = game:GetService("Workspace")

    local LocalPlayer = Players.LocalPlayer
    local mouse = LocalPlayer:GetMouse()

    -- Создание главного GUI
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Parent = game.CoreGui

    local MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0, 450, 0, 400)
    MainFrame.Position = UDim2.new(0.5, -225, 0.5, -200)
    MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    MainFrame.Visible = false
    MainFrame.Parent = ScreenGui

    local Header = Instance.new("Frame")
    Header.Size = UDim2.new(1, 0, 0, 30)
    Header.Position = UDim2.new(0, 0, 0, 0)
    Header.BackgroundColor3 = Color3.fromRGB(30, 30, 38)
    Header.Parent = MainFrame

    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, -40, 1, 0)
    Title.Position = UDim2.new(0, 10, 0, 0)
    Title.BackgroundTransparency = 1
    Title.Text = "ExpensiveMods"
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.TextSize = 14
    Title.Font = Enum.Font.GothamBold
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Parent = Header

    local CloseButton = Instance.new("TextButton")
    CloseButton.Size = UDim2.new(0, 25, 0, 25)
    CloseButton.Position = UDim2.new(1, -30, 0, 2)
    CloseButton.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
    CloseButton.Text = "X"
    CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    CloseButton.TextSize = 12
    CloseButton.Parent = Header

    -- Вкладки
    local TabButtons = Instance.new("Frame")
    TabButtons.Size = UDim2.new(0, 100, 1, -30)
    TabButtons.Position = UDim2.new(0, 0, 0, 30)
    TabButtons.BackgroundColor3 = Color3.fromRGB(25, 25, 32)
    TabButtons.Parent = MainFrame

    local ContentFrame = Instance.new("Frame")
    ContentFrame.Size = UDim2.new(1, -100, 1, -30)
    ContentFrame.Position = UDim2.new(0, 100, 0, 30)
    ContentFrame.BackgroundTransparency = 1
    ContentFrame.Parent = MainFrame

    -- Создание вкладок
    local Tabs = {"Combat", "Movement", "Visuals"}
    local CurrentTab = "Combat"

    for i, tabName in pairs(Tabs) do
        local Button = Instance.new("TextButton")
        Button.Size = UDim2.new(1, -10, 0, 30)
        Button.Position = UDim2.new(0, 5, 0, 5 + ((i - 1) * 35))
        Button.BackgroundColor3 = tabName == CurrentTab and Color3.fromRGB(70, 130, 255) or Color3.fromRGB(40, 40, 50)
        Button.Text = tabName
        Button.TextColor3 = Color3.fromRGB(255, 255, 255)
        Button.TextSize = 12
        Button.Parent = TabButtons
        
        Button.MouseButton1Click:Connect(function()
            CurrentTab = tabName
            -- Обновить видимость контента
            for _, child in pairs(ContentFrame:GetChildren()) do
                child.Visible = child.Name == tabName
            end
            -- Обновить кнопки
            for _, btn in pairs(TabButtons:GetChildren()) do
                if btn:IsA("TextButton") then
                    btn.BackgroundColor3 = btn.Text == tabName and Color3.fromRGB(70, 130, 255) or Color3.fromRGB(40, 40, 50)
                end
            end
        end)
    end

    -- Функция создания секции
    local function CreateSection(tabName, sectionName)
        local SectionFrame = Instance.new("Frame")
        SectionFrame.Name = tabName
        SectionFrame.Size = UDim2.new(1, 0, 1, 0)
        SectionFrame.BackgroundTransparency = 1
        SectionFrame.Visible = tabName == CurrentTab
        SectionFrame.Parent = ContentFrame
        
        local SectionTitle = Instance.new("TextLabel")
        SectionTitle.Size = UDim2.new(1, 0, 0, 25)
        SectionTitle.Position = UDim2.new(0, 10, 0, 5)
        SectionTitle.BackgroundTransparency = 1
        SectionTitle.Text = sectionName
        SectionTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
        SectionTitle.TextSize = 13
        SectionTitle.Font = Enum.Font.GothamBold
        SectionTitle.TextXAlignment = Enum.TextXAlignment.Left
        SectionTitle.Parent = SectionFrame
        
        return SectionFrame
    end

    -- Переменные для функций
    _G.AimbotEnabled = false
    _G.AimbotFOV = 100
    _G.ESPEnabled = false
    _G.FlyEnabled = false
    _G.SpeedEnabled = false
    _G.NoclipEnabled = false

    -- Функция создания переключателя
    local function CreateToggle(section, text, default, callback)
        local yPos = #section:GetChildren() * 30 + 35
        
        local ToggleButton = Instance.new("TextButton")
        ToggleButton.Size = UDim2.new(1, -20, 0, 25)
        ToggleButton.Position = UDim2.new(0, 10, 0, yPos)
        ToggleButton.BackgroundColor3 = default and Color3.fromRGB(70, 130, 255) or Color3.fromRGB(80, 80, 80)
        ToggleButton.Text = text
        ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        ToggleButton.TextSize = 12
        ToggleButton.Parent = section
        
        ToggleButton.MouseButton1Click:Connect(function()
            default = not default
            ToggleButton.BackgroundColor3 = default and Color3.fromRGB(70, 130, 255) or Color3.fromRGB(80, 80, 80)
            if callback then
                callback(default)
            end
        end)
    end

    -- Функция создания слайдера
    local function CreateSlider(section, text, min, max, default, callback)
        local yPos = #section:GetChildren() * 30 + 35
        
        local SliderLabel = Instance.new("TextLabel")
        SliderLabel.Size = UDim2.new(1, -20, 0, 20)
        SliderLabel.Position = UDim2.new(0, 10, 0, yPos)
        SliderLabel.BackgroundTransparency = 1
        SliderLabel.Text = text .. ": " .. default
        SliderLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        SliderLabel.TextSize = 12
        SliderLabel.TextXAlignment = Enum.TextXAlignment.Left
        SliderLabel.Parent = section
        
        local dragging = false
        
        local function updateSlider(value)
            SliderLabel.Text = text .. ": " .. math.floor(value)
            if callback then
                callback(value)
            end
        end
        
        SliderLabel.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = true
            end
        end)
        
        SliderLabel.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = false
            end
        end)
        
        UserInputService.InputChanged:Connect(function(input)
            if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                local relativeX = (input.Position.X - SliderLabel.AbsolutePosition.X) / SliderLabel.AbsoluteSize.X
                local value = min + (relativeX * (max - min))
                value = math.clamp(math.floor(value), min, max)
                updateSlider(value)
            end
        end)
    end

    -- FOV Circle
    local FOVCircle = Instance.new("Frame")
    FOVCircle.Size = UDim2.new(0, _G.AimbotFOV * 2, 0, _G.AimbotFOV * 2)
    FOVCircle.Position = UDim2.new(0.5, -_G.AimbotFOV, 0.5, -_G.AimbotFOV)
    FOVCircle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    FOVCircle.BackgroundTransparency = 0.8
    FOVCircle.Visible = false
    FOVCircle.Parent = ScreenGui

    local function UpdateFOVCircle()
        FOVCircle.Size = UDim2.new(0, _G.AimbotFOV * 2, 0, _G.AimbotFOV * 2)
        FOVCircle.Position = UDim2.new(0.5, -_G.AimbotFOV, 0.5, -_G.AimbotFOV)
    end

    -- АИМБОТ С FOV
    local function AimbotFunction(enabled)
        _G.AimbotEnabled = enabled
        FOVCircle.Visible = enabled
        
        if enabled then
            _G.AimbotConnection = RunService.RenderStepped:Connect(function()
                if not _G.AimbotEnabled then return end
                
                local closestPlayer = nil
                local shortestDistance = _G.AimbotFOV
                local screenCenter = Vector2.new(Workspace.CurrentCamera.ViewportSize.X / 2, Workspace.CurrentCamera.ViewportSize.Y / 2)
                
                for _, player in pairs(Players:GetPlayers()) do
                    if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                        local screenPoint = Workspace.CurrentCamera:WorldToViewportPoint(player.Character.HumanoidRootPart.Position)
                        if screenPoint.Z > 0 then
                            local distance = (Vector2.new(screenPoint.X, screenPoint.Y) - screenCenter).Magnitude
                            if distance < shortestDistance then
                                closestPlayer = player
                                shortestDistance = distance
                            end
                        end
                    end
                end
                
                if closestPlayer and closestPlayer.Character then
                    local screenPoint = Workspace.CurrentCamera:WorldToViewportPoint(closestPlayer.Character.HumanoidRootPart.Position)
                    mousemoverel((screenPoint.X - mouse.X) * 0.6, (screenPoint.Y - mouse.Y) * 0.6)
                end
            end)
        else
            if _G.AimbotConnection then
                _G.AimbotConnection:Disconnect()
            end
            FOVCircle.Visible = false
        end
    end

    -- ФЛАЙХАК
    local function FlyFunction(enabled)
        _G.FlyEnabled = enabled
        if enabled then
            _G.FlyConnection = RunService.Heartbeat:Connect(function()
                if not _G.FlyEnabled or not LocalPlayer.Character then return end
                local root = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                if not root then return end
                
                local bodyVelocity = root:FindFirstChild("FlyBodyVelocity")
                if not bodyVelocity then
                    bodyVelocity = Instance.new("BodyVelocity")
                    bodyVelocity.Name = "FlyBodyVelocity"
                    bodyVelocity.MaxForce = Vector3.new(40000, 40000, 40000)
                    bodyVelocity.Parent = root
                end
                
                local newVelocity = Vector3.new(0, 0, 0)
                if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                    newVelocity = newVelocity + Workspace.CurrentCamera.CFrame.LookVector * 50
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                    newVelocity = newVelocity - Workspace.CurrentCamera.CFrame.LookVector * 50
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                    newVelocity = newVelocity - Workspace.CurrentCamera.CFrame.RightVector * 50
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                    newVelocity = newVelocity + Workspace.CurrentCamera.CFrame.RightVector * 50
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                    newVelocity = newVelocity + Vector3.new(0, 50, 0)
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
                    newVelocity = newVelocity - Vector3.new(0, 50, 0)
                end
                
                bodyVelocity.Velocity = newVelocity
            end)
        else
            if _G.FlyConnection then
                _G.FlyConnection:Disconnect()
            end
            if LocalPlayer.Character then
                local bodyVelocity = LocalPlayer.Character:FindFirstChild("FlyBodyVelocity")
                if bodyVelocity then
                    bodyVelocity:Destroy()
                end
            end
        end
    end

    -- ESP
    local ESPObjects = {}
    local function ESPFunction(enabled)
        _G.ESPEnabled = enabled
        if enabled then
            _G.ESPConnection = RunService.RenderStepped:Connect(function()
                if not _G.ESPEnabled then return end
                for _, player in pairs(Players:GetPlayers()) do
                    if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                        if not ESPObjects[player] then
                            ESPObjects[player] = Instance.new("Highlight")
                            ESPObjects[player].FillColor = Color3.fromRGB(255, 0, 0)
                            ESPObjects[player].OutlineColor = Color3.fromRGB(255, 255, 255)
                            ESPObjects[player].Parent = player.Character
                        end
                        ESPObjects[player].Enabled = true
                    else
                        if ESPObjects[player] then
                            ESPObjects[player].Enabled = false
                        end
                    end
                end
            end)
        else
            if _G.ESPConnection then
                _G.ESPConnection:Disconnect()
            end
            for _, highlight in pairs(ESPObjects) do
                highlight:Destroy()
            end
            ESPObjects = {}
        end
    end

    -- НОКЛИП
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

    -- СПИДХАК
    local function SpeedFunction(enabled)
        _G.SpeedEnabled = enabled
        if enabled then
            _G.SpeedConnection = RunService.Heartbeat:Connect(function()
                if not _G.SpeedEnabled or not LocalPlayer.Character then return end
                local humanoid = LocalPlayer.Character:FindFirstChild("Humanoid")
                if humanoid then
                    humanoid.WalkSpeed = 50
                end
            end)
        else
            if _G.SpeedConnection then
                _G.SpeedConnection:Disconnect()
            end
            if LocalPlayer.Character then
                local humanoid = LocalPlayer.Character:FindFirstChild("Humanoid")
                if humanoid then
                    humanoid.WalkSpeed = 16
                end
            end
        end
    end

    -- СПАММЕР
    local function StartSpammer()
        spawn(function()
            while true do
                wait(35)
                local chatEvent = game:GetService("ReplicatedStorage"):FindFirstChild("DefaultChatSystemChatEvents")
                if chatEvent then
                    local sayMessage = chatEvent:FindFirstChild("SayMessageRequest")
                    if sayMessage then
                        local messages = {"тэгэ expensivemods чит", "т3г3 expensivemods читаем"}
                        local randomMsg = messages[math.random(1, #messages)]
                        pcall(function()
                            sayMessage:FireServer(randomMsg, "All")
                        end)
                    end
                end
            end
        end)
    end

    -- Создание секций
    local CombatSection = CreateSection("Combat", "Aimbot")
    CreateToggle(CombatSection, "Enable Aimbot", false, AimbotFunction)
    CreateSlider(CombatSection, "Aimbot FOV", 10, 300, 100, function(value)
        _G.AimbotFOV = value
        UpdateFOVCircle()
    end)

    local MovementSection = CreateSection("Movement", "Movement Hacks")
    CreateToggle(MovementSection, "Fly Hack", false, FlyFunction)
    CreateToggle(MovementSection, "Speed Hack", false, SpeedFunction)
    CreateToggle(MovementSection, "Noclip", false, NoclipFunction)

    local VisualsSection = CreateSection("Visuals", "ESP")
    CreateToggle(VisualsSection, "Enable ESP", false, ESPFunction)

    -- Запуск спаммера
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
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)

    Header.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)

    -- Функция перемещения значка
    local iconDragging = false
    local iconDragStart = nil
    local iconStartPos = nil

    MenuIcon.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            iconDragging = true
            iconDragStart = input.Position
            iconStartPos = MenuIcon.Position
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if iconDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - iconDragStart
            MenuIcon.Position = UDim2.new(iconStartPos.X.Scale, iconStartPos.X.Offset + delta.X, iconStartPos.Y.Scale, iconStartPos.Y.Offset + delta.Y)
        end
    end)

    MenuIcon.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            iconDragging = false
        end
    end)

    -- Открытие/закрытие меню
    MenuIcon.MouseButton1Click:Connect(function()
        MainFrame.Visible = not MainFrame.Visible
    end)

    CloseButton.MouseButton1Click:Connect(function()
        MainFrame.Visible = false
    end)

    -- Открытие по Insert
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        if input.KeyCode == Enum.KeyCode.Insert then
            MainFrame.Visible = not MainFrame.Visible
        end
    end)

    print("ExpensiveMods loaded! Use EM icon to open menu.")
end

-- Проверка ключа
SubmitBtn.MouseButton1Click:Connect(function()
    local input = KeyBox.Text:gsub("%s+", "")
    
    if input == AdminPassword or Keys[input] then
        Status.Text = "Access granted!"
        Status.TextColor3 = Color3.fromRGB(0, 255, 0)
        wait(1)
        LoadMainScript()
    else
        Status.Text = "Invalid key!"
        Status.TextColor3 = Color3.fromRGB(255, 50, 50)
    end
end)

KeyBox.FocusLost:Connect(function(enterPressed)
    if enterPressed then
        SubmitBtn.MouseButton1Click:Connect(function() end)
    end
end)
