-- ================================================
-- FLAMEPIE v2.0 – ULTIMATE CHEAT
-- Преимущества: Binds по UserId, стильный GUI, все фичи
-- ================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()
local parent = (gethui and gethui()) or game:GetService("CoreGui") or LocalPlayer:WaitForChild("PlayerGui")

-- Удаляем старые экземпляры
if parent:FindFirstChild("FlamePieGUI") then parent.FlamePieGUI:Destroy() end

-- Глобальное хранилище настроек (по UserId)
local function getSettings()
    local userId = LocalPlayer.UserId
    if not getgenv().FlamePieSettings then
        getgenv().FlamePieSettings = {}
    end
    if not getgenv().FlamePieSettings[userId] then
        getgenv().FlamePieSettings[userId] = {
            binds = {},
            toggles = {},
            sliders = {}
        }
    end
    return getgenv().FlamePieSettings[userId]
end

local settings = getSettings()

-- Значения по умолчанию для слайдеров (если не сохранены)
local function defaultSlider(name, min, max, default)
    if settings.sliders[name] == nil then
        settings.sliders[name] = default
    end
    return settings.sliders[name]
end

local function defaultToggle(name, default)
    if settings.toggles[name] == nil then
        settings.toggles[name] = default
    end
    return settings.toggles[name]
end

-- Настройки (загружаем из сохранённых или дефолт)
local aimbotEnabled = defaultToggle("aimbot", false)
local aimbotMode = settings.aimbotMode or "Rage" -- Rage/Legit/Human
local fovValue = defaultSlider("fov", 10, 360, 90)
local smoothValue = defaultSlider("smooth", 1, 20, 10)
local hitboxSize = defaultSlider("hitbox", 1, 3, 1)
local triggerBot = defaultToggle("triggerbot", false)
local magicBullet = defaultToggle("magicbullet", false)
local espEnabled = defaultToggle("esp", false)
local flyEnabled = defaultToggle("fly", false)
local flySpeed = defaultSlider("flyspeed", 10, 200, 50)
local noclipEnabled = defaultToggle("noclip", false)
local speedEnabled = defaultToggle("speed", false)
local speedValue = defaultSlider("speedval", 16, 250, 50)
local infJumpEnabled = defaultToggle("infjump", false)
local noRecoilEnabled = defaultToggle("norecoil", false)

-- Binds: словарь функция -> клавиша (KeyCode)
local binds = settings.binds or {}
local function saveBinds() settings.binds = binds end

-- Функция для установки бинда
local function setBind(action, keyCode)
    binds[action] = keyCode
    saveBinds()
end

-- GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "FlamePieGUI"
screenGui.ResetOnSpawn = true
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.DisplayOrder = 999
screenGui.Parent = parent

-- Главное окно
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 0, 0, 0)
mainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(15, 18, 28)
mainFrame.BackgroundTransparency = 1
mainFrame.BorderSizePixel = 0
mainFrame.ClipsDescendants = true
mainFrame.Visible = false
mainFrame.ZIndex = 999
mainFrame.Parent = screenGui

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 12)
mainCorner.Parent = mainFrame

local mainStroke = Instance.new("UIStroke")
mainStroke.Color = Color3.fromRGB(80, 140, 255)
mainStroke.Thickness = 1.5
mainStroke.Transparency = 0.4
mainStroke.Parent = mainFrame

-- Анимация появления
local function animateShow()
    mainFrame.Visible = true
    mainFrame.Size = UDim2.new(0, 0, 0, 0)
    mainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    mainFrame.BackgroundTransparency = 1
    TweenService:Create(mainFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Size = UDim2.new(0, 640, 0, 540),
        Position = UDim2.new(0.5, -320, 0.5, -270),
        BackgroundTransparency = 0.15
    }):Play()
end

local function animateHide()
    TweenService:Create(mainFrame, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
        Size = UDim2.new(0, 0, 0, 0),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        BackgroundTransparency = 1
    }):Play()
    task.delay(0.15, function() mainFrame.Visible = false end)
end

-- Заголовок (перетаскивание)
local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 38)
titleBar.BackgroundColor3 = Color3.fromRGB(20, 24, 36)
titleBar.BorderSizePixel = 0
titleBar.ZIndex = 999
titleBar.Parent = mainFrame

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 12)
titleCorner.Parent = titleBar

