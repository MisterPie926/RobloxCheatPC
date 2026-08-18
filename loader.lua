-- СКРИПТ ДЛЯ ROBLOX (LocalScript)
-- Вставьте в исполнитель (например, Synapse, Krnl, etc.)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- СОЗДАНИЕ GUI С АНИМАЦИЕЙ ПОЯВЛЕНИЯ
local screenGui = Instance.new("ScreenGui")
screenGui.Parent = LocalPlayer.PlayerGui

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 340, 0, 480)
mainFrame.Position = UDim2.new(0.5, -170, 0.5, -240)
mainFrame.BackgroundColor3 = Color3.new(0.08, 0.08, 0.08)
mainFrame.BackgroundTransparency = 0.9
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui

-- Анимация появления (TweenService)
local appearTween = TweenService:Create(mainFrame, TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundTransparency = 0.15})
appearTween:Play()

-- Заголовок
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 35)
title.Position = UDim2.new(0, 0, 0, 0)
title.Text = "⚡ CHEAT MENU ⚡"
title.TextColor3 = Color3.new(1, 1, 1)
title.BackgroundTransparency = 1
title.Font = Enum.Font.GothamBold
title.TextSize = 22
title.Parent = mainFrame

-- ВСПОМОГАТЕЛЬНЫЕ ФУНКЦИИ ДЛЯ СОЗДАНИЯ ЭЛЕМЕНТОВ
local function createCheckbox(name, yPos, default)
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, 0, 0, 30)
    container.Position = UDim2.new(0, 0, 0, yPos)
    container.BackgroundTransparency = 1
    container.Parent = mainFrame

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
        local tween = TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = targetColor})
        tween:Play()
    end)

    return {
        Get = function() return checked end,
        Toggle = function()
            checked = not checked
            local targetColor = checked and Color3.new(0, 1, 0) or Color3.new(0.3, 0.3, 0.3)
            local tween = TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = targetColor})
            tween:Play()
        end
    }
end

local function createTextbox(name, yPos, defaultText)
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, 0, 0, 30)
    container.Position = UDim2.new(0, 0, 0, yPos)
    container.BackgroundTransparency = 1
    container.Parent = mainFrame

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
        Get = function() return tonumber(box.Text) or 0 end,
        Set = function(t) box.Text = t end
    }
end

-- СОЗДАНИЕ ЭЛЕМЕНТОВ УПРАВЛЕНИЯ
local yOff = 40

-- Aimbot (выбор режима Rage/Legit + чекбокс включения)
local aimFrame = Instance.new("Frame")
aimFrame.Size = UDim2.new(1, 0, 0, 50)
aimFrame.Position = UDim2.new(0, 0, 0, yOff)
aimFrame.BackgroundTransparency = 1
aimFrame.Parent = mainFrame
yOff = yOff + 55

local aimLabel = Instance.new("TextLabel")
aimLabel.Size = UDim2.new(1, 0, 0, 20)
aimLabel.Text = "Aimbot:"
aimLabel.TextColor3 = Color3.new(0.9,0.9,0.9)
aimLabel.BackgroundTransparency = 1
aimLabel.Font = Enum.Font.Gotham
aimLabel.TextSize = 16
aimLabel.TextXAlignment = Enum.TextXAlignment.Left
aimLabel.Position = UDim2.new(0, 5, 0, 0)
aimLabel.Parent = aimFrame

local aimEnabled = createCheckbox("", 25, false) -- чекбокс включения
aimEnabled.Button.Position = UDim2.new(0.2, 0, 0.02, 0) -- сдвинем

local rageBtn = Instance.new("TextButton")
rageBtn.Size = UDim2.new(0.25, 0, 0, 25)
rageBtn.Position = UDim2.new(0.4, 0, 0.25, 0)
rageBtn.Text = "Rage"
rageBtn.BackgroundColor3 = Color3.new(0.3,0.3,0.3)
rageBtn.BorderSizePixel = 0
rageBtn.Parent = aimFrame

local legitBtn = Instance.new("TextButton")
legitBtn.Size = UDim2.new(0.25, 0, 0, 25)
legitBtn.Position = UDim2.new(0.7, 0, 0.25, 0)
legitBtn.Text = "Legit"
legitBtn.BackgroundColor3 = Color3.new(0.3,0.3,0.3)
legitBtn.BorderSizePixel = 0
legitBtn.Parent = aimFrame

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

local wallHack = createCheckbox("WallHack (3D Box)", yOff, false)
yOff = yOff + 35
local speedBox = createTextbox("SpeedHack (WalkSpeed)", yOff, "50")
yOff = yOff + 35
local speedShot = createCheckbox("SpeedShot", yOff, false)
yOff = yOff + 35
local noRecoil = createCheckbox("No Recoil", yOff, false)
yOff = yOff + 35
local spinBot = createCheckbox("SpinBot", yOff, false)
yOff = yOff + 35
local noCdJump = createCheckbox("No CD Jump", yOff, false)
yOff = yOff + 35

