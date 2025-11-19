-- Ключ-система
local Keys = {
    ["RAGE-7X9F-2K8M-4P6Q"] = true,
    ["RAGE-3B5D-8H2J-9N1M"] = true,
    ["RAGE-6C4X-7V3Z-1L9K"] = true,
    ["RAGE-8Q2W-5E7R-3T6Y"] = true
}

local AdminPassword = "svaston231211"

-- Создаем экран ввода ключа
local KeyGUI = Instance.new("ScreenGui")
KeyGUI.Name = "KeyAuth"
KeyGUI.Parent = game.CoreGui

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 400, 0, 250)
MainFrame.Position = UDim2.new(0.5, -200, 0.5, -125)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
MainFrame.BorderSizePixel = 0
MainFrame.Parent = KeyGUI

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 8)
UICorner.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 50)
Title.Position = UDim2.new(0, 0, 0, 0)
Title.BackgroundColor3 = Color3.fromRGB(30, 30, 38)
Title.Text = "ExpensiveMods - Key Access"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 16
Title.Font = Enum.Font.GothamBold
Title.Parent = MainFrame

local KeyBox = Instance.new("TextBox")
KeyBox.Size = UDim2.new(0.8, 0, 0, 40)
KeyBox.Position = UDim2.new(0.1, 0, 0.3, 0)
KeyBox.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
KeyBox.PlaceholderText = "Enter key or admin password..."
KeyBox.Text = ""
KeyBox.TextColor3 = Color3.fromRGB(255, 255, 255)
KeyBox.TextSize = 14
KeyBox.Parent = MainFrame

local KeyBoxCorner = Instance.new("UICorner")
KeyBoxCorner.CornerRadius = UDim.new(0, 6)
KeyBoxCorner.Parent = KeyBox

local SubmitBtn = Instance.new("TextButton")
SubmitBtn.Size = UDim2.new(0.6, 0, 0, 40)
SubmitBtn.Position = UDim2.new(0.2, 0, 0.5, 0)
SubmitBtn.BackgroundColor3 = Color3.fromRGB(70, 130, 255)
SubmitBtn.Text = "SUBMIT"
SubmitBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
SubmitBtn.TextSize = 16
SubmitBtn.Font = Enum.Font.GothamBold
SubmitBtn.Parent = MainFrame

local SubmitCorner = Instance.new("UICorner")
SubmitCorner.CornerRadius = UDim.new(0, 6)
SubmitCorner.Parent = SubmitBtn

local Status = Instance.new("TextLabel")
Status.Size = UDim2.new(0.8, 0, 0, 30)
Status.Position = UDim2.new(0.1, 0, 0.75, 0)
Status.BackgroundTransparency = 1
Status.Text = "Enter valid key to continue"
Status.TextColor3 = Color3.fromRGB(255, 255, 255)
Status.TextSize = 12
Status.Parent = MainFrame

local KeyList = Instance.new("TextLabel")
KeyList.Size = UDim2.new(0.8, 0, 0, 40)
KeyList.Position = UDim2.new(0.1, 0, 0.85, 0)
KeyList.BackgroundTransparency = 1
KeyList.Text = "Keys: RAGE-7X9F-2K8M-4P6Q, RAGE-3B5D-8H2J-9N1M"
KeyList.TextColor3 = Color3.fromRGB(200, 200, 200)
KeyList.TextSize = 10
KeyList.Parent = MainFrame

local function CreateMenuIcon()
    -- Создаем круглый значок для открытия меню
    local MenuIconGUI = Instance.new("ScreenGui")
    MenuIconGUI.Name = "MenuIconGUI"
    MenuIconGUI.Parent = game.CoreGui
    MenuIconGUI.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    local IconButton = Instance.new("TextButton")
    IconButton.Name = "MenuIcon"
    IconButton.Size = UDim2.new(0, 60, 0, 60)
    IconButton.Position = UDim2.new(0, 20, 0, 20)
    IconButton.BackgroundColor3 = Color3.fromRGB(70, 130, 255)
    IconButton.BackgroundTransparency = 0.2
    IconButton.Text = "EM"
    IconButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    IconButton.TextSize = 14
    IconButton.Font = Enum.Font.GothamBold
    IconButton.Parent = MenuIconGUI

    local IconCorner = Instance.new("UICorner")
    IconCorner.CornerRadius = UDim.new(1, 0)
    IconCorner.Parent = IconButton

    -- Функция перемещения значка
    local dragging = false
    local dragStart = nil
    local startPos = nil

    IconButton.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = IconButton.Position
        end
    end)

    IconButton.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)

    game:GetService("UserInputService").InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            IconButton.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)

    return IconButton, MenuIconGUI
end