local titleText = Instance.new("TextLabel")
titleText.Size = UDim2.new(1, -120, 1, 0)
titleText.Position = UDim2.new(0, 15, 0, 0)
titleText.BackgroundTransparency = 1
titleText.Text = "🔥 FLAMEPIE v2.0 🔥"
titleText.TextColor3 = Color3.fromRGB(255, 180, 50)
titleText.TextSize = 20
titleText.Font = Enum.Font.GothamBold
titleText.TextXAlignment = Enum.TextXAlignment.Left
titleText.Parent = titleBar

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 30, 0, 30)
closeBtn.Position = UDim2.new(1, -38, 0, 4)
closeBtn.BackgroundColor3 = Color3.fromRGB(220, 50, 70)
closeBtn.BorderSizePixel = 0
closeBtn.Text = "✕"
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.TextSize = 16
closeBtn.Font = Enum.Font.GothamBold
closeBtn.ZIndex = 999
closeBtn.Parent = titleBar

closeBtn.MouseButton1Click:Connect(function() animateHide() end)

-- Перетаскивание
local dragging = false
local dragStart, dragOffset

titleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        dragOffset = mainFrame.AbsolutePosition
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local newPos = dragOffset + (input.Position - dragStart)
        mainFrame.Position = UDim2.new(0, newPos.X, 0, newPos.Y)
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
end)

-- Боковая панель вкладок
local tabPanel = Instance.new("Frame")
tabPanel.Size = UDim2.new(0, 130, 1, -38)
tabPanel.Position = UDim2.new(0, 0, 0, 38)
tabPanel.BackgroundColor3 = Color3.fromRGB(12, 15, 25)
tabPanel.BorderSizePixel = 0
tabPanel.ZIndex = 999
tabPanel.Parent = mainFrame

local tabCorner = Instance.new("UICorner")
tabCorner.CornerRadius = UDim.new(0, 0)
tabCorner.Parent = tabPanel

-- Контентная область
local contentFrame = Instance.new("Frame")
contentFrame.Size = UDim2.new(1, -130, 1, -38)
contentFrame.Position = UDim2.new(0, 130, 0, 38)
contentFrame.BackgroundColor3 = Color3.fromRGB(10, 12, 20)
contentFrame.BackgroundTransparency = 0.05
contentFrame.BorderSizePixel = 0
contentFrame.ZIndex = 999
contentFrame.Parent = mainFrame

-- Создание кнопки вкладки
local function createTabButton(name, text, y)
    local btn = Instance.new("TextButton")
    btn.Name = name
    btn.Size = UDim2.new(1, -10, 0, 34)
    btn.Position = UDim2.new(0, 5, 0, y)
    btn.BackgroundColor3 = Color3.fromRGB(25, 30, 45)
    btn.BorderSizePixel = 0
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(180, 200, 255)
    btn.TextSize = 13
    btn.Font = Enum.Font.Gotham
    btn.ZIndex = 999
    btn.Parent = tabPanel

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = btn

    return btn
end

local tabs = {
    Aimbot = createTabButton("AimbotTab", "🎯 Aimbot", 10),
    Visual = createTabButton("VisualTab", "👁 Visual", 50),
    Movement = createTabButton("MovementTab", "🏃 Movement", 90),
    Weapon = createTabButton("WeaponTab", "🔫 Weapon", 130),
    Binds = createTabButton("BindsTab", "⌨ Binds", 170)
}

-- Функция показа содержимого вкладки
local function showTab(tabName)
    for name, btn in pairs(tabs) do
        btn.BackgroundColor3 = (name == tabName) and Color3.fromRGB(50, 70, 120) or Color3.fromRGB(25, 30, 45)
    end
    -- Скрываем все элементы в contentFrame, кроме тех, что принадлежат текущей вкладке
    for _, child in ipairs(contentFrame:GetChildren()) do
        child.Visible = false
    end
    -- Показываем элементы, у которых имя соответствует вкладке
    for _, child in ipairs(contentFrame:GetChildren()) do
        if child.Name == tabName then
            child.Visible = true
        end
    end
end

-- Создаём контейнеры для каждой вкладки (все сразу, но видим только активную)
local function createTabContainer(tabName)
    local container = Instance.new("Frame")
    container.Name = tabName
    container.Size = UDim2.new(1, -20, 1, -20)
    container.Position = UDim2.new(0, 10, 0, 10)
    container.BackgroundTransparency = 1
    container.Visible = false
    container.ZIndex = 999
    container.Parent = contentFrame
    return container
