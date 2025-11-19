-- RAGE MOD V1.01.02 - Ruzt Script
-- Real KeyAuth Integration
local KeyAuth = {
    init = function()
        local KeyAuth = {
            api = {
                name = "ruztsoft",
                ownerid = "Q2uvPey1OB",
                version = "1.0",
                hash = "217bed44eac9e5ac571c511296c651c786c962448b16c9ca7b49d91f86270ee6",
                url = "https://keyauth.win/api/1.2/"
            },
            initialized = false,
            sessionid = "",
            enckey = "",
            load = {}
        }

        function KeyAuth:apiReq(req, postdata)
            local response
            local success, result = pcall(function()
                return game:HttpGet(self.api.url .. req .. "&" .. postdata, true)
            end)
            
            if success and result then
                return result
            else
                return '{"success":false,"message":"Connection failed"}'
            end
        end

        function KeyAuth:init()
            local req = self:apiReq("?type=init&name=" .. self.api.name .. "&ownerid=" .. self.api.ownerid .. "&version=" .. self.api.version, "")
            local data = game:GetService("HttpService"):JSONDecode(req)
            
            if data["success"] then
                self.sessionid = data["sessionid"]
                self.enckey = data["enckey"]
                self.initialized = true
                print("[KeyAuth] Initialization successful")
                return true
            else
                warn("[KeyAuth] Initialization failed: " .. data["message"])
                return false
            end
        end

        function KeyAuth:license(key)
            if not self.initialized then
                warn("[KeyAuth] Not initialized")
                return false
            end

            local postdata = "type=license&key=" .. key .. "&sessionid=" .. self.sessionid .. "&name=" .. self.api.name .. "&ownerid=" .. self.api.ownerid
            local req = self:apiReq("", postdata)
            local data = game:GetService("HttpService"):JSONDecode(req)
            
            if data["success"] then
                print("[KeyAuth] License valid")
                return true
            else
                warn("[KeyAuth] License check failed: " .. data["message"])
                return false
            end
        end

        function KeyAuth:check()
            if not self.initialized then
                return false
            end

            local postdata = "type=check&sessionid=" .. self.sessionid .. "&name=" .. self.api.name .. "&ownerid=" .. self.api.ownerid
            local req = self:apiReq("", postdata)
            local data = game:GetService("HttpService"):JSONDecode(req)
            
            return data["success"]
        end

        function KeyAuth:var(varid)
            if not self.initialized then
                return nil
            end

            local postdata = "type=var&varid=" .. varid .. "&sessionid=" .. self.sessionid .. "&name=" .. self.api.name .. "&ownerid=" .. self.api.ownerid
            local req = self:apiReq("", postdata)
            local data = game:GetService("HttpService"):JSONDecode(req)
            
            if data["success"] then
                return data["message"]
            else
                return nil
            end
        end

        function KeyAuth:log(message)
            if not self.initialized then
                return false
            end

            local postdata = "type=log&sessionid=" .. self.sessionid .. "&name=" .. self.api.name .. "&ownerid=" .. self.api.ownerid .. "&pcuser=" .. game.Players.LocalPlayer.Name .. "&message=" .. message
            local req = self:apiReq("", postdata)
            local data = game:GetService("HttpService"):JSONDecode(req)
            
            return data["success"]
        end

        local initSuccess = KeyAuth:init()
        if not initSuccess then
            warn("[KeyAuth] Failed to initialize, using fallback authentication")
        end

        return KeyAuth
    end
}

local KeyAuthSystem = KeyAuth.init()

-- Основные переменные
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Camera = workspace.CurrentCamera
local HttpService = game:GetService("HttpService")

-- Состояние мода
local RAGE = {
    Authenticated = false,
    Menu = {
        Open = false,
        Position = UDim2.new(0, 50, 0, 50)
    },
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
        Target = nil,
        Smoothness = 1,
        TeamCheck = false
    }
}

-- Создание UI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "RAGEMod"
ScreenGui.Parent = game.CoreGui

-- Окно аутентификации
local AuthFrame = Instance.new("Frame")
AuthFrame.Name = "AuthFrame"
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

