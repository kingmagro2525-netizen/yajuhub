-- Gg Hub : Full-integrated version with Troll Tab (client-side)
-- Tabs: AP / ESP / AUTO / Misc / プレイヤー / 作者 / Music / Troll
-- IMPORTANT: Many "global" visual effects are best-effort client->workspace creations.
--            They may or may not be visible to other players depending on the game's protections.

-- ===== Services / Locals =====
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local SoundService = game:GetService("SoundService")
local StarterGui = game:GetService("StarterGui")

-- ===== Rayfield UI load =====
local ok, Rayfield = pcall(function()
    return loadstring(game:HttpGet("https://sirius.menu/rayfield"))()
end)
if not ok or not Rayfield then
    warn("[Gg Hub] Failed to load Rayfield UI. Aborting.")
    return
end

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

-- ===== Global cleanup registries (to avoid duplicates on reload) =====
if _G.GgHub_Billboards then
    for _, b in pairs(_G.GgHub_Billboards) do pcall(function() if b and b.Parent then b:Destroy() end end) end
end
if _G.GgHub_Highlights then
    for _, h in pairs(_G.GgHub_Highlights) do pcall(function() if h and h.Parent then h:Destroy() end end) end
end
if _G.GgHub_Tracers then
    for _, t in pairs(_G.GgHub_Tracers) do pcall(function() if t and t.line then pcall(function() t.line:Remove() end) end end) end
end
if _G.GgHub_MusicFolder then
    pcall(function() if _G.GgHub_MusicFolder.Parent then _G.GgHub_MusicFolder:Destroy() end end)
end
if _G.GgHub_MiscFolder then
    pcall(function() if _G.GgHub_MiscFolder.Parent then _G.GgHub_MiscFolder:Destroy() end end)
end

_G.GgHub_Billboards = {}
_GgHub_Billboards = _G.GgHub_Billboards -- alias
_G.GgHub_Highlights = {}
_G.GgHub_Tracers = {}
_G.GgHub_MusicFolder = nil
_G.GgHub_MiscFolder = nil

-- ===== Helper: safe pcall create =====
local function safeNew(className, props)
    local ok, inst = pcall(function() return Instance.new(className) end)
    if not ok then return nil end
    if props and inst then
        for k,v in pairs(props) do
            pcall(function() inst[k] = v end)
        end
    end
    return inst
end

-- =========================
-- AP Tab (Auto Parry)
-- =========================
local TabAP = Window:CreateTab("AP ⚔️", 7734053427)
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
    -- Try VirtualInputManager, then keypress, else fallback
    pcall(function()
        local vim = game:GetService("VirtualInputManager")
        vim:SendKeyEvent(true, Enum.KeyCode.F, false, game)
        task.wait(0.03)
        vim:SendKeyEvent(false, Enum.KeyCode.F, false, game)
    end)
    pcall(function()
        if keypress and keyrelease then
            keypress(0x46)
            task.wait(0.03)
            keyrelease(0x46)
        end
    end)
end

local function isCharacterRed(char)
    if not char then return false end
    for _, part in ipairs(char:GetDescendants()) do
        if part:IsA("BasePart") then
            local success, c = pcall(function() return part.Color end)
            if success and c then
                if c.R > 0.7 and c.G < 0.5 and c.B < 0.5 then
                    return true
                end
            end
        end
    end
    local hl = char:FindFirstChildOfClass("Highlight")
    if hl and hl.OutlineColor and hl.OutlineColor == Color3.fromRGB(255,0,0) then return true end
    return false
end

local function isBallLike(obj, hrp)
    if not obj or not obj:IsA("BasePart") then return false end
    local name = tostring(obj.Name):lower()
    if not string.find(name, "ball") then
        if obj:IsA("MeshPart") then
            local s = obj.Size
            if not (math.abs(s.X - s.Y) < 0.2 and math.abs(s.Y - s.Z) < 0.2) then
                return false
            end
        else
            return false
        end
    end
    if obj.Anchored then return false end
    local vel = (obj.AssemblyLinearVelocity or obj.Velocity or Vector3.new(0,0,0))
    if vel.Magnitude < 1.5 then return false end
    if hrp and vel.Magnitude > 0.01 then
        local toPlayer = (hrp.Position - obj.Position)
        if toPlayer.Magnitude > 0.5 then
            local dot = 0
            pcall(function() dot = (vel.Unit):Dot(toPlayer.Unit) end)
            if dot < 0.15 then return false end
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

