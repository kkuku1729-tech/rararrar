-- RAGE MOD V1.01.02 - KeyAuth Version
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer

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

-- State
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
        Target = nil
    }
}

-- UI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "RAGEMod"
ScreenGui.Parent = game.CoreGui

-- Auth Window
local AuthFrame = Instance.new("Frame")
AuthFrame.Size = UDim2.new(0, 300, 0, 200)
AuthFrame.Position = UDim2.new(0.5, -150, 0.5, -100)
AuthFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
AuthFrame.Visible = true
AuthFrame.Parent = ScreenGui

local AuthTitle = Instance.new("TextLabel")
AuthTitle.Size = UDim2.new(1, 0, 0, 40)
AuthTitle.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
AuthTitle.Text = "RAGE MOD - AUTH"
AuthTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
AuthTitle.TextSize = 16
AuthTitle.Font = Enum.Font.GothamBold
AuthTitle.Parent = AuthFrame

local KeyInput = Instance.new("TextBox")
KeyInput.Size = UDim2.new(0.8, 0, 0, 35)
KeyInput.Position = UDim2.new(0.1, 0, 0.3, 0)
KeyInput.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
KeyInput.TextColor3 = Color3.fromRGB(255, 255, 255)
KeyInput.PlaceholderText = "Enter key..."
KeyInput.Text = ""
KeyInput.Parent = AuthFrame

local LoginButton = Instance.new("TextButton")
LoginButton.Size = UDim2.new(0.8, 0, 0, 35)
LoginButton.Position = UDim2.new(0.1, 0, 0.6, 0)
LoginButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
LoginButton.TextColor3 = Color3.fromRGB(255, 255, 255)
LoginButton.Text = "ACTIVATE"
LoginButton.Parent = AuthFrame

-- Circle Button
local CircleButton = Instance.new("TextButton")
CircleButton.Size = UDim2.new(0, 40, 0, 40)
CircleButton.Position = UDim2.new(0, 50, 0, 50)
CircleButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
CircleButton.Text = "⚡"
CircleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CircleButton.TextSize = 18
CircleButton.Visible = false
CircleButton.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(1, 0)
UICorner.Parent = CircleButton

-- Main Menu
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 300, 0, 400)
MainFrame.Position = UDim2.new(0.5, -150, 0.5, -200)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainFrame.Visible = false
MainFrame.Parent = ScreenGui

local MainTitle = Instance.new("TextLabel")
MainTitle.Size = UDim2.new(1, 0, 0, 40)
MainTitle.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
MainTitle.Text = "RAGE MOD"
MainTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
MainTitle.TextSize = 16
MainTitle.Font = Enum.Font.GothamBold
MainTitle.Parent = MainFrame

local ScrollingFrame = Instance.new("ScrollingFrame")
ScrollingFrame.Size = UDim2.new(1, -10, 1, -50)
ScrollingFrame.Position = UDim2.new(0, 5, 0, 45)
ScrollingFrame.BackgroundTransparency = 1
ScrollingFrame.ScrollBarThickness = 3
ScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 300)
ScrollingFrame.Parent = MainFrame

-- Toggle Function
local function CreateToggle(name, feature, yPosition)
    local ToggleFrame = Instance.new("Frame")
    ToggleFrame.Size = UDim2.new(1, 0, 0, 35)
    ToggleFrame.Position = UDim2.new(0, 0, 0, yPosition)
    ToggleFrame.BackgroundTransparency = 1
    ToggleFrame.Parent = ScrollingFrame
    
    local ToggleLabel = Instance.new("TextLabel")
    ToggleLabel.Size = UDim2.new(0.7, 0, 1, 0)
    ToggleLabel.BackgroundTransparency = 1
    ToggleLabel.Text = name
    ToggleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    ToggleLabel.TextSize = 14
    ToggleLabel.TextXAlignment = Enum.TextXAlignment.Left
    ToggleLabel.Font = Enum.Font.Gotham
    ToggleLabel.Parent = ToggleFrame
    
    local ToggleButton = Instance.new("TextButton")
    ToggleButton.Size = UDim2.new(0, 45, 0, 22)
    ToggleButton.Position = UDim2.new(0.7, 0, 0.5, -11)
    ToggleButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    ToggleButton.Text = ""
    ToggleButton.Parent = ToggleFrame
    
    local ToggleCircle = Instance.new("Frame")
    ToggleCircle.Size = UDim2.new(0, 18, 0, 18)
    ToggleCircle.Position = UDim2.new(0, 2, 0.5, -9)
    ToggleCircle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    ToggleCircle.Parent = ToggleButton
    
    ToggleButton.MouseButton1Click:Connect(function()
        if not RAGE.Authenticated then return end
        RAGE.Features[feature] = not RAGE.Features[feature]
        if RAGE.Features[feature] then
            ToggleCircle.Position = UDim2.new(0, 25, 0.5, -9)
            ToggleButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
        else
            ToggleCircle.Position = UDim2.new(0, 2, 0.5, -9)
            ToggleButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        end
    end)
end

-- Create Toggles
CreateToggle("Fly Hack", "Fly", 0)
CreateToggle("Speed Hack", "Speed", 40)
CreateToggle("Aimbot", "Aimbot", 80)
CreateToggle("Noclip", "Noclip", 120)
CreateToggle("ESP", "ESP", 160)

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

-- Aimbot
local aimbotConnection
local aimbotCircle
local function Aimbot()
    if not RAGE.Authenticated then return end
    
    if RAGE.Features.Aimbot then
        if not aimbotCircle then
            aimbotCircle = Instance.new("Frame")
            aimbotCircle.Size = UDim2.new(0, RAGE.Aimbot.FOV * 2, 0, RAGE.Aimbot.FOV * 2)
            aimbotCircle.Position = UDim2.new(0.5, -RAGE.Aimbot.FOV, 0.5, -RAGE.Aimbot.FOV)
            aimbotCircle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            aimbotCircle.BackgroundTransparency = 0.8
            aimbotCircle.BorderSizePixel = 0
            aimbotCircle.Parent = ScreenGui
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
                
                if closestPlayer and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
                    local targetRoot = closestPlayer.Character:FindFirstChild("HumanoidRootPart")
                    if targetRoot then
                        local targetPosition = targetRoot.Position + Vector3.new(0, 2, 0)
                        Camera.CFrame = CFrame.lookAt(Camera.CFrame.Position, targetPosition)
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

warn("[⚡] RAGE MOD Loaded! Test Key: RAGE123")