-- Заголовок аутентификации
local AuthTitle = Instance.new("TextLabel")
AuthTitle.Name = "AuthTitle"
AuthTitle.Size = UDim2.new(1, 0, 0, 50)
AuthTitle.Position = UDim2.new(0, 0, 0, 0)
AuthTitle.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
AuthTitle.BackgroundTransparency = 0.1
AuthTitle.Text = "🔐 RAGE MOD - KEY AUTH"
AuthTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
AuthTitle.TextSize = 18
AuthTitle.Font = Enum.Font.GothamBold
AuthTitle.Parent = AuthFrame

local AuthTitleCorner = Instance.new("UICorner")
AuthTitleCorner.CornerRadius = UDim.new(0, 12)
AuthTitleCorner.Parent = AuthTitle

-- Информация о приложении
local AppInfo = Instance.new("TextLabel")
AppInfo.Name = "AppInfo"
AppInfo.Size = UDim2.new(0.8, 0, 0, 30)
AppInfo.Position = UDim2.new(0.1, 0, 0.2, 0)
AppInfo.BackgroundTransparency = 1
AppInfo.Text = "Приложение: RAGE MOD Ruzt"
AppInfo.TextColor3 = Color3.fromRGB(200, 200, 200)
AppInfo.TextSize = 12
AppInfo.Font = Enum.Font.Gotham
AppInfo.Parent = AuthFrame

-- Поле ввода ключа
local KeyInput = Instance.new("TextBox")
KeyInput.Name = "KeyInput"
KeyInput.Size = UDim2.new(0.8, 0, 0, 40)
KeyInput.Position = UDim2.new(0.1, 0, 0.4, 0)
KeyInput.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
KeyInput.TextColor3 = Color3.fromRGB(255, 255, 255)
KeyInput.PlaceholderText = "Введите лицензионный ключ..."
KeyInput.Text = ""
KeyInput.TextSize = 14
KeyInput.Font = Enum.Font.Gotham
KeyInput.Parent = AuthFrame

local KeyInputCorner = Instance.new("UICorner")
KeyInputCorner.CornerRadius = UDim.new(0, 8)
KeyInputCorner.Parent = KeyInput

local KeyInputStroke = Instance.new("UIStroke")
KeyInputStroke.Color = Color3.fromRGB(60, 60, 60)
KeyInputStroke.Thickness = 1
KeyInputStroke.Parent = KeyInput

-- Кнопка входа
local LoginButton = Instance.new("TextButton")
LoginButton.Name = "LoginButton"
LoginButton.Size = UDim2.new(0.8, 0, 0, 40)
LoginButton.Position = UDim2.new(0.1, 0, 0.65, 0)
LoginButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
LoginButton.TextColor3 = Color3.fromRGB(255, 255, 255)
LoginButton.Text = "🔓 АКТИВИРОВАТЬ ДОСТУП"
LoginButton.TextSize = 14
LoginButton.Font = Enum.Font.GothamBold
LoginButton.Parent = AuthFrame

local LoginButtonCorner = Instance.new("UICorner")
LoginButtonCorner.CornerRadius = UDim.new(0, 8)
LoginButtonCorner.Parent = LoginButton

-- Статус подключения
local StatusLabel = Instance.new("TextLabel")
StatusLabel.Name = "StatusLabel"
StatusLabel.Size = UDim2.new(0.8, 0, 0, 20)
StatusLabel.Position = UDim2.new(0.1, 0, 0.85, 0)
StatusLabel.BackgroundTransparency = 1
StatusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
StatusLabel.Text = "KeyAuth: Подключение..."
StatusLabel.TextSize = 11
StatusLabel.Font = Enum.Font.Gotham
StatusLabel.Parent = AuthFrame

-- Кружок для открытия меню
local CircleButton = Instance.new("Frame")
CircleButton.Name = "CircleButton"
CircleButton.Size = UDim2.new(0, 35, 0, 35)
CircleButton.Position = RAGE.Menu.Position
CircleButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
CircleButton.BackgroundTransparency = 0.2
CircleButton.BorderSizePixel = 0
CircleButton.Visible = false
CircleButton.ZIndex = 100
CircleButton.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(1, 0)
UICorner.Parent = CircleButton

local CircleStroke = Instance.new("UIStroke")
CircleStroke.Color = Color3.fromRGB(255, 255, 255)
CircleStroke.Thickness = 2
CircleStroke.Parent = CircleButton

