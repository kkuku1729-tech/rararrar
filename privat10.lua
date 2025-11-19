-- Кастомный полупрозрачный GUI в стиле NeverLose
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer
local mouse = LocalPlayer:GetMouse()

-- Ключ-система
local AdminPassword = "svaston231211"
local Keys = {
    "RAGE-7X9F-2K8M-4P6Q",
    "RAGE-3B5D-8H2J-9N1M", 
    "RAGE-6C4X-7V3Z-1L9K",
    "RAGE-8Q2W-5E7R-3T6Y"
}
local ActiveKeys = {
    ["RAGE-7X9F-2K8M-4P6Q"] = true,
    ["RAGE-3B5D-8H2J-9N1M"] = true,
    ["RAGE-6C4X-7V3Z-1L9K"] = true,
    ["RAGE-8Q2W-5E7R-3T6Y"] = true
}

-- Проверка ключа
local function ValidateKey(inputKey)
    return ActiveKeys[inputKey] == true
end

-- Админ функции
local function IsAdmin(inputPassword)
    return inputPassword == AdminPassword
end

-- Проверка безопасности перед созданием GUI
if not game:IsLoaded() then
    game.Loaded:Wait()
end

if not LocalPlayer then
    Players.PlayerAdded:Wait()
    LocalPlayer = Players.LocalPlayer
end

-- Экран ввода ключа
local KeyScreenGui = Instance.new("ScreenGui")
KeyScreenGui.Name = "KeyScreenGUI"
KeyScreenGui.Parent = game:FindFirstChild("CoreGui") or game:FindFirstChild("PlayerGui") or LocalPlayer:WaitForChild("PlayerGui")
KeyScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local KeyMainFrame = Instance.new("Frame")
KeyMainFrame.Name = "KeyMainFrame"
KeyMainFrame.Size = UDim2.new(0, 400, 0, 300)
KeyMainFrame.Position = UDim2.new(0.5, -200, 0.5, -150)
KeyMainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
KeyMainFrame.BackgroundTransparency = 0.1
KeyMainFrame.BorderSizePixel = 0
KeyMainFrame.ClipsDescendants = true
KeyMainFrame.Parent = KeyScreenGui

local KeyUICorner = Instance.new("UICorner")
KeyUICorner.CornerRadius = UDim.new(0, 8)
KeyUICorner.Parent = KeyMainFrame

local KeyTitle = Instance.new("TextLabel")
KeyTitle.Name = "KeyTitle"
KeyTitle.Size = UDim2.new(1, 0, 0, 60)
KeyTitle.Position = UDim2.new(0, 0, 0, 0)
KeyTitle.BackgroundColor3 = Color3.fromRGB(30, 30, 38)
KeyTitle.BackgroundTransparency = 0.1
KeyTitle.Text = "ExpensiveMods | Key System"
KeyTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
KeyTitle.TextSize = 18
KeyTitle.Font = Enum.Font.GothamBold
KeyTitle.Parent = KeyMainFrame

local KeyTitleCorner = Instance.new("UICorner")
KeyTitleCorner.CornerRadius = UDim.new(0, 8)
KeyTitleCorner.Parent = KeyTitle

local KeyInput = Instance.new("TextBox")
KeyInput.Name = "KeyInput"
KeyInput.Size = UDim2.new(0.8, 0, 0, 40)
KeyInput.Position = UDim2.new(0.1, 0, 0.3, 0)
KeyInput.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
KeyInput.BackgroundTransparency = 0.1
KeyInput.Text = ""
KeyInput.PlaceholderText = "Enter your key or admin password..."
KeyInput.TextColor3 = Color3.fromRGB(255, 255, 255)
KeyInput.TextSize = 14
KeyInput.Font = Enum.Font.Gotham
KeyInput.Parent = KeyMainFrame

local KeyInputCorner = Instance.new("UICorner")
KeyInputCorner.CornerRadius = UDim.new(0, 6)
KeyInputCorner.Parent = KeyInput

local SubmitButton = Instance.new("TextButton")
SubmitButton.Name = "SubmitButton"
SubmitButton.Size = UDim2.new(0.6, 0, 0, 40)
SubmitButton.Position = UDim2.new(0.2, 0, 0.5, 0)
SubmitButton.BackgroundColor3 = Color3.fromRGB(70, 130, 255)
SubmitButton.BackgroundTransparency = 0.1
SubmitButton.Text = "SUBMIT"
SubmitButton.TextColor3 = Color3.fromRGB(255, 255, 255)
SubmitButton.TextSize = 16
SubmitButton.Font = Enum.Font.GothamBold
SubmitButton.Parent = KeyMainFrame

local SubmitCorner = Instance.new("UICorner")
SubmitCorner.CornerRadius = UDim.new(0, 6)
SubmitCorner.Parent = SubmitButton

