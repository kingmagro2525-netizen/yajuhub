-- FTAP完全統合版 v7.1 (修正版)
-- URL修正済み: Orion Libraryの読み込み先を修正

-- ▼▼▼ 修正箇所: ライブラリのURLを正しいものに変更しました ▼▼▼
local OrionLib = loadstring(game:HttpGet(("https://raw.githubusercontent.com/Polinorsik/Orion-Z-Library/refs/heads/main/README.md")))()
-- ▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲

local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")
local Lighting = game:GetService("Lighting")
local HttpService = game:GetService("HttpService")

-- ■■■ コンソール機能の追加 ■■■
local LogMessages = {}
local LogLabel = nil
local function AddLog(text)
    local timestamp = os.date("%H:%M:%S")
    local msg = "[" .. timestamp .. "] " .. tostring(text)
    table.insert(LogMessages, 1, msg) -- 新しいログを上に追加
    if #LogMessages > 20 then table.remove(LogMessages) end -- 最大20行保持
    
    if LogLabel then
        pcall(function()
            LogLabel:Set(table.concat(LogMessages, "\n"))
        end)
    end
    print(msg) -- 標準コンソールにも出力
end
-- ■■■■■■■■■■■■■■■■■■■■

AddLog("システム初期化を開始...")

-- キャラクター取得
local LocalCharacter = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
LocalPlayer.CharacterAdded:Connect(function(character)
    LocalCharacter = character
    AddLog("キャラクターが更新されました")
end)

-- サーバーリモート
local GrabEvents = ReplicatedStorage:WaitForChild("GrabEvents", 10)
local MenuToys = ReplicatedStorage:WaitForChild("MenuToys", 10)
local CharacterEvents = ReplicatedStorage:WaitForChild("CharacterEvents", 10)

if not GrabEvents or not MenuToys or not CharacterEvents then
    warn("必要なリモートが見つかりません")
    AddLog("エラー: 必要なリモートが見つかりません")
    -- エラーでもUIを表示するためにreturnはしませんが、機能は制限されます
else
    AddLog("リモートイベントの接続に成功")
end

-- 各種リモートの取得（存在チェック付き）
local function getRemote(parent, name)
    local remote = parent:FindFirstChild(name)
    if not remote then
         -- 見つからない場合は待機してみる
         remote = parent:WaitForChild(name, 5)
    end
    return remote
end

local SetNetworkOwner = getRemote(GrabEvents, "SetNetworkOwner")
local Struggle = getRemote(CharacterEvents, "Struggle")
local CreateGrabLine = getRemote(GrabEvents, "CreateGrabLine")
local DestroyGrabLine = getRemote(GrabEvents, "DestroyGrabLine")
local DestroyToy = getRemote(MenuToys, "DestroyToy")
local RagdollRemote = getRemote(CharacterEvents, "RagdollRemote")
local BombEvents = ReplicatedStorage:FindFirstChild("BombEvents")

local toysFolder = workspace:FindFirstChild(LocalPlayer.Name.."SpawnedInToys")

-- グローバル変数
_G.strength = 450
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
local decoyOffset = 5
local circleRadius = 10
local followMode = true
local crouchWalkSpeed = 50
local crouchJumpPower = 50
local infJump = false
local antiVoidEnabled = false
local defenseStrength = 25
local blobDelay = 0.001

-- 🆕 新機能用変数
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

-- ターゲット選択
local TargetSelected = nil
local LeftBlobSelected = nil
local RightBlobSelected = nil
local DuoBlobSelected = nil
local selectedTarget = nil

-- Coroutine管理
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
    AntiGrabTestInvisible = false
}

-- 入力追跡
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