-- ПЕРЕМЕННЫЕ СОСТОЯНИЙ
local wallActive = false
local speedActive = false
local speedShotActive = false
local noRecoilActive = false
local spinActive = false
local noCdJumpActive = false
local aimActive = false
local aimModeCurrent = "Rage"

-- ОБНОВЛЕНИЕ СОСТОЯНИЙ ПРИ КЛИКЕ
wallHack.Button.MouseButton1Click:Connect(function() wallActive = wallHack.Get() end)
speedShot.Button.MouseButton1Click:Connect(function() speedShotActive = speedShot.Get() end)
noRecoil.Button.MouseButton1Click:Connect(function() noRecoilActive = noRecoil.Get() end)
spinBot.Button.MouseButton1Click:Connect(function() spinActive = spinBot.Get() end)
noCdJump.Button.MouseButton1Click:Connect(function() noCdJumpActive = noCdJump.Get() end)
aimEnabled.Button.MouseButton1Click:Connect(function() aimActive = aimEnabled.Get() end)
rageBtn.MouseButton1Click:Connect(function() aimModeCurrent = "Rage" end)
legitBtn.MouseButton1Click:Connect(function() aimModeCurrent = "Legit" end)

-- СПИСОК ИГРОКОВ ДЛЯ ESP
local highlights = {}
local function updateWall()
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer then
            if plr.Character then
                if wallActive then
                    if not highlights[plr] then
                        local hl = Instance.new("Highlight")
                        hl.Parent = plr.Character
                        hl.Adornee = plr.Character
                        hl.FillColor = Color3.new(1, 0, 0)
                        hl.FillTransparency = 0.4
                        hl.OutlineColor = Color3.new(0, 1, 0)
                        highlights[plr] = hl
                    end
                else
                    if highlights[plr] then
                        highlights[plr]:Destroy()
                        highlights[plr] = nil
                    end
                end
            end
        end
    end
end

-- ОБРАБОТКА НОВЫХ ИГРОКОВ
Players.PlayerAdded:Connect(function(plr)
    plr.CharacterAdded:Connect(function(char)
        if wallActive then
            local hl = Instance.new("Highlight")
            hl.Parent = char
            hl.Adornee = char
            hl.FillColor = Color3.new(1, 0, 0)
            hl.FillTransparency = 0.4
            hl.OutlineColor = Color3.new(0, 1, 0)
            highlights[plr] = hl
        end
    end)
end)

-- Aimbot: поиск ближайшего
local function getClosest()
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

-- SpinBot: вращение через Tween (бесконечный цикл)
local spinTween = nil
local function startSpin()
    if not spinActive then return end
    local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not root then return end
    local current = root.CFrame
    local target = current * CFrame.Angles(0, math.rad(360), 0)
    local tweenInfoSpin = TweenInfo.new(1.2, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
    spinTween = TweenService:Create(root, tweenInfoSpin, {CFrame = target})
    spinTween:Play()
    spinTween.Completed:Connect(function()
        spinTween = nil
        if spinActive then
            startSpin()
        end
    end)
end

-- ОСНОВНОЙ ЦИКЛ ОБНОВЛЕНИЯ
RunService.RenderStepped:Connect(function()
    -- SpeedHack
    local spd = speedBox.Get()
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("Humanoid") then
        local hum = char.Humanoid
        if spd > 0 then
            hum.WalkSpeed = spd
        else
            hum.WalkSpeed = 16
        end
    end

    -- No CD Jump
    if noCdJumpActive and char and char:FindFirstChild("Humanoid") then
        local hum = char.Humanoid
        hum.JumpPower = 70
        -- Эмуляция быстрого прыжка (если зажат пробел)
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
            hum.Jump = true
        end
    else
        if char and char:FindFirstChild("Humanoid") then
            char.Humanoid.JumpPower = 50
        end
    end

    -- SpeedShot & No Recoil (ищем оружие)
    if char then
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
    end

    -- WallHack
    updateWall()

    -- SpinBot
    if spinActive then
        if not spinTween then
            startSpin()
        end
    else
        if spinTween then
            spinTween:Cancel()
            spinTween = nil
        end
    end

    -- Aimbot
    if aimActive then
        local target = getClosest()
        if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
            local targetPos = target.Character.HumanoidRootPart.Position
            local cameraPos = Camera.CFrame.Position
            local lookAt = CFrame.lookAt(cameraPos, targetPos)
            if aimModeCurrent == "Rage" then
                Camera.CFrame = lookAt
            else -- Legit с плавным наведением (Tween)
                local currentCF = Camera.CFrame
                local targetCF = lookAt
                -- Используем Tween для плавного перехода
                local tweenInfoLegit = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
                local tween = TweenService:Create(Camera, tweenInfoLegit, {CFrame = targetCF})
                tween:Play()
            end
        end
    end
end)

-- АНИМАЦИЯ ПРИ ЗАКРЫТИИ (опционально)
-- Можно добавить горячую клавишу для скрытия (например, Insert)
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.Insert then
        mainFrame.Visible = not mainFrame.Visible
    end
end)

-- Завершающее сообщение (в консоль)
print("Чит загружен. Нажмите Insert для скрытия/показа меню.")
