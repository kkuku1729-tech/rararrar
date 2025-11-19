-- RAGE MOD V1.01.02 - NeverLose Style
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer

-- KeyAuth
local KeyAuth = {
    api = {
        name = "RAGEMod",
        ownerid = "your_ownerid_here",
        version = "1.0",
        url = "https://keyauth.win/api/1.2/"
    },
    initialized = false,
    sessionid = ""
}

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

KeyAuth:init()

-- NeverLose Colors
local Colors = {
    Background = Color3.fromRGB(18, 18, 24),
    Primary = Color3.fromRGB(30, 30, 40),
    Accent = Color3.fromRGB(90, 120, 255),
    Text = Color3.fromRGB(240, 240, 245),
    Success = Color3.fromRGB(80, 220, 120),
    Error = Color3.fromRGB(220, 80, 80)
}

-- State
local RAGE = {
    Authenticated = false,
    MenuOpen = false,
    Features = {
        Fly = false,
        Speed = false,
        SpeedValue = 50,
        Aimbot = true, -- Always on by default
        Noclip = false,
        ESP = false
    },
    Aimbot = {
        FOV = 80,
        Target = nil,
        Smoothness = 0.7
    }
}

-- UI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "RAGEMod"
ScreenGui.Parent = game.CoreGui

-- Auth Window (NeverLose Style)
local AuthFrame = Instance.new("Frame")
AuthFrame.Size = UDim2.new(0, 320, 0, 200)
AuthFrame.Position = UDim2.new(0.5, -160, 0.5, -100)
AuthFrame.BackgroundColor3 = Colors.Background
AuthFrame.Visible = true
AuthFrame.Parent = ScreenGui

local AuthStroke = Instance.new("UIStroke")
AuthStroke.Color = Colors.Primary
AuthStroke.Thickness = 1
AuthStroke.Parent = AuthFrame

local AuthTitle = Instance.new("TextLabel")
AuthTitle.Size = UDim2.new(1, 0, 0, 40)
AuthTitle.BackgroundColor3 = Colors.Primary
AuthTitle.Text = "RAGE MOD"
AuthTitle.TextColor3 = Colors.Accent
AuthTitle.TextSize = 16
AuthTitle.Font = Enum.Font.GothamBold
AuthTitle.Parent = AuthFrame

local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(0.8, 0, 0, 20)
StatusLabel.Position = UDim2.new(0.1, 0, 0.2, 0)
StatusLabel.BackgroundTransparency = 1
StatusLabel.TextColor3 = KeyAuth.initialized and Colors.Success or Colors.Error
StatusLabel.Text = KeyAuth.initialized and "KEYAUTH CONNECTED" : "KEYAUTH ERROR"
StatusLabel.TextSize = 12
StatusLabel.Font = Enum.Font.Gotham
StatusLabel.Parent = AuthFrame

local KeyInput = Instance.new("TextBox")
KeyInput.Size = UDim2.new(0.8, 0, 0, 35)
KeyInput.Position = UDim2.new(0.1, 0, 0.4, 0)
KeyInput.BackgroundColor3 = Colors.Primary
KeyInput.TextColor3 = Colors.Text
KeyInput.PlaceholderText = "Enter license key..."
KeyInput.Text = ""
KeyInput.TextSize = 14
KeyInput.Font = Enum.Font.Gotham
KeyInput.Parent = AuthFrame

local LoginButton = Instance.new("TextButton")
LoginButton.Size = UDim2.new(0.8, 0, 0, 35)
LoginButton.Position = UDim2.new(0.1, 0, 0.7, 0)
LoginButton.BackgroundColor3 = Colors.Accent
LoginButton.TextColor3 = Colors.Text
LoginButton.Text = "ACTIVATE"
LoginButton.TextSize = 14
LoginButton.Font = Enum.Font.GothamBold
LoginButton.Parent = AuthFrame

-- Circle Button (NeverLose Style)
local CircleButton = Instance.new("TextButton")
CircleButton.Size = UDim2.new(0, 42, 0, 42)
CircleButton.Position = UDim2.new(0, 30, 0, 30)
CircleButton.BackgroundColor3 = Colors.Accent
CircleButton.BackgroundTransparency = 0.1
CircleButton.Text = "⚡"
CircleButton.TextColor3 = Colors.Text
CircleButton.TextSize = 16
CircleButton.Visible = false
CircleButton.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(1, 0)
UICorner.Parent = CircleButton

local CircleStroke = Instance.new("UIStroke")
CircleStroke.Color = Colors.Accent
CircleStroke.Thickness = 1.5
CircleStroke.Parent = CircleButton

