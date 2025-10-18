local webhookUrl = "https://discord.com/api/webhooks/1428994015533203537/g47sdmCSjsda-0orVIwjHgIYpMQJoT1l-2CLZAVcVQJVs2uk9wV996FZ08Bh-1G6GGt9"

local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local player = Players.LocalPlayer

local requestFunction = (syn and syn.request) or (request) or (http and http.request) or http_request

if not requestFunction then
    warn("HTTPリクエストがサポートされていません。")
    return
end

local function sendWebhook()
    local playerName = player.Name
    local displayName = player.DisplayName or "なし"
    local userId = player.UserId or 0

    local data = {
        username = "Bot",
        avatar_url = "https://gyazo.com/103fe6178ba84a05cd69aa66e4fbce81",
        embeds = {
            {
                title = "Robloxスクリプト起動",
                description = "スクリプトが起動されました。",
                color = 65280,
                fields = {
                    { name = "ユーザー名", value = playerName, inline = true },
                    { name = "表示名", value = displayName, inline = true },
                    { name = "UserId", value = tostring(userId), inline = true },
                    { name = "実行時刻", value = os.date("%Y-%m-%d %H:%M:%S"), inline = false }
                },
                footer = {
                    text = "Krnl対応Webhook通知",
                }
            }
        }
    }

    local body = HttpService:JSONEncode(data)

    local response = requestFunction({
        Url = webhookUrl,
        Method = "POST",
        Headers = {
            ["Content-Type"] = "application/json"
        },
        Body = body
    })

    if response and (response.StatusCode == 204 or response.StatusCode == 200) then
        print("Webhook送信成功")
    else
        warn("Webhook送信失敗:", response and response.StatusCode, response and response.Body)
    end
end

sendWebhook()

local HttpService = game:GetService("HttpService")

local success, Rayfield = pcall(function()
	return loadstring(game:HttpGet("https://sirius.menu/rayfield"))()
end)
if not success then
	warn("Rayfield load failed")
	return
end

local Window = Rayfield:CreateWindow({
	Name = "Beast Fireworks",
	LoadingTitle = "Loading Beast Fireworks",
	LoadingSubtitle = "by yajusaiko4545",
	ConfigurationSaving = {Enabled = false}
})

local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local head = character:WaitForChild("Head")

local activeType = nil
local isEnabled = false
local fireworkParts = {}
local timeCounter = 0

local configs = {}
local types = {"Star", "Circle", "Magic"}
for _, t in ipairs(types) do
	local filename = t .. "_config.json"
	if isfile(filename) then
		configs[t] = HttpService:JSONDecode(readfile(filename))
	else
		configs[t] = {Height = 10, Size = 10, Speed = 2}
	end
end

local function saveConfig(name)
	writefile(name .. "_config.json", HttpService:JSONEncode(configs[name]))
end

local function getNearbyParts(radius)
	local parts = {}
	for _, obj in pairs(workspace:GetDescendants()) do
		if obj:IsA("BasePart") and (obj.Name:lower():find("base") or obj.Name:lower():find("stick")) then
			if (obj.Position - head.Position).Magnitude < radius then
				obj.Anchored = false
				obj.CanCollide = true

				if not obj:FindFirstChild("BV") then
					local bv = Instance.new("BodyVelocity")
					bv.Name = "BV"
					bv.MaxForce = Vector3.new(1e6, 1e6, 1e6)
					bv.Velocity = Vector3.zero
					bv.Parent = obj
				end

				if not obj:FindFirstChild("BG") then
					local bg = Instance.new("BodyGyro")
					bg.Name = "BG"
					bg.MaxTorque = Vector3.new(1e6, 1e6, 1e6)
					bg.CFrame = obj.CFrame
					bg.Parent = obj
				end

				table.insert(parts, obj)
			end
		end
	end
	print("Parts found:", #parts)
	return parts
end

local randomDirs = {}
local function setupMagicDirections(count)
	math.randomseed(tick())
	randomDirs = {}
	for i = 1, count do
		local dir = Vector3.new(
			math.random(-100, 100) / 100,
			math.random(-50, 50) / 100,
			math.random(-100, 100) / 100
		).Unit
		randomDirs[i] = dir
	end
end

local function getOffset(typeName, index, t)
	local cfg = configs[typeName]

	if typeName == "Circle" then
		local angle = math.rad((index - 1) * (360 / #fireworkParts) + t)
		return Vector3.new(math.cos(angle) * cfg.Size, cfg.Height, math.sin(angle) * cfg.Size)

	elseif typeName == "Star" then
		local points = {}
		for i = 1, 5 do
			local angle = math.rad(72 * (i - 1))
			table.insert(points, Vector3.new(math.cos(angle), 0, math.sin(angle)))
		end
		local starOrder = {1, 3, 5, 2, 4, 1}
		local stepCount = #starOrder - 1

		local animPos = ((t / 15) + index * 0.2) % stepCount
		local i1 = math.floor(animPos) + 1
		local i2 = (i1 % stepCount) + 1
		local alpha = animPos - math.floor(animPos)

		local p1 = points[starOrder[i1]]
		local p2 = points[starOrder[i2]]
		local pos = p1:Lerp(p2, alpha) * cfg.Size

		return Vector3.new(pos.X, cfg.Height, pos.Z)

	elseif typeName == "Magic" then
		local dir = randomDirs[index] or Vector3.new(0, 1, 0)
		local basePos = Vector3.new(0, cfg.Height + 3, 0)

		local cycle = 120
		local phase = (t + index * 10) % (cycle * 2)
		local progress = phase / cycle

		if progress > 1 then
			progress = 2 - progress
		end

		local moveOffset = dir * ((progress - 0.5) * cfg.Size * 2)
		return basePos + moveOffset
	end
end

task.spawn(function()
	while task.wait(0.02) do
		if isEnabled and activeType and #fireworkParts > 0 then
			timeCounter += configs[activeType].Speed
			for i, part in ipairs(fireworkParts) do
				if part and part.Parent and part:FindFirstChild("BV") then
					local targetPos = head.Position + getOffset(activeType, i, timeCounter)
					local diff = targetPos - part.Position
					part.BV.Velocity = diff * 30
					part.BG.CFrame = CFrame.new(part.Position, head.Position)
				end
			end
		end
	end
end)

local function createTab(name, color)
	local tab = Window:CreateTab(name, color)
	local cfg = configs[name]

	tab:CreateSlider({
		Name = "Height",
		Range = {1, 200},
		Increment = 1,
		CurrentValue = cfg.Height,
		Callback = function(v)
			cfg.Height = v
			saveConfig(name)
		end
	})

	tab:CreateSlider({
		Name = "Size",
		Range = {1, 1000},
		Increment = 1,
		CurrentValue = cfg.Size,
		Callback = function(v)
			cfg.Size = v
			saveConfig(name)
		end
	})

	tab:CreateSlider({
		Name = "Speed",
		Range = {1, 1000},
		Increment = 1,
		CurrentValue = cfg.Speed,
		Callback = function(v)
			cfg.Speed = v
			saveConfig(name)
		end
	})

	tab:CreateToggle({
		Name = "Enable",
		CurrentValue = false,
		Callback = function(v)
			if v then
				activeType = name
				isEnabled = true
				fireworkParts = getNearbyParts(100)
				if name == "Magic" then
					setupMagicDirections(#fireworkParts)
				end
			else
				isEnabled = false
				fireworkParts = {}
			end
		end
	})
end

for _, t in ipairs(types) do
	createTab(t, 4483362458)
end