-- Owned toys確認
pcall(function()
    if LocalPlayer:FindFirstChild("PlayerGui") and LocalPlayer.PlayerGui:FindFirstChild("MenuGui") then
        local content = LocalPlayer.PlayerGui.MenuGui.Menu.TabContents.Toys.Contents
        for i, v in pairs(content:GetChildren()) do
            if v.Name ~= "UIGridLayout" then
                ownedToys[v.Name] = true
            end
        end
    end
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

-- 🆕 Creature Anti-Grab Glitch機能
local function executeCreatureAntiGrab()
    spawn(function()
        while coroutineFlags.AntiGrabCreature do
            pcall(function()
                local character = LocalPlayer.Character
                if not character then return end
                local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
                local humanoid = character:FindFirstChild("Humanoid")
                if not humanoidRootPart or not humanoid then return end
                
                AddLog("Creature Anti-Grabを実行中...")
                
                local originalPosition = humanoidRootPart.CFrame
                local spawnY = humanoidRootPart.Position.Y - 5
                local spawnX = humanoidRootPart.Position.X
                local spawnZ = humanoidRootPart.Position.Z
                MenuToys.SpawnToyRemoteFunction:InvokeServer(
                    "CreatureBlobman",
                    CFrame.new(0, 50000, 0, 0.505097806, -0.358538955, 0.78506434, 1.77621841e-05, 0.909631014, 0.415417165, -0.863062143, -0.209812373, 0.459458977),
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
                        local interval = 0.5 / 120
                        for i = 1, 120 do
                            seat:Sit(humanoid)
                            if RagdollRemote then RagdollRemote:FireServer(humanoidRootPart, 0) end
                            wait(interval)
                        end
                    end
                    if DestroyToy then DestroyToy:FireServer(blobman) end
                end
                task.wait(0.1)
                humanoidRootPart.CFrame = originalPosition
            end)
            task.wait(1)
        end
    end)
end

-- 🆕 テスト版透明化Anti-Grab機能
local function executeTestInvisibleAntiGrab()
    spawn(function()
        while coroutineFlags.AntiGrabTestInvisible do
            pcall(function()
                local character = LocalPlayer.Character
                if not character then return end
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
                    AddLog("透明化Anti-Grab: シート検知")
                    local camera = workspace.CurrentCamera
                    camera.CameraType = Enum.CameraType.Scriptable
                    local interval = 0.5 / 120
                    for i = 1, 120 do
                        foundSeat:Sit(humanoid)
                        if RagdollRemote then RagdollRemote:FireServer(humanoidRootPart, 0) end
                        wait(interval)
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

-- 🆕 バリア破壊機能
local function executeBarrierBreak()
    spawn(function()
        pcall(function()
            AddLog("バリア破壊を開始...")
            local character = LocalPlayer.Character
            if not character or not character:FindFirstChild("HumanoidRootPart") then return end
            local originalPosition = character.HumanoidRootPart.CFrame
            MenuToys.SpawnToyRemoteFunction:InvokeServer(
                "InstrumentWoodwindOcarina",
                CFrame.new(184.148834, -5.54824972, 498.136749, 0.829037189, -0.214714944, 0.516328275, 0, 0.923344612, 0.383972496, -0.559193552, -0.318327487, 0.765486956),
                Vector3.new(0, 34, 0)
            )
            wait(0.2)
            local toyFolder = workspace:FindFirstChild(LocalPlayer.Name .. "SpawnedInToys")
            if toyFolder then
                local ocarina = toyFolder:FindFirstChild("InstrumentWoodwindOcarina")
                if ocarina and ocarina:FindFirstChild("HoldPart") then
                    ocarina.HoldPart.HoldItemRemoteFunction:InvokeServer(ocarina, character)
                    wait(0.2)
                    character.HumanoidRootPart.CFrame = CFrame.new(304.06, 25.77, 488.54)
                    wait(0.05)
                    DestroyToy:FireServer(ocarina)
                    wait(0.05)
                    character.HumanoidRootPart.CFrame = originalPosition
                    OrionLib:MakeNotification({
                        Name = "バリア破壊",
                        Content = "実行完了!",
                        Image = "rbxassetid://4483345998",
                        Time = 3
                    })
                    AddLog("バリア破壊成功")
                end
            end
        end)
    end)
end

-- 🆕 ライン色更新機能
local function UpdateLineColors(...)
    pcall(function()
        if ReplicatedStorage:FindFirstChild("DataEvents") and ReplicatedStorage.DataEvents:FindFirstChild("UpdateLineColorsEvent") then
            ReplicatedStorage.DataEvents.UpdateLineColorsEvent:FireServer(...)
        end
    end)
end

local function CreateRainbowSequence()
    return ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.new(1, 0, 0)),
        ColorSequenceKeypoint.new(0.1666666716337204, Color3.new(1, 1, 0)),
        ColorSequenceKeypoint.new(0.3333333432674408, Color3.new(0, 1, 0)),
        ColorSequenceKeypoint.new(0.5, Color3.new(0, 1, 1)),
        ColorSequenceKeypoint.new(0.6666666865348816, Color3.new(0, 0, 1)),
        ColorSequenceKeypoint.new(0.8333333134651184, Color3.new(1, 0, 1)),
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
    if CreateGrabLine then
        CreateGrabLine:FireServer(
            torso,
            CFrame.new(0.031452179, 0.229282379, -0.500015259, 0.15651536, -0.0348511487, -0.987060428, -0.145104796, 0.987721682, -0.0578833297, 0.976958394, 0.152286738, 0.149536535)
        )
    end
end

-- 死亡時の再起動
LocalPlayer.CharacterAdded:Connect(function(character)
    LocalCharacter = character
    task.wait(1)
    if coroutineFlags.AntiGrabCreature then
        executeCreatureAntiGrab()
    end
    if coroutineFlags.AntiGrabTestInvisible then
        executeTestInvisibleAntiGrab()
    end
end)

-- 🆕 Anti-Lag (Look:FireServerブロック)
local oldNamecall
oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
    local method = getnamecallmethod()
    if antiLagLookEnabled and method == "FireServer" then
        if tostring(self) == "Look" then
            return
        end
    end
    return oldNamecall(self, ...)
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

-- Grab Handler
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
                                wait()
                                for _, part in pairs(partsTable) do
                                    part.Position = Vector3.new(0, -200, 0)
                                end
                            end
                        end
                    end
                end
            end
        end)
        wait()
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
        wait(0.5)
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
                            wait(0.4)
                            local humanoid = trgtCHR:FindFirstChild("Humanoid")
                            if humanoid then
                                humanoid.Health = 0
                            end
                        end
                    end
                end
            end
        end)
        wait()
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
                                wait()
                            end
                        end
                    end
                end
            end
        end)
        wait()
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
        wait()
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
                                wait()
                            elseif TPgrabOption == "Crazy teleport" then
                                hrp.CFrame = CFrame.new(-17, 421, 50)
                                wait(0.1)
                                hrp.CFrame = CFrame.new(145, 397, -126)
                                wait(0.1)
                                hrp.CFrame = CFrame.new(157, 254, 89)
                                wait(0.1)
                            end
                        end
                    end
                end
            end
        end)
        wait()
    end
