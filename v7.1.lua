-- FTAP完全統合版 v10.0 Rayfield Edition (Nexus Patched)
-- Converted to Rayfield Interface Suite by Nexus
-- Original Structure Preserved + Critical Fixes Only
-- Security, Performance, Memory Leaks, and Race Conditions Patched

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")
local Lighting = game:GetService("Lighting")
local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")
local VirtualUser = game:GetService("VirtualUser")

-- [修正点5: Race Condition回避] キャラクターの確実な取得
local LocalCharacter = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
LocalPlayer.CharacterAdded:Connect(function(character)
    LocalCharacter = character
end)

-- サーバーリモート (Wait処理の強化)
-- [修正点3: エラーハンドリング] 無限待機を防ぎ、警告を出す
local function safeWaitForChild(parent, name, timeout)
    local child = parent:WaitForChild(name, timeout)
    if not child then
        warn("FTAP Error: Critical remote '" .. name .. "' could not be found in " .. parent.Name)
    end
    return child
end

local GrabEvents = safeWaitForChild(ReplicatedStorage, "GrabEvents", 15)
local MenuToys = safeWaitForChild(ReplicatedStorage, "MenuToys", 15)
local CharacterEvents = safeWaitForChild(ReplicatedStorage, "CharacterEvents", 15)

if not GrabEvents or not MenuToys or not CharacterEvents then
    Rayfield:Notify({
        Title = "Fatal Error",
        Content = "必要なリモートが見つかりません。ゲームが更新された可能性があります。",
        Duration = 10,
        Image = 4483345998,
    })
    return -- 安全に停止
end

local SetNetworkOwner = GrabEvents:WaitForChild("SetNetworkOwner", 10)
local Struggle = CharacterEvents:WaitForChild("Struggle", 10)
local CreateGrabLine = GrabEvents:WaitForChild("CreateGrabLine", 10)
local DestroyGrabLine = GrabEvents:WaitForChild("DestroyGrabLine", 10)
local DestroyToy = MenuToys:WaitForChild("DestroyToy", 10)
local RagdollRemote = CharacterEvents:WaitForChild("RagdollRemote", 10)
local BombEvents = ReplicatedStorage:FindFirstChild("BombEvents")

local toysFolder = workspace:FindFirstChild(LocalPlayer.Name.."SpawnedInToys")

-- グローバル変数の保護
_G.BlobmanDelay = 0.001
_G.ToyToLoad = "BombMissile"
_G.MaxMissiles = 9
_G.flySpeed = 100
_G.kickForce = 150
_G.ufoRotationSpeed = 5
_G.ufoHeight = 10

-- 共通変数定義
local strength = 450
local auraRadius = 20
local whiteListEnabled = false
local espObjects = {}
local connections = {}
local anchoredParts = {}
local compiledGroups = {}
local bombList = {}
local ownedToys = {}
local decoyOffset = 5
local circleRadius = 10
local followMode = true
local crouchWalkSpeed = 50
local crouchJumpPower = 50
local infJump = false
local antiVoidEnabled = false
local defenseStrength = 25
local blobDelay = 0.001
local mouse = LocalPlayer:GetMouse()

-- 新機能用変数
local antiGrabCreatureEnabled = false
local antiGrabTestInvisibleEnabled = false
local antiLagLookEnabled = false
local lineLagEnabled = false
local lineLagAllEnabled = false
local lineLagTarget = nil
local lineLagSpeed = 0.05
local invisibleLineEnabled = false
local randomLineEnabled = false
local gradientRandomEnabled = false
local presetSegments = 10
local antiGrabMode = "none"

-- ターゲット選択変数
local TargetSelected = nil
local LeftBlobSelected = nil
local RightBlobSelected = nil
local DuoBlobSelected = nil
local selectedTarget = nil

-- Coroutine Flags
local coroutineFlags = {
    PoisonGrab = false, PoisonAura = false, GrabAura = false, RadiactiveGrab = false,
    BurnGrab = false, FireAura = false, LoopFireAura = false, KillGrab = false,
    KickGrab = false, UfoGrab = false, NoclipGrab = false, AnchorGrab = false,
    AntiGrab = false, LoopKill = false, OrbitPlayer = false, BringAll = false,
    CrouchSpeed = false, CrouchJump = false, FireAll = false, RagdollAll = false,
    BlobmanAuto = false, HeavenGrab = false, CrazyGrab = false, DeleteAura = false,
    ServerBreak = false, AntiGrabCreature = false, AntiGrabTestInvisible = false,
    FlingAll = false, LoopLeftBlob = false, LoopRightBlob = false, LoopDuoBlob = false
}

-- [修正点4: メモリリーク対策]
local function cleanupESP()
    for _, obj in pairs(espObjects) do
        if obj and obj.Parent then obj:Destroy() end
    end
    table.clear(espObjects)
end

-- 入力監視システム
local isRightClickOrLongPress = false
local isTouchHolding = false
local touchStartTime = 0

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.UserInputType == Enum.UserInputType.Touch then
        isTouchHolding = true
        touchStartTime = tick()
    elseif input.UserInputType == Enum.UserInputType.MouseButton2 then
        isRightClickOrLongPress = true
    end
end)

UserInputService.InputEnded:Connect(function(input, gameProcessed)
    if input.UserInputType == Enum.UserInputType.Touch then
        if tick() - touchStartTime >= 0.3 then isRightClickOrLongPress = true else isRightClickOrLongPress = false end
        isTouchHolding = false
    elseif input.UserInputType == Enum.UserInputType.MouseButton2 then
        isRightClickOrLongPress = false
    end
end)

-- Owned Toys 確認
task.spawn(function()
    pcall(function()
        local menuGui = LocalPlayer:WaitForChild("PlayerGui", 10):WaitForChild("MenuGui", 10)
        if menuGui then
            local contents = menuGui:WaitForChild("Menu"):WaitForChild("TabContents"):WaitForChild("Toys"):WaitForChild("Contents")
            for i, v in pairs(contents:GetChildren()) do
                if v.Name ~= "UIGridLayout" then ownedToys[v.Name] = true end
            end
        end
    end)
end)

-- ユーティリティ関数
local function isDescendantOf(target, other)
    if not target or not other then return false end
    local currentParent = target.Parent
    while currentParent do
        if currentParent == other then return true end
        currentParent = currentParent.Parent
    end
    return false
end

local function sno(player, cf)
    pcall(function()
        if SetNetworkOwner and CreateGrabLine then
            SetNetworkOwner:FireServer(player, cf)
            CreateGrabLine:FireServer(player, cf)
        end
    end)
end

local function ungrab(player)
    pcall(function() if DestroyGrabLine then DestroyGrabLine:FireServer(player) end end)
end

local function isPlayerWhitelisted(player)
    if not whiteListEnabled then return false end
    if not player then return false end
    local success, isFriend = pcall(function() return LocalPlayer:IsFriendsWith(player.UserId) end)
    return success and isFriend
end

