--[[
    Tridient Survival - Rage Hub v1.0.03
    Исполнитель: требуется любой экзекутор с поддержкой full Lua API
    Для образовательных целей
]]

-- Сервисы
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")
local Camera = Workspace.CurrentCamera

-- Локальный игрок
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "RageHub"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = game:GetService("CoreGui")

-- Переменные
local MenuVisible = true
local Config = {
    -- Aimbot
    AimbotEnabled = true,
    HitPart = "Head",
    FOVRadius = 150,
    Smoothness = 8,
    
    -- Silent Aim
    SilentAimEnabled = false,
    SilentHitChance = 100,
    
    -- Triggerbot
    TriggerbotEnabled = false,
    TriggerbotDelay = 50,
    
    -- ESP
    ESPEnabled = true,
    BoxType = "2D Box",
    BoxColor = Color3.fromRGB(255, 255, 255),
    HealthBar = true,
    NameTags = true,
    Distance = true,
    MaxESPDistance = 1500,
    
    -- Chams
    ChamsEnabled = false,
    ChamColor = Color3.fromRGB(255, 68, 68),
    ChamMaterial = "Flat",
    
    -- Speed
    SpeedEnabled = true,
    SpeedMultiplier = 100,
    
    -- Fly
    FlyEnabled = false,
    FlySpeed = 50,
    FlyKey = "X",
    
    -- Noclip
    NoclipEnabled = false,
    NoclipKey = "V",
    
    -- Jump
    BunnyHopEnabled = true,
    JumpPower = 100,
    
    -- Anti-Aim
    AntiAimEnabled = false,
    Pitch = "None",
    Yaw = "Backward",
    SpinSpeed = 10,
    
    -- Fake Lag
    FakeLagEnabled = false,
    LagAmount = 6,
    
    -- Exploits
    InfiniteAmmo = true,
    NoRecoil = true,
    NoSpread = true,
    RapidFire = false,
    
    -- Keybinds
    MenuToggleKey = "Insert",
    PanicKey = "End",
    
    -- Fly/Noclip state
    IsFlying = false,
    IsNoclipping = false,
}

-- Сохранённые значения
local SavedSpeeds = {}
local ESPConnections = {}
local NoclipConnection = nil
local FlyConnection = nil
local AntiAimConnection = nil
local FakeLagConnection = nil
local TriggerbotConnection = nil
local AimbotConnection = nil

