--[[
  ФИНАЛЬНАЯ ВЕРСИЯ С LOCKHEAD, ПРОВЕРКОЙ СТЕН, ДЕЛЕЕМ 0.15с И DEBUG-ДИАГНОСТИКОЙ
--]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local player = Players.LocalPlayer
local mouse = player:GetMouse()

-- Функция логирования
local function debugLog(msg)
    print("[DEBUG - kajjrtf]: " .. tostring(msg))
end

debugLog("Инициализация скрипта...")

-- Удаление старого GUI
local oldGui = player.PlayerGui:FindFirstChild("kajjrtf")
if oldGui then 
    oldGui:Destroy() 
    debugLog("Удален предыдущий GUI.")
end

-- Очистка старых Drawing
if getgc then
    pcall(function()
        for _, obj in ipairs(getgc(true)) do
            if type(obj) == "table" and rawget(obj, "ClassName") == "Drawing" then
                pcall(function() obj:Remove() end)
            end
        end
    end)
end

-- Цветовая схема
local colors = {
    bg = Color3.fromRGB(40, 30, 20),
    header = Color3.fromRGB(60, 45, 25),
    accent = Color3.fromRGB(255, 165, 0),
    accent2 = Color3.fromRGB(255, 200, 50),
    text = Color3.fromRGB(255, 220, 150),
    on = Color3.fromRGB(0, 200, 0),
    off = Color3.fromRGB(200, 50, 0),
}

local guiPos = UDim2.new(0.5, -200, 0.5, -250)
local originalWalkSpeed = 16
local visibleSince = {} -- Таблица таймеров задержки выстрела из-за стены (0.1 - 0.2 сек)

-- === СОЗДАНИЕ GUI ===
local function createGUI()
    local gui = Instance.new("ScreenGui")
    gui.Name = "kajjrtf"
    gui.ResetOnSpawn = false
    gui.Parent = player.PlayerGui

    -- Загрузочный экран
    local loading = Instance.new("Frame")
    loading.Size = UDim2.new(0, 450, 0, 120)
    loading.Position = UDim2.new(0.5, -225, 0.5, -60)
    loading.BackgroundColor3 = colors.bg
    loading.BorderSizePixel = 0
    loading.Parent = gui
    Instance.new("UICorner", loading).CornerRadius = UDim.new(0, 12)

    local loadTitle = Instance.new("TextLabel", loading)
    loadTitle.Size = UDim2.new(1, 0, 0.5, 0)
    loadTitle.BackgroundTransparency = 1
    loadTitle.Text = "ЗАГРУЗКА ЧИТОВ"
    loadTitle.TextColor3 = colors.text
    loadTitle.TextScaled = true
    loadTitle.Font = Enum.Font.GothamBold

    local progress = Instance.new("Frame", loading)
    progress.Size = UDim2.new(0, 0, 0, 12)
    progress.Position = UDim2.new(0, 20, 0.7, 0)
    progress.BackgroundColor3 = colors.accent
    progress.BorderSizePixel = 0
    Instance.new("UICorner", progress).CornerRadius = UDim.new(0, 6)

    local status = Instance.new("TextLabel", loading)
    status.Size = UDim2.new(1, -40, 0, 20)
    status.Position = UDim2.new(0, 20, 0.85, 0)
    status.BackgroundTransparency = 1
    status.Text = "Инициализация..."
    status.TextColor3 = colors.text
    status.TextXAlignment = Enum.TextXAlignment.Left
    status.TextScaled = true
    status.Font = Enum.Font.Gotham

    local function updateLoading(text, percent)
        status.Text = text
        progress.Size = UDim2.new(percent, 0, 0, 12)
    end

    -- Основное меню
    local menu = Instance.new("Frame")
    menu.Name = "Menu"
    menu.Size = UDim2.new(0, 400, 0, 500)
    menu.Position = guiPos
    menu.BackgroundColor3 = colors.bg
    menu.BorderSizePixel = 0
    menu.Visible = false
    menu.Parent = gui
    Instance.new("UICorner", menu).CornerRadius = UDim.new(0, 10)

    -- Заголовок
    local header = Instance.new("Frame", menu)
    header.Size = UDim2.new(1, 0, 0, 35)
    header.BackgroundColor3 = colors.header
    header.BorderSizePixel = 0
    Instance.new("UICorner", header).CornerRadius = UDim.new(0, 10)

    local title = Instance.new("TextLabel", header)
    title.Size = UDim2.new(1, -60, 1, 0)
    title.Position = UDim2.new(0, 15, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = "kajjrtf"
    title.TextColor3 = colors.accent2
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.TextScaled = true
    title.Font = Enum.Font.GothamBold

    local closeBtn = Instance.new("TextButton", header)
    closeBtn.Size = UDim2.new(0, 35, 1, 0)
    closeBtn.Position = UDim2.new(1, -35, 0, 0)
    closeBtn.BackgroundTransparency = 1
    closeBtn.Text = "✕"
    closeBtn.TextColor3 = Color3.fromRGB(255, 80, 80)
    closeBtn.TextScaled = true
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.MouseButton1Click:Connect(function()
        local t1 = TweenService:Create(menu, TweenInfo.new(0.2), {Size = UDim2.new(0, 0, 0, 0)})
        local t2 = TweenService:Create(menu, TweenInfo.new(0.2), {Position = UDim2.new(0.5, 0, -0.5, 0)})
        t1:Play(); t2:Play()
        task.wait(0.25)
        menu.Visible = false
        menu.Size = UDim2.new(0, 400, 0, 500)
        menu.Position = guiPos
    end)

    -- Перетаскивание
    local dragStart, dragPos, isDragging = nil, nil, false
    header.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragStart = input.Position
            dragPos = menu.Position
            isDragging = true
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if isDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            menu.Position = UDim2.new(dragPos.X.Scale, dragPos.X.Offset + delta.X, dragPos.Y.Scale, dragPos.Y.Offset + delta.Y)
            guiPos = menu.Position
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then isDragging = false end
    end)

    -- Вкладки
    local tabContainer = Instance.new("Frame", menu)
    tabContainer.Size = UDim2.new(1, 0, 0, 30)
    tabContainer.Position = UDim2.new(0, 0, 0, 35)
    tabContainer.BackgroundColor3 = colors.header
    tabContainer.BorderSizePixel = 0

    local content = Instance.new("Frame", menu)
    content.Name = "Content"
    content.Size = UDim2.new(1, 0, 1, -65)
    content.Position = UDim2.new(0, 0, 0, 65)
    content.BackgroundTransparency = 1
    content.BorderSizePixel = 0

    local tabs = {"Aim", "Visuals", "Movement", "Misc"}
    local tabButtons = {}
    local currentTab = nil
    local tabContents = {}

    for i, name in ipairs(tabs) do
        local btn = Instance.new("TextButton", tabContainer)
        btn.Size = UDim2.new(0, 100, 1, 0)
        btn.Position = UDim2.new((i-1)/#tabs, 0, 0, 0)
        btn.BackgroundTransparency = 1
        btn.Text = name
        btn.TextColor3 = colors.text
        btn.TextScaled = true
        btn.Font = Enum.Font.GothamBold
        table.insert(tabButtons, btn)

        local tabScroll = Instance.new("ScrollingFrame", content)
        tabScroll.Name = name .. "Tab"
        tabScroll.Size = UDim2.new(1, 0, 1, 0)
        tabScroll.BackgroundTransparency = 1
        tabScroll.BorderSizePixel = 0
        tabScroll.ScrollBarThickness = 4
        tabScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
        tabScroll.Visible = false
        tabContents[name] = tabScroll

        btn.MouseButton1Click:Connect(function()
            if currentTab and tabContents[currentTab] then tabContents[currentTab].Visible = false end
            currentTab = name
            tabContents[name].Visible = true
            for _, b in ipairs(tabButtons) do
                b.TextColor3 = colors.text
                b.BackgroundTransparency = 1
                b.BackgroundColor3 = Color3.fromRGB(0,0,0)
            end
            btn.TextColor3 = colors.accent2
            btn.BackgroundTransparency = 0
            btn.BackgroundColor3 = colors.accent
        end)
    end

    if #tabButtons > 0 then
        local name = tabs[1]
        currentTab = name
        tabContents[name].Visible = true
        tabButtons[1].TextColor3 = colors.accent2
        tabButtons[1].BackgroundTransparency = 0
        tabButtons[1].BackgroundColor3 = colors.accent
    end

    -- Переключатели и слайдеры
    local function createToggle(parent, text, y, default)
        local f = Instance.new("Frame", parent)
        f.Size = UDim2.new(1, -20, 0, 30)
        f.Position = UDim2.new(0, 10, 0, y)
        f.BackgroundTransparency = 1

        local lbl = Instance.new("TextLabel", f)
        lbl.Size = UDim2.new(0.6, 0, 1, 0)
        lbl.BackgroundTransparency = 1
        lbl.Text = text
        lbl.TextColor3 = colors.text
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.TextScaled = true
        lbl.Font = Enum.Font.Gotham

        local btn = Instance.new("TextButton", f)
        btn.Size = UDim2.new(0, 60, 1, 0)
        btn.Position = UDim2.new(1, -70, 0, 0)
        btn.BackgroundColor3 = default and colors.on or colors.off
        btn.Text = default and "ON" or "OFF"
        btn.TextColor3 = Color3.new(1,1,1)
        btn.TextScaled = true
        btn.Font = Enum.Font.GothamBold
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)

        local state = default or false
        btn.MouseButton1Click:Connect(function()
            state = not state
            local newColor = state and colors.on or colors.off
            TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = newColor}):Play()
            btn.Text = state and "ON" or "OFF"
            debugLog("Переключатель '" .. text .. "' установлен в: " .. tostring(state))
        end)
        return function() return state end
    end

    local function createSlider(parent, text, y, min, max, default, suffix)
        local f = Instance.new("Frame", parent)
        f.Size = UDim2.new(1, -20, 0, 30)
        f.Position = UDim2.new(0, 10, 0, y)
        f.BackgroundTransparency = 1

        local lbl = Instance.new("TextLabel", f)
        lbl.Size = UDim2.new(0.5, 0, 1, 0)
        lbl.BackgroundTransparency = 1
        lbl.Text = text
        lbl.TextColor3 = colors.text
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.TextScaled = true
        lbl.Font = Enum.Font.Gotham

        local val = Instance.new("TextLabel", f)
        val.Size = UDim2.new(0.2, 0, 1, 0)
        val.Position = UDim2.new(0.5, 0, 0, 0)
        val.BackgroundTransparency = 1
        val.Text = tostring(default)..(suffix or "")
        val.TextColor3 = colors.text
        val.TextScaled = true
        val.Font = Enum.Font.Gotham

        local slider = Instance.new("Frame", f)
        slider.Size = UDim2.new(0.25, 0, 0.6, 0)
        slider.Position = UDim2.new(0.72, 0, 0.2, 0)
        slider.BackgroundColor3 = Color3.fromRGB(80, 70, 60)
        slider.BorderSizePixel = 0
        Instance.new("UICorner", slider).CornerRadius = UDim.new(0, 4)

        local fill = Instance.new("Frame", slider)
        fill.Size = UDim2.new((default-min)/(max-min), 0, 1, 0)
        fill.BackgroundColor3 = colors.accent
        fill.BorderSizePixel = 0
        Instance.new("UICorner", fill).CornerRadius = UDim.new(0, 4)

        local dragging = false
        local function update(v)
            v = math.clamp(v, min, max)
            fill.Size = UDim2.new((v-min)/(max-min), 0, 1, 0)
            val.Text = tostring(math.round(v))..(suffix or "")
            return v
        end
        local value = update(default)

        local function onMouseMove()
            if dragging then
                local pos = mouse.X - slider.AbsolutePosition.X
                local percent = math.clamp(pos / slider.AbsoluteSize.X, 0, 1)
                value = update(min + (max-min)*percent)
            end
        end

        mouse.Move:Connect(onMouseMove)
        slider.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = true
                onMouseMove()
            end
        end)
        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
        end)

        return function() return value end
    end

    -- Настройка меню
    local y = 10
    local aimTab = tabContents["Aim"]
    local getAimEnabled = createToggle(aimTab, "AimBot", y, false)
    y = y + 35
    local getLockhead = createToggle(aimTab, "Лютый LockHead", y, true)
    y = y + 35
    local getAimFOV = createSlider(aimTab, "FOV", y, 0, 360, 120, "°")
    y = y + 35
    local getAimSmooth = createSlider(aimTab, "Плавность (при выкл. Lockhead)", y, 1, 20, 1, "")
    y = y + 35
    local getTriggerBot = createToggle(aimTab, "TriggerBot", y, false)
    aimTab.CanvasSize = UDim2.new(0, 0, 0, y+20)

    y = 10
    local visTab = tabContents["Visuals"]
    local getWHEnabled = createToggle(visTab, "WallHack (ESP)", y, false)
    y = y + 35
    local getWHBox = createToggle(visTab, "3D Box", y, true)
    y = y + 35
    local getWHSkeleton = createToggle(visTab, "Skeleton", y, true)
    y = y + 35
    local getWHTrail = createToggle(visTab, "Trail", y, true)
    y = y + 35
    local getWHHighlight = createToggle(visTab, "Highlight (обводка)", y, true)
    y = y + 35
    local getWHChams = createToggle(visTab, "Chams (Neon)", y, false)
    visTab.CanvasSize = UDim2.new(0, 0, 0, y+20)

    y = 10
    local movTab = tabContents["Movement"]
    local getSpinEnabled = createToggle(movTab, "SpinBot", y, false)
    y = y + 35
    local getSpinSpeed = createSlider(movTab, "Скорость вращения", y, 1, 30, 10, "")
    y = y + 35
    local getSpinDirY = createSlider(movTab, "Направление Y", y, -100, 100, 100, "")
    y = y + 35
    local getBHEnabled = createToggle(movTab, "BunnyHop", y, false)
    y = y + 35
    local getSpeedHack = createToggle(movTab, "SpeedHack", y, false)
    y = y + 35
    local getSpeedValue = createSlider(movTab, "Скорость", y, 16, 100, 50, "")
    movTab.CanvasSize = UDim2.new(0, 0, 0, y+20)

    y = 10
    local miscTab = tabContents["Misc"]
    local getRapidFire = createToggle(miscTab, "Rapid Fire", y, false)
    y = y + 35
    local getFly = createToggle(miscTab, "Fly", y, false)
    y = y + 35
    local getNoclip = createToggle(miscTab, "Noclip", y, false)
    miscTab.CanvasSize = UDim2.new(0, 0, 0, y+20)

    -- Анимация загрузки
    local steps = {"Инициализация...", "Настройка Аима & LockHead...", "Настройка Visuals...", "Запуск потоков...", "Готово!"}
    local percents = {0.2, 0.5, 0.7, 0.9, 1.0}
    for i = 1, #steps do
        updateLoading(steps[i], percents[i])
        task.wait(0.08)
    end

    loading:Destroy()
    menu.Visible = true
    menu.Size = UDim2.new(0, 0, 0, 0)
    TweenService:Create(menu, TweenInfo.new(0.3, Enum.EasingStyle.Back), {Size = UDim2.new(0, 400, 0, 500)}):Play()

    return {
        getAimEnabled = getAimEnabled,
        getLockhead = getLockhead,
        getAimFOV = getAimFOV,
        getAimSmooth = getAimSmooth,
        getTriggerBot = getTriggerBot,
        getWHEnabled = getWHEnabled,
        getWHBox = getWHBox,
        getWHSkeleton = getWHSkeleton,
        getWHTrail = getWHTrail,
        getWHHighlight = getWHHighlight,
        getWHChams = getWHChams,
        getSpinEnabled = getSpinEnabled,
        getSpinSpeed = getSpinSpeed,
        getSpinDirY = getSpinDirY,
        getBHEnabled = getBHEnabled,
        getSpeedHack = getSpeedHack,
        getSpeedValue = getSpeedValue,
        getRapidFire = getRapidFire,
        getFly = getFly,
        getNoclip = getNoclip,
    }
