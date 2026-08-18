-- =====================================================
-- ПОЛНОСТЬЮ ПЕРЕРАБОТАННЫЙ ЧИТ ДЛЯ ROBLOX v12
-- Работает в любом экзекьюторе (Synapse, Krnl, Wave и др.)
-- =====================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- ========== СОЗДАНИЕ ГЛАВНОГО GUI ==========
local screenGui = Instance.new("ScreenGui")
screenGui.Parent = LocalPlayer.PlayerGui

-- Главное окно
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 420, 0, 560)
mainFrame.Position = UDim2.new(0.5, -210, 0.5, -280)
mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
mainFrame.BackgroundTransparency = 0.15
mainFrame.BorderSizePixel = 0
mainFrame.ClipsDescendants = true
mainFrame.Parent = screenGui

-- Скругление (используем UICorner)
local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 8)
corner.Parent = mainFrame

-- Заголовок (перетаскивание)
local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 32)
titleBar.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
titleBar.BorderSizePixel = 0
titleBar.Parent = mainFrame

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 8)
titleCorner.Parent = titleBar

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, 0, 1, 0)
titleLabel.Text = "⚡ ADVANCED CHEAT v12 ⚡"
titleLabel.TextColor3 = Color3.fromRGB(255, 200, 50)
titleLabel.BackgroundTransparency = 1
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextSize = 18
titleLabel.Parent = titleBar

-- Кнопка закрытия (крестик)
local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 28, 0, 28)
closeBtn.Position = UDim2.new(1, -32, 0, 2)
closeBtn.Text = "✕"
closeBtn.TextColor3 = Color3.fromRGB(255, 80, 80)
closeBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
closeBtn.BorderSizePixel = 0
closeBtn.Font = Enum.Font.Gotham
closeBtn.TextSize = 16
closeBtn.Parent = titleBar
closeBtn.MouseButton1Click:Connect(function()
    mainFrame.Visible = false
end)

-- Контейнер с прокруткой
local scrollFrame = Instance.new("ScrollingFrame")
scrollFrame.Size = UDim2.new(1, -10, 1, -40)
scrollFrame.Position = UDim2.new(0, 5, 0, 36)
scrollFrame.BackgroundTransparency = 1
scrollFrame.BorderSizePixel = 0
scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
scrollFrame.ScrollBarThickness = 6
scrollFrame.Parent = mainFrame

local listLayout = Instance.new("UIListLayout")
listLayout.Padding = UDim.new(0, 6)
listLayout.SortOrder = Enum.SortOrder.LayoutOrder
listLayout.Parent = scrollFrame

-- ========== ПЕРЕТАСКИВАНИЕ ==========
local dragging = false
local dragStart, startPos
titleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = mainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then dragging = false end
        end)
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- ========== ВСПОМОГАТЕЛЬНЫЕ ФУНКЦИИ СОЗДАНИЯ ЭЛЕМЕНТОВ ==========
local function createCategory(title)
    local cat = Instance.new("Frame")
    cat.Size = UDim2.new(1, 0, 0, 32)
    cat.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    cat.BorderSizePixel = 0
    cat.Parent = scrollFrame

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, 0, 1, 0)
    lbl.Text = title
    lbl.TextColor3 = Color3.fromRGB(220, 220, 255)
    lbl.BackgroundTransparency = 1
    lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = 15
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Position = UDim2.new(0, 10, 0, 0)
    lbl.Parent = cat

    local line = Instance.new("Frame")
    line.Size = UDim2.new(0.9, 0, 0, 2)
    line.Position = UDim2.new(0.05, 0, 0.8, 0)
    line.BackgroundColor3 = Color3.fromRGB(100, 100, 150)
    line.BorderSizePixel = 0
    line.Parent = cat

    return cat
end

