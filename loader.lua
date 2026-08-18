-- =============================================
-- FLAMEPIE v2.5 – FINAL STABLE
-- Исправлены: CanvasSize (500), ZIndex (-100),
-- переключение вкладок, тогглы, бинды, утечки
-- =============================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local parent = (gethui and gethui()) or game:GetService("CoreGui") or LocalPlayer:WaitForChild("PlayerGui")

if parent:FindFirstChild("FlamePieGUI") then parent.FlamePieGUI:Destroy() end

-- ====== СОХРАНЕНИЕ НАСТРОЕК ======
local function getSettings()
    local userId = LocalPlayer.UserId
    if not getgenv().FlamePieSettings then getgenv().FlamePieSettings = {} end
    if not getgenv().FlamePieSettings[userId] then
        getgenv().FlamePieSettings[userId] = { binds = {}, toggles = {}, sliders = {} }
    end
    return getgenv().FlamePieSettings[userId]
end
local settings = getSettings()

local function defaultToggle(name, def)
    if settings.toggles[name] == nil then settings.toggles[name] = def end
    return settings.toggles[name]
end
local function defaultSlider(name, min, max, def)
    if settings.sliders[name] == nil then settings.sliders[name] = def end
    return settings.sliders[name]
end

-- ====== ПЕРЕМЕННЫЕ ======
local aimbotEnabled = defaultToggle("aimbot", false)
local aimbotMode = settings.aimbotMode or "Rage"
local fovValue = defaultSlider("fov", 10, 360, 90)
local smoothValue = defaultSlider("smooth", 1, 20, 10)
local hitboxSize = defaultSlider("hitbox", 1, 3, 1)
local triggerBot = defaultToggle("triggerbot", false)
local espEnabled = defaultToggle("esp", false)
local flyEnabled = defaultToggle("fly", false)
local flySpeed = defaultSlider("flyspeed", 10, 200, 50)
local noclipEnabled = defaultToggle("noclip", false)
local speedEnabled = defaultToggle("speed", false)
local speedValue = defaultSlider("speedval", 16, 250, 50)
local infJumpEnabled = defaultToggle("infjump", false)
local noRecoilEnabled = defaultToggle("norecoil", false)

local binds = settings.binds or {}
local function saveBinds() settings.binds = binds end

-- ====== GUI ======
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "FlamePieGUI"
screenGui.ResetOnSpawn = true
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.DisplayOrder = 999
screenGui.Parent = parent

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 0, 0, 0)
mainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(15, 18, 28)
mainFrame.BackgroundTransparency = 1
mainFrame.BorderSizePixel = 0
mainFrame.ClipsDescendants = true
mainFrame.Visible = false
mainFrame.ZIndex = 899
mainFrame.Parent = screenGui

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 12)
mainCorner.Parent = mainFrame
local mainStroke = Instance.new("UIStroke")
mainStroke.Color = Color3.fromRGB(80, 140, 255)
mainStroke.Thickness = 1.5
mainStroke.Transparency = 0.4
mainStroke.Parent = mainFrame

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
titleBar.ZIndex = 899
titleBar.Parent = mainFrame
local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 12)
titleCorner.Parent = titleBar
local titleText = Instance.new("TextLabel")
titleText.Size = UDim2.new(1, -120, 1, 0)
titleText.Position = UDim2.new(0, 15, 0, 0)
titleText.BackgroundTransparency = 1
titleText.Text = "🔥 FLAMEPIE v2.5 🔥"
titleText.TextColor3 = Color3.fromRGB(255, 180, 50)
titleText.TextSize = 20
titleText.Font = Enum.Font.GothamBold
titleText.TextXAlignment = Enum.TextXAlignment.Left
titleText.ZIndex = 900
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
closeBtn.ZIndex = 900
closeBtn.Parent = titleBar
closeBtn.MouseButton1Click:Connect(function() animateHide() end)

local dragging = false
local dragStart, dragOffset

titleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        dragOffset = mainFrame.AbsolutePosition
    end
end)

RunService.RenderStepped:Connect(function()
    if dragging then
        local mousePos = UserInputService:GetMouseLocation()
        local newPos = dragOffset + (mousePos - dragStart)
        mainFrame.Position = UDim2.new(0, newPos.X, 0, newPos.Y)
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
end)

