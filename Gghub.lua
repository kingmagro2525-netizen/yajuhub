-- Gg Hub : Full restored + Save/Load (account-specific)
-- Tabs: AP / ESP / AUTO / Misc / プレイヤー / 作者
-- Note: Some exploits may not support Drawing/VirtualInputManager/keypress; graceful fallbacks included.

-- Services & locals (LocalPlayer set before Window to use in FileName)
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera

-- Load Rayfield UI
local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

local Window = Rayfield:CreateWindow({
    Name = "Gg Hub",
    LoadingTitle = "Loading Gg Hub",
    LoadingSubtitle = "by yajusaiko4545",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "GgHubConfigs",
        FileName = "GgHub_" .. (LocalPlayer and LocalPlayer.Name or "Unknown")
    }
})

-- ======================================================
-- Global cleanup storage (stable names)
-- ======================================================
if _G.GgHub_Billboards then
    for _, b in pairs(_G.GgHub_Billboards) do pcall(function() if b and b.Parent then b:Destroy() end end) end
end
if _G.GgHub_Highlights then
    for _, h in pairs(_G.GgHub_Highlights) do pcall(function() if h and h.Parent then h:Destroy() end end) end
end
if _G.GgHub_Tracers then
    for _, t in pairs(_G.GgHub_Tracers) do pcall(function() if t and t.line then pcall(function() t.line:Remove() end) end end) end
end

_G.GgHub_Billboards = {}
_G.GgHub_Highlights = {}
_G.GgHub_Tracers = {} -- keyed by player.UserId

local billboards = _G.GgHub_Billboards
local highlights = _G.GgHub_Highlights
local tracers = _G.GgHub_Tracers

-- ======================================================
-- Helper: ESP create/remove functions
-- ======================================================
local function createNameTag(plr)
    if not plr or not plr.Character then return end
    local head = plr.Character:FindFirstChild("Head")
    if not head then return end
    local existing = head:FindFirstChild("ESP_NameTag")
    if existing then existing:Destroy() end

    local billboard = Instance.new("BillboardGui")
    billboard.Name = "ESP_NameTag"
    billboard.Adornee = head
    billboard.Size = UDim2.new(0,160,0,28)
    billboard.StudsOffset = Vector3.new(0,2.5,0)
    billboard.AlwaysOnTop = true
    billboard.ResetOnSpawn = false

    local label = Instance.new("TextLabel", billboard)
    label.Size = UDim2.new(1,0,1,0)
    label.BackgroundTransparency = 1
    label.Text = plr.Name
    label.TextColor3 = Color3.new(1,1,1)
    label.Font = Enum.Font.SourceSansBold
    label.TextScaled = true

    billboard.Parent = head
    billboards[plr.UserId] = billboard
end

local function removeNameTag(plr)
    local b = billboards[plr.UserId]
    if b then pcall(function() b:Destroy() end) end
    billboards[plr.UserId] = nil
end

local function createHighlight(plr)
    if not plr or not plr.Character then return end
    local existing = plr.Character:FindFirstChild("ESP_Highlight")
    if existing then existing:Destroy() end
    local highlight = Instance.new("Highlight")
    highlight.Name = "ESP_Highlight"
    highlight.FillTransparency = 0.8
    highlight.OutlineColor = Color3.fromRGB(0,255,0)
    highlight.Parent = plr.Character
    highlights[plr.UserId] = highlight
end

local function removeHighlight(plr)
    local h = highlights[plr.UserId]
    if h then pcall(function() h:Destroy() end) end
    highlights[plr.UserId] = nil
end

local function createTracerObj(plr, color)
    if tracers[plr.UserId] and tracers[plr.UserId].line then return end
    local ok, line = pcall(function() return Drawing.new("Line") end)
    if not ok or not line then return end
    line.Color = color or Color3.fromRGB(255,0,0)
    line.Thickness = 2
    line.Visible = false
    tracers[plr.UserId] = { line = line }
end

local function removeTracerObj(plr)
    local t = tracers[plr.UserId]
    if t and t.line then
        pcall(function() t.line:Remove() end)
    end
    tracers[plr.UserId] = nil
end

local function cleanupPlayerESP(plr)
    removeNameTag(plr)
    removeHighlight(plr)
    removeTracerObj(plr)
end

-- ======================================================
-- AP Tab (Auto Parry)
-- ======================================================
local TabAP = Window:CreateTab("AP", 4483362458)
TabAP:CreateSection("Auto Parry")

local autoParryEnabled = false
local parryRange = 15
local parryDelay = 0.25
local parryCooldown = 0.5
local lastParry = 0

TabAP:CreateToggle({
    Name = "Auto Parry (Red + Ball-like)",
    CurrentValue = false,
    Callback = function(v) autoParryEnabled = v end
})