-- =========================
-- ESP Tab
-- =========================
local TabESP = Window:CreateTab("ESP 👀", 6034509993)
TabESP:CreateSection("ESP")

local espState = { name = false, box = false, tracer = false }
local tracerColor = Color3.fromRGB(255,0,0)
local billboards = _G.GgHub_Billboards
local highlights = _G.GgHub_Highlights
local tracers = _G.GgHub_Tracers

local function createNameTag(plr)
    if not plr or not plr.Character then return end
    local head = plr.Character:FindFirstChild("Head")
    if not head then return end
    local exist = head:FindFirstChild("ESP_NameTag")
    if exist then exist:Destroy() end
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "ESP_NameTag"
    billboard.Adornee = head
    billboard.Size = UDim2.new(0,160,0,28)
    billboard.StudsOffset = Vector3.new(0,2.5,0)
    billboard.AlwaysOnTop = true
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
    local exist = plr.Character:FindFirstChild("ESP_Highlight")
    if exist then exist:Destroy() end
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
    local success, line = pcall(function() return Drawing.new("Line") end)
    if not success or not line then return end
    line.Color = color or tracerColor
    line.Thickness = 2
    line.Visible = false
    tracers[plr.UserId] = { line = line }
end

local function removeTracerObj(plr)
    local t = tracers[plr.UserId]
    if t and t.line then pcall(function() t.line:Remove() end) end
    tracers[plr.UserId] = nil
end

local function cleanupPlayerESP(plr)
    removeNameTag(plr)
    removeHighlight(plr)
    removeTracerObj(plr)
end

function applyESPToPlayer(plr)
    if not plr or plr == LocalPlayer then return end
    if espState.name then createNameTag(plr) else removeNameTag(plr) end
    if espState.box then createHighlight(plr) else removeHighlight(plr) end
    if espState.tracer then createTracerObj(plr, tracerColor) else removeTracerObj(plr) end
end

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

Players.PlayerAdded:Connect(function(plr)
    plr.CharacterAdded:Connect(function()
        task.wait(0.1)
        applyESPToPlayer(plr)
    end)
end)
Players.PlayerRemoving:Connect(function(plr) cleanupPlayerESP(plr) end)

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

-- =========================
-- AUTO Tab (Anti AFK)
-- =========================
local TabAuto = Window:CreateTab("AUTO 🔄", 6031094678)
TabAuto:CreateSection("Automation")

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

-- =========================
-- Misc Tab
-- =========================
local TabMisc = Window:CreateTab("Misc 🧰", 6031280882)
TabMisc:CreateSection("Utilities")

TabMisc:CreateButton({
    Name = "Reset Character",
    Callback = function()
        if LocalPlayer.Character then pcall(function() LocalPlayer.Character:BreakJoints() end) end
    end
})

TabMisc:CreateButton({
    Name = "Godmode",
    Callback = function()
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            pcall(function() LocalPlayer.Character.Humanoid.Name = "GodHumanoid" end)
        end
    end
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
    Name = "Save Settings",
    Callback = function()
        pcall(function() Rayfield:SaveConfiguration() end)
        pcall(function() Rayfield:Notify({ Title = "Saved!", Content = "Settings saved for " .. LocalPlayer.Name, Duration = 4 }) end)
    end
})

TabMisc:CreateButton({
    Name = "Load Settings",
    Callback = function()
        pcall(function() Rayfield:LoadConfiguration() end)
        pcall(function() Rayfield:Notify({ Title = "Loaded!", Content = "Settings loaded for " .. LocalPlayer.Name, Duration = 4 }) end)
    end
})

-- =========================
-- Player Tab (Japanese)
-- =========================
local TabPlayer = Window:CreateTab("プレイヤー 🕺", 6034509994)
TabPlayer:CreateSection("Player Settings")

TabPlayer:CreateSlider({
    Name = "WalkSpeed",
    Range = {16, 200},
    Increment = 1,
    CurrentValue = 16,
    Callback = function(v)
        pcall(function()
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                LocalPlayer.Character.Humanoid.WalkSpeed = v
            end
        end)
    end
})