-- Вкладки
local tabPanel = Instance.new("Frame")
tabPanel.Size = UDim2.new(0, 130, 1, -38)
tabPanel.Position = UDim2.new(0, 0, 0, 38)
tabPanel.BackgroundColor3 = Color3.fromRGB(12, 15, 25)
tabPanel.BorderSizePixel = 0
tabPanel.ZIndex = 899
tabPanel.Parent = mainFrame

local contentFrame = Instance.new("Frame")
contentFrame.Size = UDim2.new(1, -130, 1, -38)
contentFrame.Position = UDim2.new(0, 130, 0, 38)
contentFrame.BackgroundColor3 = Color3.fromRGB(10, 12, 20)
contentFrame.BackgroundTransparency = 0.05
contentFrame.BorderSizePixel = 0
contentFrame.ZIndex = 899
contentFrame.Parent = mainFrame

-- Кнопки вкладок и контейнеры
local tabButtons = {}
local containers = {}
local activeTab = ""

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
    btn.ZIndex = 901
    btn.Parent = tabPanel
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = btn
    return btn
end

tabButtons.Aimbot = createTabButton("AimbotTab", "🎯 Aimbot", 10)
tabButtons.Visual = createTabButton("VisualTab", "👁 Visual", 50)
tabButtons.Movement = createTabButton("MovementTab", "🏃 Movement", 90)
tabButtons.Weapon = createTabButton("WeaponTab", "🔫 Weapon", 130)
tabButtons.Binds = createTabButton("BindsTab", "⌨ Binds", 170)

local function createTabContainer(tabName)
    local container = Instance.new("ScrollingFrame")
    container.Name = tabName
    container.Size = UDim2.new(1, -20, 1, -20)
    container.Position = UDim2.new(0, 10, 0, 10)
    container.BackgroundTransparency = 1
    container.BorderSizePixel = 0
    container.ScrollBarThickness = 4
    container.ScrollBarImageColor3 = Color3.fromRGB(80, 140, 255)
    container.CanvasSize = UDim2.new(0, 0, 0, 500)  -- исправлено!
    container.Visible = false
    container.ZIndex = 900
    container.Parent = contentFrame
    containers[tabName] = container
    return container
end

local containerAimbot = createTabContainer("AimbotTab")
local containerVisual = createTabContainer("VisualTab")
local containerMovement = createTabContainer("MovementTab")
local containerWeapon = createTabContainer("WeaponTab")
local containerBinds = createTabContainer("BindsTab")

local function selectTab(tabName)
    activeTab = tabName
    for name, cont in pairs(containers) do
        cont.Visible = (name == tabName)
    end
    for name, btn in pairs(tabButtons) do
        if name == tabName then
            btn.BackgroundColor3 = Color3.fromRGB(50, 70, 120)
            btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        else
            btn.BackgroundColor3 = Color3.fromRGB(25, 30, 45)
            btn.TextColor3 = Color3.fromRGB(180, 200, 255)
        end
    end
end

for name, btn in pairs(tabButtons) do
    btn.MouseButton1Click:Connect(function()
        selectTab(name)
    end)
end

-- Вспомогательные функции UI (исправленные)
local function updateCanvasSize(container)
    local contentHeight = 0
    for _, child in ipairs(container:GetChildren()) do
        if child:IsA("Frame") then
            local y = child.Position.Y.Offset + child.Size.Y.Offset
            if y > contentHeight then contentHeight = y end
        end
    end
    container.CanvasSize = UDim2.new(0, 0, 0, contentHeight + 20)
end