local function getDescendantParts(descendantName)
    local parts = {}
    for _, descendant in ipairs(workspace:GetDescendants()) do
        if descendant:IsA("Part") and descendant.Name == descendantName then
            table.insert(parts, descendant)
        end
    end
    return parts
end

local PoisonHurtParts = getDescendantParts("PoisonHurtPart")
local PaintPlayerParts = getDescendantParts("PaintPlayerPart")

local function spawnItem(itemName, position)
    task.spawn(function()
        pcall(function()
            if MenuToys and MenuToys:FindFirstChild("SpawnToyRemoteFunction") then
                MenuToys.SpawnToyRemoteFunction:InvokeServer(itemName, CFrame.new(position), Vector3.new(0, 90, 0))
            end
        end)
    end)
end

local function spawnItemCf(itemName, cframe)
    task.spawn(function()
        pcall(function()
            if MenuToys and MenuToys:FindFirstChild("SpawnToyRemoteFunction") then
                MenuToys.SpawnToyRemoteFunction:InvokeServer(itemName, cframe, Vector3.new(0, 0, 0))
            end
        end)
    end)
end

local function burn(part)
    if not part then return end
    pcall(function()
        if not toysFolder or not toysFolder:FindFirstChild("Campfire") then
            spawnItem("Campfire", Vector3.new(-72.9, -5.9, -265.5))
            task.wait(0.5)
        end
        local campfire = toysFolder and toysFolder:FindFirstChild("Campfire")
        if campfire then
            local burnPart = campfire:FindFirstChild("FirePlayerPart")
            if burnPart then
                burnPart.Size = Vector3.new(7, 7, 7)
                burnPart.Position = part.Position
                task.wait(0.3)
                burnPart.Position = Vector3.new(0, -50, 0)
            end
        end
    end)
end

-- [修正点1 & 6: セキュリティ強化] HookMetamethod
local oldNamecall
local function safeHook()
    local success, err = pcall(function()
        if not hookmetamethod then return end
        task.wait(math.random(1, 3) * 0.1)
        oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
            local method = getnamecallmethod()
            if antiLagLookEnabled and method == "FireServer" then
                if self.Name == "Look" and self.Parent == CharacterEvents and self:IsA("RemoteEvent") then
                    return -- ブロック成功
                end
            end
            return oldNamecall(self, ...)
        end)
    end)
    if not success then warn("Hook initialization warning: " .. tostring(err)) end
end
safeHook()

-- 機能ロジック群 (省略なし)
local function executeCreatureAntiGrab(character)
    spawn(function()
        while coroutineFlags.AntiGrabCreature do
            pcall(function()
                if not character or not character.Parent or not character:FindFirstChild("HumanoidRootPart") then 
                    coroutineFlags.AntiGrabCreature = false; return 
                end
                local hrp = character:FindFirstChild("HumanoidRootPart")
                local hum = character:FindFirstChild("Humanoid")
                local orig = hrp.CFrame
                local spawnY = hrp.Position.Y - 5
                
                MenuToys.SpawnToyRemoteFunction:InvokeServer("CreatureBlobman", CFrame.new(0, 50000, 0), Vector3.new(hrp.Position.X, spawnY, hrp.Position.Z))
                task.wait(0.1)
                local spawned = workspace:FindFirstChild(LocalPlayer.Name .. "SpawnedInToys")
                local blob = spawned and spawned:FindFirstChild("CreatureBlobman")
                if blob then
                    for _, p in pairs(blob:GetDescendants()) do if p:IsA("BasePart") then p.Anchored = true end end
                    local seat = blob:FindFirstChildWhichIsA("Seat") or blob:FindFirstChildWhichIsA("VehicleSeat")
                    if seat then
                        for i = 1, 60 do seat:Sit(hum); RagdollRemote:FireServer(hrp, 0); RunService.Heartbeat:Wait() end
                    end
                    DestroyToy:FireServer(blob)
                end
                task.wait(0.1)
                if hrp then hrp.CFrame = orig end
            end)
            task.wait(1)
        end
    end)
end

local function executeTestInvisibleAntiGrab(character)
    spawn(function()
        while coroutineFlags.AntiGrabTestInvisible do
            pcall(function()
                if not character or not character.Parent then coroutineFlags.AntiGrabTestInvisible = false; return end
                local hrp = character:FindFirstChild("HumanoidRootPart")
                local hum = character:FindFirstChild("Humanoid")
                if not hrp or not hum then return end
                
                local foundSeat = nil
                for _, obj in pairs(workspace:GetDescendants()) do
                    if (obj:IsA("Seat") or obj:IsA("VehicleSeat")) and obj.Name == "Seat" then foundSeat = obj; break end
                end
                
                if foundSeat then
                    workspace.CurrentCamera.CameraType = Enum.CameraType.Scriptable
                    for i = 1, 60 do foundSeat:Sit(hum); RagdollRemote:FireServer(hrp, 0); RunService.Heartbeat:Wait() end
                    workspace.CurrentCamera.CameraType = Enum.CameraType.Custom
                    task.wait(0.1)
                    hrp.CFrame = CFrame.new(hrp.Position.X, 1000, hrp.Position.Z)
                end
            end)
            task.wait(1)
        end
    end)
end

local function executeBarrierBreak()
    spawn(function()
        pcall(function()
            local char = LocalPlayer.Character
            if not char or not char:FindFirstChild("HumanoidRootPart") then return end
            local orig = char.HumanoidRootPart.CFrame
            MenuToys.SpawnToyRemoteFunction:InvokeServer("InstrumentWoodwindOcarina", CFrame.new(184.14, -5.54, 498.13), Vector3.new(0, 34, 0))
            task.wait(0.2)
            local tf = workspace:FindFirstChild(LocalPlayer.Name .. "SpawnedInToys")
            if tf then
                local oca = tf:FindFirstChild("InstrumentWoodwindOcarina")
                if oca and oca:FindFirstChild("HoldPart") then
                    oca.HoldPart.HoldItemRemoteFunction:InvokeServer(oca, char)
                    task.wait(0.2)
                    char.HumanoidRootPart.CFrame = CFrame.new(304.06, 25.77, 488.54)
                    task.wait(0.05)
                    DestroyToy:FireServer(oca)
                    task.wait(0.05)
                    char.HumanoidRootPart.CFrame = orig
                    Rayfield:Notify({Title="Barrier Break", Content="バリア破壊完了！", Duration=3})
                end
            end
        end)
    end)
end

local function UpdateLineColors(...) pcall(function() ReplicatedStorage.DataEvents.UpdateLineColorsEvent:FireServer(...) end) end
local function CreateRainbowSequence() return ColorSequence.new{ColorSequenceKeypoint.new(0, Color3.new(1,0,0)), ColorSequenceKeypoint.new(0.2, Color3.new(1,1,0)), ColorSequenceKeypoint.new(0.4, Color3.new(0,1,0)), ColorSequenceKeypoint.new(0.6, Color3.new(0,1,1)), ColorSequenceKeypoint.new(0.8, Color3.new(0,0,1)), ColorSequenceKeypoint.new(1, Color3.new(1,0,1))} end
local function CreateSolidSequence(color) return ColorSequence.new{ColorSequenceKeypoint.new(0, color), ColorSequenceKeypoint.new(1, color)} end
local function CreateLineLag(targetPlayer) if not targetPlayer or not targetPlayer.Character then return end; local t = targetPlayer.Character:FindFirstChild("Torso") or targetPlayer.Character:FindFirstChild("UpperTorso"); if t then CreateGrabLine:FireServer(t, CFrame.new(0,0,0)) end end

