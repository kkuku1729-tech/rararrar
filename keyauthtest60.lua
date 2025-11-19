-- RAGE MOD V1.01.02 - KeyAuth Version
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local HttpService = game:GetService("HttpService")

-- Real KeyAuth Integration
local KeyAuth = {
    api = {
        name = "ruztsoft",
        ownerid = "Q2uvPey1OB", -- ЗАМЕНИ НА СВОЙ OWNER_ID
        version = "1.0",
        url = "https://keyauth.win/api/1.2/"
    },
    initialized = false,
    sessionid = ""
}

-- Инициализация KeyAuth
function KeyAuth:init()
    local success, result = pcall(function()
        local req = self:apiReq("?type=init&name=" .. self.api.name .. "&ownerid=" .. self.api.ownerid .. "&version=" .. self.api.version)
        local data = HttpService:JSONDecode(req)
        
        if data["success"] then
            self.sessionid = data["sessionid"]
            self.initialized = true
            return true
        else
            return false, data["message"]
        end
    end)
    
    if success then
        return result
    else
        return false, "Connection failed"
    end
end

-- HTTP запросы
function KeyAuth:apiReq(endpoint)
    local response
    local success, result = pcall(function()
        return game:HttpGet(self.api.url .. endpoint, true)
    end)
    
    if success and result then
        return result
    else
        return '{"success":false,"message":"Connection failed"}'
    end
end

-- Проверка лицензии
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

-- Логирование
function KeyAuth:log(message)
    if not self.initialized then return false end
    
    pcall(function()
        local postdata = "type=log&sessionid=" .. self.sessionid .. "&name=" .. self.api.name .. "&ownerid=" .. self.api.ownerid .. "&pcuser=" .. LocalPlayer.Name .. "&message=" .. message
        self:apiReq("?" .. postdata)
    end)
end

-- Инициализируем KeyAuth
local authSuccess, authMessage = KeyAuth:init()
if authSuccess then
    warn("[KeyAuth] Initialized successfully")
else
    warn("[KeyAuth] Init failed: " .. tostring(authMessage))
end

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
        FOV = 50,
        Target = nil
    }
}

-- Создание UI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "RAGEMod"
ScreenGui.Parent = game.CoreGui

-- Окно аутентификации
local AuthFrame = Instance.new("Frame")
AuthFrame.Size = UDim2.new(0, 350, 0, 250)
AuthFrame.Position = UDim2.new(0.5, -175, 0.5, -125)
AuthFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
AuthFrame.BorderSizePixel = 0
AuthFrame.Visible = true
AuthFrame.Parent = ScreenGui

local AuthCorner = Instance.new("UICorner")
AuthCorner.CornerRadius = UDim.new(0, 12)
AuthCorner.Parent = AuthFrame

local AuthStroke = Instance.new("UIStroke")
AuthStroke.Color = Color3.fromRGB(255, 0, 0)
AuthStroke.Thickness = 2
AuthStroke.Parent = AuthFrame

local AuthTitle = Instance.new("TextLabel")
AuthTitle.Size = UDim2.new(1, 0, 0, 50)
AuthTitle.Position = UDim2.new(0, 0, 0, 0)
AuthTitle.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
AuthTitle.Text = "🔐 RAGE MOD - KEY AUTH"
AuthTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
AuthTitle.TextSize = 18
AuthTitle.Font = Enum.Font.GothamBold
AuthTitle.Parent = AuthFrame

local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(0.8, 0, 0, 20)
StatusLabel.Position = UDim2.new(0.1, 0, 0.2, 0)
StatusLabel.BackgroundTransparency = 1
StatusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
StatusLabel.Text = KeyAuth.initialized and "KeyAuth: Подключено ✅" or "KeyAuth: Ошибка ❌"
StatusLabel.TextSize = 12
StatusLabel.Font = Enum.Font.Gotham
StatusLabel.Parent = AuthFrame

local KeyInput = Instance.new("TextBox")
KeyInput.Size = UDim2.new(0.8, 0, 0, 40)
KeyInput.Position = UDim2.new(0.1, 0, 0.4, 0)
KeyInput.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
KeyInput.TextColor3 = Color3.fromRGB(255, 255, 255)
KeyInput.PlaceholderText = "Введите лицензионный ключ..."
KeyInput.Text = ""
KeyInput.TextSize = 14
KeyInput.Font = Enum.Font.Gotham
KeyInput.Parent = AuthFrame

local LoginButton = Instance.new("TextButton")
LoginButton.Size = UDim2.new(0.8, 0, 0, 40)
LoginButton.Position = UDim2.new(0.1, 0, 0.65, 0)
LoginButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
LoginButton.TextColor3 = Color3.fromRGB(255, 255, 255)
LoginButton.Text = "🔓 АКТИВИРОВАТЬ"
LoginButton.TextSize = 14
LoginButton.Font = Enum.Font.GothamBold
LoginButton.Parent = AuthFrame

-- Кружок меню
local CircleButton = Instance.new("TextButton")
CircleButton.Size = UDim2.new(0, 40, 0, 40)
CircleButton.Position = UDim2.new(0, 50, 0, 50)
CircleButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
CircleButton.BackgroundTransparency = 0.2
CircleButton.Text = "⚡"
CircleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CircleButton.TextSize = 18
CircleButton.Visible = false
CircleButton.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(1, 0)
UICorner.Parent = CircleButton

-- Главное меню
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 300, 0, 400)
MainFrame.Position = UDim2.new(0.5, -150, 0.5, -200)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainFrame.BorderSizePixel = 0
MainFrame.Visible = false
MainFrame.Parent = ScreenGui