-- Создание меню
local function createMenu()
    -- Main container
    local MainContainer = Instance.new("Frame")
    MainContainer.Name = "MainContainer"
    MainContainer.Size = UDim2.new(0, 500, 0, 400)
    MainContainer.Position = UDim2.new(0.5, -250, 0.5, -200)
    MainContainer.BackgroundColor3 = Color3.fromRGB(44, 44, 44)
    MainContainer.BorderColor3 = Color3.fromRGB(255, 255, 255)
    MainContainer.BorderSizePixel = 2
    MainContainer.Parent = ScreenGui
    MainContainer.ClipsDescendants = true
    
    -- Glow effect
    local Glow = Instance.new("Frame")
    Glow.Name = "Glow"
    Glow.Size = UDim2.new(1, 0, 1, 0)
    Glow.Position = UDim2.new(0, 0, 0, 0)
    Glow.BackgroundTransparency = 1
    Glow.Parent = MainContainer
    
    -- Title bar
    local TitleBar = Instance.new("Frame")
    TitleBar.Name = "TitleBar"
    TitleBar.Size = UDim2.new(1, 0, 0, 40)
    TitleBar.BackgroundColor3 = Color3.fromRGB(37, 37, 37)
    TitleBar.BorderSizePixel = 0
    TitleBar.Parent = MainContainer
    
    local Title = Instance.new("TextLabel")
    Title.Name = "Title"
    Title.Size = UDim2.new(1, 0, 1, 0)
    Title.BackgroundTransparency = 1
    Title.Text = "TRIDIENT SURVIVAL"
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.Font = Enum.Font.SourceSansBold
    Title.TextSize = 20
    Title.Parent = TitleBar
    
    local Subtitle = Instance.new("TextLabel")
    Subtitle.Name = "Subtitle"
    Subtitle.Size = UDim2.new(1, 0, 0, 15)
    Subtitle.Position = UDim2.new(0, 0, 0, 40)
    Subtitle.BackgroundTransparency = 1
    Subtitle.Text = "v1.0.03 -- rage hub"
    Subtitle.TextColor3 = Color3.fromRGB(170, 170, 170)
    Subtitle.Font = Enum.Font.SourceSans
    Subtitle.TextSize = 11
    Subtitle.Parent = MainContainer
    
    -- Tab buttons container
    local TabContainer = Instance.new("Frame")
    TabContainer.Name = "TabContainer"
    TabContainer.Size = UDim2.new(1, 0, 0, 30)
    TabContainer.Position = UDim2.new(0, 0, 0, 55)
    TabContainer.BackgroundColor3 = Color3.fromRGB(37, 37, 37)
    TabContainer.BorderSizePixel = 0
    TabContainer.Parent = MainContainer
    
    local Tabs = {"Combat", "Visuals", "Movement", "Misc", "Config"}
    local TabButtons = {}
    
    for i, tabName in ipairs(Tabs) do
        local TabButton = Instance.new("TextButton")
        TabButton.Name = tabName
        TabButton.Size = UDim2.new(0.2, 0, 1, 0)
        TabButton.Position = UDim2.new((i-1)*0.2, 0, 0, 0)
        TabButton.BackgroundColor3 = Color3.fromRGB(37, 37, 37)
        TabButton.BorderSizePixel = 0
        TabButton.Text = tabName
        TabButton.TextColor3 = Color3.fromRGB(136, 136, 136)
        TabButton.Font = Enum.Font.SourceSansBold
        TabButton.TextSize = 13
        TabButton.Parent = TabContainer
        TabButtons[tabName] = TabButton
        
        if i == 1 then
            TabButton.TextColor3 = Color3.fromRGB(255, 255, 255)
            local underline = Instance.new("Frame")
            underline.Name = "Underline"
            underline.Size = UDim2.new(1, 0, 0, 2)
            underline.Position = UDim2.new(0, 0, 1, -2)
            underline.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            underline.BorderSizePixel = 0
            underline.Parent = TabButton
        end
    end
    
    -- Tab content container
    local ContentContainer = Instance.new("Frame")
    ContentContainer.Name = "ContentContainer"
    ContentContainer.Size = UDim2.new(1, -20, 1, -95)
    ContentContainer.Position = UDim2.new(0, 10, 0, 90)
    ContentContainer.BackgroundTransparency = 1
    ContentContainer.Parent = MainContainer
    
    -- Combat Tab Content
    local CombatTab = Instance.new("ScrollingFrame")
    CombatTab.Name = "CombatTab"
    CombatTab.Size = UDim2.new(1, 0, 1, 0)
    CombatTab.BackgroundTransparency = 1
    CombatTab.ScrollBarThickness = 4
    CombatTab.ScrollBarImageColor3 = Color3.fromRGB(255, 255, 255)
    CombatTab.CanvasSize = UDim2.new(0, 0, 0, 500)
    CombatTab.Visible = true
    CombatTab.Parent = ContentContainer
    
    local combatList = Instance.new("UIListLayout")
    combatList.SortOrder = Enum.SortOrder.LayoutOrder
    combatList.Padding = UDim.new(0, 4)
    combatList.Parent = CombatTab
    
    -- Функция для создания toggle
    local function createToggle(parent, text, enabled)
        local item = Instance.new("TextButton")
        item.Size = UDim2.new(1, 0, 0, 40)
        item.BackgroundColor3 = Color3.fromRGB(58, 58, 58)
        item.BorderColor3 = Color3.fromRGB(255, 255, 255)
        item.BorderSizePixel = 1
        item.Text = ""
        item.AutoButtonColor = false
        item.Parent = parent
        
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(0.7, 0, 1, 0)
        label.Position = UDim2.new(0, 10, 0, 0)
        label.BackgroundTransparency = 1
        label.Text = text
        label.TextColor3 = Color3.fromRGB(255, 255, 255)
        label.Font = Enum.Font.SourceSans
        label.TextSize = 14
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Parent = item
        
        local toggleFrame = Instance.new("Frame")
        toggleFrame.Name = "ToggleFrame"
        toggleFrame.Size = UDim2.new(0, 45, 0, 24)
        toggleFrame.Position = UDim2.new(1, -60, 0.5, -12)
        toggleFrame.BackgroundColor3 = enabled and Color3.fromRGB(138, 138, 138) or Color3.fromRGB(85, 85, 85)
        toggleFrame.BorderColor3 = Color3.fromRGB(255, 255, 255)
        toggleFrame.BorderSizePixel = 1
        toggleFrame.Parent = item
        
        local toggleDot = Instance.new("Frame")
        toggleDot.Name = "ToggleDot"
        toggleDot.Size = UDim2.new(0, 18, 0, 18)
        toggleDot.Position = enabled and UDim2.new(0, 23, 0.5, -9) or UDim2.new(0, 2, 0.5, -9)
        toggleDot.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        toggleDot.BorderSizePixel = 0
        toggleDot.Parent = toggleFrame
        
        item.MouseButton1Click:Connect(function()
            local isActive = toggleFrame.BackgroundColor3 == Color3.fromRGB(85, 85, 85)
            if isActive then
                toggleFrame.BackgroundColor3 = Color3.fromRGB(138, 138, 138)
                toggleDot:TweenPosition(UDim2.new(0, 23, 0.5, -9), "Out", "Quad", 0.2, true)
            else
                toggleFrame.BackgroundColor3 = Color3.fromRGB(85, 85, 85)
                toggleDot:TweenPosition(UDim2.new(0, 2, 0.5, -9), "Out", "Quad", 0.2, true)
            end
        end)
        
        return toggleFrame
    end
    
    -- Функция для создания слайдера
    local function createSlider(parent, text, min, max, default)
        local item = Instance.new("TextButton")
        item.Size = UDim2.new(1, 0, 0, 40)
        item.BackgroundColor3 = Color3.fromRGB(58, 58, 58)
        item.BorderColor3 = Color3.fromRGB(255, 255, 255)
        item.BorderSizePixel = 1
        item.Text = ""
        item.AutoButtonColor = false
        item.Parent = parent
        
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(0.5, 0, 1, 0)
        label.Position = UDim2.new(0, 10, 0, 0)
        label.BackgroundTransparency = 1
        label.Text = text
        label.TextColor3 = Color3.fromRGB(255, 255, 255)
        label.Font = Enum.Font.SourceSans
        label.TextSize = 14
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Parent = item
        
        local valueLabel = Instance.new("TextLabel")
        valueLabel.Name = "ValueLabel"
        valueLabel.Size = UDim2.new(0, 35, 1, 0)
        valueLabel.Position = UDim2.new(1, -40, 0, 0)
        valueLabel.BackgroundTransparency = 1
        valueLabel.Text = tostring(default)
        valueLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        valueLabel.Font = Enum.Font.SourceSans
        valueLabel.TextSize = 12
        valueLabel.Parent = item
        
        local sliderFrame = Instance.new("Frame")
        sliderFrame.Size = UDim2.new(0, 80, 0, 5)
        sliderFrame.Position = UDim2.new(1, -130, 0.5, -2)
        sliderFrame.BackgroundColor3 = Color3.fromRGB(85, 85, 85)
        sliderFrame.BorderColor3 = Color3.fromRGB(255, 255, 255)
        sliderFrame.BorderSizePixel = 1
        sliderFrame.Parent = item
        
        local sliderFill = Instance.new("Frame")
        sliderFill.Name = "SliderFill"
        sliderFill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
        sliderFill.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        sliderFill.BorderSizePixel = 0
        sliderFill.Parent = sliderFrame
        
        local sliderButton = Instance.new("TextButton")
        sliderButton.Size = UDim2.new(0, 16, 0, 16)
        sliderButton.Position = UDim2.new((default - min) / (max - min), -8, 0.5, -8)
        sliderButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        sliderButton.BorderSizePixel = 0
        sliderButton.Text = ""
        sliderButton.AutoButtonColor = false
        sliderButton.Parent = sliderFrame
        
        local dragging = false
        
        sliderButton.MouseButton1Down:Connect(function()
            dragging = true
        end)
        
        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = false
            end
        end)
        
        UserInputService.InputChanged:Connect(function(input)
            if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                local mousePos = UserInputService:GetMouseLocation()
                local sliderPos = sliderFrame.AbsolutePosition
                local sliderSize = sliderFrame.AbsoluteSize
                local percent = math.clamp((mousePos.X - sliderPos.X) / sliderSize.X, 0, 1)
                local value = math.floor(min + (max - min) * percent)
                
                sliderFill.Size = UDim2.new(percent, 0, 1, 0)
                sliderButton.Position = UDim2.new(percent, -8, 0.5, -8)
                valueLabel.Text = tostring(value)
            end
        end)
        
        return sliderFrame
    end
    
    -- Функция для создания категории
    local function createCategory(parent, text)
        local category = Instance.new("TextLabel")
        category.Size = UDim2.new(1, 0, 0, 20)
        category.BackgroundTransparency = 1
        category.Text = text
        category.TextColor3 = Color3.fromRGB(255, 255, 255)
        category.Font = Enum.Font.SourceSansBold
        category.TextSize = 13
        category.TextXAlignment = Enum.TextXAlignment.Left
        category.Parent = parent
        
        return category
    end
    
    -- Заполнение Combat вкладки
    createCategory(CombatTab, "AIMBOT")
    createToggle(CombatTab, "Enable", true)
    
    local hitPartDropdown = Instance.new("TextButton")
    hitPartDropdown.Size = UDim2.new(1, 0, 0, 40)
    hitPartDropdown.BackgroundColor3 = Color3.fromRGB(58, 58, 58)
    hitPartDropdown.BorderColor3 = Color3.fromRGB(255, 255, 255)
    hitPartDropdown.BorderSizePixel = 1
    hitPartDropdown.Text = ""
    hitPartDropdown.AutoButtonColor = false
    hitPartDropdown.Parent = CombatTab
    
    local hitPartLabel = Instance.new("TextLabel")
    hitPartLabel.Size = UDim2.new(0.5, 0, 1, 0)
    hitPartLabel.Position = UDim2.new(0, 10, 0, 0)
    hitPartLabel.BackgroundTransparency = 1
    hitPartLabel.Text = "Hit Part"
    hitPartLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    hitPartLabel.Font = Enum.Font.SourceSans
    hitPartLabel.TextSize = 14
    hitPartLabel.TextXAlignment = Enum.TextXAlignment.Left
    hitPartLabel.Parent = hitPartDropdown
    
    local hitPartValue = Instance.new("TextLabel")
    hitPartValue.Size = UDim2.new(0, 60, 1, 0)
    hitPartValue.Position = UDim2.new(1, -65, 0, 0)
    hitPartValue.BackgroundTransparency = 1
    hitPartValue.Text = "Head"
    hitPartValue.TextColor3 = Color3.fromRGB(255, 255, 255)
    hitPartValue.Font = Enum.Font.SourceSans
    hitPartValue.TextSize = 12
    hitPartValue.Parent = hitPartDropdown
    
    local hitParts = {"Head", "Torso", "Legs"}
    local hitPartIndex = 1
    hitPartDropdown.MouseButton1Click:Connect(function()
        hitPartIndex = hitPartIndex % 3 + 1
        hitPartValue.Text = hitParts[hitPartIndex]
    end)
    
    createSlider(CombatTab, "FOV Radius", 10, 500, 150)
    createSlider(CombatTab, "Smoothness", 1, 20, 8)
    
    createCategory(CombatTab, "SILENT AIM")
    createToggle(CombatTab, "Enable", false)
    createSlider(CombatTab, "Hit Chance", 10, 100, 100)
    
    createCategory(CombatTab, "TRIGGERBOT")
    createToggle(CombatTab, "Enable", false)
    createSlider(CombatTab, "Delay (ms)", 0, 500, 50)
    
    -- Заполнение других вкладок упрощённо
    local otherTabs = {"VisualsTab", "MovementTab", "MiscTab", "ConfigTab"}
    for _, tabName in ipairs(otherTabs) do
        local tab = Instance.new("ScrollingFrame")
        tab.Name = tabName
        tab.Size = UDim2.new(1, 0, 1, 0)
        tab.BackgroundTransparency = 1
        tab.ScrollBarThickness = 4
        tab.ScrollBarImageColor3 = Color3.fromRGB(255, 255, 255)
        tab.CanvasSize = UDim2.new(0, 0, 0, 500)
        tab.Visible = false
        tab.Parent = ContentContainer
        
        local list = Instance.new("UIListLayout")
        list.SortOrder = Enum.SortOrder.LayoutOrder
        list.Padding = UDim.new(0, 4)
        list.Parent = tab
    end
    
    -- Переключение вкладок
    for tabName, button in pairs(TabButtons) do
        button.MouseButton1Click:Connect(function()
            for _, btn in pairs(TabButtons) do
                btn.TextColor3 = Color3.fromRGB(136, 136, 136)
                if btn:FindFirstChild("Underline") then
                    btn.Underline:Destroy()
                end
            end
            button.TextColor3 = Color3.fromRGB(255, 255, 255)
            local underline = Instance.new("Frame")
            underline.Name = "Underline"
            underline.Size = UDim2.new(1, 0, 0, 2)
            underline.Position = UDim2.new(0, 0, 1, -2)
            underline.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            underline.BorderSizePixel = 0
            underline.Parent = button
            
            -- Скрытие всех вкладок
            for _, child in pairs(ContentContainer:GetChildren()) do
                if child:IsA("ScrollingFrame") then
                    child.Visible = false
                end
            end
            
            -- Показ нужной вкладки
            local tabMap = {
                Combat = CombatTab,
                Visuals = ContentContainer.VisualsTab,
                Movement = ContentContainer.MovementTab,
                Misc = ContentContainer.MiscTab,
                Config = ContentContainer.ConfigTab
            }
            if tabMap[tabName] then
                tabMap[tabName].Visible = true
            end
        end)
    end
    
    -- Перетаскивание меню
    local dragging = false
    local dragInput
    local dragStart
    local startPos
    
    TitleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = MainContainer.Position
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            MainContainer.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
end