end

local settings = createGUI()

-- === ПРОВЕРКИ И ВАЛИДАЦИЯ ИГРОКОВ ===
local function isAlive(char)
    return char and char:FindFirstChild("Humanoid") and char.Humanoid.Health > 0
end

local function hasWeapon()
    local char = player.Character
    return char and char:FindFirstChildWhichIsA("Tool") ~= nil
end

-- Рейкаст с проверкой на стены
local function isVisible(origin, targetPos, myChar, targetChar)
    local dir = targetPos - origin
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Blacklist
    params.FilterDescendantsInstances = {myChar}
    local result = workspace:Raycast(origin, dir, params)
    if result then
        if result.Instance and result.Instance:IsDescendantOf(targetChar) then
            return true
        end
        return false
    end
    return true
end

-- ДИАГНОСТИКА И ЗАГРУЗКА ИГРОКОВ ПРИ СТАРТЕ
local function runPlayerDiagnostics()
    local allPlrs = Players:GetPlayers()
    local totalOnServer = #allPlrs
    local successfullyLoaded = 0
    local failureReasons = {}

    debugLog("==========================================")
    debugLog("ЗАПУСК ДИАГНОСТИКИ СЕРВЕРА...")

    for _, plr in ipairs(allPlrs) do
        if plr == player then
            -- Пропускаем локального игрока
        else
            local char = plr.Character
            if not char then
                table.insert(failureReasons, string.format("Игрок '%s': Персонаж еще не заспавнился (Character = nil)", plr.Name))
            elseif not char:FindFirstChild("Humanoid") then
                table.insert(failureReasons, string.format("Игрок '%s': Нет компонента Humanoid", plr.Name))
            elseif char.Humanoid.Health <= 0 then
                table.insert(failureReasons, string.format("Игрок '%s': Персонаж мертв (Health <= 0)", plr.Name))
            elseif not char:FindFirstChild("Head") then
                table.insert(failureReasons, string.format("Игрок '%s': Отсутствует голова (Head)", plr.Name))
            else
                successfullyLoaded = successfullyLoaded + 1
            end
        end
    end

    -- Учитываем LocalPlayer в общей статистике
    local targetsAvailable = totalOnServer - 1
    debugLog(string.format("СТАТУС ИГРОКОВ: Успешно загружено %d из %d целых целей на сервере (Всего игроков: %d).", successfullyLoaded, targetsAvailable, totalOnServer))

    if successfullyLoaded < targetsAvailable then
        debugLog("ПРИЧИНЫ НЕПОЛНОЙ ЗАГРУЗКИ ИГРОКОВ:")
        for _, reason in ipairs(failureReasons) do
            debugLog("  [!] " .. reason)
        end
    else
        debugLog("ВСЕ ИГРОКИ НА СЕРВЕРЕ УСПЕШНО ИНИЦИАЛИЗИРОВАНЫ И ГОТОВЫ!")
    end
    debugLog("==========================================")