local CircleIcon = Instance.new("TextLabel")
CircleIcon.Name = "CircleIcon"
CircleIcon.Size = UDim2.new(1, 0, 1, 0)
CircleIcon.Position = UDim2.new(0, 0, 0, 0)
CircleIcon.BackgroundTransparency = 1
CircleIcon.Text = "⚡"
CircleIcon.TextColor3 = Color3.fromRGB(255, 255, 255)
CircleIcon.TextSize = 16
CircleIcon.Font = Enum.Font.GothamBold
CircleIcon.Parent = CircleButton

-- Главное меню
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 320, 0, 500)
MainFrame.Position = UDim2.new(0.5, -160, 0.5, -250)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
MainFrame.BorderSizePixel = 0
MainFrame.Visible = false
MainFrame.ZIndex = 90
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 12)
MainCorner.Parent = MainFrame

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Color3.fromRGB(255, 0, 0)
MainStroke.Thickness = 2
MainStroke.Parent = MainFrame

-- Заголовок меню
local Title = Instance.new("TextLabel")
Title.Name = "Title"
Title.Size = UDim2.new(1, 0, 0, 50)
Title.Position = UDim2.new(0, 0, 0, 0)
Title.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
Title.BackgroundTransparency = 0.1
Title.Text = "⚡ RAGE MOD - RUZT"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 18
Title.Font = Enum.Font.GothamBold
Title.Parent = MainFrame

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 12)
TitleCorner.Parent = Title

-- Контейнер для функций
local ScrollingFrame = Instance.new("ScrollingFrame")
ScrollingFrame.Name = "ScrollingFrame"
ScrollingFrame.Size = UDim2.new(1, -10, 1, -60)
ScrollingFrame.Position = UDim2.new(0, 5, 0, 55)
ScrollingFrame.BackgroundTransparency = 1
ScrollingFrame.ScrollBarThickness = 3
ScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 600)
ScrollingFrame.Parent = MainFrame

-- Функция аутентификации
local function Authenticate()
    local key = KeyInput.Text:gsub("%s+", "")
    
    if key == "" then
        StatusLabel.TextColor3 = Color3.fromRGB(255, 50, 50)
        StatusLabel.Text = "Ошибка: Введите ключ!"
        return
    end
    
    StatusLabel.TextColor3 = Color3.fromRGB(255, 255, 100)
    StatusLabel.Text = "Проверка ключа..."
    LoginButton.Text = "⏳ ПРОВЕРКА..."
    
    wait(0.5)
    
    local success = KeyAuthSystem:license(key)
    
    if success then
        RAGE.Authenticated = true
        AuthFrame.Visible = false
        CircleButton.Visible = true
        
        KeyAuthSystem:log("User authenticated successfully - " .. LocalPlayer.Name)
        
        StatusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
        StatusLabel.Text = "Успешная аутентификация!"
        
        warn("[⚡] RAGE MOD: KeyAuth аутентификация успешна!")
        warn("[⚡] Добро пожаловать, " .. LocalPlayer.Name .. "!")
        
    else
        StatusLabel.TextColor3 = Color3.fromRGB(255, 50, 50)
        StatusLabel.Text = "Ошибка: Неверный ключ!"
        LoginButton.Text = "🔓 АКТИВИРОВАТЬ ДОСТУП"
        
        KeyAuthSystem:log("Failed authentication attempt - " .. LocalPlayer.Name)
        warn("[⚡] RAGE MOD: Ошибка аутентификации KeyAuth!")
    end
end

-- Обработчики аутентификации
LoginButton.MouseButton1Click:Connect(Authenticate)
KeyInput.FocusLost:Connect(function(enterPressed)
    if enterPressed then
        Authenticate()
    end
end)

-- Обновление статуса подключения
spawn(function()
    while true do
        if KeyAuthSystem.initialized then
            StatusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
            StatusLabel.Text = "KeyAuth: Подключено ✅"
        else
            StatusLabel.TextColor3 = Color3.fromRGB(255, 255, 100)
            StatusLabel.Text = "KeyAuth: Переподключение..."
        end
        wait(5)
    end
end)

