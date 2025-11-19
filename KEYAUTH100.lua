-- Кастомный полупрозрачный GUI в стиле NeverLose с KeyAuth
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local HttpService = game:GetService("HttpService")

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

-- KeyAuth система
local KeyAuth = {
    api = {
        name = "ruztsoft",
        ownerid = "Q2uvPey1OB", -- ЗАМЕНИТЕ НА ВАШ OWNER_ID
        version = "1.0",
        url = "https://keyauth.win/api/1.2/"
    },
    initialized = false,
    sessionid = ""
}

-- Инициализация KeyAuth
function KeyAuth:init()
    local success, result = pcall(function()
        local req = game:HttpGet(self.api.url .. "?type=init&name=" .. self.api.name .. "&ownerid=" .. self.api.ownerid .. "&version=" .. self.api.version, true)
        local data = HttpService:JSONDecode(req)
        
        if data["success"] then
            self.sessionid = data["sessionid"]
            self.initialized = true
            return true
        end
        return false
    end)
    
    return success and result or false
end

-- Проверка лицензии
function KeyAuth:license(key)
    if not self.initialized then return false end
    
    local success, result = pcall(function()
        local postdata = "type=license&key=" .. key .. "&sessionid=" .. self.sessionid .. "&name=" .. self.api.name .. "&ownerid=" .. self.api.ownerid
        local req = game:HttpGet(self.api.url .. "?" .. postdata, true)
        local data = HttpService:JSONDecode(req)
        return data["success"]
    end)
    
    return success and result or false
end

-- Инициализируем KeyAuth
KeyAuth:init()

-- Создание главного GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ExpensiveModsGUI_" .. HttpService:GenerateGUID(false)
ScreenGui.Parent = game:FindFirstChild("CoreGui") or game:FindFirstChild("PlayerGui") or LocalPlayer:WaitForChild("PlayerGui")
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- Окно аутентификации
local AuthFrame = Instance.new("Frame")
AuthFrame.Name = "AuthFrame"
AuthFrame.Size = UDim2.new(0, 350, 0, 250)
AuthFrame.Position = UDim2.new(0.5, -175, 0.5, -125)
AuthFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
AuthFrame.BackgroundTransparency = 0.1
AuthFrame.BorderSizePixel = 0
AuthFrame.Visible = true
AuthFrame.Parent = ScreenGui

local AuthCorner = Instance.new("UICorner")
AuthCorner.CornerRadius = UDim.new(0, 8)
AuthCorner.Parent = AuthFrame

local AuthStroke = Instance.new("UIStroke")
AuthStroke.Color = Color3.fromRGB(70, 130, 255)
AuthStroke.Thickness = 1
AuthStroke.Parent = AuthFrame

-- Заголовок аутентификации
local AuthTitle = Instance.new("TextLabel")
AuthTitle.Size = UDim2.new(1, 0, 0, 50)
AuthTitle.BackgroundColor3 = Color3.fromRGB(30, 30, 38)
AuthTitle.Text = "EXPENSIVEMODS - KEY AUTH"
AuthTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
AuthTitle.TextSize = 16
AuthTitle.Font = Enum.Font.GothamBold
AuthTitle.Parent = AuthFrame

local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(0.8, 0, 0, 20)
StatusLabel.Position = UDim2.new(0.1, 0, 0.2, 0)
StatusLabel.BackgroundTransparency = 1
StatusLabel.TextColor3 = KeyAuth.initialized and Color3.fromRGB(80, 220, 120) or Color3.fromRGB(220, 80, 80)
StatusLabel.Text = KeyAuth.initialized and "KEYAUTH CONNECTED" or "KEYAUTH ERROR"
StatusLabel.TextSize = 12
StatusLabel.Font = Enum.Font.Gotham
StatusLabel.Parent = AuthFrame

local KeyInput = Instance.new("TextBox")
KeyInput.Size = UDim2.new(0.8, 0, 0, 40)
KeyInput.Position = UDim2.new(0.1, 0, 0.4, 0)
KeyInput.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
KeyInput.TextColor3 = Color3.fromRGB(255, 255, 255)
KeyInput.PlaceholderText = "Enter license key..."
KeyInput.Text = ""
KeyInput.TextSize = 14
KeyInput.Font = Enum.Font.Gotham
KeyInput.Parent = AuthFrame

