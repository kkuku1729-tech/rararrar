-- RAGE MOD V1.01.02 - NeverLose Style
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Camera = workspace.CurrentCamera
local HttpService = game:GetService("HttpService")

-- KeyAuth
local KeyAuth = {
    api = {
        name = "ruztsoft",
        ownerid = "Q2uvPey1OB",
        version = "1.0",
        url = "https://keyauth.win/api/1.2/"
    },
    initialized = false,
    sessionid = ""
}

function KeyAuth:init()
    local success, result = pcall(function()
        local req = self:apiReq("?type=init&name=" .. self.api.name .. "&ownerid=" .. self.api.ownerid .. "&version=" .. self.api.version)
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

function KeyAuth:apiReq(endpoint)
    local success, result = pcall(function()
        return game:HttpGet(self.api.url .. endpoint, true)
    end)
    return success and result or '{"success":false}'
end

function KeyAuth:license(key)
    if not self.initialized then return false end
    local success, result = pcall(function()
        local postdata = "type=license&key=" .. key .. "&sessionid=" .. self.sessionid .. "&name=" .. self.api.name .. "&ownerid=" .. self.api.ownerid
        local req = self:apiReq("?" .. postdata)
        local data = HttpService:JSONDecode(req)
        return data["success"]
    end)
    return success and result or false
end

KeyAuth:init()

-- Состояние мода
local RAGE = {
    Authenticated = false,
    MenuOpen = false,
    Features = {
        Fly = false,
        Speed = false,
        SpeedValue = 50,
        Aimbot = false,
        Noclip = false,
        ESP = false
    },
    Aimbot = {
        FOV = 80,
        Target = nil,
        Smoothness = 1
    }
}

-- NeverLose Colors
local Colors = {
    Background = Color3.fromRGB(20, 20, 25),
    Primary = Color3.fromRGB(45, 45, 55),
    Accent = Color3.fromRGB(90, 120, 255),
    Text = Color3.fromRGB(240, 240, 245),
    Success = Color3.fromRGB(80, 220, 120),
    Error = Color3.fromRGB(220, 80, 80)
}

-- Создание UI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "RAGEMod"
ScreenGui.Parent = game.CoreGui

-- Окно аутентификации
local AuthFrame = Instance.new("Frame")
AuthFrame.Size = UDim2.new(0, 360, 0, 220)
AuthFrame.Position = UDim2.new(0.5, -180, 0.5, -110)
AuthFrame.BackgroundColor3 = Colors.Background
AuthFrame.BorderSizePixel = 0
AuthFrame.Visible = true
AuthFrame.Parent = ScreenGui

local AuthCorner = Instance.new("UICorner")
AuthCorner.CornerRadius = UDim.new(0, 8)
AuthCorner.Parent = AuthFrame

local AuthStroke = Instance.new("UIStroke")
AuthStroke.Color = Colors.Primary
AuthStroke.Thickness = 1
AuthStroke.Parent = AuthFrame

local AuthTitle = Instance.new("TextLabel")
AuthTitle.Size = UDim2.new(1, 0, 0, 45)
AuthTitle.Position = UDim2.new(0, 0, 0, 0)
AuthTitle.BackgroundColor3 = Colors.Primary
AuthTitle.Text = "RAGE MOD"
AuthTitle.TextColor3 = Colors.Text
AuthTitle.TextSize = 18
AuthTitle.Font = Enum.Font.GothamBold
AuthTitle.Parent = AuthFrame

local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(0.8, 0, 0, 20)
StatusLabel.Position = UDim2.new(0.1, 0, 0.25, 0)
StatusLabel.BackgroundTransparency = 1
StatusLabel.TextColor3 = KeyAuth.initialized and Colors.Success or Colors.Error
StatusLabel.Text = KeyAuth.initialized and "KEYAUTH CONNECTED" : "KEYAUTH ERROR"
StatusLabel.TextSize = 12
StatusLabel.Font = Enum.Font.Gotham
StatusLabel.Parent = AuthFrame

local KeyInput = Instance.new("TextBox")
KeyInput.Size = UDim2.new(0.8, 0, 0, 38)
KeyInput.Position = UDim2.new(0.1, 0, 0.45, 0)
KeyInput.BackgroundColor3 = Colors.Primary
KeyInput.TextColor3 = Colors.Text
KeyInput.PlaceholderText = "Enter license key..."
KeyInput.Text = ""
KeyInput.TextSize = 14
KeyInput.Font = Enum.Font.Gotham
KeyInput.Parent = AuthFrame

local KeyInputCorner = Instance.new("UICorner")
KeyInputCorner.CornerRadius = UDim.new(0, 6)
KeyInputCorner.Parent = KeyInput

local LoginButton = Instance.new("TextButton")
LoginButton.Size = UDim2.new(0.8, 0, 0, 38)
LoginButton.Position = UDim2.new(0.1, 0, 0.75, 0)
LoginButton.BackgroundColor3 = Colors.Accent
LoginButton.TextColor3 = Colors.Text
LoginButton.Text = "ACTIVATE"
LoginButton.TextSize = 14
LoginButton.Font = Enum.Font.GothamBold
LoginButton.Parent = AuthFrame

local LoginButtonCorner = Instance.new("UICorner")
LoginButtonCorner.CornerRadius = UDim.new(0, 6)
LoginButtonCorner.Parent = LoginButton

-- Кружок меню (NeverLose Style)
local CircleButton = Instance.new("TextButton")
CircleButton.Size = UDim2.new(0, 42, 0, 42)
CircleButton.Position = UDim2.new(0, 30, 0, 30)
CircleButton.BackgroundColor3 = Colors.Accent
CircleButton.BackgroundTransparency = 0.1
CircleButton.Text = "⚡"
CircleButton.TextColor3 = Colors.Text
CircleButton.TextSize = 16
CircleButton.Visible = false
CircleButton.ZIndex = 1000
CircleButton.Parent = ScreenGui

local CircleCorner = Instance.new("UICorner")
CircleCorner.CornerRadius = UDim.new(1, 0)
CircleCorner.Parent = CircleButton

local CircleStroke = Instance.new("UIStroke")
CircleStroke.Color = Colors.Accent
CircleStroke.Thickness = 1.5
CircleStroke.Parent = CircleButton

-- Главное меню
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 320, 0, 420)
MainFrame.Position = UDim2.new(0.5, -160, 0.5, -210)
MainFrame.BackgroundColor3 = Colors.Background
MainFrame.BorderSizePixel = 0
MainFrame.Visible = false
MainFrame.ZIndex = 900
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 8)
MainCorner.Parent = MainFrame

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Colors.Primary
MainStroke.Thickness = 1
MainStroke.Parent = MainFrame