local function LoadMainScript()
    KeyGUI:Destroy()
    
    -- Создаем значок меню
    local MenuIcon, MenuIconGUI = CreateMenuIcon()
    
    -- ОСНОВНОЙ КОД ЧИТА
    local UserInputService = game:GetService("UserInputService")
    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local Workspace = game:GetService("Workspace")

    local LocalPlayer = Players.LocalPlayer
    local mouse = LocalPlayer:GetMouse()

    -- Создание главного GUI (изначально скрыто)
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "ExpensiveModsGUI"
    ScreenGui.Parent = game.CoreGui
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    -- Главный фрейм
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = UDim2.new(0, 500, 0, 450)
    MainFrame.Position = UDim2.new(0.5, -250, 0.5, -225)
    MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    MainFrame.BackgroundTransparency = 0.2
    MainFrame.BorderSizePixel = 0
    MainFrame.ClipsDescendants = true
    MainFrame.Visible = false  -- Скрыто до нажатия на значок
    MainFrame.Parent = ScreenGui

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

    -- Контейнер для вкладок
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
    local Tabs = {"Combat", "Movement", "Visuals", "Misc"}
    local CurrentTab = "Combat"
    local Elements = {}

    -- Создание вкладок
    for i, tabName in pairs(Tabs) do
        local Button = Instance.new("TextButton")
        Button.Name = tabName .. "Button"
        Button.Size = UDim2.new(1, -10, 0, 35)
        Button.Position = UDim2.new(0, 5, 0, 5 + ((i - 1) * 40))
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
            for _, element in pairs(Elements) do
                element.Frame.Visible = element.Tab == tabName
            end
            for _, btn in pairs(TabButtons:GetChildren()) do
                if btn:IsA("TextButton") then
                    btn.BackgroundColor3 = btn.Name == tabName .. "Button" and Color3.fromRGB(70, 130, 255) or Color3.fromRGB(40, 40, 50)
                end
            end
        end)
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

    -- Переменные для функций
    local elementCounters = {}
    _G.AimbotEnabled = false
    _G.AimbotFOV = 100
    _G.ESPEnabled = false
    _G.FlyEnabled = false
    _G.SpeedEnabled = false
    _G.NoclipEnabled = false

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
        
        local SliderFill = Instance.new("Frame")
        SliderFill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
        SliderFill.Position = UDim2.new(0, 0, 0, 0)
        SliderFill.BackgroundColor3 = Color3.fromRGB(70, 130, 255)
        SliderFill.BorderSizePixel = 0
        SliderFill.Parent = SliderBar
        
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

    -- FOV Circle
    local FOVCircle = Instance.new("Frame")
    FOVCircle.Name = "FOVCircle"
    FOVCircle.Size = UDim2.new(0, _G.AimbotFOV * 2, 0, _G.AimbotFOV * 2)
    FOVCircle.Position = UDim2.new(0.5, -_G.AimbotFOV, 0.5, -_G.AimbotFOV)
    FOVCircle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    FOVCircle.BackgroundTransparency = 0.8
    FOVCircle.BorderSizePixel = 0
    FOVCircle.Visible = false
    FOVCircle.ZIndex = 5
    FOVCircle.Parent = ScreenGui

    local FOVCorner = Instance.new("UICorner")
    FOVCorner.CornerRadius = UDim.new(1, 0)
    FOVCorner.Parent = FOVCircle

    local function UpdateFOVCircle()
        FOVCircle.Size = UDim2.new(0, _G.AimbotFOV * 2, 0, _G.AimbotFOV * 2)
        FOVCircle.Position = UDim2.new(0.5, -_G.AimbotFOV, 0.5, -_G.AimbotFOV)
    end

    -- ИСПРАВЛЕННЫЙ АИМБОТ С FOV
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
                        local character = player.Character
                        local screenPoint = Workspace.CurrentCamera:WorldToViewportPoint(character.HumanoidRootPart.Position)
                        
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
                    local targetPos = closestPlayer.Character.HumanoidRootPart.Position
                    local screenPoint = Workspace.CurrentCamera:WorldToViewportPoint(targetPos)
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

    -- ИСПРАВЛЕННЫЙ ФЛАЙХАК
    local function FlyFunction(enabled)
        _G.FlyEnabled = enabled
        if enabled then
            _G.FlyConnection = RunService.Heartbeat:Connect(function()
                if not _G.FlyEnabled or not LocalPlayer.Character then return end
                
                local humanoidRootPart = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                if not humanoidRootPart then return end
                
                -- Создаем BodyVelocity если его нет
                local bodyVelocity = humanoidRootPart:FindFirstChild("FlyBodyVelocity")
                if not bodyVelocity then
                    bodyVelocity = Instance.new("BodyVelocity")
                    bodyVelocity.Name = "FlyBodyVelocity"
                    bodyVelocity.Velocity = Vector3.new(0, 0, 0)
                    bodyVelocity.MaxForce = Vector3.new(40000, 40000, 40000)
                    bodyVelocity.Parent = humanoidRootPart
                end
                
                -- Управление полетом
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
            -- Удаляем BodyVelocity при отключении
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                local bodyVelocity = LocalPlayer.Character.HumanoidRootPart:FindFirstChild("FlyBodyVelocity")
                if bodyVelocity then
                    bodyVelocity:Destroy()
                end
            end
        end
    end

    -- РАБОЧИЙ ESP
    local ESPObjects = {}
    local function ESPFunction(enabled)
        _G.ESPEnabled = enabled
        
        if enabled then
            _G.ESPConnection = RunService.RenderStepped:Connect(function()
                if not _G.ESPEnabled then return end
                
                for _, player in pairs(Players:GetPlayers()) do
                    if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                        local character = player.Character
                        local humanoidRootPart = character.HumanoidRootPart
                        local screenPoint = Workspace.CurrentCamera:WorldToViewportPoint(humanoidRootPart.Position)
                        
                        if screenPoint.Z > 0 then
                            if not ESPObjects[player] then
                                -- Создаем Highlight для игрока
                                ESPObjects[player] = Instance.new("Highlight")
                                ESPObjects[player].Name = "ESP_" .. player.Name
                                ESPObjects[player].FillColor = Color3.fromRGB(255, 0, 0)
                                ESPObjects[player].OutlineColor = Color3.fromRGB(255, 255, 255)
                                ESPObjects[player].FillTransparency = 0.5
                                ESPObjects[player].OutlineTransparency = 0
                                ESPObjects[player].DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                                ESPObjects[player].Parent = character
                            end
                            ESPObjects[player].Enabled = true
                        else
                            if ESPObjects[player] then
                                ESPObjects[player].Enabled = false
                            end
                        end
                    else
                        -- Удаляем ESP если игрок вышел или умер
                        if ESPObjects[player] then
                            ESPObjects[player]:Destroy()
                            ESPObjects[player] = nil
                        end
                    end
                end
            end)
        else
            -- Отключаем ESP
            if _G.ESPConnection then
                _G.ESPConnection:Disconnect()
            end
            -- Удаляем все ESP объекты
            for player, highlight in pairs(ESPObjects) do
                if highlight then
                    highlight:Destroy()
                end
            end
            ESPObjects = {}
        end
    end

    -- РАБОЧИЙ НОКЛИП
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

    -- Остальные функции
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
                        local messages = {
                            "тэгэ expensivemods чит",
                            "т3г3 expensivemods читаем"
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

    -- Создание секций
    local CombatSection = CreateSection("Combat", "Aimbot", 150)
    CreateToggle(CombatSection, "Enable Aimbot", false, AimbotFunction)
    CreateSlider(CombatSection, "Aimbot FOV", 10, 300, 100, function(value)
        _G.AimbotFOV = value
        UpdateFOVCircle()
    end)

    local MovementSection = CreateSection("Movement", "Movement Hacks", 200)
    CreateToggle(MovementSection, "Fly Hack", false, FlyFunction)
    CreateToggle(MovementSection, "Speed Hack", false, SpeedFunction)
    CreateToggle(MovementSection, "Noclip", false, NoclipFunction)

    local VisualsSection = CreateSection("Visuals", "ESP", 120)
    CreateToggle(VisualsSection, "Enable ESP", false, ESPFunction)

    local MiscSection = CreateSection("Misc", "Other", 120)
    CreateToggle(MiscSection, "Enable Spammer", true, function() end)

    -- Запуск спаммера
    StartSpammer()

    -- Функция перемещения GUI
    local draggingGUI = false
    local dragStartGUI = nil
    local startPosGUI = nil

    Header.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            draggingGUI = true
            dragStartGUI = input.Position
            startPosGUI = MainFrame.Position
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if draggingGUI and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStartGUI
            MainFrame.Position = UDim2.new(startPosGUI.X.Scale, startPosGUI.X.Offset + delta.X, startPosGUI.Y.Scale, startPosGUI.Y.Offset + delta.Y)
        end
    end)

    Header.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            draggingGUI = false
        end
    end)

    -- Закрытие GUI
    CloseButton.MouseButton1Click:Connect(function()
        MainFrame.Visible = false
    end)

    -- Открытие меню по нажатию на значок
    MenuIcon.MouseButton1Click:Connect(function()
        MainFrame.Visible = not MainFrame.Visible
    end)

    -- Открытие/закрытие по Insert
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        if input.KeyCode == Enum.KeyCode.Insert then
            MainFrame.Visible = not MainFrame.Visible
        end
    end)

    print("ExpensiveMods successfully loaded! Use the EM icon to open menu.")
end

-- Обработка ввода ключа
SubmitBtn.MouseButton1Click:Connect(function()
    local input = KeyBox.Text:gsub("%s+", "")
    
    if input == AdminPassword then
        Status.Text = "Admin access granted!"
        Status.TextColor3 = Color3.fromRGB(0, 255, 0)
        wait(1)
        LoadMainScript()
    elseif Keys[input] then
        Status.Text = "Access granted! Loading..."
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
