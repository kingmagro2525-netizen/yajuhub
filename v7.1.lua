-- FTAP完全統合版 v10.1 Rayfield Edition (Delta-Time Fixed)
-- Converted to Delta-Time independent execution by Nexus
-- Frame-rate independent animation and timing

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

-- Delta Time用グローバルタイマー
local lastFrameTime = tick()
local deltaTime = 0

-- Delta Time更新ループ
RunService.Heartbeat:Connect(function()
    local currentTime = tick()
    deltaTime = currentTime - lastFrameTime
    lastFrameTime = currentTime
end)

-- キャラクター取得（Race Condition回避）
local LocalCharacter = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
LocalPlayer.CharacterAdded:Connect(function(character)
    LocalCharacter = character
    lastFrameTime = tick() -- リスポーン時にタイマーリセット
end)

-- 安全なWaitForChild
local function safeWaitForChild(parent, name, timeout)
    local child = parent:WaitForChild(name, timeout)
    if not child then
        warn("FTAP Error: Critical remote '" .. name .. "' could not be found in " .. parent.Name)
    end
    return child
end

-- リモート取得
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
    return
end

local SetNetworkOwner = GrabEvents:WaitForChild("SetNetworkOwner", 10)
local Struggle = CharacterEvents:WaitForChild("Struggle", 10)
local CreateGrabLine = GrabEvents:WaitForChild("CreateGrabLine", 10)
local DestroyGrabLine = GrabEvents:WaitForChild("DestroyGrabLine", 10)
local DestroyToy = MenuToys:WaitForChild("DestroyToy", 10)
local RagdollRemote = CharacterEvents:WaitForChild("RagdollRemote", 10)
local BombEvents = ReplicatedStorage:FindFirstChild("BombEvents")
local toysFolder = workspace:FindFirstChild(LocalPlayer.Name.."SpawnedInToys")

-- グローバル変数
_G.BlobmanDelay = 0.001
_G.ToyToLoad = "BombMissile"
_G.MaxMissiles = 9
_G.flySpeed = 100
_G.kickForce = 150
_G.ufoRotationSpeed = 5
_G.ufoHeight = 10

-- 共通変数
local strength = 450
local auraRadius = 20
local whiteListEnabled = false
local espObjects = {}
local connections = {}
local anchoredParts = {}
local compiledGroups = {}
local bombList = {}
local ownedToys = {}
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

-- ターゲット選択
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

-- メモリリーク対策
local function cleanupESP()
    for _, obj in pairs(espObjects) do
        if obj and obj.Parent then obj:Destroy() end
    end
    table.clear(espObjects)
end

-- 入力監視（変更なし）
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
        if tick() - touchStartTime >= 0.3 then 
            isRightClickOrLongPress = true 
        else 
            isRightClickOrLongPress = false 
        end
        isTouchHolding = false
    elseif input.UserInputType == Enum.UserInputType.MouseButton2 then
        isRightClickOrLongPress = false
    end
end)

-- Owned Toys確認
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
    pcall(function() 
        if DestroyGrabLine then 
            DestroyGrabLine:FireServer(player) 
        end 
    end)
end

local function isPlayerWhitelisted(player)
    if not whiteListEnabled then return false end
    if not player then return false end
    local success, isFriend = pcall(function() 
        return LocalPlayer:IsFriendsWith(player.UserId) 
    end)
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

-- HookMetamethod (セキュリティ強化)
local oldNamecall
local function safeHook()
    local success, err = pcall(function()
        if not hookmetamethod then return end
        task.wait(math.random(1, 3) * 0.1)
        oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
            local method = getnamecallmethod()
            if antiLagLookEnabled and method == "FireServer" then
                if self.Name == "Look" and self.Parent == CharacterEvents and self:IsA("RemoteEvent") then
                    return
                end
            end
            return oldNamecall(self, ...)
        end)
    end)
    if not success then 
        warn("Hook initialization warning: " .. tostring(err)) 
    end
end
safeHook()
-- ================= Delta-Time対応の主要機能 =================

-- Creature Anti-Grab (Delta-Time対応)
local function executeCreatureAntiGrab(character)
    spawn(function()
        local accumulatedTime = 0
        local executeInterval = 1.0 -- 1秒ごとに実行
        
        local connection
        connection = RunService.Heartbeat:Connect(function()
            if not coroutineFlags.AntiGrabCreature then
                connection:Disconnect()
                return
            end
            
            accumulatedTime = accumulatedTime + deltaTime
            
            if accumulatedTime >= executeInterval then
                accumulatedTime = 0
                
                pcall(function()
                    if not character or not character.Parent or not character:FindFirstChild("HumanoidRootPart") then 
                        coroutineFlags.AntiGrabCreature = false
                        connection:Disconnect()
                        return 
                    end
                    
                    local hrp = character:FindFirstChild("HumanoidRootPart")
                    local hum = character:FindFirstChild("Humanoid")
                    if not hrp or not hum then return end
                    
                    local orig = hrp.CFrame
                    local spawnY = hrp.Position.Y - 5
                    
                    MenuToys.SpawnToyRemoteFunction:InvokeServer(
                        "CreatureBlobman", 
                        CFrame.new(0, 50000, 0), 
                        Vector3.new(hrp.Position.X, spawnY, hrp.Position.Z)
                    )
                    
                    task.wait(0.1)
                    
                    local spawned = workspace:FindFirstChild(LocalPlayer.Name .. "SpawnedInToys")
                    local blob = spawned and spawned:FindFirstChild("CreatureBlobman")
                    
                    if blob then
                        for _, p in pairs(blob:GetDescendants()) do 
                            if p:IsA("BasePart") then 
                                p.Anchored = true 
                            end 
                        end
                        
                        local seat = blob:FindFirstChildWhichIsA("Seat") or blob:FindFirstChildWhichIsA("VehicleSeat")
                        
                        if seat then
                            local sitTime = 0
                            local sitDuration = 0.5 -- 0.5秒間座る
                            local sitConnection
                            
                            sitConnection = RunService.Heartbeat:Connect(function()
                                sitTime = sitTime + deltaTime
                                if sitTime >= sitDuration then
                                    sitConnection:Disconnect()
                                    return
                                end
                                seat:Sit(hum)
                                RagdollRemote:FireServer(hrp, 0)
                            end)
                            
                            task.wait(sitDuration)
                        end
                        
                        DestroyToy:FireServer(blob)
                    end
                    
                    task.wait(0.1)
                    if hrp then 
                        hrp.CFrame = orig 
                    end
                end)
            end
        end)
    end)
end

-- Test Invisible Anti-Grab (Delta-Time対応)
local function executeTestInvisibleAntiGrab(character)
    spawn(function()
        local accumulatedTime = 0
        local executeInterval = 1.0
        
        local connection
        connection = RunService.Heartbeat:Connect(function()
            if not coroutineFlags.AntiGrabTestInvisible then
                connection:Disconnect()
                return
            end
            
            accumulatedTime = accumulatedTime + deltaTime
            
            if accumulatedTime >= executeInterval then
                accumulatedTime = 0
                
                pcall(function()
                    if not character or not character.Parent then 
                        coroutineFlags.AntiGrabTestInvisible = false
                        connection:Disconnect()
                        return 
                    end
                    
                    local hrp = character:FindFirstChild("HumanoidRootPart")
                    local hum = character:FindFirstChild("Humanoid")
                    if not hrp or not hum then return end
                    
                    local foundSeat = nil
                    for _, obj in pairs(workspace:GetDescendants()) do
                        if (obj:IsA("Seat") or obj:IsA("VehicleSeat")) and obj.Name == "Seat" then 
                            foundSeat = obj
                            break 
                        end
                    end
                    
                    if foundSeat then
                        workspace.CurrentCamera.CameraType = Enum.CameraType.Scriptable
                        
                        local sitTime = 0
                        local sitDuration = 0.5
                        local sitConnection
                        
                        sitConnection = RunService.Heartbeat:Connect(function()
                            sitTime = sitTime + deltaTime
                            if sitTime >= sitDuration then
                                sitConnection:Disconnect()
                                return
                            end
                            foundSeat:Sit(hum)
                            RagdollRemote:FireServer(hrp, 0)
                        end)
                        
                        task.wait(sitDuration)
                        workspace.CurrentCamera.CameraType = Enum.CameraType.Custom
                        task.wait(0.1)
                        hrp.CFrame = CFrame.new(hrp.Position.X, 1000, hrp.Position.Z)
                    end
                end)
            end
        end)
    end)