local function createToggle(parent, labelText, y, defaultState, onChange)
    local state = defaultState
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 30)
    frame.Position = UDim2.new(0, 0, 0, y)
    frame.BackgroundTransparency = 1
    frame.ZIndex = 900
    frame.Parent = parent

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.7, 0, 1, 0)
    label.Position = UDim2.new(0, 5, 0, 0)
    label.Text = labelText
    label.TextColor3 = Color3.fromRGB(200, 210, 230)
    label.BackgroundTransparency = 1
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Font = Enum.Font.Gotham
    label.TextSize = 14
    label.ZIndex = 902
    label.Parent = frame

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 22, 0, 22)
    btn.Position = UDim2.new(1, -25, 0.5, -11)
    btn.BackgroundColor3 = state and Color3.fromRGB(0, 150, 255) or Color3.fromRGB(40, 40, 40)
    btn.Text = state and "✓" or ""
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 14
    btn.ZIndex = 902
    btn.BorderSizePixel = 0
    btn.Parent = frame

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 4)
    corner.Parent = btn

    local function updateVisuals()
        btn.BackgroundColor3 = state and Color3.fromRGB(0, 150, 255) or Color3.fromRGB(40, 40, 40)
        btn.Text = state and "✓" or ""
    end

    btn.MouseButton1Click:Connect(function()
        state = not state
        updateVisuals()
        if onChange then onChange(state) end
    end)

    updateCanvasSize(parent)
    return {
        GetState = function() return state end,
        SetState = function(newState, triggerCallback)
            state = newState
            updateVisuals()
            if triggerCallback and onChange then onChange(state) end
        end
    }
end

local function createSlider(parent, labelText, y, minVal, maxVal, defaultVal, onChange)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -10, 0, 50)
    frame.Position = UDim2.new(0, 5, 0, y)
    frame.BackgroundTransparency = 1
    frame.ZIndex = 900
    frame.Parent = parent

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 0, 18)
    label.Text = labelText .. ": " .. tostring(defaultVal)
    label.TextColor3 = Color3.fromRGB(180, 200, 255)
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.Gotham
    label.TextSize = 13
    label.ZIndex = 902
    label.Parent = frame

    local sliderBg = Instance.new("Frame")
    sliderBg.Position = UDim2.new(0, 0, 0, 22)
    sliderBg.Size = UDim2.new(1, 0, 0, 6)
    sliderBg.BackgroundColor3 = Color3.fromRGB(40, 45, 65)
    sliderBg.BorderSizePixel = 0
    sliderBg.ZIndex = 902
    sliderBg.Parent = frame

    local sliderFill = Instance.new("Frame")
    sliderFill.Size = UDim2.new((defaultVal - minVal) / (maxVal - minVal), 0, 1, 0)
    sliderFill.BackgroundColor3 = Color3.fromRGB(80, 160, 255)
    sliderFill.BorderSizePixel = 0
    sliderFill.ZIndex = 902
    sliderFill.Parent = sliderBg

    local knob = Instance.new("TextButton")
    knob.Size = UDim2.new(0, 16, 0, 16)
    knob.Position = UDim2.new((defaultVal - minVal) / (maxVal - minVal), -8, 0, -5)
    knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    knob.BorderSizePixel = 0
    knob.Text = ""
    knob.ZIndex = 902
    knob.Parent = sliderBg

    local draggingSlider = false
    local function updateSlider(input)
        local mouseX = input.Position.X
        local absX = sliderBg.AbsolutePosition.X
        local width = sliderBg.AbsoluteSize.X
        if width == 0 then return end
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
        if input.UserInputType == Enum.UserInputType.MouseButton1 and draggingSlider then updateSlider(input) end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if draggingSlider and input.UserInputType == Enum.UserInputType.MouseMovement then updateSlider(input) end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then draggingSlider = false end
    end)

    updateCanvasSize(parent)
    return {
        GetValue = function() return minVal + (maxVal - minVal) * knob.Position.X.Scale end,
        SetValue = function(v)
            v = math.clamp(v, minVal, maxVal)
            local p = (v - minVal) / (maxVal - minVal)
            sliderFill.Size = UDim2.new(p, 0, 1, 0)
            knob.Position = UDim2.new(p, -8, 0, -5)
            label.Text = labelText .. ": " .. tostring(v)
            if onChange then onChange(v) end
        end
    }
end

-- ====== ЗАПОЛНЕНИЕ ВКЛАДОК ======
-- Aimbot
local aimToggle = createToggle(containerAimbot, "Aimbot", 0, aimbotEnabled, function(s) aimbotEnabled = s; settings.toggles.aimbot = s end)