-- Инициализация GUI
createMenu()

-- Обработка Insert
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.KeyCode == Enum.KeyCode.Insert then
        ScreenGui.Enabled = not ScreenGui.Enabled
    end
    
    if input.KeyCode == Enum.KeyCode.End then
        -- Panic - отключение всего
        ScreenGui.Enabled = false
        -- Очистка всех активных функций
        Config.AimbotEnabled = false
        Config.SilentAimEnabled = false
        Config.TriggerbotEnabled = false
        Config.ESPEnabled = false
        Config.ChamsEnabled = false
        Config.SpeedEnabled = false
        Config.FlyEnabled = false
        Config.NoclipEnabled = false
        Config.BunnyHopEnabled = false
        Config.AntiAimEnabled = false
        Config.FakeLagEnabled = false
        Config.IsFlying = false
        Config.IsNoclipping = false
    end
end)

-- Функции утилит
local function getClosestPlayer()
    local closest = nil
    local shortestDistance = Config.FOVRadius
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 then
            local head = player.Character:FindFirstChild("Head")
            if head then
                local screenPos, onScreen = Camera:WorldToViewportPoint(head.Position)
                if onScreen then
                    local mousePos = Vector2.new(Mouse.X, Mouse.Y)
                    local distance = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
                    if distance < shortestDistance then
                        shortestDistance = distance
                        closest = player
                    end
                end
            end
        end
    end
    
    return closest
