-- Кастомный полупрозрачный GUI в стиле NeverLose
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

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
MainFrame.BackgroundTransparency = 0.2 -- Полупрозрачность
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true
MainFrame.Parent = ScreenGui

-- Скругление углов
local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 8)
UICorner.Parent = MainFrame

-- Тень
local DropShadow = Instance.new("ImageLabel")
DropShadow.Name = "DropShadow"
DropShadow.Size = UDim2.new(1, 0, 1, 0)
DropShadow.Position = UDim2.new(0, 0, 0, 0)
DropShadow.BackgroundTransparency = 1
DropShadow.Image = "rbxassetid://6014261993"
DropShadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
DropShadow.ImageTransparency = 0.5
DropShadow.ScaleType = Enum.ScaleType.Slice
DropShadow.SliceCenter = Rect.new(49, 49, 450, 450)
DropShadow.Parent = MainFrame

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

-- Функция создания кнопки вкладки
local function CreateTabButton(tabName)
    local Button = Instance.new("TextButton")
    Button.Name = tabName .. "Button"
    Button.Size = UDim2.new(1, -10, 0, 35)
    Button.Position = UDim2.new(0, 5, 0, 5 + (#Elements * 40))
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
end

-- Функция создания секции
local function CreateSection(tabName, sectionName)
    local SectionFrame = Instance.new("Frame")
    SectionFrame.Name = tabName .. sectionName .. "Section"
    SectionFrame.Size = UDim2.new(1, -20, 0, 200)
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
for _, tabName in pairs(Tabs) do
    CreateTabButton(tabName)
end

-- Функция создания переключателя
local function CreateToggle(section, text, default, callback)
    local ToggleFrame = Instance.new("Frame")
    ToggleFrame.Size = UDim2.new(1, -20, 0, 25)
    ToggleFrame.Position = UDim2.new(0, 10, 0, 40 + (#section:GetChildren() * 30))
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
    
    return {Set = function(value) default = value end}
end

-- Создание элементов управления
local CombatSection = CreateSection("Combat", "Aimbot")
local aimbotToggle = CreateToggle(CombatSection, "Enable Aimbot", false, function(value)
    -- Логика аимбота здесь
end)

local MovementSection = CreateSection("Movement", "Movement Hacks")
local flyToggle = CreateToggle(MovementSection, "Fly Hack", false, function(value)
    -- Логика флайхака здесь
end)

local VisualsSection = CreateSection("Visuals", "ESP")
local espToggle = CreateToggle(VisualsSection, "Enable ESP", false, function(value)
    -- Логика ESP здесь
end)

local MiscSection = CreateSection("Misc", "Other")
local spammerToggle = CreateToggle(MiscSection, "Enable Spammer", false, function(value)
    -- Логика спаммера здесь
end)

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
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.KeyCode == Enum.KeyCode.Insert then
        MainFrame.Visible = not MainFrame.Visible
    end
end)

-- Уведомление
local Notification = Instance.new("TextLabel")
Notification.Size = UDim2.new(0, 300, 0, 40)
Notification.Position = UDim2.new(0.5, -150, 0, 10)
Notification.BackgroundColor3 = Color3.fromRGB(30, 30, 38)
Notification.BackgroundTransparency = 0.15
Notification.Text = "ExpensiveMods loaded! Press INSERT"
Notification.TextColor3 = Color3.fromRGB(255, 255, 255)
Notification.TextSize = 14
Notification.Font = Enum.Font.Gotham
Notification.Parent = ScreenGui

local NotifCorner = Instance.new("UICorner")
NotifCorner.CornerRadius = UDim.new(0, 6)
NotifCorner.Parent = Notification

-- Авто-скрытие уведомления
delay(3, function()
    if Notification then
        Notification:Destroy()
    end
end)