end

runPlayerDiagnostics()

-- Поиск цели для AIM (С проверкой стен и задержкой 0.1-0.2 сек)
local function getClosestTarget(fov)
    local closest, minDist = nil, fov
    local myChar = player.Character
    if not myChar then return nil end
    local camera = workspace.CurrentCamera

    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= player and plr.Character and isAlive(plr.Character) then
            local char = plr.Character
            local head = char:FindFirstChild("Head")
            if head then
                local pos, onScreen = camera:WorldToViewportPoint(head.Position)
                if onScreen then
                    local center = camera.ViewportSize / 2
                    local dist = (Vector2.new(pos.X, pos.Y) - Vector2.new(center.X, center.Y)).Magnitude
                    
                    if dist < minDist then
                        local origin = camera.CFrame.Position
                        local canSee = isVisible(origin, head.Position, myChar, char)

                        if canSee then
                            -- Засекаем время появления врага из-за стены
                            if not visibleSince[plr] then
                                visibleSince[plr] = tick()
                            end

                            -- Ждем от 0.1 до 0.2 секунд (задержка реакции)
                            local timeVisible = tick() - visibleSince[plr]
                            if timeVisible >= 0.15 then
                                minDist = dist
                                closest = char
                            end
                        else
                            -- Игрок за стеной -> сбрасываем таймер
                            visibleSince[plr] = nil
                        end
                    end
                end
            end
        end
    end
    return closest