end

local function getHitPosition(player, hitPart)
    local character = player.Character
    if not character then return nil end
    
    local part = character:FindFirstChild(hitPart)
    if part then
        return part.Position
    elseif hitPart == "Head" and character:FindFirstChild("Head") then
        return character.Head.Position
    elseif character:FindFirstChild("HumanoidRootPart") then
        return character.HumanoidRootPart.Position
    end
    
    return nil
end

-- Функции читов (оставлены как есть из предыдущей версии)
local function aimbotFunction()
    if not Config.AimbotEnabled then return end
    
    local target = getClosestPlayer()
    if target and target.Character then
        local hitPos = getHitPosition(target, Config.HitPart)
        if hitPos then
            local screenPos = Camera:WorldToViewportPoint(hitPos)
            local targetPos = Vector2.new(screenPos.X, screenPos.Y)
            local mousePos = Vector2.new(Mouse.X, Mouse.Y)
            local delta = targetPos - mousePos
            local smoothFactor = Config.Smoothness / 10
            
            mousemoverel(delta.X / smoothFactor, delta.Y / smoothFactor)
        end
    end
end

local function silentAimFunction()
    if not Config.SilentAimEnabled then return end
    if math.random(1, 100) > Config.SilentHitChance then return end
    
    local target = getClosestPlayer()
    if target and target.Character then
        local hitPos = getHitPosition(target, Config.HitPart)
        if hitPos then
            local tool = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Tool")
            if tool and tool:FindFirstChild("Handle") then
                local handle = tool.Handle
                local direction = (hitPos - handle.Position).Unit
                local oldCFrame = handle.CFrame
                handle.CFrame = CFrame.new(handle.Position, handle.Position + direction)
                task.wait()
                handle.CFrame = oldCFrame
            end
        end
    end