TabAP:CreateSlider({
    Name = "Parry Range (studs)",
    Range = {5, 50},
    Increment = 1,
    CurrentValue = parryRange,
    Callback = function(v) parryRange = v end
})

TabAP:CreateSlider({
    Name = "Parry Delay (sec)",
    Range = {0.05, 1},
    Increment = 0.05,
    CurrentValue = parryDelay,
    Callback = function(v) parryDelay = v end
})

local function sendFKey()
    -- try VirtualInputManager
    local ok = pcall(function()
        local vim = game:GetService("VirtualInputManager")
        vim:SendKeyEvent(true, Enum.KeyCode.F, false, game)
        task.wait(0.03)
        vim:SendKeyEvent(false, Enum.KeyCode.F, false, game)
    end)
    if ok then return end
    -- try keypress/keyrelease
    ok = pcall(function()
        if keypress and keyrelease then
            keypress(0x46)
            task.wait(0.03)
            keyrelease(0x46)
        end
    end)
    if ok then return end
    -- fallback (may not be effective in many exploits)
    pcall(function()
        UIS.InputBegan:Fire({KeyCode = Enum.KeyCode.F, UserInputType = Enum.UserInputType.Keyboard}, false)
        task.wait(0.03)
        UIS.InputEnded:Fire({KeyCode = Enum.KeyCode.F, UserInputType = Enum.UserInputType.Keyboard}, false)
    end)
end

local function isCharacterRed(char)
    if not char then return false end
    for _, part in ipairs(char:GetDescendants()) do
        if part:IsA("BasePart") then
            local ok, c = pcall(function() return part.Color end)
            if ok and c then
                if c.R > 0.7 and c.G < 0.4 and c.B < 0.4 then
                    return true
                end
            end
        end
    end
    -- check Highlight red
    local hl = char:FindFirstChildOfClass("Highlight")
    if hl and hl.OutlineColor and hl.OutlineColor == Color3.fromRGB(255,0,0) then
        return true
    end
    return false
end

-- ball-like detection: prefer name contains "ball"; also accept roughly-spherical meshes (heuristic)
local function isBallLike(obj, hrp)
    if not obj or not obj:IsA("BasePart") then return false end
    local name = tostring(obj.Name):lower()
    if not string.find(name, "ball") then
        -- heuristic: roughly equal XYZ size and is a MeshPart (could be sphere)
        if obj:IsA("MeshPart") then
            local s = obj.Size
            if math.abs(s.X - s.Y) < 0.1 and math.abs(s.Y - s.Z) < 0.1 then
                -- ok, treat as ball-like
            else
                return false
            end
        else
            return false
        end
    end
    if obj.Anchored then return false end
    local vel = (obj.AssemblyLinearVelocity or obj.Velocity or Vector3.new(0,0,0))
    if vel.Magnitude < 2 then return false end
    if hrp and vel.Magnitude > 0.01 then
        local toPlayer = (hrp.Position - obj.Position)
        if toPlayer.Magnitude > 0.5 then
            local dot = 0
            pcall(function() dot = (vel.Unit):Dot(toPlayer.Unit) end)
            if dot < 0.2 then return false end
        end
    end
    return true
end

RunService.Heartbeat:Connect(function()
    if not autoParryEnabled then return end
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local humanoid = char:FindFirstChild("Humanoid")
    if not hrp or not humanoid or humanoid.Health <= 0 then return end
    if not isCharacterRed(char) then return end
    local now = tick()
    if now - lastParry < parryCooldown then return end

    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") and isBallLike(obj, hrp) then
            local dist = (obj.Position - hrp.Position).Magnitude
            if dist <= parryRange then
                lastParry = now
                task.spawn(function()
                    task.wait(parryDelay)
                    sendFKey()
                end)
                break
            end
        end
    end
end)

-- ======================================================
-- ESP Tab
-- ======================================================
local TabESP = Window:CreateTab("ESP", 4483362458)
TabESP:CreateSection("ESP")

local espState = { name = false, box = false, tracer = false }
local tracerColor = Color3.fromRGB(255,0,0)

TabESP:CreateToggle({
    Name = "Name ESP",
    CurrentValue = false,
    Callback = function(state)
        espState.name = state
        for _, p in ipairs(Players:GetPlayers()) do applyESPToPlayer(p) end
    end
})

TabESP:CreateToggle({
    Name = "Box ESP",
    CurrentValue = false,
    Callback = function(state)
        espState.box = state
        for _, p in ipairs(Players:GetPlayers()) do applyESPToPlayer(p) end
    end
})

TabESP:CreateToggle({
    Name = "Tracer ESP",
    CurrentValue = false,
    Callback = function(state)
        espState.tracer = state
        for _, p in ipairs(Players:GetPlayers()) do applyESPToPlayer(p) end
    end
})

