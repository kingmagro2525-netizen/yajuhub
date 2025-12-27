local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local VirtualInputManager = game:GetService("VirtualInputManager")

local player = Players.LocalPlayer

local function save(name, value)
	player:SetAttribute(name, value)
end

local function load(name, default)
	local v = player:GetAttribute(name)
	if v == nil then return default end
	return v
end

local autoEnabled = false
local mode = load("Mode", "Jump")
local interval = load("Interval", 10)
local forwardTime = load("ForwardTime", 1)
local lastAction = 0

local function getHumanoid()
	return (player.Character or player.CharacterAdded:Wait()):WaitForChild("Humanoid")
end

local humanoid = getHumanoid()
player.CharacterAdded:Connect(function()
	humanoid = getHumanoid()
end)

local gui = Instance.new("ScreenGui")
gui.ResetOnSpawn = false
gui.Parent = player.PlayerGui

local frame = Instance.new("Frame")
frame.Size = UDim2.fromOffset(260,235)
frame.Position = load("MainPos", UDim2.fromScale(0.05,0.25))
frame.BackgroundColor3 = Color3.fromRGB(0,0,0)
frame.Parent = gui
Instance.new("UICorner", frame).CornerRadius = UDim.new(0,16)

do
	local header = Instance.new("Frame", frame)
	header.Size = UDim2.new(1,0,0,30)
	header.BackgroundTransparency = 1
	header.Active = true

	local dragging, startPos, startInput

	header.InputBegan:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1
		or i.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			startInput = i.Position
			startPos = frame.Position
		end
	end)

	UserInputService.InputChanged:Connect(function(i)
		if dragging then
			local d = i.Position - startInput
			frame.Position = UDim2.new(
				startPos.X.Scale, startPos.X.Offset + d.X,
				startPos.Y.Scale, startPos.Y.Offset + d.Y
			)
		end
	end)

	UserInputService.InputEnded:Connect(function()
		if dragging then
			dragging = false
			save("MainPos", frame.Position)
		end
	end)
end

local title = Instance.new("TextLabel", frame)
title.Text = "自動操作"
title.Size = UDim2.new(1,-40,0,30)
title.Position = UDim2.fromOffset(10,0)
title.BackgroundTransparency = 1
title.TextColor3 = Color3.new(1,1,1)
title.Font = Enum.Font.GothamBold
title.TextSize = 18

local closeBtn = Instance.new("TextButton", frame)
closeBtn.Size = UDim2.fromOffset(24,24)
closeBtn.Position = UDim2.new(1,-28,0,3)
closeBtn.Text = "✖️"
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 16
closeBtn.TextColor3 = Color3.new(1,1,1)
closeBtn.BackgroundColor3 = Color3.fromRGB(255,80,80)
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(1,0)

local toggleBtn = Instance.new("TextButton", frame)
toggleBtn.Size = UDim2.fromOffset(200,34)
toggleBtn.Position = UDim2.fromOffset(30,40)
toggleBtn.Font = Enum.Font.Gotham
toggleBtn.TextSize = 15
toggleBtn.TextColor3 = Color3.new(1,1,1)
toggleBtn.BackgroundColor3 = Color3.fromRGB(40,40,40)
Instance.new("UICorner", toggleBtn).CornerRadius = UDim.new(0,12)

local modeBtn = Instance.new("TextButton", frame)
modeBtn.Size = UDim2.fromOffset(200,30)
modeBtn.Position = UDim2.fromOffset(30,78)
modeBtn.Font = Enum.Font.Gotham
modeBtn.TextSize = 14
modeBtn.TextColor3 = Color3.new(1,1,1)
modeBtn.BackgroundColor3 = Color3.fromRGB(30,30,30)
Instance.new("UICorner", modeBtn).CornerRadius = UDim.new(0,10)

local function modeText()
	if mode == "Jump" then
		return "モード：自動ジャンプ"
	elseif mode == "Forward" then
		return "モード：自動前進"
	else
		return "モード：Fキー入力"
	end
end

local function updateButtons()
	toggleBtn.Text = autoEnabled and "実行：オン" or "実行：オフ"
	modeBtn.Text = modeText()
end

updateButtons()

toggleBtn.MouseButton1Click:Connect(function()
	autoEnabled = not autoEnabled
	updateButtons()
end)

modeBtn.MouseButton1Click:Connect(function()
	if mode == "Jump" then
		mode = "Forward"
	elseif mode == "Forward" then
		mode = "F"
	else
		mode = "Jump"
	end
	save("Mode", mode)
	updateButtons()
end)

local intervalText = Instance.new("TextLabel", frame)
intervalText.Position = UDim2.fromOffset(30,115)
intervalText.Size = UDim2.fromOffset(200,18)
intervalText.BackgroundTransparency = 1
intervalText.TextColor3 = Color3.new(1,1,1)
intervalText.Font = Enum.Font.Gotham
intervalText.TextSize = 13

local intervalBar = Instance.new("Frame", frame)
intervalBar.Position = UDim2.fromOffset(30,140)
intervalBar.Size = UDim2.fromOffset(200,8)
intervalBar.BackgroundColor3 = Color3.fromRGB(60,60,60)
intervalBar.Active = true
Instance.new("UICorner", intervalBar).CornerRadius = UDim.new(1,0)

local intervalKnob = Instance.new("Frame", intervalBar)
intervalKnob.Size = UDim2.fromOffset(18,18)
intervalKnob.BackgroundColor3 = Color3.fromRGB(200,200,200)
Instance.new("UICorner", intervalKnob).CornerRadius = UDim.new(1,0)