end

-- Anti Explosion
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
        AddLog(p .. "をキルしています...")
        local inPos = a:GetPivot()
        while pCHR.Humanoid.Health ~= 0 do
            a.HumanoidRootPart.CFrame = pHRP.CFrame - Vector3.new(0, 10, 0)
            SetNetworkOwner:FireServer(pHRP, CFrame.new(pHRP.Position))
            for _, part in pairs(PoisonHurtParts) do
                part.Size = Vector3.new(1.5,1.5,1.5)
                part.Transparency = 1
                part.Position = pCHR:FindFirstChild("Head").Position
            end
            wait()
            for _, part in pairs(PoisonHurtParts) do
                part.Position = Vector3.new(0, -200, 0)
            end
        end
        a:PivotTo(inPos)
        AddLog(p .. "のキル完了")
    end)
end

-- Dropdown functions
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

-- Blobman functions
local function bringLeft(k)
    for _, v in pairs(workspace:GetDescendants()) do
        if v.Name == "CreatureBlobman" then
            pcall(function()
                local args = {
                    [1] = v.LeftDetector,
                    [2] = Players:FindFirstChild(k).Character.HumanoidRootPart,
                    [3] = v.LeftDetector.LeftWeld
                }
                v.BlobmanSeatAndOwnerScript.CreatureGrab:FireServer(unpack(args))
            end)
        end
    end
end