local function createCheckbox(name, default)
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, 0, 0, 28)
    container.BackgroundTransparency = 1
    container.Parent = scrollFrame

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.7, 0, 1, 0)
    label.Position = UDim2.new(0, 8, 0, 0)
    label.Text = name
    label.TextColor3 = Color3.fromRGB(200, 200, 210)
    label.BackgroundTransparency = 1
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Font = Enum.Font.Gotham
    label.TextSize = 14
    label.Parent = container

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 24, 0, 24)
    btn.Position = UDim2.new(0.85, 0, 0.02, 0)
    btn.BackgroundColor3 = default and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(60, 60, 70)
    btn.Text = ""
    btn.BorderSizePixel = 0
    btn.Parent = container

    local checked = default or false
    btn.MouseButton1Click:Connect(function()
        checked = not checked
        TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = checked and Color3.fromRGB(0,200,0) or Color3.fromRGB(60,60,70)}):Play()
    end)

    return {
        Button = btn,
        Get = function() return checked end,
        Toggle = function()
            checked = not checked
            TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = checked and Color3.fromRGB(0,200,0) or Color3.fromRGB(60,60,70)}):Play()
        end
    }
end

local function createSlider(name, min, max, default)
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, 0, 0, 30)
    container.BackgroundTransparency = 1
    container.Parent = scrollFrame

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.5, 0, 1, 0)
    label.Position = UDim2.new(0, 8, 0, 0)
    label.Text = name
    label.TextColor3 = Color3.fromRGB(200, 200, 210)
    label.BackgroundTransparency = 1
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Font = Enum.Font.Gotham
    label.TextSize = 14
    label.Parent = container

    local box = Instance.new("TextBox")
    box.Size = UDim2.new(0.25, 0, 1, 0)
    box.Position = UDim2.new(0.7, 0, 0, 0)
    box.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    box.Text = tostring(default)
    box.TextColor3 = Color3.fromRGB(255,255,255)
    box.Font = Enum.Font.Gotham
    box.TextSize = 13
    box.BorderSizePixel = 0
    box.Parent = container

    local value = default
    box.FocusLost:Connect(function()
        local num = tonumber(box.Text)
        if num then
            value = math.clamp(num, min, max)
            box.Text = tostring(value)
        else
            box.Text = tostring(value)
        end
    end)

    return {
        Box = box,
        Get = function()
            local num = tonumber(box.Text)
            if num then
                value = math.clamp(num, min, max)
                box.Text = tostring(value)
                return value
            else
                return value
            end
        end,
        Set = function(v)
            value = math.clamp(v, min, max)
            box.Text = tostring(value)
        end
    }
end

-- ========== ПОСТРОЕНИЕ ИНТЕРФЕЙСА ==========
-- Категория: Aimbot
createCategory("🎯 Aimbot")
local aimEnable = createCheckbox("Включить Aimbot", false)
local aimModeRage = createCheckbox("Rage режим (мгновенный)", true)
local aimModeLegit = createCheckbox("Legit режим (плавный)", false)
local fovSlider = createSlider("FOV (градусы)", 5, 180, 60)

-- Категория: ESP
createCategory("👁 ESP")
local espEnable = createCheckbox("Включить ESP", false)
local espBox = createCheckbox("3D Box", true)
local espHealth = createCheckbox("HP Bar + Имя", true)

-- Категория: Movement
createCategory("🏃 Movement")
local speedBox = createSlider("SpeedHack (WalkSpeed)", 16, 250, 50)
local noCdJump = createCheckbox("No CD Jump (без задержки)", false)
local spinBot = createCheckbox("SpinBot (вращение)", false)

-- Категория: Weapon
createCategory("🔫 Weapon")
local speedShot = createCheckbox("SpeedShot (быстрый огонь)", false)
local noRecoil = createCheckbox("No Recoil (без отдачи)", false)

-- Категория: Info
createCategory("ℹ Управление")
local infoLabel = Instance.new("TextLabel")
infoLabel.Size = UDim2.new(1, 0, 0, 24)
infoLabel.Text = "Insert - скрыть/показать меню"
infoLabel.TextColor3 = Color3.fromRGB(150,150,170)
infoLabel.BackgroundTransparency = 1
infoLabel.Font = Enum.Font.Gotham
infoLabel.TextSize = 13
infoLabel.TextXAlignment = Enum.TextXAlignment.Left
infoLabel.Position = UDim2.new(0, 10, 0, 0)
infoLabel.Parent = scrollFrame