local modeFrame = Instance.new("Frame")
modeFrame.Size = UDim2.new(1, 0, 0, 35)
modeFrame.Position = UDim2.new(0, 0, 0, 35)
modeFrame.BackgroundTransparency = 1
modeFrame.ZIndex = 900
modeFrame.Parent = containerAimbot
local modeLabel = Instance.new("TextLabel")
modeLabel.Size = UDim2.new(0.2, 0, 1, 0)
modeLabel.Text = "Mode:"
modeLabel.TextColor3 = Color3.fromRGB(180, 200, 255)
modeLabel.BackgroundTransparency = 1
modeLabel.Font = Enum.Font.Gotham
modeLabel.TextSize = 14
modeLabel.ZIndex = 902
modeLabel.Parent = modeFrame

local function createModeBtn(parent, text, x, default)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 60, 0, 28)
    btn.Position = UDim2.new(x, 0, 0.05, 0)
    btn.BackgroundColor3 = default and Color3.fromRGB(80, 120, 200) or Color3.fromRGB(40, 45, 70)
    btn.BorderSizePixel = 0
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextSize = 12
    btn.Font = Enum.Font.GothamBold
    btn.ZIndex = 902
    btn.Parent = parent
    return btn
end
local rageBtn = createModeBtn(modeFrame, "Rage", 0.25, aimbotMode == "Rage")
local legitBtn = createModeBtn(modeFrame, "Legit", 0.45, aimbotMode == "Legit")
local humanBtn = createModeBtn(modeFrame, "Human", 0.65, aimbotMode == "Human")

local function setMode(m)
    aimbotMode = m
    settings.aimbotMode = m
    rageBtn.BackgroundColor3 = (m == "Rage") and Color3.fromRGB(80,120,200) or Color3.fromRGB(40,45,70)
    legitBtn.BackgroundColor3 = (m == "Legit") and Color3.fromRGB(80,120,200) or Color3.fromRGB(40,45,70)
    humanBtn.BackgroundColor3 = (m == "Human") and Color3.fromRGB(80,120,200) or Color3.fromRGB(40,45,70)
end
rageBtn.MouseButton1Click:Connect(function() setMode("Rage") end)
legitBtn.MouseButton1Click:Connect(function() setMode("Legit") end)
humanBtn.MouseButton1Click:Connect(function() setMode("Human") end)

local fovSlider = createSlider(containerAimbot, "FOV", 80, 10, 360, fovValue, function(v) fovValue = v; settings.sliders.fov = v end)
local smoothSlider = createSlider(containerAimbot, "Smooth", 135, 1, 20, smoothValue, function(v) smoothValue = v; settings.sliders.smooth = v end)
local hitboxSlider = createSlider(containerAimbot, "Hitbox Size", 190, 1, 3, hitboxSize, function(v) hitboxSize = v; settings.sliders.hitbox = v end)
local triggerToggle = createToggle(containerAimbot, "Trigger Bot", 250, triggerBot, function(s) triggerBot = s; settings.toggles.triggerbot = s end)

-- Visual
local espToggle = createToggle(containerVisual, "ESP (3D Box + HP)", 0, espEnabled, function(s) espEnabled = s; settings.toggles.esp = s end)

-- Movement
local flyToggle = createToggle(containerMovement, "Fly", 0, flyEnabled, function(s) flyEnabled = s; settings.toggles.fly = s end)
local flySpeedSlider = createSlider(containerMovement, "Fly Speed", 40, 10, 200, flySpeed, function(v) flySpeed = v; settings.sliders.flyspeed = v end)
local noclipToggle = createToggle(containerMovement, "Noclip", 100, noclipEnabled, function(s) noclipEnabled = s; settings.toggles.noclip = s end)
local speedToggle = createToggle(containerMovement, "Speed Hack", 140, speedEnabled, function(s) speedEnabled = s; settings.toggles.speed = s end)
local speedSlider = createSlider(containerMovement, "Speed Value", 190, 16, 250, speedValue, function(v) speedValue = v; settings.sliders.speedval = v end)
local infJumpToggle = createToggle(containerMovement, "Infinite Jump", 250, infJumpEnabled, function(s) infJumpEnabled = s; settings.toggles.infjump = s end)