end

-- Barrier Break (変更なし - 一度きりの実行)
local function executeBarrierBreak()
    spawn(function()
        pcall(function()
            local char = LocalPlayer.Character
            if not char or not char:FindFirstChild("HumanoidRootPart") then return end
            
            local orig = char.HumanoidRootPart.CFrame
            
            MenuToys.SpawnToyRemoteFunction:InvokeServer(
                "InstrumentWoodwindOcarina", 
                CFrame.new(184.14, -5.54, 498.13), 
                Vector3.new(0, 34, 0)
            )
            
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
                    
                    Rayfield:Notify({
                        Title = "Barrier Break", 
                        Content = "バリア破壊完了！", 
                        Duration = 3
                    })
                end
            end
        end)
    end)
end

-- Line機能
local function UpdateLineColors(...) 
    pcall(function() 
        ReplicatedStorage.DataEvents.UpdateLineColorsEvent:FireServer(...) 
    end) 
end

local function CreateRainbowSequence() 
    return ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.new(1,0,0)), 
        ColorSequenceKeypoint.new(0.2, Color3.new(1,1,0)), 
        ColorSequenceKeypoint.new(0.4, Color3.new(0,1,0)), 
        ColorSequenceKeypoint.new(0.6, Color3.new(0,1,1)), 
        ColorSequenceKeypoint.new(0.8, Color3.new(0,0,1)), 
        ColorSequenceKeypoint.new(1, Color3.new(1,0,1))
    } 
end

local function CreateBrightRandomGradient(colorCount)
    local keypoints = {}
    for i = 0, colorCount - 1 do
        local time = i / (colorCount - 1)
        local hue = math.random()
        local color = Color3.fromHSV(hue, 1, 1)
        table.insert(keypoints, ColorSequenceKeypoint.new(time, color))
    end
    return ColorSequence.new(keypoints)
end

local function CreateSolidSequence(color) 
    return ColorSequence.new{
        ColorSequenceKeypoint.new(0, color), 
        ColorSequenceKeypoint.new(1, color)
    } 
end

local function CreateLineLag(targetPlayer) 
    if not targetPlayer or not targetPlayer.Character then return end
    local t = targetPlayer.Character:FindFirstChild("Torso") or targetPlayer.Character:FindFirstChild("UpperTorso")
    if t then 
        CreateGrabLine:FireServer(t, CFrame.new(0,0,0)) 
    end 
end

local presets = {
    ["Black & White"] = {Color3.new(0,0,0), Color3.new(1,1,1)}, 
    ["Red & Blue"] = {Color3.new(1,0,0), Color3.new(0,0,1)}, 
    ["Red & Black"] = {Color3.new(1,0,0), Color3.new(0,0,0)}, 
    ["Blue & Yellow"] = {Color3.new(0,0,1), Color3.new(1,1,0)}
}

-- リスポーンハンドラ
LocalPlayer.CharacterAdded:Connect(function(c)
    LocalCharacter = c
    lastFrameTime = tick()
    
    if coroutineFlags.AntiGrabCreature then 
        executeCreatureAntiGrab(c) 
    end
    if coroutineFlags.AntiGrabTestInvisible then 
        executeTestInvisibleAntiGrab(c) 
    end
end)

-- Kick Grab (Delta-Time対応)
local function kickGrab()
    local accumulatedTime = 0
    local executeInterval = 0.5
    
    local connection
    connection = RunService.Heartbeat:Connect(function()
        if not coroutineFlags.KickGrab then
            connection:Disconnect()
            return
        end
        
        accumulatedTime = accumulatedTime + deltaTime
        
        if accumulatedTime >= executeInterval then
            accumulatedTime = 0
            
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
                            end
                        end
                    end
                end
            end)
        end
    end)
end

-- UFO Grab (Delta-Time対応)
local function ufoGrab()
    local connection
    connection = RunService.Heartbeat:Connect(function()
        if not coroutineFlags.UfoGrab then
            connection:Disconnect()
            return
        end
        
        pcall(function()
            local c = workspace:FindFirstChild("GrabParts")
            if c and c:FindFirstChild("GrabPart") then
                local w = c.GrabPart:FindFirstChild("WeldConstraint")
                if w and w.Part1 and w.Part1.Parent then
                    local hrp = w.Part1.Parent:FindFirstChild("HumanoidRootPart")
                    if hrp then
                        -- 既存のBodyMoverを削除
                        for _, v in pairs(hrp:GetChildren()) do 
                            if v:IsA("BodyMover") then 
                                v:Destroy() 
                            end 
                        end
                        
                        local bp = Instance.new("BodyPosition", hrp)
                        bp.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                        bp.Position = hrp.Position + Vector3.new(0, _G.ufoHeight, 0)
                        
                        local bav = Instance.new("BodyAngularVelocity", hrp)
                        bav.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
                        bav.AngularVelocity = Vector3.new(0, _G.ufoRotationSpeed, 0)
                        
                        -- GrabPartsが消えたら削除
                        local cleanupConn
                        cleanupConn = RunService.Heartbeat:Connect(function()
                            if not workspace:FindFirstChild("GrabParts") or not coroutineFlags.UfoGrab then
                                if bp then bp:Destroy() end
                                if bav then bav:Destroy() end
                                cleanupConn:Disconnect()
                            end
                        end)
                    end
                end
            end
        end)
    end)
end

-- Grab Handler (Delta-Time対応)
local function grabHandler(grabType)
    local connection
    connection = RunService.Heartbeat:Connect(function()
        if not coroutineFlags[grabType.."Grab"] then
            connection:Disconnect()
            return
        end
        
        pcall(function()
            local c = workspace:FindFirstChild("GrabParts")
            if c and c:FindFirstChild("GrabPart") then
                local w = c.GrabPart:FindFirstChild("WeldConstraint")
                if w and w.Part1 and w.Part1.Parent then
                    local h = w.Part1.Parent:FindFirstChild("Head")
                    if h then
                        local pt = grabType == "poison" and PoisonHurtParts or PaintPlayerParts
                        for _, p in pairs(pt) do 
                            p.Size = Vector3.new(2, 2, 2)
                            p.Transparency = 1
                            p.Position = h.Position 
                        end
                        
                        task.wait(deltaTime)
                        
                        for _, p in pairs(pt) do 
                            p.Position = Vector3.new(0, -200, 0) 
                        end
                    end
                end
            end
        end)
    end)
end

-- Burn Grab (Delta-Time対応)
local function burnGrab()
    local accumulatedTime = 0
    local executeInterval = 0.5
    
    local connection
    connection = RunService.Heartbeat:Connect(function()
        if not coroutineFlags.BurnGrab then
            connection:Disconnect()
            return
        end
        
        accumulatedTime = accumulatedTime + deltaTime
        
        if accumulatedTime >= executeInterval then
            accumulatedTime = 0
            
            pcall(function()
                local c = workspace:FindFirstChild("GrabParts")
                if c and c:FindFirstChild("GrabPart") then
                    local w = c.GrabPart:FindFirstChild("WeldConstraint")
                    if w and w.Part1 and w.Part1.Parent then
                        local h = w.Part1.Parent:FindFirstChild("Head")
                        if h then 
                            burn(h) 
                        end
                    end
                end
            end)
        end
    end)
end

-- Kill Grab (Delta-Time対応)
local function killGrab()
    local connection
    connection = RunService.Heartbeat:Connect(function()
        if not coroutineFlags.KillGrab then
            connection:Disconnect()
            return
        end
        
        pcall(function()
            local c = workspace:FindFirstChild("GrabParts")
            if c and c:FindFirstChild("GrabPart") then
                local w = c.GrabPart:FindFirstChild("WeldConstraint")
                if w and w.Part1 and w.Part1.Parent then
                    local h = w.Part1.Parent:FindFirstChild("Humanoid")
                    if h then 
                        h.Health = 0 
                    end
                end
            end
        end)
    end)
end
-- ================= 追加のグラブ機能（Delta-Time対応） =================