local MainTitle = Instance.new("TextLabel")
MainTitle.Size = UDim2.new(1, 0, 0, 45)
MainTitle.Position = UDim2.new(0, 0, 0, 0)
MainTitle.BackgroundColor3 = Colors.Primary
MainTitle.Text = "RAGE MOD"
MainTitle.TextColor3 = Colors.Text
MainTitle.TextSize = 16
MainTitle.Font = Enum.Font.GothamBold
MainTitle.Parent = MainFrame

-- Контейнер для функций
local ScrollingFrame = Instance.new("ScrollingFrame")
ScrollingFrame.Size = UDim2.new(1, -10, 1, -55)
ScrollingFrame.Position = UDim2.new(0, 5, 0, 50)
ScrollingFrame.BackgroundTransparency = 1
ScrollingFrame.ScrollBarThickness = 2
ScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 400)
ScrollingFrame.Parent = MainFrame

-- Функция создания переключателей
local function CreateToggle(name, feature, yPosition)
    local ToggleFrame = Instance.new("Frame")
    ToggleFrame.Size = UDim2.new(1, 0, 0, 32)
    ToggleFrame.Position = UDim2.new(0, 0, 0, yPosition)
    ToggleFrame.BackgroundTransparency = 1
    ToggleFrame.Parent = ScrollingFrame
    
    local ToggleLabel = Instance.new("TextLabel")
    ToggleLabel.Size = UDim2.new(0.7, 0, 1, 0)
    ToggleLabel.Position = UDim2.new(0, 0, 0, 0)
    ToggleLabel.BackgroundTransparency = 1
    ToggleLabel.Text = name
    ToggleLabel.TextColor3 = Colors.Text
    ToggleLabel.TextSize = 13
    ToggleLabel.TextXAlignment = Enum.TextXAlignment.Left
    ToggleLabel.Font = Enum.Font.Gotham
    ToggleLabel.Parent = ToggleFrame
    
    local ToggleButton = Instance.new("TextButton")
    ToggleButton.Size = UDim2.new(0, 42, 0, 20)
    ToggleButton.Position = UDim2.new(0.75, 0, 0.5, -10)
    ToggleButton.BackgroundColor3 = Colors.Primary
    ToggleButton.Text = ""
    ToggleButton.Parent = ToggleFrame
    
    local ToggleCorner = Instance.new("UICorner")
    ToggleCorner.CornerRadius = UDim.new(0, 10)
    ToggleCorner.Parent = ToggleButton
    
    local ToggleCircle = Instance.new("Frame")
    ToggleCircle.Size = UDim2.new(0, 16, 0, 16)
    ToggleCircle.Position = UDim2.new(0, 2, 0.5, -8)
    ToggleCircle.BackgroundColor3 = Colors.Text
    ToggleCircle.Parent = ToggleButton
    
    local CircleCorner = Instance.new("UICorner")
    CircleCorner.CornerRadius = UDim.new(1, 0)
    CircleCorner.Parent = ToggleCircle
    
    ToggleButton.MouseButton1Click:Connect(function()
        if not RAGE.Authenticated then return end
        
        RAGE.Features[feature] = not RAGE.Features[feature]
        if RAGE.Features[feature] then
            TweenService:Create(ToggleCircle, TweenInfo.new(0.2), {Position = UDim2.new(0, 24, 0.5, -8)}):Play()
            ToggleButton.BackgroundColor3 = Colors.Accent
        else
            TweenService:Create(ToggleCircle, TweenInfo.new(0.2), {Position = UDim2.new(0, 2, 0.5, -8)}):Play()
            ToggleButton.BackgroundColor3 = Colors.Primary
        end
    end)
    
    return ToggleFrame