end

local function triggerbotFunction()
    if not Config.TriggerbotEnabled then return end
    
    local target = LocalPlayer:GetMouse().Target
    if target and target.Parent then
        local humanoid = target.Parent:FindFirstChild("Humanoid")
        if humanoid and target.Parent ~= LocalPlayer.Character then
            task.wait(Config.TriggerbotDelay / 1000)
            mouse1click()
        end
    end
end

local function espFunction()
    for _, conn in pairs(ESPConnections) do
        pcall(function() conn:Disconnect() end)
    end
    ESPConnections = {}
    
    if not Config.ESPEnabled then return end
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local box = Drawing.new("Square")
            box.Visible = true
            box.Color = Config.BoxColor
            box.Thickness = 1.5
            box.Filled = false
            box.Transparency = 1
            
            local healthBar = Drawing.new("Square")
            healthBar.Visible = Config.HealthBar
            healthBar.Color = Color3.fromRGB(0, 255, 0)
            healthBar.Filled = true
            healthBar.Transparency = 1
            
            local nameTag = Drawing.new("Text")
            nameTag.Visible = Config.NameTags
            nameTag.Color = Color3.fromRGB(255, 255, 255)
            nameTag.Size = 14
            nameTag.Center = true
            nameTag.Outline = true
            nameTag.Text = player.Name
            nameTag.Transparency = 1
            
            local distanceTag = Drawing.new("Text")
            distanceTag.Visible = Config.Distance
            distanceTag.Color = Color3.fromRGB(200, 200, 200)
            distanceTag.Size = 12
            distanceTag.Center = true
            distanceTag.Outline = true
            distanceTag.Transparency = 1
            
            local connection = RunService.RenderStepped:Connect(function()
                if player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character:FindFirstChild("Humanoid") and player.Character:FindFirstChild("Head") then
                    local rootPart = player.Character.HumanoidRootPart
                    local head = player.Character.Head
                    local humanoid = player.Character.Humanoid
                    
                    if humanoid.Health <= 0 then
                        box.Visible = false
                        healthBar.Visible = false
                        nameTag.Visible = false
                        distanceTag.Visible = false
                        return
                    end
                    
                    local rootPos, rootOnScreen = Camera:WorldToViewportPoint(rootPart.Position)
                    local headPos, headOnScreen = Camera:WorldToViewportPoint(head.Position + Vector3.new(0, 0.5, 0))
                    local distance = (LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character.HumanoidRootPart.Position - rootPart.Position).Magnitude or 0
                    
                    if rootOnScreen and headOnScreen and distance <= Config.MaxESPDistance then
                        local boxHeight = math.abs(headPos.Y - rootPos.Y) * 1.5
                        local boxWidth = boxHeight * 0.65
                        
                        box.Position = Vector2.new(headPos.X - boxWidth / 2, headPos.Y - boxHeight * 0.3)
                        box.Size = Vector2.new(boxWidth, boxHeight)
                        box.Visible = true
                        
                        if Config.HealthBar then
                            local healthPercent = humanoid.Health / humanoid.MaxHealth
                            healthBar.Position = Vector2.new(headPos.X - boxWidth / 2 - 5, headPos.Y - boxHeight * 0.3 + boxHeight * (1 - healthPercent))
                            healthBar.Size = Vector2.new(3, boxHeight * healthPercent)
                            healthBar.Color = Color3.fromRGB(255 * (1 - healthPercent), 255 * healthPercent, 0)
                            healthBar.Visible = true
                        end
                        
                        if Config.NameTags then
                            nameTag.Position = Vector2.new(headPos.X, headPos.Y - boxHeight * 0.4)
                            nameTag.Text = player.Name
                            nameTag.Visible = true
                        end
                        
                        if Config.Distance then
                            distanceTag.Position = Vector2.new(headPos.X, headPos.Y - boxHeight * 0.4 - 16)
                            distanceTag.Text = math.floor(distance) .. "m"
                            distanceTag.Visible = true
                        end
                    else
                        box.Visible = false
                        healthBar.Visible = false
                        nameTag.Visible = false
                        distanceTag.Visible = false
                    end
                else
                    box.Visible = false
                    healthBar.Visible = false
                    nameTag.Visible = false
                    distanceTag.Visible = false
                end
            end)
            
            table.insert(ESPConnections, {
                Box = box,
                HealthBar = healthBar,
                NameTag = nameTag,
                DistanceTag = distanceTag,
                Connection = connection
            })
        end
    end