end

local containerAimbot = createTabContainer("AimbotTab")
local containerVisual = createTabContainer("VisualTab")
local containerMovement = createTabContainer("MovementTab")
local containerWeapon = createTabContainer("WeaponTab")
local containerBinds = createTabContainer("BindsTab")

-- Вспомогательные функции создания элементов интерфейса
local function createToggle(parent, labelText, y, defaultState, onChange)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 30)
    frame.Position = UDim2.new(0, 0, 0, y)
    frame.BackgroundTransparency = 1
    frame.Parent = parent

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.6, 0, 1, 0)
    label.Position = UDim2.new(0, 5, 0, 0)
    label.Text = labelText
    label.TextColor3 = Color3.fromRGB(200, 210, 230)
    label.BackgroundTransparency = 1
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Font = Enum.Font.Gotham
    label.TextSize = 14
    label.Parent = frame

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 70, 0, 24)
    btn.Position = UDim2.new(0.75, 0, 0.03, 0)
    btn.BackgroundColor3 = defaultState and Color3.fromRGB(50, 180, 70) or Color3.fromRGB(60, 60, 80)
    btn.BorderSizePixel = 0
    btn.Text = defaultState and "ON" or "OFF"
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextSize = 12
    btn.Font = Enum.Font.GothamBold
    btn.Parent = frame

    local state = defaultState
    btn.MouseButton1Click:Connect(function()
        state = not state
        btn.BackgroundColor3 = state and Color3.fromRGB(50, 180, 70) or Color3.fromRGB(60, 60, 80)
        btn.Text = state and "ON" or "OFF"
        if onChange then onChange(state) end
    end)

    return {
        Button = btn,
        GetState = function() return state end,
        SetState = function(s)
            state = s
            btn.BackgroundColor3 = state and Color3.fromRGB(50, 180, 70) or Color3.fromRGB(60, 60, 80)
            btn.Text = state and "ON" or "OFF"
            if onChange then onChange(state) end
        end
    }
end

local function createSlider(parent, labelText, y, minVal, maxVal, defaultVal, onChange)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -10, 0, 50)
    frame.Position = UDim2.new(0, 5, 0, y)
    frame.BackgroundTransparency = 1
    frame.Parent = parent

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 0, 18)
    label.Text = labelText .. ": " .. tostring(defaultVal)
    label.TextColor3 = Color3.fromRGB(180, 200, 255)
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.Gotham
    label.TextSize = 13
    label.Parent = frame

    local sliderBg = Instance.new("Frame")
    sliderBg.Position = UDim2.new(0, 0, 0, 22)
    sliderBg.Size = UDim2.new(1, 0, 0, 6)
    sliderBg.BackgroundColor3 = Color3.fromRGB(40, 45, 65)
    sliderBg.BorderSizePixel = 0
    sliderBg.Parent = frame

    local sliderFill = Instance.new("Frame")
    sliderFill.Size = UDim2.new((defaultVal - minVal) / (maxVal - minVal), 0, 1, 0)
    sliderFill.BackgroundColor3 = Color3.fromRGB(80, 160, 255)
    sliderFill.BorderSizePixel = 0
    sliderFill.Parent = sliderBg

    local knob = Instance.new("TextButton")
    knob.Size = UDim2.new(0, 16, 0, 16)
    knob.Position = UDim2.new((defaultVal - minVal) / (maxVal - minVal), -8, 0, -5)
    knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    knob.BorderSizePixel = 0
    knob.Text = ""
    knob.Parent = sliderBg

    local draggingSlider = false
    local function updateSlider(input)
        local mouseX = input.Position.X
        local absX = sliderBg.AbsolutePosition.X
        local width = sliderBg.AbsoluteSize.X
        local percent = math.clamp((mouseX - absX) / width, 0, 1)
        local val = minVal + (maxVal - minVal) * percent
        val = math.floor(val + 0.5)
        sliderFill.Size = UDim2.new(percent, 0, 1, 0)
        knob.Position = UDim2.new(percent, -8, 0, -5)
        label.Text = labelText .. ": " .. tostring(val)
        if onChange then onChange(val) end
        return val
    end

    knob.MouseButton1Down:Connect(function() draggingSlider = true end)
    UserInputService.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 and draggingSlider then
            updateSlider(input)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if draggingSlider and input.UserInputType == Enum.UserInputType.MouseMovement then
            updateSlider(input)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then draggingSlider = false end
    end)

    return {
        GetValue = function()
            local percent = knob.Position.X.Scale
            return minVal + (maxVal - minVal) * percent
        end,
        SetValue = function(val)
            val = math.clamp(val, minVal, maxVal)
            local percent = (val - minVal) / (maxVal - minVal)
            sliderFill.Size = UDim2.new(percent, 0, 1, 0)
            knob.Position = UDim2.new(percent, -8, 0, -5)
            label.Text = labelText .. ": " .. tostring(val)
            if onChange then onChange(val) end
        end
    }
