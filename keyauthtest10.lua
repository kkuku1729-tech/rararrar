-- KeyAuth система
local KeyAuth = {
    name = "ExpensiveMods",
    ownerid = "Q2uvPey1OB",
    secret = "217bed44eac9e5ac571c511296c651c786c962448b16c9ca7b49d91f86270ee6", 
    version = "1.0"
}

-- Инициализация KeyAuth
local KeyAuthInit = game:HttpGet("https://keyauth.win/api/1.1/?type=init&name="..KeyAuth.name.."&ownerid="..KeyAuth.ownerid.."&secret="..KeyAuth.secret.."&version="..KeyAuth.version)
local AuthData = game:GetService("HttpService"):JSONDecode(KeyAuthInit)

if not AuthData.success then
    error("KeyAuth failed: "..AuthData.message)
end

-- GUI для ключа
local KeyGUI = Instance.new("ScreenGui")
KeyGUI.Parent = game.CoreGui

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 350, 0, 200)
MainFrame.Position = UDim2.new(0.5, -175, 0.5, -100)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
MainFrame.Parent = KeyGUI

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundColor3 = Color3.fromRGB(30, 30, 38)
Title.Text = "ExpensiveMods - Key Auth"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 16
Title.Font = Enum.Font.GothamBold
Title.Parent = MainFrame

local KeyBox = Instance.new("TextBox")
KeyBox.Size = UDim2.new(0.8, 0, 0, 30)
KeyBox.Position = UDim2.new(0.1, 0, 0.3, 0)
KeyBox.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
KeyBox.PlaceholderText = "Enter license key..."
KeyBox.TextColor3 = Color3.fromRGB(255, 255, 255)
KeyBox.TextSize = 14
KeyBox.Parent = MainFrame

local SubmitBtn = Instance.new("TextButton")
SubmitBtn.Size = UDim2.new(0.6, 0, 0, 30)
SubmitBtn.Position = UDim2.new(0.2, 0, 0.5, 0)
SubmitBtn.BackgroundColor3 = Color3.fromRGB(70, 130, 255)
SubmitBtn.Text = "ACTIVATE"
SubmitBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
SubmitBtn.TextSize = 14
SubmitBtn.Parent = MainFrame