local function bringRight(k)
    for _, v in pairs(workspace:GetDescendants()) do
        if v.Name == "CreatureBlobman" then
            pcall(function()
                local args = {
                    [1] = v.RightDetector,
                    [2] = Players:FindFirstChild(k).Character.HumanoidRootPart,
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

-- UI作成
task.wait(1)
AddLog("UIを構築中...")
local Window = OrionLib:MakeWindow({
    Name = "FTAP完全統合版 v7.1",
    HidePremium = false,
    SaveConfig = true,
    ConfigFolder = "FTAPMergedV71",
    IntroEnabled = false
})

-- ■■■ GUIコンソールタブ ■■■
local ConsoleTab = Window:MakeTab({Name = "📜 コンソール", Icon = "rbxassetid://4483345998"})
ConsoleTab:AddSection({Name = "システムログ"})
LogLabel = ConsoleTab:AddLabel("初期化中...")
AddLog("コンソール準備完了")
-- ■■■■■■■■■■■■■■■■

-- 攻撃タブ
local AttackTab = Window:MakeTab({Name = "⚔️ 攻撃", Icon = "rbxassetid://4483345998"})

AttackTab:AddSection({Name = "ターゲット攻撃"})

local targetDropdown = AttackTab:AddDropdown({
    Name = "ターゲット選択",
    Default = "",
    Options = TargetPlayersDropdown(),
    Callback = function(Value)
        selectedTarget = Players:FindFirstChild(Value)
        TargetSelected = Value
        AddLog("ターゲット選択: " .. tostring(Value))
    end
})

AttackTab:AddToggle({
    Name = "ループキル",
    Default = false,
    Callback = function(enabled)
        coroutineFlags.LoopKill = enabled
        AddLog("ループキル: " .. tostring(enabled))
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
        else
            AddLog("ターゲットが選択されていません")
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
            AddLog("テレポートしました")
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
        _G.strength = Value
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

AttackTab:AddToggle({
    Name = "全員をフリング",
    Default = false,
    Callback = function(enabled)
        if enabled then
            AddLog("全員フリング開始")
            connections.FlingAll = RunService.Heartbeat:Connect(function()
                pcall(function()
                    for _, player in pairs(Players:GetPlayers()) do
                        if player ~= LocalPlayer and not isPlayerWhitelisted(player) and player.Character then
                            local hrp = player.Character:FindFirstChild("HumanoidRootPart")
                            if hrp and LocalCharacter and LocalCharacter:FindFirstChild("HumanoidRootPart") then
                                sno(hrp, hrp.CFrame)
                                local bv = Instance.new("BodyVelocity", hrp)
                                bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                                bv.Velocity = Vector3.new(math.random(-2000, 2000), math.random(1000, 2000), math.random(-2000, 2000))
                                Debris:AddItem(bv, 0.1)
                                task.wait(0.05)
                                ungrab(hrp)
                            end
                        end
                    end
                end)
            end)
        else
            if connections.FlingAll then
                connections.FlingAll:Disconnect()
                connections.FlingAll = nil
            end
        end
    end
})

AttackTab:AddToggle({
    Name = "全員を自分に引き寄せ",
    Default = false,
    Callback = function(enabled)
        coroutineFlags.BringAll = enabled
        if enabled then
            AddLog("全員引き寄せ開始")
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

-- グラブタブ
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

-- オーラタブ
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
                                                if SetNetworkOwner then SetNetworkOwner:FireServer(playerHRP, playerHRP.CFrame) end
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
                                            if SetNetworkOwner then SetNetworkOwner:FireServer(torso, hrp.CFrame) end
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
                                    if SetNetworkOwner then SetNetworkOwner:FireServer(firePlayerPart, firePlayerPart.CFrame) end
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

-- 🆕 オートタブ
local AutoTab = Window:MakeTab({Name = "🤖 オート", Icon = "rbxassetid://4483345998"})

AutoTab:AddSection({Name = "🆕 バリア破壊"})

AutoTab:AddButton({
    Name = "🆕 バリア破壊を実行",
    Callback = function()
        executeBarrierBreak()
    end
})

-- Blobmanタブ
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
        AddLog("Bring all 実行中...")
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
        AddLog("Server Break: " .. tostring(enabled))
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

-- キャラクタータブ
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

-- 防御タブ
local DefenseTab = Window:MakeTab({Name = "🛡️ 防御", Icon = "rbxassetid://4483345998"})

DefenseTab:AddSection({Name = "🆕 新アンチグラブグリッチ"})

DefenseTab:AddToggle({
    Name = "🆕 アンチグラブグリッチ (Creature)",
    Default = false,
    Callback = function(enabled)
        coroutineFlags.AntiGrabCreature = enabled
        antiGrabCreatureEnabled = enabled
        if enabled then
            executeCreatureAntiGrab()
            OrionLib:MakeNotification({
                Name = "Anti-Grab Glitch",
                Content = "Creature方式が有効化されました（死亡時自動再起動）",
                Image = "rbxassetid://4483345998",
                Time = 3
            })
            AddLog("Anti-Grab (Creature) 有効化")
        else
            AddLog("Anti-Grab (Creature) 無効化")
        end
    end
})

DefenseTab:AddToggle({
    Name = "🆕 テスト版透明化アンチグラブグリッチ",
    Default = false,
    Callback = function(enabled)
        coroutineFlags.AntiGrabTestInvisible = enabled
        antiGrabTestInvisibleEnabled = enabled
        if enabled then
            executeTestInvisibleAntiGrab()
            OrionLib:MakeNotification({
                Name = "Test Invisible Anti-Grab",
                Content = "テスト版が有効化されました（死亡時自動再起動）",
                Image = "rbxassetid://4483345998",
                Time = 3
            })
            AddLog("Anti-Grab (Test Invisible) 有効化")
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
            AddLog("Anti Lag (Look Block) 有効化")
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

-- 🆕 Lineタブ (完全版)
local LineTab = Window:MakeTab({Name = "📏 Line", Icon = "rbxassetid://4483345998"})

LineTab:AddSection({Name = "Special Presets"})

LineTab:AddButton({
    Name = "🌈 Rainbow",
    Callback = function()
        UpdateLineColors(CreateRainbowSequence())
        OrionLib:MakeNotification({
            Name = "Line Color",
            Content = "Rainbow applied!",
            Image = "rbxassetid://4483345998",
            Time = 2
        })
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
            OrionLib:MakeNotification({
                Name = "Random Line",
                Content = "Enabled - Color changing!",
                Image = "rbxassetid://4483345998",
                Time = 2
            })
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
            OrionLib:MakeNotification({
                Name = "Gradient Random",
                Content = "Enabled - Gradient changing!",
                Image = "rbxassetid://4483345998",
                Time = 2
            })
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
            OrionLib:MakeNotification({
                Name = "Preset Applied",
                Content = presetName,
                Image = "rbxassetid://4483345998",
                Time = 2
            })
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
            OrionLib:MakeNotification({
                Name = "Line Lag",
                Content = "Enabled (All Players)!",
                Image = "rbxassetid://4483345998",
                Time = 2
            })
            AddLog("Line Lag (All) 有効化")
        else
            OrionLib:MakeNotification({
                Name = "Line Lag",
                Content = "Disabled!",
                Image = "rbxassetid://4483345998",
                Time = 2
            })
            AddLog("Line Lag (All) 無効化")
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
                OrionLib:MakeNotification({
                    Name = "Error",
                    Content = "Select a player first!",
                    Image = "rbxassetid://4483345998",
                    Time = 2
                })
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
            OrionLib:MakeNotification({
                Name = "Line Lag",
                Content = "Single target enabled!",
                Image = "rbxassetid://4483345998",
                Time = 2
            })
            AddLog("Line Lag (Single) 有効化")
        else
            lineLagEnabled = false
            OrionLib:MakeNotification({
                Name = "Line Lag",
                Content = "Single target disabled!",
                Image = "rbxassetid://4483345998",
                Time = 2
            })
        end
    end
})

LineTab:AddButton({
    Name = "Refresh Player List",
    Callback = function()
        LineLagTargetDropdown:Refresh(TargetPlayersDropdown(), true)
        OrionLib:MakeNotification({
            Name = "Refreshed",
            Content = "Player list updated!",
            Image = "rbxassetid://4483345998",
            Time = 2
        })
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
        OrionLib:MakeNotification({
            Name = "FartherReach",
            Content = enabled and "Enabled!" or "Disabled!",
            Image = "rbxassetid://4483345998",
            Time = 2
        })
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
                        if CreateGrabLine then CreateGrabLine:FireServer() end
                    end)
                    wait(0.1)
                end
            end)
            OrionLib:MakeNotification({
                Name = "Invisible Line",
                Content = "Enabled - Looping!",
                Image = "rbxassetid://4483345998",
                Time = 2
            })
        else
            OrionLib:MakeNotification({
                Name = "Invisible Line",
                Content = "Disabled!",
                Image = "rbxassetid://4483345998",
                Time = 2
            })
        end
    end
})

-- テレポートタブ
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

-- ビジュアルタブ
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
            if workspace.CurrentCamera:FindFirstChild("Blur") then
                workspace.CurrentCamera.Blur.Enabled = false
            end
        else
            if workspace.CurrentCamera:FindFirstChild("Blur") then
                workspace.CurrentCamera.Blur.Enabled = true
            end
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

VisualTab:AddButton({
    Name = "昼 (デフォルト)",
    Callback = function()
        Lighting.ClockTime = 10
    end
})

VisualTab:AddButton({
    Name = "夜",
    Callback = function()
        Lighting.ClockTime = 0
    end
})

VisualTab:AddButton({
    Name = "朝",
    Callback = function()
        Lighting.ClockTime = 6
    end
})

VisualTab:AddButton({
    Name = "夕方",
    Callback = function()
        Lighting.ClockTime = 18
    end
})

-- Funタブ
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

-- キーバインドタブ
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
                                    if SetNetworkOwner then
                                        SetNetworkOwner:FireServer(targetPlayer.Character.HumanoidRootPart, targetPlayer.Character.HumanoidRootPart.CFrame)
                                        burn(targetPlayer.Character:FindFirstChild("Head"))
                                        if DestroyGrabLine then DestroyGrabLine:FireServer(targetPlayer.Character.HumanoidRootPart) end
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
                                    if SetNetworkOwner then SetNetworkOwner:FireServer(targetPlayer.Character.HumanoidRootPart, CFrame.new(targetPlayer.Character.HumanoidRootPart.Position)) end
                                    for _, part in pairs(PoisonHurtParts) do
                                        part.Size = Vector3.new(1.5,1.5,1.5)
                                        part.Transparency = 1
                                        part.Position = targetPlayer.Character:FindFirstChild("Head").Position
                                    end
                                    wait()
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
                    if SetNetworkOwner then SetNetworkOwner:FireServer(character.HumanoidRootPart, character.HumanoidRootPart.CFrame) end
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

-- スクリプトタブ
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

-- 設定タブ
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
        for _, conn in pairs(connections) do
            if conn then pcall(function() conn:Disconnect() end) end
        end
        OrionLib:Destroy()
    end
})

SettingsTab:AddSection({Name = "情報"})
SettingsTab:AddLabel("バージョン: v7.1 完全統合版")
SettingsTab:AddLabel("✅ 元の全機能 + 新機能追加")
SettingsTab:AddLabel("🆕 Creature Anti-Grab Glitch")
SettingsTab:AddLabel("🆕 テスト版透明化Anti-Grab")
SettingsTab:AddLabel("🆕 Look:FireServerブロック")
SettingsTab:AddLabel("🆕 バリア破壊ボタン")
SettingsTab:AddLabel("🆕 Line機能完全版")
SettingsTab:AddLabel("⚽ Kick Grab搭載")
SettingsTab:AddLabel("🛸 UFO Grab搭載")

-- サーバー情報タブ
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

-- プレイヤー更新
Players.PlayerAdded:Connect(function()
    AmountOfPlayers = #Players:GetPlayers()
    CounOfPlayersLbl:Set("プレイヤー数: "..AmountOfPlayers)
    AllPlayersLbl:Set("全プレイヤー: "..AmountOfPlayers)
    PlayerListLbl:Set(updatePlayerList())
    if targetDropdown then targetDropdown:Refresh(TargetPlayersDropdown(), true) end
    if LeftBlobDrop then LeftBlobDrop:Refresh(TargetPlayersDropdown(), true) end
    if RightBlobDrop then RightBlobDrop:Refresh(TargetPlayersDropdown(), true) end
    if DuoBlobDrop then DuoBlobDrop:Refresh(TargetPlayersDropdown(), true) end
    
    -- ログ追加
    AddLog("プレイヤー参加: 更新完了")
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
    
    -- ログ追加
    AddLog("プレイヤー退出: 更新完了")
end)

-- 初期化完了通知
OrionLib:Init()
task.wait(0.5)

OrionLib:MakeNotification({
    Name = "🎉 FTAP完全統合版 v7.1",
    Content = "全ての元機能 + 新機能ロード完了！",
    Image = "rbxassetid://4483345998",
    Time = 5
})

AddLog("FTAP v7.1 全機能ロード完了")
print("========================================")
print("FTAP Complete v7.1 Loaded Successfully!")
print("========================================")
