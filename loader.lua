-- ПОЛНОСТЬЮ ИСПРАВЛЕННЫЙ СКРИПТ ДЛЯ ROBLOX (LocalScript)
-- Вставьте в исполнитель (Synapse, Krnl, Delta и т.д.)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- ----- СОЗДАНИЕ GUI -----
local screenGui = Instance.new("ScreenGui")
screenGui.Parent = LocalPlayer.PlayerGui

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 360, 0, 520)
mainFrame.Position = UDim2.new(0.5, -180, 0.5, -260)
mainFrame.BackgroundColor3 = Color3.new(0.08, 0.08, 0.08)
mainFrame.BackgroundTransparency = 0.2
mainFrame.BorderSizePixel = 0
mainFrame.ClipsDescendants = true
mainFrame.Parent = screenGui

-- Анимация появления
local appearTween = TweenService:Create(mainFrame, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundTransparency = 0.15})
appearTween:Play()

-- Заголовок (для перетаскивания)
local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 30)
titleBar.BackgroundColor3 = Color3.new(0.15, 0.15, 0.15)
titleBar.BorderSizePixel = 0
titleBar.Parent = mainFrame

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, 0, 1, 0)
titleLabel.Text = "⚡ CHEAT MENU v11 ⚡"
titleLabel.TextColor3 = Color3.new(1, 1, 1)
titleLabel.BackgroundTransparency = 1
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextSize = 20
titleLabel.Parent = titleBar

-- Контейнер для списка элементов (ScrollingFrame + UIListLayout)
local scrollFrame = Instance.new("ScrollingFrame")
scrollFrame.Size = UDim2.new(1, -10, 1, -40)
scrollFrame.Position = UDim2.new(0, 5, 0, 35)
scrollFrame.BackgroundTransparency = 1
scrollFrame.BorderSizePixel = 0
scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
scrollFrame.ScrollBarThickness = 8
scrollFrame.Parent = mainFrame

local listLayout = Instance.new("UIListLayout")
listLayout.Padding = UDim.new(0, 4)
listLayout.SortOrder = Enum.SortOrder.LayoutOrder
listLayout.Parent = scrollFrame

-- ----- ПЕРЕТАСКИВАНИЕ ОКНА (Dragging) -----
local dragging = false
local dragStart, startPos

titleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = mainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- ----- ВСПОМОГАТЕЛЬНЫЕ ФУНКЦИИ СОЗДАНИЯ ЭЛЕМЕНТОВ -----
local function createCheckbox(name, default)
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, 0, 0, 30)
    container.BackgroundTransparency = 1
    container.Parent = scrollFrame

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.65, 0, 1, 0)
    label.Position = UDim2.new(0, 5, 0, 0)
    label.Text = name
    label.TextColor3 = Color3.new(0.9, 0.9, 0.9)
    label.BackgroundTransparency = 1
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Font = Enum.Font.Gotham
    label.TextSize = 16
    label.Parent = container

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 26, 0, 26)
    btn.Position = UDim2.new(0.85, 0, 0.02, 0)
    btn.BackgroundColor3 = default and Color3.new(0, 1, 0) or Color3.new(0.3, 0.3, 0.3)
    btn.Text = ""
    btn.BorderSizePixel = 0
    btn.Parent = container

    local checked = default or false
    btn.MouseButton1Click:Connect(function()
        checked = not checked
        local targetColor = checked and Color3.new(0, 1, 0) or Color3.new(0.3, 0.3, 0.3)
        TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = targetColor}):Play()
    end)

    return {
        Button = btn,  -- теперь есть поле Button
        Get = function() return checked end,
        Toggle = function()
            checked = not checked
            local targetColor = checked and Color3.new(0, 1, 0) or Color3.new(0.3, 0.3, 0.3)
            TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = targetColor}):Play()
        end
    }
end

local function createTextbox(name, defaultText)
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, 0, 0, 30)
    container.BackgroundTransparency = 1
    container.Parent = scrollFrame

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.5, 0, 1, 0)
    label.Position = UDim2.new(0, 5, 0, 0)
    label.Text = name
    label.TextColor3 = Color3.new(0.9, 0.9, 0.9)
    label.BackgroundTransparency = 1
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Font = Enum.Font.Gotham
    label.TextSize = 16
    label.Parent = container

    local box = Instance.new("TextBox")
    box.Size = UDim2.new(0.35, 0, 1, 0)
    box.Position = UDim2.new(0.6, 0, 0, 0)
    box.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)
    box.Text = defaultText or "50"
    box.TextColor3 = Color3.new(1, 1, 1)
    box.Font = Enum.Font.Gotham
    box.TextSize = 14
    box.BorderSizePixel = 0
    box.Parent = container

    return {
        Box = box,  -- поле для доступа к текстбоксу (не обязательно)
        Get = function() return tonumber(box.Text) or 0 end,
        Set = function(t) box.Text = tostring(t) end
    }