end

-- Visual Drawing Elements
local fovCircle = Drawing.new("Circle")
fovCircle.Thickness = 2
fovCircle.Color = Color3.fromRGB(255, 165, 0)
fovCircle.Transparency = 0.4
fovCircle.Visible = false
fovCircle.Filled = false

local aimEnabled = false
UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.Y then
        aimEnabled = not aimEnabled
        debugLog("Горячая клавиша AimBot (Y): " .. tostring(aimEnabled))
    end
end)

-- Пулы отрисовки
local function createLinePool(count)
    local pool = {}
    for i = 1, count do
        local line = Drawing.new("Line")
        line.Visible = false
        table.insert(pool, line)
    end
    return pool
end

local boxLines = createLinePool(200)
local skelLines = createLinePool(300)
local trailLines = createLinePool(50)

local function resetPool(pool)
    for _, line in ipairs(pool) do line.Visible = false end
end

local function getLine(pool)
    for _, line in ipairs(pool) do
        if not line.Visible then
            line.Visible = true
            return line
        end
    end
    local newLine = Drawing.new("Line")
    table.insert(pool, newLine)
    newLine.Visible = true
    return newLine
end

-- Highlights / Chams
local highlights = {}
local chamsCopies = {}

local function createChamsCopy(char)
    if not char then return nil end
    local clone = Instance.new("Model")
    clone.Name = char.Name .. "_Chams"
    clone.Archivable = false
    for _, child in ipairs(char:GetChildren()) do
        if child:IsA("BasePart") then
            local newPart = Instance.new("Part")
            newPart.Name = child.Name
            newPart.Size = child.Size
            newPart.CFrame = child.CFrame
            newPart.Material = Enum.Material.Neon
            newPart.Color = Color3.fromRGB(255, 165, 0)
            newPart.Transparency = 0.6
            newPart.Anchored = true
            newPart.CanCollide = false
            newPart.Parent = clone
        end
    end
    clone.Parent = workspace
    return clone