-- Weapon
local noRecoilToggle = createToggle(containerWeapon, "No Recoil", 0, noRecoilEnabled, function(s) noRecoilEnabled = s; settings.toggles.norecoil = s end)

-- Binds
local actions = {
    {name = "Aimbot", key = "aimbot"},
    {name = "Trigger Bot", key = "triggerbot"},
    {name = "Fly", key = "fly"},
    {name = "Noclip", key = "noclip"},
    {name = "Speed Hack", key = "speed"},
    {name = "Infinite Jump", key = "infjump"},
    {name = "ESP", key = "esp"},
    {name = "No Recoil", key = "norecoil"}
}
local bindsY = 0
for _, act in ipairs(actions) do
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 32)
    frame.Position = UDim2.new(0, 0, 0, bindsY)
    frame.BackgroundTransparency = 1
    frame.ZIndex = 900
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
    label.ZIndex = 902
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
    keyBtn.ZIndex = 902
    keyBtn.Parent = frame

    local listening = false
    keyBtn.MouseButton1Click:Connect(function()
        if listening then return end
        listening = true
        keyBtn.Text = "..."
        keyBtn.BackgroundColor3 = Color3.fromRGB(200, 100, 50)
        local conn
        conn = UserInputService.InputBegan:Connect(function(input, gp)
            if gp then return end
            if input.KeyCode ~= Enum.KeyCode.Unknown then
                listening = false
                keyBtn.BackgroundColor3 = Color3.fromRGB(40, 45, 70)
                keyBtn.Text = tostring(input.KeyCode):gsub("Enum.KeyCode.", "")
                binds[act.key] = input.KeyCode
                saveBinds()
                conn:Disconnect()
            end
        end)
        task.delay(5, function()
            if listening then
                listening = false
                keyBtn.BackgroundColor3 = Color3.fromRGB(40, 45, 70)
                keyBtn.Text = "None"
            end
        end)
    end)
    bindsY = bindsY + 38
end

updateCanvasSize(containerAimbot)
updateCanvasSize(containerVisual)
updateCanvasSize(containerMovement)
updateCanvasSize(containerWeapon)
updateCanvasSize(containerBinds)

-- Принудительная активация первой вкладки
selectTab("AimbotTab")

-- ====== УПРАВЛЕНИЕ: G – меню, Y – аимбот ======
UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.G then
        if mainFrame.Visible then animateHide() else animateShow() end
    elseif input.KeyCode == Enum.KeyCode.Y then
        aimbotEnabled = not aimbotEnabled
        aimToggle.SetState(aimbotEnabled, false)
        settings.toggles.aimbot = aimbotEnabled
    end
end)

-- ====== ОСНОВНАЯ ЛОГИКА ======
local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local hum = char:WaitForChild("Humanoid")
local rootPart = char:WaitForChild("HumanoidRootPart")

LocalPlayer.CharacterAdded:Connect(function(newChar)
    char = newChar
    hum = newChar:WaitForChild("Humanoid")
    rootPart = newChar:WaitForChild("HumanoidRootPart")
    if noclipEnabled then
        task.spawn(function()
            task.wait(0.5)
            for _, part in ipairs(newChar:GetDescendants()) do
                if part:IsA("BasePart") then part.CanCollide = false end
            end
        end)
    end
end)

-- JumpRequest (один раз)
UserInputService.JumpRequest:Connect(function()
    if infJumpEnabled and hum and hum.Parent then
        hum:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)

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
    local camPos = camera.CFrame.Position
    local forward = camera.CFrame.LookVector
    local fovRad = math.rad(fovValue)
    local best = nil
    local bestAngle = fovRad
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local targetHum = player.Character:FindFirstChild("Humanoid")
            local targetHead = player.Character:FindFirstChild("Head")
            if targetHum and targetHead and targetHum.Health > 0 then
                local dir = (targetHead.Position - camPos).Unit
                local angle = math.acos(math.clamp(forward:Dot(dir), -1, 1))
                if angle < bestAngle and canSeeTarget(targetHead) then
                    bestAngle = angle
                    best = { Head = targetHead, Player = player }
                end
            end
        end
    end
    return best
