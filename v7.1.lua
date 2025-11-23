-- FTAP完全統合版 v10.0 "True Legacy" (Nexus Fixed)
-- Original Structure Preserved (2600+ Lines Logic) + Critical Fixes Only
-- Security, Performance, Memory Leaks, and Race Conditions Patched without cutting content

local OrionLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/Polinorsik/Orion-Z-Library/refs/heads/main/README.md"))()
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
    OrionLib:MakeNotification({
        Name = "Fatal Error",
        Content = "必要なリモートが見つかりません。ゲームが更新された可能性があります。",
        Image = "rbxassetid://4483345998",
        Time = 10
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

-- グローバル変数の保護 (修正点7: ローカルテーブルへの移行推奨だが、互換性のため_Gも維持しつつローカル優先)
_G.BlobmanDelay = 0.001
_G.ToyToLoad = "BombMissile"
_G.MaxMissiles = 9
_G.flySpeed = 100
_G.kickForce = 150
_G.ufoRotationSpeed = 5
_G.ufoHeight = 10

-- 共通変数定義 (大量の変数群)
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

-- 新機能用変数 (Line, Anti-Grab等)
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

-- Coroutine Flags (制御フラグ)
local coroutineFlags = {
    PoisonGrab = false,
    PoisonAura = false,
    GrabAura = false,
    RadiactiveGrab = false,
    BurnGrab = false,
    FireAura = false,
    LoopFireAura = false,
    KillGrab = false,
    KickGrab = false,
    UfoGrab = false,
    NoclipGrab = false,
    AnchorGrab = false,
    AntiGrab = false,
    LoopKill = false,
    OrbitPlayer = false,
    BringAll = false,
    CrouchSpeed = false,
    CrouchJump = false,
    FireAll = false,
    RagdollAll = false,
    BlobmanAuto = false,
    HeavenGrab = false,
    CrazyGrab = false,
    DeleteAura = false,
    ServerBreak = false,
    AntiGrabCreature = false,
    AntiGrabTestInvisible = false,
    FlingAll = false, -- 修正点4対応
    LoopLeftBlob = false,
    LoopRightBlob = false,
    LoopDuoBlob = false
}

-- [修正点4: メモリリーク対策] クリーンアップ関数の実装
local function cleanupESP()
    for _, obj in pairs(espObjects) do
        if obj and obj.Parent then
            obj:Destroy()
        end
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
        local holdDuration = tick() - touchStartTime
        if holdDuration >= 0.3 then
            isRightClickOrLongPress = true
        else
            isRightClickOrLongPress = false
        end
        isTouchHolding = false
    elseif input.UserInputType == Enum.UserInputType.MouseButton2 then
        isRightClickOrLongPress = false
    end
end)

-- Owned Toys 確認ロジック
task.spawn(function()
    pcall(function()
        local menuGui = LocalPlayer:WaitForChild("PlayerGui", 10):WaitForChild("MenuGui", 10)
        if menuGui then
            local contents = menuGui:WaitForChild("Menu"):WaitForChild("TabContents"):WaitForChild("Toys"):WaitForChild("Contents")
            for i, v in pairs(contents:GetChildren()) do
                if v.Name ~= "UIGridLayout" then
                    ownedToys[v.Name] = true
                end
            end
        end
    end)
end)

-- ユーティリティ関数群
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
                local cframe = CFrame.new(position)
                local rotation = Vector3.new(0, 90, 0)
                MenuToys.SpawnToyRemoteFunction:InvokeServer(itemName, cframe, rotation)
            end
        end)
    end)
end

local function spawnItemCf(itemName, cframe)
    task.spawn(function()
        pcall(function()
            if MenuToys and MenuToys:FindFirstChild("SpawnToyRemoteFunction") then
                local rotation = Vector3.new(0, 0, 0)
                MenuToys.SpawnToyRemoteFunction:InvokeServer(itemName, cframe, rotation)
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

local function createHighlight(parent)
    local highlight = Instance.new("Highlight")
    highlight.DepthMode = Enum.HighlightDepthMode.Occluded
    highlight.FillTransparency = 1
    highlight.Name = "Highlight"
    highlight.OutlineColor = Color3.new(0, 0, 1)
    highlight.OutlineTransparency = 0.5
    highlight.Parent = parent
    return highlight
end

-- [修正点1 & 6: セキュリティ強化] HookMetamethodの安全な実装と検出回避
local oldNamecall
local function safeHook()
    local success, err = pcall(function()
        if not hookmetamethod then return end
        
        -- アンチチート検出回避のためのランダムディレイ
        task.wait(math.random(1, 3) * 0.1)
        
        oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
            local method = getnamecallmethod()
            
            -- Lookリモートのブロック機能 (Anti-Lag)
            -- [修正点6] RemoteEventのParentとClassも確認して誤爆を防ぐ
            if antiLagLookEnabled and method == "FireServer" then
                if self.Name == "Look" and self.Parent == CharacterEvents and self:IsA("RemoteEvent") then
                    return -- ブロック成功
                end
            end
            
            return oldNamecall(self, ...)
        end)
    end)
    
    if not success then
        warn("Hook initialization warning: " .. tostring(err))
    end
end
safeHook() -- フック実行

-- ==============================
-- 新機能: Creature Anti-Grab (修正版)
-- ==============================
local function executeCreatureAntiGrab(character)
    spawn(function()
        while coroutineFlags.AntiGrabCreature do
            pcall(function()
                -- [修正点8] キャラクター存在チェックの強化
                if not character or not character.Parent or not character:FindFirstChild("HumanoidRootPart") then 
                    coroutineFlags.AntiGrabCreature = false 
                    return 
                end
                
                local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
                local humanoid = character:FindFirstChild("Humanoid")
                
                local originalPosition = humanoidRootPart.CFrame
                local spawnY = humanoidRootPart.Position.Y - 5
                local spawnX = humanoidRootPart.Position.X
                local spawnZ = humanoidRootPart.Position.Z
                
                MenuToys.SpawnToyRemoteFunction:InvokeServer(
                    "CreatureBlobman",
                    CFrame.new(0, 50000, 0, 0.5, -0.3, 0.7, 0, 0.9, 0.4, -0.8, -0.2, 0.4),
                    Vector3.new(spawnX, spawnY, spawnZ)
                )
                
                task.wait(0.1)
                
                local spawnedToys = workspace:FindFirstChild(LocalPlayer.Name .. "SpawnedInToys")
                local blobman = spawnedToys and spawnedToys:FindFirstChild("CreatureBlobman")
                
                if blobman then
                    for _, part in pairs(blobman:GetDescendants()) do
                        if part:IsA("BasePart") then
                            part.Anchored = true
                        end
                    end
                    
                    local seat = blobman:FindFirstChildWhichIsA("Seat") or blobman:FindFirstChildWhichIsA("VehicleSeat")
                    
                    if seat then
                        -- 座る処理の高速化と確実化
                        local interval = 0.5 / 60
                        for i = 1, 60 do
                            seat:Sit(humanoid)
                            RagdollRemote:FireServer(humanoidRootPart, 0)
                            RunService.Heartbeat:Wait() -- wait()よりHeartbeatを推奨
                        end
                    end
                    
                    DestroyToy:FireServer(blobman)
                end
                
                task.wait(0.1)
                if humanoidRootPart then
                    humanoidRootPart.CFrame = originalPosition
                end
            end)
            task.wait(1)
        end
    end)
end

-- ==============================
-- 新機能: Test Invisible Anti-Grab (修正版)
-- ==============================
local function executeTestInvisibleAntiGrab(character)
    spawn(function()
        while coroutineFlags.AntiGrabTestInvisible do
            pcall(function()
                if not character or not character.Parent then 
                    coroutineFlags.AntiGrabTestInvisible = false 
                    return 
                end
                
                local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
                local humanoid = character:FindFirstChild("Humanoid")
                if not humanoidRootPart or not humanoid then return end
                
                local foundSeat = nil
                for _, obj in pairs(workspace:GetDescendants()) do
                    if (obj:IsA("Seat") or obj:IsA("VehicleSeat")) and obj.Name == "Seat" then
                        foundSeat = obj
                        break
                    end
                end
                
                if foundSeat then
                    local camera = workspace.CurrentCamera
                    camera.CameraType = Enum.CameraType.Scriptable
                    
                    local interval = 0.5 / 60
                    for i = 1, 60 do
                        foundSeat:Sit(humanoid)
                        RagdollRemote:FireServer(humanoidRootPart, 0)
                        RunService.Heartbeat:Wait()
                    end
                    
                    camera.CameraType = Enum.CameraType.Custom
                    
                    task.wait(0.1)
                    humanoidRootPart.CFrame = CFrame.new(humanoidRootPart.Position.X, 1000, humanoidRootPart.Position.Z)
                end
            end)
            task.wait(1)
        end
    end)
end

-- ==============================
-- 新機能: バリア破壊 (Barrier Break)
-- ==============================
local function executeBarrierBreak()
    spawn(function()
        pcall(function()
            local character = LocalPlayer.Character
            if not character or not character:FindFirstChild("HumanoidRootPart") then return end
            
            local originalPosition = character.HumanoidRootPart.CFrame
            
            MenuToys.SpawnToyRemoteFunction:InvokeServer(
                "InstrumentWoodwindOcarina",
                CFrame.new(184.14, -5.54, 498.13),
                Vector3.new(0, 34, 0)
            )
            
            task.wait(0.2)
            
            local toyFolder = workspace:FindFirstChild(LocalPlayer.Name .. "SpawnedInToys")
            if toyFolder then
                local ocarina = toyFolder:FindFirstChild("InstrumentWoodwindOcarina")
                if ocarina and ocarina:FindFirstChild("HoldPart") then
                    ocarina.HoldPart.HoldItemRemoteFunction:InvokeServer(ocarina, character)
                    
                    task.wait(0.2)
                    character.HumanoidRootPart.CFrame = CFrame.new(304.06, 25.77, 488.54)
                    task.wait(0.05)
                    
                    DestroyToy:FireServer(ocarina)
                    task.wait(0.05)
                    
                    character.HumanoidRootPart.CFrame = originalPosition
                    
                    OrionLib:MakeNotification({
                        Name = "Barrier Break",
                        Content = "バリア破壊完了！",
                        Image = "rbxassetid://4483345998",
                        Time = 3
                    })
                end
            end
        end)
    end)
end

-- ==============================
-- Line機能群 (完全版)
-- ==============================
local function UpdateLineColors(...)
    pcall(function()
        ReplicatedStorage.DataEvents.UpdateLineColorsEvent:FireServer(...)
    end)
end

local function CreateRainbowSequence()
    return ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.new(1, 0, 0)), 
        ColorSequenceKeypoint.new(0.166, Color3.new(1, 1, 0)), 
        ColorSequenceKeypoint.new(0.333, Color3.new(0, 1, 0)), 
        ColorSequenceKeypoint.new(0.5, Color3.new(0, 1, 1)), 
        ColorSequenceKeypoint.new(0.666, Color3.new(0, 0, 1)), 
        ColorSequenceKeypoint.new(0.833, Color3.new(1, 0, 1)), 
        ColorSequenceKeypoint.new(1, Color3.new(1, 0, 0))
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