-- Noclip Grab (Delta-Time対応)
local function noclipGrab()
    local connection
    connection = RunService.Heartbeat:Connect(function()
        if not coroutineFlags.NoclipGrab then
            connection:Disconnect()
            return
        end
        
        pcall(function()
            local c = workspace:FindFirstChild("GrabParts")
            if c and c:FindFirstChild("GrabPart") then
                local w = c.GrabPart:FindFirstChild("WeldConstraint")
                if w and w.Part1 and w.Part1.Parent then
                    for _, p in pairs(w.Part1.Parent:GetChildren()) do 
                        if p:IsA("BasePart") then 
                            p.CanCollide = false 
                        end 
                    end
                end
            end
        end)
    end)
end

-- Heaven Grab (Delta-Time対応)
local function heavenGrab()
    local connection
    connection = RunService.Heartbeat:Connect(function()
        if not coroutineFlags.HeavenGrab then
            connection:Disconnect()
            return
        end
        
        pcall(function()
            local c = workspace:FindFirstChild("GrabParts")
            if c and c:FindFirstChild("GrabPart") then
                local w = c.GrabPart:FindFirstChild("WeldConstraint")
                if w and w.Part1 and w.Part1.Parent then
                    local t = w.Part1.Parent:FindFirstChild("Torso")
                    if t then
                        local v = t:FindFirstChild("heavenG") or Instance.new("BodyVelocity", t)
                        v.Name = "heavenG"
                        v.Velocity = Vector3.new(0, 9999999, 0)
                        v.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                        Debris:AddItem(v, 100)
                    end
                end
            end
        end)
    end)
end

-- Teleport Grab (Delta-Time対応)
local TPgrabOption = "TP to spawn"
local function crazyGrab()
    local connection
    connection = RunService.Heartbeat:Connect(function()
        if not coroutineFlags.CrazyGrab then
            connection:Disconnect()
            return
        end
        
        pcall(function()
            local c = workspace:FindFirstChild("GrabParts")
            if c and c:FindFirstChild("GrabPart") then
                local w = c.GrabPart:FindFirstChild("WeldConstraint")
                if w and w.Part1 and w.Part1.Parent then
                    local hrp = w.Part1.Parent:FindFirstChild("HumanoidRootPart")
                    if hrp then
                        if TPgrabOption == "TP to spawn" then 
                            hrp.CFrame = CFrame.new(-1, -7, -9)
                        elseif TPgrabOption == "Crazy teleport" then
                            hrp.CFrame = CFrame.new(-17, 421, 50)
                            task.wait(0.1)
                            hrp.CFrame = CFrame.new(145, 397, -126)
                            task.wait(0.1)
                            hrp.CFrame = CFrame.new(157, 254, 89)
                            task.wait(0.1)
                        end
                    end
                end
            end
        end)
    end)
end

-- Anti Explosion Setup
local antiExplosionConnection
local characterAddedConn

local function setupAntiExplosion(character)
    task.wait(0.5)
    local h = character:FindFirstChild("Humanoid")
    if not h then return end
    
    local r = h:FindFirstChild("Ragdolled")
    if r then
        if antiExplosionConnection then 
            antiExplosionConnection:Disconnect() 
        end
        
        antiExplosionConnection = r:GetPropertyChangedSignal("Value"):Connect(function()
            pcall(function()
                if r.Value then
                    for _, p in ipairs(character:GetChildren()) do 
                        if p:IsA("BasePart") then 
                            p.Anchored = true 
                        end 
                    end
                    task.wait(0.5)
                    for _, p in ipairs(character:GetChildren()) do 
                        if p:IsA("BasePart") then 
                            p.Anchored = false 
                        end 
                    end
                end
            end)
        end)
    end
end

-- Kill Function (Delta-Time対応)
local function kill(p)
    pcall(function()
        local pl = Players:FindFirstChild(p)
        if not pl or not pl.Character then return end
        
        local phrp = pl.Character:FindFirstChild("HumanoidRootPart")
        local phum = pl.Character:FindFirstChild("Humanoid")
        local mhrp = LocalCharacter and LocalCharacter:FindFirstChild("HumanoidRootPart")
        
        if phrp and mhrp and phum then
            local old = mhrp.CFrame
            
            local killConnection
            killConnection = RunService.Heartbeat:Connect(function()
                if phum.Health <= 0 then
                    killConnection:Disconnect()
                    mhrp.CFrame = old
                    return
                end
                
                mhrp.CFrame = phrp.CFrame - Vector3.new(0, 10, 0)
                SetNetworkOwner:FireServer(phrp, CFrame.new(phrp.Position))
                
                for _, pt in pairs(PoisonHurtParts) do 
                    pt.Size = Vector3.new(1.5, 1.5, 1.5)
                    pt.Transparency = 1
                    pt.Position = pl.Character.Head.Position 
                end
                
                task.wait(deltaTime)
                
                for _, pt in pairs(PoisonHurtParts) do 
                    pt.Position = Vector3.new(0, -200, 0) 
                end
            end)
        end
    end)
end

-- Dropdown Helper
local function TargetPlayersDropdown()
    local t = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then 
            table.insert(t, p.Name) 
        end
    end
    return t
end

-- Blobman Functions
local function bringLeft(k)
    if not k then return end
    local p = Players:FindFirstChild(k)
    if not p or not p.Character then return end
    
    for _, v in pairs(workspace:GetDescendants()) do
        if v.Name == "CreatureBlobman" then
            pcall(function() 
                v.BlobmanSeatAndOwnerScript.CreatureGrab:FireServer(
                    v.LeftDetector, 
                    p.Character.HumanoidRootPart, 
                    v.LeftDetector.LeftWeld
                ) 
            end)
        end
    end
end

local function bringRight(k)
    if not k then return end
    local p = Players:FindFirstChild(k)
    if not p or not p.Character then return end
    
    for _, v in pairs(workspace:GetDescendants()) do
        if v.Name == "CreatureBlobman" then
            pcall(function() 
                v.BlobmanSeatAndOwnerScript.CreatureGrab:FireServer(
                    v.RightDetector, 
                    p.Character.HumanoidRootPart, 
                    v.RightDetector.RightWeld
                ) 
            end)
        end
    end
end

-- ================= オーラ系機能（Delta-Time対応） =================

-- Loop Kill (Delta-Time対応)
local function startLoopKill()
    local accumulatedTime = 0
    local executeInterval = 0.3
    
    local connection
    connection = RunService.Heartbeat:Connect(function()
        if not coroutineFlags.LoopKill or not selectedTarget then
            connection:Disconnect()
            return
        end
        
        accumulatedTime = accumulatedTime + deltaTime
        
        if accumulatedTime >= executeInterval then
            accumulatedTime = 0
            
            pcall(function()
                if not isPlayerWhitelisted(selectedTarget) and selectedTarget.Character then
                    local h = selectedTarget.Character:FindFirstChild("Head")
                    if h then
                        for _, p in pairs(PoisonHurtParts) do 
                            p.Size = Vector3.new(2, 2, 2)
                            p.Transparency = 1
                            p.Position = h.Position 
                        end
                        
                        task.wait(0.1)
                        
                        for _, p in pairs(PoisonHurtParts) do 
                            p.Position = Vector3.new(0, -200, 0) 
                        end
                    end
                end
            end)
        end
    end)
end

-- Orbit Player (Delta-Time対応 - 滑らかな回転)
local function startOrbitPlayer()
    local angle = 0
    local angularSpeed = 1.5 -- ラジアン/秒
    
    local connection
    connection = RunService.Heartbeat:Connect(function()
        if not coroutineFlags.OrbitPlayer or not selectedTarget then
            connection:Disconnect()
            return
        end
        
        pcall(function()
            if selectedTarget.Character and LocalCharacter then
                local targetHRP = selectedTarget.Character:FindFirstChild("HumanoidRootPart")
                local myHRP = LocalCharacter:FindFirstChild("HumanoidRootPart")
                
                if targetHRP and myHRP then
                    angle = angle + (angularSpeed * deltaTime)
                    local offset = Vector3.new(math.cos(angle) * 10, 2, math.sin(angle) * 10)
                    myHRP.CFrame = CFrame.new(
                        targetHRP.Position + offset, 
                        targetHRP.Position
                    )
                end
            end
        end)
    end)
end