end

local function updateChams(char, enable)
    if enable then
        if not chamsCopies[char] then
            chamsCopies[char] = createChamsCopy(char)
        end
    else
        if chamsCopies[char] then
            chamsCopies[char]:Destroy()
            chamsCopies[char] = nil
        end
    end
end

local function updateHighlight(char, enable)
    if enable then
        if not highlights[char] then
            local hl = Instance.new("Highlight")
            hl.FillColor = Color3.fromRGB(255, 200, 0)
            hl.OutlineColor = Color3.fromRGB(255, 100, 0)
            hl.FillTransparency = 0.5
            hl.OutlineTransparency = 0.3
            hl.Parent = char
            highlights[char] = hl
        end
    else
        if highlights[char] then
            highlights[char]:Destroy()
            highlights[char] = nil
        end
    end
end

local skeletonConnections = {
    {"Head", "Torso"}, {"Torso", "LeftArm"}, {"Torso", "RightArm"},
    {"Torso", "LeftLeg"}, {"Torso", "RightLeg"}, {"Head", "UpperTorso"},
    {"UpperTorso", "LowerTorso"}, {"UpperTorso", "LeftUpperArm"},
    {"LeftUpperArm", "LeftLowerArm"}, {"UpperTorso", "RightUpperArm"},
    {"RightUpperArm", "RightLowerArm"}, {"LowerTorso", "LeftUpperLeg"},
    {"LeftUpperLeg", "LeftLowerLeg"}, {"LowerTorso", "RightUpperLeg"},
    {"RightUpperLeg", "RightLowerLeg"}
}