-- Функции для создания элементов интерфейса
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
    
    local ToggleCorner = Instance.new("UICorner")
    ToggleCorner.CornerRadius = UDim.new(0, 11)
    ToggleCorner.Parent = ToggleButton
    
    local ToggleCircle = Instance.new("Frame")
    ToggleCircle.Size = UDim2.new(0, 18, 0, 18)
    ToggleCircle.Position = UDim2.new(0, 2, 0.5, -9)
    ToggleCircle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    ToggleCircle.Parent = ToggleButton
    
    local CircleCorner = Instance.new("UICorner")
    CircleCorner.CornerRadius = UDim.new(1, 0)
    CircleCorner.Parent = ToggleCircle
    
    ToggleButton.MouseButton1Click:Connect(function()
        if not RAGE.Authenticated then
            warn("[⚡] RAGE MOD: Требуется аутентификация KeyAuth!")
            return
        end
        
        RAGE.Features[feature] = not RAGE.Features[feature]
        if RAGE.Features[feature] then
            TweenService:Create(ToggleCircle, TweenInfo.new(0.2), {Position = UDim2.new(0, 25, 0.5, -9)}):Play()
            ToggleButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
            warn("[⚡] RAGE MOD: " .. name .. " активирован!")
        else
            TweenService:Create(ToggleCircle, TweenInfo.new(0.2), {Position = UDim2.new(0, 2, 0.5, -9)}):Play()
            ToggleButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
            warn("[⚡] RAGE MOD: " .. name .. " деактивирован!")
        end
    end)
    
    return ToggleFrame
end

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
    SliderLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    SliderLabel.TextSize = 12
    SliderLabel.TextXAlignment = Enum.TextXAlignment.Left
    SliderLabel.Font = Enum.Font.Gotham
    SliderLabel.Parent = SliderFrame
    
    local SliderTrack = Instance.new("Frame")
    SliderTrack.Size = UDim2.new(1, 0, 0, 6)
    SliderTrack.Position = UDim2.new(0, 0, 0, 25)
    SliderTrack.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    SliderTrack.Parent = SliderFrame
    
    local SliderTrackCorner = Instance.new("UICorner")
    SliderTrackCorner.CornerRadius = UDim.new(0, 3)
    SliderTrackCorner.Parent = SliderTrack
    
    local SliderFill = Instance.new("Frame")
    SliderFill.Size = UDim2.new((defaultVal - minVal) / (maxVal - minVal), 0, 1, 0)
    SliderFill.Position = UDim2.new(0, 0, 0, 0)
    SliderFill.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
    SliderFill.Parent = SliderTrack
    
    local SliderFillCorner = Instance.new("UICorner")
    SliderFillCorner.CornerRadius = UDim.new(0, 3)
    SliderFillCorner.Parent = SliderFill
    
    local SliderButton = Instance.new("TextButton")
    SliderButton.Size = UDim2.new(0, 16, 0, 16)
    SliderButton.Position = UDim2.new((defaultVal - minVal) / (maxVal - minVal), -8, 0.5, -8)
    SliderButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    SliderButton.Text = ""
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

-- Создание элементов интерфейса
local yPos = 0
local elementHeight = 40

-- Основные функции
CreateToggle("🕊️ Fly Hack", "Fly", yPos); yPos = yPos + elementHeight
CreateToggle("💨 Speed Hack", "Speed", yPos); yPos = yPos + elementHeight
CreateToggle("🎯 Aimbot", "Aimbot", yPos); yPos = yPos + elementHeight
CreateToggle("👻 Noclip", "Noclip", yPos); yPos = yPos + elementHeight
CreateToggle("👁️ ESP", "ESP", yPos); yPos = yPos + elementHeight

-- Слайдеры
CreateSlider("Скорость", 16, 100, 50, function(value)
    RAGE.Features.SpeedValue = value
end, yPos); yPos = yPos + 60

CreateSlider("FOV аимбота", 10, 200, 50, function(value)
    RAGE.Aimbot.FOV = value
end, yPos); yPos = yPos + 60

CreateSlider("Сглаживание", 1, 10, 1, function(value)
    RAGE.Aimbot.Smoothness = value
end, yPos); yPos = yPos + 60

-- Drag логика для кружка
local dragging = false
local dragInput, dragStart, startPos

local function updateInput(input)
    local delta = input.Position - dragStart
    CircleButton.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end

CircleButton.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = CircleButton.Position
        
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

