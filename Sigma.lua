local Players       = game:GetService("Players")
local RunService    = game:GetService("RunService")
local SoundService  = game:GetService("SoundService")
local GuiService    = game:GetService("GuiService")
local StarterGui    = game:GetService("StarterGui")
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

ContextActionService:BindActionAtPriority(
	"M7_BlockEscape",
	function() return Enum.ContextActionResult.Sink end,
	false,
	Enum.ContextActionPriority.High.Value + 1000,
	Enum.KeyCode.Escape,
	Enum.KeyCode.ButtonStart
)

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
		task.wait(0.05)
	end
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
	gui.DisplayOrder = id
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
for i = 1, 5 do
	task.delay(i * 0.2, spawnPopup)
end

task.spawn(function()
	local interval = 0.5
	while true do
		task.wait(interval)
		spawnPopup()
		interval = math.max(0.03, interval * 0.96)
	end
end)