-- Grab Aura (Delta-Time対応)
local function startGrabAura()
    local accumulatedTime = 0
    local executeInterval = 0.02
    
    local connection
    connection = RunService.Heartbeat:Connect(function()
        if not coroutineFlags.GrabAura then
            connection:Disconnect()
            return
        end
        
        accumulatedTime = accumulatedTime + deltaTime
        
        if accumulatedTime >= executeInterval then
            accumulatedTime = 0
            
            pcall(function()
                if LocalCharacter and LocalCharacter:FindFirstChild("HumanoidRootPart") then
                    local myPos = LocalCharacter.HumanoidRootPart.Position
                    
                    for _, p in pairs(Players:GetPlayers()) do
                        if p ~= LocalPlayer and p.Character then
                            local h = p.Character:FindFirstChild("HumanoidRootPart")
                            if h then
                                local distance = (h.Position - myPos).Magnitude
                                if distance <= auraRadius and not isPlayerWhitelisted(p) then
                                    sno(h, h.CFrame)
                                end
                            end
                        end
                    end
                end
            end)
        end
    end)
end

-- Poison Aura (Delta-Time対応)
local function startPoisonAura()
    local accumulatedTime = 0
    local executeInterval = 0.1
    
    local connection
    connection = RunService.Heartbeat:Connect(function()
        if not coroutineFlags.PoisonAura then
            connection:Disconnect()
            return
        end
        
        accumulatedTime = accumulatedTime + deltaTime
        
        if accumulatedTime >= executeInterval then
            accumulatedTime = 0
            
            pcall(function()
                if LocalCharacter and LocalCharacter:FindFirstChild("HumanoidRootPart") then
                    local myPos = LocalCharacter.HumanoidRootPart.Position
                    
                    for _, p in pairs(Players:GetPlayers()) do
                        if p ~= LocalPlayer and p.Character then
                            local h = p.Character:FindFirstChild("Head")
                            local hrp = p.Character:FindFirstChild("HumanoidRootPart")
                            
                            if h and hrp then
                                local distance = (hrp.Position - myPos).Magnitude
                                if distance <= auraRadius and not isPlayerWhitelisted(p) then
                                    for _, pt in pairs(PoisonHurtParts) do 
                                        pt.Size = Vector3.new(2, 2, 2)
                                        pt.Transparency = 1
                                        pt.Position = h.Position 
                                    end
                                    
                                    task.wait(deltaTime)
                                    
                                    for _, pt in pairs(PoisonHurtParts) do 
                                        pt.Position = Vector3.new(0, -200, 0) 
                                    end
                                end
                            end
                        end
                    end
                end
            end)
        end
    end)
end

-- Fire Aura (Delta-Time対応)
local function startFireAura()
    local accumulatedTime = 0
    local executeInterval = 0.5
    
    local connection
    connection = RunService.Heartbeat:Connect(function()
        if not coroutineFlags.FireAura then
            connection:Disconnect()
            return
        end
        
        accumulatedTime = accumulatedTime + deltaTime
        
        if accumulatedTime >= executeInterval then
            accumulatedTime = 0
            
            pcall(function()
                if LocalCharacter and LocalCharacter:FindFirstChild("HumanoidRootPart") then
                    local myPos = LocalCharacter.HumanoidRootPart.Position
                    
                    for _, p in pairs(Players:GetPlayers()) do
                        if p ~= LocalPlayer and p.Character then
                            local h = p.Character:FindFirstChild("Head")
                            local hrp = p.Character:FindFirstChild("HumanoidRootPart")
                            
                            if h and hrp then
                                local distance = (hrp.Position - myPos).Magnitude
                                if distance <= auraRadius and not isPlayerWhitelisted(p) then
                                    burn(h)
                                end
                            end
                        end
                    end
                end
            end)
        end
    end)
end

-- Delete Aura (Delta-Time対応)
local function startDeleteAura()
    local accumulatedTime = 0
    local executeInterval = 0.5
    
    local connection
    connection = RunService.Heartbeat:Connect(function()
        if not coroutineFlags.DeleteAura then
            connection:Disconnect()
            return
        end
        
        accumulatedTime = accumulatedTime + deltaTime
        
        if accumulatedTime >= executeInterval then
            accumulatedTime = 0
            
            pcall(function()
                if LocalCharacter and LocalCharacter:FindFirstChild("HumanoidRootPart") then
                    local myPos = LocalCharacter.HumanoidRootPart.Position
                    
                    for _, p in pairs(Players:GetPlayers()) do
                        if p ~= LocalPlayer and p.Character then
                            local t = p.Character:FindFirstChild("Torso")
                            local hrp = p.Character:FindFirstChild("HumanoidRootPart")
                            
                            if t and hrp then
                                local distance = (hrp.Position - myPos).Magnitude
                                if distance <= auraRadius and not isPlayerWhitelisted(p) then
                                    SetNetworkOwner:FireServer(t, hrp.CFrame)
                                    local vel = Instance.new("BodyVelocity", t)
                                    vel.Velocity = Vector3.new(0, 9999999, 0)
                                    vel.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                                    Debris:AddItem(vel, 100)
                                end
                            end
                        end
                    end
                end
            end)
        end
    end)
end

-- Bring All (Delta-Time対応)
local function startBringAll()
    local accumulatedTime = 0
    local executeInterval = 0.5
    
    local connection
    connection = RunService.Heartbeat:Connect(function()
        if not coroutineFlags.BringAll then
            connection:Disconnect()
            return
        end
        
        accumulatedTime = accumulatedTime + deltaTime
        
        if accumulatedTime >= executeInterval then
            accumulatedTime = 0
            
            pcall(function()
                if LocalCharacter and LocalCharacter:FindFirstChild("HumanoidRootPart") then
                    local pos = LocalCharacter.HumanoidRootPart.Position
                    
                    for _, p in pairs(Players:GetPlayers()) do
                        if p ~= LocalPlayer and not isPlayerWhitelisted(p) and p.Character then
                            local h = p.Character:FindFirstChild("HumanoidRootPart")
                            if h then 
                                h.CFrame = CFrame.new(
                                    pos + Vector3.new(
                                        math.random(-5, 5), 
                                        0, 
                                        math.random(-5, 5)
                                    )
                                ) 
                            end
                        end
                    end
                end
            end)
        end
    end)
end

-- Fling All (Delta-Time対応 - バッチ処理)
local function startFlingAll()
    local accumulatedTime = 0
    local executeInterval = 0.15 -- 0.15秒ごとにバッチ実行
    
    local connection
    connection = RunService.Heartbeat:Connect(function()
        if not coroutineFlags.FlingAll then
            connection:Disconnect()
            return
        end
        
        accumulatedTime = accumulatedTime + deltaTime
        
        if accumulatedTime >= executeInterval then
            accumulatedTime = 0
            
            local list = Players:GetPlayers()
            local BATCH_SIZE = 3
            
            for i = 1, #list, BATCH_SIZE do
                if not coroutineFlags.FlingAll then break end
                
                for j = i, math.min(i + BATCH_SIZE - 1, #list) do
                    local p = list[j]
                    if p ~= LocalPlayer and not isPlayerWhitelisted(p) and p.Character then
                        local hrp = p.Character:FindFirstChild("HumanoidRootPart")
                        if hrp then
                            sno(hrp, hrp.CFrame)
                            local bv = Instance.new("BodyVelocity", hrp)
                            bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                            bv.Velocity = Vector3.new(
                                math.random(-2000, 2000), 
                                math.random(1000, 2000), 
                                math.random(-2000, 2000)
                            )
                            Debris:AddItem(bv, 0.1)
                            task.delay(0.1, function() ungrab(hrp) end)
                        end
                    end
                end
                
                task.wait(0.05)
            end
        end
    end)
end
-- ================= Rayfield Window Creation =================
local Window = Rayfield:CreateWindow({
    Name = "FTAP v10.1 Rayfield Edition (Delta-Time Fixed)",
    LoadingTitle = "FTAP by Nexus",
    LoadingSubtitle = "Delta-Time Independent System Loading...",
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
            startLoopKill()
        end
    end,
})

AttackTab:CreateButton({
    Name = "ターゲットを即キル",
    Callback = function()
        if TargetSelected then 
            kill(TargetSelected) 
        end
    end,
})

AttackTab:CreateButton({
    Name = "ターゲットにテレポート",
    Callback = function()
        if selectedTarget and selectedTarget.Character and LocalCharacter then
            pcall(function()
                LocalCharacter.HumanoidRootPart.CFrame = selectedTarget.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, 3)
            end)
        end
    end,
})