end

local function chamsFunction()
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local highlight = player.Character:FindFirstChild("ChamHighlight")
            if Config.ChamsEnabled then
                if not highlight then
                    highlight = Instance.new("Highlight")
                    highlight.Name = "ChamHighlight"
                    highlight.Parent = player.Character
                end
                highlight.FillColor = Config.ChamColor
                highlight.OutlineColor = Config.ChamColor
                highlight.FillTransparency = 0.5
                highlight.OutlineTransparency = 0
                highlight.Enabled = true
            else
                if highlight then
                    highlight:Destroy()
                end
            end
        end
    end
end

local function speedFunction()
    if not LocalPlayer.Character then return end
    local humanoid = LocalPlayer.Character:FindFirstChild("Humanoid")
    if humanoid then
        if Config.SpeedEnabled then
            if not SavedSpeeds[LocalPlayer.UserId] then
                SavedSpeeds[LocalPlayer.UserId] = humanoid.WalkSpeed
            end
            humanoid.WalkSpeed = Config.SpeedMultiplier
        else
            if SavedSpeeds[LocalPlayer.UserId] then
                humanoid.WalkSpeed = SavedSpeeds[LocalPlayer.UserId]
                SavedSpeeds[LocalPlayer.UserId] = nil
            end
        end
    end