end

-- ----- СОЗДАНИЕ ЭЛЕМЕНТОВ УПРАВЛЕНИЯ -----
-- Aimbot: отдельный контейнер с двумя режимами
local aimContainer = Instance.new("Frame")
aimContainer.Size = UDim2.new(1, 0, 0, 50)
aimContainer.BackgroundTransparency = 1
aimContainer.Parent = scrollFrame

local aimLabel = Instance.new("TextLabel")
aimLabel.Size = UDim2.new(0.5, 0, 0.5, 0)
aimLabel.Position = UDim2.new(0, 5, 0, 0)
aimLabel.Text = "Aimbot:"
aimLabel.TextColor3 = Color3.new(0.9,0.9,0.9)
aimLabel.BackgroundTransparency = 1
aimLabel.TextXAlignment = Enum.TextXAlignment.Left
aimLabel.Font = Enum.Font.Gotham
aimLabel.TextSize = 16
aimLabel.Parent = aimContainer

local aimEnabledCheck = createCheckbox("", false)  -- чекбокс включения, без текста
aimEnabledCheck.Button.Position = UDim2.new(0.15, 0, 0.1, 0)  -- сдвинем
aimEnabledCheck.Button.Parent = aimContainer

local rageBtn = Instance.new("TextButton")
rageBtn.Size = UDim2.new(0.2, 0, 0.6, 0)
rageBtn.Position = UDim2.new(0.35, 0, 0.2, 0)
rageBtn.Text = "Rage"
rageBtn.BackgroundColor3 = Color3.new(0, 1, 0)
rageBtn.BorderSizePixel = 0
rageBtn.Parent = aimContainer

local legitBtn = Instance.new("TextButton")
legitBtn.Size = UDim2.new(0.2, 0, 0.6, 0)
legitBtn.Position = UDim2.new(0.6, 0, 0.2, 0)
legitBtn.Text = "Legit"
legitBtn.BackgroundColor3 = Color3.new(0.3,0.3,0.3)
legitBtn.BorderSizePixel = 0
legitBtn.Parent = aimContainer

local aimMode = "Rage"
local function setAimMode(mode)
    aimMode = mode
    local c1 = (mode == "Rage") and Color3.new(0,1,0) or Color3.new(0.3,0.3,0.3)
    local c2 = (mode == "Legit") and Color3.new(0,1,0) or Color3.new(0.3,0.3,0.3)
    TweenService:Create(rageBtn, TweenInfo.new(0.2), {BackgroundColor3 = c1}):Play()
    TweenService:Create(legitBtn, TweenInfo.new(0.2), {BackgroundColor3 = c2}):Play()
end
rageBtn.MouseButton1Click:Connect(function() setAimMode("Rage") end)
legitBtn.MouseButton1Click:Connect(function() setAimMode("Legit") end)
setAimMode("Rage")

local wallHack = createCheckbox("WallHack (3D Box)", false)
local speedBox = createTextbox("SpeedHack (WalkSpeed)", "50")
local speedShot = createCheckbox("SpeedShot", false)
local noRecoil = createCheckbox("No Recoil", false)
local spinBot = createCheckbox("SpinBot", false)
local noCdJump = createCheckbox("No CD Jump", false)

-- ----- ПЕРЕМЕННЫЕ СОСТОЯНИЙ (связываем с чекбоксами) -----
local wallActive = false
local speedShotActive = false
local noRecoilActive = false
local spinActive = false
local noCdJumpActive = false
local aimActive = false

-- Обновляем состояния через клики по кнопкам (теперь обращение через .Button)
wallHack.Button.MouseButton1Click:Connect(function() wallActive = wallHack.Get() end)
speedShot.Button.MouseButton1Click:Connect(function() speedShotActive = speedShot.Get() end)
noRecoil.Button.MouseButton1Click:Connect(function() noRecoilActive = noRecoil.Get() end)
spinBot.Button.MouseButton1Click:Connect(function() spinActive = spinBot.Get() end)
noCdJump.Button.MouseButton1Click:Connect(function() noCdJumpActive = noCdJump.Get() end)
aimEnabledCheck.Button.MouseButton1Click:Connect(function() aimActive = aimEnabledCheck.Get() end)