local MainTitle = Instance.new("TextLabel")
MainTitle.Size = UDim2.new(1, 0, 0, 40)
MainTitle.Position = UDim2.new(0, 0, 0, 0)
MainTitle.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
MainTitle.Text = "RAGE MOD - RUZT"
MainTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
MainTitle.TextSize = 16
MainTitle.Font = Enum.Font.GothamBold
MainTitle.Parent = MainFrame

-- Контейнер для кнопок
local ScrollingFrame = Instance.new("ScrollingFrame")
ScrollingFrame.Size = UDim2.new(1, -10, 1, -50)
ScrollingFrame.Position = UDim2.new(0, 5, 0, 45)
ScrollingFrame.BackgroundTransparency = 1
ScrollingFrame.ScrollBarThickness = 3
ScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 300)
ScrollingFrame.Parent = MainFrame

-- Функция создания кнопок
local function CreateToggle(name, feature, yPosition)
    local ToggleFrame = Instance.new("Frame")
    ToggleFrame.Size = UDim2.new(1, 0, 0, 35)
    ToggleFrame.Position = UDim2.new(0, 0, 0, yPosition)
    ToggleFrame.BackgroundTransparency = 1
    ToggleFrame.Parent = ScrollingFrame
    
    local ToggleLabel = Instance.new("TextLabel")
    ToggleLabel.Size = UDim2.new(0.7, 0, 1, 0)
    ToggleLabel.Position = UDim2.new(0, 0, 0, 0)
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
    
    return ToggleFrame
end

-- Создаем кнопки
local yPos = 0
CreateToggle("Fly Hack", "Fly", yPos); yPos = yPos + 40
CreateToggle("Speed Hack", "Speed", yPos); yPos = yPos + 40
CreateToggle("Aimbot", "Aimbot", yPos); yPos = yPos + 40
CreateToggle("Noclip", "Noclip", yPos); yPos = yPos + 40
CreateToggle("ESP", "ESP", yPos); yPos = yPos + 40

-- Обновляем размер контента
ScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, yPos)

-- Аутентификация с KeyAuth
local function Authenticate()
    local key = KeyInput.Text:gsub("%s+", "")
    if key == "" then 
        StatusLabel.TextColor3 = Color3.fromRGB(255, 50, 50)
        StatusLabel.Text = "Введите ключ!"
        return 
    end
    
    if not KeyAuth.initialized then
        StatusLabel.TextColor3 = Color3.fromRGB(255, 50, 50)
        StatusLabel.Text = "KeyAuth не инициализирован!"
        return
    end
    
    StatusLabel.TextColor3 = Color3.fromRGB(255, 255, 100)
    StatusLabel.Text = "Проверка ключа..."
    LoginButton.Text = "⏳ ПРОВЕРКА..."
    
    wait(1)
    
    local success = KeyAuth:license(key)
    
    if success then
        RAGE.Authenticated = true
        AuthFrame.Visible = false
        CircleButton.Visible = true
        
        -- Логируем успешный вход
        KeyAuth:log("User authenticated - " .. LocalPlayer.Name)
        
        StatusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
        StatusLabel.Text = "Успешная аутентификация!"
        
        warn("[⚡] KeyAuth: Аутентификация успешна!")
    else
        StatusLabel.TextColor3 = Color3.fromRGB(255, 50, 50)
        StatusLabel.Text = "Неверный ключ!"
        LoginButton.Text = "🔓 АКТИВИРОВАТЬ"
        
        -- Логируем неудачную попытку
        KeyAuth:log("Failed authentication attempt - " .. LocalPlayer.Name)
        
        warn("[⚡] KeyAuth: Ошибка аутентификации!")
    end
end

LoginButton.MouseButton1Click:Connect(Authenticate)
KeyInput.FocusLost:Connect(function(enterPressed)
    if enterPressed then Authenticate() end
end)

-- Открытие/закрытие меню
CircleButton.MouseButton1Click:Connect(function()
    if not RAGE.Authenticated then return end
    RAGE.MenuOpen = not RAGE.MenuOpen
    MainFrame.Visible = RAGE.MenuOpen
end)

-- Функции хаков
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
                flyBodyVelocity.MaxForce = Vector3.new(0, 9.81 * 100, 0)
                flyBodyVelocity.Parent = character.HumanoidRootPart
            end
            
            local newVelocity = Vector3.new(0, 0, 0)
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                newVelocity = Vector3.new(0, 50, 0)
            elseif UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
                newVelocity = Vector3.new(0, -50, 0)
            end
            flyBodyVelocity.Velocity = newVelocity
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
local function Noclip()
    if not RAGE.Authenticated then return end
    
    local character = LocalPlayer.Character
    if character and RAGE.Features.Noclip then
        for _, part in pairs(character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
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
                highlight.FillColor = Color3.fromRGB(255, 0, 0)
                highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                highlight.FillTransparency = 0.5
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
        
        local closestPlayer = nil
        local closestDistance = RAGE.Aimbot.FOV
        local mousePos = UserInputService:GetMouseLocation()
        
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                local rootPart = player.Character:FindFirstChild("HumanoidRootPart")
                if rootPart then
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
                Camera.CFrame = CFrame.lookAt(Camera.CFrame.Position, targetRoot.Position)
            end
        end
    elseif aimbotCircle then
        aimbotCircle:Destroy()
        aimbotCircle = nil
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

warn("[⚡] RAGE MOD with KeyAuth Loaded!")
warn("[⚡] KeyAuth Status: " .. (KeyAuth.initialized and "Connected" or "Disconnected"))
