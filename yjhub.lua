local player = game:GetService("Players").LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local existing = playerGui:FindFirstChild("YajusaikoMessageGui")
if existing then existing:Destroy() end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "YajusaikoMessageGui"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

local label = Instance.new("TextLabel")
label.Size = UDim2.new(0, 520, 0, 70)
label.Position = UDim2.new(0.5, 0, 0.5, 0) -- 完全中央
label.AnchorPoint = Vector2.new(0.5, 0.5)   -- 中央基準
label.BackgroundTransparency = 0.3
label.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
label.TextColor3 = Color3.fromRGB(255, 255, 255)
label.TextScaled = true
label.Text = "ただいまこのスクリプトは使えません"
label.TextWrapped = true
label.Parent = screenGui