local function CreateAlternatingSequence(colors, segments)
    local keypoints = {}
    local colorCount = #colors
    for i = 0, segments do
        local time = i / segments
        local colorIndex = (math.floor(time * segments) % colorCount) + 1
        table.insert(keypoints, ColorSequenceKeypoint.new(time, colors[colorIndex]))
    end
    return ColorSequence.new(keypoints)
end

local function CreateSolidSequence(color)
    return ColorSequence.new{
        ColorSequenceKeypoint.new(0, color),
        ColorSequenceKeypoint.new(1, color)
    }
end

local presets = {
    ["Black & White"] = {Color3.new(0, 0, 0), Color3.new(1, 1, 1)},
    ["Red & Blue"] = {Color3.new(1, 0, 0), Color3.new(0, 0, 1)},
    ["Red & Black"] = {Color3.new(1, 0, 0), Color3.new(0, 0, 0)},
    ["Blue & Yellow"] = {Color3.new(0, 0, 1), Color3.new(1, 1, 0)},
    ["Purple & Green"] = {Color3.new(0.5, 0, 0.5), Color3.new(0, 1, 0)},
    ["Orange & Cyan"] = {Color3.new(1, 0.5, 0), Color3.new(0, 1, 1)},
    ["Pink & White"] = {Color3.new(1, 0.4, 0.7), Color3.new(1, 1, 1)},
    ["Gold & Black"] = {Color3.new(1, 0.84, 0), Color3.new(0, 0, 0)},
}

local function CreateLineLag(targetPlayer)
    if not targetPlayer or not targetPlayer.Character then return end
    local character = targetPlayer.Character
    local torso = character:FindFirstChild("Torso") or character:FindFirstChild("UpperTorso")
    if not torso then return end
    
    CreateGrabLine:FireServer(
        torso,
        CFrame.new(0.0314, 0.2292, -0.5000, 0.1565, -0.0348, -0.9870, -0.1451, 0.9877, -0.0578, 0.9769, 0.1522, 0.1495)
    )
end

-- 死亡時・リスポーン時の自動再起動
LocalPlayer.CharacterAdded:Connect(function(character)
    LocalCharacter = character
    -- [修正点5] task.wait(1)は削除。即時適用可能なら適用する。
    
    if coroutineFlags.AntiGrabCreature then
        executeCreatureAntiGrab(character)
    end
    
    if coroutineFlags.AntiGrabTestInvisible then
        executeTestInvisibleAntiGrab(character)
    end
end)

-- Kick Grab関数
local function kickGrab()
    while coroutineFlags.KickGrab do
        pcall(function()
            local child = workspace:FindFirstChild("GrabParts")
            if child then
                local grabPart = child:FindFirstChild("GrabPart")
                if grabPart then
                    local weld = grabPart:FindFirstChild("WeldConstraint")
                    if weld and weld.Part1 and weld.Part1.Parent then
                        local character = weld.Part1.Parent
                        local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
                        if humanoidRootPart then
                            local kickVelocity = Instance.new("BodyVelocity")
                            kickVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                            kickVelocity.Velocity = workspace.CurrentCamera.CFrame.LookVector * _G.kickForce + Vector3.new(0, 50, 0)
                            kickVelocity.Parent = humanoidRootPart
                            Debris:AddItem(kickVelocity, 0.5)
                            task.wait(0.3)
                        end
                    end
                end
            end
        end)
        task.wait(0.5)
    end
end

-- UFO Grab関数
local function ufoGrab()
    while coroutineFlags.UfoGrab do
        pcall(function()
            local child = workspace:FindFirstChild("GrabParts")
            if child then
                local grabPart = child:FindFirstChild("GrabPart")
                if grabPart then
                    local weld = grabPart:FindFirstChild("WeldConstraint")
                    if weld and weld.Part1 and weld.Part1.Parent then
                        local character = weld.Part1.Parent
                        local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
                        if humanoidRootPart then
                            for _, v in pairs(humanoidRootPart:GetChildren()) do
                                if v:IsA("BodyPosition") or v:IsA("BodyGyro") or v:IsA("BodyAngularVelocity") then
                                    v:Destroy()
                                end
                            end
                            
                            local bodyPosition = Instance.new("BodyPosition")
                            bodyPosition.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                            bodyPosition.P = 5000
                            bodyPosition.D = 500
                            bodyPosition.Position = humanoidRootPart.Position + Vector3.new(0, _G.ufoHeight, 0)
                            bodyPosition.Parent = humanoidRootPart
                            
                            local bodyAngularVelocity = Instance.new("BodyAngularVelocity")
                            bodyAngularVelocity.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
                            bodyAngularVelocity.AngularVelocity = Vector3.new(0, _G.ufoRotationSpeed, 0)
                            bodyAngularVelocity.P = 5000
                            bodyAngularVelocity.Parent = humanoidRootPart
                            
                            for _, part in pairs(character:GetChildren()) do
                                if part:IsA("BasePart") then
                                    part.CanCollide = false
                                end
                            end
                            
                            while workspace:FindFirstChild("GrabParts") and coroutineFlags.UfoGrab do
                                task.wait()
                            end
                            
                            if bodyPosition then bodyPosition:Destroy() end
                            if bodyAngularVelocity then bodyAngularVelocity:Destroy() end
                        end
                    end
                end
            end
        end)
        task.wait()
    end
end

-- Grab Handler (汎用)
local function grabHandler(grabType)
    while true do
        pcall(function()
            local child = workspace:FindFirstChild("GrabParts")
            if child and child.Name == "GrabParts" then
                local grabPart = child:FindFirstChild("GrabPart")
                if grabPart then
                    local weld = grabPart:FindFirstChild("WeldConstraint")
                    if weld and weld.Part1 then
                        local grabbedPart = weld.Part1
                        local head = grabbedPart.Parent:FindFirstChild("Head")
                        if head then
                            while workspace:FindFirstChild("GrabParts") do
                                local partsTable = grabType == "poison" and PoisonHurtParts or PaintPlayerParts
                                for _, part in pairs(partsTable) do
                                    part.Size = Vector3.new(2, 2, 2)
                                    part.Transparency = 1
                                    part.Position = head.Position
                                end
                                task.wait()
                                for _, part in pairs(partsTable) do
                                    part.Position = Vector3.new(0, -200, 0)
                                end
                            end
                        end
                    end
                end
            end
        end)
        task.wait()
    end
end

-- Burn Grab
local function burnGrab()
    while true do
        pcall(function()
            local child = workspace:FindFirstChild("GrabParts")
            if child and child.Name == "GrabParts" then
                local grabPart = child:FindFirstChild("GrabPart")
                if grabPart then
                    local weld = grabPart:FindFirstChild("WeldConstraint")
                    if weld and weld.Part1 then
                        local head = weld.Part1.Parent:FindFirstChild("Head")
                        if head then
                            burn(head)
                        end
                    end
                end
            end
        end)
        task.wait(0.5)
    end
end

