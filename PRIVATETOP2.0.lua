-- Кастомный полупрозрачный GUI в стиле NeverLose с KeyAuth и настройкой цвета ESP
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

-- Кружок для открытия меню (NeverLose Style)
local CircleButton = Instance.new("TextButton")
CircleButton.Name = "CircleButton"
CircleButton.Size = UDim2.new(0, 45, 0, 45)
CircleButton.Position = UDim2.new(0, 30, 0, 30)
CircleButton.BackgroundColor3 = Color3.fromRGB(70, 130, 255)
CircleButton.BackgroundTransparency = 0.1
CircleButton.Text = "⚡"
CircleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CircleButton.TextSize = 18
CircleButton.Visible = false
CircleButton.ZIndex = 1000
CircleButton.Parent = ScreenGui

local CircleCorner = Instance.new("UICorner")
CircleCorner.CornerRadius = UDim.new(1, 0)
CircleCorner.Parent = CircleButton

local CircleStroke = Instance.new("UIStroke")
CircleStroke.Color = Color3.fromRGB(70, 130, 255)
CircleStroke.Thickness = 1.5
CircleStroke.Parent = CircleButton

-- Главный фрейм (скрыт до аутентификации)
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 450, 0, 500)
MainFrame.Position = UDim2.new(0.5, -225, 0.5, -250)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
MainFrame.BackgroundTransparency = 0.2
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true
MainFrame.Visible = false
MainFrame.ZIndex = 900
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
    "Visuals"
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
_G.BoxColor = Color3.fromRGB(255, 255, 255)
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
        CircleButton.Visible = true
        
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

-- Drag логика для кружка
local draggingCircle = false
local circleDragStart, circleStartPos

CircleButton.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        draggingCircle = true
        circleDragStart = input.Position
        circleStartPos = CircleButton.Position
    end
end)

CircleButton.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        draggingCircle = false
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if draggingCircle and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - circleDragStart
        CircleButton.Position = UDim2.new(circleStartPos.X.Scale, circleStartPos.X.Offset + delta.X, circleStartPos.Y.Scale, circleStartPos.Y.Offset + delta.Y)
    end
end)