end

local function flyFunction()
    if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then return end
    
    local rootPart = LocalPlayer.Character.HumanoidRootPart
    local humanoid = LocalPlayer.Character:FindFirstChild("Humanoid")
    
    if Config.IsFlying then
        local bodyGyro = Instance.new("BodyGyro")
        bodyGyro.P = 9e4
        bodyGyro.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
        bodyGyro.CFrame = rootPart.CFrame
        bodyGyro.Parent = rootPart
        
        local bodyVelocity = Instance.new("BodyVelocity")
        bodyVelocity.Velocity = Vector3.new(0, 0, 0)
        bodyVelocity.MaxForce = Vector3.new(9e9, 9e9, 9e9)
        bodyVelocity.Parent = rootPart
        
        if humanoid then
            humanoid.PlatformStand = true
        end
        
        FlyConnection = RunService.RenderStepped:Connect(function()
            if not Config.IsFlying then
                if FlyConnection then FlyConnection:Disconnect() end
                bodyGyro:Destroy()
                bodyVelocity:Destroy()
                if humanoid then humanoid.PlatformStand = false end
                return
            end
            
            local direction = Vector3.new(0, 0, 0)
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                direction += Camera.CFrame.LookVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                direction -= Camera.CFrame.LookVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                direction -= Camera.CFrame.RightVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                direction += Camera.CFrame.RightVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                direction += Vector3.new(0, 1, 0)
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
                direction -= Vector3.new(0, 1, 0)
            end
            
            bodyVelocity.Velocity = direction * Config.FlySpeed
            bodyGyro.CFrame = Camera.CFrame
        end)
    else
        if FlyConnection then
            FlyConnection:Disconnect()
            FlyConnection = nil
        end
        if humanoid then humanoid.PlatformStand = false end
        local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if root then
            for _, child in pairs(root:GetChildren()) do
                if child:IsA("BodyGyro") or child:IsA("BodyVelocity") then
                    child:Destroy()
                end
            end
        end
    end
end

local function noclipFunction()
    if not LocalPlayer.Character then return end
    
    if Config.IsNoclipping then
        NoclipConnection = RunService.Stepped:Connect(function()
            if LocalPlayer.Character then
                for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                    end
                end
            end
        end)
    else
        if NoclipConnection then
            NoclipConnection:Disconnect()
            NoclipConnection = nil
        end
        if LocalPlayer.Character then
            for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = true
                end
            end
        end
    end
end