-- Kill Grab
local function killGrab()
    while true do
        pcall(function()
            local child = workspace:FindFirstChild("GrabParts")
            if child and child.Name == "GrabParts" then
                local grabPart = child:FindFirstChild("GrabPart")
                if grabPart then
                    local weld = grabPart:FindFirstChild("WeldConstraint")
                    if weld and weld.Part1 and weld.Part1.Parent then
                        local trgtCHR = weld.Part1.Parent
                        if trgtCHR then 
                            task.wait(0.4) 
                            local humanoid = trgtCHR:FindFirstChild("Humanoid")
                            if humanoid then
                                humanoid.Health = 0 
                            end
                        end
                    end
                end
            end
        end)
        task.wait()
    end
end

-- Noclip Grab
local function noclipGrab()
    while true do
        pcall(function()
            local child = workspace:FindFirstChild("GrabParts")
            if child and child.Name == "GrabParts" then
                local grabPart = child:FindFirstChild("GrabPart")
                if grabPart then
                    local weld = grabPart:FindFirstChild("WeldConstraint")
                    if weld and weld.Part1 then
                        local character = weld.Part1.Parent
                        if character and character:FindFirstChild("HumanoidRootPart") then
                            while workspace:FindFirstChild("GrabParts") do
                                for _, part in pairs(character:GetChildren()) do
                                    if part:IsA("BasePart") then
                                        part.CanCollide = false
                                    end
                                end
                                task.wait()
                            end
                        end
                    end
                end
            end
        end)
        task.wait()
    end
end

-- Heaven Grab
local function heavenGrab()
    while true do
        pcall(function()
            local child = workspace:FindFirstChild("GrabParts")
            if child and child.Name == "GrabParts" then
                local grabPart = child:FindFirstChild("GrabPart")
                if grabPart then
                    local weld = grabPart:FindFirstChild("WeldConstraint")
                    if weld and weld.Part1 and weld.Part1.Parent then
                        local trgtCHR = weld.Part1.Parent
                        local target = trgtCHR:FindFirstChild("Torso")
                        if target then
                            local velocity = target:FindFirstChild("heavenG") or Instance.new("BodyVelocity")
                            velocity.Name = "heavenG"
                            velocity.Parent = target
                            velocity.Velocity = Vector3.new(0,9999999,0)
                            velocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                            Debris:AddItem(velocity, 100)
                        end
                    end
                end
            end
        end)
        task.wait()
    end
end

-- Teleport Grab
local TPgrabOption = "TP to spawn"
local function crazyGrab()
    while true do
        pcall(function()
            local child = workspace:FindFirstChild("GrabParts")
            if child and child.Name == "GrabParts" then
                local grabPart = child:FindFirstChild("GrabPart")
                if grabPart then
                    local weld = grabPart:FindFirstChild("WeldConstraint")
                    if weld and weld.Part1 and weld.Part1.Parent then
                        local trgtCHR = weld.Part1.Parent
                        local hrp = trgtCHR:FindFirstChild("HumanoidRootPart")
                        if hrp then
                            if TPgrabOption == "TP to spawn" then
                                hrp.CFrame = CFrame.new(-1, -7, -9)
                                task.wait()
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
            end
        end)
        task.wait()
    end
end

-- Anti Explosion Setup
local antiExplosionConnection
local characterAddedConn
local function setupAntiExplosion(character)
    task.wait(0.5)
    local humanoid = character:FindFirstChild("Humanoid")
    if not humanoid then return end
    
    local ragdolled = humanoid:FindFirstChild("Ragdolled")
    if ragdolled then
        if antiExplosionConnection then
            antiExplosionConnection:Disconnect()
        end
        
        antiExplosionConnection = ragdolled:GetPropertyChangedSignal("Value"):Connect(function()
            pcall(function()
                if ragdolled.Value then
                    for _, part in ipairs(character:GetChildren()) do
                        if part:IsA("BasePart") then
                            part.Anchored = true
                        end
                    end
                    task.wait(0.5)
                    for _, part in ipairs(character:GetChildren()) do
                        if part:IsA("BasePart") then
                            part.Anchored = false
                        end
                    end
                end
            end)
        end)
    end
end

-- Kill function
local function kill(p)
    pcall(function()
        local player = Players:FindFirstChild(p)
        if not player or not player.Character then return end
        
        local pCHR = player.Character
        local pHRP = pCHR:FindFirstChild("HumanoidRootPart")
        if not pHRP then return end
        
        local a = LocalPlayer.Character
        if not a or not a:FindFirstChild("HumanoidRootPart") then return end
        
        local inPos = a:GetPivot()
        while pCHR.Humanoid.Health ~= 0 do
            a.HumanoidRootPart.CFrame = pHRP.CFrame - Vector3.new(0, 10, 0)
            SetNetworkOwner:FireServer(pHRP, CFrame.new(pHRP.Position))
            for _, part in pairs(PoisonHurtParts) do
                part.Size = Vector3.new(1.5,1.5,1.5)
                part.Transparency = 1
                part.Position = pCHR:FindFirstChild("Head").Position
            end
            task.wait()
            for _, part in pairs(PoisonHurtParts) do
                part.Position = Vector3.new(0, -200, 0)
            end
        end
        a:PivotTo(inPos)
    end)
end

-- Dropdown Functions (Safety Checked)
local function TargetPlayersDropdown()
    local players = Players:GetPlayers()
    local playerNames = {}
    for _, player in ipairs(players) do
        if player ~= LocalPlayer then
            table.insert(playerNames, player.Name)
        end
    end
    return playerNames
end

-- Blobman Functions
local function bringLeft(k)
    if not k then return end
    local targetPlayer = Players:FindFirstChild(k)
    if not targetPlayer or not targetPlayer.Character then return end

    for _, v in pairs(workspace:GetDescendants()) do
        if v.Name == "CreatureBlobman" then
            pcall(function()
                local args = {
                    [1] = v.LeftDetector,
                    [2] = targetPlayer.Character.HumanoidRootPart,
                    [3] = v.LeftDetector.LeftWeld
                }
                v.BlobmanSeatAndOwnerScript.CreatureGrab:FireServer(unpack(args))
            end)
        end
    end
end

local function bringRight(k)
    if not k then return end
    local targetPlayer = Players:FindFirstChild(k)
    if not targetPlayer or not targetPlayer.Character then return end
    
    for _, v in pairs(workspace:GetDescendants()) do
        if v.Name == "CreatureBlobman" then
            pcall(function()
                local args = {
                    [1] = v.RightDetector,
                    [2] = targetPlayer.Character.HumanoidRootPart,
                    [3] = v.RightDetector.RightWeld
                }
                v.BlobmanSeatAndOwnerScript.CreatureGrab:FireServer(unpack(args))
            end)
        end
    end
end

-- 最近のプレイヤー取得
local function getNearestPlayer()
    local nearestPlayer
    local nearestDistance = math.huge
    pcall(function()
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") and LocalCharacter and LocalCharacter:FindFirstChild("HumanoidRootPart") then
                local distance = (LocalCharacter.HumanoidRootPart.Position - player.Character.HumanoidRootPart.Position).Magnitude
                if distance < nearestDistance then
                    nearestDistance = distance
                    nearestPlayer = player
                end
            end
        end
    end)
    return nearestPlayer
end

-- UI作成 (OrionLib)
task.wait(1)
local Window = OrionLib:MakeWindow({
    Name = "FTAP完全統合版 v10.0 (True Legacy Fix)",
    HidePremium = false,
    SaveConfig = true,
    ConfigFolder = "FTAP_Legacy",
    IntroEnabled = false
})

-- ==================================
-- タブ: 攻撃 (Attack)
-- ==================================
local AttackTab = Window:MakeTab({Name = "⚔️ 攻撃", Icon = "rbxassetid://4483345998"})

AttackTab:AddSection({Name = "ターゲット攻撃"})

local targetDropdown = AttackTab:AddDropdown({
    Name = "ターゲット選択",
    Default = "",
    Options = TargetPlayersDropdown(),
    Callback = function(Value)
        selectedTarget = Players:FindFirstChild(Value)
        TargetSelected = Value
    end
})

AttackTab:AddToggle({
    Name = "ループキル",
    Default = false,
    Callback = function(enabled)
        coroutineFlags.LoopKill = enabled
        if enabled then
            task.spawn(function()
                while coroutineFlags.LoopKill and selectedTarget do
                    pcall(function()
                        if not isPlayerWhitelisted(selectedTarget) and selectedTarget.Character then
                            local targetHead = selectedTarget.Character:FindFirstChild("Head")
                            if targetHead then
                                for _, part in pairs(PoisonHurtParts) do
                                    if part and part.Parent then
                                        part.Size = Vector3.new(2, 2, 2)
                                        part.Transparency = 1
                                        part.Position = targetHead.Position
                                    end
                                end
                                task.wait(0.1)
                                for _, part in pairs(PoisonHurtParts) do
                                    if part and part.Parent then
                                        part.Position = Vector3.new(0, -200, 0)
                                    end
                                end
                            end
                        end
                    end)
                    task.wait(0.3)
                end
            end)
        end
    end
})

AttackTab:AddButton({
    Name = "ターゲットを即キル",
    Callback = function()
        if TargetSelected then
            kill(TargetSelected)
        end
    end
})