-- ----- РАБОТА С HIGHLIGHT (WallHack) без утечек -----
local highlights = {}  -- { [Player] = Highlight }

local function addHighlight(plr)
    local char = plr.Character
    if not char then return end
    if highlights[plr] then
        highlights[plr]:Destroy()
        highlights[plr] = nil
    end
    local hl = Instance.new("Highlight")
    hl.Adornee = char
    hl.FillColor = Color3.new(1, 0, 0)
    hl.FillTransparency = 0.4
    hl.OutlineColor = Color3.new(0, 1, 0)
    hl.Enabled = wallActive  -- сразу применяем состояние
    hl.Parent = char
    highlights[plr] = hl
end

-- Подписываемся на новых игроков и их персонажей
Players.PlayerAdded:Connect(function(plr)
    plr.CharacterAdded:Connect(function(char)
        addHighlight(plr)
    end)
    -- если персонаж уже есть
    if plr.Character then
        addHighlight(plr)
    end
end)

-- Обработка уже существующих игроков
for _, plr in ipairs(Players:GetPlayers()) do
    if plr ~= LocalPlayer then
        plr.CharacterAdded:Connect(function(char)
            addHighlight(plr)
        end)
        if plr.Character then
            addHighlight(plr)
        end
    end
end

-- Функция обновления состояния всех Highlight в цикле
local function updateWallState()
    for plr, hl in pairs(highlights) do
        if hl and hl.Parent then
            hl.Enabled = wallActive
        else
            highlights[plr] = nil
        end
    end
end

-- ----- AIMBOT: поиск ближайшего врага -----
local function getClosestEnemy()
    local closest, minDist = nil, math.huge
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
            local root = plr.Character.HumanoidRootPart
            local pos, onScreen = Camera:WorldToViewportPoint(root.Position)
            if onScreen then
                local dist = (Vector2.new(pos.X, pos.Y) - Vector2.new(Mouse.X, Mouse.Y)).Magnitude
                if dist < minDist then
                    minDist = dist
                    closest = plr
                end
            end
        end
    end
    return closest
end

-- ----- SPINBOT (вращение через CFrame в RenderStepped) -----
local spinSpeed = 360  -- градусов в секунду

-- ----- ОСНОВНОЙ ЦИКЛ ОБНОВЛЕНИЯ (RenderStepped) -----
RunService.RenderStepped:Connect(function(deltaTime)
    local char = LocalPlayer.Character
    if not char then return end
    local hum = char:FindFirstChild("Humanoid")
    if not hum then return end

    -- 1) SpeedHack
    local spd = speedBox.Get()
    if spd > 0 then
        hum.WalkSpeed = spd
    else
        hum.WalkSpeed = 16
    end

    -- 2) No CD Jump
    if noCdJumpActive then
        hum.JumpPower = 70
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
            hum.Jump = true
        end
    else
        hum.JumpPower = 50
    end

    -- 3) SpeedShot & No Recoil (ищем оружие в руках)
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

    -- 4) WallHack (обновляем Enabled)
    updateWallState()

    -- 5) SpinBot (вращение через CFrame в цикле)
    local rootPart = char:FindFirstChild("HumanoidRootPart")
    if spinActive and rootPart then
        -- вращаем на spinSpeed градусов в секунду
        local angle = math.rad(spinSpeed * deltaTime)
        rootPart.CFrame = rootPart.CFrame * CFrame.Angles(0, angle, 0)
    end

    -- 6) Aimbot
    if aimActive then
        local target = getClosestEnemy()
        if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
            local targetPos = target.Character.HumanoidRootPart.Position
            local cameraPos = Camera.CFrame.Position
            local lookAt = CFrame.lookAt(cameraPos, targetPos)
            if aimMode == "Rage" then
                Camera.CFrame = lookAt
            else -- Legit: плавное наведение через Lerp (без TweenService)
                Camera.CFrame = Camera.CFrame:Lerp(lookAt, 0.25)  -- 0.25 - скорость сглаживания
            end
        end
    end
end)

-- ----- КЛАВИША ДЛЯ СКРЫТИЯ МЕНЮ (Insert) -----
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.Insert then
        mainFrame.Visible = not mainFrame.Visible
    end
end)

-- Вывод в консоль
print("Чит v11 загружен без ошибок. Нажмите Insert для скрытия/показа.")