local presets = {["Black & White"]={Color3.new(0,0,0),Color3.new(1,1,1)}, ["Red & Blue"]={Color3.new(1,0,0),Color3.new(0,0,1)}, ["Red & Black"]={Color3.new(1,0,0),Color3.new(0,0,0)}, ["Blue & Yellow"]={Color3.new(0,0,1),Color3.new(1,1,0)}}

-- リスポーンハンドラ
LocalPlayer.CharacterAdded:Connect(function(c)
    LocalCharacter = c
    if coroutineFlags.AntiGrabCreature then executeCreatureAntiGrab(c) end
    if coroutineFlags.AntiGrabTestInvisible then executeTestInvisibleAntiGrab(c) end
end)

local function kickGrab()
    while coroutineFlags.KickGrab do
        pcall(function()
            local c = workspace:FindFirstChild("GrabParts")
            if c then
                local gp = c:FindFirstChild("GrabPart")
                if gp then
                    local w = gp:FindFirstChild("WeldConstraint")
                    if w and w.Part1 and w.Part1.Parent then
                        local hrp = w.Part1.Parent:FindFirstChild("HumanoidRootPart")
                        if hrp then
                            local bv = Instance.new("BodyVelocity", hrp)
                            bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                            bv.Velocity = workspace.CurrentCamera.CFrame.LookVector * _G.kickForce + Vector3.new(0, 50, 0)
                            Debris:AddItem(bv, 0.5)
                            task.wait(0.3)
                        end
                    end
                end
            end
        end)
        task.wait(0.5)
    end
end

local function ufoGrab()
    while coroutineFlags.UfoGrab do
        pcall(function()
            local c = workspace:FindFirstChild("GrabParts")
            if c and c:FindFirstChild("GrabPart") then
                local w = c.GrabPart:FindFirstChild("WeldConstraint")
                if w and w.Part1 and w.Part1.Parent then
                    local hrp = w.Part1.Parent:FindFirstChild("HumanoidRootPart")
                    if hrp then
                        for _,v in pairs(hrp:GetChildren()) do if v:IsA("BodyMover") then v:Destroy() end end
                        local bp = Instance.new("BodyPosition", hrp); bp.MaxForce=Vector3.new(math.huge,math.huge,math.huge); bp.Position=hrp.Position+Vector3.new(0,_G.ufoHeight,0)
                        local bav = Instance.new("BodyAngularVelocity", hrp); bav.MaxTorque=Vector3.new(math.huge,math.huge,math.huge); bav.AngularVelocity=Vector3.new(0,_G.ufoRotationSpeed,0)
                        while workspace:FindFirstChild("GrabParts") and coroutineFlags.UfoGrab do task.wait() end
                        bp:Destroy(); bav:Destroy()
                    end
                end
            end
        end)
        task.wait()
    end
end

local function grabHandler(grabType)
    while true do
        pcall(function()
            local c = workspace:FindFirstChild("GrabParts")
            if c and c:FindFirstChild("GrabPart") then
                local w = c.GrabPart:FindFirstChild("WeldConstraint")
                if w and w.Part1 and w.Part1.Parent then
                    local h = w.Part1.Parent:FindFirstChild("Head")
                    if h then
                        while workspace:FindFirstChild("GrabParts") do
                            local pt = grabType == "poison" and PoisonHurtParts or PaintPlayerParts
                            for _, p in pairs(pt) do p.Size=Vector3.new(2,2,2); p.Transparency=1; p.Position=h.Position end
                            task.wait(); for _, p in pairs(pt) do p.Position=Vector3.new(0,-200,0) end
                        end
                    end
                end
            end
        end)
        task.wait()
    end
end

local function burnGrab()
    while true do
        pcall(function()
            local c = workspace:FindFirstChild("GrabParts")
            if c and c:FindFirstChild("GrabPart") then
                local w = c.GrabPart:FindFirstChild("WeldConstraint")
                if w and w.Part1 and w.Part1.Parent then
                    local h = w.Part1.Parent:FindFirstChild("Head")
                    if h then burn(h) end
                end
            end
        end)
        task.wait(0.5)
    end
end

local function killGrab()
    while true do
        pcall(function()
            local c = workspace:FindFirstChild("GrabParts")
            if c and c:FindFirstChild("GrabPart") then
                local w = c.GrabPart:FindFirstChild("WeldConstraint")
                if w and w.Part1 and w.Part1.Parent then
                    local h = w.Part1.Parent:FindFirstChild("Humanoid")
                    if h then h.Health = 0 end
                end
            end
        end)
        task.wait()
    end
end

local function noclipGrab()
    while true do
        pcall(function()
            local c = workspace:FindFirstChild("GrabParts")
            if c and c:FindFirstChild("GrabPart") then
                local w = c.GrabPart:FindFirstChild("WeldConstraint")
                if w and w.Part1 and w.Part1.Parent then
                    while workspace:FindFirstChild("GrabParts") do
                        for _,p in pairs(w.Part1.Parent:GetChildren()) do if p:IsA("BasePart") then p.CanCollide=false end end
                        task.wait()
                    end
                end
            end
        end)
        task.wait()
    end
end

local function heavenGrab()
    while true do
        pcall(function()
            local c = workspace:FindFirstChild("GrabParts")
            if c and c:FindFirstChild("GrabPart") then
                local w = c.GrabPart:FindFirstChild("WeldConstraint")
                if w and w.Part1 and w.Part1.Parent then
                    local t = w.Part1.Parent:FindFirstChild("Torso")
                    if t then
                        local v = t:FindFirstChild("heavenG") or Instance.new("BodyVelocity", t)
                        v.Name="heavenG"; v.Velocity=Vector3.new(0,9999999,0); v.MaxForce=Vector3.new(math.huge,math.huge,math.huge); Debris:AddItem(v, 100)
                    end
                end
            end
        end)
        task.wait()
    end
end

local TPgrabOption = "TP to spawn"
local function crazyGrab()
    while true do
        pcall(function()
            local c = workspace:FindFirstChild("GrabParts")
            if c and c:FindFirstChild("GrabPart") then
                local w = c.GrabPart:FindFirstChild("WeldConstraint")
                if w and w.Part1 and w.Part1.Parent then
                    local hrp = w.Part1.Parent:FindFirstChild("HumanoidRootPart")
                    if hrp then
                        if TPgrabOption == "TP to spawn" then hrp.CFrame=CFrame.new(-1,-7,-9); task.wait()
                        elseif TPgrabOption == "Crazy teleport" then
                            hrp.CFrame=CFrame.new(-17,421,50); task.wait(0.1); hrp.CFrame=CFrame.new(145,397,-126); task.wait(0.1); hrp.CFrame=CFrame.new(157,254,89); task.wait(0.1)
                        end
                    end
                end
            end
        end)
        task.wait()
    end
