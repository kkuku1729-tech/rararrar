-- NeverLose стиль GUI
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/Neverlosecc/Source/main/Source.lua"))()
local Window = Library:Window({
    Title = "ExpensiveMods | RUZT Alpha 2.9.7",
    Center = true,
    AutoShow = true,
    TabPadding = 10,
    MenuFadeTime = 0.2
})

-- Основные вкладки
local CombatTab = Window:Tab("Combat")
local MovementTab = Window:Tab("Movement")
local VisualsTab = Window:Tab("Visuals")
local MiscTab = Window:Tab("Misc")

-- Аимбот
local AimingSection = CombatTab:Section("Aimbot")
local aimbotEnabled = AimingSection:Toggle("Enable Aimbot", false)
local aimbotFOV = AimingSection:Slider("FOV", 1, 300, 50, function(value)
    _G.AimbotFOV = value
end)
local aimbotSmoothness = AimingSection:Slider("Smoothness", 1, 30, 10)

-- ESP
local ESPSection = VisualsTab:Section("ESP")
local espEnabled = ESPSection:Toggle("Enable ESP", false)
local espBoxes = ESPSection:Toggle("2D Boxes", false)
local espDistance = ESPSection:Slider("Max Distance", 50, 1000, 200)
local espColor = ESPSection:ColorPicker("ESP Color", Color3.fromRGB(255, 0, 0))

-- Движение
local MovementSection = MovementTab:Section("Movement")
local flyEnabled = MovementSection:Toggle("Fly Hack", false)
local flySpeed = MovementSection:Slider("Fly Speed", 1, 200, 50)
local speedEnabled = MovementSection:Toggle("Speed Hack", false)
local speedValue = MovementSection:Slider("Speed Multiplier", 1, 10, 3)
local noclipEnabled = MovementSection:Toggle("Noclip", false)

-- Рассыльщик
local SpammerSection = MiscTab:Section("Spammer")
local spammerEnabled = SpammerSection:Toggle("Enable Spammer", false)

-- Аимбот логика
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")

aimbotEnabled:OnChanged(function()
    if aimbotEnabled.Value then
        _G.AimbotConnection = RunService.Heartbeat:Connect(function()
            local closestPlayer = nil
            local shortestDistance = _G.AimbotFOV or 50
            
            for _, player in pairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                    local character = player.Character
                    local screenPoint, visible = workspace.CurrentCamera:WorldToViewportPoint(character.HumanoidRootPart.Position)
                    local distance = (Vector2.new(screenPoint.X, screenPoint.Y) - Vector2.new(mouse.X, mouse.Y)).Magnitude
                    
                    if distance < shortestDistance and visible then
                        closestPlayer = player
                        shortestDistance = distance
                    end
                end
            end
            
            if closestPlayer then
                local targetPos = closestPlayer.Character.HumanoidRootPart.Position
                local currentPos = workspace.CurrentCamera.CFrame.Position
                local smooth = aimbotSmoothness.Value / 10
                
                workspace.CurrentCamera.CFrame = workspace.CurrentCamera.CFrame:Lerp(
                    CFrame.lookAt(currentPos, targetPos),
                    1/smooth
                )
            end
        end)
    else
        if _G.AimbotConnection then
            _G.AimbotConnection:Disconnect()
        end
    end
end)

-- Fly Hack
flyEnabled:OnChanged(function()
    if flyEnabled.Value then
        local bodyVelocity = Instance.new("BodyVelocity")
        bodyVelocity.Velocity = Vector3.new(0, 0, 0)
        bodyVelocity.MaxForce = Vector3.new(4000, 4000, 4000)
        bodyVelocity.Parent = LocalPlayer.Character.HumanoidRootPart
        
        _G.FlyConnection = RunService.Heartbeat:Connect(function()
            local root = LocalPlayer.Character.HumanoidRootPart
            local newVelocity = Vector3.new(0, 0, 0)
            
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                newVelocity = newVelocity + workspace.CurrentCamera.CFrame.LookVector * flySpeed.Value
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                newVelocity = newVelocity - workspace.CurrentCamera.CFrame.LookVector * flySpeed.Value
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                newVelocity = newVelocity - workspace.CurrentCamera.CFrame.RightVector * flySpeed.Value
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                newVelocity = newVelocity + workspace.CurrentCamera.CFrame.RightVector * flySpeed.Value
            end
            
            bodyVelocity.Velocity = newVelocity
        end)
    else
        if _G.FlyConnection then
            _G.FlyConnection:Disconnect()
        end
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local bv = LocalPlayer.Character.HumanoidRootPart:FindFirstChild("BodyVelocity")
            if bv then bv:Destroy() end
        end
    end
end)

-- Speed Hack
speedEnabled:OnChanged(function()
    if speedEnabled.Value then
        LocalPlayer.Character.Humanoid.WalkSpeed = 16 * speedValue.Value
    else
        LocalPlayer.Character.Humanoid.WalkSpeed = 16
    end
end)

-- Noclip
noclipEnabled:OnChanged(function()
    if noclipEnabled.Value then
        _G.NoclipConnection = RunService.Stepped:Connect(function()
            if LocalPlayer.Character then
                for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                    end
                end
            end
        end)
    else
        if _G.NoclipConnection then
            _G.NoclipConnection:Disconnect()
        end
    end
end)

-- ESP
espEnabled:OnChanged(function()
    if espEnabled.Value then
        _G.ESPConnection = RunService.Heartbeat:Connect(function()
            for _, player in pairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and player.Character then
                    -- Логика ESP с боксами
                    -- (упрощенная реализация)
                end
            end
        end)
    else
        if _G.ESPConnection then
            _G.ESPConnection:Disconnect()
        end
    end
end)

-- Спаммер сообщений
spammerEnabled:OnChanged(function()
    if spammerEnabled.Value then
        _G.SpamConnection = game:GetService("ReplicatedStorage").DefaultChatSystemChatEvents.SayMessageRequest
        
        local messages = {
            "тэгэ expensivemods чит",
            "т3г3 expensivemods читаем",
            "tege expensivemods читаем",
            "тэгэ expensivemods читаем",
            "т3г3 expensivemods читаем",
            "tege expensivemods читаем"
        }
        
        _G.SpamTimer = tick()
        _G.SpamActive = true
        
        while _G.SpamActive do
            if tick() - _G.SpamTimer > 35 then
                local randomMsg = messages[math.random(1, #messages)]
                _G.SpamConnection:FireServer(randomMsg, "All")
                _G.SpamTimer = tick()
            end
            wait(1)
        end
    else
        _G.SpamActive = false
    end
end)

Library:Notify("ExpensiveMods loaded! | RUZT Alpha 2.9.7")