local LoginButton = Instance.new("TextButton")
LoginButton.Size = UDim2.new(0.8, 0, 0, 40)
LoginButton.Position = UDim2.new(0.1, 0, 0.7, 0)
LoginButton.BackgroundColor3 = Color3.fromRGB(70, 130, 255)
LoginButton.TextColor3 = Color3.fromRGB(255, 255, 255)
LoginButton.Text = "ACTIVATE"
LoginButton.TextSize = 14
LoginButton.Font = Enum.Font.GothamBold
LoginButton.Parent = AuthFrame

-- Главный фрейм (скрыт до аутентификации)
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 500, 0, 500)
MainFrame.Position = UDim2.new(0.5, -250, 0.5, -250)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
MainFrame.BackgroundTransparency = 0.2
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true
MainFrame.Visible = false
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
_G.AimSmoothness = 10
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
_G.Authenticated = false

-- Функция аутентификации
local function Authenticate()
    local key = KeyInput.Text:gsub("%s+", "")
    if key == "" then 
        StatusLabel.TextColor3 = Color3.fromRGB(220, 80, 80)
        StatusLabel.Text = "ENTER LICENSE KEY"
        return 
    end
    
    StatusLabel.TextColor3 = Color3.fromRGB(255, 255, 100)
    StatusLabel.Text = "CHECKING LICENSE..."
    LoginButton.Text = "CHECKING..."
    
    wait(1)
    
    local success = KeyAuth:license(key)
    
    if success then
        _G.Authenticated = true
        AuthFrame.Visible = false
        MainFrame.Visible = true
        
        StatusLabel.TextColor3 = Color3.fromRGB(80, 220, 120)
        StatusLabel.Text = "LICENSE VALID"
        
        -- Запускаем спаммер после успешной аутентификации
        StartSpammer()
    else
        StatusLabel.TextColor3 = Color3.fromRGB(220, 80, 80)
        StatusLabel.Text = "INVALID LICENSE"
        LoginButton.Text = "ACTIVATE"
    end
end

LoginButton.MouseButton1Click:Connect(Authenticate)
KeyInput.FocusLost:Connect(function(enterPressed)
    if enterPressed then Authenticate() end
end)

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
        if not _G.Authenticated then return end
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
    ToggleFrame.Size = UDim2.new(1, -20, 0, 30)
    ToggleFrame.Position = UDim2.new(0, 10, 0, 40 + ((elementCounters[section] - 1) * 35))
    ToggleFrame.BackgroundTransparency = 1
    ToggleFrame.Parent = section
    
    local ToggleButton = Instance.new("TextButton")
    ToggleButton.Size = UDim2.new(0, 20, 0, 20)
    ToggleButton.Position = UDim2.new(0, 0, 0, 5)
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
            if not _G.Authenticated then return end
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
    SliderFrame.Size = UDim2.new(1, -20, 0, 45)
    SliderFrame.Position = UDim2.new(0, 10, 0, 40 + ((elementCounters[section] - 1) * 50))
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
    SliderBar.Size = UDim2.new(1, 0, 0, 6)
    SliderBar.Position = UDim2.new(0, 0, 0, 30)
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

-- УЛУЧШЕННЫЙ АИМБОТ --
local function IsVisible(target)
    if not _G.VisibleCheck then return true end
    
    local character = LocalPlayer.Character
    local targetChar = target.Character
    if not character or not targetChar then return false end
    
    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    local targetRoot = targetChar:FindFirstChild("HumanoidRootPart")
    if not humanoidRootPart or not targetRoot then return false end
    
    local origin = humanoidRootPart.Position
    local targetPos = targetRoot.Position
    
    -- Raycast для проверки видимости
    local ray = Ray.new(origin, (targetPos - origin).Unit * (targetPos - origin).Magnitude)
    local hit, position = Workspace:FindPartOnRayWithIgnoreList(ray, {character, targetChar})
    
    return hit == nil
end