end

local antiExplosionConnection
local characterAddedConn
local function setupAntiExplosion(character)
    task.wait(0.5)
    local h = character:FindFirstChild("Humanoid")
    if not h then return end
    local r = h:FindFirstChild("Ragdolled")
    if r then
        if antiExplosionConnection then antiExplosionConnection:Disconnect() end
        antiExplosionConnection = r:GetPropertyChangedSignal("Value"):Connect(function()
            pcall(function()
                if r.Value then
                    for _,p in ipairs(character:GetChildren()) do if p:IsA("BasePart") then p.Anchored=true end end
                    task.wait(0.5)
                    for _,p in ipairs(character:GetChildren()) do if p:IsA("BasePart") then p.Anchored=false end end
                end
            end)
        end)
    end
end

local function kill(p)
    pcall(function()
        local pl = Players:FindFirstChild(p)
        if not pl or not pl.Character then return end
        local phrp = pl.Character:FindFirstChild("HumanoidRootPart")
        local mhrp = LocalCharacter and LocalCharacter:FindFirstChild("HumanoidRootPart")
        if phrp and mhrp then
            local old = mhrp.CFrame
            while pl.Character.Humanoid.Health ~= 0 do
                mhrp.CFrame = phrp.CFrame - Vector3.new(0,10,0)
                SetNetworkOwner:FireServer(phrp, CFrame.new(phrp.Position))
                for _, pt in pairs(PoisonHurtParts) do pt.Size=Vector3.new(1.5,1.5,1.5); pt.Transparency=1; pt.Position=pl.Character.Head.Position end
                task.wait(); for _, pt in pairs(PoisonHurtParts) do pt.Position=Vector3.new(0,-200,0) end
            end
            mhrp.CFrame = old
        end
    end)
end

local function TargetPlayersDropdown()
    local t = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then table.insert(t, p.Name) end
    end
    return t
end

local function bringLeft(k)
    if not k then return end
    local p = Players:FindFirstChild(k)
    if not p or not p.Character then return end
    for _, v in pairs(workspace:GetDescendants()) do
        if v.Name == "CreatureBlobman" then
            pcall(function() v.BlobmanSeatAndOwnerScript.CreatureGrab:FireServer(v.LeftDetector, p.Character.HumanoidRootPart, v.LeftDetector.LeftWeld) end)
        end
    end
end

local function bringRight(k)
    if not k then return end
    local p = Players:FindFirstChild(k)
    if not p or not p.Character then return end
    for _, v in pairs(workspace:GetDescendants()) do
        if v.Name == "CreatureBlobman" then
            pcall(function() v.BlobmanSeatAndOwnerScript.CreatureGrab:FireServer(v.RightDetector, p.Character.HumanoidRootPart, v.RightDetector.RightWeld) end)
        end
    end
end

-- ================= Rayfield Window Creation =================
local Window = Rayfield:CreateWindow({
    Name = "FTAP v10.0 Rayfield Edition (Nexus Patched)",
    LoadingTitle = "FTAP by Nexus",
    LoadingSubtitle = "Loading...",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "FTAPRayfield",
        FileName = "Config"
    },
    Discord = {
        Enabled = false,
        Invite = "",
        RememberJoins = true 
    },
    KeySystem = false,
})

-- ================= Attack Tab =================
local AttackTab = Window:CreateTab("⚔️ 攻撃", 4483345998)

AttackTab:CreateSection("ターゲット攻撃")

local TargetDropdown = AttackTab:CreateDropdown({
    Name = "ターゲット選択",
    Options = TargetPlayersDropdown(),
    CurrentOption = "",
    Flag = "TargetSelect",
    Callback = function(Option)
        TargetSelected = Option[1]
        selectedTarget = Players:FindFirstChild(TargetSelected)
    end,
})

AttackTab:CreateToggle({
    Name = "ループキル",
    CurrentValue = false,
    Flag = "LoopKill",
    Callback = function(Value)
        coroutineFlags.LoopKill = Value
        if Value then
            task.spawn(function()
                while coroutineFlags.LoopKill and selectedTarget do
                    pcall(function()
                        if not isPlayerWhitelisted(selectedTarget) and selectedTarget.Character then
                            local h = selectedTarget.Character:FindFirstChild("Head")
                            if h then
                                for _, p in pairs(PoisonHurtParts) do p.Size=Vector3.new(2,2,2); p.Transparency=1; p.Position=h.Position end
                                task.wait(0.1)
                                for _, p in pairs(PoisonHurtParts) do p.Position=Vector3.new(0,-200,0) end
                            end
                        end
                    end)
                    task.wait(0.3)
                end
            end)
        end
    end,
})

AttackTab:CreateButton({
    Name = "ターゲットを即キル",
    Callback = function()
        if TargetSelected then kill(TargetSelected) end
    end,
})

AttackTab:CreateButton({
    Name = "ターゲットにテレポート",
    Callback = function()
        if selectedTarget and selectedTarget.Character and LocalCharacter then
            LocalCharacter.HumanoidRootPart.CFrame = selectedTarget.Character.HumanoidRootPart.CFrame * CFrame.new(0,0,3)
        end
    end,
})

AttackTab:CreateToggle({
    Name = "ターゲット周回",
    CurrentValue = false,
    Flag = "OrbitTarget",
    Callback = function(Value)
        coroutineFlags.OrbitPlayer = Value
        if Value and selectedTarget then
            task.spawn(function()
                local angle = 0
                while coroutineFlags.OrbitPlayer and selectedTarget do
                    pcall(function()
                        if selectedTarget.Character and LocalCharacter then
                            angle = angle + 0.05
                            local offset = Vector3.new(math.cos(angle)*10, 2, math.sin(angle)*10)
                            LocalCharacter.HumanoidRootPart.CFrame = CFrame.new(selectedTarget.Character.HumanoidRootPart.Position + offset, selectedTarget.Character.HumanoidRootPart.Position)
                        end
                    end)
                    task.wait(0.03)
                end
            end)
        end
    end,
})

AttackTab:CreateSection("範囲攻撃")

AttackTab:CreateSlider({
    Name = "グラブ強度",
    Range = {100, 10000},
    Increment = 50,
    Suffix = "Force",
    CurrentValue = 450,
    Flag = "GrabStrength",
    Callback = function(Value)
        strength = Value
    end,
})