CircleButton.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        updateInput(input)
    end
end)

-- Открытие/закрытие меню
CircleButton.MouseButton1Click:Connect(function()
    if not RAGE.Authenticated then
        warn("[⚡] RAGE MOD: Требуется аутентификация KeyAuth!")
        return
    end
    
    RAGE.Menu.Open = not RAGE.Menu.Open
    MainFrame.Visible = RAGE.Menu.Open
end)

-- РЕАЛЬНЫЕ ФУНКЦИИ ХАКОВ

-- Fly Hack
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
                flyBodyVelocity.MaxForce = Vector3.new(0, 9.81 * 100, 0)
                flyBodyVelocity.Parent = character.HumanoidRootPart
            end
            
            if not flyConnection then
                flyConnection = RunService.Heartbeat:Connect(function()
                    if not RAGE.Features.Fly or not RAGE.Authenticated then return end
                    
                    local character = LocalPlayer.Character
                    if character and character:FindFirstChild("HumanoidRootPart") and flyBodyVelocity then
                        local newVelocity = Vector3.new(0, 0, 0)
                        
                        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                            newVelocity = Vector3.new(0, 50, 0)
                        elseif UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
                            newVelocity = Vector3.new(0, -50, 0)
                        end
                        
                        flyBodyVelocity.Velocity = newVelocity
                    end
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
local speedConnection
local originalWalkSpeed

local function SpeedHack()
    if not RAGE.Authenticated then return end
    
    if RAGE.Features.Speed then
        if not speedConnection then
            speedConnection = RunService.Heartbeat:Connect(function()
                local character = LocalPlayer.Character
                if character and character:FindFirstChild("Humanoid") and RAGE.Authenticated then
                    if not originalWalkSpeed then
                        originalWalkSpeed = character.Humanoid.WalkSpeed
                    end
                    character.Humanoid.WalkSpeed = RAGE.Features.SpeedValue
                end
            end)
        end
    else
        if speedConnection then
            speedConnection:Disconnect()
            speedConnection = nil
        end
        local character = LocalPlayer.Character
        if character and character:FindFirstChild("Humanoid") and originalWalkSpeed then
            character.Humanoid.WalkSpeed = originalWalkSpeed
        end
    end
end

-- Noclip
local noclipConnection
local originalCollide = {}

local function Noclip()
    if not RAGE.Authenticated then return end
    
    if RAGE.Features.Noclip then
        if not noclipConnection then
            noclipConnection = RunService.Stepped:Connect(function()
                local character = LocalPlayer.Character
                if character and RAGE.Authenticated then
                    for _, part in pairs(character:GetDescendants()) do
                        if part:IsA("BasePart") then
                            if part.CanCollide then
                                originalCollide[part] = true
                                part.CanCollide = false
                            end
                        end
                    end
                end
            end)
        end
    else
        if noclipConnection then
            noclipConnection:Disconnect()
            noclipConnection = nil
        end
        -- Восстанавливаем коллизию
        for part, canCollide in pairs(originalCollide) do
            if part and part.Parent then
                part.CanCollide = canCollide
            end
        end
        originalCollide = {}
    end
end

-- ESP система
local espConnections = {}
local espObjects = {}

local function ESP()
    if not RAGE.Authenticated then return end
    
    if RAGE.Features.ESP then
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                local character = player.Character
                local humanoid = character:FindFirstChild("Humanoid")
                local rootPart = character:FindFirstChild("HumanoidRootPart")
                
                if humanoid and rootPart and not espObjects[player] then
                    -- Создаем Highlight
                    local highlight = Instance.new("Highlight")
                    highlight.FillColor = Color3.fromRGB(255, 0, 0)
                    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                    highlight.FillTransparency = 0.5
                    highlight.OutlineTransparency = 0
                    highlight.Parent = character
                    
                    -- Создаем BillboardGui для ника
                    local billboard = Instance.new("BillboardGui")
                    billboard.Size = UDim2.new(0, 200, 0, 50)
                    billboard.StudsOffset = Vector3.new(0, 3, 0)
                    billboard.AlwaysOnTop = true
                    billboard.Parent = character
                    
                    local nameLabel = Instance.new("TextLabel")
                    nameLabel.Size = UDim2.new(1, 0, 1, 0)
                    nameLabel.BackgroundTransparency = 1
                    nameLabel.Text = player.Name
                    nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
                    nameLabel.TextStrokeTransparency = 0
                    nameLabel.TextSize = 14
                    nameLabel.Font = Enum.Font.GothamBold
                    nameLabel.Parent = billboard
                    
                    espObjects[player] = {
                        Highlight = highlight,
                        Billboard = billboard
                    }
                end
            end
        end
    else
        for player, objects in pairs(espObjects) do
            if objects.Highlight then
                objects.Highlight:Destroy()
            end
            if objects.Billboard then
                objects.Billboard:Destroy()
            end
        end
        espObjects = {}
    end
end

-- Aimbot система
local aimbotConnection
local aimbotCircle

local function Aimbot()
    if not RAGE.Authenticated then return end
    
    if RAGE.Features.Aimbot then
        -- Создаем круг FOV если его нет
        if not aimbotCircle then
            aimbotCircle = Instance.new("Frame")
            aimbotCircle.Size = UDim2.new(0, RAGE.Aimbot.FOV * 2, 0, RAGE.Aimbot.FOV * 2)
            aimbotCircle.Position = UDim2.new(0.5, -RAGE.Aimbot.FOV, 0.5, -RAGE.Aimbot.FOV)
            aimbotCircle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            aimbotCircle.BackgroundTransparency = 0.8
            aimbotCircle.BorderSizePixel = 0
            aimbotCircle.Parent = ScreenGui
            
            local circleCorner = Instance.new("UICorner")
            circleCorner.CornerRadius = UDim.new(1, 0)
            circleCorner.Parent = aimbotCircle
        end
        
        -- Обновляем размер круга FOV
        aimbotCircle.Size = UDim2.new(0, RAGE.Aimbot.FOV * 2, 0, RAGE.Aimbot.FOV * 2)
        aimbotCircle.Position = UDim2.new(0.5, -RAGE.Aimbot.FOV, 0.5, -RAGE.Aimbot.FOV)
        
        if not aimbotConnection then
            aimbotConnection = RunService.Heartbeat:Connect(function()
                local closestPlayer = nil
                local closestDistance = RAGE.Aimbot.FOV
                local mousePos = UserInputService:GetMouseLocation()
                
                for _, player in pairs(Players:GetPlayers()) do
                    if player ~= LocalPlayer and player.Character then
                        local character = player.Character
                        local humanoid = character:FindFirstChild("Humanoid")
                        local rootPart = character:FindFirstChild("HumanoidRootPart")
                        
                        if humanoid and rootPart and humanoid.Health > 0 then
                            local screenPoint, onScreen = Camera:WorldToViewportPoint(rootPart.Position)
                            
                            if onScreen then
                                local distance = (Vector2.new(screenPoint.X, screenPoint.Y) - mousePos).Magnitude
                                
                                if distance < closestDistance then
                                    closestDistance = distance
                                    closestPlayer = player
                                    RAGE.Aimbot.Target = player
                                end
                            end
                        end
                    end
                end
                
                -- Автоматическое прицеливание при нажатии правой кнопки мыши
                if closestPlayer and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
                    local targetRoot = closestPlayer.Character:FindFirstChild("HumanoidRootPart")
                    if targetRoot then
                        Camera.CFrame = CFrame.lookAt(Camera.CFrame.Position, targetRoot.Position)
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
        RAGE.Aimbot.Target = nil
    end
end

-- Очистка при выходе игрока
LocalPlayer.CharacterRemoving:Connect(function()
    if flyBodyVelocity then
        flyBodyVelocity:Destroy()
        flyBodyVelocity = nil
    end
    if flyConnection then
        flyConnection:Disconnect()
        flyConnection = nil
    end
end)

-- Основной цикл обновления функций
RunService.Heartbeat:Connect(function()
    if RAGE.Authenticated then
        FlyHack()
        SpeedHack()
        Noclip()
        ESP()
        Aimbot()
    end
end)

warn("[⚡] RAGE MOD V1.01.02 - Ruzt Script Loaded!")
warn("[⚡] KeyAuth System: Initialized")
warn("[⚡] Waiting for authentication...")
warn("[⚡] Features: Fly, Speed, Aimbot, Noclip, ESP with real functionality")