end

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

-- ESP: 3D Box + Имя + HP (полоска)
local espBoxes = {}

local function updateESP()
    if not espEnabled then
        for _, data in pairs(espBoxes) do
            for _, obj in pairs(data) do
                if type(obj) == "Instance" and obj:IsA("Instance") then
                    obj:Destroy()
                end
            end
        end
        espBoxes = {}
        return
    end

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local char = player.Character
            local hum = char:FindFirstChild("Humanoid")
            local root = char:FindFirstChild("HumanoidRootPart")
            local head = char:FindFirstChild("Head")
            if hum and root and head and hum.Health > 0 then
                local pos, onScreen = Camera:WorldToViewportPoint(root.Position)
                if onScreen then
                    if not espBoxes[player] then
                        local box = Instance.new("Frame")
                        box.Size = UDim2.new(0, 0, 0, 0)
                        box.BackgroundTransparency = 0.6
                        box.BackgroundColor3 = Color3.fromRGB(255,0,0)
                        box.BorderSizePixel = 1
                        box.BorderColor3 = Color3.fromRGB(0,255,0)
                        box.Visible = true
                        box.ZIndex = 900
                        box.Parent = screenGui

                        local nameLbl = Instance.new("TextLabel")
                        nameLbl.Size = UDim2.new(0, 120, 0, 16)
                        nameLbl.BackgroundTransparency = 1
                        nameLbl.TextColor3 = Color3.fromRGB(255,255,255)
                        nameLbl.Font = Enum.Font.GothamBold
                        nameLbl.TextSize = 12
                        nameLbl.TextStrokeTransparency = 0.3
                        nameLbl.TextStrokeColor3 = Color3.fromRGB(0,0,0)
                        nameLbl.Visible = true
                        nameLbl.ZIndex = 900
                        nameLbl.Parent = screenGui

                        local healthBg = Instance.new("Frame")
                        healthBg.Size = UDim2.new(0, 60, 0, 4)
                        healthBg.BackgroundColor3 = Color3.fromRGB(40,40,40)
                        healthBg.BorderSizePixel = 0
                        healthBg.Visible = true
                        healthBg.ZIndex = 900
                        healthBg.Parent = screenGui

                        local healthFill = Instance.new("Frame")
                        healthFill.Size = UDim2.new(1, 0, 1, 0)
                        healthFill.BackgroundColor3 = Color3.fromRGB(0,200,0)
                        healthFill.BorderSizePixel = 0
                        healthFill.ZIndex = 900
                        healthFill.Parent = healthBg

                        local healthTxt = Instance.new("TextLabel")
                        healthTxt.Size = UDim2.new(0, 60, 0, 14)
                        healthTxt.BackgroundTransparency = 1
                        healthTxt.TextColor3 = Color3.fromRGB(255,255,255)
                        healthTxt.Font = Enum.Font.Gotham
                        healthTxt.TextSize = 11
                        healthTxt.TextStrokeTransparency = 0.3
                        healthTxt.Visible = true
                        healthTxt.ZIndex = 900
                        healthTxt.Parent = screenGui

                        espBoxes[player] = { Box = box, NameLabel = nameLbl, HealthBar = healthBg, HealthFill = healthFill, HealthText = healthTxt }
                    end
                    local data = espBoxes[player]
                    local dist = (Camera.CFrame.Position - root.Position).Magnitude
                    local scale = 350 / math.max(dist, 1)
                    local boxSize = Vector2.new(2.5 * scale, 4.5 * scale)
                    local center = Vector2.new(pos.X, pos.Y - boxSize.Y/2 + 30)

                    data.Box.Size = UDim2.new(0, boxSize.X, 0, boxSize.Y)
                    data.Box.Position = UDim2.new(0, center.X - boxSize.X/2, 0, center.Y)
                    data.Box.BackgroundColor3 = Color3.fromRGB(255,0,0)
                    data.Box.BorderColor3 = Color3.fromRGB(0,255,0)

                    local health = hum.Health
                    local maxHealth = hum.MaxHealth
                    local hpPercent = math.clamp(health / maxHealth, 0, 1)

                    data.NameLabel.Text = player.Name .. " [" .. math.floor(health) .. " HP]"
                    data.NameLabel.Size = UDim2.new(0, 120, 0, 16)
                    data.NameLabel.Position = UDim2.new(0, center.X - 60, 0, center.Y - boxSize.Y - 18)
                    data.NameLabel.TextColor3 = hpPercent > 0.5 and Color3.fromRGB(0,255,0) or Color3.fromRGB(255,0,0)

                    data.HealthBar.Size = UDim2.new(0, boxSize.X, 0, 4)
                    data.HealthBar.Position = UDim2.new(0, center.X - boxSize.X/2, 0, center.Y + boxSize.Y + 2)
                    data.HealthFill.Size = UDim2.new(hpPercent, 0, 1, 0)
                    data.HealthFill.BackgroundColor3 = Color3.fromRGB(255 * (1 - hpPercent), 255 * hpPercent, 0)

                    data.HealthText.Text = math.floor(health) .. "/" .. math.floor(maxHealth)
                    data.HealthText.Size = UDim2.new(0, 60, 0, 14)
                    data.HealthText.Position = UDim2.new(0, center.X - 30, 0, center.Y + boxSize.Y + 8)
                else
                    if espBoxes[player] then
                        for _, obj in pairs(espBoxes[player]) do
                            if type(obj) == "Instance" and obj:IsA("Instance") then
                                obj.Visible = false
                            end
                        end
                    end
                end
            else
                if espBoxes[player] then
                    for _, obj in pairs(espBoxes[player]) do
                        if type(obj) == "Instance" and obj:IsA("Instance") then
                            obj:Destroy()
                        end
                    end
                    espBoxes[player] = nil
                end
            end
        end
    end