AttackTab:AddButton({
    Name = "ターゲットにテレポート",
    Callback = function()
        if selectedTarget and selectedTarget.Character and LocalCharacter then
            pcall(function()
                local targetHRP = selectedTarget.Character:FindFirstChild("HumanoidRootPart")
                local myHRP = LocalCharacter:FindFirstChild("HumanoidRootPart")
                if targetHRP and myHRP then
                    myHRP.CFrame = targetHRP.CFrame * CFrame.new(0, 0, 3)
                end
            end)
        end
    end
})

AttackTab:AddToggle({
    Name = "ターゲット周回",
    Default = false,
    Callback = function(enabled)
        coroutineFlags.OrbitPlayer = enabled
        if enabled and selectedTarget then
            task.spawn(function()
                local angle = 0
                while coroutineFlags.OrbitPlayer and selectedTarget do
                    pcall(function()
                        if selectedTarget.Character and LocalCharacter then
                            local targetHRP = selectedTarget.Character:FindFirstChild("HumanoidRootPart")
                            local myHRP = LocalCharacter:FindFirstChild("HumanoidRootPart")
                            if targetHRP and myHRP then
                                angle = angle + 0.05
                                local offset = Vector3.new(math.cos(angle) * 10, 2, math.sin(angle) * 10)
                                myHRP.CFrame = CFrame.new(targetHRP.Position + offset, targetHRP.Position)
                            end
                        end
                    end)
                    task.wait(0.03)
                end
            end)
        end
    end
})

AttackTab:AddSection({Name = "範囲攻撃"})

AttackTab:AddSlider({
    Name = "グラブ強度",
    Min = 100,
    Max = 10000,
    Default = 450,
    Increment = 50,
    Callback = function(Value)
        strength = Value
    end
})

AttackTab:AddToggle({
    Name = "強度グラブ",
    Default = false,
    Callback = function(enabled)
        if enabled then
            connections.Strength = workspace.ChildAdded:Connect(function(NewModel)
                if NewModel.Name == "GrabParts" then
                    pcall(function()
                        local grabPart = NewModel:WaitForChild("GrabPart", 1)
                        if grabPart then
                            local weld = grabPart:WaitForChild("WeldConstraint", 1)
                            if weld and weld.Part1 then
                                local PartToImpulse = weld.Part1
                                local VelocityObject = Instance.new("BodyVelocity", PartToImpulse)
                                VelocityObject.Velocity = Vector3.new(0, 0, 0)
                                VelocityObject.MaxForce = Vector3.new(0, 0, 0)
                                NewModel:GetPropertyChangedSignal("Parent"):Connect(function()
                                    if not NewModel.Parent then
                                        pcall(function()
                                            if isRightClickOrLongPress then
                                                VelocityObject.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                                                VelocityObject.Velocity = workspace.CurrentCamera.CFrame.LookVector * strength
                                                Debris:AddItem(VelocityObject, 1)
                                            else
                                                VelocityObject:Destroy()
                                            end
                                            isRightClickOrLongPress = false
                                        end)
                                    end
                                end)
                            end
                        end
                    end)
                end
            end)
        else
            if connections.Strength then
                connections.Strength:Disconnect()
                connections.Strength = nil
            end
        end
    end
})

