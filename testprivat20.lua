-- Простая ключ-система
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
Status.Size = UDim2.new(0.8, 0, 0, 40)
Status.Position = UDim2.new(0.1, 0, 0.85, 0)
Status.BackgroundTransparency = 1
Status.Text = "Keys: RAGE-7X9F-2K8M-4P6Q, RAGE-3B5D-8H2J-9N1M"
Status.TextColor3 = Color3.fromRGB(200, 200, 200)
Status.TextSize = 10
Status.Parent = MainFrame

local function LoadMainScript()
    KeyGUI:Destroy()
    
    -- ВСТАВЬТЕ СЮДА ВЕСЬ ПРЕДЫДУЩИЙ РАБОЧИЙ КОД БЕЗ КЛЮЧ-СИСТЕМЫ
    -- (тот код где все функции работали правильно)
    -- Начиная от создания ScreenGui и до конца
    
    print("ExpensiveMods loaded successfully!")
end

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