-- Открытие/закрытие меню по клику на кружок
CircleButton.MouseButton1Click:Connect(function()
    if not _G.Authenticated then return end
    MainFrame.Visible = not MainFrame.Visible
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

-- Функция создания цветового пикера
local function CreateColorPicker(section, text, defaultColor, callback)
    if not elementCounters[section] then
        elementCounters[section] = 0
    end
    
    elementCounters[section] = elementCounters[section] + 1
    
    local ColorPickerFrame = Instance.new("Frame")
    ColorPickerFrame.Size = UDim2.new(1, -20, 0, 40)
    ColorPickerFrame.Position = UDim2.new(0, 10, 0, 40 + ((elementCounters[section] - 1) * 45))
    ColorPickerFrame.BackgroundTransparency = 1
    ColorPickerFrame.Parent = section
    
    local ColorPickerLabel = Instance.new("TextLabel")
    ColorPickerLabel.Size = UDim2.new(0.6, 0, 1, 0)
    ColorPickerLabel.Position = UDim2.new(0, 0, 0, 0)
    ColorPickerLabel.BackgroundTransparency = 1
    ColorPickerLabel.Text = text
    ColorPickerLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    ColorPickerLabel.TextSize = 12
    ColorPickerLabel.Font = Enum.Font.Gotham
    ColorPickerLabel.TextXAlignment = Enum.TextXAlignment.Left
    ColorPickerLabel.Parent = ColorPickerFrame
    
    local ColorButton = Instance.new("TextButton")
    ColorButton.Size = UDim2.new(0, 60, 0, 25)
    ColorButton.Position = UDim2.new(0.65, 0, 0.2, 0)
    ColorButton.BackgroundColor3 = defaultColor
    ColorButton.Text = ""
    ColorButton.Parent = ColorPickerFrame
    
    local ColorButtonCorner = Instance.new("UICorner")
    ColorButtonCorner.CornerRadius = UDim.new(0, 4)
    ColorButtonCorner.Parent = ColorButton
    
    local ColorButtonStroke = Instance.new("UIStroke")
    ColorButtonStroke.Color = Color3.fromRGB(255, 255, 255)
    ColorButtonStroke.Thickness = 1
    ColorButtonStroke.Parent = ColorButton
    
    -- Создаем окно выбора цвета
    local ColorPickerWindow = Instance.new("Frame")
    ColorPickerWindow.Size = UDim2.new(0, 200, 0, 150)
    ColorPickerWindow.Position = UDim2.new(0, 0, 1, 5)
    ColorPickerWindow.BackgroundColor3 = Color3.fromRGB(30, 30, 38)
    ColorPickerWindow.BackgroundTransparency = 0.1
    ColorPickerWindow.BorderSizePixel = 0
    ColorPickerWindow.Visible = false
    ColorPickerWindow.ZIndex = 100
    ColorPickerWindow.Parent = ColorPickerFrame
    
    local ColorPickerCorner = Instance.new("UICorner")
    ColorPickerCorner.CornerRadius = UDim.new(0, 6)
    ColorPickerCorner.Parent = ColorPickerWindow
    
    -- Палитра цветов
    local colors = {
        Color3.fromRGB(255, 0, 0),    -- Красный
        Color3.fromRGB(0, 255, 0),    -- Зеленый
        Color3.fromRGB(0, 0, 255),    -- Синий
        Color3.fromRGB(255, 255, 0),  -- Желтый
        Color3.fromRGB(255, 0, 255),  -- Пурпурный
        Color3.fromRGB(0, 255, 255),  -- Голубой
        Color3.fromRGB(255, 255, 255),-- Белый
        Color3.fromRGB(255, 165, 0),  -- Оранжевый
        Color3.fromRGB(128, 0, 128),  -- Фиолетовый
        Color3.fromRGB(0, 255, 127),  -- Весенний зеленый
        Color3.fromRGB(70, 130, 255), -- Синий NeverLose
        Color3.fromRGB(220, 20, 60)   -- Малиновый
    }
    
    -- Создаем кнопки цветов
    for i, color in ipairs(colors) do
        local row = math.floor((i-1)/4)
        local col = (i-1) % 4
        
        local ColorOption = Instance.new("TextButton")
        ColorOption.Size = UDim2.new(0, 40, 0, 25)
        ColorOption.Position = UDim2.new(0, 10 + (col * 45), 0, 10 + (row * 30))
        ColorOption.BackgroundColor3 = color
        ColorOption.Text = ""
        ColorOption.ZIndex = 101
        ColorOption.Parent = ColorPickerWindow
        
        local ColorOptionCorner = Instance.new("UICorner")
        ColorOptionCorner.CornerRadius = UDim.new(0, 4)
        ColorOptionCorner.Parent = ColorOption
        
        ColorOption.MouseButton1Click:Connect(function()
            ColorButton.BackgroundColor3 = color
            ColorPickerWindow.Visible = false
            if callback then
                callback(color)
            end
        end)
    end
    
    -- Кнопка закрытия
    local CloseColorPicker = Instance.new("TextButton")
    CloseColorPicker.Size = UDim2.new(0, 180, 0, 25)
    CloseColorPicker.Position = UDim2.new(0, 10, 0, 115)
    CloseColorPicker.BackgroundColor3 = Color3.fromRGB(70, 130, 255)
    CloseColorPicker.Text = "Close"
    CloseColorPicker.TextColor3 = Color3.fromRGB(255, 255, 255)
    CloseColorPicker.TextSize = 12
    CloseColorPicker.ZIndex = 101
    CloseColorPicker.Parent = ColorPickerWindow
    
    local CloseColorCorner = Instance.new("UICorner")
    CloseColorCorner.CornerRadius = UDim.new(0, 4)
    CloseColorCorner.Parent = CloseColorPicker
    
    CloseColorPicker.MouseButton1Click:Connect(function()
        ColorPickerWindow.Visible = false
    end)
    
    -- Открытие/закрытие пикера
    ColorButton.MouseButton1Click:Connect(function()
        ColorPickerWindow.Visible = not ColorPickerWindow.Visible
    end)
    
    return ColorPickerFrame
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
                    
                    -- Плавное наведение с учетом с
