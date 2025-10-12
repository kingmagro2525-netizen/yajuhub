local HttpService = game:GetService("HttpService")
local success, Rayfield = pcall(function()
    return loadstring(game:HttpGet("https://sirius.menu/rayfield"))()
end)
if not success then
    warn("Rayfieldロード失敗")
    return
end

local Window = Rayfield:CreateWindow({
    Name = "やじゅうの花火",
    LoadingTitle = "ロード中 やじゅうの花火",
    LoadingSubtitle = "by yajusaiko4545",
    ConfigurationSaving = {Enabled = false}
})

local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local head = character:WaitForChild("Head")

local activeMode = nil
local enabled = false
local sparklerList = {}
local angle = 0
local railDirections, railOffsets, railTargets = {}, {}, {}

local modes = {"星","丸","変化","マジック"}
local modeConfigs = {}

for _, mode in ipairs(modes) do
    local filename = mode.."_config.json"
    if isfile(filename) then
        modeConfigs[mode] = HttpService:JSONDecode(readfile(filename))
    else
        modeConfigs[mode] = {Height=10, Size=10, Speed=2}
    end
end

local function saveModeConfig(mode)
    local filename = mode.."_config.json"
    writefile(filename, HttpService:JSONEncode(modeConfigs[mode]))
end

local function findNearbySparklers(radius)
    local found = {}
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") and obj.Name:lower():find("base") then
            if (obj.Position - head.Position).Magnitude < radius then
                pcall(function()
                    obj:SetNetworkOwner(nil)
                end)
                obj.Anchored = true
                table.insert(found, obj)
            end
        end
    end
    return found
end

local function getStarPathPos(i, t)
    local step = math.pi*2/5
    local points = {}
    for k=1,5 do
        points[k] = Vector3.new(math.cos(step*(k-1)),0,math.sin(step*(k-1)))
    end
    local order = {1,3,5,2,4,1}
    local totalSeg = #order-1
    local seg = ((i+t/10)%totalSeg)+1
    local idx = math.floor(seg)
    local ratio = seg-idx
    local p1 = points[order[idx]]
    local p2 = points[order[idx+1]]
    local pos = p1:Lerp(p2, ratio) * modeConfigs["星"].Size
    return Vector3.new(pos.X, modeConfigs["星"].Height, pos.Z)
end

local function getTargetPos(mode, i, t)
    local cfg = modeConfigs[mode]
    if mode=="星" then
        return getStarPathPos(i,t)
    elseif mode=="丸" then
        local count = math.max(1,#sparklerList)
        local rad = math.rad((i-1)*(360/count)+t)
        return Vector3.new(math.cos(rad)*cfg.Size, cfg.Height, math.sin(rad)*cfg.Size)
    elseif mode=="変化" then
        local rad = math.rad(t+i*15)
        local spiral = cfg.Size*0.8 + i*0.3
        return Vector3.new(math.cos(rad)*spiral, cfg.Height + math.sin(rad*2)*3, math.sin(rad)*spiral)
    elseif mode=="マジック" then
        local current = railTargets[i] or Vector3.new()
        local dir = railDirections[i]
        local offset = railOffsets[i]
        local target = dir*(math.sin(t*0.05*cfg.Speed + offset)*cfg.Size)
        railTargets[i] = current:Lerp(target, 0.1)
        return railTargets[i]
    end
end

task.spawn(function()
    while task.wait(0.02) do
        if enabled and activeMode and #sparklerList>0 then
            if not head or not head.Parent then continue end
            local cfg = modeConfigs[activeMode]
            angle += cfg.Speed
            for i, base in ipairs(sparklerList) do
                if base and base.Parent then
                    local targetOffset = getTargetPos(activeMode, i, angle)
                    base.CFrame = CFrame.new(head.Position + targetOffset, head.Position)
                end
            end
        end
    end
end)

local function createModeTab(modeName, icon)
    local tab = Window:CreateTab(modeName, icon)
    local cfg = modeConfigs[modeName]

    tab:CreateSlider({
        Name = "高さ",
        Range = {1,200},
        Increment = 1,
        CurrentValue = cfg.Height,
        Callback = function(v)
            cfg.Height = v
            saveModeConfig(modeName)
        end
    })

    tab:CreateSlider({
        Name = "大きさ",
        Range = {1,1000},
        Increment = 1,
        CurrentValue = cfg.Size,
        Callback = function(v)
            cfg.Size = v
            saveModeConfig(modeName)
        end
    })

    tab:CreateSlider({
        Name = "スピード",
        Range = {1,1000},
        Increment = 1,
        CurrentValue = cfg.Speed,
        Callback = function(v)
            cfg.Speed = v
            saveModeConfig(modeName)
        end
    })

    tab:CreateToggle({
        Name = "つける",
        CurrentValue = false,
        Callback = function(value)
            if value then
                activeMode = modeName
                enabled = true
                sparklerList = findNearbySparklers(100)
                railTargets = {}

                if modeName=="マジック" then
                    railDirections={}
                    railOffsets={}
                    for i, s in ipairs(sparklerList) do
                        railDirections[i]=Vector3.new(math.random(-100,100)/100, math.random(-100,100)/100, math.random(-100,100)/100).Unit
                        railOffsets[i]=math.random()*math.pi*2
                        railTargets[i]=Vector3.new()
                    end
                end
            else
                enabled=false
                sparklerList={}
            end
        end
    })
end

for _, mode in ipairs(modes) do
    createModeTab(mode, 4483362458)
end