end

-- ===================================================
-- ЗАПОЛНЯЕМ ВКЛАДКИ
-- ===================================================

-- Aimbot
local aimbotToggle = createToggle(containerAimbot, "Aimbot", 0, aimbotEnabled, function(s) aimbotEnabled = s; settings.toggles.aimbot = s end)

-- Режимы (Rage/Legit/Human) – три кнопки
local modeFrame = Instance.new("Frame")
modeFrame.Size = UDim2.new(1, 0, 0, 35)
modeFrame.Position = UDim2.new(0, 0, 0, 35)
modeFrame.BackgroundTransparency = 1
modeFrame.Parent = containerAimbot

local modeLabel = Instance.new("TextLabel")
modeLabel.Size = UDim2.new(0.2, 0, 1, 0)
modeLabel.Text = "Mode:"
modeLabel.TextColor3 = Color3.fromRGB(180, 200, 255)
modeLabel.BackgroundTransparency = 1
modeLabel.Font = Enum.Font.Gotham
modeLabel.TextSize = 14
modeLabel.Parent = modeFrame

local function createModeButton(parent, text, x, default)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 60, 0, 28)
    btn.Position = UDim2.new(x, 0, 0.05, 0)
    btn.BackgroundColor3 = default and Color3.fromRGB(80, 120, 200) or Color3.fromRGB(40, 45, 70)
    btn.BorderSizePixel = 0
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextSize = 12
    btn.Font = Enum.Font.GothamBold
    btn.Parent = parent
    return btn
end

local rageBtn = createModeButton(modeFrame, "Rage", 0.25, aimbotMode == "Rage")
local legitBtn = createModeButton(modeFrame, "Legit", 0.45, aimbotMode == "Legit")
local humanBtn = createModeButton(modeFrame, "Human", 0.65, aimbotMode == "Human")

local function setMode(mode)
    aimbotMode = mode
    settings.aimbotMode = mode
    rageBtn.BackgroundColor3 = (mode == "Rage") and Color3.fromRGB(80, 120, 200) or Color3.fromRGB(40, 45, 70)
    legitBtn.BackgroundColor3 = (mode == "Legit") and Color3.fromRGB(80, 120, 200) or Color3.fromRGB(40, 45, 70)
    humanBtn.BackgroundColor3 = (mode == "Human") and Color3.fromRGB(80, 120, 200) or Color3.fromRGB(40, 45, 70)
end

rageBtn.MouseButton1Click:Connect(function() setMode("Rage") end)
legitBtn.MouseButton1Click:Connect(function() setMode("Legit") end)
humanBtn.MouseButton1Click:Connect(function() setMode("Human") end)

local fovSlider = createSlider(containerAimbot, "FOV", 80, 10, 360, fovValue, function(v) fovValue = v; settings.sliders.fov = v end)
local smoothSlider = createSlider(containerAimbot, "Smooth", 135, 1, 20, smoothValue, function(v) smoothValue = v; settings.sliders.smooth = v end)
local hitboxSlider = createSlider(containerAimbot, "Hitbox Size", 190, 1, 3, hitboxSize, function(v) hitboxSize = v; settings.sliders.hitbox = v end)

local triggerToggle = createToggle(containerAimbot, "Trigger Bot", 250, triggerBot, function(s) triggerBot = s; settings.toggles.triggerbot = s end)
local magicToggle = createToggle(containerAimbot, "Magic Bullet", 290, magicBullet, function(s) magicBullet = s; settings.toggles.magicbullet = s end)

-- Visual
local espToggle = createToggle(containerVisual, "ESP (Highlight + Info)", 0, espEnabled, function(s) espEnabled = s; settings.toggles.esp = s end)