end

Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function() end)
end)

-- FOV Circle
local fovCircle = nil
if Drawing and Drawing.new then
    fovCircle = Drawing.new("Circle")
    fovCircle.Thickness = 2
    fovCircle.Color = Color3.fromRGB(80, 160, 255)
    fovCircle.Visible = false
end

-- Trigger Bot
task.spawn(function()
    while screenGui and screenGui.Parent do
        if triggerBot and aimbotEnabled then
            local target = getClosestInFOV()
            if target then
                VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
                task.wait(0.03)
                VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0)
                task.wait(math.random(50, 150) / 1000)
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

    -- No Recoil
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

    -- ESP
    updateESP()

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

-- Обработка биндов (без зацикливания)
UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.Unknown then return end
    for action, key in pairs(binds) do
        if key == input.KeyCode then
            if action == "aimbot" then
                aimbotEnabled = not aimbotEnabled
                aimToggle.SetState(aimbotEnabled, false)
                settings.toggles.aimbot = aimbotEnabled
            elseif action == "triggerbot" then
                triggerBot = not triggerBot
                triggerToggle.SetState(triggerBot, false)
                settings.toggles.triggerbot = triggerBot
            elseif action == "fly" then
                flyEnabled = not flyEnabled
                flyToggle.SetState(flyEnabled, false)
                settings.toggles.fly = flyEnabled
            elseif action == "noclip" then
                noclipEnabled = not noclipEnabled
                noclipToggle.SetState(noclipEnabled, false)
                settings.toggles.noclip = noclipEnabled
            elseif action == "speed" then
                speedEnabled = not speedEnabled
                speedToggle.SetState(speedEnabled, false)
                settings.toggles.speed = speedEnabled
            elseif action == "infjump" then
                infJumpEnabled = not infJumpEnabled
                infJumpToggle.SetState(infJumpEnabled, false)
                settings.toggles.infjump = infJumpEnabled
            elseif action == "esp" then
                espEnabled = not espEnabled
                espToggle.SetState(espEnabled, false)
                settings.toggles.esp = espEnabled
            elseif action == "norecoil" then
                noRecoilEnabled = not noRecoilEnabled
                noRecoilToggle.SetState(noRecoilEnabled, false)
                settings.toggles.norecoil = noRecoilEnabled
            end
            break
        end
    end
end)

print("✅ FlamePie v2.5 loaded! G - menu, Y - toggle aimbot.")