-- Обновляем CanvasSize при добавлении элементов
listLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    scrollFrame.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y)
end)

-- ========== ПЕРЕМЕННЫЕ СОСТОЯНИЙ ==========
local aimActive = false
local aimRage = true
local aimLegit = false
local fovValue = 60

local espActive = false
local espBoxActive = true
local espHealthActive = true

local speedActive = false
local speedValue = 50
local noCdActive = false
local spinActive = false

local speedShotActive = false
local noRecoilActive = false

-- Обновление состояний при клике
aimEnable.Button.MouseButton1Click:Connect(function() aimActive = aimEnable.Get() end)
aimModeRage.Button.MouseButton1Click:Connect(function()
    aimRage = aimModeRage.Get()
    if aimRage then aimModeLegit.Toggle() end
end)
aimModeLegit.Button.MouseButton1Click:Connect(function()
    aimLegit = aimModeLegit.Get()
    if aimLegit then aimModeRage.Toggle() end
end)
-- Чтобы не было обоих включено, делаем взаимное выключение
aimModeRage.Button.MouseButton1Click:Connect(function()
    if aimModeRage.Get() then
        if aimModeLegit.Get() then aimModeLegit.Toggle() end
    end
end)
aimModeLegit.Button.MouseButton1Click:Connect(function()
    if aimModeLegit.Get() then
        if aimModeRage.Get() then aimModeRage.Toggle() end
    end
end)

espEnable.Button.MouseButton1Click:Connect(function() espActive = espEnable.Get() end)
espBox.Button.MouseButton1Click:Connect(function() espBoxActive = espBox.Get() end)
espHealth.Button.MouseButton1Click:Connect(function() espHealthActive = espHealth.Get() end)

noCdJump.Button.MouseButton1Click:Connect(function() noCdActive = noCdJump.Get() end)
spinBot.Button.MouseButton1Click:Connect(function() spinActive = spinBot.Get() end)
speedShot.Button.MouseButton1Click:Connect(function() speedShotActive = speedShot.Get() end)
noRecoil.Button.MouseButton1Click:Connect(function() noRecoilActive = noRecoil.Get() end)

-- FOV обновляем через Get
fovValue = fovSlider.Get()

-- ========== ESP СИСТЕМА (динамические GUI-элементы) ==========
local espObjects = {} -- [Player] = { Box, NameLabel, HealthBar, HealthText }

local function createESPForPlayer(plr)
    if plr == LocalPlayer then return end
    if espObjects[plr] then return end

    local box = Instance.new("Frame")
    box.Size = UDim2.new(0, 0, 0, 0)
    box.BackgroundTransparency = 0.6
    box.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
    box.BorderSizePixel = 1
    box.BorderColor3 = Color3.fromRGB(0, 255, 0)
    box.Visible = false
    box.Parent = screenGui

    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(0, 100, 0, 16)
    nameLabel.BackgroundTransparency = 1
    nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.TextSize = 12
    nameLabel.TextStrokeTransparency = 0.3
    nameLabel.TextStrokeColor3 = Color3.fromRGB(0,0,0)
    nameLabel.Visible = false
    nameLabel.Parent = screenGui

    local healthBarBg = Instance.new("Frame")
    healthBarBg.Size = UDim2.new(0, 60, 0, 4)
    healthBarBg.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    healthBarBg.BorderSizePixel = 0
    healthBarBg.Visible = false
    healthBarBg.Parent = screenGui

    local healthBar = Instance.new("Frame")
    healthBar.Size = UDim2.new(1, 0, 1, 0)
    healthBar.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
    healthBar.BorderSizePixel = 0
    healthBar.Parent = healthBarBg

    local healthText = Instance.new("TextLabel")
    healthText.Size = UDim2.new(0, 40, 0, 14)
    healthText.BackgroundTransparency = 1
    healthText.TextColor3 = Color3.fromRGB(255, 255, 255)
    healthText.Font = Enum.Font.Gotham
    healthText.TextSize = 11
    healthText.TextStrokeTransparency = 0.3
    healthText.Visible = false
    healthText.Parent = screenGui

    espObjects[plr] = {
        Box = box,
        NameLabel = nameLabel,
        HealthBarBg = healthBarBg,
        HealthBar = healthBar,
        HealthText = healthText
    }

    -- Обновление при перезаходе персонажа
    plr.CharacterAdded:Connect(function()
        -- просто чистим, чтобы пересоздать при следующем цикле (удалим объекты)
        if espObjects[plr] then
            for _, obj in pairs(espObjects[plr]) do
                if obj and obj:IsA("Instance") then obj:Destroy() end
            end
            espObjects[plr] = nil
        end
    end)