end

-- Функция создания слайдера
local function CreateSlider(name, minVal, maxVal, defaultVal, callback, yPosition)
    local SliderFrame = Instance.new("Frame")
    SliderFrame.Size = UDim2.new(1, 0, 0, 50)
    SliderFrame.Position = UDim2.new(0, 0, 0, yPosition)
    SliderFrame.BackgroundTransparency = 1
    SliderFrame.Parent = ScrollingFrame
    
    local SliderLabel = Instance.new("TextLabel")
    SliderLabel.Size = UDim2.new(1, 0, 0, 20)
    SliderLabel.Position = UDim2.new(0, 0, 0, 0)
    SliderLabel.BackgroundTransparency = 1
    SliderLabel.Text = name .. ": " .. defaultVal
    SliderLabel.TextColor3 = Colors.Text
    SliderLabel.TextSize = 12
    SliderLabel.TextXAlignment = Enum.TextXAlignment.Left
    SliderLabel.Font = Enum.Font.Gotham
    SliderLabel.Parent = SliderFrame
    
    local SliderTrack = Instance.new("Frame")
    SliderTrack.Size = UDim2.new(1, 0, 0, 4)
    SliderTrack.Position = UDim2.new(0, 0, 0, 30)
    SliderTrack.BackgroundColor3 = Colors.Primary
    SliderTrack.Parent = SliderFrame
    
    local SliderTrackCorner = Instance.new("UICorner")
    SliderTrackCorner.CornerRadius = UDim.new(0, 2)
    SliderTrackCorner.Parent = SliderTrack
    
    local SliderFill = Instance.new("Frame")
    SliderFill.Size = UDim2.new((defaultVal - minVal) / (maxVal - minVal), 0, 1, 0)
    SliderFill.Position = UDim2.new(0, 0, 0, 0)
    SliderFill.BackgroundColor3 = Colors.Accent
    SliderFill.Parent = SliderTrack
    
    local SliderFillCorner = Instance.new("UICorner")
    SliderFillCorner.CornerRadius = UDim.new(0, 2)
    SliderFillCorner.Parent = SliderFill
    
    local SliderButton = Instance.new("TextButton")
    SliderButton.Size = UDim2.new(0, 16, 0, 16)
    SliderButton.Position = UDim2.new((defaultVal - minVal) / (maxVal - minVal), -8, 0.5, -8)
    SliderButton.BackgroundColor3 = Colors.Text
    SliderButton.Text = ""
    SliderButton.ZIndex = 2
    SliderButton.Parent = SliderTrack
    
    local SliderButtonCorner = Instance.new("UICorner")
    SliderButtonCorner.CornerRadius = UDim.new(1, 0)
    SliderButtonCorner.Parent = SliderButton
    
    local dragging = false
    
    local function updateSlider(input)
        local pos = UDim2.new(math.clamp((input.Position.X - SliderTrack.AbsolutePosition.X) / SliderTrack.AbsoluteSize.X, 0, 1), -8, 0.5, -8)
        SliderButton.Position = pos
        
        local value = math.floor(minVal + (pos.X.Scale * (maxVal - minVal)))
        SliderLabel.Text = name .. ": " .. value
        SliderFill.Size = UDim2.new(pos.X.Scale, 0, 1, 0)
        
        callback(value)
    end
    
    SliderButton.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
        end
    end)
    
    SliderButton.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            updateSlider(input)
        end
    end)
    
    return SliderFrame