local function AimbotFunction(enabled)
    if not _G.Authenticated then return end
    
    _G.AimbotEnabled = enabled
    FOVCircle.Visible = enabled
    
    if enabled then
        _G.AimbotConnection = RunService.RenderStepped:Connect(function()
            if not _G.AimbotEnabled or not _G.Authenticated then return end
            
            local closestPlayer = nil
            local shortestDistance = _G.AimbotFOV
            local screenCenter = Vector2.new(Workspace.CurrentCamera.ViewportSize.X / 2, Workspace.CurrentCamera.ViewportSize.Y / 2)
            
            for _, player in pairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 then
                    local character = player.Character
                    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
                    if not humanoidRootPart then continue end
                    
                    local screenPoint, visible = Workspace.CurrentCamera:WorldToViewportPoint(humanoidRootPart.Position)
                    
                    if visible and IsVisible(player) then
                        local distance = (Vector2.new(screenPoint.X, screenPoint.Y) - screenCenter).Magnitude
                        
                        if distance < shortestDistance then
                            closestPlayer = player
                            shortestDistance = distance
                        end
                    end
                end
            end
            
            if closestPlayer and closestPlayer.Character then
                local humanoidRootPart = closestPlayer.Character:FindFirstChild("HumanoidRootPart")
                if humanoidRootPart then
                    local screenPoint = Workspace.CurrentCamera:WorldToViewportPoint(humanoidRootPart.Position)
                    
                    -- Плавное наведение с учетом сглаживания
                    local smoothFactor = math.max(0.1, _G.AimSmoothness / 20)
                    local deltaX = (screenPoint.X - screenCenter.X) * smoothFactor
                    local deltaY = (screenPoint.Y - screenCenter.Y) * smoothFactor
                    
                    mousemoverel(deltaX, deltaY)
                    
                    -- Автострельба
                    if _G.AutoShoot then
                        mouse1press()
                        task.wait(0.05)
                        mouse1release()
                    end
                end
            end
        end)
    else
        if _G.AimbotConnection then
            _G.AimbotConnection:Disconnect()
        end
        FOVCircle.Visible = false
    end
end

-- РАБОЧИЙ ESP С HP --
local ESPObjects = {}

local function ESPFunction(enabled)
    if not _G.Authenticated then return end
    
    _G.ESPEnabled = enabled
    
    if enabled then
        _G.ESPConnection = RunService.RenderStepped:Connect(function()
            if not _G.ESPEnabled or not _G.Authenticated then return end
            
            for _, player in pairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 then
                    local character = player.Character
                    local humanoid = character:FindFirstChild("Humanoid")
                    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
                    
                    if not humanoidRootPart then continue end
                    
                    local screenPoint, visible = Workspace.CurrentCamera:WorldToViewportPoint(humanoidRootPart.Position)
                    local distance = (humanoidRootPart.Position - Workspace.CurrentCamera.CFrame.Position).Magnitude
                    
                    if visible and distance <= _G.ESPDistance then
                        if not ESPObjects[player] then
                            ESPObjects[player] = {}
                            
                            -- Box
                            ESPObjects[player].Box = Instance.new("Frame")
                            ESPObjects[player].Box.BackgroundTransparency = 0.7
                            ESPObjects[player].Box.BackgroundColor3 = _G.ESPColor
                            ESPObjects[player].Box.BorderSizePixel = 1
                            ESPObjects[player].Box.BorderColor3 = Color3.fromRGB(255, 255, 255)
                            ESPObjects[player].Box.ZIndex = 10
                            ESPObjects[player].Box.Parent = ScreenGui
                            
                            -- Name
                            ESPObjects[player].Name = Instance.new("TextLabel")
                            ESPObjects[player].Name.BackgroundTransparency = 1
                            ESPObjects[player].Name.TextColor3 = _G.ESPColor
                            ESPObjects[player].Name.TextSize = 14
                            ESPObjects[player].Name.Font = Enum.Font.GothamBold
                            ESPObjects[player].Name.ZIndex = 10
                            ESPObjects[player].Name.Parent = ScreenGui
                            
                            -- Distance
                            ESPObjects[player].Distance = Instance.new("TextLabel")
                            ESPObjects[player].Distance.BackgroundTransparency = 1
                            ESPObjects[player].Distance.TextColor3 = _G.ESPColor
                            ESPObjects[player].Distance.TextSize = 12
                            ESPObjects[player].Distance.Font = Enum.Font.Gotham
                            ESPObjects[player].Distance.ZIndex = 10
                            ESPObjects[player].Distance.Parent = ScreenGui
                            
                            -- Health
                            ESPObjects[player].Health = Instance.new("TextLabel")
                            ESPObjects[player].Health.BackgroundTransparency = 1
                            ESPObjects[player].Health.TextColor3 = _G.ESPColor
                            ESPObjects[player].Health.TextSize = 12
                            ESPObjects[player].Health.Font = Enum.Font.Gotham
                            ESPObjects[player].Health.ZIndex = 10
                            ESPObjects[player].Health.Parent = ScreenGui
                        end
                        
                        -- Update positions
                        local boxSize = 30
                        ESPObjects[player].Box.Size = UDim2.new(0, boxSize, 0, boxSize)
                        ESPObjects[player].Box.Position = UDim2.new(0, screenPoint.X - boxSize/2, 0, screenPoint.Y - boxSize/2)
                        ESPObjects[player].Box.Visible = _G.ESPBoxes
                        
                        ESPObjects[player].Name.Text = player.Name
                        ESPObjects[player].Name.Position = UDim2.new(0, screenPoint.X, 0, screenPoint.Y - 40)
                        ESPObjects[player].Name.Visible = _G.ESPNames
                        
                        ESPObjects[player].Distance.Text = math.floor(distance) .. "m"
                        ESPObjects[player].Distance.Position = UDim2.new(0, screenPoint.X, 0, screenPoint.Y - 25)
                        ESPObjects[player].Distance.Visible = _G.ESPNames
                        
                        if humanoid then
                            ESPObjects[player].Health.Text = "HP: " .. math.floor(humanoid.Health) .. "/" .. math.floor(humanoid.MaxHealth)
                            ESPObjects[player].Health.Position = UDim2.new(0, screenPoint.X, 0, screenPoint.Y - 10)
                            ESPObjects[player].Health.Visible = _G.ESPHealth
                        end
                        
                    else
                        if ESPObjects[player] then
                            ESPObjects[player].Box.Visible = false
                            ESPObjects[player].Name.Visible = false
                            ESPObjects[player].Distance.Visible = false
                            ESPObjects[player].Health.Visible = false
                        end
                    end
                else
                    if ESPObjects[player] then
                        ESPObjects[player].Box:Destroy()
                        ESPObjects[player].Name:Destroy()
                        ESPObjects[player].Distance:Destroy()
                        ESPObjects[player].Health:Destroy()
                        ESPObjects[player] = nil
                    end
                end
            end
        end)
    else
        if _G.ESPConnection then
            _G.ESPConnection:Disconnect()
        end
        for player, esp in pairs(ESPObjects) do
            if esp.Box then esp.Box:Destroy() end
            if esp.Name then esp.Name:Destroy() end
            if esp.Distance then esp.Distance:Destroy() end
            if esp.Health then esp.Health:Destroy() end
        end
        ESPObjects = {}
    end