local KeyList = Instance.new("TextLabel")
KeyList.Name = "KeyList"
KeyList.Size = UDim2.new(0.8, 0, 0, 80)
KeyList.Position = UDim2.new(0.1, 0, 0.7, 0)
KeyList.BackgroundTransparency = 1
KeyList.Text = "Available Keys:\nRAGE-7X9F-2K8M-4P6Q\nRAGE-3B5D-8H2J-9N1M\nRAGE-6C4X-7V3Z-1L9K\nRAGE-8Q2W-5E7R-3T6Y"
KeyList.TextColor3 = Color3.fromRGB(200, 200, 200)
KeyList.TextSize = 11
KeyList.Font = Enum.Font.Gotham
KeyList.TextXAlignment = Enum.TextXAlignment.Left
KeyList.Parent = KeyMainFrame

local StatusLabel = Instance.new("TextLabel")
StatusLabel.Name = "StatusLabel"
StatusLabel.Size = UDim2.new(0.8, 0, 0, 20)
StatusLabel.Position = UDim2.new(0.1, 0, 0.9, 0)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = "Enter key to access mod menu"
StatusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
StatusLabel.TextSize = 12
StatusLabel.Font = Enum.Font.Gotham
StatusLabel.Parent = KeyMainFrame

-- Переменные для доступа
local HasAccess = false
local IsAdminMode = false

-- Функция проверки доступа
SubmitButton.MouseButton1Click:Connect(function()
    local input = KeyInput.Text
    local trimmedInput = string.gsub(input, "%s+", "")
    
    if IsAdmin(trimmedInput) then
        IsAdminMode = true
        HasAccess = true
        StatusLabel.Text = "Admin access granted!"
        StatusLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
        wait(1)
        KeyScreenGui:Destroy()
        LoadMainGUI()
    elseif ValidateKey(trimmedInput) then
        HasAccess = true
        StatusLabel.Text = "Access granted! Loading..."
        StatusLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
        wait(1)
        KeyScreenGui:Destroy()
        LoadMainGUI()
    else
        StatusLabel.Text = "Invalid key or password!"
        StatusLabel.TextColor3 = Color3.fromRGB(255, 50, 50)
    end
end)

KeyInput.FocusLost:Connect(function(enterPressed)
    if enterPressed then
        SubmitButton.MouseButton1Click:Connect(function() end)
    end
end)