end

-- Создаём ESP для всех существующих игроков
for _, plr in ipairs(Players:GetPlayers()) do
    if plr ~= LocalPlayer then
        createESPForPlayer(plr)
    end
end

Players.PlayerAdded:Connect(function(plr)
    plr.CharacterAdded:Connect(function()
        createESPForPlayer(plr)
    end)
    createESPForPlayer(plr)
end)

-- Функция обновления позиций ESP
local function updateESP()
    if not espActive then
        -- Скрываем все объекты
        for _, data in pairs(espObjects) do
            data.Box.Visible = false
            data.NameLabel.Visible = false
            data.HealthBarBg.Visible = false
            data.HealthText.Visible = false
        end
        return
    end

    for plr, data in pairs(espObjects) do
        local char = plr.Character
        if not char or not char:FindFirstChild("HumanoidRootPart") then
            data.Box.Visible = false
            data.NameLabel.Visible = false
            data.HealthBarBg.Visible = false
            data.HealthText.Visible = false
            continue
        end

        local root = char.HumanoidRootPart
        local head = char:FindFirstChild("Head") or root
        local hum = char:FindFirstChild("Humanoid")

        -- Вычисляем позицию на экране
        local rootPos, onScreen = Camera:WorldToViewportPoint(root.Position)
        if not onScreen then
            data.Box.Visible = false
            data.NameLabel.Visible = false
            data.HealthBarBg.Visible = false
            data.HealthText.Visible = false
            continue
        end

        -- Расчёт размеров бокса (приблизительно)
        local headPos, _ = Camera:WorldToViewportPoint(head.Position)
        local dist = (Camera.CFrame.Position - root.Position).Magnitude
        local scale = 400 / dist  -- эмпирический коэффициент
        local boxSize = Vector2.new(2.5 * scale, 4.5 * scale)
        local center = Vector2.new(rootPos.X, rootPos.Y - boxSize.Y/2 + 30)

        -- Обновляем Box
        if espBoxActive then
            data.Box.Visible = true
            data.Box.Size = UDim2.new(0, boxSize.X, 0, boxSize.Y)
            data.Box.Position = UDim2.new(0, center.X - boxSize.X/2, 0, center.Y)
            data.Box.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
            data.Box.BorderColor3 = Color3.fromRGB(0, 255, 0)
        else
            data.Box.Visible = false
        end

        -- Имя и HP
        if espHealthActive and hum then
            local health = hum.Health
            local maxHealth = hum.MaxHealth
            local healthPercent = math.clamp(health / maxHealth, 0, 1)

            -- Имя над боксом
            data.NameLabel.Visible = true
            data.NameLabel.Text = plr.Name .. " [" .. math.floor(health) .. " HP]"
            data.NameLabel.Size = UDim2.new(0, 120, 0, 16)
            data.NameLabel.Position = UDim2.new(0, center.X - 60, 0, center.Y - boxSize.Y - 18)
            data.NameLabel.TextColor3 = healthPercent > 0.5 and Color3.fromRGB(0,255,0) or Color3.fromRGB(255,0,0)

            -- Полоска HP под боксом
            data.HealthBarBg.Visible = true
            data.HealthBarBg.Size = UDim2.new(0, boxSize.X, 0, 4)
            data.HealthBarBg.Position = UDim2.new(0, center.X - boxSize.X/2, 0, center.Y + boxSize.Y + 2)
            data.HealthBar.Size = UDim2.new(healthPercent, 0, 1, 0)
            data.HealthBar.BackgroundColor3 = Color3.fromRGB(255 * (1 - healthPercent), 255 * healthPercent, 0)

            -- Текст HP (дополнительно)
            data.HealthText.Visible = true
            data.HealthText.Text = math.floor(health) .. "/" .. math.floor(maxHealth)
            data.HealthText.Size = UDim2.new(0, 60, 0, 14)
            data.HealthText.Position = UDim2.new(0, center.X - 30, 0, center.Y + boxSize.Y + 8)
            data.HealthText.TextColor3 = Color3.fromRGB(255,255,255)
        else
            data.NameLabel.Visible = false
            data.HealthBarBg.Visible = false
            data.HealthText.Visible = false
        end
    end
