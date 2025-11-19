-- NeverLose стиль GUI с перемещением
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/Neverlosecc/Source/main/Source.lua"))()
local Window = Library:Window({
    Title = "ExpensiveMods | RUZT Alpha 2.9.7",
    Center = true,
    AutoShow = false, -- Сначала скрыто
    TabPadding = 10,
    MenuFadeTime = 0.2
})

-- Скрыть/показать по Insert
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.KeyCode == Enum.KeyCode.Insert then
        Library:Toggle()
    end
end)

-- Функция перемещения GUI
local function MakeDraggable(gui)
    local dragging = false
    local dragInput, dragStart, startPos
    
    gui.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = gui.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    
    gui.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            gui.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

-- Применить перемещение к главному GUI
MakeDraggable(Library.Interface)

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
local mouse = LocalPlayer:GetMouse()

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
            
            if closestPlayer and closestPlayer.Character and closestPlayer.Character:FindFirstChild("HumanoidRootPart") then
                local targetPos = closestPlayer.Character.HumanoidRootPart.Position
                local currentPos = workspace.CurrentCamera.CFrame.Position
                local smooth = math.max(aimbotSmoothness.Value / 10, 0.1)
                
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
    if speedEnabled.Value and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.WalkSpeed = 16 * speedValue.Value
    elseif LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
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

-- Спаммер сообщений
spammerEnabled:OnChanged(function()
    if spammerEnabled.Value then
        local chatEvent = game:GetService("ReplicatedStorage"):FindFirstChild("DefaultChatSystemChatEvents")
        if chatEvent then
            local sayMessage = chatEvent:FindFirstChild("SayMessageRequest")
            if sayMessage then
                _G.SpamActive = true
                
                local messages = {
                    "тэгэ expensivemods чит",
                    "т3г3 expensivemods читаем", 
                    "tege expensivemods читаем",
                    "тэгэ expensivemods читаем",
                    "т3г3 expensivemods читаем",
                    "tege expensivemods читаем"
                }
                
                spawn(function()
                    while _G.SpamActive do
                        local randomMsg = messages[math.random(1, #messages)]
                        sayMessage:FireServer(randomMsg, "All")
                        wait(math.random(30, 40))
                    end
                end)
            end
        end
    else
        _G.SpamActive = false
    end
end)

-- Уведомление о загрузке
Library:Notify("ExpensiveMods loaded! | Press INSERT to open/close menu")

-- Проблемы с инжектом обычно возникают из-за:
-- 1. Античита игры - используйте другой исполнитель
-- 2. Блокировка ссылок - попробуйте другую библиотеку GUI
-- 3. Ошибки синтаксиса - проверьте версию исполнителя

-- Альтернативная библиотека если не работает NeverLose:
-- loadstring(game:HttpGet("https://raw.githubusercontent.com/bloodball/-back-ups-for-libs/main/0x"))()