end

-- РАБОЧИЙ ФЛАЙХАК --
local function FlyFunction(enabled)
    if not _G.Authenticated then return end
    
    _G.FlyEnabled = enabled
    
    if enabled then
        _G.FlyConnection = RunService.Heartbeat:Connect(function()
            if not _G.FlyEnabled or not _G.Authenticated or not LocalPlayer.Character then return end
            
            local humanoidRootPart = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if not humanoidRootPart then return end
            
            -- Создание или получение BodyVelocity
            local bodyVelocity = humanoidRootPart:FindFirstChild("FlyBodyVelocity")
            if not bodyVelocity then
                bodyVelocity = Instance.new("BodyVelocity")
                bodyVelocity.Name = "FlyBodyVelocity"
                bodyVelocity.Velocity = Vector3.new(0, 0, 0)
                bodyVelocity.MaxForce = Vector3.new(40000, 40000, 40000)
                bodyVelocity.Parent = humanoidRootPart
            end
            
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
            
            bodyVelocity.Velocity = newVelocity
        end)
    else
        if _G.FlyConnection then
            _G.FlyConnection:Disconnect()
        end
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local bodyVelocity = LocalPlayer.Character.HumanoidRootPart:FindFirstChild("FlyBodyVelocity")
            if bodyVelocity then
                bodyVelocity:Destroy()
            end
        end
    end
end