-- Movement
local flyToggle = createToggle(containerMovement, "Fly", 0, flyEnabled, function(s) flyEnabled = s; settings.toggles.fly = s end)
local flySpeedSlider = createSlider(containerMovement, "Fly Speed", 40, 10, 200, flySpeed, function(v) flySpeed = v; settings.sliders.flyspeed = v end)
local noclipToggle = createToggle(containerMovement, "Noclip", 100, noclipEnabled, function(s) noclipEnabled = s; settings.toggles.noclip = s end)
local speedToggle = createToggle(containerMovement, "Speed Hack", 140, speedEnabled, function(s) speedEnabled = s; settings.toggles.speed = s end)
local speedSlider = createSlider(containerMovement, "Speed Value", 190, 16, 250, speedValue, function(v) speedValue = v; settings.sliders.speedval = v end)
local infJumpToggle = createToggle(containerMovement, "Infinite Jump", 250, infJumpEnabled, function(s) infJumpEnabled = s; settings.toggles.infjump = s end)

-- Weapon
local noRecoilToggle = createToggle(containerWeapon, "No Recoil", 0, noRecoilEnabled, function(s) noRecoilEnabled = s; settings.toggles.norecoil = s end)

-- Binds (отдельная вкладка)
-- Список действий, которые можно забиндить
local actions = {
    {name = "Aimbot", key = "aimbot"},
    {name = "Trigger Bot", key = "triggerbot"},
    {name = "Fly", key = "fly"},
    {name = "Noclip", key = "noclip"},
    {name = "Speed Hack", key = "speed"},
    {name = "Infinite Jump", key = "infjump"},
    {name = "ESP", key = "esp"},
    {name = "No Recoil", key = "norecoil"},
    {name = "Magic Bullet", key = "magicbullet"}
}

-- Создаём элементы для каждого действия
local bindsY = 0
local bindObjects = {}
for _, act in ipairs(actions) do
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 32)
    frame.Position = UDim2.new(0, 0, 0, bindsY)
    frame.BackgroundTransparency = 1
    frame.Parent = containerBinds

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.5, 0, 1, 0)
    label.Position = UDim2.new(0, 5, 0, 0)
    label.Text = act.name
    label.TextColor3 = Color3.fromRGB(200, 210, 230)
    label.BackgroundTransparency = 1
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Font = Enum.Font.Gotham
    label.TextSize = 14
    label.Parent = frame

    local keyBtn = Instance.new("TextButton")
    keyBtn.Size = UDim2.new(0, 100, 0, 26)
    keyBtn.Position = UDim2.new(0.7, 0, 0.02, 0)
    keyBtn.BackgroundColor3 = Color3.fromRGB(40, 45, 70)
    keyBtn.BorderSizePixel = 0
    local currentKey = binds[act.key]
    keyBtn.Text = currentKey and tostring(currentKey):gsub("Enum.KeyCode.", "") or "None"
    keyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    keyBtn.TextSize = 12
    keyBtn.Font = Enum.Font.Gotham
    keyBtn.Parent = frame

    local listening = false
    keyBtn.MouseButton1Click:Connect(function()
        if listening then return end
        listening = true
        keyBtn.Text = "..."
        keyBtn.BackgroundColor3 = Color3.fromRGB(200, 100, 50)
        local conn
        conn = UserInputService.InputBegan:Connect(function(input, gameProcessed)
            if gameProcessed then return end
            if input.KeyCode ~= Enum.KeyCode.Unknown then
                listening = false
                keyBtn.BackgroundColor3 = Color3.fromRGB(40, 45, 70)
                keyBtn.Text = tostring(input.KeyCode):gsub("Enum.KeyCode.", "")
                setBind(act.key, input.KeyCode)
                conn:Disconnect()
            end
        end)
        -- Тайм-аут через 5 секунд
        task.delay(5, function()
            if listening then
                listening = false
                keyBtn.BackgroundColor3 = Color3.fromRGB(40, 45, 70)
                keyBtn.Text = "None"
            end
        end)
    end)

    bindObjects[act.key] = {Button = keyBtn, Action = act.key}
    bindsY = bindsY + 38
end

-- Показываем первую вкладку
showTab("AimbotTab")

-- События вкладок
for name, btn in pairs(tabs) do
    btn.MouseButton1Click:Connect(function()
        showTab(name)
    end)
end

-- Горячая клавиша для показа/скрытия меню (Insert)
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.Insert then
        if mainFrame.Visible then
            animateHide()
        else
            animateShow()
        end
    end