local function getSkeletonPoints(char)
    local parts = {}
    for _, conn in ipairs(skeletonConnections) do
        local p1 = char:FindFirstChild(conn[1])
        local p2 = char:FindFirstChild(conn[2])
        if p1 and p2 then table.insert(parts, {p1.Position, p2.Position}) end
    end
    return parts
end

-- === АВТОМАТИЧЕСКАЯ ПРОВЕРКА ВСЕХ ИГРОКОВ КАЖДЫЕ 0.5 СЕКУНДЫ ===
task.spawn(function()
    debugLog("Запущена фоновая проверка игроков (каждые 0.5 сек)...")
    while true do
        task.wait(0.5)
        local allPlayers = Players:GetPlayers()
        for _, plr in ipairs(allPlayers) do
            if plr ~= player and plr.Character and isAlive(plr.Character) then
                local char = plr.Character
                if settings.getWHEnabled() then
                    if settings.getWHHighlight() then updateHighlight(char, true) end
                    if settings.getWHChams() then updateChams(char, true) end
                end
            end
        end
    end
end)

local lastTriggerClick = 0
local wasNoclip = false

-- === ОСНОВНОЙ РЕНДЕР-ЦИКЛ ===
RunService.RenderStepped:Connect(function(dt)
    local camera = workspace.CurrentCamera
    if not camera then return end
    local viewport = camera.ViewportSize
    local char = player.Character
    local myRoot = char and char:FindFirstChild("HumanoidRootPart")

    local aimActive = settings.getAimEnabled() or aimEnabled
    local fov = settings.getAimFOV()

    if aimActive then
        fovCircle.Visible = true
        fovCircle.Position = Vector2.new(viewport.X / 2, viewport.Y / 2)
        fovCircle.Radius = fov
    else
        fovCircle.Visible = false
    end

    -- AIM / LOCKHEAD
    if aimActive and hasWeapon() then
        local target = getClosestTarget(fov)
        if target then
            local head = target:FindFirstChild("Head")
            if head then
                if settings.getLockhead() then
                    -- ЛЮТЫЙ LOCKHEAD: Мгновенная жесткая привязка прицела прямо на голову
                    camera.CFrame = CFrame.lookAt(camera.CFrame.Position, head.Position)
                else
                    -- Плавный наводчик
                    local current = camera.CFrame
                    local newCF = CFrame.lookAt(current.Position, head.Position)
                    local smooth = settings.getAimSmooth()
                    local lerp = 1 - math.exp(-10 * dt / math.max(smooth, 1))
                    camera.CFrame = current:Lerp(newCF, math.min(lerp, 1))
                end
            end
        end
    end

    -- TRIGGERBOT
    if settings.getTriggerBot() and hasWeapon() then
        local now = tick()
        if now - lastTriggerClick >= 0.08 then
            local ray = camera:ViewportPointToRay(viewport.X / 2, viewport.Y / 2, 0)
            local params = RaycastParams.new()
            params.FilterType = Enum.RaycastFilterType.Blacklist
            params.FilterDescendantsInstances = {char}
            local result = workspace:Raycast(ray.Origin, ray.Direction * 500, params)
            if result and result.Instance then
                local hit = result.Instance
                for _, plr in pairs(Players:GetPlayers()) do
                    if plr ~= player and plr.Character and isAlive(plr.Character) and hit:IsDescendantOf(plr.Character) then
                        lastTriggerClick = now
                        mouse1click()
                        break
                    end
                end
            end
        end
    end

    -- SPINBOT
    if settings.getSpinEnabled() and myRoot then
        local speed = settings.getSpinSpeed() * dt * 5
        local dy = settings.getSpinDirY() / 100
        myRoot.CFrame = myRoot.CFrame * CFrame.Angles(0, math.rad(speed * 30 * dy), 0)
    end

    -- ESP & VISUALS
    if settings.getWHEnabled() then
        resetPool(boxLines)
        resetPool(skelLines)
        resetPool(trailLines)

        for _, plr in pairs(Players:GetPlayers()) do
            if plr ~= player and plr.Character and isAlive(plr.Character) then
                local targetChar = plr.Character
                local head = targetChar:FindFirstChild("Head")
                local torso = targetChar:FindFirstChild("Torso") or targetChar:FindFirstChild("UpperTorso")
                
                if head and torso then
                    updateHighlight(targetChar, settings.getWHHighlight())
                    updateChams(targetChar, settings.getWHChams())

                    if settings.getWHBox() then
                        local cf, size = targetChar:GetBoundingBox()
                        size = size / 2
                        local off = {
                            Vector3.new(-size.X, -size.Y, -size.Z), Vector3.new( size.X, -size.Y, -size.Z),
                            Vector3.new( size.X,  size.Y, -size.Z), Vector3.new(-size.X,  size.Y, -size.Z),
                            Vector3.new(-size.X, -size.Y,  size.Z), Vector3.new( size.X, -size.Y,  size.Z),
                            Vector3.new( size.X,  size.Y,  size.Z), Vector3.new(-size.X,  size.Y,  size.Z),
                        }
                        local wp = {}
                        for _, v in ipairs(off) do table.insert(wp, cf * v) end
                        local edges = {{1,2},{2,3},{3,4},{4,1},{5,6},{6,7},{7,8},{8,5},{1,5},{2,6},{3,7},{4,8}}
                        for _, pair in ipairs(edges) do
                            local p1 = camera:WorldToViewportPoint(wp[pair[1]])
                            local p2 = camera:WorldToViewportPoint(wp[pair[2]])
                            if p1.Z > 0 and p2.Z > 0 then
                                local line = getLine(boxLines)
                                line.From = Vector2.new(p1.X, p1.Y)
                                line.To = Vector2.new(p2.X, p2.Y)
                                line.Color = Color3.fromRGB(255, 200, 0)
                                line.Thickness = 2
                            end
                        end
                    end

                    if settings.getWHSkeleton() then
                        for _, pair in ipairs(getSkeletonPoints(targetChar)) do
                            local p1 = camera:WorldToViewportPoint(pair[1])
                            local p2 = camera:WorldToViewportPoint(pair[2])
                            if p1.Z > 0 and p2.Z > 0 then
                                local line = getLine(skelLines)
                                line.From = Vector2.new(p1.X, p1.Y)
                                line.To = Vector2.new(p2.X, p2.Y)
                                line.Color = Color3.fromRGB(255, 255, 100)
                                line.Thickness = 1
                            end
                        end
                    end

                    if settings.getWHTrail() then
                        local p1 = camera:WorldToViewportPoint(camera.CFrame.Position + camera.CFrame.LookVector * 5)
                        local p2 = camera:WorldToViewportPoint(torso.Position)
                        if p1.Z > 0 and p2.Z > 0 then
                            local line = getLine(trailLines)
                            line.From = Vector2.new(p1.X, p1.Y)
                            line.To = Vector2.new(p2.X, p2.Y)
                            line.Color = Color3.fromRGB(255, 150, 50)
                            line.Thickness = 2
                        end
                    end
                end
            end
        end
    else
        resetPool(boxLines)
        resetPool(skelLines)
        resetPool(trailLines)
        for c, hl in pairs(highlights) do if hl then hl:Destroy() end end
        highlights = {}
        for c, clone in pairs(chamsCopies) do if clone then clone:Destroy() end end
        chamsCopies = {}
    end

    -- Очистка омертвевших или выбывших целей
    for targetChar, hl in pairs(highlights) do
        if not (targetChar and targetChar.Parent and isAlive(targetChar)) then
            if hl then hl:Destroy() end
            highlights[targetChar] = nil
        end
    end
    for targetChar, clone in pairs(chamsCopies) do
        if not (targetChar and targetChar.Parent and isAlive(targetChar)) then
            if clone then clone:Destroy() end
            chamsCopies[targetChar] = nil
        end
    end

    -- Синхронизация Chams
    if settings.getWHChams() then
        for targetChar, clone in pairs(chamsCopies) do
            if targetChar and targetChar.Parent and isAlive(targetChar) and clone then
                for _, clonePart in ipairs(clone:GetChildren()) do
                    if clonePart:IsA("BasePart") then
                        local origPart = targetChar:FindFirstChild(clonePart.Name)
                        if origPart and origPart:IsA("BasePart") then
                            clonePart.CFrame = origPart.CFrame
                        end
                    end
                end
            end
        end
    end

    -- SPEEDHACK
    if char and char:FindFirstChild("Humanoid") then
        local hum = char.Humanoid
        if settings.getSpeedHack() then
            hum.WalkSpeed = settings.getSpeedValue()
        else
            if hum.WalkSpeed == settings.getSpeedValue() then hum.WalkSpeed = originalWalkSpeed end
        end
    end

    -- BUNNYHOP
    if settings.getBHEnabled() and not UserInputService:GetFocusedTextBox() then
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) and char and char:FindFirstChild("Humanoid") then
            local hum = char.Humanoid
            if hum:GetState() == Enum.HumanoidStateType.Running or hum:GetState() == Enum.HumanoidStateType.Landed then
                hum.Jump = true
            end
        end
    end

    -- FLY
    if settings.getFly() and not UserInputService:GetFocusedTextBox() then
        if char and char:FindFirstChild("Humanoid") then
            char.Humanoid.PlatformStand = true
            if myRoot then
                local move = Vector3.new()
                local speed = 50
                if UserInputService:IsKeyDown(Enum.KeyCode.W) then move = move + camera.CFrame.LookVector * speed end
                if UserInputService:IsKeyDown(Enum.KeyCode.S) then move = move - camera.CFrame.LookVector * speed end
                if UserInputService:IsKeyDown(Enum.KeyCode.A) then move = move - camera.CFrame.RightVector * speed end
                if UserInputService:IsKeyDown(Enum.KeyCode.D) then move = move + camera.CFrame.RightVector * speed end
                if UserInputService:IsKeyDown(Enum.KeyCode.Space) then move = move + Vector3.new(0, speed, 0) end
                if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then move = move - Vector3.new(0, speed, 0) end
                myRoot.AssemblyLinearVelocity = move
            end
        end
    else
        if char and char:FindFirstChild("Humanoid") then char.Humanoid.PlatformStand = false end
    end

    -- NOCLIP
    if char then
        local noc = settings.getNoclip()
        if noc then
            wasNoclip = true
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") then part.CanCollide = false end
            end
        elseif wasNoclip then
            wasNoclip = false
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    if part.Name == "Head" or part.Name == "Torso" or part.Name == "UpperTorso" or part.Name == "LowerTorso" then
                        part.CanCollide = true
                    end
                end
            end
        end
    end