AttackTab:CreateToggle({
    Name = "強度グラブ",
    CurrentValue = false,
    Flag = "StrengthGrab",
    Callback = function(Value)
        if Value then
            connections.Strength = workspace.ChildAdded:Connect(function(m)
                if m.Name == "GrabParts" then
                    pcall(function()
                        local w = m:WaitForChild("GrabPart",1):WaitForChild("WeldConstraint",1)
                        if w and w.Part1 then
                            local bv = Instance.new("BodyVelocity", w.Part1); bv.MaxForce=Vector3.new(0,0,0)
                            m:GetPropertyChangedSignal("Parent"):Connect(function()
                                if not m.Parent then
                                    if isRightClickOrLongPress then
                                        bv.MaxForce=Vector3.new(math.huge,math.huge,math.huge); bv.Velocity=workspace.CurrentCamera.CFrame.LookVector*strength; Debris:AddItem(bv,1)
                                    else bv:Destroy() end
                                    isRightClickOrLongPress = false
                                end
                            end)
                        end
                    end)
                end
            end)
        elseif connections.Strength then
            connections.Strength:Disconnect(); connections.Strength = nil
        end
    end,
})

AttackTab:CreateToggle({
    Name = "全員をフリング (最適化済)",
    CurrentValue = false,
    Flag = "FlingAll",
    Callback = function(Value)
        coroutineFlags.FlingAll = Value
        if Value then
            task.spawn(function()
                while coroutineFlags.FlingAll do
                    local list = Players:GetPlayers()
                    for i = 1, #list, 3 do
                        if not coroutineFlags.FlingAll then break end
                        for j = i, math.min(i+2, #list) do
                            local p = list[j]
                            if p ~= LocalPlayer and not isPlayerWhitelisted(p) and p.Character then
                                local hrp = p.Character:FindFirstChild("HumanoidRootPart")
                                if hrp then
                                    sno(hrp, hrp.CFrame)
                                    local bv = Instance.new("BodyVelocity", hrp); bv.MaxForce=Vector3.new(math.huge,math.huge,math.huge); bv.Velocity=Vector3.new(math.random(-2000,2000),math.random(1000,2000),math.random(-2000,2000))
                                    Debris:AddItem(bv, 0.1)
                                    task.delay(0.1, function() ungrab(hrp) end)
                                end
                            end
                        end
                        task.wait(0.05)
                    end
                    task.wait(0.1)
                end
            end)
        end
    end,
})

AttackTab:CreateToggle({
    Name = "全員を自分に引き寄せ",
    CurrentValue = false,
    Flag = "BringAll",
    Callback = function(Value)
        coroutineFlags.BringAll = Value
        if Value then
            task.spawn(function()
                while coroutineFlags.BringAll do
                    pcall(function()
                        if LocalCharacter then
                            local pos = LocalCharacter.HumanoidRootPart.Position
                            for _, p in pairs(Players:GetPlayers()) do
                                if p ~= LocalPlayer and not isPlayerWhitelisted(p) and p.Character then
                                    local h = p.Character:FindFirstChild("HumanoidRootPart")
                                    if h then h.CFrame = CFrame.new(pos + Vector3.new(math.random(-5,5),0,math.random(-5,5))) end
                                end
                            end
                        end
                    end)
                    task.wait(0.5)
                end
            end)
        end
    end,
})

-- ================= Grab Tab =================
local GrabTab = Window:CreateTab("🎯 グラブ", 4483345998)

GrabTab:CreateSection("ダメージグラブ")

GrabTab:CreateToggle({Name = "毒グラブ", CurrentValue = false, Flag = "PoisonGrab", Callback = function(v) coroutineFlags.PoisonGrab=v; if v then task.spawn(function() grabHandler("poison") end) end end})
GrabTab:CreateToggle({Name = "放射能グラブ", CurrentValue = false, Flag = "RadGrab", Callback = function(v) coroutineFlags.RadiactiveGrab=v; if v then task.spawn(function() grabHandler("radioctive") end) end end})
GrabTab:CreateToggle({Name = "火グラブ", CurrentValue = false, Flag = "BurnGrab", Callback = function(v) coroutineFlags.BurnGrab=v; if v then task.spawn(burnGrab) end end})
GrabTab:CreateToggle({Name = "キルグラブ", CurrentValue = false, Flag = "KillGrab", Callback = function(v) coroutineFlags.KillGrab=v; if v then task.spawn(killGrab) end end})
GrabTab:CreateToggle({Name = "天国グラブ", CurrentValue = false, Flag = "HeavenGrab", Callback = function(v) coroutineFlags.HeavenGrab=v; if v then task.spawn(heavenGrab) end end})

GrabTab:CreateSection("新グラブエフェクト")

GrabTab:CreateToggle({Name = "キックグラブ ⚽", CurrentValue = false, Flag = "KickGrab", Callback = function(v) coroutineFlags.KickGrab=v; if v then task.spawn(kickGrab) end end})
GrabTab:CreateSlider({Name = "キック力", Range = {50, 500}, Increment = 10, CurrentValue = 150, Flag = "KickForce", Callback = function(v) _G.kickForce=v end})
GrabTab:CreateToggle({Name = "UFOグラブ 🛸", CurrentValue = false, Flag = "UfoGrab", Callback = function(v) coroutineFlags.UfoGrab=v; if v then task.spawn(ufoGrab) end end})
GrabTab:CreateSlider({Name = "UFO高さ", Range = {5, 30}, Increment = 1, CurrentValue = 10, Flag = "UfoHeight", Callback = function(v) _G.ufoHeight=v end})
GrabTab:CreateSlider({Name = "UFO回転速度", Range = {1, 20}, Increment = 1, CurrentValue = 5, Flag = "UfoRot", Callback = function(v) _G.ufoRotationSpeed=v end})

GrabTab:CreateSection("エフェクトグラブ")
GrabTab:CreateToggle({Name = "ノークリップグラブ", CurrentValue = false, Flag = "NoclipGrab", Callback = function(v) coroutineFlags.NoclipGrab=v; if v then task.spawn(noclipGrab) end end})
GrabTab:CreateToggle({Name = "テレポートグラブ", CurrentValue = false, Flag = "TpGrab", Callback = function(v) coroutineFlags.CrazyGrab=v; if v then task.spawn(crazyGrab) end end})

-- ================= Aura Tab =================
local AuraTab = Window:CreateTab("🔥 オーラ", 4483345998)
AuraTab:CreateSlider({Name = "オーラ範囲", Range = {5, 100}, Increment = 1, CurrentValue = 20, Flag = "AuraRadius", Callback = function(v) auraRadius=v end})

AuraTab:CreateToggle({
    Name = "グラブオーラ", CurrentValue = false, Flag = "GrabAura",
    Callback = function(v)
        coroutineFlags.GrabAura = v
        if v then task.spawn(function()
            while coroutineFlags.GrabAura do
                pcall(function()
                    if LocalCharacter then
                        for _, p in pairs(Players:GetPlayers()) do
                            if p ~= LocalPlayer and p.Character then
                                local h = p.Character:FindFirstChild("HumanoidRootPart")
                                if h and (LocalCharacter.HumanoidRootPart.Position - h.Position).Magnitude <= auraRadius and not isPlayerWhitelisted(p) then
                                    sno(h, h.CFrame)
                                end
                            end
                        end
                    end
                end); task.wait(0.02)
            end
        end) end
})

AuraTab:CreateToggle({
    Name = "毒オーラ", CurrentValue = false, Flag = "PoisonAura",
    Callback = function(v)
        coroutineFlags.PoisonAura = v
        if v then task.spawn(function()
            while coroutineFlags.PoisonAura do
                pcall(function()
                    if LocalCharacter then
                        for _, p in pairs(Players:GetPlayers()) do
                            if p ~= LocalPlayer and p.Character then
                                local h = p.Character:FindFirstChild("Head")
                                if h and (LocalCharacter.HumanoidRootPart.Position - p.Character.HumanoidRootPart.Position).Magnitude <= auraRadius and not isPlayerWhitelisted(p) then
                                    for _, pt in pairs(PoisonHurtParts) do pt.Size=Vector3.new(2,2,2); pt.Transparency=1; pt.Position=h.Position end
                                    task.wait(); for _, pt in pairs(PoisonHurtParts) do pt.Position=Vector3.new(0,-200,0) end
                                end
                            end
                        end
                    end
                end); task.wait(0.1)
            end
        end) end
})

AuraTab:CreateToggle({
    Name = "火オーラ", CurrentValue = false, Flag = "FireAura",
    Callback = function(v)
        coroutineFlags.FireAura = v
        if v then task.spawn(function()
            while coroutineFlags.FireAura do
                pcall(function()
                    if LocalCharacter then
                        for _, p in pairs(Players:GetPlayers()) do
                            if p ~= LocalPlayer and p.Character then
                                local h = p.Character:FindFirstChild("Head")
                                if h and (LocalCharacter.HumanoidRootPart.Position - p.Character.HumanoidRootPart.Position).Magnitude <= auraRadius and not isPlayerWhitelisted(p) then
                                    burn(h)
                                end
                            end
                        end
                    end
                end); task.wait(0.5)
            end
        end) end
})

AuraTab:CreateToggle({
    Name = "削除オーラ (天国)", CurrentValue = false, Flag = "DeleteAura",
    Callback = function(v)
        coroutineFlags.DeleteAura = v
        if v then task.spawn(function()
            while coroutineFlags.DeleteAura do
                pcall(function()
                    if LocalCharacter then
                        for _, p in pairs(Players:GetPlayers()) do
                            if p ~= LocalPlayer and p.Character then
                                local t = p.Character:FindFirstChild("Torso")
                                local h = p.Character:FindFirstChild("HumanoidRootPart")
                                if t and h and (h.Position - LocalCharacter.HumanoidRootPart.Position).Magnitude <= auraRadius and not isPlayerWhitelisted(p) then
                                    SetNetworkOwner:FireServer(t, h.CFrame)
                                    local vel = Instance.new("BodyVelocity", t); vel.Velocity=Vector3.new(0,9999999,0); vel.MaxForce=Vector3.new(math.huge,math.huge,math.huge); Debris:AddItem(vel,100)
                                end
                            end
                        end
                    end
                end); task.wait(0.5)
            end
        end) end
})

AuraTab:CreateSection("全員攻撃")
AuraTab:CreateToggle({
    Name = "Fire All (全員燃やす)", CurrentValue = false, Flag = "FireAll",
    Callback = function(v)
        coroutineFlags.FireAll = v
        if v then task.spawn(function()
            while coroutineFlags.FireAll do
                pcall(function()
                    if toysFolder and toysFolder:FindFirstChild("Campfire") then DestroyToy:FireServer(toysFolder.Campfire); task.wait(0.5) end
                    spawnItemCf("Campfire", LocalCharacter.Head.CFrame); task.wait(0.5)
                    local cf = toysFolder and toysFolder:WaitForChild("Campfire", 2)
                    if cf then
                        local fpp = cf:FindFirstChild("FirePlayerPart")
                        if fpp then
                            fpp.Size=Vector3.new(10,10,10); SetNetworkOwner:FireServer(fpp, fpp.CFrame)
                            local bp = Instance.new("BodyPosition", cf.Main); bp.P=20000; bp.Position=LocalCharacter.Head.Position+Vector3.new(0,600,0)
                            while coroutineFlags.FireAll do
                                for _,p in pairs(Players:GetPlayers()) do
                                    if p~=LocalPlayer and not isPlayerWhitelisted(p) and p.Character then fpp.Position=p.Character.HumanoidRootPart.Position; task.wait() end
                                end
                                task.wait()
                            end
                        end
                    end
                end); task.wait()
            end
        end) end
})

-- ================= Auto Tab =================
local AutoTab = Window:CreateTab("🤖 オート", 4483345998)
AutoTab:CreateButton({Name = "🆕 バリア破壊を実行", Callback = executeBarrierBreak})

-- ================= Blobman Tab =================
local BlobTab = Window:CreateTab("👾 Blobman", 4483345998)
BlobTab:CreateSection("Left Bring")
local LeftDrop = BlobTab:CreateDropdown({Name = "Left Player", Options = TargetPlayersDropdown(), CurrentOption = "", Flag = "LeftBlob", Callback = function(o) LeftBlobSelected = o[1] end})
BlobTab:CreateButton({Name = "Left Bring", Callback = function() if LeftBlobSelected then bringLeft(LeftBlobSelected) end end})
BlobTab:CreateToggle({Name = "Loop Left", CurrentValue = false, Flag = "LoopLeft", Callback = function(v) coroutineFlags.LoopLeftBlob=v; while coroutineFlags.LoopLeftBlob do bringLeft(LeftBlobSelected); task.wait(blobDelay) end end})

BlobTab:CreateSection("Right Bring")
local RightDrop = BlobTab:CreateDropdown({Name = "Right Player", Options = TargetPlayersDropdown(), CurrentOption = "", Flag = "RightBlob", Callback = function(o) RightBlobSelected = o[1] end})
BlobTab:CreateButton({Name = "Right Bring", Callback = function() if RightBlobSelected then bringRight(RightBlobSelected) end end})
BlobTab:CreateToggle({Name = "Loop Right", CurrentValue = false, Flag = "LoopRight", Callback = function(v) coroutineFlags.LoopRightBlob=v; while coroutineFlags.LoopRightBlob do bringRight(RightBlobSelected); task.wait(blobDelay) end end})

BlobTab:CreateSection("Duo Bring")
local DuoDrop = BlobTab:CreateDropdown({Name = "Two Hands Player", Options = TargetPlayersDropdown(), CurrentOption = "", Flag = "DuoBlob", Callback = function(o) DuoBlobSelected = o[1] end})
BlobTab:CreateButton({Name = "Two Hands Bring", Callback = function() if DuoBlobSelected then bringRight(DuoBlobSelected); bringLeft(DuoBlobSelected) end end})
BlobTab:CreateToggle({Name = "Loop Two Hands", CurrentValue = false, Flag = "LoopDuo", Callback = function(v) coroutineFlags.LoopDuoBlob=v; while coroutineFlags.LoopDuoBlob do bringLeft(DuoBlobSelected); bringRight(DuoBlobSelected); task.wait(blobDelay) end end})

BlobTab:CreateSection("Server")
BlobTab:CreateButton({Name = "Bring All", Callback = function() for _,p in pairs(Players:GetPlayers()) do if p~=LocalPlayer and not isPlayerWhitelisted(p) then bringLeft(p.Name); bringRight(p.Name) end end end})
BlobTab:CreateToggle({Name = "Destroy Server", CurrentValue = false, Flag = "DesServ", Callback = function(v) coroutineFlags.ServerBreak=v; while coroutineFlags.ServerBreak do for _,p in pairs(Players:GetPlayers()) do if p~=LocalPlayer and not isPlayerWhitelisted(p) then bringLeft(p.Name); bringRight(p.Name) end end; task.wait(blobDelay) end end})
BlobTab:CreateSlider({Name = "Blob Delay", Range = {0.001, 1}, Increment = 0.001, CurrentValue = 0.001, Flag = "BlobDelay", Callback = function(v) blobDelay=v; _G.BlobmanDelay=v end})

-- ================= Character Tab =================
local CharTab = Window:CreateTab("🏃 キャラ", 4483345998)
CharTab:CreateSlider({Name = "WalkSpeed", Range = {16, 500}, Increment = 1, CurrentValue = 16, Flag = "WS", Callback = function(v) if LocalCharacter then LocalCharacter.Humanoid.WalkSpeed=v end end})
CharTab:CreateSlider({Name = "JumpPower", Range = {50, 500}, Increment = 1, CurrentValue = 50, Flag = "JP", Callback = function(v) if LocalCharacter then LocalCharacter.Humanoid.JumpPower=v end end})
CharTab:CreateToggle({Name = "無限ジャンプ", CurrentValue = false, Flag = "InfJump", Callback = function(v) infJump=v; if v then UserInputService.JumpRequest:Connect(function() if infJump and LocalCharacter then LocalCharacter.Humanoid:ChangeState("Jumping") end end) end end})
CharTab:CreateButton({Name = "Sit", Callback = function() if LocalCharacter then LocalCharacter.Humanoid.Sit=true end end})

-- ================= Defense Tab =================
local DefTab = Window:CreateTab("🛡️ 防御", 4483345998)
DefTab:CreateSection("新アンチグラブ")
DefTab:CreateToggle({Name = "🆕 アンチグラブ (Creature)", CurrentValue = false, Flag = "AntiCreature", Callback = function(v) coroutineFlags.AntiGrabCreature=v; if v then executeCreatureAntiGrab(LocalCharacter) end end})
DefTab:CreateToggle({Name = "🆕 透明アンチグラブ (Test)", CurrentValue = false, Flag = "AntiInvis", Callback = function(v) coroutineFlags.AntiGrabTestInvisible=v; if v then executeTestInvisibleAntiGrab(LocalCharacter) end end})

DefTab:CreateSection("基本防御")
DefTab:CreateToggle({Name = "Anti Grab", CurrentValue = false, Flag = "AntiGrab", Callback = function(v) if v then connections.AntiGrab=RunService.Heartbeat:Connect(function() pcall(function() if LocalCharacter and LocalCharacter.Head:FindFirstChild("PartOwner") and LocalCharacter.Head.PartOwner.Value~=LocalPlayer.Name then Struggle:FireServer(); RagdollRemote:FireServer(LocalCharacter.HumanoidRootPart, 0) end end) end) else if connections.AntiGrab then connections.AntiGrab:Disconnect() end end end})
DefTab:CreateToggle({Name = "Anti Fling", CurrentValue = false, Flag = "AntiFling", Callback = function(v) if v then connections.AntiFling=RunService.Heartbeat:Connect(function() pcall(function() Struggle:FireServer(); RagdollRemote:FireServer(LocalCharacter.HumanoidRootPart, 0); if ReplicatedStorage:FindFirstChild("GameCorrectionEvents") then ReplicatedStorage.GameCorrectionEvents.StopAllVelocity:FireServer() end end) end) else if connections.AntiFling then connections.AntiFling:Disconnect() end end end})
DefTab:CreateToggle({Name = "Anti Explosion", CurrentValue = false, Flag = "AntiExp", Callback = function(v) if v then setupAntiExplosion(LocalCharacter); characterAddedConn=LocalPlayer.CharacterAdded:Connect(setupAntiExplosion) else if characterAddedConn then characterAddedConn:Disconnect() end end end})
DefTab:CreateToggle({Name = "Anti Void", CurrentValue = false, Flag = "AntiVoid", Callback = function(v) antiVoidEnabled=v; if v then workspace.FallenPartsDestroyHeight=0/0; connections.AntiVoid=RunService.Heartbeat:Connect(function() if LocalCharacter and LocalCharacter.HumanoidRootPart.Position.Y<-500 then LocalCharacter.HumanoidRootPart.CFrame=CFrame.new(2,10,-4) end end) else workspace.FallenPartsDestroyHeight=-500; if connections.AntiVoid then connections.AntiVoid:Disconnect() end end end})
DefTab:CreateToggle({Name = "Anti Lag (Block Look)", CurrentValue = false, Flag = "AntiLag", Callback = function(v) antiLagLookEnabled=v end})

-- ================= Line Tab =================
local LineTab = Window:CreateTab("📏 Line", 4483345998)
LineTab:CreateButton({Name = "🌈 Rainbow", Callback = function() UpdateLineColors(CreateRainbowSequence()) end})
LineTab:CreateToggle({Name = "Random Line (Loop)", CurrentValue = false, Flag = "RandLine", Callback = function(v) randomLineEnabled=v; if v then spawn(function() while randomLineEnabled do UpdateLineColors(CreateSolidSequence(Color3.fromHSV(math.random(),1,1))); wait(0.05) end end) end end})
LineTab:CreateToggle({Name = "Gradient Random (Loop)", CurrentValue = false, Flag = "GradLine", Callback = function(v) gradientRandomEnabled=v; if v then spawn(function() while gradientRandomEnabled do UpdateLineColors(CreateBrightRandomGradient(math.random(3,10))); wait(0.5) end end) end end})

for k, c in pairs(presets) do LineTab:CreateButton({Name = k, Callback = function() UpdateLineColors(CreateSolidSequence(c[1])) end}) end

LineTab:CreateSection("Line Lag")
LineTab:CreateSlider({Name = "Lag Speed", Range = {0.01, 0.5}, Increment = 0.01, CurrentValue = 0.05, Flag = "LagSpd", Callback = function(v) lineLagSpeed=v end})
LineTab:CreateToggle({Name = "Line Lag All", CurrentValue = false, Flag = "LineLagAll", Callback = function(v) lineLagEnabled=v; lineLagAllEnabled=v; if v then spawn(function() while lineLagEnabled and lineLagAllEnabled do for _,p in pairs(Players:GetPlayers()) do if p~=LocalPlayer then CreateLineLag(p); wait(lineLagSpeed) end end; wait(0.01) end end) end end})

-- ================= TP Tab =================
local TPTab = Window:CreateTab("🌐 TP", 4483345998)
local teleportLocations = {
    ["スポーン"] = Vector3.new(2, -7, -4), ["黄色い家"] = Vector3.new(-492, -7, -164),
    ["緑の家"] = Vector3.new(-532, -7, 95), ["紫の家"] = Vector3.new(255, -7, 465),
    ["中華風の家"] = Vector3.new(558, 123, -76), ["青い家"] = Vector3.new(511, 83, -344),
    ["大きな家"] = Vector3.new(-244, 80, 293), ["農場"] = Vector3.new(-197, 59, -285),
    ["雪山"] = Vector3.new(-433, 230, 516), ["山"] = Vector3.new(394, 163, 278), ["浮島"] = Vector3.new(71, 346, 330)
}
for n, p in pairs(teleportLocations) do TPTab:CreateButton({Name = n, Callback = function() if LocalCharacter then LocalCharacter.HumanoidRootPart.CFrame=CFrame.new(p) end end}) end

-- ================= Visual Tab =================
local VisTab = Window:CreateTab("👁️ ビジュアル", 4483345998)
VisTab:CreateToggle({Name = "フルブライト", CurrentValue = false, Flag = "FB", Callback = function(v) if v then Lighting.Brightness=2; Lighting.ClockTime=14; Lighting.GlobalShadows=false else Lighting.Brightness=1; Lighting.ClockTime=12; Lighting.GlobalShadows=true end end})
VisTab:CreateSlider({Name = "FOV", Range = {70, 120}, Increment = 1, CurrentValue = 70, Flag = "FOV", Callback = function(v) workspace.CurrentCamera.FieldOfView=v end})
VisTab:CreateToggle({Name = "Unblur", CurrentValue = false, Flag = "Unblur", Callback = function(v) workspace.CurrentCamera.Blur.Enabled = not v end})
VisTab:CreateButton({Name = "雲を削除", Callback = function() if workspace.Terrain:FindFirstChild("Clouds") then workspace.Terrain.Clouds:Destroy() end end})
VisTab:CreateSection("時間")
VisTab:CreateButton({Name = "昼", Callback = function() Lighting.ClockTime = 10 end})
VisTab:CreateButton({Name = "夜", Callback = function() Lighting.ClockTime = 0 end})

-- ================= Fun Tab =================
local FunTab = Window:CreateTab("🎮 Fun", 4483345998)
FunTab:CreateToggle({Name = "Ragdoll (Loop)", CurrentValue = false, Flag = "Ragdoll", Callback = function(v) if v then connections.Ragdoll=RunService.Heartbeat:Connect(function() if LocalCharacter then RagdollRemote:FireServer(LocalCharacter.HumanoidRootPart,0) end end) else if connections.Ragdoll then connections.Ragdoll:Disconnect() end end end})

-- ================= Bind Tab =================
local BindTab = Window:CreateTab("⌨️ バインド", 4483345998)
local clickBurn, clickKill = false, false
BindTab:CreateToggle({Name = "Burn (有効化)", CurrentValue = false, Flag = "ClickBurn", Callback = function(v) clickBurn=v; if v then spawnItem("Campfire", Vector3.new(-72.9, -5.9, -265.5)) end end})
BindTab:CreateKeybind({
    Name = "Bind Burn (V)",
    CurrentKeybind = "V",
    HoldToInteract = false,
    Flag = "BindBurnKey",
    Callback = function()
        if clickBurn then
            local t = LocalPlayer:GetMouse().Target
            if t and t.Parent and t.Parent:FindFirstChild("Head") then burn(t.Parent.Head) end
        end
    end,
})
BindTab:CreateToggle({Name = "Kill (有効化)", CurrentValue = false, Flag = "ClickKill", Callback = function(v) clickKill=v end})
BindTab:CreateKeybind({
    Name = "Bind Kill (X)",
    CurrentKeybind = "X",
    HoldToInteract = false,
    Flag = "BindKillKey",
    Callback = function()
        if clickKill then
            local t = LocalPlayer:GetMouse().Target
            if t and t.Parent and t.Parent:FindFirstChild("Humanoid") then kill(Players:GetPlayerFromCharacter(t.Parent).Name) end
        end
    end,
})
BindTab:CreateKeybind({
    Name = "地獄送り (Z)",
    CurrentKeybind = "Z",
    HoldToInteract = false,
    Flag = "HellBind",
    Callback = function()
        local t = LocalPlayer:GetMouse().Target
        if t and t:IsA("BasePart") then
            local c = t.Parent
            if t.Name == "FirePlayerPart" then c = t.Parent.Parent end
            if c:IsA("Model") and c:FindFirstChildOfClass("Humanoid") then
                SetNetworkOwner:FireServer(c.HumanoidRootPart, c.HumanoidRootPart.CFrame)
                local bv = Instance.new("BodyVelocity", c.Torso); bv.Velocity=Vector3.new(0,-4,0); bv.MaxForce=Vector3.new(math.huge,math.huge,math.huge)
                for _,p in ipairs(c:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide=false end end
            end
        end
    end,
})

-- ================= Script Tab =================
local ScriptTab = Window:CreateTab("📜 スクリプト", 4483345998)
ScriptTab:CreateButton({Name = "Infinite Yield", Callback = function() loadstring(game:HttpGet("https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source"))() end})
ScriptTab:CreateButton({Name = "Dex Explorer v2", Callback = function() loadstring(game:HttpGet("https://raw.githubusercontent.com/MariyaFurmanova/Library/main/dex2.0", true))() end})

-- ================= Settings Tab =================
local SettingsTab = Window:CreateTab("⚙️ 設定", 4483345998)
SettingsTab:CreateToggle({Name = "フレンド保護", CurrentValue = false, Flag = "Whitelist", Callback = function(v) whiteListEnabled=v; if v then Rayfield:Notify({Title="Protected", Content="Friends are now safe.", Duration=3}) end end})
SettingsTab:CreateButton({Name = "UI破棄 & クリーンアップ", Callback = function() cleanupESP(); for _, c in pairs(connections) do if c then c:Disconnect() end end; Rayfield:Destroy() end})

-- プレイヤー更新
Players.PlayerAdded:Connect(function() 
    if TargetDropdown then TargetDropdown:Refresh(TargetPlayersDropdown(), true) end 
    if LeftDrop then LeftDrop:Refresh(TargetPlayersDropdown(), true) end
    if RightDrop then RightDrop:Refresh(TargetPlayersDropdown(), true) end
    if DuoDrop then DuoDrop:Refresh(TargetPlayersDropdown(), true) end
end)
Players.PlayerRemoving:Connect(function() 
    if TargetDropdown then TargetDropdown:Refresh(TargetPlayersDropdown(), true) end
    if LeftDrop then LeftDrop:Refresh(TargetPlayersDropdown(), true) end
    if RightDrop then RightDrop:Refresh(TargetPlayersDropdown(), true) end
    if DuoDrop then DuoDrop:Refresh(TargetPlayersDropdown(), true) end
end)

Rayfield:Notify({
    Title = "FTAP Rayfield Edition",
    Content = "v10.0 (Nexus Patched) Loaded Successfully!",
    Duration = 5,
    Image = 4483345998,
})