end)

-- ===================================================
-- ЛОГИКА ЧИТА
-- ===================================================

local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local hum = char:WaitForChild("Humanoid")
local rootPart = char:WaitForChild("HumanoidRootPart")

-- Переподключение при респавне
LocalPlayer.CharacterAdded:Connect(function(newChar)
    char = newChar
    hum = newChar:WaitForChild("Humanoid")
    rootPart = newChar:WaitForChild("HumanoidRootPart")
    if noclipEnabled then
        task.spawn(function()
            task.wait(0.5)
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") then part.CanCollide = false end
            end
        end)
    end
end)

-- Функция получения цели в FOV с учётом стен
local function canSeeTarget(targetHead)
    if not char or not rootPart then return false end
    local rayParams = RaycastParams.new()
    rayParams.FilterType = Enum.RaycastFilterType.Exclude
    rayParams.FilterDescendantsInstances = {char, targetHead.Parent}
    local result = workspace:Raycast(Camera.CFrame.Position, (targetHead.Position - Camera.CFrame.Position), rayParams)
    return result == nil
end

local function getClosestInFOV()
    if not char or not rootPart then return nil end
    local camera = Camera
    local cameraPos = camera.CFrame.Position
    local forward = camera.CFrame.LookVector
    local fovRad = math.rad(fovValue)
    local best = nil
    local bestAngle = fovRad

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local targetHum = player.Character:FindFirstChild("Humanoid")
            local targetHead = player.Character:FindFirstChild("Head")
            if targetHum and targetHead and targetHum.Health > 0 then
                local dir = (targetHead.Position - cameraPos).Unit
                local angle = math.acos(math.clamp(forward:Dot(dir), -1, 1))
                if angle < bestAngle and canSeeTarget(targetHead) then
                    bestAngle = angle
                    best = {Head = targetHead, Player = player}
                end
            end
        end
    end
    return best
end

-- Хитбоксы (увеличение головы)
local function applyHitboxSize()
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local head = player.Character:FindFirstChild("Head")
            if head and head:IsDescendantOf(workspace) then
                if hitboxSize > 1 then
                    if not head:GetAttribute("OriginalSize") then
                        head:SetAttribute("OriginalSize", head.Size)
                    end
                    head.Size = head:GetAttribute("OriginalSize") * hitboxSize
                else
                    local orig = head:GetAttribute("OriginalSize")
                    if orig then
                        head.Size = orig
                        head:SetAttribute("OriginalSize", nil)
                    end
                end
            end
        end
    end
end

-- ESP (Highlight + Billboard)
local espObjects = {}
local function updateESP()
    if not espEnabled then
        for _, data in pairs(espObjects) do
            if data.Highlight then data.Highlight:Destroy() end
            if data.Billboard then data.Billboard:Destroy() end
        end
        espObjects = {}
        return
    end

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local char = player.Character
            local hum = char:FindFirstChild("Humanoid")
            local head = char:FindFirstChild("Head")
            if hum and head and hum.Health > 0 then
                if not espObjects[player] then
                    -- Highlight
                    local hl = Instance.new("Highlight")
                    hl.FillTransparency = 0.6
                    hl.OutlineColor = Color3.fromRGB(100, 200, 255)
                    hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                    hl.Parent = char
                    -- Billboard
                    local bill = Instance.new("BillboardGui")
                    bill.Size = UDim2.new(0, 200, 0, 40)
                    bill.StudsOffset = Vector3.new(0, 2.5, 0)
                    bill.AlwaysOnTop = true
                    bill.Parent = head

                    local frame = Instance.new("Frame")
                    frame.Size = UDim2.new(1, 0, 1, 0)
                    frame.BackgroundColor3 = Color3.fromRGB(0,0,0)
                    frame.BackgroundTransparency = 0.5
                    frame.Parent = bill

                    local nameLbl = Instance.new("TextLabel")
                    nameLbl.Size = UDim2.new(1, 0, 0, 20)
                    nameLbl.BackgroundTransparency = 1
                    nameLbl.Text = player.Name
                    nameLbl.TextColor3 = Color3.fromRGB(255,255,255)
                    nameLbl.TextSize = 14
                    nameLbl.Font = Enum.Font.GothamBold
                    nameLbl.Parent = frame

                    local infoLbl = Instance.new("TextLabel")
                    infoLbl.Name = "Info"
                    infoLbl.Size = UDim2.new(1, 0, 0, 18)
                    infoLbl.Position = UDim2.new(0, 0, 0, 20)
                    infoLbl.BackgroundTransparency = 1
                    infoLbl.TextColor3 = Color3.fromRGB(150, 200, 255)
                    infoLbl.TextSize = 12
                    infoLbl.Font = Enum.Font.Gotham
                    infoLbl.Parent = frame

                    espObjects[player] = {Highlight = hl, Billboard = bill, Frame = frame, NameLabel = nameLbl, InfoLabel = infoLbl}
                end
                -- Обновляем информацию
                local data = espObjects[player]
                local dist = (rootPart and (head.Position - rootPart.Position).Magnitude) or 0
                local weapon = "No weapon"
                for _, child in ipairs(char:GetChildren()) do
                    if child:IsA("Tool") then weapon = child.Name; break end
                end
                data.InfoLabel.Text = "HP: " .. math.floor(hum.Health) .. " | " .. math.floor(dist) .. "m | " .. weapon
            else
                if espObjects[player] then
                    espObjects[player].Highlight:Destroy()
                    espObjects[player].Billboard:Destroy()
                    espObjects[player] = nil
                end
            end
        end
    end