local function bunnyHopFunction()
    if not Config.BunnyHopEnabled then return end
    if not LocalPlayer.Character then return end
    
    local humanoid = LocalPlayer.Character:FindFirstChild("Humanoid")
    if humanoid and humanoid:GetState() == Enum.HumanoidStateType.Landed then
        humanoid.Jump = true
        humanoid.JumpPower = Config.JumpPower
    end
end

local function antiAimFunction()
    if not Config.AntiAimEnabled then return end
    if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then return end
    
    local rootPart = LocalPlayer.Character.HumanoidRootPart
    
    if Config.Pitch == "Down" then
        rootPart.CFrame = rootPart.CFrame * CFrame.Angles(math.rad(89), 0, 0)
    elseif Config.Pitch == "Up" then
        rootPart.CFrame = rootPart.CFrame * CFrame.Angles(math.rad(-89), 0, 0)
    elseif Config.Pitch == "Zero" then
        rootPart.CFrame = CFrame.new(rootPart.Position) * CFrame.Angles(0, rootPart.Orientation.Y, 0)
    end
    
    if Config.Yaw == "Backward" then
        rootPart.CFrame = rootPart.CFrame * CFrame.Angles(0, math.rad(180), 0)
    elseif Config.Yaw == "Spin" then
        local spinAngle = tick() * Config.SpinSpeed % 360
        rootPart.CFrame = CFrame.new(rootPart.Position) * CFrame.Angles(0, math.rad(spinAngle), 0)
    elseif Config.Yaw == "Jitter" then
        local jitterAngle = math.random(-180, 180)
        rootPart.CFrame = CFrame.new(rootPart.Position) * CFrame.Angles(0, math.rad(jitterAngle), 0)
    end
end

local function fakeLagFunction()
    if not Config.FakeLagEnabled then return end
    
    if FakeLagConnection then
        FakeLagConnection:Disconnect()
    end
    
    FakeLagConnection = RunService.RenderStepped:Connect(function()
        task.wait(Config.LagAmount / 100)
    end)
end

local function exploitsFunction()
    if not LocalPlayer.Character then return end
    
    if Config.InfiniteAmmo then
        for _, tool in pairs(LocalPlayer.Character:GetChildren()) do
            if tool:IsA("Tool") then
                local ammo = tool:FindFirstChild("Ammo")
                if ammo and ammo:IsA("IntValue") then
                    ammo.Value = 999
                end
            end
        end
    end
    
    if Config.NoRecoil then
        local recoilScripts = {}
        for _, descendant in pairs(getgc()) do
            if type(descendant) == "function" and getfenv(descendant).recoil then
                pcall(function()
                    local env = getfenv(descendant)
                    env.recoil = 0
                end)
            end
        end
    end
    
    if Config.NoSpread then
        for _, descendant in pairs(getgc()) do
            if type(descendant) == "function" and getfenv(descendant).spread then
                pcall(function()
                    local env = getfenv(descendant)
                    env.spread = 0
                end)
            end
        end
    end
    
    if Config.RapidFire then
        local tool = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Tool")
        if tool and tool:FindFirstChild("FireRate") then
            tool.FireRate.Value = 0.001
        end
    end
end

-- Обработка клавиш Fly и Noclip
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.KeyCode == Enum.KeyCode.X then
        Config.FlyEnabled = not Config.FlyEnabled
        Config.IsFlying = Config.FlyEnabled
        flyFunction()
    end
    
    if input.KeyCode == Enum.KeyCode.V then
        Config.NoclipEnabled = not Config.NoclipEnabled
        Config.IsNoclipping = Config.NoclipEnabled
        noclipFunction()
    end
end)

-- Основной цикл
RunService.RenderStepped:Connect(function()
    pcall(function()
        aimbotFunction()
        silentAimFunction()
        triggerbotFunction()
        bunnyHopFunction()
        exploitsFunction()
    end)
end)

RunService.Stepped:Connect(function()
    pcall(function()
        antiAimFunction()
    end)
end)

RunService.Heartbeat:Connect(function()
    pcall(function()
        fakeLagFunction()
    end)
end)

spawn(function()
    while true do
        task.wait(0.5)
        pcall(function()
            speedFunction()
            chamsFunction()
        end)
    end
end)

espFunction()

print("Tridient Survival Rage Hub v1.0.03 loaded successfully")
print("Made for educational purposes")
print("Press Insert to toggle menu")
print("Panic key: End")