AttackTab:CreateToggle({
    Name = "ターゲット周回 (滑らか)",
    CurrentValue = false,
    Flag = "OrbitTarget",
    Callback = function(Value)
        coroutineFlags.OrbitPlayer = Value
        if Value and selectedTarget then
            startOrbitPlayer()
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
                        local gp = m:WaitForChild("GrabPart", 1)
                        if gp then
                            local w = gp:WaitForChild("WeldConstraint", 1)
                            if w and w.Part1 then
                                local bv = Instance.new("BodyVelocity", w.Part1)
                                bv.MaxForce = Vector3.new(0, 0, 0)
                                
                                m:GetPropertyChangedSignal("Parent"):Connect(function()
                                    if not m.Parent then
                                        if isRightClickOrLongPress then
                                            bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                                            bv.Velocity = workspace.CurrentCamera.CFrame.LookVector * strength
                                            Debris:AddItem(bv, 1)
                                        else 
                                            bv:Destroy() 
                                        end
                                        isRightClickOrLongPress = false
                                    end
                                end)
                            end
                        end
                    end)
                end
            end)
        elseif connections.Strength then
            connections.Strength:Disconnect()
            connections.Strength = nil
        end
    end,
})

AttackTab:CreateToggle({
    Name = "全員をフリング (最適化)",
    CurrentValue = false,
    Flag = "FlingAll",
    Callback = function(Value)
        coroutineFlags.FlingAll = Value
        if Value then
            startFlingAll()
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
            startBringAll()
        end
    end,
})

-- ================= Grab Tab =================
local GrabTab = Window:CreateTab("🎯 グラブ", 4483345998)

GrabTab:CreateSection("ダメージグラブ")

GrabTab:CreateToggle({
    Name = "毒グラブ", 
    CurrentValue = false, 
    Flag = "PoisonGrab", 
    Callback = function(v) 
        coroutineFlags.PoisonGrab = v
        if v then 
            grabHandler("poison") 
        end 
    end
})

GrabTab:CreateToggle({
    Name = "放射能グラブ", 
    CurrentValue = false, 
    Flag = "RadGrab", 
    Callback = function(v) 
        coroutineFlags.RadiactiveGrab = v
        if v then 
            grabHandler("radioctive") 
        end 
    end
})

GrabTab:CreateToggle({
    Name = "火グラブ", 
    CurrentValue = false, 
    Flag = "BurnGrab", 
    Callback = function(v) 
        coroutineFlags.BurnGrab = v
        if v then 
            burnGrab() 
        end 
    end
})

GrabTab:CreateToggle({
    Name = "キルグラブ", 
    CurrentValue = false, 
    Flag = "KillGrab", 
    Callback = function(v) 
        coroutineFlags.KillGrab = v
        if v then 
            killGrab() 
        end 
    end
})

GrabTab:CreateToggle({
    Name = "天国グラブ", 
    CurrentValue = false, 
    Flag = "HeavenGrab", 
    Callback = function(v) 
        coroutineFlags.HeavenGrab = v
        if v then 
            heavenGrab() 
        end 
    end
})

GrabTab:CreateSection("新グラブエフェクト")

GrabTab:CreateToggle({
    Name = "キックグラブ ⚽", 
    CurrentValue = false, 
    Flag = "KickGrab", 
    Callback = function(v) 
        coroutineFlags.KickGrab = v
        if v then 
            kickGrab() 
        end 
    end
})

GrabTab:CreateSlider({
    Name = "キック力", 
    Range = {50, 500}, 
    Increment = 10, 
    CurrentValue = 150, 
    Flag = "KickForce", 
    Callback = function(v) 
        _G.kickForce = v 
    end
})

GrabTab:CreateToggle({
    Name = "UFOグラブ 🛸", 
    CurrentValue = false, 
    Flag = "UfoGrab", 
    Callback = function(v) 
        coroutineFlags.UfoGrab = v
        if v then 
            ufoGrab() 
        end 
    end
})

GrabTab:CreateSlider({
    Name = "UFO高さ", 
    Range = {5, 30}, 
    Increment = 1, 
    CurrentValue = 10, 
    Flag = "UfoHeight", 
    Callback = function(v) 
        _G.ufoHeight = v 
    end
})

GrabTab:CreateSlider({
    Name = "UFO回転速度", 
    Range = {1, 20}, 
    Increment = 1, 
    CurrentValue = 5, 
    Flag = "UfoRot", 
    Callback = function(v) 
        _G.ufoRotationSpeed = v 
    end
})

GrabTab:CreateSection("エフェクトグラブ")

GrabTab:CreateToggle({
    Name = "ノークリップグラブ", 
    CurrentValue = false, 
    Flag = "NoclipGrab", 
    Callback = function(v) 
        coroutineFlags.NoclipGrab = v
        if v then 
            noclipGrab() 
        end 
    end
})

GrabTab:CreateToggle({
    Name = "テレポートグラブ", 
    CurrentValue = false, 
    Flag = "TpGrab", 
    Callback = function(v) 
        coroutineFlags.CrazyGrab = v
        if v then 
            crazyGrab() 
        end 
    end
})

-- ================= Aura Tab =================
local AuraTab = Window:CreateTab("🔥 オーラ", 4483345998)

AuraTab:CreateSlider({
    Name = "オーラ範囲", 
    Range = {5, 100}, 
    Increment = 1, 
    CurrentValue = 20, 
    Flag = "AuraRadius", 
    Callback = function(v) 
        auraRadius = v 
    end
})

AuraTab:CreateToggle({
    Name = "グラブオーラ", 
    CurrentValue = false, 
    Flag = "GrabAura",
    Callback = function(v)
        coroutineFlags.GrabAura = v
        if v then 
            startGrabAura() 
        end
    end
})

AuraTab:CreateToggle({
    Name = "毒オーラ", 
    CurrentValue = false, 
    Flag = "PoisonAura",
    Callback = function(v)
        coroutineFlags.PoisonAura = v
        if v then 
            startPoisonAura() 
        end
    end
})

AuraTab:CreateToggle({
    Name = "火オーラ", 
    CurrentValue = false, 
    Flag = "FireAura",
    Callback = function(v)
        coroutineFlags.FireAura = v
        if v then 
            startFireAura() 
        end
    end
})

AuraTab:CreateToggle({
    Name = "削除オーラ (天国)", 
    CurrentValue = false, 
    Flag = "DeleteAura",
    Callback = function(v)
        coroutineFlags.DeleteAura = v
        if v then 
            startDeleteAura() 
        end
    end
})

AuraTab:CreateSection("全員攻撃")

AuraTab:CreateToggle({
    Name = "Fire All (全員燃やす)", 
    CurrentValue = false, 
    Flag = "FireAll",
    Callback = function(v)
        coroutineFlags.FireAll = v
        if v then 
            task.spawn(function()
                while coroutineFlags.FireAll do
                    pcall(function()
                        if toysFolder and toysFolder:FindFirstChild("Campfire") then 
                            DestroyToy:FireServer(toysFolder.Campfire)
                            task.wait(0.5) 
                        end
                        
                        if LocalCharacter and LocalCharacter:FindFirstChild("Head") then
                            spawnItemCf("Campfire", LocalCharacter.Head.CFrame)
                            task.wait(0.5)
                            
                            local cf = toysFolder and toysFolder:WaitForChild("Campfire", 2)
                            if cf then
                                local fpp = cf:FindFirstChild("FirePlayerPart")
                                if fpp then
                                    fpp.Size = Vector3.new(10, 10, 10)
                                    SetNetworkOwner:FireServer(fpp, fpp.CFrame)
                                    
                                    local bp = Instance.new("BodyPosition", cf.Main)
                                    bp.P = 20000
                                    bp.Position = LocalCharacter.Head.Position + Vector3.new(0, 600, 0)
                                    
                                    local fireConnection
                                    fireConnection = RunService.Heartbeat:Connect(function()
                                        if not coroutineFlags.FireAll then
                                            fireConnection:Disconnect()
                                            return
                                        end
                                        
                                        for _, p in pairs(Players:GetPlayers()) do
                                            if p ~= LocalPlayer and not isPlayerWhitelisted(p) and p.Character then
                                                local hrp = p.Character:FindFirstChild("HumanoidRootPart")
                                                if hrp then
                                                    fpp.Position = hrp.Position
                                                end
                                            end
                                        end
                                    end)
                                end
                            end
                        end
                    end)
                    task.wait(1)
                end
            end)
        end
    end
})