end

-- Обработка новых игроков
Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function()
        if espEnabled then
            -- будет обновлено в цикле
        end
    end)
end)

-- Magic Bullet (вмешательство в RemoteEvent)
local oldNamecall = nil
local function setupMagicBullet()
    if not getrawmetatable or not getnamecallmethod then return end
    local mt = getrawmetatable(game)
    if not mt or not mt.__namecall then return end
    oldNamecall = mt.__namecall
    local function newNamecall(self, ...)
        local args = {...}
        if magicBullet and self and typeof(self) == "Instance" and self:IsA("RemoteEvent") then
            local method = getnamecallmethod()
            if method == "FireServer" then
                if char and rootPart then
                    local target = getClosestInFOV()
                    if target then
                        local pos = target.Head.Position
                        for i, arg in ipairs(args) do
                            if typeof(arg) == "Vector3" then
                                args[i] = pos
                            elseif typeof(arg) == "CFrame" then
                                args[i] = CFrame.new(pos)
                            end
                        end
                    end
                end
            end
        end
        if oldNamecall then
            return oldNamecall(self, unpack(args))
        end
    end
    pcall(function()
        setreadonly(mt, false)
        mt.__namecall = newNamecall
        setreadonly(mt, true)
    end)
end
task.spawn(function()
    task.wait(1)
    setupMagicBullet()
end)

-- FOV Circle (если доступен Drawing)
local fovCircle = nil
if Drawing and Drawing.new then
    fovCircle = Drawing.new("Circle")
    fovCircle.Thickness = 2
    fovCircle.Color = Color3.fromRGB(80, 160, 255)
    fovCircle.Visible = false
end

-- Trigger Bot (автострельба)
task.spawn(function()
    while screenGui and screenGui.Parent do
        if triggerBot and aimbotEnabled then
            local target = getClosestInFOV()
            if target then
                VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
                task.wait(0.03)
                VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0)
                task.wait(math.random(50, 150)/1000)
            end
        end
        task.wait(0.05)
    end
end)