end)

-- РАПИДФАЙР
local rapidFireActive = false
UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.UserInputType == Enum.UserInputType.MouseButton1 and settings.getRapidFire() then
        rapidFireActive = true
        task.spawn(function()
            while rapidFireActive and settings.getRapidFire() do
                mouse1click()
                task.wait(0.05)
            end
        end)
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then rapidFireActive = false end
end)

-- КЛАВИША МЕНЮ (G)
UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.G then
        local gui = player.PlayerGui:FindFirstChild("kajjrtf")
        if gui then
            local menu = gui:FindFirstChild("Menu")
            if menu then
                if menu.Visible then
                    local t1 = TweenService:Create(menu, TweenInfo.new(0.2), {Size = UDim2.new(0, 0, 0, 0)})
                    local t2 = TweenService:Create(menu, TweenInfo.new(0.2), {Position = UDim2.new(0.5, 0, -0.5, 0)})
                    t1:Play(); t2:Play()
                    task.wait(0.25)
                    menu.Visible = false
                    menu.Size = UDim2.new(0, 400, 0, 500)
                    menu.Position = guiPos
                else
                    menu.Visible = true
                    menu.Size = UDim2.new(0, 0, 0, 0)
                    TweenService:Create(menu, TweenInfo.new(0.3, Enum.EasingStyle.Back), {Size = UDim2.new(0, 400, 0, 500)}):Play()
                end
            end
        end
    end
end)

debugLog("Успешный запуск! Откройте консоль (F9), чтобы видеть подробные DEBUG логи.")
