-- 🌟 やじゅうの花火EX - モード別タブ版
local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

local Window = Rayfield:CreateWindow({
    Name = "やじゅうの花火",
    LoadingTitle = "ロード中 やじゅうの花火",
    LoadingSubtitle = "by yajusaiko4545",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = nil,
        FileName = "sparklerConfig_tabs"
    }
})

local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local head = character:WaitForChild("Head")

local activeMode = nil
local enabled = false
local sparklerList = {}
local angle = 0
local height, size, speed = 10, 10, 2
local railDirections, railOffsets = {}, {}

-- 🔍 スパークラー検出
local function findNearbySparklers(radius)
    local found = {}
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") and obj.Name:lower():find("base") then
            if (obj.Position - head.Position).Magnitude < radius then
                obj.Anchored = true
                table.insert(found, obj)
            end
        end
    end
    return found
end

-- 🌟 星モード
local function getStarPathPos(i, t)
    local starPoints = {}
    local step = math.pi * 2 / 5
    for k = 1, 5 do
        local ang = step * (k - 1)
        starPoints[k] = Vector3.new(math.cos(ang), 0, math.sin(ang))
    end
    local order = {1, 3, 5, 2, 4, 1}
    local totalSeg = #order - 1
    local seg = ((i + t / 10) % totalSeg) + 1
    local idx = math.floor(seg)
    local ratio = seg - idx
    local p1 = starPoints[order[idx]]
    local p2 = starPoints[order[idx + 1]]
    local pos = p1:Lerp(p2, ratio) * size
    return Vector3.new(pos.X, height, pos.Z)
end

-- 💫 各モード位置決定
local function getTargetPos(mode, i, t)
    if mode == "星" then
        return getStarPathPos(i, t)
    elseif mode == "丸" then
        local count = math.max(1, #sparklerList)
        local angleDeg = (i - 1) * (360 / count) + t
        local rad = math.rad(angleDeg)
        return Vector3.new(math.cos(rad) * size, height, math.sin(rad) * size)
    elseif mode == "変化" then
        local rad = math.rad(t + i * 15)
        local spiral = size * 0.8 + (i * 0.3)
        return Vector3.new(math.cos(rad) * spiral, height + math.sin(rad * 2) * 3, math.sin(rad) * spiral)
    elseif mode == "マジック" then
        local dir = railDirections[i]
        local offset = railOffsets[i]
        local movement = math.sin(t * 0.05 * speed + offset) * size
        return dir * movement
    end
end

-- 🎬 メインループ
task.spawn(function()
    while task.wait(0.02) do
        if enabled and activeMode and #sparklerList > 0 then
            if not head or not head.Parent then continue end
            angle += speed
            for i, base in pairs(sparklerList) do
                if base and base.Parent then
                    local targetOffset = getTargetPos(activeMode, i, angle)
                    local targetPos = head.Position + targetOffset
                    if targetPos.Magnitude < 10000 then
                        base.CFrame = CFrame.new(targetPos, head.Position)
                    else
                        base.CFrame = CFrame.new(head.Position)
                    end
                end
            end
        end
    end
end)

-- 🧩 モードタブ作成関数
local function createModeTab(modeName, icon)
    local tab = Window:CreateTab(modeName .. "", icon)

    tab:CreateSlider({
        Name = "高さ",
        Range = {1, 200},
        Increment = 1,
        CurrentValue = height,
        Callback = function(v) height = v end
    })
    tab:CreateSlider({
        Name = "大きさ",
        Range = {1, 1000},
        Increment = 1,
        CurrentValue = size,
        Callback = function(v) size = v end
    })
    tab:CreateSlider({
        Name = "スピード",
        Range = {1, 300},
        Increment = 1,
        CurrentValue = speed,
        Callback = function(v) speed = v end
    })

    tab:CreateToggle({
        Name = "つける",
        CurrentValue = false,
        Callback = function(value)
            if value then
                activeMode = modeName
                enabled = true
                sparklerList = findNearbySparklers(100)

                if modeName == "マジック" then
                    railDirections = {}
                    railOffsets = {}
                    for i, s in ipairs(sparklerList) do
                        railDirections[i] = Vector3.new(math.random(-100,100)/100, math.random(-100,100)/100, math.random(-100,100)/100).Unit
                        railOffsets[i] = math.random() * math.pi * 2
                    end
                end
            else
                enabled = false
                sparklerList = {}
            end
        end
    })
end

-- 🌟 各モードタブ作成
createModeTab("星", 4483362458)
createModeTab("丸", 4483362458)
createModeTab("変化", 4483362458)
createModeTab("マジック", 4483362458)

Rayfield:LoadConfiguration()