-- Основной цикл
RunService.RenderStepped:Connect(function(deltaTime)
    if not char or not hum or not rootPart then return end

    -- Speed Hack
    if speedEnabled then
        local moveDir = hum.MoveDirection
        if moveDir.Magnitude > 0 then
            local step = (speedValue - 16) * deltaTime * 0.5
            if step > 0 then
                rootPart.CFrame = rootPart.CFrame + (moveDir.Unit * step)
            end
        end
    end

    -- Fly
    if flyEnabled then
        hum.PlatformStand = true
        local direction = Vector3.new()
        local cam = Camera
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then direction += cam.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then direction -= cam.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then direction -= cam.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then direction += cam.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then direction += Vector3.new(0,1,0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then direction -= Vector3.new(0,1,0) end
        if direction.Magnitude > 0 then direction = direction.Unit end
        rootPart.AssemblyLinearVelocity = direction * flySpeed
    else
        hum.PlatformStand = false
    end

    -- Noclip
    if noclipEnabled then
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") then part.CanCollide = false end
        end
    end

    -- No Recoil (ищем оружие)
    if noRecoilEnabled then
        local tool = char:FindFirstChildOfClass("Tool")
        if tool then
            for _, child in ipairs(tool:GetDescendants()) do
                if child:IsA("NumberValue") and (child.Name == "Recoil" or child.Name == "CameraRecoil") then
                    child.Value = 0
                end
            end
        end
    end

    -- Inf Jump (через JumpRequest)
    if infJumpEnabled then
        UserInputService.JumpRequest:Connect(function()
            hum:ChangeState(Enum.HumanoidStateType.Jumping)
        end)
    end

    -- ESP обновление (раз в 0.3 сек, чтобы не грузить)
    if espEnabled then
        updateESP()
    else
        -- удаляем все объекты ESP
        for _, data in pairs(espObjects) do
            if data.Highlight then data.Highlight:Destroy() end
            if data.Billboard then data.Billboard:Destroy() end
        end
        espObjects = {}
    end

    -- Hitbox
    applyHitboxSize()

    -- FOV Circle
    if aimbotEnabled and fovCircle then
        local screenSize = Camera.ViewportSize
        local center = Vector2.new(screenSize.X/2, screenSize.Y/2)
        local radius = math.tan(math.rad(fovValue)/2) * (screenSize.Y/2)
        fovCircle.Visible = true
        fovCircle.Radius = radius
        fovCircle.Position = center
    elseif fovCircle then
        fovCircle.Visible = false
    end

    -- Aimbot
    if aimbotEnabled then
        local target = getClosestInFOV()
        if target then
            local cam = Camera
            local targetPos = target.Head.Position
            local lookAt = CFrame.lookAt(cam.CFrame.Position, targetPos)
            if aimbotMode == "Rage" then
                cam.CFrame = lookAt
            elseif aimbotMode == "Legit" then
                local smoothFactor = smoothValue / 100
                cam.CFrame = cam.CFrame:Lerp(lookAt, smoothFactor)
            elseif aimbotMode == "Human" then
                -- Имитация человеческого поведения: случайная задержка и небольшие отклонения
                if not humanDelay or os.clock() > humanDelay then
                    humanDelay = os.clock() + math.random(120, 250)/1000
                    local offset = Vector3.new(math.random(-1,1), math.random(-1,1), math.random(-1,1))
                    local targetCF = CFrame.lookAt(cam.CFrame.Position, targetPos + offset)
                    cam.CFrame = cam.CFrame:Lerp(targetCF, 0.08)
                end
            end
        end
    end
end)

-- Обработка биндов (клавиши)
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.Unknown then return end
    -- Проверяем, есть ли бинд для этой клавиши
    for action, key in pairs(binds) do
        if key == input.KeyCode then
            -- Переключаем соответствующую функцию
            if action == "aimbot" then
                aimbotEnabled = not aimbotEnabled
                aimbotToggle.SetState(aimbotEnabled)
                settings.toggles.aimbot = aimbotEnabled
            elseif action == "triggerbot" then
                triggerBot = not triggerBot
                triggerToggle.SetState(triggerBot)
                settings.toggles.triggerbot = triggerBot
            elseif action == "fly" then
                flyEnabled = not flyEnabled
                flyToggle.SetState(flyEnabled)
                settings.toggles.fly = flyEnabled
            elseif action == "noclip" then
                noclipEnabled = not noclipEnabled
                noclipToggle.SetState(noclipEnabled)
                settings.toggles.noclip = noclipEnabled
            elseif action == "speed" then
                speedEnabled = not speedEnabled
                speedToggle.SetState(speedEnabled)
                settings.toggles.speed = speedEnabled
            elseif action == "infjump" then
                infJumpEnabled = not infJumpEnabled
                infJumpToggle.SetState(infJumpEnabled)
                settings.toggles.infjump = infJumpEnabled
            elseif action == "esp" then
                espEnabled = not espEnabled
                espToggle.SetState(espEnabled)
                settings.toggles.esp = espEnabled
            elseif action == "norecoil" then
                noRecoilEnabled = not noRecoilEnabled
                noRecoilToggle.SetState(noRecoilEnabled)
                settings.toggles.norecoil = noRecoilEnabled
            elseif action == "magicbullet" then
                magicBullet = not magicBullet
                magicToggle.SetState(magicBullet)
                settings.toggles.magicbullet = magicBullet
            end
            break
        end
    end
end)

print("✅ FlamePie v2.0 loaded! Insert to toggle menu.")