-- Main Menu (NeverLose Style)
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 280, 0, 350)
MainFrame.Position = UDim2.new(0.5, -140, 0.5, -175)
MainFrame.BackgroundColor3 = Colors.Background
MainFrame.Visible = false
MainFrame.Parent = ScreenGui

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Colors.Primary
MainStroke.Thickness = 1
MainStroke.Parent = MainFrame

local MainTitle = Instance.new("TextLabel")
MainTitle.Size = UDim2.new(1, 0, 0, 35)
MainTitle.BackgroundColor3 = Colors.Primary
MainTitle.Text = "RAGE MOD"
MainTitle.TextColor3 = Colors.Accent
MainTitle.TextSize = 14
MainTitle.Font = Enum.Font.GothamBold
MainTitle.Parent = MainFrame

local ScrollingFrame = Instance.new("ScrollingFrame")
ScrollingFrame.Size = UDim2.new(1, -10, 1, -45)
ScrollingFrame.Position = UDim2.new(0, 5, 0, 40)
ScrollingFrame.BackgroundTransparency = 1
ScrollingFrame.ScrollBarThickness = 2
ScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 400)
ScrollingFrame.Parent = MainFrame

-- Toggle Function (NeverLose Style)
local function CreateToggle(name, feature, yPosition)
    local ToggleFrame = Instance.new("Frame")
    ToggleFrame.Size = UDim2.new(1, 0, 0, 30)
    ToggleFrame.Position = UDim2.new(0, 0, 0, yPosition)
    ToggleFrame.BackgroundTransparency = 1
    ToggleFrame.Parent = ScrollingFrame
    
    local ToggleLabel = Instance.new("TextLabel")
    ToggleLabel.Size = UDim2.new(0.7, 0, 1, 0)
    ToggleLabel.BackgroundTransparency = 1
    ToggleLabel.Text = name
    ToggleLabel.TextColor3 = Colors.Text
    ToggleLabel.TextSize = 13
    ToggleLabel.TextXAlignment = Enum.TextXAlignment.Left
    ToggleLabel.Font = Enum.Font.Gotham
    ToggleLabel.Parent = ToggleFrame
    
    local ToggleButton = Instance.new("TextButton")
    ToggleButton.Size = UDim2.new(0, 40, 0, 20)
    ToggleButton.Position = UDim2.new(0.75, 0, 0.5, -10)
    ToggleButton.BackgroundColor3 = Colors.Primary
    ToggleButton.Text = ""
    ToggleButton.Parent = ToggleFrame
    
    local ToggleCircle = Instance.new("Frame")
    ToggleCircle.Size = UDim2.new(0, 16, 0, 16)
    ToggleCircle.Position = UDim2.new(0, 2, 0.5, -8)
    ToggleCircle.BackgroundColor3 = Colors.Text
    ToggleCircle.Parent = ToggleButton
    
    local CircleCorner = Instance.new("UICorner")
    CircleCorner.CornerRadius = UDim.new(1, 0)
    CircleCorner.Parent = ToggleCircle
    
    -- Set initial state for Aimbot (always on)
    if feature == "Aimbot" then
        ToggleCircle.Position = UDim2.new(0, 22, 0.5, -8)
        ToggleButton.BackgroundColor3 = Colors.Accent
    end
    
    ToggleButton.MouseButton1Click:Connect(function()
        if not RAGE.Authenticated then return end
        RAGE.Features[feature] = not RAGE.Features[feature]
        if RAGE.Features[feature] then
            ToggleCircle.Position = UDim2.new(0, 22, 0.5, -8)
            ToggleButton.BackgroundColor3 = Colors.Accent
        else
            ToggleCircle.Position = UDim2.new(0, 2, 0.5, -8)
            ToggleButton.BackgroundColor3 = Colors.Primary
        end
    end)
end

-- Slider Function
local function CreateSlider(name, minVal, maxVal, defaultVal, callback, yPosition)
    local SliderFrame = Instance.new("Frame")
    SliderFrame.Size = UDim2.new(1, 0, 0, 45)
    SliderFrame.Position = UDim2.new(0, 0, 0, yPosition)
    SliderFrame.BackgroundTransparency = 1
    SliderFrame.Parent = ScrollingFrame
    
    local SliderLabel = Instance.new("TextLabel")
    SliderLabel.Size = UDim2.new(1, 0, 0, 20)
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
    
    local SliderFill = Instance.new("Frame")
    SliderFill.Size = UDim2.new((defaultVal - minVal) / (maxVal - minVal), 0, 1, 0)
    SliderFill.BackgroundColor3 = Colors.Accent
    SliderFill.Parent = SliderTrack
    
    local SliderButton = Instance.new("TextButton")
    SliderButton.Size = UDim2.new(0, 14, 0, 14)
    SliderButton.Position = UDim2.new((defaultVal - minVal) / (maxVal - minVal), -7, 0.5, -7)
    SliderButton.BackgroundColor3 = Colors.Text
    SliderButton.Text = ""
    SliderButton.Parent = SliderTrack
    
    local dragging = false
    
    local function updateSlider(input)
        local pos = UDim2.new(math.clamp((input.Position.X - SliderTrack.AbsolutePosition.X) / SliderTrack.AbsoluteSize.X, 0, 1), -7, 0.5, -7)
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
end