-- ================= Auto Tab =================
local AutoTab = Window:CreateTab("🤖 オート", 4483345998)

AutoTab:CreateButton({
    Name = "🆕 バリア破壊を実行", 
    Callback = executeBarrierBreak
})

-- ================= Blobman Tab =================
local BlobTab = Window:CreateTab("👾 Blobman", 4483345998)

BlobTab:CreateSection("Left Bring")

local LeftDrop = BlobTab:CreateDropdown({
    Name = "Left Player", 
    Options = TargetPlayersDropdown(), 
    CurrentOption = "", 
    Flag = "LeftBlob", 
    Callback = function(o) 
        LeftBlobSelected = o[1] 
    end
})

BlobTab:CreateButton({
    Name = "Left Bring", 
    Callback = function() 
        if LeftBlobSelected then 
            bringLeft(LeftBlobSelected) 
        end 
    end
})

BlobTab:CreateToggle({
    Name = "Loop Left", 
    CurrentValue = false, 
    Flag = "LoopLeft", 
    Callback = function(v) 
        coroutineFlags.LoopLeftBlob = v
        
        if v then
            local accumulatedTime = 0
            local connection
            connection = RunService.Heartbeat:Connect(function()
                if not coroutineFlags.LoopLeftBlob then
                    connection:Disconnect()
                    return
                end
                
                accumulatedTime = accumulatedTime + deltaTime
                if accumulatedTime >= _G.BlobmanDelay then
                    accumulatedTime = 0
                    if LeftBlobSelected then
                        bringLeft(LeftBlobSelected)
                    end
                end
            end)
        end
    end
})

BlobTab:CreateSection("Right Bring")

local RightDrop = BlobTab:CreateDropdown({
    Name = "Right Player", 
    Options = TargetPlayersDropdown(), 
    CurrentOption = "", 
    Flag = "RightBlob", 
    Callback = function(o) 
        RightBlobSelected = o[1] 
    end
})

BlobTab:CreateButton({
    Name = "Right Bring", 
    Callback = function() 
        if RightBlobSelected then 
            bringRight(RightBlobSelected) 
        end 
    end
})

BlobTab:CreateToggle({
    Name = "Loop Right", 
    CurrentValue = false, 
    Flag = "LoopRight", 
    Callback = function(v) 
        coroutineFlags.LoopRightBlob = v
        
        if v then
            local accumulatedTime = 0
            local connection
            connection = RunService.Heartbeat:Connect(function()
                if not coroutineFlags.LoopRightBlob then
                    connection:Disconnect()
                    return
                end
                
                accumulatedTime = accumulatedTime + deltaTime
                if accumulatedTime >= _G.BlobmanDelay then
                    accumulatedTime = 0
                    if RightBlobSelected then
                        bringRight(RightBlobSelected)
                    end
                end
            end)
        end
    end
})

BlobTab:CreateSection("Duo Bring")

local DuoDrop = BlobTab:CreateDropdown({
    Name = "Two Hands Player", 
    Options = TargetPlayersDropdown(), 
    CurrentOption = "", 
    Flag = "DuoBlob", 
    Callback = function(o) 
        DuoBlobSelected = o[1] 
    end
})

BlobTab:CreateButton({
    Name = "Two Hands Bring", 
    Callback = function() 
        if DuoBlobSelected then 
            bringRight(DuoBlobSelected)
            bringLeft(DuoBlobSelected) 
        end 
    end
})

BlobTab:CreateToggle({
    Name = "Loop Two Hands", 
    CurrentValue = false, 
    Flag = "LoopDuo", 
    Callback = function(v) 
        coroutineFlags.LoopDuoBlob = v
        
        if v then
            local accumulatedTime = 0
            local connection
            connection = RunService.Heartbeat:Connect(function()
                if not coroutineFlags.LoopDuoBlob then
                    connection:Disconnect()
                    return
                end
                
                accumulatedTime = accumulatedTime + deltaTime
                if accumulatedTime >= _G.BlobmanDelay then
                    accumulatedTime = 0
                    if DuoBlobSelected then
                        bringLeft(DuoBlobSelected)
                        bringRight(DuoBlobSelected)
                    end
                end
            end)
        end
    end
})

BlobTab:CreateSection("Server")

BlobTab:CreateButton({
    Name = "Bring All", 
    Callback = function() 
        for _, p in pairs(Players:GetPlayers()) do 
            if p ~= LocalPlayer and not isPlayerWhitelisted(p) then 
                bringLeft(p.Name)
                bringRight(p.Name) 
            end 
        end 
    end
})

BlobTab:CreateToggle({
    Name = "Destroy Server", 
    CurrentValue = false, 
    Flag = "DesServ", 
    Callback = function(v) 
        coroutineFlags.ServerBreak = v
        
        if v then
            local accumulatedTime = 0
            local connection
            connection = RunService.Heartbeat:Connect(function()
                if not coroutineFlags.ServerBreak then
                    connection:Disconnect()
                    return
                end
                
                accumulatedTime = accumulatedTime + deltaTime
                if accumulatedTime >= _G.BlobmanDelay then
                    accumulatedTime = 0
                    for _, p in pairs(Players:GetPlayers()) do 
                        if p ~= LocalPlayer and not isPlayerWhitelisted(p) then 
                            bringLeft(p.Name)
                            bringRight(p.Name) 
                        end 
                    end
                end
            end)
        end
    end
})

BlobTab:CreateSlider({
    Name = "Blob Delay", 
    Range = {0.001, 1}, 
    Increment = 0.001, 
    CurrentValue = 0.001, 
    Flag = "BlobDelay", 
    Callback = function(v) 
        _G.BlobmanDelay = v 
    end
})

-- ================= Character Tab =================
local CharTab = Window:CreateTab("🏃 キャラ", 4483345998)

CharTab:CreateSlider({
    Name = "WalkSpeed", 
    Range = {16, 500}, 
    Increment = 1, 
    CurrentValue = 16, 
    Flag = "WS", 
    Callback = function(v) 
        if LocalCharacter and LocalCharacter:FindFirstChild("Humanoid") then 
            LocalCharacter.Humanoid.WalkSpeed = v 
        end 
    end
})

CharTab:CreateSlider({
    Name = "JumpPower", 
    Range = {50, 500}, 
    Increment = 1, 
    CurrentValue = 50, 
    Flag = "JP", 
    Callback = function(v) 
        if LocalCharacter and LocalCharacter:FindFirstChild("Humanoid") then 
            LocalCharacter.Humanoid.JumpPower = v 
        end 
    end
})

local infJump = false
CharTab:CreateToggle({
    Name = "無限ジャンプ", 
    CurrentValue = false, 
    Flag = "InfJump", 
    Callback = function(v) 
        infJump = v
        if v then 
            UserInputService.JumpRequest:Connect(function() 
                if infJump and LocalCharacter then 
                    local hum = LocalCharacter:FindFirstChildOfClass("Humanoid")
                    if hum then
                        hum:ChangeState("Jumping") 
                    end
                end 
            end) 
        end 
    end
})

CharTab:CreateButton({
    Name = "Sit", 
    Callback = function() 
        if LocalCharacter and LocalCharacter:FindFirstChild("Humanoid") then 
            LocalCharacter.Humanoid.Sit = true 
        end 
    end
})
-- ================= Defense Tab =================
local DefTab = Window:CreateTab("🛡️ 防御", 4483345998)

DefTab:CreateSection("新アンチグラブ")

DefTab:CreateToggle({
    Name = "🆕 アンチグラブ (Creature)", 
    CurrentValue = false, 
    Flag = "AntiCreature", 
    Callback = function(v) 
        coroutineFlags.AntiGrabCreature = v
        if v then 
            executeCreatureAntiGrab(LocalCharacter) 
        end 
    end
})

DefTab:CreateToggle({
    Name = "🆕 透明アンチグラブ (Test)", 
    CurrentValue = false, 
    Flag = "AntiInvis", 
    Callback = function(v) 
        coroutineFlags.AntiGrabTestInvisible = v
        if v then 
            executeTestInvisibleAntiGrab(LocalCharacter) 
        end 
    end
})

DefTab:CreateSection("基本防御")