TabPlayer:CreateSlider({
    Name = "JumpPower",
    Range = {50, 300},
    Increment = 5,
    CurrentValue = 50,
    Callback = function(v)
        pcall(function()
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                LocalPlayer.Character.Humanoid.JumpPower = v
            end
        end)
    end
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
    Callback = function()
        pcall(function()
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                LocalPlayer.Character.Humanoid.MaxHealth = 500
                LocalPlayer.Character.Humanoid.Health = 500
            end
        end)
    end
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

-- Teleport dropdown robust init
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

-- =========================
-- Author Tab (Japanese)
-- =========================
local TabAuthor = Window:CreateTab("作者 ✍️", 6031280858)
TabAuthor:CreateSection("Author Info")

TabAuthor:CreateButton({ Name = "Copy Author: yajusaiko4545", Callback = function() pcall(function() setclipboard("yajusaiko4545") end) end })
TabAuthor:CreateButton({ Name = "TikTok: yajusaiko4545", Callback = function() pcall(function() setclipboard("yajusaiko4545") end) end })
TabAuthor:CreateButton({ Name = "Discord: yajusaiko4545", Callback = function() pcall(function() setclipboard("yajusaiko4545") end) end })

-- =========================
-- Music Tab (50 tracks placeholder)
-- =========================
local TabMusic = Window:CreateTab("Music 🎵", 6026663719)
TabMusic:CreateSection("Music Player (Global-ish)")

-- song table: keys ordered like "01. Name" etc
local Songs = {
    -- Note: many placeholder IDs — replace with valid rbxassetids as needed
    ["1. Infernal Funk"] = "rbxassetid://1835774571",
    ["2. Funk (generic)"] = "rbxassetid://79004524366784",
    ["3. Bouncy Funk"] = "rbxassetid://1839802242",
    ["4. Funk do Goofy"] = "rbxassetid://105832154444494",
    ["5. BRR BRR PATAPIM FUNK"] = "rbxassetid://117170901476451",
    ["6. Boogie Funk Cops"] = "rbxassetid://1836262425",
    ["7. Funky Town"] = "rbxassetid://1841068332",
    ["8. Brazil Do Funk"] = "rbxassetid://133498554139200",
    ["9. What The Funk?"] = "rbxassetid://82585964553305",
    ["10. Freaky Funk"] = "rbxassetid://73140398421340",
    -- 11..50 (some placeholders / repeats)
    ["11. Clap"] = "rbxassetid://1845351312",
    ["12. Funk da Favela"] = "rbxassetid://1837196820",
    ["13. F-360"] = "rbxassetid://1841682637",
    ["14. Funk Festa"] = "rbxassetid://103409297553965",
    ["15. Goofy (alt)"] = "rbxassetid://124928367733395",
    ["16. Tudo"] = "rbxassetid://124928367733395",
    ["17. Hoje é Baile Funk Rave"] = "rbxassetid://6524526935",
    ["18. Brazil Funk 80s"] = "rbxassetid://133498554139200",
    ["19. Funk Sample A"] = "rbxassetid://1841682507",
    ["20. Funk Sample B"] = "rbxassetid://127091051322471",
    ["21. Phonk Loop 1"] = "rbxassetid://7345678901",
    ["22. Phonk Loop 2"] = "rbxassetid://8456789012",
    ["23. Phonk Beat 3"] = "rbxassetid://6983600450",
    ["24. Dark Phonk 1"] = "rbxassetid://8989012423",
    ["25. Retro Phonk"] = "rbxassetid://9120316202",
    ["26. Chill Phonk"] = "rbxassetid://9120199876",
    ["27. Memphis Phonk"] = "rbxassetid://9120245654",
    ["28. Phonk Sample X"] = "rbxassetid://9054321234",
    ["29. Phonk Sample Y"] = "rbxassetid://9054325678",
    ["30. Phonk Sample Z"] = "rbxassetid://9054329999",
    ["31. Funk Remix 1"] = "rbxassetid://1837199999",
    ["32. Funk Remix 2"] = "rbxassetid://1837200001",
    ["33. Funk Groove 1"] = "rbxassetid://1849999999",
    ["34. Funk Groove 2"] = "rbxassetid://1850000001",
    ["35. Party Funk 1"] = "rbxassetid://1067890123",
    ["36. Party Funk 2"] = "rbxassetid://1167890123",
    ["37. Dance Funk 1"] = "rbxassetid://1330000000",
    ["38. Dance Funk 2"] = "rbxassetid://1330001111",
    ["39. Bass Funk"] = "rbxassetid://1400000000",
    ["40. Electro Funk"] = "rbxassetid://1410000001",
    ["41. Masha UltraFunk"] = "rbxassetid://1848354536",
    ["42. Vem No Pique"] = "rbxassetid://6715959738",
    ["43. KrushDaFight"] = "rbxassetid://9123456780",
    ["44. Funk de Beleza (part1)"] = "rbxassetid://127091051322471",
    ["45. Que Beleza"] = "rbxassetid://1841682507",
    ["46. Brazil Funk Hit"] = "rbxassetid://133498554139200",
    ["47. Hoje Baile Funk (alt)"] = "rbxassetid://6524526935",
    ["48. Murder In My Mind (Kordhell)"] = "rbxassetid://8989012423",
    ["49. Sample Funk 49"] = "rbxassetid://123456789012345",
    ["50. Sample Funk 50"] = "rbxassetid://234567890123456",
}

-- prepare songKeys in numeric order
local songKeys = {}
for k,_ in pairs(Songs) do table.insert(songKeys,k) end
table.sort(songKeys, function(a,b)
    local na = tonumber(a:match("^(%d+)")) or 9999
    local nb = tonumber(b:match("^(%d+)")) or 9999
    if na ~= nb then return na < nb end
    return a < b
end)

-- music storage
local musicFolderName = "_GgHub_MusicParts"
local musicFolder = workspace:FindFirstChild(musicFolderName)
if not musicFolder then
    musicFolder = Instance.new("Folder")
    musicFolder.Name = musicFolderName
    musicFolder.Parent = workspace
end
_G.GgHub_MusicFolder = musicFolder

local currentSoundObject = nil
local currentSongKey = nil
local currentVolume = 5
local autoPlay = false
local randomMode = false
local autoplayTask = nil

local function cleanupMusic()
    for _, obj in ipairs(musicFolder:GetChildren()) do pcall(function() obj:Destroy() end) end
    currentSoundObject = nil
    currentSongKey = nil
end

local function createAndPlayGlobalSound(soundId)
    cleanupMusic()
    local part = Instance.new("Part")
    part.Name = "GgHub_MusicPart"
    part.Size = Vector3.new(1,1,1)
    part.Transparency = 1
    part.CanCollide = false
    -- place near local player (best-effort)
    part.CFrame = (LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character.HumanoidRootPart.CFrame) or CFrame.new(0,10,0)
    part.Anchored = true
    part.Parent = musicFolder

    local sound = Instance.new("Sound")
    sound.Name = "GgHub_Sound"
    sound.SoundId = tostring(soundId)
    sound.Looped = true
    pcall(function() sound.Volume = currentVolume end)
    sound.RollOffMode = Enum.RollOffMode.Linear
    sound.Parent = part
    pcall(function() sound:Play() end)
    currentSoundObject = { part = part, sound = sound }
end

local function playSongByKey(key)
    if not key or not Songs[key] then return end
    local id = Songs[key]
    createAndPlayGlobalSound(id)
    currentSongKey = key
end

local function stopMusic()
    if currentSoundObject and currentSoundObject.sound then
        pcall(function() currentSoundObject.sound:Stop() end)
    end
    cleanupMusic()
end

local function nextSong()
    if randomMode then
        local idx = math.random(1,#songKeys)
        playSongByKey(songKeys[idx])
    else
        if not currentSongKey then
            playSongByKey(songKeys[1])
            return
        end
        local curIndex = nil
        for i,k in ipairs(songKeys) do if k==currentSongKey then curIndex = i break end end
        local nextIndex = (curIndex and curIndex % #songKeys + 1) or 1
        playSongByKey(songKeys[nextIndex])
    end
end

local function prevSong()
    if randomMode then
        local idx = math.random(1,#songKeys)
        playSongByKey(songKeys[idx])
    else
        if not currentSongKey then
            playSongByKey(songKeys[1])
            return
        end
        local curIndex = nil
        for i,k in ipairs(songKeys) do if k==currentSongKey then curIndex = i break end end
        local prevIndex = (curIndex and ((curIndex - 2) % #songKeys) + 1) or 1
        playSongByKey(songKeys[prevIndex])
    end
end

-- Music UI
local dropdownOptions = {}
for i,k in ipairs(songKeys) do table.insert(dropdownOptions, k) end
local selectedSongOption = nil
local songDropdown = TabMusic:CreateDropdown({
    Name = "Select Song (1-50)",
    Options = dropdownOptions,
    CurrentOption = dropdownOptions[1] or "",
    Callback = function(option) selectedSongOption = option end
})

TabMusic:CreateButton({ Name = "Play", Callback = function() if selectedSongOption then playSongByKey(selectedSongOption) else playSongByKey(songKeys[1]) end end })
TabMusic:CreateButton({ Name = "Stop", Callback = function() stopMusic() end })
TabMusic:CreateButton({ Name = "Next", Callback = function() nextSong() end })
TabMusic:CreateButton({ Name = "Prev", Callback = function() prevSong() end })
TabMusic:CreateToggle({ Name = "Random Mode", CurrentValue = false, Flag = "MusicRandomMode", Callback = function(val) randomMode = val end })
TabMusic:CreateButton({ Name = "Random Play (one song)", Callback = function() local idx = math.random(1,#songKeys) playSongByKey(songKeys[idx]) end })
TabMusic:CreateSlider({ Name = "Volume (1-20)", Range = {1,20}, Increment = 1, CurrentValue = currentVolume, Callback = function(v) currentVolume = v if currentSoundObject and currentSoundObject.sound then pcall(function() currentSoundObject.sound.Volume = currentVolume end) end end })
TabMusic:CreateToggle({ Name = "Auto Play", CurrentValue = false, Flag = "MusicAutoPlayFlag", Callback = function(val) autoPlay = val if autoPlay then if not autoplayTask then autoplayTask = task.spawn(function() while autoPlay do local waitTime = 120 if currentSoundObject and currentSoundObject.sound then local ok,len = pcall(function() return currentSoundObject.sound.TimeLength end) if ok and type(len)=="number" and len>1 and not currentSoundObject.sound.Looped then waitTime = len end end task.wait(waitTime) if not autoPlay then break end nextSong() end autoplayTask = nil end) end else autoPlay = false end end })
TabMusic:CreateButton({ Name = "Save Music Settings", Callback = function() pcall(function() Rayfield:SaveConfiguration() Rayfield:Notify({Title="Music", Content="Music settings saved", Duration=3}) end) end })
TabMusic:CreateButton({ Name = "Load Music Settings", Callback = function() pcall(function() Rayfield:LoadConfiguration() Rayfield:Notify({Title="Music", Content="Music settings loaded", Duration=3}) end) end })

-- =========================
-- Troll Tab (All features requested)
-- =========================
local TabTroll = Window:CreateTab("Troll 😈", 7743878856)
TabTroll:CreateSection("Fun / Prank Tools (visual only)")

-- ensure misc folder exists to store generated prank objects
local miscFolderName = "_GgHub_MiscEffects"
local miscFolder = workspace:FindFirstChild(miscFolderName)
if not miscFolder then
    miscFolder = Instance.new("Folder")
    miscFolder.Name = miscFolderName
    miscFolder.Parent = workspace
end
_G.GgHub_MiscFolder = miscFolder

-- helper spawn function
local function spawnPartAt(pos, size, color, anchored, lifetime, material)
    local p = Instance.new("Part")
    p.Size = size or Vector3.new(1,1,1)
    p.Position = pos or Vector3.new(0,10,0)
    p.Anchored = anchored == nil and false or anchored
    p.CanCollide = false
    p.Material = material or Enum.Material.Neon
    p.Color = color or Color3.fromRGB(255,255,255)
    p.Parent = miscFolder
    if lifetime and lifetime > 0 then
        task.delay(lifetime, function() p:Destroy() end)
    end
    return p
end

-- Helper: create decorative explosion (visual only)
local function fakeExplosionAt(pos, radius)
    local r = radius or 6
    -- particles-like: create many small parts outward
    for i=1,20 do
        local dir = Vector3.new((math.random()-0.5)*2, (math.random()-0.2)*2, (math.random()-0.5)*2).Unit
        local sp = spawnPartAt(pos + dir * 0.5, Vector3.new(0.4,0.4,0.4), Color3.fromHSV(math.random(),1,1), false, 6, Enum.Material.Neon)
        pcall(function()
            sp.AssemblyLinearVelocity = dir * (20 + math.random()*40)
            sp.AssemblyAngularVelocity = Vector3.new(math.random()*10,math.random()*10,math.random()*10)
        end)
    end
    -- ring
    for i=1,18 do
        local ang = (i/18) * math.pi*2
        local offset = Vector3.new(math.cos(ang)*r, 0, math.sin(ang)*r)
        local ring = spawnPartAt(pos + offset + Vector3.new(0,2,0), Vector3.new(1,1,1), Color3.fromRGB(255,160,0), false, 6, Enum.Material.Neon)
        pcall(function() ring.AssemblyLinearVelocity = Vector3.new(0, 20, 0) end)
    end
end

-- Fake Kill Notification (local system chat style)
TabTroll:CreateButton({
    Name = "Fake Kill Notification",
    Callback = function()
        local txt = string.format("[KILL] %s was eliminated by an unknown force.", LocalPlayer.Name)
        StarterGui:SetCore("ChatMakeSystemMessage", {
            Text = txt,
            Color = Color3.fromRGB(255,80,80),
            Font = Enum.Font.SourceSansBold,
            FontSize = Enum.FontSize.Size24
        })
    end
})

-- Global BGM quick play (uses existing Songs list; plays in workspace so others may hear)
TabTroll:CreateDropdown({
    Name = "Prank Music (Select)",
    Options = songKeys,
    CurrentOption = songKeys[1],
    Callback = function(opt) TabTroll.SelectedPrankSong = opt end
})
TabTroll:CreateButton({
    Name = "Play Prank Music (Global-ish)",
    Callback = function()
        local sel = TabTroll.SelectedPrankSong or songKeys[1]
        if Songs[sel] then
            createAndPlayGlobalSound(Songs[sel])
            Rayfield:Notify({ Title = "Troll", Content = "Prank music playing (best-effort global).", Duration = 3 })
        end
    end
})
TabTroll:CreateButton({
    Name = "Stop Prank Music",
    Callback = function()
        stopMusic()
        Rayfield:Notify({ Title = "Troll", Content = "Prank music stopped.", Duration = 2 })
    end
})

-- Fake Explosion (visual only) at player's position
TabTroll:CreateButton({
    Name = "Fake Explosion (Local Visual)",
    Callback = function()
        local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if hrp then
            fakeExplosionAt(hrp.Position, 6)
            Rayfield:Notify({ Title = "Troll", Content = "Boom! (visual only)", Duration = 2 })
        end
    end
})

-- Spawn Giant Text (LOL / GG / FUNK)
TabTroll:CreateDropdown({
    Name = "Giant Text",
    Options = {"LOL","GG","FUNK"},
    CurrentOption = "LOL",
    Callback = function(opt) TabTroll.GiantTextChoice = opt end
})
TabTroll:CreateButton({
    Name = "Spawn Giant Text Nearby",
    Callback = function()
        local text = TabTroll.GiantTextChoice or "LOL"
        local pos = (LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character.HumanoidRootPart.Position + Vector3.new(0,10,0)) or Vector3.new(0,10,0)
        local base = Instance.new("Part")
        base.Size = Vector3.new(#text*2, 5, 1)
        base.Anchored = true
        base.CanCollide = false
        base.Position = pos
        base.Transparency = 1
        base.Parent = miscFolder
        local gui = Instance.new("SurfaceGui", base)
        gui.Face = Enum.NormalId.Front
        gui.AlwaysOnTop = true
        local label = Instance.new("TextLabel", gui)
        label.Size = UDim2.new(1,0,1,0)
        label.Text = text
        label.TextScaled = true
        label.Font = Enum.Font.Fantasy
        label.TextColor3 = Color3.fromRGB(255,0,0)
        -- auto remove
        task.delay(12, function() pcall(function() base:Destroy() end) end)
    end
})

-- Spawn Dummy Player (visual)
TabTroll:CreateButton({
    Name = "Spawn Dummy Player",
    Callback = function()
        local hrpPos = (LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character.HumanoidRootPart.Position) or Vector3.new(0,5,0)
        local dummy = Instance.new("Part")
        dummy.Size = Vector3.new(2,5,1)
        dummy.Position = hrpPos + Vector3.new(5,0,0)
        dummy.Anchored = true
        dummy.CanCollide = false
        dummy.BrickColor = BrickColor.Random()
        dummy.Name = "GgHub_Dummy"
        dummy.Parent = miscFolder
        -- simple head label
        local head = Instance.new("Part")
        head.Size = Vector3.new(1.2,1.2,1.2)
        head.Position = dummy.Position + Vector3.new(0,3.2,0)
        head.Anchored = true
        head.Parent = miscFolder
        local billboard = Instance.new("BillboardGui", head)
        billboard.Size = UDim2.new(0,120,0,40)
        billboard.AlwaysOnTop = true
        local lbl = Instance.new("TextLabel", billboard)
        lbl.Size = UDim2.new(1,0,1,0)
        lbl.Text = "Dummy"
        lbl.TextScaled = true
        task.delay(18, function() pcall(function() dummy:Destroy() head:Destroy() end) end)
    end
})

-- Fake System Message (local)
TabTroll:CreateButton({
    Name = "Fake System Message",
    Callback = function()
        StarterGui:SetCore("ChatMakeSystemMessage", {
            Text = "⚠ Server maintenance in 10s (just a prank)",
            Color = Color3.fromRGB(255,200,0),
            Font = Enum.Font.SourceSansBold,
            FontSize = Enum.FontSize.Size24
        })
    end
})

-- Big Head (local for everyone? Here implemented local and best-effort attempt on all characters if visible)
TabTroll:CreateButton({
    Name = "Big Head (Local)",
    Callback = function()
        for _, p in ipairs(Players:GetPlayers()) do
            if p.Character and p.Character:FindFirstChild("Head") then
                pcall(function() p.Character.Head.Size = Vector3.new(6,6,6) end)
            end
        end
        Rayfield:Notify({ Title="Troll", Content="Attempted Big Head (local change).", Duration=3 })
    end
})

-- Fly toggle (local)
local flying = false
TabTroll:CreateToggle({
    Name = "Fly (local)",
    CurrentValue = false,
    Callback = function(state)
        flying = state
        if flying then
            task.spawn(function()
                while flying do
                    task.wait(0.12)
                    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                        -- small upward force to "hover"
                        local hrp = LocalPlayer.Character.HumanoidRootPart
                        hrp.Velocity = Vector3.new(hrp.Velocity.X, 0, hrp.Velocity.Z)
                    end
                end
            end)
        end
    end
})

-- Force All Players Jump (local attempt)
TabTroll:CreateButton({
    Name = "Force All Players Jump (local attempts)",
    Callback = function()
        for _, p in ipairs(Players:GetPlayers()) do
            if p.Character and p.Character:FindFirstChild("Humanoid") then
                pcall(function() p.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping) end)
            end
        end
    end
})

-- Glow Aura (local on localplayer)
TabTroll:CreateButton({
    Name = "Glow Aura (local)",
    Callback = function()
        if LocalPlayer.Character then
            local hl = Instance.new("Highlight")
            hl.Name = "GgHub_GlowAura"
            hl.FillTransparency = 0.6
            hl.OutlineColor = Color3.fromRGB(255,0,255)
            hl.Parent = LocalPlayer.Character
            task.delay(20, function() pcall(function() if hl and hl.Parent then hl:Destroy() end end) end)
        end
    end
})

-- Cleanup misc effects
TabTroll:CreateButton({
    Name = "Cleanup Troll Effects",
    Callback = function()
        pcall(function()
            for _, obj in ipairs(miscFolder:GetChildren()) do pcall(function() obj:Destroy() end) end
        end)
        Rayfield:Notify({ Title="Troll", Content="Cleaned up troll effects.", Duration=2 })
    end
})

-- =========================
-- Final: notifications & auto-load config
-- =========================
task.delay(0.7, function()
    pcall(function() Rayfield:LoadConfiguration() end)
end)

Rayfield:Notify({
    Title = "Gg Hub",
    Content = "Loaded: AP / ESP / AUTO / Misc / プレイヤー / 作者 / Music / Troll",
    Duration = 4
})

print("[Gg Hub] Loaded full build with Troll tab. Test features in private server first.")