TabESP:CreateColorPicker({
    Name = "Tracer Color",
    Color = tracerColor,
    Callback = function(c)
        tracerColor = c
        for uid, obj in pairs(tracers) do
            pcall(function() if obj.line then obj.line.Color = tracerColor end end)
        end
    end
})

TabESP:CreateButton({
    Name = "ESP OFF (Clear All)",
    Callback = function()
        espState = { name = false, box = false, tracer = false }
        for _, p in ipairs(Players:GetPlayers()) do cleanupPlayerESP(p) end
    end
})

-- applyESPToPlayer defined here (after TabESP UI to avoid forward ref issue)
function applyESPToPlayer(plr)
    if not plr or plr == LocalPlayer then return end
    if espState.name then createNameTag(plr) else removeNameTag(plr) end
    if espState.box then createHighlight(plr) else removeHighlight(plr) end
    if espState.tracer then createTracerObj(plr, tracerColor) else removeTracerObj(plr) end
end

Players.PlayerAdded:Connect(function(plr)
    plr.CharacterAdded:Connect(function()
        task.wait(0.1)
        applyESPToPlayer(plr)
    end)
end)
Players.PlayerRemoving:Connect(function(plr) cleanupPlayerESP(plr) end)

-- Tracer update loop
RunService.RenderStepped:Connect(function()
    if espState.tracer then
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                local obj = tracers[p.UserId]
                if obj and obj.line then
                    local pos, onScreen = Camera:WorldToViewportPoint(p.Character.HumanoidRootPart.Position)
                    if onScreen then
                        obj.line.From = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y)
                        obj.line.To = Vector2.new(pos.X, pos.Y)
                        obj.line.Color = tracerColor
                        obj.line.Visible = true
                    else
                        obj.line.Visible = false
                    end
                else
                    if espState.tracer then createTracerObj(p, tracerColor) end
                end
            end
        end
    else
        for uid, obj in pairs(tracers) do
            pcall(function() if obj.line then obj.line.Visible = false end end)
        end
    end
end)

-- ======================================================
-- AUTO Tab (Anti AFK)
-- ======================================================
local TabAuto = Window:CreateTab("AUTO", 4483362458)
TabAuto:CreateSection("AUTO")

local antiAfkEnabled = false
TabAuto:CreateToggle({
    Name = "ANTI AFK (Jump every 25s)",
    CurrentValue = false,
    Callback = function(v) antiAfkEnabled = v end
})

task.spawn(function()
    while task.wait(25) do
        if antiAfkEnabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            pcall(function() LocalPlayer.Character.Humanoid:ChangeState("Jumping") end)
        end
    end
end)

-- ======================================================
-- Misc Tab (with Save/Load account-specific)
-- ======================================================
local TabMisc = Window:CreateTab("Misc", 4483362458)
TabMisc:CreateSection("Utility")

TabMisc:CreateButton({
    Name = "Reset Character",
    Callback = function() if LocalPlayer.Character then pcall(function() LocalPlayer.Character:BreakJoints() end) end end
})

TabMisc:CreateButton({
    Name = "Godmode",
    Callback = function() if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then pcall(function() LocalPlayer.Character.Humanoid.Name = "GodHumanoid" end) end end
})

TabMisc:CreateButton({
    Name = "Misc ESP OFF",
    Callback = function()
        espState.box = false
        espState.tracer = false
        for _, p in ipairs(Players:GetPlayers()) do
            removeHighlight(p)
            removeTracerObj(p)
        end
    end
})

TabMisc:CreateButton({
    Name = "Save Setting",
    Callback = function()
        pcall(function() Rayfield:SaveConfiguration() end)
        pcall(function()
            Rayfield:Notify({ Title = "Saved!", Content = "Settings saved for " .. LocalPlayer.Name, Duration = 4 })
        end)
    end
})

TabMisc:CreateButton({
    Name = "Load Setting",
    Callback = function()
        pcall(function() Rayfield:LoadConfiguration() end)
        pcall(function()
            Rayfield:Notify({ Title = "Loaded!", Content = "Settings loaded for " .. LocalPlayer.Name, Duration = 4 })
        end)
    end
})

-- auto-load at startup (silent on failure)
task.delay(1, function()
    pcall(function() Rayfield:LoadConfiguration() end)
end)

-- ======================================================
-- プレイヤー Tab (tab name Japanese; inner labels English)
-- ======================================================
local TabPlayer = Window:CreateTab("プレイヤー", 4483362458)
TabPlayer:CreateSection("Player Settings")