DefTab:CreateToggle({
    Name = "Anti Grab", 
    CurrentValue = false, 
    Flag = "AntiGrab", 
    Callback = function(v) 
        if v then 
            connections.AntiGrab = RunService.Heartbeat:Connect(function() 
                pcall(function() 
                    if LocalCharacter and LocalCharacter:FindFirstChild("Head") then
                        local head = LocalCharacter.Head
                        local owner = head:FindFirstChild("PartOwner")
                        if owner and owner.Value ~= LocalPlayer.Name then 
                            Struggle:FireServer()
                            if LocalCharacter:FindFirstChild("HumanoidRootPart") then
                                RagdollRemote:FireServer(LocalCharacter.HumanoidRootPart, 0)
                            end
                        end 
                    end
                end) 
            end) 
        else 
            if connections.AntiGrab then 
                connections.AntiGrab:Disconnect()
                connections.AntiGrab = nil
            end 
        end 
    end
})

DefTab:CreateToggle({
    Name = "Anti Fling", 
    CurrentValue = false, 
    Flag = "AntiFling", 
    Callback = function(v) 
        if v then 
            connections.AntiFling = RunService.Heartbeat:Connect(function() 
                pcall(function() 
                    Struggle:FireServer()
                    if LocalCharacter and LocalCharacter:FindFirstChild("HumanoidRootPart") then
                        RagdollRemote:FireServer(LocalCharacter.HumanoidRootPart, 0)
                    end
                    if ReplicatedStorage:FindFirstChild("GameCorrectionEvents") then 
                        local stopVel = ReplicatedStorage.GameCorrectionEvents:FindFirstChild("StopAllVelocity")
                        if stopVel then
                            stopVel:FireServer() 
                        end
                    end 
                end) 
            end) 
        else 
            if connections.AntiFling then 
                connections.AntiFling:Disconnect()
                connections.AntiFling = nil
            end 
        end 
    end
})

DefTab:CreateToggle({
    Name = "Anti Explosion", 
    CurrentValue = false, 
    Flag = "AntiExp", 
    Callback = function(v) 
        if v then 
            setupAntiExplosion(LocalCharacter)
            characterAddedConn = LocalPlayer.CharacterAdded:Connect(setupAntiExplosion) 
        else 
            if antiExplosionConnection then 
                antiExplosionConnection:Disconnect()
                antiExplosionConnection = nil
            end
            if characterAddedConn then 
                characterAddedConn:Disconnect()
                characterAddedConn = nil
            end 
        end 
    end
})

DefTab:CreateToggle({
    Name = "Anti Void", 
    CurrentValue = false, 
    Flag = "AntiVoid", 
    Callback = function(v) 
        if v then 
            workspace.FallenPartsDestroyHeight = 0/0
            connections.AntiVoid = RunService.Heartbeat:Connect(function() 
                if LocalCharacter and LocalCharacter:FindFirstChild("HumanoidRootPart") then
                    if LocalCharacter.HumanoidRootPart.Position.Y < -500 then 
                        LocalCharacter.HumanoidRootPart.CFrame = CFrame.new(2, 10, -4)
                        Rayfield:Notify({
                            Title = "Anti Void",
                            Content = "Void回避成功！",
                            Duration = 2
                        })
                    end 
                end
            end) 
        else 
            workspace.FallenPartsDestroyHeight = -500
            if connections.AntiVoid then 
                connections.AntiVoid:Disconnect()
                connections.AntiVoid = nil
            end 
        end 
    end
})

DefTab:CreateToggle({
    Name = "Anti Lag (Block Look)", 
    CurrentValue = false, 
    Flag = "AntiLag", 
    Callback = function(v) 
        antiLagLookEnabled = v
        if v then
            Rayfield:Notify({
                Title = "Anti Lag",
                Content = "Look:FireServerブロック有効",
                Duration = 2
            })
        end
    end
})

-- ================= Line Tab (Delta-Time対応) =================
local LineTab = Window:CreateTab("📏 Line", 4483345998)

LineTab:CreateButton({
    Name = "🌈 Rainbow", 
    Callback = function() 
        UpdateLineColors(CreateRainbowSequence()) 
    end
})

LineTab:CreateToggle({
    Name = "Random Line (Loop)", 
    CurrentValue = false, 
    Flag = "RandLine", 
    Callback = function(v) 
        randomLineEnabled = v
        if v then 
            local accumulatedTime = 0
            local updateInterval = 0.05
            
            local connection
            connection = RunService.Heartbeat:Connect(function()
                if not randomLineEnabled then
                    connection:Disconnect()
                    return
                end
                
                accumulatedTime = accumulatedTime + deltaTime
                if accumulatedTime >= updateInterval then
                    accumulatedTime = 0
                    UpdateLineColors(CreateSolidSequence(Color3.fromHSV(math.random(), 1, 1)))
                end
            end)
        end 
    end
})

LineTab:CreateToggle({
    Name = "Gradient Random (Loop)", 
    CurrentValue = false, 
    Flag = "GradLine", 
    Callback = function(v) 
        gradientRandomEnabled = v
        if v then 
            local accumulatedTime = 0
            local updateInterval = 0.5
            
            local connection
            connection = RunService.Heartbeat:Connect(function()
                if not gradientRandomEnabled then
                    connection:Disconnect()
                    return
                end
                
                accumulatedTime = accumulatedTime + deltaTime
                if accumulatedTime >= updateInterval then
                    accumulatedTime = 0
                    UpdateLineColors(CreateBrightRandomGradient(math.random(3, 10)))
                end
            end)
        end 
    end
})

LineTab:CreateSection("プリセット")

for k, c in pairs(presets) do 
    LineTab:CreateButton({
        Name = k, 
        Callback = function() 
            UpdateLineColors(CreateSolidSequence(c[1])) 
        end
    }) 
end

LineTab:CreateSection("Line Lag")

LineTab:CreateSlider({
    Name = "Lag Speed", 
    Range = {0.01, 0.5}, 
    Increment = 0.01, 
    CurrentValue = 0.05, 
    Flag = "LagSpd", 
    Callback = function(v) 
        lineLagSpeed = v 
    end
})

LineTab:CreateToggle({
    Name = "Line Lag All", 
    CurrentValue = false, 
    Flag = "LineLagAll", 
    Callback = function(v) 
        lineLagEnabled = v
        lineLagAllEnabled = v
        
        if v then 
            local accumulatedTime = 0
            
            local connection
            connection = RunService.Heartbeat:Connect(function()
                if not lineLagEnabled or not lineLagAllEnabled then
                    connection:Disconnect()
                    return
                end
                
                accumulatedTime = accumulatedTime + deltaTime
                if accumulatedTime >= lineLagSpeed then
                    accumulatedTime = 0
                    
                    for _, p in pairs(Players:GetPlayers()) do 
                        if p ~= LocalPlayer then 
                            CreateLineLag(p)
                        end 
                    end
                end
            end)
        end 
    end
})

-- ================= TP Tab =================
local TPTab = Window:CreateTab("🌐 TP", 4483345998)

local teleportLocations = {
    ["スポーン"] = Vector3.new(2, -7, -4), 
    ["黄色い家"] = Vector3.new(-492, -7, -164),
    ["緑の家"] = Vector3.new(-532, -7, 95), 
    ["紫の家"] = Vector3.new(255, -7, 465),
    ["中華風の家"] = Vector3.new(558, 123, -76), 
    ["青い家"] = Vector3.new(511, 83, -344),
    ["大きな家"] = Vector3.new(-244, 80, 293), 
    ["農場"] = Vector3.new(-197, 59, -285),
    ["雪山"] = Vector3.new(-433, 230, 516), 
    ["山"] = Vector3.new(394, 163, 278), 
    ["浮島"] = Vector3.new(71, 346, 330)
}

for n, p in pairs(teleportLocations) do 
    TPTab:CreateButton({
        Name = n, 
        Callback = function() 
            if LocalCharacter and LocalCharacter:FindFirstChild("HumanoidRootPart") then 
                LocalCharacter.HumanoidRootPart.CFrame = CFrame.new(p) 
            end 
        end
    }) 
end

-- ================= Visual Tab =================
local VisTab = Window:CreateTab("👁️ ビジュアル", 4483345998)

VisTab:CreateToggle({
    Name = "フルブライト", 
    CurrentValue = false, 
    Flag = "FB", 
    Callback = function(v) 
        if v then 
            Lighting.Brightness = 2
            Lighting.ClockTime = 14
            Lighting.GlobalShadows = false 
        else 
            Lighting.Brightness = 1
            Lighting.ClockTime = 12
            Lighting.GlobalShadows = true 
        end 
    end
})