local Status = Instance.new("TextLabel")
Status.Size = UDim2.new(0.8, 0, 0, 30)
Status.Position = UDim2.new(0.1, 0, 0.7, 0)
Status.BackgroundTransparency = 1
Status.Text = "Enter your key"
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

    -- Сервисы
    local UIS = game:GetService("UserInputService")
    local Players = game:GetService("Players")
    local RS = game:GetService("RunService")
    local WS = game:GetService("Workspace")
    
    local LP = Players.LocalPlayer
    local Mouse = LP:GetMouse()

    -- Главное меню
    local MainGUI = Instance.new("ScreenGui")
    MainGUI.Parent = game.CoreGui

    local MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0, 450, 0, 400)
    MainFrame.Position = UDim2.new(0.5, -225, 0.5, -200)
    MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    MainFrame.Visible = false
    MainFrame.Parent = MainGUI

    local Header = Instance.new("Frame")
    Header.Size = UDim2.new(1, 0, 0, 30)
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

    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Size = UDim2.new(0, 25, 0, 25)
    CloseBtn.Position = UDim2.new(1, -30, 0, 2)
    CloseBtn.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
    CloseBtn.Text = "X"
    CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    CloseBtn.TextSize = 12
    CloseBtn.Parent = Header

    -- Вкладки
    local TabFrame = Instance.new("Frame")
    TabFrame.Size = UDim2.new(0, 100, 1, -30)
    TabFrame.Position = UDim2.new(0, 0, 0, 30)
    TabFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 32)
    TabFrame.Parent = MainFrame

    local ContentFrame = Instance.new("Frame")
    ContentFrame.Size = UDim2.new(1, -100, 1, -30)
    ContentFrame.Position = UDim2.new(0, 100, 0, 30)
    ContentFrame.BackgroundTransparency = 1
    ContentFrame.Parent = MainFrame

    -- Создание вкладок
    local Tabs = {"Combat", "Movement", "Visuals", "Misc"}
    local CurrentTab = "Combat"

    for i, tab in pairs(Tabs) do
        local Btn = Instance.new("TextButton")
        Btn.Size = UDim2.new(1, -10, 0, 30)
        Btn.Position = UDim2.new(0, 5, 0, 5 + ((i-1)*35))
        Btn.BackgroundColor3 = tab == CurrentTab and Color3.fromRGB(70, 130, 255) or Color3.fromRGB(40, 40, 50)
        Btn.Text = tab
        Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        Btn.TextSize = 12
        Btn.Parent = TabFrame
        
        Btn.MouseButton1Click:Connect(function()
            CurrentTab = tab
            for _, child in pairs(ContentFrame:GetChildren()) do
                child.Visible = child.Name == tab
            end
            for _, btn in pairs(TabFrame:GetChildren()) do
                if btn:IsA("TextButton") then
                    btn.BackgroundColor3 = btn.Text == tab and Color3.fromRGB(70, 130, 255) or Color3.fromRGB(40, 40, 50)
                end
            end
        end)
    end

    -- Функция создания секции
    local function CreateSection(tabName, title)
        local Section = Instance.new("Frame")
        Section.Name = tabName
        Section.Size = UDim2.new(1, 0, 1, 0)
        Section.BackgroundTransparency = 1
        Section.Visible = tabName == CurrentTab
        Section.Parent = ContentFrame
        
        local TitleLabel = Instance.new("TextLabel")
        TitleLabel.Size = UDim2.new(1, 0, 0, 25)
        TitleLabel.Position = UDim2.new(0, 10, 0, 5)
        TitleLabel.BackgroundTransparency = 1
        TitleLabel.Text = title
        TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        TitleLabel.TextSize = 13
        TitleLabel.Font = Enum.Font.GothamBold
        TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
        TitleLabel.Parent = Section
        
        return Section
    end

    -- Переменные функций
    _G.AimbotEnabled = false
    _G.AimbotFOV = 100
    _G.ESPEnabled = false
    _G.FlyEnabled = false
    _G.SpeedEnabled = false
    _G.NoclipEnabled = false

    -- Функция создания тогглов
    local function CreateToggle(section, text, default, callback)
        local yPos = #section:GetChildren() * 30 + 35
        
        local Toggle = Instance.new("TextButton")
        Toggle.Size = UDim2.new(1, -20, 0, 25)
        Toggle.Position = UDim2.new(0, 10, 0, yPos)
        Toggle.BackgroundColor3 = default and Color3.fromRGB(70, 130, 255) or Color3.fromRGB(80, 80, 80)
        Toggle.Text = text
        Toggle.TextColor3 = Color3.fromRGB(255, 255, 255)
        Toggle.TextSize = 12
        Toggle.Parent = section
        
        Toggle.MouseButton1Click:Connect(function()
            default = not default
            Toggle.BackgroundColor3 = default and Color3.fromRGB(70, 130, 255) or Color3.fromRGB(80, 80, 80)
            callback(default)
        end)
    end

    -- Функция создания слайдера
    local function CreateSlider(section, text, min, max, default, callback)
        local yPos = #section:GetChildren() * 30 + 35
        
        local Label = Instance.new("TextLabel")
        Label.Size = UDim2.new(1, -20, 0, 20)
        Label.Position = UDim2.new(0, 10, 0, yPos)
        Label.BackgroundTransparency = 1
        Label.Text = text .. ": " .. default
        Label.TextColor3 = Color3.fromRGB(255, 255, 255)
        Label.TextSize = 12
        Label.TextXAlignment = Enum.TextXAlignment.Left
        Label.Parent = section
        
        local dragging = false
        
        local function update(value)
            Label.Text = text .. ": " .. math.floor(value)
            callback(value)
        end
        
        Label.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = true
            end
        end)
        
        Label.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = false
            end
        end)
        
        UIS.InputChanged:Connect(function(input)
            if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                local x = (input.Position.X - Label.AbsolutePosition.X) / Label.AbsoluteSize.X
                local value = min + (x * (max - min))
                value = math.clamp(math.floor(value), min, max)
                update(value)
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
    FOVCircle.Parent = MainGUI

    local function UpdateFOV()
        FOVCircle.Size = UDim2.new(0, _G.AimbotFOV * 2, 0, _G.AimbotFOV * 2)
        FOVCircle.Position = UDim2.new(0.5, -_G.AimbotFOV, 0.5, -_G.AimbotFOV)
    end

    -- АИМБОТ
    local function Aimbot(enabled)
        _G.AimbotEnabled = enabled
        FOVCircle.Visible = enabled
        
        if enabled then
            _G.AimbotConnection = RS.RenderStepped:Connect(function()
                if not _G.AimbotEnabled then return end
                
                local closest = nil
                local shortest = _G.AimbotFOV
                local center = Vector2.new(WS.CurrentCamera.ViewportSize.X/2, WS.CurrentCamera.ViewportSize.Y/2)
                
                for _, player in pairs(Players:GetPlayers()) do
                    if player ~= LP and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                        local point = WS.CurrentCamera:WorldToViewportPoint(player.Character.HumanoidRootPart.Position)
                        if point.Z > 0 then
                            local dist = (Vector2.new(point.X, point.Y) - center).Magnitude
                            if dist < shortest then
                                closest = player
                                shortest = dist
                            end
                        end
                    end
                end
                
                if closest and closest.Character then
                    local point = WS.CurrentCamera:WorldToViewportPoint(closest.Character.HumanoidRootPart.Position)
                    mousemoverel((point.X - Mouse.X) * 0.6, (point.Y - Mouse.Y) * 0.6)
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
    local function Fly(enabled)
        _G.FlyEnabled = enabled
        if enabled then
            _G.FlyConnection = RS.Heartbeat:Connect(function()
                if not _G.FlyEnabled or not LP.Character then return end
                local root = LP.Character:FindFirstChild("HumanoidRootPart")
                if not root then return end
                
                local bv = root:FindFirstChild("FlyBV")
                if not bv then
                    bv = Instance.new("BodyVelocity")
                    bv.Name = "FlyBV"
                    bv.MaxForce = Vector3.new(40000, 40000, 40000)
                    bv.Parent = root
                end
                
                local vel = Vector3.new(0, 0, 0)
                if UIS:IsKeyDown(Enum.KeyCode.W) then
                    vel = vel + WS.CurrentCamera.CFrame.LookVector * 50
                end
                if UIS:IsKeyDown(Enum.KeyCode.S) then
                    vel = vel - WS.CurrentCamera.CFrame.LookVector * 50
                end
                if UIS:IsKeyDown(Enum.KeyCode.A) then
                    vel = vel - WS.CurrentCamera.CFrame.RightVector * 50
                end
                if UIS:IsKeyDown(Enum.KeyCode.D) then
                    vel = vel + WS.CurrentCamera.CFrame.RightVector * 50
                end
                if UIS:IsKeyDown(Enum.KeyCode.Space) then
                    vel = vel + Vector3.new(0, 50, 0)
                end
                if UIS:IsKeyDown(Enum.KeyCode.LeftShift) then
                    vel = vel - Vector3.new(0, 50, 0)
                end
                
                bv.Velocity = vel
            end)
        else
            if _G.FlyConnection then
                _G.FlyConnection:Disconnect()
            end
            if LP.Character then
                local bv = LP.Character:FindFirstChild("FlyBV")
                if bv then bv:Destroy() end
            end
        end
    end

    -- ESP
    local ESPObjs = {}
    local function ESP(enabled)
        _G.ESPEnabled = enabled
        if enabled then
            _G.ESPConnection = RS.RenderStepped:Connect(function()
                if not _G.ESPEnabled then return end
                for _, player in pairs(Players:GetPlayers()) do
                    if player ~= LP and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                        if not ESPObjs[player] then
                            ESPObjs[player] = Instance.new("Highlight")
                            ESPObjs[player].FillColor = Color3.fromRGB(255, 0, 0)
                            ESPObjs[player].OutlineColor = Color3.fromRGB(255, 255, 255)
                            ESPObjs[player].Parent = player.Character
                        end
                        ESPObjs[player].Enabled = true
                    else
                        if ESPObjs[player] then
                            ESPObjs[player].Enabled = false
                        end
                    end
                end
            end)
        else
            if _G.ESPConnection then
                _G.ESPConnection:Disconnect()
            end
            for _, hl in pairs(ESPObjs) do
                hl:Destroy()
            end
            ESPObjs = {}
        end
    end

    -- НОКЛИП
    local function Noclip(enabled)
        _G.NoclipEnabled = enabled
        if enabled then
            _G.NoclipConnection = RS.Stepped:Connect(function()
                if not _G.NoclipEnabled or not LP.Character then return end
                for _, part in pairs(LP.Character:GetDescendants()) do
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
    local function Speed(enabled)
        _G.SpeedEnabled = enabled
        if enabled then
            _G.SpeedConnection = RS.Heartbeat:Connect(function()
                if not _G.SpeedEnabled or not LP.Character then return end
                local hum = LP.Character:FindFirstChild("Humanoid")
                if hum then hum.WalkSpeed = 50 end
            end)
        else
            if _G.SpeedConnection then
                _G.SpeedConnection:Disconnect()
            end
            if LP.Character then
                local hum = LP.Character:FindFirstChild("Humanoid")
                if hum then hum.WalkSpeed = 16 end
            end
        end
    end

    -- СПАММЕР
    spawn(function()
        while true do
            wait(35)
            local chat = game:GetService("ReplicatedStorage"):FindFirstChild("DefaultChatSystemChatEvents")
            if chat then
                local say = chat:FindFirstChild("SayMessageRequest")
                if say then
                    local msgs = {"тэгэ expensivemods чит", "т3г3 expensivemods читаем"}
                    local msg = msgs[math.random(1, #msgs)]
                    pcall(function() say:FireServer(msg, "All") end)
                end
            end
        end
    end)

    -- Создание интерфейса
    local Combat = CreateSection("Combat", "Aimbot")
    CreateToggle(Combat, "Enable Aimbot", false, Aimbot)
    CreateSlider(Combat, "Aimbot FOV", 10, 300, 100, function(v)
        _G.AimbotFOV = v
        UpdateFOV()
    end)

    local Movement = CreateSection("Movement", "Movement Hacks")
    CreateToggle(Movement, "Fly Hack", false, Fly)
    CreateToggle(Movement, "Speed Hack", false, Speed)
    CreateToggle(Movement, "Noclip", false, Noclip)

    local Visuals = CreateSection("Visuals", "ESP")
    CreateToggle(Visuals, "Enable ESP", false, ESP)

    local Misc = CreateSection("Misc", "Other")
    CreateToggle(Misc, "Enable Spammer", true, function() end)

    -- Управление GUI
    local dragging = false
    local dragStart, startPos

    Header.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = MainFrame.Position
        end
    end)

    UIS.InputChanged:Connect(function(input)
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

    -- Перемещение значка
    local iconDrag = false
    local iconStart, iconPos

    MenuIcon.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            iconDrag = true
            iconStart = input.Position
            iconPos = MenuIcon.Position
        end
    end)

    UIS.InputChanged:Connect(function(input)
        if iconDrag and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - iconStart
            MenuIcon.Position = UDim2.new(iconPos.X.Scale, iconPos.X.Offset + delta.X, iconPos.Y.Scale, iconPos.Y.Offset + delta.Y)
        end
    end)

    MenuIcon.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            iconDrag = false
        end
    end)

    -- Открытие/закрытие
    MenuIcon.MouseButton1Click:Connect(function()
        MainFrame.Visible = not MainFrame.Visible
    end)

    CloseBtn.MouseButton1Click:Connect(function()
        MainFrame.Visible = false
    end)

    UIS.InputBegan:Connect(function(input, processed)
        if processed then return end
        if input.KeyCode == Enum.KeyCode.Insert then
            MainFrame.Visible = not MainFrame.Visible
        end
    end)

    print("ExpensiveMods loaded successfully!")
end

-- Проверка ключа
SubmitBtn.MouseButton1Click:Connect(function()
    local key = KeyBox.Text:gsub("%s+", "")
    if key == "" then
        Status.Text = "Enter key"
        Status.TextColor3 = Color3.fromRGB(255, 50, 50)
        return
    end
    
    Status.Text = "Checking key..."
    Status.TextColor3 = Color3.fromRGB(255, 255, 0)
    
    local keyCheck = game:HttpGet("https://keyauth.win/api/1.1/?type=license&key="..key.."&name="..KeyAuth.name.."&ownerid="..KeyAuth.ownerid)
    local result = game:GetService("HttpService"):JSONDecode(keyCheck)
    
    if result.success then
        Status.Text = "Success! Loading..."
        Status.TextColor3 = Color3.fromRGB(0, 255, 0)
        wait(1)
        LoadMainScript()
    else
        Status.Text = "Invalid key: "..result.message
        Status.TextColor3 = Color3.fromRGB(255, 50, 50)
    end
end)

KeyBox.FocusLost:Connect(function(enter)
    if enter then SubmitBtn.MouseButton1Click() end
end)