end

-- ========== AIMBOT С FOV ==========
local function getClosestEnemyInFOV()
    local fov = fovSlider.Get()
    local fovRad = math.rad(fov)
    local closest, minAngle = nil, math.huge

    local cameraCF = Camera.CFrame
    local cameraPos = cameraCF.Position
    local forward = cameraCF.LookVector

    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
            local root = plr.Character.HumanoidRootPart
            local targetPos = root.Position
            local dir = (targetPos - cameraPos).Unit
            local angle = math.acos(math.clamp(forward:Dot(dir), -1, 1))
            if angle < fovRad then
                if angle < minAngle then
                    minAngle = angle
                    closest = plr
                end
            end
        end
    end
    return closest
end

-- ========== ОСНОВНОЙ ЦИКЛ (RenderStepped) ==========
RunService.RenderStepped:Connect(function(deltaTime)
    local char = LocalPlayer.Character
    if not char then return end
    local hum = char:FindFirstChild("Humanoid")
    if not hum then return end

    -- 1. SpeedHack
    local spd = speedBox.Get()
    if spd > 16 then
        hum.WalkSpeed = spd
    else
        hum.WalkSpeed = 16
    end

    -- 2. No CD Jump
    if noCdActive then
        hum.JumpPower = 70
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
            hum.Jump = true
        end
    else
        hum.JumpPower = 50
    end

    -- 3. SpinBot
    local rootPart = char:FindFirstChild("HumanoidRootPart")
    if spinActive and rootPart then
        local angle = math.rad(360 * deltaTime) -- 360 град/сек
        rootPart.CFrame = rootPart.CFrame * CFrame.Angles(0, angle, 0)
    end

    -- 4. SpeedShot & No Recoil (оружие в руках)
    local tool = char:FindFirstChildOfClass("Tool")
    if tool then
        if speedShotActive then
            for _, child in ipairs(tool:GetDescendants()) do
                if child:IsA("NumberValue") and child.Name == "CooldownTime" then
                    child.Value = 0
                end
            end
        end
        if noRecoilActive then
            for _, child in ipairs(tool:GetDescendants()) do
                if child:IsA("NumberValue") and (child.Name == "Recoil" or child.Name == "CameraRecoil") then
                    child.Value = 0
                end
            end
        end
    end

    -- 5. ESP (обновление позиций)
    updateESP()

    -- 6. Aimbot
    if aimActive then
        local target = getClosestEnemyInFOV()
        if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
            local targetPos = target.Character.HumanoidRootPart.Position
            local cameraPos = Camera.CFrame.Position
            local lookAt = CFrame.lookAt(cameraPos, targetPos)

            if aimModeRage.Get() and not aimModeLegit.Get() then
                -- Rage: мгновенно
                Camera.CFrame = lookAt
            elseif aimModeLegit.Get() and not aimModeRage.Get() then
                -- Legit: плавно через Lerp
                Camera.CFrame = Camera.CFrame:Lerp(lookAt, 0.2)
            end
        end
    end
end)

-- ========== КЛАВИША INSERT ДЛЯ ПОКАЗА/СКРЫТИЯ ==========
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.Insert then
        mainFrame.Visible = not mainFrame.Visible
    end
end)

print("✅ Чит v12 загружен. Нажмите Insert для меню.")