VisTab:CreateSlider({
    Name = "FOV", 
    Range = {70, 120}, 
    Increment = 1, 
    CurrentValue = 70, 
    Flag = "FOV", 
    Callback = function(v) 
        workspace.CurrentCamera.FieldOfView = v 
    end
})

VisTab:CreateToggle({
    Name = "Unblur", 
    CurrentValue = false, 
    Flag = "Unblur", 
    Callback = function(v) 
        workspace.CurrentCamera.Blur.Enabled = not v 
    end
})

VisTab:CreateButton({
    Name = "雲を削除", 
    Callback = function() 
        if workspace.Terrain:FindFirstChild("Clouds") then 
            workspace.Terrain.Clouds:Destroy() 
        end 
    end
})

VisTab:CreateSection("時間")

VisTab:CreateButton({Name = "昼", Callback = function() Lighting.ClockTime = 10 end})
VisTab:CreateButton({Name = "夜", Callback = function() Lighting.ClockTime = 0 end})
VisTab:CreateButton({Name = "朝", Callback = function() Lighting.ClockTime = 6 end})
VisTab:CreateButton({Name = "夕方", Callback = function() Lighting.ClockTime = 18 end})

-- ================= Fun Tab =================
local FunTab = Window:CreateTab("🎮 Fun", 4483345998)

FunTab:CreateToggle({
    Name = "Ragdoll (Loop)", 
    CurrentValue = false, 
    Flag = "Ragdoll", 
    Callback = function(v) 
        if v then 
            connections.Ragdoll = RunService.Heartbeat:Connect(function() 
                if LocalCharacter and LocalCharacter:FindFirstChild("HumanoidRootPart") then 
                    RagdollRemote:FireServer(LocalCharacter.HumanoidRootPart, 0) 
                end 
            end) 
        else 
            if connections.Ragdoll then 
                connections.Ragdoll:Disconnect()
                connections.Ragdoll = nil
            end 
        end 
    end
})

-- ================= Bind Tab =================
local BindTab = Window:CreateTab("⌨️ バインド", 4483345998)

local clickBurn, clickKill = false, false

BindTab:CreateToggle({
    Name = "Burn (有効化)", 
    CurrentValue = false, 
    Flag = "ClickBurn", 
    Callback = function(v) 
        clickBurn = v
        if v then 
            spawnItem("Campfire", Vector3.new(-72.9, -5.9, -265.5)) 
        end 
    end
})

BindTab:CreateKeybind({
    Name = "Bind Burn (V)",
    CurrentKeybind = "V",
    HoldToInteract = false,
    Flag = "BindBurnKey",
    Callback = function()
        if clickBurn then
            local t = LocalPlayer:GetMouse().Target
            if t and t.Parent and t.Parent:FindFirstChild("Head") then 
                burn(t.Parent.Head) 
            end
        end
    end,
})

BindTab:CreateToggle({
    Name = "Kill (有効化)", 
    CurrentValue = false, 
    Flag = "ClickKill", 
    Callback = function(v) 
        clickKill = v 
    end
})

BindTab:CreateKeybind({
    Name = "Bind Kill (X)",
    CurrentKeybind = "X",
    HoldToInteract = false,
    Flag = "BindKillKey",
    Callback = function()
        if clickKill then
            local t = LocalPlayer:GetMouse().Target
            if t and t.Parent and t.Parent:FindFirstChild("Humanoid") then 
                local player = Players:GetPlayerFromCharacter(t.Parent)
                if player then
                    kill(player.Name) 
                end
            end
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
            if t.Name == "FirePlayerPart" then 
                c = t.Parent.Parent 
            end
            
            if c:IsA("Model") and c:FindFirstChildOfClass("Humanoid") then
                pcall(function()
                    local hrp = c:FindFirstChild("HumanoidRootPart")
                    local torso = c:FindFirstChild("Torso")
                    
                    if hrp and torso then
                        SetNetworkOwner:FireServer(hrp, hrp.CFrame)
                        
                        local bv = Instance.new("BodyVelocity", torso)
                        bv.Velocity = Vector3.new(0, -4, 0)
                        bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                        
                        for _, p in ipairs(c:GetDescendants()) do 
                            if p:IsA("BasePart") then 
                                p.CanCollide = false 
                            end 
                        end
                    end
                end)
            end
        end
    end,
})

-- ================= Script Tab =================
local ScriptTab = Window:CreateTab("📜 スクリプト", 4483345998)

ScriptTab:CreateButton({
    Name = "Infinite Yield", 
    Callback = function() 
        loadstring(game:HttpGet("https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source"))() 
    end
})

ScriptTab:CreateButton({
    Name = "Dex Explorer v2", 
    Callback = function() 
        loadstring(game:HttpGet("https://raw.githubusercontent.com/MariyaFurmanova/Library/main/dex2.0", true))() 
    end
})

ScriptTab:CreateButton({
    Name = "SystemBroken", 
    Callback = function() 
        loadstring(game:HttpGet("https://raw.githubusercontent.com/H20CalibreYT/SystemBroken/main/script"))() 
    end
})

ScriptTab:CreateButton({
    Name = "Float", 
    Callback = function() 
        loadstring(game:HttpGet("https://raw.githubusercontent.com/GhostPlayer352/Test4/main/Float"))() 
    end
})

ScriptTab:CreateButton({
    Name = "Shaders", 
    Callback = function() 
        loadstring(game:HttpGet("https://pastefy.app/xXkUxA0P/raw", true))() 
    end
})

-- ================= Settings Tab =================
local SettingsTab = Window:CreateTab("⚙️ 設定", 4483345998)

SettingsTab:CreateToggle({
    Name = "フレンド保護", 
    CurrentValue = false, 
    Flag = "Whitelist", 
    Callback = function(v) 
        whiteListEnabled = v
        if v then 
            Rayfield:Notify({
                Title = "Protected", 
                Content = "フレンドを保護中", 
                Duration = 3
            }) 
        end 
    end
})

SettingsTab:CreateButton({
    Name = "UI破棄 & クリーンアップ", 
    Callback = function() 
        cleanupESP()
        for _, c in pairs(connections) do 
            if c then 
                pcall(function() c:Disconnect() end)
            end 
        end
        Rayfield:Destroy() 
    end
})

SettingsTab:CreateSection("情報")

SettingsTab:CreateLabel("バージョン: v10.1 Delta-Time Edition")
SettingsTab:CreateLabel("✅ フレームレート非依存システム")
SettingsTab:CreateLabel("🔧 全ループをDelta-Time対応化")
SettingsTab:CreateLabel("⚡ 滑らかな動作・最適化済み")
SettingsTab:CreateLabel("🎯 60FPS/144FPS/240FPS対応")

-- ================= プレイヤーリスト更新 =================
Players.PlayerAdded:Connect(function() 
    if TargetDropdown then 
        TargetDropdown:Refresh(TargetPlayersDropdown(), true) 
    end 
    if LeftDrop then 
        LeftDrop:Refresh(TargetPlayersDropdown(), true) 
    end
    if RightDrop then 
        RightDrop:Refresh(TargetPlayersDropdown(), true) 
    end
    if DuoDrop then 
        DuoDrop:Refresh(TargetPlayersDropdown(), true) 
    end
end)

Players.PlayerRemoving:Connect(function() 
    if TargetDropdown then 
        TargetDropdown:Refresh(TargetPlayersDropdown(), true) 
    end 
    if LeftDrop then 
        LeftDrop:Refresh(TargetPlayersDropdown(), true) 
    end
    if RightDrop then 
        RightDrop:Refresh(TargetPlayersDropdown(), true) 
    end
    if DuoDrop then 
        DuoDrop:Refresh(TargetPlayersDropdown(), true) 
    end
end)

-- ================= 初期化完了通知 =================
Rayfield:Notify({
    Title = "FTAP Rayfield Edition",
    Content = "v10.1 Delta-Time Fixed - ロード完了！",
    Duration = 5,
    Image = 4483345998,
})

print("========================================")
print("FTAP v10.1 Delta-Time Edition Loaded!")
print("Delta-Time System: Active")
print("Frame-Rate Independent: TRUE")
print("All loops optimized for smooth performance")
print("========================================")