end

-- Создаем элементы интерфейса
local yPos = 0
CreateToggle("FLY HACK", "Fly", yPos); yPos = yPos + 35
CreateToggle("SPEED HACK", "Speed", yPos); yPos = yPos + 35
CreateToggle("AIMBOT", "Aimbot", yPos); yPos = yPos + 35
CreateToggle("NOCLIP", "Noclip", yPos); yPos = yPos + 35
CreateToggle("ESP", "ESP", yPos); yPos = yPos + 45

CreateSlider("SPEED VALUE", 16, 100, 50, function(value)
    RAGE.Features.SpeedValue = value
end, yPos); yPos = yPos + 60

CreateSlider("AIMBOT FOV", 10, 200, 80, function(value)
    RAGE.Aimbot.FOV = value
end, yPos); yPos = yPos + 60

ScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, yPos)

-- Аутентификация
local function Authenticate()
    local key = KeyInput.Text:gsub("%s+", "")
    if key == "" then 
        StatusLabel.TextColor3 = Colors.Error
        StatusLabel.Text = "ENTER LICENSE KEY"
        return 
    end
    
    StatusLabel.TextColor3 = Colors.Text
    StatusLabel.Text = "CHECKING LICENSE..."
    LoginButton.Text = "CHECKING..."
    
    wait(0.5)
    
    local success = KeyAuth:license(key)
    
    if success then
        RAGE.Authenticated = true
        AuthFrame.Visible = false
        CircleButton.Visible = true
        
        StatusLabel.TextColor3 = Colors.Success
        StatusLabel.Text = "LICENSE VALID"
    else
        StatusLabel.TextColor3 = Colors.Error
        StatusLabel.Text = "INVALID LICENSE"
        LoginButton.Text = "ACTIVATE"
    end
end

LoginButton.MouseButton1Click:Connect(Authenticate)
KeyInput.FocusLost:Connect(function(enterPressed)
    if enterPressed then Authenticate() end
end)

-- Drag для кружка
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

-- Открытие/закрытие меню
CircleButton.MouseButton1Click:Connect(function()
    if not RAGE.Authenticated then return end
    RAGE.MenuOpen = not RAGE.MenuOpen
    MainFrame.Visible = RAGE.MenuOpen
end)

-- ИСПРАВЛЕННЫЙ FLY HACK
local flyBodyVelocity
local flyConnection

local function FlyHack()
    if not RAGE.Authenticated then return end
    
    if RAGE.Features.Fly then
        local character = LocalPlayer.Character
        if character and character:FindFirstChild("HumanoidRootPart") then
            if not flyBodyVelocity then
                flyBodyVelocity = Instance.new("BodyVelocity")
                flyBodyVelocity.Velocity = Vector3.new(0, 0, 0)
                flyBodyVelocity.MaxForce = Vector3.new(40000, 40000, 40000)
                flyBodyVelocity.Parent = character.HumanoidRootPart
            end
            
            if not flyConnection then
                flyConnection = RunService.Heartbeat:Connect(function()
                    if not RAGE.Features.Fly or not flyBodyVelocity then return end
                    
                    local cam = workspace.CurrentCamera
                    local moveDirection = Vector3.new(0, 0, 0)
                    
                    if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                        moveDirection = moveDirection + cam.CFrame.LookVector
                    end
                    if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                        moveDirection = moveDirection - cam.CFrame.LookVector
                    end
                    if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                        moveDirection = moveDirection - cam.CFrame.RightVector
                    end
                    if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                        moveDirection = moveDirection + cam.CFrame.RightVector
                    end
                    if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                        moveDirection = moveDirection + Vector3.new(0, 1, 0)
                    end
                    if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
                        moveDirection = moveDirection - Vector3.new(0, 1, 0)
                    end
                    
                    flyBodyVelocity.Velocity = moveDirection * 100
                end)
            end
        end
    else
        if flyBodyVelocity then
            flyBodyVelocity:Destroy()
            flyBodyVelocity = nil
        end
        if flyConnection then
            flyConnection:Disconnect()
            flyConnection = nil
        end
    end
end

-- Speed Hack
local originalWalkSpeed
local function SpeedHack()
    if not RAGE.Authenticated then return end
    
    local character = LocalPlayer.Character
    if character and character:FindFirstChild("Humanoid") then
        if RAGE.Features.Speed then
            if not originalWalkSpeed then
                originalWalkSpeed = character.Humanoid.WalkSpeed
            end
            character.Humanoid.WalkSpeed = RAGE.Features.SpeedValue
        elseif originalWalkSpeed then
            character.Humanoid.WalkSpeed = originalWalkSpeed
        end
    end