TabPlayer:CreateSlider({
    Name = "WalkSpeed",
    Range = {16, 200},
    Increment = 1,
    CurrentValue = 16,
    Callback = function(v) pcall(function() if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then LocalPlayer.Character.Humanoid.WalkSpeed = v end end) end
})

TabPlayer:CreateSlider({
    Name = "JumpPower",
    Range = {50, 300},
    Increment = 5,
    CurrentValue = 50,
    Callback = function(v) pcall(function() if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then LocalPlayer.Character.Humanoid.JumpPower = v end end) end
})

local infJump = false
TabPlayer:CreateToggle({
    Name = "Infinite Jump",
    CurrentValue = false,
    Callback = function(s) infJump = s end
})
UIS.JumpRequest:Connect(function() if infJump and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then pcall(function() LocalPlayer.Character.Humanoid:ChangeState("Jumping") end) end end)

TabPlayer:CreateButton({
    Name = "Set Health 500",
    Callback = function() pcall(function() if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then LocalPlayer.Character.Humanoid.MaxHealth = 500 LocalPlayer.Character.Humanoid.Health = 500 end end) end
})

local noclip = false
TabPlayer:CreateToggle({
    Name = "Noclip",
    CurrentValue = false,
    Callback = function(s) noclip = s end
})
RunService.Stepped:Connect(function()
    if noclip and LocalPlayer.Character then
        for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") then pcall(function() part.CanCollide = false end) end
        end
    end
end)

-- Teleport dropdown (robust init)
local selectedPlayer = nil
local function getPlayerNamesList()
    local list = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then table.insert(list, p.Name) end
    end
    return list
end

local playerNames = getPlayerNamesList()
if #playerNames == 0 then table.insert(playerNames, "No Players") end

local dropdown = TabPlayer:CreateDropdown({
    Name = "Select Player",
    Options = playerNames,
    CurrentOption = playerNames[1],
    Callback = function(opt)
        if opt == "No Players" then selectedPlayer = nil else selectedPlayer = Players:FindFirstChild(opt) end
    end
})

local function refreshDropdown()
    local names = getPlayerNamesList()
    if #names == 0 then table.insert(names, "No Players") end
    local ok = pcall(function() dropdown:SetOptions(names) end)
    if not ok then
        pcall(function() if dropdown.ClearOptions then dropdown:ClearOptions() end end)
        for _, nm in ipairs(names) do pcall(function() if dropdown.AddOption then dropdown:AddOption(nm) end end) end
        pcall(function() if dropdown.SetValue then dropdown:SetValue(names[1]) end end)
    end
end

refreshDropdown()
Players.PlayerAdded:Connect(refreshDropdown)
Players.PlayerRemoving:Connect(refreshDropdown)

TabPlayer:CreateButton({
    Name = "Teleport to Player",
    Callback = function()
        if selectedPlayer and selectedPlayer.Character and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local hrp = selectedPlayer.Character:FindFirstChild("HumanoidRootPart")
            if hrp then pcall(function() LocalPlayer.Character:MoveTo(hrp.Position + Vector3.new(0,3,0)) end) end
        end
    end
})

TabPlayer:CreateInput({
    Name = "Teleport to Coords (x,y,z)",
    PlaceholderText = "ex: 0,10,0",
    RemoveTextAfterFocusLost = false,
    Callback = function(txt)
        local x,y,z = txt:match("([^,]+),([^,]+),([^,]+)")
        if x and y and z then
            local xr, yr, zr = tonumber(x), tonumber(y), tonumber(z)
            if xr and yr and zr and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                pcall(function() LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(xr, yr, zr) end)
            end
        end
    end
})

TabPlayer:CreateButton({
    Name = "Teleport to Spawn",
    Callback = function()
        local spawn = workspace:FindFirstChildWhichIsA("SpawnLocation") or workspace:FindFirstChild("SpawnLocation")
        if spawn and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            pcall(function() LocalPlayer.Character.HumanoidRootPart.CFrame = spawn.CFrame + Vector3.new(0,5,0) end)
        end
    end
})

-- ======================================================
-- Author Tab (tab name Japanese)
-- ======================================================
local TabAuthor = Window:CreateTab("作者", 4483362458)
TabAuthor:CreateSection("Author Info")

TabAuthor:CreateButton({ Name = "Copy Author: yajusaiko4545", Callback = function() pcall(function() setclipboard("yajusaiko4545") end) end })
TabAuthor:CreateButton({ Name = "TikTok: yajusaiko4545", Callback = function() pcall(function() setclipboard("yajusaiko4545") end) end })
TabAuthor:CreateButton({ Name = "Discord: yajusaiko4545", Callback = function() pcall(function() setclipboard("yajusaiko4545") end) end })

print("[Gg Hub] Full restored loaded. If anything is missing, tell me which tab/feature and paste any runtime error.")