-- Create UI Elements
CreateToggle("FLY", "Fly", 0)
CreateToggle("SPEED", "Speed", 35)
CreateToggle("AIMBOT", "Aimbot", 70)
CreateToggle("NOCLIP", "Noclip", 105)
CreateToggle("ESP", "ESP", 140)

CreateSlider("SPEED", 16, 100, 50, function(value)
    RAGE.Features.SpeedValue = value
end, 175)

CreateSlider("FOV", 10, 300, 80, function(value)
    RAGE.Aimbot.FOV = value
end, 230)

-- Authentication
local function Authenticate()
    local key = KeyInput.Text
    if key == "" then return end
    
    if KeyAuth:license(key) then
        RAGE.Authenticated = true
        AuthFrame.Visible = false
        CircleButton.Visible = true
    end
end

LoginButton.MouseButton1Click:Connect(Authenticate)
KeyInput.FocusLost:Connect(function(enterPressed)
    if enterPressed then Authenticate() end
end)

-- Menu Toggle
CircleButton.MouseButton1Click:Connect(function()
    if not RAGE.Authenticated then return end
    RAGE.MenuOpen = not RAGE.MenuOpen
    MainFrame.Visible = RAGE.MenuOpen
end)

-- Fly Hack
local flyBodyVelocity
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
            
            local moveDirection = Vector3.new(0, 0, 0)
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                moveDirection = moveDirection + Camera.CFrame.LookVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                moveDirection = moveDirection - Camera.CFrame.LookVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                moveDirection = moveDirection - Camera.CFrame.RightVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                moveDirection = moveDirection + Camera.CFrame.RightVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                moveDirection = moveDirection + Vector3.new(0, 1, 0)
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
                moveDirection = moveDirection - Vector3.new(0, 1, 0)
            end
            
            flyBodyVelocity.Velocity = moveDirection * 100
        end
    elseif flyBodyVelocity then
        flyBodyVelocity:Destroy()
        flyBodyVelocity = nil
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

-- Aimbot (Always Active)
local aimbotConnection
local aimbotCircle
local function Aimbot()
    if not RAGE.Authenticated then return end
    
    if RAGE.Features.Aimbot then
        -- FOV Circle
        if not aimbotCircle then
            aimbotCircle = Instance.new("Frame")
            aimbotCircle.Size = UDim2.new(0, RAGE.Aimbot.FOV * 2, 0, RAGE.Aimbot.FOV * 2)
            aimbotCircle.Position = UDim2.new(0.5, -RAGE.Aimbot.FOV, 0.5, -RAGE.Aimbot.FOV)
            aimbotCircle.BackgroundColor3 = Colors.Accent
            aimbotCircle.BackgroundTransparency = 0.8
            aimbotCircle.BorderSizePixel = 0
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
                
                for _, player in pairs(Players:GetPlayers()) do
                    if player ~= LocalPlayer and player.Character then
                        local humanoid = player.Character:FindFirstChild("Humanoid")
                        local rootPart = player.Character:FindFirstChild("HumanoidRootPart")
                        
                        if humanoid and humanoid.Health > 0 and rootPart then
                            local screenPoint, onScreen = Camera:WorldToViewportPoint(rootPart.Position)
                            
                            if onScreen then
                                local mousePos = UserInputService:GetMouseLocation()
                                local distance = (Vector2.new(screenPoint.X, screenPoint.Y) - mousePos).Magnitude
                                
                                if distance < closestDistance then
                                    closestDistance = distance
                                    closestPlayer = player
                                end
                            end
                        end
                    end
                end
                
                -- Always aim at closest target
                if closestPlayer then
                    local targetRoot = closestPlayer.Character:FindFirstChild("HumanoidRootPart")
                    if targetRoot then
                        local targetPosition = targetRoot.Position + Vector3.new(0, 2, 0)
                        local currentCFrame = Camera.CFrame
                        local newCFrame = CFrame.lookAt(currentCFrame.Position, targetPosition)
                        Camera.CFrame = newCFrame:Lerp(newCFrame, RAGE.Aimbot.Smoothness)
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

-- Main Loop
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