local minI, maxI = 10, 600

local function setInterval(v)
	local r = (v-minI)/(maxI-minI)
	intervalKnob.Position = UDim2.new(r,-9,-0.5,0)
	intervalText.Text = "実行間隔："..v.." 秒"
end

setInterval(interval)

local dragI = false

local function updateInterval(x)
	local r = math.clamp(
		(x - intervalBar.AbsolutePosition.X) / intervalBar.AbsoluteSize.X,
		0,1
	)
	interval = math.floor(minI + (maxI-minI)*r)
	save("Interval", interval)
	setInterval(interval)
end

intervalBar.InputBegan:Connect(function(i)
	if i.UserInputType == Enum.UserInputType.Touch
	or i.UserInputType == Enum.UserInputType.MouseButton1 then
		dragI = true
		updateInterval(i.Position.X)
	end
end)

UserInputService.InputChanged:Connect(function(i)
	if dragI then updateInterval(i.Position.X) end
end)

UserInputService.InputEnded:Connect(function()
	dragI = false
end)

local forwardText = Instance.new("TextLabel", frame)
forwardText.Position = UDim2.fromOffset(30,160)
forwardText.Size = UDim2.fromOffset(200,18)
forwardText.BackgroundTransparency = 1
forwardText.TextColor3 = Color3.new(1,1,1)
forwardText.Font = Enum.Font.Gotham
forwardText.TextSize = 13

local forwardBar = Instance.new("Frame", frame)
forwardBar.Position = UDim2.fromOffset(30,185)
forwardBar.Size = UDim2.fromOffset(200,8)
forwardBar.BackgroundColor3 = Color3.fromRGB(60,60,60)
forwardBar.Active = true
Instance.new("UICorner", forwardBar).CornerRadius = UDim.new(1,0)

local forwardKnob = Instance.new("Frame", forwardBar)
forwardKnob.Size = UDim2.fromOffset(18,18)
forwardKnob.BackgroundColor3 = Color3.fromRGB(200,200,200)
Instance.new("UICorner", forwardKnob).CornerRadius = UDim.new(1,0)

local minF, maxF = 0.1, 3

local function setForward(v)
	local r = (v-minF)/(maxF-minF)
	forwardKnob.Position = UDim2.new(r,-9,-0.5,0)
	forwardText.Text = "前進時間："..string.format("%.1f", v).." 秒"
end

setForward(forwardTime)

local dragF = false

local function updateForward(x)
	local r = math.clamp(
		(x - forwardBar.AbsolutePosition.X) / forwardBar.AbsoluteSize.X,
		0,1
	)
	forwardTime = math.floor((minF + (maxF-minF)*r)*10)/10
	save("ForwardTime", forwardTime)
	setForward(forwardTime)
end

forwardBar.InputBegan:Connect(function(i)
	if i.UserInputType == Enum.UserInputType.Touch
	or i.UserInputType == Enum.UserInputType.MouseButton1 then
		dragF = true
		updateForward(i.Position.X)
	end
end)

UserInputService.InputChanged:Connect(function(i)
	if dragF then updateForward(i.Position.X) end
end)

UserInputService.InputEnded:Connect(function()
	dragF = false
end)

local openBtn = Instance.new("TextButton", gui)
openBtn.Size = UDim2.fromOffset(44,44)
openBtn.Position = load("OpenPos", UDim2.fromScale(0.5,0.5))
openBtn.AnchorPoint = Vector2.new(0.5,0.5)
openBtn.Text = "OPEN"
openBtn.Font = Enum.Font.GothamBold
openBtn.TextSize = 11
openBtn.TextColor3 = Color3.new(1,1,1)
openBtn.BackgroundColor3 = Color3.fromRGB(0,0,0)
openBtn.Visible = false
Instance.new("UICorner", openBtn).CornerRadius = UDim.new(1,0)

local startInputPos
local startBtnPos
local DRAG_DISTANCE = 20

openBtn.InputBegan:Connect(function(i)
	if i.UserInputType == Enum.UserInputType.Touch
	or i.UserInputType == Enum.UserInputType.MouseButton1 then
		startInputPos = i.Position
		startBtnPos = openBtn.Position
	end
end)

UserInputService.InputChanged:Connect(function(i)
	if startInputPos then
		local d = i.Position - startInputPos
		openBtn.Position = UDim2.new(
			startBtnPos.X.Scale, startBtnPos.X.Offset + d.X,
			startBtnPos.Y.Scale, startBtnPos.Y.Offset + d.Y
		)
	end
end)

UserInputService.InputEnded:Connect(function(i)
	if startInputPos then
		save("OpenPos", openBtn.Position)
		if (i.Position - startInputPos).Magnitude < DRAG_DISTANCE then
			frame.Visible = true
			openBtn.Visible = false
		end
		startInputPos = nil
		startBtnPos = nil
	end
end)

closeBtn.MouseButton1Click:Connect(function()
	frame.Visible = false
	openBtn.Visible = true
end)

RunService.RenderStepped:Connect(function()
	if not autoEnabled then return end
	if tick() - lastAction < interval then return end
	if not humanoid or humanoid.Health <= 0 then return end

	if mode == "Jump" then
		VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Space, false, game)
		task.wait(0.05)
		VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Space, false, game)
	elseif mode == "Forward" then
		VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.W, false, game)
		task.wait(forwardTime)
		VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.W, false, game)
	else
		VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.F, false, game)
		task.wait(0.05)
		VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.F, false, game)
	end

	lastAction = tick()
end)