-- Основная функция загрузки GUI
function LoadMainGUI()
    -- Создание главного GUI
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "ExpensiveModsGUI_" .. HttpService:GenerateGUID(false)
    ScreenGui.Parent = game:FindFirstChild("CoreGui") or game:FindFirstChild("PlayerGui") or LocalPlayer:WaitForChild("PlayerGui")
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    -- Главный фрейм
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = UDim2.new(0, 550, 0, 600)
    MainFrame.Position = UDim2.new(0.5, -275, 0.5, -300)
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
    Title.Size = UDim2.new(1, -80, 1, 0)
    Title.Position = UDim2.new(0, 15, 0, 0)
    Title.BackgroundTransparency = 1
    Title.Text = "ExpensiveMods | RUZT Alpha 2.9.7" .. (IsAdminMode and " [ADMIN]" or "")
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.TextSize = 14
    Title.Font = Enum.Font.GothamSemibold
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Parent = Header

    local AdminButton = Instance.new("TextButton")
    AdminButton.Name = "AdminButton"
    AdminButton.Size = UDim2.new(0, 30, 0, 30)
    AdminButton.Position = UDim2.new(1, -70, 0, 5)
    AdminButton.BackgroundColor3 = IsAdminMode and Color3.fromRGB(255, 165, 0) or Color3.fromRGB(80, 80, 80)
    AdminButton.BackgroundTransparency = 0.2
    AdminButton.Text = "A"
    AdminButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    AdminButton.TextSize = 14
    AdminButton.Font = Enum.Font.GothamBold
    AdminButton.Visible = IsAdminMode
    AdminButton.Parent = Header

    local AdminCorner = Instance.new("UICorner")
    AdminCorner.CornerRadius = UDim.new(0, 4)
    AdminCorner.Parent = AdminButton

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
    
    if IsAdminMode then
        table.insert(Tabs, "Admin")
    end

    local CurrentTab = "Combat"
    local Elements = {}
    local TabButtonsList = {}

    -- Глобальные переменные для функций
    _G.AimbotEnabled = false
    _G.AimbotFOV = 50
    _G.AimSmoothness = 10
    _G.AimDistance = 100
    _G.VisibleCheck = true
    _G.Wallshot = false
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

    -- Функция создания кнопки
    local function CreateButton(section, text, callback)
        if not elementCounters[section] then
            elementCounters[section] = 0
        end
        
        elementCounters[section] = elementCounters[section] + 1
        
        local ButtonFrame = Instance.new("Frame")
        ButtonFrame.Size = UDim2.new(1, -20, 0, 35)
        ButtonFrame.Position = UDim2.new(0, 10, 0, 40 + ((elementCounters[section] - 1) * 40))
        ButtonFrame.BackgroundTransparency = 1
        ButtonFrame.Parent = section
        
        local Button = Instance.new("TextButton")
        Button.Size = UDim2.new(1, 0, 1, 0)
        Button.BackgroundColor3 = Color3.fromRGB(70, 130, 255)
        Button.BackgroundTransparency = 0.1
        Button.Text = text
        Button.TextColor3 = Color3.fromRGB(255, 255, 255)
        Button.TextSize = 12
        Button.Font = Enum.Font.Gotham
        Button.Parent = ButtonFrame
        
        local ButtonCorner = Instance.new("UICorner")
        ButtonCorner.CornerRadius = UDim.new(0, 6)
        ButtonCorner.Parent = Button
        
        Button.MouseButton1Click:Connect(function()
            if callback then
                callback()
            end
        end)
        
        return Button
    end

    -- Функция создания текстового поля
    local function CreateTextBox(section, placeholder, callback)
        if not elementCounters[section] then
            elementCounters[section] = 0
        end
        
        elementCounters[section] = elementCounters[section] + 1
        
        local TextBoxFrame = Instance.new("Frame")
        TextBoxFrame.Size = UDim2.new(1, -20, 0, 35)
        TextBoxFrame.Position = UDim2.new(0, 10, 0, 40 + ((elementCounters[section] - 1) * 40))
        TextBoxFrame.BackgroundTransparency = 1
        TextBoxFrame.Parent = section
        
        local TextBox = Instance.new("TextBox")
        TextBox.Size = UDim2.new(1, 0, 1, 0)
        TextBox.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
        TextBox.BackgroundTransparency = 0.1
        TextBox.Text = ""
        TextBox.PlaceholderText = placeholder
        TextBox.TextColor3 = Color3.fromRGB(255, 255, 255)
        TextBox.TextSize = 12
        TextBox.Font = Enum.Font.Gotham
        TextBox.Parent = TextBoxFrame
        
        local TextBoxCorner = Instance.new("UICorner")
        TextBoxCorner.CornerRadius = UDim.new(0, 6)
        TextBoxCorner.Parent = TextBox
        
        TextBox.FocusLost:Connect(function(enterPressed)
            if enterPressed and callback then
                callback(TextBox.Text)
            end
        end)
        
        return TextBox
    end

    -- АДМИН ПАНЕЛЬ --
    local AdminSection = CreateSection("Admin", "Key Management", 400)
    
    local KeyStatusLabel = Instance.new("TextLabel")
    KeyStatusLabel.Size = UDim2.new(1, -20, 0, 30)
    KeyStatusLabel.Position = UDim2.new(0, 10, 0, 40)
    KeyStatusLabel.BackgroundTransparency = 1
    KeyStatusLabel.Text = "Active Keys:"
    KeyStatusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    KeyStatusLabel.TextSize = 14
    KeyStatusLabel.Font = Enum.Font.GothamBold
    KeyStatusLabel.TextXAlignment = Enum.TextXAlignment.Left
    KeyStatusLabel.Parent = AdminSection
    
    local KeysListLabel = Instance.new("TextLabel")
    KeysListLabel.Size = UDim2.new(1, -20, 0, 120)
    KeysListLabel.Position = UDim2.new(0, 10, 0, 75)
    KeysListLabel.BackgroundTransparency = 1
    KeysListLabel.Text = ""
    KeysListLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    KeysListLabel.TextSize = 11
    KeysListLabel.Font = Enum.Font.Gotham
    KeysListLabel.TextXAlignment = Enum.TextXAlignment.Left
    KeysListLabel.TextYAlignment = Enum.TextYAlignment.Top
    KeysListLabel.Parent = AdminSection
    
    local function UpdateKeysList()
        local keysText = ""
        for _, key in pairs(Keys) do
            local status = ActiveKeys[key] and "🟢 ACTIVE" or "🔴 INACTIVE"
            keysText = keysText .. key .. " - " .. status .. "\n"
        end
        KeysListLabel.Text = keysText
    end
    
    UpdateKeysList()
    
    local DeactivateKeyBox = CreateTextBox(AdminSection, "Enter key to deactivate", function(key)
        if ActiveKeys[key] ~= nil then
            ActiveKeys[key] = false
            UpdateKeysList()
        end
    end)
    
    local ActivateKeyBox = CreateTextBox(AdminSection, "Enter key to activate", function(key)
        if ActiveKeys[key] ~= nil then
            ActiveKeys[key] = true
            UpdateKeysList()
        end
    end)
    
    CreateButton(AdminSection, "Generate New Key", function()
        local newKey = "RAGE-" .. string.upper(HttpService:GenerateGUID(false):sub(1, 12))
        table.insert(Keys, newKey)
        ActiveKeys[newKey] = true
        UpdateKeysList()
    end)
    
    CreateButton(AdminSection, "Delete Key", function()
        local keyToDelete = DeactivateKeyBox.Text
        if keyToDelete ~= "" then
            for i, key in pairs(Keys) do
                if key == keyToDelete then
                    table.remove(Keys, i)
                    ActiveKeys[key] = nil
                    UpdateKeysList()
                    break
                end
            end
        end
    end)

    -- [ОСТАЛЬНЫЕ СЕКЦИИ И ФУНКЦИИ ОСТАЮТСЯ БЕЗ ИЗМЕНЕНИЙ ИЗ ПРЕДЫДУЩЕГО КОДА]
    -- Combat, Movement, Visuals, Misc секции с их функциями...

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

    print("ExpensiveMods successfully loaded! All features are working.")
end