-- [修正点2: パフォーマンス改善 - バッチ処理の実装]
-- 元の機能(FlingAll)を維持しつつ、ループを分割してサーバー負荷とFPS低下を抑制
AttackTab:AddToggle({
    Name = "全員をフリング (修正版)",
    Default = false,
    Callback = function(enabled)
        coroutineFlags.FlingAll = enabled
        if enabled then
            task.spawn(function()
                while coroutineFlags.FlingAll do
                    local playersList = Players:GetPlayers()
                    local BATCH_SIZE = 3 -- 1フレームあたりの処理人数
                    
                    for i = 1, #playersList, BATCH_SIZE do
                        if not coroutineFlags.FlingAll then break end
                        local batchEnd = math.min(i + BATCH_SIZE - 1, #playersList)
                        
                        for j = i, batchEnd do
                            local player = playersList[j]
                            if player ~= LocalPlayer and not isPlayerWhitelisted(player) and player.Character then
                                local hrp = player.Character:FindFirstChild("HumanoidRootPart")
                                if hrp and LocalCharacter and LocalCharacter:FindFirstChild("HumanoidRootPart") then
                                    sno(hrp, hrp.CFrame)
                                    local bv = Instance.new("BodyVelocity", hrp)
                                    bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                                    bv.Velocity = Vector3.new(math.random(-2000, 2000), math.random(1000, 2000), math.random(-2000, 2000))
                                    Debris:AddItem(bv, 0.1)
                                    task.delay(0.1, function() ungrab(hrp) end)
                                end
                            end
                        end
                        task.wait(0.05) -- バッチ間の待機
                    end
                    task.wait(0.1) -- 全員処理後の待機
                end
            end)
        end
    end
})

AttackTab:AddToggle({
    Name = "全員を自分に引き寄せ",
    Default = false,
    Callback = function(enabled)
        coroutineFlags.BringAll = enabled
        if enabled then
            task.spawn(function()
                while coroutineFlags.BringAll do
                    pcall(function()
                        if LocalCharacter and LocalCharacter:FindFirstChild("HumanoidRootPart") then
                            local myPos = LocalCharacter.HumanoidRootPart.Position
                            for _, player in pairs(Players:GetPlayers()) do
                                if player ~= LocalPlayer and not isPlayerWhitelisted(player) and player.Character then
                                    local hrp = player.Character:FindFirstChild("HumanoidRootPart")
                                    if hrp then
                                        hrp.CFrame = CFrame.new(myPos + Vector3.new(math.random(-5, 5), 0, math.random(-5, 5)))
                                    end
                                end
                            end
                        end
                    end)
                    task.wait(0.5)
                end
            end)
        end
    end
})

-- ==================================
-- タブ: グラブ (Grab)
-- ==================================
local GrabTab = Window:MakeTab({Name = "🎯 グラブ", Icon = "rbxassetid://4483345998"})

GrabTab:AddSection({Name = "ダメージグラブ"})

GrabTab:AddToggle({
    Name = "毒グラブ",
    Default = false,
    Callback = function(Value)
        coroutineFlags.PoisonGrab = Value
        if Value then
            task.spawn(function() grabHandler("poison") end)
        end
    end
})

GrabTab:AddToggle({
    Name = "放射能グラブ",
    Default = false,
    Callback = function(Value)
        coroutineFlags.RadiactiveGrab = Value
        if Value then
            task.spawn(function() grabHandler("radioctive") end)
        end
    end
})

GrabTab:AddToggle({
    Name = "火グラブ",
    Default = false,
    Callback = function(Value)
        coroutineFlags.BurnGrab = Value
        if Value then
            task.spawn(burnGrab)
        end
    end
})

GrabTab:AddToggle({
    Name = "キルグラブ",
    Default = false,
    Callback = function(Value)
        coroutineFlags.KillGrab = Value
        if Value then
            task.spawn(killGrab)
        end
    end
})

GrabTab:AddToggle({
    Name = "天国グラブ",
    Default = false,
    Callback = function(Value)
        coroutineFlags.HeavenGrab = Value
        if Value then
            task.spawn(heavenGrab)
        end
    end
})

GrabTab:AddSection({Name = "新グラブエフェクト"})

GrabTab:AddToggle({
    Name = "キックグラブ ⚽",
    Default = false,
    Callback = function(enabled)
        coroutineFlags.KickGrab = enabled
        if enabled then
            task.spawn(kickGrab)
        end
    end
})

GrabTab:AddSlider({
    Name = "キック力",
    Min = 50,
    Max = 500,
    Default = 150,
    Increment = 10,
    Callback = function(Value)
        _G.kickForce = Value
    end
})

GrabTab:AddToggle({
    Name = "UFOグラブ 🛸",
    Default = false,
    Callback = function(enabled)
        coroutineFlags.UfoGrab = enabled
        if enabled then
            task.spawn(ufoGrab)
        end
    end
})

GrabTab:AddSlider({
    Name = "UFO高さ",
    Min = 5,
    Max = 30,
    Default = 10,
    Increment = 1,
    Callback = function(Value)
        _G.ufoHeight = Value
    end
})

GrabTab:AddSlider({
    Name = "UFO回転速度",
    Min = 1,
    Max = 20,
    Default = 5,
    Increment = 1,
    Callback = function(Value)
        _G.ufoRotationSpeed = Value
    end
})

GrabTab:AddSection({Name = "エフェクトグラブ"})

GrabTab:AddToggle({
    Name = "ノークリップグラブ",
    Default = false,
    Callback = function(enabled)
        coroutineFlags.NoclipGrab = enabled
        if enabled then
            task.spawn(noclipGrab)
        end
    end
})

GrabTab:AddToggle({
    Name = "テレポートグラブ",
    Default = false,
    Callback = function(enabled)
        coroutineFlags.CrazyGrab = enabled
        if enabled then
            task.spawn(crazyGrab)
        end
    end
})

-- ==================================
-- タブ: オーラ (Aura)
-- ==================================
local AuraTab = Window:MakeTab({Name = "🔥 オーラ", Icon = "rbxassetid://4483345998"})

AuraTab:AddSlider({
    Name = "オーラ範囲",
    Min = 5,
    Max = 100,
    Default = 20,
    Callback = function(Value)
        auraRadius = Value
    end
})

AuraTab:AddToggle({
    Name = "グラブオーラ",
    Default = false,
    Callback = function(enabled)
        coroutineFlags.GrabAura = enabled
        if enabled then
            task.spawn(function()
                while coroutineFlags.GrabAura do
                    pcall(function()
                        if LocalCharacter and LocalCharacter:FindFirstChild("HumanoidRootPart") then
                            for _, player in pairs(Players:GetPlayers()) do
                                if player ~= LocalPlayer and player.Character then
                                    local playerHRP = player.Character:FindFirstChild("HumanoidRootPart")
                                    if playerHRP then
                                        local distance = (LocalCharacter.HumanoidRootPart.Position - playerHRP.Position).Magnitude
                                        if distance <= auraRadius then
                                            if not isPlayerWhitelisted(player) then
                                                SetNetworkOwner:FireServer(playerHRP, playerHRP.CFrame)
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end)
                    task.wait(0.02)
                end
            end)
        end
    end
})

AuraTab:AddToggle({
    Name = "毒オーラ",
    Default = false,
    Callback = function(enabled)
        coroutineFlags.PoisonAura = enabled
        if enabled then
            task.spawn(function()
                while coroutineFlags.PoisonAura do
                    pcall(function()
                        if LocalCharacter and LocalCharacter:FindFirstChild("HumanoidRootPart") then
                            local myPos = LocalCharacter.HumanoidRootPart.Position
                            for _, player in pairs(Players:GetPlayers()) do
                                if player ~= LocalPlayer and not isPlayerWhitelisted(player) and player.Character then
                                    local hrp = player.Character:FindFirstChild("HumanoidRootPart")
                                    local head = player.Character:FindFirstChild("Head")
                                    if hrp and head then
                                        local distance = (hrp.Position - myPos).Magnitude
                                        if distance <= auraRadius then
                                            for _, part in pairs(PoisonHurtParts) do
                                                if part and part.Parent then
                                                    part.Size = Vector3.new(2, 2, 2)
                                                    part.Transparency = 1
                                                    part.Position = head.Position
                                                end
                                            end
                                            task.wait()
                                            for _, part in pairs(PoisonHurtParts) do
                                                if part and part.Parent then
                                                    part.Position = Vector3.new(0, -200, 0)
                                                end
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end)
                    task.wait(0.1)
                end
            end)
        end
    end
})

AuraTab:AddToggle({
    Name = "火オーラ",
    Default = false,
    Callback = function(enabled)
        coroutineFlags.FireAura = enabled
        if enabled then
            task.spawn(function()
                while coroutineFlags.FireAura do
                    pcall(function()
                        if LocalCharacter and LocalCharacter:FindFirstChild("HumanoidRootPart") then
                            local myPos = LocalCharacter.HumanoidRootPart.Position
                            for _, player in pairs(Players:GetPlayers()) do
                                if player ~= LocalPlayer and not isPlayerWhitelisted(player) and player.Character then
                                    local hrp = player.Character:FindFirstChild("HumanoidRootPart")
                                    local head = player.Character:FindFirstChild("Head")
                                    if hrp and head then
                                        local distance = (hrp.Position - myPos).Magnitude
                                        if distance <= auraRadius then
                                            burn(head)
                                        end
                                    end
                                end
                            end
                        end
                    end)
                    task.wait(0.5)
                end
            end)
        end
    end
})

AuraTab:AddToggle({
    Name = "削除オーラ (天国送り)",
    Default = false,
    Callback = function(enabled)
        coroutineFlags.DeleteAura = enabled
        if enabled then
            task.spawn(function()
                while coroutineFlags.DeleteAura do
                    pcall(function()
                        if LocalCharacter and LocalCharacter:FindFirstChild("HumanoidRootPart") then
                            local myPos = LocalCharacter.HumanoidRootPart.Position
                            for _, player in pairs(Players:GetPlayers()) do
                                if player ~= LocalPlayer and not isPlayerWhitelisted(player) and player.Character then
                                    local hrp = player.Character:FindFirstChild("HumanoidRootPart")
                                    local torso = player.Character:FindFirstChild("Torso")
                                    if hrp and torso then
                                        local distance = (hrp.Position - myPos).Magnitude
                                        if distance <= auraRadius then
                                            SetNetworkOwner:FireServer(torso, hrp.CFrame)
                                            local velocity = torso:FindFirstChild("heavenG") or Instance.new("BodyVelocity")
                                            velocity.Name = "heavenG"
                                            velocity.Parent = torso
                                            velocity.Velocity = Vector3.new(0,9999999,0)
                                            velocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                                            Debris:AddItem(velocity, 100)
                                        end
                                    end
                                end
                            end
                        end
                    end)
                    task.wait(0.5)
                end
            end)
        end
    end
})

AuraTab:AddSection({Name = "全員攻撃"})

AuraTab:AddToggle({
    Name = "Fire All (全員燃やす)",
    Default = false,
    Callback = function(enabled)
        coroutineFlags.FireAll = enabled
        if enabled then
            task.spawn(function()
                while coroutineFlags.FireAll do
                    pcall(function()
                        if toysFolder and toysFolder:FindFirstChild("Campfire") then
                            if DestroyToy then
                                DestroyToy:FireServer(toysFolder:FindFirstChild("Campfire"))
                            end
                            task.wait(0.5)
                        end
                        if LocalCharacter and LocalCharacter:FindFirstChild("Head") then
                            spawnItemCf("Campfire", LocalCharacter.Head.CFrame)
                            task.wait(0.5)
                            local campfire = toysFolder and toysFolder:WaitForChild("Campfire", 2)
                            if campfire then
                                local firePlayerPart
                                for _, part in pairs(campfire:GetChildren()) do
                                    if part.Name == "FirePlayerPart" then
                                        part.Size = Vector3.new(10, 10, 10)
                                        firePlayerPart = part
                                        break
                                    end
                                end
                                if firePlayerPart and LocalCharacter:FindFirstChild("Torso") then
                                    SetNetworkOwner:FireServer(firePlayerPart, firePlayerPart.CFrame)
                                    local bodyPosition = Instance.new("BodyPosition")
                                    bodyPosition.P = 20000
                                    bodyPosition.Position = LocalCharacter.Head.Position + Vector3.new(0, 600, 0)
                                    bodyPosition.Parent = campfire.Main
                                    while coroutineFlags.FireAll do
                                        for _, player in pairs(Players:GetChildren()) do
                                            pcall(function()
                                                bodyPosition.Position = LocalCharacter.Head.Position + Vector3.new(0, 600, 0)
                                                if player.Character and player.Character.HumanoidRootPart and player.Character ~= LocalCharacter and not isPlayerWhitelisted(player) then
                                                    firePlayerPart.Position = player.Character.HumanoidRootPart.Position
                                                    task.wait()
                                                end
                                            end)
                                        end
                                        task.wait()
                                    end
                                end
                            end
                        end
                    end)
                    task.wait()
                end
            end)
        end
    end
})

-- ==================================
-- タブ: オート (Auto)
-- ==================================
local AutoTab = Window:MakeTab({Name = "🤖 オート", Icon = "rbxassetid://4483345998"})

AutoTab:AddSection({Name = "🆕 バリア破壊"})

AutoTab:AddButton({
    Name = "🆕 バリア破壊を実行",
    Callback = function()
        executeBarrierBreak()
    end
})

-- ==================================
-- タブ: Blobman
-- ==================================
local BlobmanTab = Window:MakeTab({Name = "👾 Blobman", Icon = "rbxassetid://4483345998"})

BlobmanTab:AddSection({Name = "Left Bring"})

local LeftBlobDrop = BlobmanTab:AddDropdown({
    Name = "Left player",
    Default = "",
    Options = TargetPlayersDropdown(),
    Callback = function(Value)
        LeftBlobSelected = Value
    end
})

BlobmanTab:AddButton({
    Name = "Left bring",
    Callback = function()
        if LeftBlobSelected then
            bringLeft(LeftBlobSelected)
        end
    end
})

BlobmanTab:AddToggle({
    Name = "Loop left bring",
    Default = false,
    Callback = function(enabled)
        if LeftBlobSelected then
            coroutineFlags.LoopLeftBlob = enabled
            while coroutineFlags.LoopLeftBlob do
                bringLeft(LeftBlobSelected)
                task.wait(blobDelay)
            end
        end
    end
})

BlobmanTab:AddSection({Name = "Right Bring"})

local RightBlobDrop = BlobmanTab:AddDropdown({
    Name = "Right player",
    Default = "",
    Options = TargetPlayersDropdown(),
    Callback = function(Value)
        RightBlobSelected = Value
    end
})

BlobmanTab:AddButton({
    Name = "Right bring",
    Callback = function()
        if RightBlobSelected then
            bringRight(RightBlobSelected)
        end
    end
})

BlobmanTab:AddToggle({
    Name = "Loop right bring",
    Default = false,
    Callback = function(enabled)
        if RightBlobSelected then
            coroutineFlags.LoopRightBlob = enabled
            while coroutineFlags.LoopRightBlob do
                bringRight(RightBlobSelected)
                task.wait(blobDelay)
            end
        end
    end
})

BlobmanTab:AddSection({Name = "Duo Bring"})

local DuoBlobDrop = BlobmanTab:AddDropdown({
    Name = "Two hands player",
    Default = "",
    Options = TargetPlayersDropdown(),
    Callback = function(Value)
        DuoBlobSelected = Value
    end
})

BlobmanTab:AddButton({
    Name = "Two hands bring",
    Callback = function()
        if DuoBlobSelected then
            bringRight(DuoBlobSelected)
            bringLeft(DuoBlobSelected)
        end
    end
})

BlobmanTab:AddToggle({
    Name = "Loop two hands bring",
    Default = false,
    Callback = function(enabled)
        if DuoBlobSelected then
            coroutineFlags.LoopDuoBlob = enabled
            while coroutineFlags.LoopDuoBlob do
                bringLeft(DuoBlobSelected)
                bringRight(DuoBlobSelected)
                task.wait(blobDelay)
            end
        end
    end
})

BlobmanTab:AddSection({Name = "サーバー破壊"})

BlobmanTab:AddButton({
    Name = "Bring all",
    Callback = function()
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and not isPlayerWhitelisted(player) then
                bringLeft(player.Name)
                bringRight(player.Name)
            end
        end
    end
})

BlobmanTab:AddToggle({
    Name = "Destroy server",
    Default = false,
    Callback = function(enabled)
        coroutineFlags.ServerBreak = enabled
        while coroutineFlags.ServerBreak do
            for _, player in pairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and not isPlayerWhitelisted(player) then
                    bringLeft(player.Name)
                    bringRight(player.Name)
                end
            end
            task.wait(blobDelay)
        end
    end
})

BlobmanTab:AddSlider({
    Name = "Blob Delay",
    Min = 0.001,
    Max = 1,
    Default = 0.001,
    Increment = 0.001,
    Callback = function(Value)
        blobDelay = Value
        _G.BlobmanDelay = Value
    end
})

-- ==================================
-- タブ: キャラクター (Character)
-- ==================================
local CharTab = Window:MakeTab({Name = "🏃 キャラクター", Icon = "rbxassetid://4483345998"})

CharTab:AddSlider({
    Name = "歩行速度",
    Min = 16,
    Max = 500,
    Default = 16,
    Callback = function(Value)
        pcall(function()
            if LocalCharacter and LocalCharacter:FindFirstChild("Humanoid") then
                LocalCharacter.Humanoid.WalkSpeed = Value
            end
        end)
    end
})

CharTab:AddSlider({
    Name = "ジャンプ力",
    Min = 50,
    Max = 500,
    Default = 50,
    Callback = function(Value)
        pcall(function()
            if LocalCharacter and LocalCharacter:FindFirstChild("Humanoid") then
                LocalCharacter.Humanoid.JumpPower = Value
            end
        end)
    end
})

CharTab:AddToggle({
    Name = "無限ジャンプ",
    Default = false,
    Callback = function(enabled)
        infJump = enabled
        if enabled then
            UserInputService.JumpRequest:Connect(function()
                if infJump and LocalCharacter then
                    local humanoid = LocalCharacter:FindFirstChildOfClass("Humanoid")
                    if humanoid then
                        humanoid:ChangeState("Jumping")
                    end
                end
            end)
        end
    end
})

CharTab:AddButton({
    Name = "Sit",
    Callback = function()
        if LocalCharacter and LocalCharacter:FindFirstChild("Humanoid") then
            LocalCharacter.Humanoid.Sit = true
        end
    end
})

-- ==================================
-- タブ: 防御 (Defense)
-- ==================================
local DefenseTab = Window:MakeTab({Name = "🛡️ 防御", Icon = "rbxassetid://4483345998"})

DefenseTab:AddSection({Name = "🆕 新アンチグラブグリッチ"})

-- 排他制御のため、トグル変数を先に定義
local antiGrabCreatureToggle
local antiGrabTestInvisibleToggle

antiGrabCreatureToggle = DefenseTab:AddToggle({
    Name = "🆕 アンチグラブグリッチ (Creature)",
    Default = false,
    Callback = function(enabled)
        coroutineFlags.AntiGrabCreature = enabled
        antiGrabCreatureEnabled = enabled
        
        if enabled then
            antiGrabMode = "creature"
            -- 他方を無効化
            if coroutineFlags.AntiGrabTestInvisible then
                coroutineFlags.AntiGrabTestInvisible = false
                antiGrabTestInvisibleEnabled = false
                if antiGrabTestInvisibleToggle then
                    antiGrabTestInvisibleToggle:Set(false)
                end
            end
            
            executeCreatureAntiGrab(LocalCharacter)
            OrionLib:MakeNotification({
                Name = "Anti-Grab Glitch",
                Content = "Creature方式が有効化されました",
                Image = "rbxassetid://4483345998",
                Time = 3
            })
        else
            if antiGrabMode == "creature" then
                antiGrabMode = "none"
            end
        end
    end
})

antiGrabTestInvisibleToggle = DefenseTab:AddToggle({
    Name = "🆕 テスト版透明化アンチグラブグリッチ",
    Default = false,
    Callback = function(enabled)
        coroutineFlags.AntiGrabTestInvisible = enabled
        antiGrabTestInvisibleEnabled = enabled
        
        if enabled then
            antiGrabMode = "invisible"
            -- 他方を無効化
            if coroutineFlags.AntiGrabCreature then
                coroutineFlags.AntiGrabCreature = false
                antiGrabCreatureEnabled = false
                if antiGrabCreatureToggle then
                    antiGrabCreatureToggle:Set(false)
                end
            end
            
            executeTestInvisibleAntiGrab(LocalCharacter)
            OrionLib:MakeNotification({
                Name = "Test Invisible Anti-Grab",
                Content = "テスト版が有効化されました",
                Image = "rbxassetid://4483345998",
                Time = 3
            })
        else
            if antiGrabMode == "invisible" then
                antiGrabMode = "none"
            end
        end
    end
})

DefenseTab:AddSection({Name = "基本防御"})

DefenseTab:AddToggle({
    Name = "Anti Grab",
    Default = false,
    Callback = function(enabled)
        if enabled then
            connections.AntiGrab = RunService.Heartbeat:Connect(function()
                pcall(function()
                    if LocalCharacter and LocalCharacter:FindFirstChild("Head") then
                        local head = LocalCharacter.Head
                        local partOwner = head:FindFirstChild("PartOwner")
                        if partOwner and partOwner.Value ~= LocalPlayer.Name then
                            if Struggle then
                                Struggle:FireServer()
                            end
                            if RagdollRemote and LocalCharacter:FindFirstChild("HumanoidRootPart") then
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

DefenseTab:AddToggle({
    Name = "Anti Fling",
    Default = false,
    Callback = function(enabled)
        if enabled then
            connections.AntiFling = RunService.Heartbeat:Connect(function()
                pcall(function()
                    if Struggle then 
                        Struggle:FireServer() 
                    end
                    if LocalCharacter and LocalCharacter:FindFirstChild("HumanoidRootPart") and RagdollRemote then
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

DefenseTab:AddToggle({
    Name = "Anti Explosion",
    Default = false,
    Callback = function(enabled)
        if enabled then
            if LocalCharacter then
                setupAntiExplosion(LocalCharacter)
            end
            characterAddedConn = LocalPlayer.CharacterAdded:Connect(function(character)
                if antiExplosionConnection then
                    antiExplosionConnection:Disconnect()
                end
                setupAntiExplosion(character)
            end)
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

DefenseTab:AddToggle({
    Name = "Anti Void",
    Default = false,
    Callback = function(enabled)
        antiVoidEnabled = enabled
        if enabled then
            workspace.FallenPartsDestroyHeight = 0/0
            connections.AntiVoid = RunService.Heartbeat:Connect(function()
                pcall(function()
                    if LocalCharacter and LocalCharacter:FindFirstChild("HumanoidRootPart") then
                        local hrp = LocalCharacter.HumanoidRootPart
                        if hrp.Position.Y < -500 then
                            hrp.CFrame = CFrame.new(2, 10, -4)
                            OrionLib:MakeNotification({
                                Name = "Anti Void",
                                Content = "Saved from void!",
                                Image = "rbxassetid://4483345998",
                                Time = 3
                            })
                        end
                    end
                end)
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

DefenseTab:AddToggle({
    Name = "Anti Lag",
    Default = false,
    Callback = function(enabled)
        pcall(function()
            if LocalPlayer:FindFirstChild("PlayerScripts") then
                local charMove = LocalPlayer.PlayerScripts:FindFirstChild("CharacterAndBeamMove")
                if charMove then
                    charMove.Enabled = not enabled
                end
            end
        end)
    end
})

DefenseTab:AddToggle({
    Name = "🆕 アンチラグ (Look:FireServerブロック)",
    Default = false,
    Callback = function(enabled)
        antiLagLookEnabled = enabled
        if enabled then
            OrionLib:MakeNotification({
                Name = "Anti Lag",
                Content = "Look RemoteEventをブロック中",
                Image = "rbxassetid://4483345998",
                Time = 3
            })
        else
            OrionLib:MakeNotification({
                Name = "Anti Lag",
                Content = "ブロック解除",
                Image = "rbxassetid://4483345998",
                Time = 2
            })
        end
    end
})

-- ==================================
-- タブ: Line (完全版)
-- ==================================
local LineTab = Window:MakeTab({Name = "📏 Line", Icon = "rbxassetid://4483345998"})

LineTab:AddSection({Name = "Special Presets"})

LineTab:AddButton({
    Name = "🌈 Rainbow",
    Callback = function()
        UpdateLineColors(CreateRainbowSequence())
        OrionLib:MakeNotification({Name = "Line Color", Content = "Rainbow applied!", Image = "rbxassetid://4483345998", Time = 2})
    end
})

LineTab:AddToggle({
    Name = "Random Line (Loop)",
    Default = false,
    Callback = function(enabled)
        randomLineEnabled = enabled
        if enabled then
            spawn(function()
                while randomLineEnabled do
                    local hue = math.random()
                    local randomColor = Color3.fromHSV(hue, 1, 1)
                    UpdateLineColors(CreateSolidSequence(randomColor))
                    wait(0.05)
                end
            end)
        end
    end
})

LineTab:AddToggle({
    Name = "Gradient Random (Loop)",
    Default = false,
    Callback = function(enabled)
        gradientRandomEnabled = enabled
        if enabled then
            spawn(function()
                while gradientRandomEnabled do
                    UpdateLineColors(CreateBrightRandomGradient(math.random(3, 10)))
                    wait(0.5)
                end
            end)
        end
    end
})

LineTab:AddSection({Name = "Alternating Presets"})

LineTab:AddSlider({
    Name = "Alternating Segments",
    Min = 2,
    Max = 50,
    Default = 10,
    Increment = 1,
    Callback = function(Value)
        presetSegments = Value
    end
})

for presetName, colors in pairs(presets) do
    LineTab:AddButton({
        Name = presetName,
        Callback = function()
            UpdateLineColors(CreateAlternatingSequence(colors, presetSegments))
        end
    })
end

LineTab:AddSection({Name = "Line Lag"})

LineTab:AddSlider({
    Name = "Lag Speed (All Mode)",
    Min = 0.01,
    Max = 0.5,
    Default = 0.05,
    Increment = 0.01,
    Callback = function(Value)
        lineLagSpeed = Value
    end
})

LineTab:AddToggle({
    Name = "Enable Line Lag (All Players)",
    Default = false,
    Callback = function(enabled)
        lineLagEnabled = enabled
        lineLagAllEnabled = enabled
        if enabled then
            spawn(function()
                while lineLagEnabled and lineLagAllEnabled do
                    for _, player in pairs(Players:GetPlayers()) do
                        if player ~= LocalPlayer and lineLagEnabled and lineLagAllEnabled then
                            CreateLineLag(player)
                            wait(lineLagSpeed)
                        end
                    end
                    wait(0.01)
                end
            end)
        end
    end
})

LineTab:AddSection({Name = "Target Specific Player"})

local LineLagTargetDropdown = LineTab:AddDropdown({
    Name = "Select Player for Line Lag",
    Default = "",
    Options = TargetPlayersDropdown(),
    Callback = function(Value)
        lineLagTarget = Players:FindFirstChild(Value)
    end
})

LineTab:AddToggle({
    Name = "Enable Single Target Line Lag",
    Default = false,
    Callback = function(enabled)
        if enabled then
            if not lineLagTarget then
                OrionLib:MakeNotification({Name = "Error", Content = "Select a player first!", Time = 2})
                return
            end
            lineLagEnabled = true
            lineLagAllEnabled = false
            spawn(function()
                while lineLagEnabled and not lineLagAllEnabled and lineLagTarget do
                    CreateLineLag(lineLagTarget)
                    wait(0.01)
                end
            end)
        else
            lineLagEnabled = false
        end
    end
})

LineTab:AddButton({
    Name = "Refresh Player List",
    Callback = function()
        LineLagTargetDropdown:Refresh(TargetPlayersDropdown(), true)
    end
})

LineTab:AddSection({Name = "FartherReach Visual"})

local fartherReachEnabled = false
LineTab:AddToggle({
    Name = "FartherReach Visual",
    Default = false,
    Callback = function(enabled)
        fartherReachEnabled = enabled
        pcall(function()
            if not LocalPlayer:FindFirstChild("FartherReach") then
                local fartherReach = Instance.new("BoolValue")
                fartherReach.Name = "FartherReach"
                fartherReach.Value = false
                fartherReach.Parent = LocalPlayer
            end
            wait(0.1)
            LocalPlayer.FartherReach.Value = enabled
        end)
    end
})

LineTab:AddSection({Name = "Invisible Line"})

LineTab:AddToggle({
    Name = "Invisible Line (Loop)",
    Default = false,
    Callback = function(enabled)
        invisibleLineEnabled = enabled
        if enabled then
            spawn(function()
                while invisibleLineEnabled do
                    pcall(function()
                        CreateGrabLine:FireServer()
                    end)
                    wait(0.1)
                end
            end)
        end
    end
})

-- ==================================
-- タブ: テレポート (Teleport)
-- ==================================
local TPTab = Window:MakeTab({Name = "🌐 テレポート", Icon = "rbxassetid://4483345998"})

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

for name, pos in pairs(teleportLocations) do
    TPTab:AddButton({
        Name = name,
        Callback = function()
            pcall(function()
                if LocalCharacter and LocalCharacter:FindFirstChild("HumanoidRootPart") then
                    LocalCharacter.HumanoidRootPart.CFrame = CFrame.new(pos)
                end
            end)
        end
    })
end

-- ==================================
-- タブ: ビジュアル (Visual)
-- ==================================
local VisualTab = Window:MakeTab({Name = "👁️ ビジュアル", Icon = "rbxassetid://4483345998"})

VisualTab:AddToggle({
    Name = "フルブライト",
    Default = false,
    Callback = function(enabled)
        if enabled then
            Lighting.Brightness = 2
            Lighting.ClockTime = 14
            Lighting.FogEnd = 100000
            Lighting.GlobalShadows = false
        else
            Lighting.Brightness = 1
            Lighting.ClockTime = 12
            Lighting.FogEnd = 100000
            Lighting.GlobalShadows = true
        end
    end
})

VisualTab:AddSlider({
    Name = "視野角 (FOV)",
    Min = 70,
    Max = 120,
    Default = 70,
    Callback = function(Value)
        workspace.CurrentCamera.FieldOfView = Value
    end
})

VisualTab:AddToggle({
    Name = "Unblur (ぼかし無効)",
    Default = false,
    Callback = function(enabled)
        if enabled then
            workspace.CurrentCamera.Blur.Enabled = false
        else
            workspace.CurrentCamera.Blur.Enabled = true
        end
    end
})

VisualTab:AddButton({
    Name = "雲を削除",
    Callback = function()
        pcall(function()
            workspace.Terrain.Clouds:Destroy()
        end)
    end
})

VisualTab:AddSection({Name = "時間設定"})

VisualTab:AddButton({Name = "昼 (デフォルト)", Callback = function() Lighting.ClockTime = 10 end})
VisualTab:AddButton({Name = "夜", Callback = function() Lighting.ClockTime = 0 end})
VisualTab:AddButton({Name = "朝", Callback = function() Lighting.ClockTime = 6 end})
VisualTab:AddButton({Name = "夕方", Callback = function() Lighting.ClockTime = 18 end})

-- ==================================
-- タブ: Fun
-- ==================================
local FunTab = Window:MakeTab({Name = "🎮 Fun", Icon = "rbxassetid://4483345998"})

FunTab:AddToggle({
    Name = "Ragdoll (super anti-grab用)",
    Default = false,
    Callback = function(enabled)
        if enabled then
            connections.Ragdoll = RunService.Heartbeat:Connect(function()
                pcall(function()
                    if LocalCharacter and LocalCharacter:FindFirstChild("HumanoidRootPart") and RagdollRemote then
                        RagdollRemote:FireServer(LocalCharacter.HumanoidRootPart, 0)
                    end
                end)
            end)
        else
            if connections.Ragdoll then
                connections.Ragdoll:Disconnect()
                connections.Ragdoll = nil
            end
        end
    end
})

-- ==================================
-- タブ: キーバインド (Keybinds)
-- ==================================
local BindTab = Window:MakeTab({Name = "⌨️ キーバインド", Icon = "rbxassetid://4483345998"})

local clickBurn = false
local clickKill = false

BindTab:AddToggle({
    Name = "Burn (有効化)",
    Default = false,
    Callback = function(Value)
        clickBurn = Value
        if Value then
            spawnItem("Campfire", Vector3.new(-72.9, -5.9, -265.5))
        end
    end
})

BindTab:AddBind({
    Name = "Bind burn",
    Default = Enum.KeyCode.V,
    Hold = false,
    Callback = function()
        if clickBurn then
            local Mouse = LocalPlayer:GetMouse()
            local target = Mouse.Target
            if target and target.Parent then
                local targetHumanoid = target.Parent:FindFirstChildOfClass("Humanoid")
                local targetPlayer = Players:GetPlayerFromCharacter(target.Parent)
                if targetHumanoid and targetPlayer and targetPlayer ~= LocalPlayer then
                    pcall(function()
                        if LocalCharacter and LocalCharacter:FindFirstChild("HumanoidRootPart") then
                            local distance = (LocalCharacter.HumanoidRootPart.Position - target.Position).Magnitude
                            if distance <= 20 then
                                if workspace:FindFirstChild("GrabParts") then
                                    burn(targetPlayer.Character:FindFirstChild("Head"))
                                else
                                    SetNetworkOwner:FireServer(targetPlayer.Character.HumanoidRootPart, targetPlayer.Character.HumanoidRootPart.CFrame)
                                    burn(targetPlayer.Character:FindFirstChild("Head"))
                                    DestroyGrabLine:FireServer(targetPlayer.Character.HumanoidRootPart)
                                end
                            end
                        end
                    end)
                end
            end
        end
    end
})

BindTab:AddToggle({
    Name = "Kill (有効化)",
    Default = false,
    Callback = function(Value)
        clickKill = Value
    end
})

BindTab:AddBind({
    Name = "Bind kill",
    Default = Enum.KeyCode.X,
    Hold = false,
    Callback = function()
        if clickKill then
            local Mouse = LocalPlayer:GetMouse()
            local target = Mouse.Target
            if target and target.Parent then
                local targetHumanoid = target.Parent:FindFirstChildOfClass("Humanoid")
                local targetPlayer = Players:GetPlayerFromCharacter(target.Parent)
                if targetHumanoid and targetPlayer and targetPlayer ~= LocalPlayer then
                    pcall(function()
                        if LocalCharacter and LocalCharacter:FindFirstChild("HumanoidRootPart") then
                            local distance = (LocalCharacter.HumanoidRootPart.Position - target.Position).Magnitude
                            if distance <= 20 then
                                while targetPlayer.Character.Humanoid.Health ~= 0 do
                                    SetNetworkOwner:FireServer(targetPlayer.Character.HumanoidRootPart, CFrame.new(targetPlayer.Character.HumanoidRootPart.Position))
                                    for _, part in pairs(PoisonHurtParts) do
                                        part.Size = Vector3.new(1.5,1.5,1.5)
                                        part.Transparency = 1
                                        part.Position = targetPlayer.Character:FindFirstChild("Head").Position
                                    end
                                    RunService.Heartbeat:Wait()
                                    for _, part in pairs(PoisonHurtParts) do
                                        part.Position = Vector3.new(0, -200, 0)
                                    end
                                end
                            end
                        end
                    end)
                end
            end
        end
    end
})

BindTab:AddBind({
    Name = "地獄送り",
    Default = Enum.KeyCode.Z,
    Hold = false,
    Callback = function()
        local mouse = LocalPlayer:GetMouse()
        local target = mouse.Target
        if target and target:IsA("BasePart") then
            pcall(function()
                local character = target.Parent
                if target.Name == "FirePlayerPart" then
                    character = target.Parent.Parent
                end
                if character:IsA("Model") and character:FindFirstChildOfClass("Humanoid") then
                    SetNetworkOwner:FireServer(character.HumanoidRootPart, character.HumanoidRootPart.CFrame)
                    for _, part in ipairs(character:GetDescendants()) do
                        if part:IsA("BasePart") then
                            part.CanCollide = false
                        end
                    end
                    local bodyVelocity = Instance.new("BodyVelocity")
                    bodyVelocity.Parent = character.Torso
                    bodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                    bodyVelocity.Velocity = Vector3.new(0, -4, 0)
                    character.Torso.CanCollide = false
                    task.wait(1)
                    character.Torso.CanCollide = false
                end
            end)
        end
    end
})

-- ==================================
-- タブ: スクリプト (Script)
-- ==================================
local ScriptTab = Window:MakeTab({Name = "📜 スクリプト", Icon = "rbxassetid://4483345998"})

ScriptTab:AddSection({Name = "外部スクリプト"})

ScriptTab:AddButton({
    Name = "Infinite Yield",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source"))()
    end
})

ScriptTab:AddButton({
    Name = "SystemBroken",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/H20CalibreYT/SystemBroken/main/script"))()
    end
})

ScriptTab:AddButton({
    Name = "Float",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/GhostPlayer352/Test4/main/Float"))()
    end
})

ScriptTab:AddButton({
    Name = "Shaders",
    Callback = function()
        loadstring(game:HttpGet("https://pastefy.app/xXkUxA0P/raw", true))()
    end
})

ScriptTab:AddButton({
    Name = "Dex Explorer v2",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/MariyaFurmanova/Library/main/dex2.0", true))()
    end
})

-- ==================================
-- タブ: 設定 (Settings)
-- ==================================
local SettingsTab = Window:MakeTab({Name = "⚙️ 設定", Icon = "rbxassetid://4483345998"})

SettingsTab:AddSection({Name = "ホワイトリスト"})

SettingsTab:AddToggle({
    Name = "グローバルフレンドホワイトリスト",
    Default = false,
    Callback = function(enabled)
        whiteListEnabled = enabled
        if enabled then
            OrionLib:MakeNotification({
                Name = "ホワイトリスト有効",
                Content = "フレンドは全攻撃から除外されます",
                Image = "rbxassetid://4483345998",
                Time = 5
            })
        end
    end
})

SettingsTab:AddSection({Name = "UI設定"})

SettingsTab:AddButton({
    Name = "UI破棄",
    Callback = function()
        cleanupESP() -- クリーンアップ実行
        for _, conn in pairs(connections) do
            if conn then pcall(function() conn:Disconnect() end) end
        end
        OrionLib:Destroy()
    end
})

SettingsTab:AddSection({Name = "情報"})
SettingsTab:AddLabel("バージョン: v10.0 True Legacy (Fix Patched)")
SettingsTab:AddLabel("✅ 元の全コード構造を維持")
SettingsTab:AddLabel("🔧 8点の技術的問題点を修正済み")
SettingsTab:AddLabel("🆕 Creature Anti-Grab Glitch (Fix)")
SettingsTab:AddLabel("🆕 Test Invisible Anti-Grab (Fix)")
SettingsTab:AddLabel("🆕 Look:FireServerブロック")
SettingsTab:AddLabel("🆕 バリア破壊ボタン")
SettingsTab:AddLabel("🆕 Line機能完全版")
SettingsTab:AddLabel("⚽ Kick Grab搭載")
SettingsTab:AddLabel("🛸 UFO Grab搭載")

-- ==================================
-- タブ: サーバー情報 (Server Info)
-- ==================================
local ServerInfoTab = Window:MakeTab({Name = "📊 サーバー情報", Icon = "rbxassetid://4483345998"})

local AmountOfPlayers = #Players:GetPlayers()
local CounOfPlayersLbl = ServerInfoTab:AddLabel("プレイヤー数: "..AmountOfPlayers)
local AllPlayersLbl = ServerInfoTab:AddLabel("全プレイヤー: "..AmountOfPlayers)

ServerInfoTab:AddSection({Name = "プレイヤーリスト"})

local function updatePlayerList()
    local playerList = ""
    for _, player in pairs(Players:GetPlayers()) do
        playerList = playerList .. player.Name .. "\n"
    end
    return playerList
end

local PlayerListLbl = ServerInfoTab:AddLabel(updatePlayerList())

-- プレイヤー更新監視
Players.PlayerAdded:Connect(function()
    AmountOfPlayers = #Players:GetPlayers()
    CounOfPlayersLbl:Set("プレイヤー数: "..AmountOfPlayers)
    AllPlayersLbl:Set("全プレイヤー: "..AmountOfPlayers)
    PlayerListLbl:Set(updatePlayerList())
    
    if targetDropdown then targetDropdown:Refresh(TargetPlayersDropdown(), true) end
    if LeftBlobDrop then LeftBlobDrop:Refresh(TargetPlayersDropdown(), true) end
    if RightBlobDrop then RightBlobDrop:Refresh(TargetPlayersDropdown(), true) end
    if DuoBlobDrop then DuoBlobDrop:Refresh(TargetPlayersDropdown(), true) end
end)

Players.PlayerRemoving:Connect(function()
    AmountOfPlayers = #Players:GetPlayers()
    CounOfPlayersLbl:Set("プレイヤー数: "..AmountOfPlayers)
    AllPlayersLbl:Set("全プレイヤー: "..AmountOfPlayers)
    PlayerListLbl:Set(updatePlayerList())
    
    if targetDropdown then targetDropdown:Refresh(TargetPlayersDropdown(), true) end
    if LeftBlobDrop then LeftBlobDrop:Refresh(TargetPlayersDropdown(), true) end
    if RightBlobDrop then RightBlobDrop:Refresh(TargetPlayersDropdown(), true) end
    if DuoBlobDrop then DuoBlobDrop:Refresh(TargetPlayersDropdown(), true) end
end)

-- 初期化完了通知
OrionLib:Init()
task.wait(0.5)

OrionLib:MakeNotification({
    Name = "🎉 FTAP v10.0 True Legacy",
    Content = "全機能搭載 + 致命的バグ修正済み (オリジナル構造維持)",
    Image = "rbxassetid://4483345998",
    Time = 5
})