end

-- Noclip
local noclipConnection
local function Noclip()
    if not RAGE.Authenticated then return end
    
    if RAGE.Features.Noclip then
        if not noclipConnection then
            noclipConnection = RunService.Stepped:Connect(function()
                local character = LocalPlayer.Character
                if character then
                    for _, part in pairs(character:GetDescendants()) do
                        if part:IsA("BasePart") then
                            part.CanCollide = false
                        end
                    end
                end
            end)
        end
    elseif noclipConnection then
        noclipConnection:Disconnect()
        noclipConnection = nil
    end
end

-- ESP
local espObjects = {}
local function ESP()
    if not RAGE.Authenticated then return end
    
    if RAGE.Features.ESP then
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character and not espObjects[player] then
                local highlight = Instance.new("Highlight")
                highlight.FillColor = Color3.fromRGB(255, 50, 50)
                highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                highlight.FillTransparency = 0.7
                highlight.Parent = player.Character
                espObjects[player] = highlight
            end
        end
    else
        for player, highlight in pairs(espObjects) do
            if highlight then highlight:Destroy() end
        end
        espObjects = {}
    end
end

-- ИСПРАВЛЕННЫЙ AIMBOT
local aimbotConnection
local aimbotCircle

local function Aimbot()
    if not RAGE.Authenticated then return end
    
    if RAGE.Features.Aimbot then
        -- Создаем FOV круг
        if not aimbotCircle then
            aimbotCircle = Instance.new("Frame")
            aimbotCircle.Size = UDim2.new(0, RAGE.Aimbot.FOV * 2, 0, RAGE.Aimbot.FOV * 2)
            aimbotCircle.Position = UDim2.new(0.5, -RAGE.Aimbot.FOV, 0.5, -RAGE.Aimbot.FOV)
            aimbotCircle.BackgroundColor3 = Colors.Accent
            aimbotCircle.BackgroundTransparency = 0.8
            aimbotCircle.BorderSizePixel = 0
            aimbotCircle.ZIndex = 500
            aimbotCircle.Parent = ScreenGui
            
            local circleCorner = Instance.new("UICorner")
            circleCorner.CornerRadius = UDim.new(1, 0)
            circleCorner.Parent = aimbotCircle
        end
        
        aimbotCircle.Visible = true
        aimbotCircle.Size = UDim2.new(0, RAGE.Aimbot.FOV * 2, 0, RAGE.Aimbot.FOV * 2)
        aimbotCircle.Position = UDim2.new(0.5, -RAGE.Aimbot.FOV, 0.5, -RAGE.Aimbot.FOV)
        
        if not aimbotConnection then
            aimbotConnection = RunService.Heartbeat:Connect(function()
                local closestPlayer = nil
                local closestDistance = RAGE.Aimbot.FOV
                local mousePos = UserInputService:GetMouseLocation()
                
                for _, player in pairs(Players:GetPlayers()) do
                    if player ~= LocalPlayer and player.Character then
                        local humanoid = player.Character:FindFirstChild("Humanoid")
                        local rootPart = player.Character:FindFirstChild("HumanoidRootPart")
                        
                        if humanoid and humanoid.Health > 0 and rootPart then
                            local screenPoint, onScreen = Camera:WorldToViewportPoint(rootPart.Position)
                            
                            if onScreen then
                                local distance = (Vector2.new(screenPoint.X, screenPoint.Y) - mousePos).Magnitude
                                
                                if distance < closestDistance then
                                    closestDistance = distance
                                    closestPlayer = player
                                end
                            end
                        end
                    end
                end
                
                -- Автоприцеливание при зажатии правой кнопки
                if closestPlayer and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
                    local targetRoot = closestPlayer.Character:FindFirstChild("HumanoidRootPart")
                    if targetRoot then
                        local currentCFrame = Camera.CFrame
                        local targetPosition = targetRoot.Position + Vector3.new(0, 2, 0)
                        local newCFrame = CFrame.lookAt(currentCFrame.Position, targetPosition)
                        Camera.CFrame = newCFrame:Lerp(newCFrame, 0.7)
                    end
                end
            end)
        end
    else
        if aimbotConnection then
            aimbotConnection:Disconnect()
            aimbotConnection = nil
        end
        if aimbotCircle then
            aimbotCircle.Visible = false
        end
    end
end

-- Основной цикл
RunService.Heartbeat:Connect(function()
    if RAGE.Authenticated then
        FlyHack()
        SpeedHack()
        Noclip()
        ESP()
        Aimbot()
    end
end)

warn("[⚡] RAGE MOD NeverLose Style Loaded!")