-- РАБОЧИЙ СПИДХАК --
local function SpeedFunction(enabled)
    if not _G.Authenticated then return end
    
    _G.SpeedEnabled = enabled
    
    if enabled then
        _G.SpeedConnection = RunService.Heartbeat:Connect(function()
            if not _G.SpeedEnabled or not _G.Authenticated or not LocalPlayer.Character then return end
            
            local humanoid = LocalPlayer.Character:FindFirstChild("Humanoid")
            if humanoid then
                humanoid.WalkSpeed = _G.SpeedValue
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

-- РАБОЧИЙ НОКЛИП --
local function NoclipFunction(enabled)
    if not _G.Authenticated then return end
    
    _G.NoclipEnabled = enabled
    
    if enabled then
        _G.NoclipConnection = RunService.Stepped:Connect(function()
            if not _G.NoclipEnabled or not _G.Authenticated or not LocalPlayer.Character then return end
            
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

-- РАБОЧИЙ СПАММЕР --
local function StartSpammer()
    spawn(function()
        while _G.Authenticated do
            task.wait(math.random(30, 40))
            
            local success, result = pcall(function()
                local chatService = game:GetService("ReplicatedStorage"):FindFirstChild("DefaultChatSystemChatEvents")
                if chatService then
                    local sayMessage = chatService:FindFirstChild("SayMessageRequest")
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
                        sayMessage:FireServer(randomMsg, "All")
                        print("Spammer: Sent message - " .. randomMsg)
                    end
                end
            end)
        end
    end)
end

-- Создание секций и элементов
local CombatSection = CreateSection("Combat", "Aimbot", 250)
local aimbotToggle = CreateToggle(CombatSection, "Enable Aimbot", false, AimbotFunction)
CreateSlider(CombatSection, "Aimbot FOV", 10, 300, 50, function(value)
    _G.AimbotFOV = value
    UpdateFOVCircle()
end)
CreateSlider(CombatSection, "Aim Smoothness", 1, 20, 10, function(value)
    _G.AimSmoothness = value
end)
local visibleToggle = CreateToggle(CombatSection, "Visible Check", true, function(value)
    _G.VisibleCheck = value
end)
local autoShootToggle = CreateToggle(CombatSection, "Auto Shoot", false, function(value)
    _G.AutoShoot = value
end)

local MovementSection = CreateSection("Movement", "Movement Hacks", 220)
local flyToggle = CreateToggle(MovementSection, "Fly Hack", false, FlyFunction)
CreateSlider(MovementSection, "Fly Speed", 1, 200, 50, function(value)
    _G.FlySpeed = value
end)
local speedToggle = CreateToggle(MovementSection, "Speed Hack", false, SpeedFunction)
CreateSlider(MovementSection, "Speed Value", 16, 100, 50, function(value)
    _G.SpeedValue = value
end)
local noclipToggle = CreateToggle(MovementSection, "Noclip", false, NoclipFunction)

local VisualsSection = CreateSection("Visuals", "ESP Settings", 220)
local espToggle = CreateToggle(VisualsSection, "Enable ESP", false, ESPFunction)
local espBoxesToggle = CreateToggle(VisualsSection, "2D Boxes", true, function(value)
    _G.ESPBoxes = value
end)
local espNamesToggle = CreateToggle(VisualsSection, "Player Names", true, function(value)
    _G.ESPNames = value
end)
local espHealthToggle = CreateToggle(VisualsSection, "Show HP", true, function(value)
    _G.ESPHealth = value
end)
CreateSlider(VisualsSection, "ESP Distance", 50, 500, 200, function(value)
    _G.ESPDistance = value
end)

local MiscSection = CreateSection("Misc", "Other", 120)
local spammerToggle = CreateToggle(MiscSection, "Enable Spammer", true, function() end)

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
        if _G.Authenticated then
            menuVisible = not menuVisible
            MainFrame.Visible = menuVisible
        end
    end
end)

-- Уведомление
local Notification = Instance.new("TextLabel")
Notification.Size = UDim2.new(0, 350, 0, 40)
Notification.Position = UDim2.new(0.5, -175, 0, 10)
Notification.BackgroundColor3 = Color3.fromRGB(30, 30, 38)
Notification.BackgroundTransparency = 0.15
Notification.Text = "ExpensiveMods loaded! Enter license key to activate"
Notification.TextColor3 = Color3.fromRGB(255, 255, 255)
Notification.TextSize = 14
Notification.Font = Enum.Font.Gotham
Notification.Parent = ScreenGui

local NotifCorner = Instance.new("UICorner")
NotifCorner.CornerRadius = UDim.new(0, 6)
NotifCorner.Parent = Notification

-- Авто-скрытие уведомления
task.delay(5, function()
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

print("ExpensiveMods successfully loaded! Waiting for authentication...")
