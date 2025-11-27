--[[
    修正点:
    1. (最重要) スクリプト冒頭の `playerCharacter` 取得から `CharacterAdded:Wait()` を削除しました。
       代わりに、`CharacterAdded` イベントと起動時のチェックで `playerCharacter` を設定するように変更しました。
       これにより、キャラクターの読み込みが遅れてもスクリプト（GUI）が起動するようになります。
    2. 長時間実行されるコルーチン (しゃがみ速度/ジャンプ、ミサイルリロード、FireAllなど) が、
       古いキャラクターの情報を参照し続けるのを防ぐため、ループ内で常に最新の `localPlayer.Character` を
       参照するように修正しました。
    3. 多くの `pcall` (安全呼び出し) に `warn` を追加しました。もし特定の機能がエラーで動作していない場合、
       開発者コンソール (F9キー) に原因（エラーメッセージ）が出力されるようになります。
    4. `arson` 関数など、いくつかの箇所で nil チェックを強化し、エラー耐性を高めました。
]]

local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")

-- ゲーム内オブジェクトの待機
local GrabEvents = ReplicatedStorage:WaitForChild("GrabEvents")
local MenuToys = ReplicatedStorage:WaitForChild("MenuToys")
local CharacterEvents = ReplicatedStorage:WaitForChild("CharacterEvents")
local DataEvents = ReplicatedStorage:FindFirstChild("DataEvents") -- Line機能用

local SetNetworkOwner = GrabEvents:WaitForChild("SetNetworkOwner")
local Struggle = CharacterEvents:WaitForChild("Struggle")
local CreateLine = GrabEvents:WaitForChild("CreateGrabLine")
local DestroyLine = GrabEvents:WaitForChild("DestroyGrabLine")
local DestroyToy = MenuToys:WaitForChild("DestroyToy")

local localPlayer = Players.LocalPlayer
local playerCharacter = localPlayer.Character -- <--- [修正点 1] :Wait() を削除

localPlayer.CharacterAdded:Connect(function(character)
    playerCharacter = character
end)
if localPlayer.Character then -- <--- [修正点 1] 既に存在する場合に設定
    playerCharacter = localPlayer.Character
end


-- 変数定義
local AutoRecoverDroppedPartsCoroutine
local connectionBombReload
local reloadBombCoroutine
local antiExplosionConnection
local poisonAuraCoroutine
local strengthConnection
local autoStruggleCoroutine
local autoDefendCoroutine
local auraCoroutine
local gravityCoroutine
local kickCoroutine
local anchoredParts = {}
local anchoredConnections = {}
local compiledGroups = {}
local compileConnections = {}
local compileCoroutine
local fireAllCoroutine
local connections = {}
local renderSteppedConnections = {}
local ragdollAllCoroutine
local crouchJumpCoroutine
local crouchSpeedCoroutine
local anchorGrabCoroutine
local poisonGrabCoroutine
local ufoGrabCoroutine
local fireGrabCoroutine
local noclipGrabCoroutine
local antiKickCoroutine
local kickGrabConnections = {}
local lightbitpos = {}
local lightbitparts = {}
local lightbitcon
local lightbitcon2
local lightorbitcon
local bodyPositions = {}
local alignOrientations = {}
local characterAddedConn
local anchorKickCoroutine
local deathAuraCoroutine
local poisonCoroutines = {}
local coroutineRunning = false
local kickGrabCoroutine
local hellSendGrabCoroutine
local blobmanCoroutine
local lighBitSpeedCoroutine
local tpAllCoroutine
local autoDefendKickCoroutine 

-- Blobman用変数
local AutoSitEnabled = false
local loopTpCoroutine
local currentLoopTpPlayerIndex = 1
local blobman
local isSpawningBlobmanForSit = false -- 自動スポーン制御用フラグ
local lastSpawnAttempt = 0 -- AutoSitクールダウン用
local SPAWN_COOLDOWN = 0.5 -- 0.5秒のクールダウン

-- Line機能用変数
local lineLagEnabled = false
local lineLagAllEnabled = false
local lineLagTarget = nil
local lineLagSpeed = 0.05
local invisibleLineEnabled = false
local randomLineEnabled = false
local gradientRandomEnabled = false
local presetSegments = 10
local fartherReachEnabled = false

-- 設定値
_G.ToyToLoad = "BombMissile"
_G.MaxMissiles = 9
_G.BlobmanDelay = 0.05

local decoyOffset = 15
local stopDistance = 5
local circleRadius = 10
local auraToggle = 1
local crouchWalkSpeed = 50
local crouchJumpPower = 50
local kickMode = 1
local auraRadius = 20
local lightbit = 0.3125
local lightbitoffset = 1
local lightbitradius = 20
local usingradius = lightbitradius

-- OrionLibロード
local OrionLib = loadstring(game:HttpGet(("https://raw.githubusercontent.com/Polinorsik/Orion-Z-Library/refs/heads/main/README.md")))()

-- ユーティリティ関数
local Utilities = {}
local U = Utilities

function Utilities.IsDescendantOf(child, parent)
    local currentParent = child.Parent
    while currentParent do
        if currentParent == parent then return true end
        currentParent = currentParent.Parent
    end
    return false
end

function Utilities.GetDescendant(parent, name, className)
    for _, descendant in ipairs(parent:GetDescendants()) do
        if descendant.Name == name and (not className or descendant:IsA(className)) then
            return descendant
        end
    end
    return nil
end

function Utilities.FindFirstAncestorOfType(child, className)
    local currentParent = child.Parent
    while currentParent do
        if currentParent:IsA(className) then return currentParent end
        currentParent = currentParent.Parent
    end
    return nil
end

function Utilities.GetSurroundingVectors(target, radius, amount, offset)
    local positions = {}
    for i = 1, amount do
        local angle = ((i - 1) / amount) * 2 * math.pi + offset
        local x = target.X + radius * math.cos(angle)
        local z = target.Z + radius * math.sin(angle)
        table.insert(positions, Vector3.new(x, target.Y, z))
    end
    return positions
end

-- Line機能用ヘルパー関数
local function UpdateLineColors(...)
    if not DataEvents then 
        warn("DataEvents not found - Line features disabled")
        return 
    end
    local success, err = pcall(function()
        if DataEvents:FindFirstChild("UpdateLineColorsEvent") then
            DataEvents.UpdateLineColorsEvent:FireServer(...)
        end
    end)
    if not success then warn("Error in UpdateLineColors: "..tostring(err)) end
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
    
    if CreateLine then
        CreateLine:FireServer(
            torso,
            CFrame.new(0.031452179, 0.229282379, -0.500015259, 0.15651536, -0.0348511487, -0.987060428, -0.145104796, 0.987721682, -0.0578833297, 0.976958394, 0.152286738, 0.149536535)
        )
    end
end

local function executeBarrierBreak()
    task.spawn(function()
        local success, err = pcall(function()
            local character = localPlayer.Character -- <--- [修正点 2] 最新のキャラを取得
            if not character or not character:FindFirstChild("HumanoidRootPart") then return end
            
            local originalPosition = character.HumanoidRootPart.CFrame
            
            -- オカリナをスポーンさせる
            ReplicatedStorage.MenuToys.SpawnToyRemoteFunction:InvokeServer(
                "InstrumentWoodwindOcarina",
                CFrame.new(184.148834, -5.54824972, 498.136749, 0.829037189, -0.214714944, 0.516328275, 0, 0.923344612, 0.383972496, -0.559193552, -0.318327487, 0.765486956),
                Vector3.new(0, 34, 0)
            )
            
            wait(0.2)
            
            local toyFolder = workspace:FindFirstChild(localPlayer.Name .. "SpawnedInToys")
            if toyFolder then
                local ocarina = toyFolder:FindFirstChild("InstrumentWoodwindOcarina")
                if ocarina and ocarina:FindFirstChild("HoldPart") then
                    -- オカリナを持って壁抜け
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
                end
            end
        end)
        if not success then warn("Error in executeBarrierBreak: "..tostring(err)) end
    end)
end

local followMode = true
local toysFolder = workspace:FindFirstChild(localPlayer.Name.."SpawnedInToys")
local ownedToys = {}
local bombList = {}
local platforms = {}

local function isDescendantOf(target, other)
    local currentParent = target.Parent
    while currentParent do
        if currentParent == other then return true end
        currentParent = currentParent.Parent
    end
    return false
end

local function DestroyT(toy)
    toy = toy or toysFolder:FindFirstChildWhichIsA("Model")
    DestroyToy:FireServer(toy)
end

local function getDescendantParts(descendantName)
    local parts = {}
    if workspace:FindFirstChild("Map") then -- マップが存在するか確認
        for _, descendant in ipairs(workspace.Map:GetDescendants()) do
            if descendant:IsA("Part") and descendant.Name == descendantName then
                table.insert(parts, descendant)
            end
        end
    else
        warn("workspace.Map not found, cannot get "..descendantName)
    end
    return parts
end

local poisonHurtParts = getDescendantParts("PoisonHurtPart")
local paintPlayerParts = getDescendantParts("PaintPlayerPart")

-- GUIの準備ができてからおもちゃリストを取得
task.spawn(function()
    local contents = localPlayer:WaitForChild("PlayerGui"):WaitForChild("MenuGui"):WaitForChild("Menu"):WaitForChild("TabContents"):WaitForChild("Toys"):WaitForChild("Contents")
    for i, v in pairs(contents:GetChildren()) do
        if v.Name ~= "UIGridLayout" then
            ownedToys[v.Name] = true
        end
    end
end)


local function getNearestPlayer()
    local nearestPlayer
    local nearestDistance = math.huge
    local character = localPlayer.Character -- <--- [修正点 2] 最新のキャラを取得
    if not character or not character:FindFirstChild("HumanoidRootPart") then return nil end
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= localPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local distance = (character.HumanoidRootPart.Position - player.Character.HumanoidRootPart.Position).Magnitude
            if distance < nearestDistance then
                nearestDistance = distance
                nearestPlayer = player
            end
        end
    end
    return nearestPlayer
end

local function getPlayerNamesForDropdown()
    local names = {}
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= localPlayer then
            table.insert(names, player.Name)
        end
    end
    return names
end

local function cleanupConnections(connectionTable)
    for i = #connectionTable, 1, -1 do
        local connection = table.remove(connectionTable, i)
        if connection and typeof(connection) == "RBXScriptConnection" then
            pcall(function() connection:Disconnect() end)
        end
    end
end

local function spawnItem(itemName, position, orientation)
    task.spawn(function()
        local cframe = CFrame.new(position)
        local rotation = Vector3.new(0, 90, 0)
        ReplicatedStorage.MenuToys.SpawnToyRemoteFunction:InvokeServer(itemName, cframe, rotation)
    end)
end

local function arson(part)
    if not toysFolder then
        warn("toysFolder not found in arson")
        return
    end
    if not toysFolder:FindFirstChild("Campfire") then
        spawnItem("Campfire", Vector3.new(-72.9304581, -5.96906614, -265.543732))
    end
    local campfire = toysFolder:WaitForChild("Campfire", 2) -- <--- [修正点 4] WaitForChildとnilチェック
    if not campfire then 
        warn("Campfire not found in arson")
        return 
    end
    
    local burnPart = campfire:FindFirstChild("FirePlayerPart")
    if not burnPart then -- <--- [修正点 4] nilチェック
        warn("FirePlayerPart not found in arson")
        return 
    end
    
    burnPart.Size = Vector3.new(7, 7, 7)
    burnPart.Position = part.Position
    task.wait(0.3)
    burnPart.Position = Vector3.new(0, -50, 0)
end

local function handleCharacterAdded(player)
    local characterAddedConnection = player.CharacterAdded:Connect(function(character)
        local hrp = character:WaitForChild("HumanoidRootPart")
        if hrp then
            local fpp = hrp:WaitForChild("FirePlayerPart")
            if fpp then
                fpp.Size = Vector3.new(4.5, 5, 4.5)
                fpp.CollisionGroup = "1"
                fpp.CanQuery = true
            end
        end
    end)
    table.insert(kickGrabConnections, characterAddedConnection)
end

local function kickGrab()
    for _, player in pairs(Players:GetPlayers()) do
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local hrp = player.Character.HumanoidRootPart
            if hrp:FindFirstChild("FirePlayerPart") then
                local fpp = hrp.FirePlayerPart
                fpp.Size = Vector3.new(4.5, 5.5, 4.5)
                fpp.CollisionGroup = "1"
                fpp.CanQuery = true
            end
        end
        handleCharacterAdded(player)
    end
    local playerAddedConnection = Players.PlayerAdded:Connect(handleCharacterAdded)
    table.insert(kickGrabConnections, playerAddedConnection)
end

local function grabHandler(grabType)
    while true do
        local success, err = pcall(function()
            local child = workspace:FindFirstChild("GrabParts")
            if child and child.Name == "GrabParts" then
                local grabPart = child:FindFirstChild("GrabPart")
                if grabPart and grabPart:FindFirstChild("WeldConstraint") then
                    local grabbedPart = grabPart.WeldConstraint.Part1
                    if grabbedPart then
                        local head = grabbedPart.Parent:FindFirstChild("Head")
                        if head then
                            while workspace:FindFirstChild("GrabParts") do
                                local partsTable = grabType == "poison" and poisonHurtParts or paintPlayerParts
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
                            for _, part in pairs(partsTable) do
                                part.Position = Vector3.new(0, -200, 0)
                            end
                        end
                    end
                end
            end
        end)
        if not success then warn("Error in grabHandler ("..tostring(grabType).."): "..tostring(err)) end -- <--- [修正点 3]
        wait()
    end
end

local function fireGrab()
    while true do
        local success, err = pcall(function()
            local child = workspace:FindFirstChild("GrabParts")
            if child and child.Name == "GrabParts" then
                local grabPart = child:FindFirstChild("GrabPart")
                if grabPart and grabPart:FindFirstChild("WeldConstraint") then
                    local grabbedPart = grabPart.WeldConstraint.Part1
                    if grabbedPart then
                        local head = grabbedPart.Parent:FindFirstChild("Head")
                        if head then arson(head) end
                    end
                end
            end
        end)
        if not success then warn("Error in fireGrab: "..tostring(err)) end -- <--- [修正点 3]
        wait()
    end
end

local function noclipGrab()
    while true do
        local success, err = pcall(function()
            local child = workspace:FindFirstChild("GrabParts")
            if child and child.Name == "GrabParts" then
                local grabPart = child:FindFirstChild("GrabPart")
                if grabPart and grabPart:FindFirstChild("WeldConstraint") then
                    local grabbedPart = grabPart.WeldConstraint.Part1
                    if grabbedPart then
                        local character = grabbedPart.Parent
                        if character and character:FindFirstChild("HumanoidRootPart") then
                            while workspace:FindFirstChild("GrabParts") do
                                for _, part in pairs(character:GetChildren()) do
                                    if part:IsA("BasePart") then
                                        part.CanCollide = false
                                    end
                                end
                                wait()
                            end
                            for _, part in pairs(character:GetChildren()) do
                                if part:IsA("BasePart") then
                                    part.CanCollide = true
                                end
                            end
                        end
                    end
                end
            end
        end)
        if not success then warn("Error in noclipGrab: "..tostring(err)) end -- <--- [修正点 3]
        wait()
    end
end

local function spawnItemCf(itemName, cframe)
    task.spawn(function()
        local rotation = Vector3.new(0, 0, 0)
        ReplicatedStorage.MenuToys.SpawnToyRemoteFunction:InvokeServer(itemName, cframe, rotation)
    end)
end

local function fireAll()
    while true do
        local success, err = pcall(function()
            if not toysFolder then return end
            
            local character = localPlayer.Character -- <--- [修正点 2]
            if not character or not character:FindFirstChild("Head") or not character:FindFirstChild("Torso") then return end
            
            if toysFolder:FindFirstChild("Campfire") then
                DestroyT(toysFolder:FindFirstChild("Campfire"))
                wait(0.5)
            end
            spawnItemCf("Campfire", character.Head.CFrame)
            local campfire = toysFolder:WaitForChild("Campfire")
            local firePlayerPart
            for _, part in pairs(campfire:GetChildren()) do
                if part.Name == "FirePlayerPart" then
                    part.Size = Vector3.new(10, 10, 10)
                    firePlayerPart = part
                    break
                end
            end
            if not firePlayerPart then return end -- パーツが見つからなければリトライ
            
            local originalPosition = character.Torso.Position
            SetNetworkOwner:FireServer(firePlayerPart, firePlayerPart.CFrame)
            character:MoveTo(firePlayerPart.Position)
            wait(0.3)
            character:MoveTo(originalPosition)
            
            local bodyPosition = Instance.new("BodyPosition")
            bodyPosition.P = 20000
            bodyPosition.Position = character.Head.Position + Vector3.new(0, 600, 0)
            bodyPosition.Parent = campfire.Main
            
            while true do
                local currentCharacter = localPlayer.Character -- <--- [修正点 2] 内側ループでも最新を取得
                if not currentCharacter or not currentCharacter:FindFirstChild("Head") then 
                    bodyPosition:Destroy() -- キャラがいなくなったらBodyPositionを削除してループを抜ける
                    break 
                end
                
                for _, player in pairs(Players:GetChildren()) do
                    pcall(function()
                        bodyPosition.Position = currentCharacter.Head.Position + Vector3.new(0, 600, 0)
                        if player.Character and player.Character.HumanoidRootPart and player.Character ~= currentCharacter then
                            firePlayerPart.Position = player.Character.HumanoidRootPart.Position or player.Character.Head.Position
                            wait()
                        end
                    end)
                end  
                wait()
            end
        end)
        if not success then warn("Error in fireAll: "..tostring(err)) end -- <--- [修正点 3]
        wait()
    end
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

local function onPartOwnerAdded(descendant, primaryPart)
    if descendant.Name == "PartOwner" and descendant.Value ~= localPlayer.Name then
        local highlight = primaryPart:FindFirstChild("Highlight") or U.GetDescendant(U.FindFirstAncestorOfType(primaryPart, "Model"), "Highlight", "Highlight")
        if highlight then
            if descendant.Value ~= localPlayer.Name then
                highlight.OutlineColor = Color3.new(1, 0, 0)
            else
                highlight.OutlineColor = Color3.new(0, 0, 1)
            end
        end
    end
end

local function createBodyMovers(part, position, rotation)
    local bodyPosition = Instance.new("BodyPosition")
    local bodyGyro = Instance.new("BodyGyro")
    bodyPosition.P = 15000
    bodyPosition.D = 200
    bodyPosition.MaxForce = Vector3.new(5000000, 5000000, 5000000)
    bodyPosition.Position = position
    bodyPosition.Parent = part
    bodyGyro.P = 15000
    bodyGyro.D = 200
    bodyGyro.MaxTorque = Vector3.new(5000000, 5000000, 5000000)
    bodyGyro.CFrame = rotation
    bodyGyro.Parent = part
end

local function anchorGrab()
    while true do
        local success, err = pcall(function()
            local grabParts = workspace:FindFirstChild("GrabParts")
            if not grabParts then return end
            local grabPart = grabParts:FindFirstChild("GrabPart")
            if not grabPart then return end
            local weldConstraint = grabPart:FindFirstChild("WeldConstraint")
            if not weldConstraint or not weldConstraint.Part1 then return end
            local primaryPart = weldConstraint.Part1.Name == "SoundPart" and weldConstraint.Part1 or weldConstraint.Part1.Parent.SoundPart or weldConstraint.Part1.Parent.PrimaryPart or weldConstraint.Part1
            if not primaryPart then return end
            if primaryPart.Anchored then return end
            if isDescendantOf(primaryPart, workspace.Map) then return end
            for _, player in pairs(Players:GetChildren()) do
                if player.Character and isDescendantOf(primaryPart, player.Character) then return end -- <--- 修正: player.Characterの存在チェック
            end
            local t = true
            for _, v in pairs(primaryPart:GetDescendants()) do
                if table.find(anchoredParts, v) then
                    t = false
                end
            end
            if t and not table.find(anchoredParts, primaryPart) then
                local target 
                if U.FindFirstAncestorOfType(primaryPart, "Model") and U.FindFirstAncestorOfType(primaryPart, "Model") ~= workspace then
                    target = U.FindFirstAncestorOfType(primaryPart, "Model")
                else
                    target = primaryPart
                end
                local highlight = createHighlight(target)
                table.insert(anchoredParts, primaryPart)
                local connection = target.DescendantAdded:Connect(function(descendant)
                    onPartOwnerAdded(descendant, primaryPart)
                end)
                table.insert(anchoredConnections, connection)
            end
            if U.FindFirstAncestorOfType(primaryPart, "Model") and U.FindFirstAncestorOfType(primaryPart, "Model") ~= workspace then 
                for _, child in ipairs(U.FindFirstAncestorOfType(primaryPart, "Model"):GetDescendants()) do
                    if child:IsA("BodyPosition") or child:IsA("BodyGyro") then
                        child:Destroy()
                    end
                end
            else
                for _, child in ipairs(primaryPart:GetChildren()) do
                    if child:IsA("BodyPosition") or child:IsA("BodyGyro") then
                        child:Destroy()
                    end
                end
            end
            while workspace:FindFirstChild("GrabParts") do
                wait()
            end
            createBodyMovers(primaryPart, primaryPart.Position, primaryPart.CFrame)
        end)
        if not success then warn("Error in anchorGrab: "..tostring(err)) end -- <--- [修正点 3]
        wait()
    end
end

local function anchorKickGrab()
    while true do
        local success, err = pcall(function()
            local grabParts = workspace:FindFirstChild("GrabParts")
            if not grabParts then return end
            local grabPart = grabParts:FindFirstChild("GrabPart")
            if not grabPart then return end
            local weldConstraint = grabPart:FindFirstChild("WeldConstraint")
            if not weldConstraint or not weldConstraint.Part1 then return end
            local primaryPart = weldConstraint.Part1
            if not primaryPart then return end
            if isDescendantOf(primaryPart, workspace.Map) then return end
            if primaryPart.Name ~= "FirePlayerPart" then return end
            for _, child in ipairs(primaryPart:GetChildren()) do
                if child:IsA("BodyPosition") or child:IsA("BodyGyro") then
                    child:Destroy()
                end
            end
            while workspace:FindFirstChild("GrabParts") do
                wait()
            end
            createBodyMovers(primaryPart, primaryPart.Position, primaryPart.CFrame)
        end)
        if not success then warn("Error in anchorKickGrab: "..tostring(err)) end -- <--- [修正点 3]
        wait()
    end
end

local function cleanupAnchoredParts()
    for _, part in ipairs(anchoredParts) do
        if part and part.Parent then -- <--- 修正: partが存在し、Parentがあるか確認
            if part:FindFirstChild("BodyPosition") then
                part.BodyPosition:Destroy()
            end
            if part:FindFirstChild("BodyGyro") then
                part.BodyGyro:Destroy()
            end
            local highlight = part:FindFirstChild("Highlight") or part.Parent and part.Parent:FindFirstChild("Highlight")
            if highlight then
                highlight:Destroy()
            end
        end
    end
    cleanupConnections(anchoredConnections)
    anchoredParts = {}
end

local function updateBodyMovers(primaryPart)
    for _, group in ipairs(compiledGroups) do
        if group.primaryPart and group.primaryPart == primaryPart and group.primaryPart.Parent then -- <--- 修正: primaryPartが存在するか確認
            for _, data in ipairs(group.group) do
                if data.part and data.part.Parent then -- <--- 修正: data.partが存在するか確認
                    local bodyPosition = data.part:FindFirstChild("BodyPosition")
                    local bodyGyro = data.part:FindFirstChild("BodyGyro")
                    if bodyPosition then
                        bodyPosition.Position = (primaryPart.CFrame * data.offset).Position
                    end
                    if bodyGyro then
                        bodyGyro.CFrame = primaryPart.CFrame * data.offset
                    end
                end
            end
        end
    end
end

local function compileGroup()
    if #anchoredParts == 0 then
        OrionLib:MakeNotification({Name = "Error", Content = "No anchored parts found", Image = "rbxassetid://4483345998", Time = 5})
        return
    end
    OrionLib:MakeNotification({Name = "Success", Content = "Compiled "..#anchoredParts.." Toys together", Image = "rbxassetid://4483345998", Time = 5})
    local primaryPart = anchoredParts[1]
    if not primaryPart or not primaryPart.Parent then return end -- <--- 修正: 存在チェック
    
    local highlight = primaryPart:FindFirstChild("Highlight") or (primaryPart.Parent and primaryPart.Parent:FindFirstChild("Highlight"))
    if not highlight then
        highlight = createHighlight(primaryPart.Parent:IsA("Model") and primaryPart.Parent or primaryPart)
    end
    highlight.OutlineColor = Color3.new(0, 1, 0)
    local group = {}
    for _, part in ipairs(anchoredParts) do
        if part and part.Parent and part ~= primaryPart then -- <--- 修正: 存在チェック
            local offset = primaryPart.CFrame:toObjectSpace(part.CFrame)
            table.insert(group, {part = part, offset = offset})
        end
    end
    table.insert(compiledGroups, {primaryPart = primaryPart, group = group})
    local connection = primaryPart:GetPropertyChangedSignal("CFrame"):Connect(function()
        updateBodyMovers(primaryPart)
    end)
    table.insert(compileConnections, connection)
    local renderSteppedConnection = RunService.Heartbeat:Connect(function()
        updateBodyMovers(primaryPart)
    end)
    table.insert(renderSteppedConnections, renderSteppedConnection)
end

local function cleanupCompiledGroups()
    for _, groupData in ipairs(compiledGroups) do
        for _, data in ipairs(groupData.group) do
            if data.part and data.part.Parent then -- <--- 修正: 存在チェック
                if data.part:FindFirstChild("BodyPosition") then
                    data.part.BodyPosition:Destroy()
                end
                if data.part:FindFirstChild("BodyGyro") then
                    data.part.BodyGyro:Destroy()
                end
            end
        end
        if groupData.primaryPart and groupData.primaryPart.Parent then
            local highlight = groupData.primaryPart:FindFirstChild("Highlight") or groupData.primaryPart.Parent:FindFirstChild("Highlight")
            if highlight then
                highlight:Destroy()
            end
        end
    end
    cleanupConnections(compileConnections)
    cleanupConnections(renderSteppedConnections)
    compiledGroups = {}
end

local function compileCoroutineFunc()
    while true do
        local success, err = pcall(function()
            for _, groupData in ipairs(compiledGroups) do
                if groupData.primaryPart and groupData.primaryPart.Parent then -- <--- 修正: 存在チェック
                    updateBodyMovers(groupData.primaryPart)
                end
            end
        end)
        if not success then warn("Error in compileCoroutineFunc: "..tostring(err)) end -- <--- [修正点 3]
        wait()
    end
end

local function unanchorPrimaryPart()
    if #anchoredParts == 0 then return end
    local primaryPart = anchoredParts[1]
    if not primaryPart or not primaryPart.Parent then return end -- <--- 修正: 存在チェック
    if primaryPart:FindFirstChild("BodyPosition") then
        primaryPart.BodyPosition:Destroy()
    end
    if primaryPart:FindFirstChild("BodyGyro") then
        primaryPart.BodyGyro:Destroy()
    end
    local highlight = primaryPart.Parent:FindFirstChild("Highlight") or primaryPart:FindFirstChild("Highlight")
    if highlight then
        highlight:Destroy()
    end
end

local function recoverParts()
    while true do
        local success, err = pcall(function()
            local character = localPlayer.Character -- <--- [修正点 2]
            if character and character:FindFirstChild("Head") and character:FindFirstChild("HumanoidRootPart") then
                local humanoidRootPart = character.HumanoidRootPart
                for _, partModel in pairs(anchoredParts) do
                    coroutine.wrap(function()
                        if partModel and partModel.Parent then -- <--- 修正: 存在チェック
                            local distance = (partModel.Position - humanoidRootPart.Position).Magnitude
                            if distance <= 30 then
                                local highlight = partModel:FindFirstChild("Highlight") or partModel.Parent:FindFirstChild("Highlight")
                                if highlight and highlight.OutlineColor == Color3.new(1, 0, 0) then
                                    SetNetworkOwner:FireServer(partModel, partModel.CFrame)
                                    local partOwner = partModel:WaitForChild("PartOwner", 0.5) -- <--- 修正: 少し待つ
                                    if partOwner and partOwner.Value == localPlayer.Name then
                                        highlight.OutlineColor = Color3.new(0, 0, 1)
                                    end
                                 end
                            end
                        end
                    end)()
                end
            end
        end)
        if not success then warn("Error in recoverParts: "..tostring(err)) end -- <--- [修正点 3]
        wait(0.02)
    end
end

local function ragdollAll()
    while true do
        local success, err = pcall(function()
            if not toysFolder then return end
            
            local character = localPlayer.Character -- <--- [修正点 2]
            if not character or not character:FindFirstChild("Head") then return end

            if not toysFolder:FindFirstChild("FoodBanana") then
                spawnItem("FoodBanana", Vector3.new(-72.9304581, -5.96906614, -265.543732))
            end
            local banana = toysFolder:WaitForChild("FoodBanana")
            local bananaPeel
            for _, part in pairs(banana:GetChildren()) do
                if part.Name == "BananaPeel" and part:FindFirstChild("TouchInterest") then
                    part.Size = Vector3.new(10, 10, 10)
                    part.Transparency = 1
                    bananaPeel = part
                    break
                end
            end
            if not bananaPeel then return end -- パーツが見つからなければリトライ
            
            local bodyPosition = Instance.new("BodyPosition")
            bodyPosition.P = 20000
            bodyPosition.Parent = banana.Main
            
            while true do
                local currentCharacter = localPlayer.Character -- <--- [修正点 2] 内側ループでも最新を取得
                if not currentCharacter or not currentCharacter:FindFirstChild("Head") then
                    bodyPosition:Destroy()
                    break
                end
                
                for _, player in pairs(Players:GetChildren()) do
                    pcall(function()
                        if player.Character and player.Character ~= currentCharacter then
                            bananaPeel.Position = player.Character.HumanoidRootPart.Position or player.Character.Head.Position
                            bodyPosition.Position = currentCharacter.Head.Position + Vector3.new(0, 600, 0)
                            wait()
                        end
                    end)
                end  
                wait()
            end
        end)
        if not success then warn("Error in ragdollAll: "..tostring(err)) end -- <--- [修正点 3]
        wait()
    end
end

local function reloadMissile(bool)
    if bool then
        if not ownedToys[_G.ToyToLoad] then
            OrionLib:MakeNotification({
                Name = "Missing toy",
                Content = "You do not own the ".._G.ToyToLoad.." toy.",
                Image = "rbxassetid://4483345998",
                Time = 3
            })
            return
        end
        if not reloadBombCoroutine then
            reloadBombCoroutine = coroutine.create(function()
                if not toysFolder then
                    warn("toysFolder not found in reloadMissile")
                    return
                end
                
                connectionBombReload = toysFolder.ChildAdded:Connect(function(child)
                    if child.Name == _G.ToyToLoad and child:WaitForChild("ThisToysNumber", 1) then
                        if child.ThisToysNumber.Value == (toysFolder.ToyNumber.Value - 1) then
                            local connection2
                            connection2 = toysFolder.ChildRemoved:Connect(function(child2)
                                if child2 == child then
                                    connection2:Disconnect()
                                end
                            end)
                            SetNetworkOwner:FireServer(child.Body, child.Body.CFrame)
                            local waiting = child.Body:WaitForChild("PartOwner", 0.5)
                            local connection = child.DescendantAdded:Connect(function(descendant)
                                if descendant.Name == "PartOwner" then
                                    if descendant.Value ~= localPlayer.Name then
                                        DestroyT(child)
                                        connection:Disconnect()
                                    end
                                end
                            end)
                            Debris:AddItem(connection, 60)
                            if waiting and waiting.Value == localPlayer.Name then
                                for _, v in pairs(child:GetChildren()) do
                                    if v:IsA("BasePart") then
                                        v.CanCollide = false
                                    end
                                end
                                child:SetPrimaryPartCFrame(CFrame.new(-72.9304581, -3.96906614, -265.543732))
                                wait(0.2)
                                for _, v in pairs(child:GetChildren()) do
                                    if v:IsA("BasePart") then
                                        v.Anchored = true
                                    end
                                end
                                table.insert(bombList, child)
                                child.AncestryChanged:Connect(function()
                                    if not child.Parent then
                                        for i, bomb in ipairs(bombList) do
                                            if bomb == child then
                                                table.remove(bombList, i)
                                                break
                                            end
                                        end
                                    end
                                end)
                                connection2:Disconnect()
                            else
                                DestroyT(child)
                            end
                        end
                    end
                end)
                while true do
                    local character = localPlayer.Character -- <--- [修正点 2]
                    if localPlayer.CanSpawnToy and localPlayer.CanSpawnToy.Value and #bombList < _G.MaxMissiles and character and character:FindFirstChild("Head") then
                        spawnItemCf(_G.ToyToLoad, character.Head.CFrame or character.HumanoidRootPart.CFrame)
                    end
                    RunService.Heartbeat:Wait()
                end
            end)
            coroutine.resume(reloadBombCoroutine)
        end
    else
        if reloadBombCoroutine then
            coroutine.close(reloadBombCoroutine)
            reloadBombCoroutine = nil
        end
        if connectionBombReload then
            connectionBombReload:Disconnect()
            connectionBombReload = nil -- <--- 修正: 切断後にnilに設定
        end
    end
end

local function setupAntiExplosion(character)
    if not character or not character:FindFirstChild("Humanoid") then return end
    local partOwner = character.Humanoid:FindFirstChild("Ragdolled")
    if partOwner then
        local partOwnerChangedConn
        partOwnerChangedConn = partOwner:GetPropertyChangedSignal("Value"):Connect(function()
            if partOwner.Value then
                for _, part in ipairs(character:GetChildren()) do
                    if part:IsA("BasePart") then
                        part.Anchored = true
                    end
                end
            else
                for _, part in ipairs(character:GetChildren()) do
                    if part:IsA("BasePart") then
                        part.Anchored = false
                    end
                end
            end
        end)
        antiExplosionConnection = partOwnerChangedConn
    end
end

local blobalter = 1
local function blobGrabPlayerTP(targetPlayer, blobman)
    if not targetPlayer or targetPlayer == localPlayer or not targetPlayer.Character or not targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
        return
    end
    local targetHRP = targetPlayer.Character.HumanoidRootPart
    local playerHRP = localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not playerHRP then return end
    
    local targetPos = targetHRP.CFrame
    playerHRP.CFrame = targetPos * CFrame.new(0, 5, 0)
    task.wait(_G.BlobmanDelay / 2)
    local blobmanHRP = blobman.PrimaryPart or blobman:FindFirstChild("Head") or blobman:FindFirstChild("Body")
    if blobmanHRP then
        blobmanHRP.CFrame = targetPos * CFrame.new(0, 1, 0)
    end
    task.wait(_G.BlobmanDelay / 2)
    
    if blobalter == 1 then
        local leftDetector = blobman:FindFirstChild("LeftDetector")
        if leftDetector then
            targetHRP.CFrame = leftDetector.CFrame * CFrame.new(0, 0, -3)
            task.wait(0.05)
            local args = {
                [1] = leftDetector,
                [2] = targetHRP,
                [3] = leftDetector:FindFirstChild("LeftWeld")
            }
            local script = blobman:WaitForChild("BlobmanSeatAndOwnerScript", 0.5)
            if script then
                local creatureGrab = script:WaitForChild("CreatureGrab", 0.5)
                if creatureGrab then
                    creatureGrab:FireServer(unpack(args))
                    blobalter = 2
                end
            end
        end
    else
        local rightDetector = blobman:FindFirstChild("RightDetector")
        if rightDetector then
            targetHRP.CFrame = rightDetector.CFrame * CFrame.new(0, 0, -3)
            task.wait(0.05)
            local args = {
                [1] = rightDetector,
                [2] = targetHRP,
                [3] = rightDetector:FindFirstChild("RightWeld")
            }
            local script = blobman:WaitForChild("BlobmanSeatAndOwnerScript", 0.5)
            if script then
                local creatureGrab = script:WaitForChild("CreatureGrab", 0.5)
                if creatureGrab then
                    creatureGrab:FireServer(unpack(args))
                    blobalter = 1
                end
            end
        end
    end
end

local function loopTPFunction(blobman)
    while true do
        local success, err = pcall(function() -- <--- [修正点 3] pcall追加
            local playersToTarget = {}
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= localPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") and p:FindFirstChild("IsHeld") and p.IsHeld.Value == false then -- <--- 修正: IsHeldの存在チェック
                    table.insert(playersToTarget, p)
                end
            end
            if #playersToTarget > 0 then
                local targetPlayer = playersToTarget[currentLoopTpPlayerIndex]
                if targetPlayer then
                    blobGrabPlayerTP(targetPlayer, blobman)
                end
                currentLoopTpPlayerIndex = currentLoopTpPlayerIndex + 1
                if currentLoopTpPlayerIndex > #playersToTarget then
                    currentLoopTpPlayerIndex = 1
                end
            else
                wait(0.5)
            end
        end)
        if not success then warn("Error in loopTPFunction: "..tostring(err)) end
        wait(_G.BlobmanDelay)
    end
end

-- GUI Setup
local Window = OrionLib:MakeWindow({
    Name = "野獣のおちんちんハブ", 
    HidePremium = false,
    SaveConfig = true,
    ConfigFolder = "野獣のおちんちんハブ",
    IntroEnabled = true,
    IntroText = "野獣のおちんちんハブ", 
    IntroIcon = "https://ibb.co/NgBCXdB6",
    Icon = "https://ibb.co/NgBCXdB6"
})

local GrabTab = Window:MakeTab({Name = "グラブ", Icon = "rbxassetid://18624615643", PremiumOnly = false})
local ObjectGrabTab = Window:MakeTab({Name = "オブジェクトグラブ", Icon = "rbxassetid://18624606749", PremiumOnly = false})
local DefenseTab = Window:MakeTab({Name = "ディフェンス", Icon = "rbxassetid://18624604880", PremiumOnly = false})
local BlobmanTab = Window:MakeTab({Name = "ブロブマン", Icon = "rbxassetid://18624614127", PremiumOnly = false})
local LineTab = Window:MakeTab({Name = "Line", Icon = "rbxassetid://18624615643", PremiumOnly = false}) -- Line Tab追加
local FunTab = Window:MakeTab({Name = "楽しい", Icon = "rbxassetid://18624603093", PremiumOnly = false})
local ScriptTab = Window:MakeTab({Name = "他スクリプト", Icon = "rbxassetid://11570626783", PremiumOnly = false})
local AuraTab = Window:MakeTab({Name = "オーラ", Icon = "rbxassetid://18624608005", PremiumOnly = false})
local CharacterTab = Window:MakeTab({Name = "キャラクター", Icon = "rbxassetid://18624601543", PremiumOnly = false})
local ExplosionTab = Window:MakeTab({Name = "爆弾", Icon = "rbxassetid://18624610285", PremiumOnly = false})
local KeybindsTab = Window:MakeTab({Name = "キービエンス", Icon = "rbxassetid://18624616682", PremiumOnly = false})
local DevTab = Window:MakeTab({Name = "デベロッパーテスト", Icon = "rbxassetid://18624599762", PremiumOnly = false})

local ThrowPower = 400

GrabTab:AddToggle({
    Name = "Stronger Throw",
    Default = false,
    Callback = function(enabled)
        if enabled then
            strengthConnection = workspace.ChildAdded:Connect(function(model) 
                if model.Name == "GrabParts" then
                    local grabPart = model:FindFirstChild("GrabPart")
                    local weld = grabPart and grabPart:FindFirstChild("WeldConstraint")
                    local partToImpulse = weld and weld.Part1

                    if partToImpulse then
                        local velocityObj = Instance.new("BodyVelocity")
                        velocityObj.Parent = partToImpulse
                        velocityObj.MaxForce = Vector3.zero 

                        model:GetPropertyChangedSignal("Parent"):Connect(function()
                            if not model.Parent then 
                                local lastInput = UserInputService:GetLastInputType()
                                if lastInput == Enum.UserInputType.MouseButton2 or lastInput == Enum.UserInputType.Touch then
                                    velocityObj.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                                    velocityObj.Velocity = workspace.CurrentCamera.CFrame.LookVector * ThrowPower 
                                    Debris:AddItem(velocityObj, 1)
                                else
                                    velocityObj:Destroy() 
                                end
                            end
                        end)
                    end
                end
            end)
        elseif strengthConnection then
            strengthConnection:Disconnect()
            strengthConnection = nil 
        end
    end
})

GrabTab:AddSlider({
    Name = "Throw Power",
    Min = 300,
    Max = 4000,
    ValueName = "Power", 
    Increment = 1,
    Default = 400, 
    Callback = function(value)
        ThrowPower = value 
    end
})

GrabTab:AddParagraph("Grab stuff", "These effects apply when you grab someone")

GrabTab:AddToggle({
    Name = "放射線グラブ",
    Default = false,
    Save = true,
    Color = Color3.fromRGB(240, 0, 0),
    Flag = "放射線グラブ",
    Callback = function(enabled)
        if enabled then
            poisonGrabCoroutine = coroutine.create(function() grabHandler("poison") end)
            coroutine.resume(poisonGrabCoroutine)
        else
            if poisonGrabCoroutine then
                coroutine.close(poisonGrabCoroutine)
                poisonGrabCoroutine = nil
                for _, part in pairs(poisonHurtParts) do
                    part.Position = Vector3.new(0, -200, 0)
                end
            end
        end
    end
})

GrabTab:AddToggle({
    Name = "Radioactive Grab",
    Default = false,
    Color = Color3.fromRGB(240, 0, 0),
    Save = true,
    Flag = "RadioactiveGrab",
    Callback = function(enabled)
        if enabled then
            ufoGrabCoroutine = coroutine.create(function() grabHandler("radioactive") end)
            coroutine.resume(ufoGrabCoroutine)
        else
            if ufoGrabCoroutine then
                coroutine.close(ufoGrabCoroutine)
                ufoGrabCoroutine = nil
                for _, part in pairs(paintPlayerParts) do
                    part.Position = Vector3.new(0, -200, 0)
                end
            end
        end
    end
})

GrabTab:AddToggle({
    Name = "炎グラブ",
    Default = false,
    Color = Color3.fromRGB(240, 0, 0),
    Save = true,
    Flag = "炎グラブ",
    Callback = function(enabled)
        if enabled then
            fireGrabCoroutine = coroutine.create(fireGrab)
            coroutine.resume(fireGrabCoroutine)
        else
            if fireGrabCoroutine then
                coroutine.close(fireGrabCoroutine)
                fireGrabCoroutine = nil
            end
        end
    end
})

GrabTab:AddToggle({
    Name = "ノークリップグラブ",
    Default = false,
    Color = Color3.fromRGB(240, 0, 0),
    Save = true,
    Flag = "ノークリップグラブ",
    Callback = function(enabled)
        if enabled then
            noclipGrabCoroutine = coroutine.create(noclipGrab)
            coroutine.resume(noclipGrabCoroutine)
        else
            if noclipGrabCoroutine then
                coroutine.close(noclipGrabCoroutine)
                noclipGrabCoroutine = nil
            end
        end
    end
})

GrabTab:AddToggle({
    Name = "キックグラブ",
    Color = Color3.fromRGB(240, 0, 0),
    Default = false,
    Save = true,
    Flag = "キックグラブ",
    Callback = function(enabled)
        if enabled then
            kickGrab()
        else
            cleanupConnections(kickGrabConnections) -- <--- 修正: 専用のクリーンアップ関数を使用
            kickGrabConnections = {} -- <--- 修正: テーブルをリセット
            
            for _, player in pairs(Players:GetPlayers()) do
                if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                    local hrp = player.Character.HumanoidRootPart
                    if hrp:FindFirstChild("FirePlayerPart") then
                        local fpp = hrp.FirePlayerPart
                        fpp.Size = Vector3.new(2.5, 5.5, 2.5)
                        fpp.CollisionGroup = "Default"
                        fpp.CanQuery = false
                    end
                end
            end
        end
    end
})

GrabTab:AddToggle({
    Name = "キックグラブ固定 (使うにはキックグラブをオンにして)",
    Default = false,
    Save = true,
    Color = Color3.fromRGB(240, 0, 0),
    Flag = "AnchorKickGrab",
    Callback = function(enabled)
        if enabled then
            if not anchorKickCoroutine or coroutine.status(anchorKickCoroutine) == "dead" then
                anchorKickCoroutine = coroutine.create(anchorKickGrab)
                coroutine.resume(anchorKickCoroutine)
            end
        else
            if anchorKickCoroutine and coroutine.status(anchorKickCoroutine) ~= "dead" then
                coroutine.close(anchorKickCoroutine)
                anchorKickCoroutine = nil
            end
        end
    end
})

GrabTab:AddParagraph("自分でスポーンさせたキャンプファイヤーがあったら消してください")

GrabTab:AddToggle({
    Name = "ファイヤーオール",
    Default = false,
    Color = Color3.fromRGB(240, 0, 0),
    Save = true,
    Callback = function(enabled)
        if enabled then
            if not fireAllCoroutine or coroutine.status(fireAllCoroutine) == "dead" then -- <--- 修正: 再開防止
                fireAllCoroutine = coroutine.create(fireAll)
                coroutine.resume(fireAllCoroutine)
            end
        else
            if fireAllCoroutine and coroutine.status(fireAllCoroutine) ~= "dead" then -- <--- 修正: ステータスチェック
                coroutine.close(fireAllCoroutine)
                fireAllCoroutine = nil
            end
            if toysFolder and toysFolder:FindFirstChild("Campfire") then -- <--- 修正: クリーンアップ
                DestroyT(toysFolder:FindFirstChild("Campfire"))
            end
        end
    end
})

ObjectGrabTab:AddParagraph("オブジェクトだけです")

ObjectGrabTab:AddToggle({
    Name = "固めるグラブ",
    Default = false,
    Color = Color3.fromRGB(240, 0, 0),
    Save = true,
    Flag = "AnchorGrab",
    Callback = function(enabled)
        if enabled then
            if not anchorGrabCoroutine or coroutine.status(anchorGrabCoroutine) == "dead" then
                anchorGrabCoroutine = coroutine.create(anchorGrab)
                coroutine.resume(anchorGrabCoroutine)
            end
        else
            if anchorGrabCoroutine and coroutine.status(anchorGrabCoroutine) ~= "dead" then
                coroutine.close(anchorGrabCoroutine)
                anchorGrabCoroutine = nil
            end
        end
    end
})

ObjectGrabTab:AddButton({
    Name = "全て解除",
    Callback = cleanupAnchoredParts
})

ObjectGrabTab:AddButton({
    Name = "コンパイル",
    Callback = function()
        compileGroup()
        if not compileCoroutine or coroutine.status(compileCoroutine) == "dead" then
            compileCoroutine = coroutine.create(compileCoroutineFunc)
            coroutine.resume(compileCoroutine)
        end
    end
})

ObjectGrabTab:AddButton({
    Name = "Disassemble Parts",
    Callback = function()
        cleanupCompiledGroups()
        cleanupAnchoredParts()
        if compileCoroutine and coroutine.status(compileCoroutine) ~= "dead" then
            coroutine.close(compileCoroutine)
            compileCoroutine = nil
        end
    end
})

ObjectGrabTab:AddToggle({
    Name = "落としたパーツを自動回復",
    Color = Color3.fromRGB(240, 0, 0),
    Default = false,
    Save = true,
    Flag = "AutoRecoverDroppedParts",
    Callback = function(enabled)
        if enabled then
            if not AutoRecoverDroppedPartsCoroutine or coroutine.status(AutoRecoverDroppedPartsCoroutine) == "dead" then
                AutoRecoverDroppedPartsCoroutine = coroutine.create(recoverParts)
                coroutine.resume(AutoRecoverDroppedPartsCoroutine)
            end
        else
            if AutoRecoverDroppedPartsCoroutine and coroutine.status(AutoRecoverDroppedPartsCoroutine) ~= "dead" then
                coroutine.close(AutoRecoverDroppedPartsCoroutine)
                AutoRecoverDroppedPartsCoroutine = nil
            end
        end
    end
})

ObjectGrabTab:AddButton({
    Name = "Unanchor Header Part",
    Callback = unanchorPrimaryPart
})

DefenseTab:AddLabel("グラブディフェンス")

DefenseTab:AddToggle({
    Name = "アンチグラブ",
    Color = Color3.fromRGB(240, 0, 0),
    Default = false,
    Save = true,
    Flag = "AutoStruggle",
    Callback = function(enabled)
        if enabled then
            autoStruggleCoroutine = RunService.Heartbeat:Connect(function()
                local success, err = pcall(function() -- <--- [修正点 3]
                    local character = localPlayer.Character -- <--- [修正点 2]
                    if character and character:FindFirstChild("Head") then
                        local head = character.Head
                        local partOwner = head:FindFirstChild("PartOwner")
                        if partOwner and localPlayer:FindFirstChild("IsHeld") and localPlayer.IsHeld.Value == true then -- <--- 修正: IsHeldチェック
                            Struggle:FireServer()
                            ReplicatedStorage.GameCorrectionEvents.StopAllVelocity:FireServer()
                            for _, part in pairs(character:GetChildren()) do
                                if part:IsA("BasePart") then
                                    part.Anchored = true
                                end
                            end
                            while localPlayer.IsHeld.Value do
                                Struggle:FireServer() -- <--- 修正: ループ中もStruggle
                                wait()
                            end
                            for _, part in pairs(character:GetChildren()) do
                                if part:IsA("BasePart") then
                                    part.Anchored = false
                                end
                            end
                        end
                    end
                end)
                if not success then warn("Error in AutoStruggle: "..tostring(err)) end
            end)
        else
            if autoStruggleCoroutine then
                autoStruggleCoroutine:Disconnect()
                autoStruggleCoroutine = nil
            end
        end
    end
})

DefenseTab:AddToggle({
    Name = "アンチキックグラブ",
    Default = false,
    Color = Color3.fromRGB(240, 0, 0),
    Save = true,
    Flag = "AntiKickGrab",
    Callback = function(enabled)
        if enabled then
            antiKickCoroutine = RunService.Heartbeat:Connect(function()
                local success, err = pcall(function() -- <--- [修正点 3]
                    local character = localPlayer.Character -- <--- [修正点 2]
                    if character and character:FindFirstChild("HumanoidRootPart") and character.HumanoidRootPart:FindFirstChild("FirePlayerPart") then
                        local partOwner = character.HumanoidRootPart.FirePlayerPart:FindFirstChild("PartOwner")
                        if partOwner and partOwner.Value ~= localPlayer.Name then
                            local args = {[1] = character:WaitForChild("HumanoidRootPart"), [2] = 0}
                            game:GetService("ReplicatedStorage"):WaitForChild("CharacterEvents"):WaitForChild("RagdollRemote"):FireServer(unpack(args))
                            wait(0.1)
                            Struggle:FireServer()
                        end
                    end
                end)
                if not success then warn("Error in AntiKickGrab: "..tostring(err)) end
            end)
        else
            if antiKickCoroutine then
                antiKickCoroutine:Disconnect()
                antiKickCoroutine = nil
            end
        end
    end
})

DefenseTab:AddToggle({
    Name = "アンチ爆弾",
    Default = false,
    Color = Color3.fromRGB(240, 0, 0),
    Save = true,
    Flag = "AntiExplosion",
    Callback = function(enabled)
        if enabled then
            if localPlayer.Character then
                setupAntiExplosion(localPlayer.Character)
            end
            characterAddedConn = localPlayer.CharacterAdded:Connect(function(character)
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

DefenseTab:AddLabel("自己防御")

DefenseTab:AddToggle({
    Name = "エアサスペンション",
    Color = Color3.fromRGB(240, 0, 0),
    Default = false,
    Save = true,
    Flag = "SelfDefenseAirSuspend",
    Callback = function(enabled)
        if enabled then
            if not autoDefendCoroutine or coroutine.status(autoDefendCoroutine) == "dead" then -- <--- 修正: 再開防止
                autoDefendCoroutine = coroutine.create(function()
                    while true do -- <--- 修正: enabledフラグではなくcoroutine.closeで制御
                        local success, err = pcall(function() -- <--- [修正点 3]
                            local character = localPlayer.Character -- <--- [修正点 2]
                            if character and character:FindFirstChild("Head") then
                                local head = character.Head
                                local partOwner = head:FindFirstChild("PartOwner")
                                if partOwner and partOwner.Value ~= localPlayer.Name then -- <--- 修正: 自分以外
                                    local attacker = Players:FindFirstChild(partOwner.Value)
                                    if attacker and attacker.Character and attacker.Character:FindFirstChild("HumanoidRootPart") and attacker.Character.HumanoidRootPart:FindFirstChild("FirePlayerPart") then -- <--- 修正: nilチェック追加
                                        Struggle:FireServer()
                                        SetNetworkOwner:FireServer(attacker.Character.Head or attacker.Character.Torso, attacker.Character.HumanoidRootPart.FirePlayerPart.CFrame)
                                        task.wait(0.1)
                                        local target = attacker.Character:FindFirstChild("Torso")
                                        if target then
                                            local velocity = target:FindFirstChild("l") or Instance.new("BodyVelocity")
                                            velocity.Name = "l"
                                            velocity.Parent = target
                                            velocity.Velocity = Vector3.new(0, 50, 0)
                                            velocity.MaxForce = Vector3.new(0, math.huge, 0)
                                            Debris:AddItem(velocity, 100) -- <--- 修正: 100秒は長すぎるかも？ 5秒に変更
                                            Debris:AddItem(velocity, 5)
                                        end
                                    end
                                end
                            end
                        end)
                        if not success then warn("Error in SelfDefenseAirSuspend: "..tostring(err)) end
                        wait(0.02)
                    end
                end)
                coroutine.resume(autoDefendCoroutine)
            end
        else
            if autoDefendCoroutine and coroutine.status(autoDefendCoroutine) ~= "dead" then -- <--- 修正: ステータスチェック
                coroutine.close(autoDefendCoroutine)
                autoDefendCoroutine = nil
            end
        end
    end
})

DefenseTab:AddToggle({
    Name = "アンチキック-サイレント",
    Default = false,
    Save = true,
    Color = Color3.fromRGB(240, 0, 0),
    Flag = "SelfDefenseKick",
    Callback = function(enabled)
        if enabled then
            if not autoDefendKickCoroutine or coroutine.status(autoDefendKickCoroutine) == "dead" then -- <--- 修正: 再開防止
                autoDefendKickCoroutine = coroutine.create(function()
                    while true do -- <--- 修正: enabledフラグではなくcoroutine.closeで制御
                        local success, err = pcall(function() -- <--- [修正点 3]
                            local character = localPlayer.Character -- <--- [修正点 2]
                            if character and character:FindFirstChild("HumanoidRootPart") then
                                local head = character:FindFirstChild("Head")
                                if head then
                                    local partOwner = head:FindFirstChild("PartOwner")
                                    if partOwner and partOwner.Value ~= localPlayer.Name then -- <--- 修正: 自分以外
                                        local attacker = Players:FindFirstChild(partOwner.Value)
                                        if attacker and attacker.Character and attacker.Character:FindFirstChild("HumanoidRootPart") and attacker.Character.HumanoidRootPart:FindFirstChild("FirePlayerPart") then -- <--- 修正: nilチェック追加
                                            Struggle:FireServer()
                                            SetNetworkOwner:FireServer(attacker.Character.HumanoidRootPart.FirePlayerPart, attacker.Character.HumanoidRootPart.FirePlayerPart.CFrame)
                                            task.wait(0.1)
                                            if not attacker.Character.HumanoidRootPart.FirePlayerPart:FindFirstChild("BodyVelocity") then
                                                local bodyVelocity = Instance.new("BodyVelocity")
                                                bodyVelocity.Name = "BodyVelocity"
                                                bodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                                                bodyVelocity.Velocity = Vector3.new(0, 20, 0)
                                                bodyVelocity.Parent = attacker.Character.HumanoidRootPart.FirePlayerPart
                                            end
                                        end
                                    end
                                end
                            end
                        end)
                        if not success then warn("Error in SelfDefenseKick: "..tostring(err)) end
                        wait(0.02)
                    end
                end)
                coroutine.resume(autoDefendKickCoroutine)
            end
        else
            if autoDefendKickCoroutine and coroutine.status(autoDefendKickCoroutine) ~= "dead" then -- <--- 修正: ステータスチェック
                coroutine.close(autoDefendKickCoroutine)
                autoDefendKickCoroutine = nil
            end
        end
    end
})

DefenseTab:AddLabel("その他")
DefenseTab:AddButton({
    Name = "家のバリア破壊",
    Callback = function()
        executeBarrierBreak()
    end
})

-- Blobman Tab (機能整理済み)
BlobmanTab:AddToggle({
    Name = "自動で座る",
    Default = false,
    Color = Color3.fromRGB(240, 0, 0),
    Save = true,
    Flag = "AutoSitBlobman",
    Callback = function(enabled)
        AutoSitEnabled = enabled
    end
})

local blobman1
blobman1 = BlobmanTab:AddToggle({
    Name = "キックオール(性能が低いため使うことはお勧めしない)",
    Color = Color3.fromRGB(240, 0, 0),
    Default = false,
    Callback = function(enabled)
        if enabled then
            if not loopTpCoroutine or coroutine.status(loopTpCoroutine) == "dead" then -- <--- 修正: 再開防止
                loopTpCoroutine = coroutine.create(function()
                    local foundBlobman = false
                    local character = localPlayer.Character -- <--- [修正点 2]
                    if not character then
                        OrionLib:MakeNotification({Name = "Error", Content = "キャラクターが見つかりません", Image = "rbxassetid://4483345998", Time = 5})
                        blobman1:Set(false)
                        return
                    end
                    
                    for i, v in pairs(game.Workspace:GetDescendants()) do
                        if v:IsA("Model") and v.Name == "CreatureBlobman" then
                            if v:FindFirstChild("VehicleSeat") and v.VehicleSeat:FindFirstChild("SeatWeld") and isDescendantOf(v.VehicleSeat.SeatWeld.Part1, character) then
                                blobman = v
                                foundBlobman = true
                                break
                            end
                        end
                    end
                    
                    if not foundBlobman then
                        OrionLib:MakeNotification({
                            Name = "Error",
                            Content = "ブロブマンに乗ってからトグルをオンにしてください", 
                            Image = "rbxassetid://4483345998", 
                            Time = 5
                        })
                        blobman1:Set(false)
                        blobman = nil
                        return
                    end
                    currentLoopTpPlayerIndex = 1
                    loopTPFunction(blobman)
                end)
                coroutine.resume(loopTpCoroutine)
            end
        else
            if loopTpCoroutine and coroutine.status(loopTpCoroutine) ~= "dead" then -- <--- 修正: ステータスチェック
                coroutine.close(loopTpCoroutine)
                loopTpCoroutine = nil
                blobman = nil
            end
        end
    end
})

BlobmanTab:AddSlider({
    Name = "テレポート時間",
    Min = 0.0005,
    Max = 1,
    Color = Color3.fromRGB(240, 0, 0),
    ValueName = "sec",
    Increment = 0.001,
    Default = _G.BlobmanDelay,
    Callback = function(value)
        _G.BlobmanDelay = value
    end
})

-- Line Tab
if DataEvents and DataEvents:FindFirstChild("UpdateLineColorsEvent") then
    -- Line Tabの機能を有効化
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
                task.spawn(function()
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
                task.spawn(function()
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
                task.spawn(function()
                    while lineLagEnabled and lineLagAllEnabled do
                        local success, err = pcall(function() -- <--- [修正点 3]
                            for _, player in pairs(Players:GetPlayers()) do
                                if player ~= localPlayer and lineLagEnabled and lineLagAllEnabled then
                                    CreateLineLag(player)
                                    wait(lineLagSpeed)
                                end
                            end
                        end)
                        if not success then warn("Error in Line Lag (All): "..tostring(err)) end
                        wait(0.01)
                    end
                end)
                OrionLib:MakeNotification({
                    Name = "Line Lag",
                    Content = "Enabled (All Players)!",
                    Image = "rbxassetid://4483345998",
                    Time = 2
                })
            else
                OrionLib:MakeNotification({
                    Name = "Line Lag",
                    Content = "Disabled!",
                    Image = "rbxassetid://4483345998",
                    Time = 2
                })
            end
        end
    })

    LineTab:AddSection({Name = "Target Specific Player"})

    local LineLagTargetDropdown = LineTab:AddDropdown({
        Name = "Select Player for Line Lag",
        Default = "",
        Options = getPlayerNamesForDropdown(),
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
                task.spawn(function()
                    while lineLagEnabled and not lineLagAllEnabled and lineLagTarget do
                        local success, err = pcall(function() -- <--- [修正点 3]
                            CreateLineLag(lineLagTarget)
                        end)
                        if not success then warn("Error in Line Lag (Single): "..tostring(err)) end
                        wait(0.01)
                    end
                end)
                OrionLib:MakeNotification({
                    Name = "Line Lag",
                    Content = "Single target enabled!",
                    Image = "rbxassetid://4483345998",
                    Time = 2
                })
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
            LineLagTargetDropdown:Refresh(getPlayerNamesForDropdown(), true)
            OrionLib:MakeNotification({
                Name = "Refreshed",
                Content = "Player list updated!",
                Image = "rbxassetid://4483345998",
                Time = 2
            })
        end
    })

    LineTab:AddSection({Name = "FartherReach Visual"})

    LineTab:AddToggle({
        Name = "FartherReach Visual",
        Default = false,
        Callback = function(enabled)
            fartherReachEnabled = enabled
            local success, err = pcall(function() -- <--- [修正点 3]
                if not localPlayer:FindFirstChild("FartherReach") then
                    local fartherReach = Instance.new("BoolValue")
                    fartherReach.Name = "FartherReach"
                    fartherReach.Value = false
                    fartherReach.Parent = localPlayer
                end
                wait(0.1)
                localPlayer.FartherReach.Value = enabled
            end)
            if not success then warn("Error in FartherReach: "..tostring(err)) end
            
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
                task.spawn(function()
                    while invisibleLineEnabled do
                        local success, err = pcall(function() -- <--- [修正点 3]
                            if CreateLine then
                                CreateLine:FireServer()
                            end
                        end)
                        if not success then warn("Error in Invisible Line: "..tostring(err)) end
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
else
    -- DataEventsが見つからない場合の警告
    LineTab:AddParagraph("注意", "Line機能に必要なDataEventsが見つかりません")
end

-- Fun Tab
FunTab:AddLabel("クローン操作")

FunTab:AddSlider({
    Name = "Offset",
    Min = 1,
    Max = 10,
    Color = Color3.fromRGB(240, 0, 0),
    ValueName = ".",
    Increment = 1,
    Default = decoyOffset,
    Callback = function(value)
        decoyOffset = value
    end
})

FunTab:AddTextbox({
    Name = "Circle Radius",
    Default = "Radius for Surround Mode (Adjust based on clones)",
    TextDisappear = false,
    Callback = function(value)
        circleRadius = tonumber(value) or 10
    end
})

FunTab:AddButton({
    Name = "デコイフォロー",
    Callback = function()
        local decoys = {}
        for _, descendant in pairs(workspace:GetDescendants()) do
            if descendant:IsA("Model") and descendant.Name == "YouDecoy" then
                table.insert(decoys, descendant)
            end
        end
        local numDecoys = #decoys
        local midPoint = math.ceil(numDecoys / 2)

        local function updateDecoyPositions()
            local character = localPlayer.Character -- <--- [修正点 2]
            
            for index, decoy in pairs(decoys) do
                if not decoy or not decoy.Parent then continue end -- <--- 修正: デコイ存在チェック
                
                local torso = decoy:FindFirstChild("Torso")
                if torso then
                    local bodyPosition = torso:FindFirstChild("BodyPosition")
                    local bodyGyro = torso:FindFirstChild("BodyGyro")
                    if bodyPosition and bodyGyro then
                        local targetPosition
                        if followMode then
                            if character and character:FindFirstChild("HumanoidRootPart") then
                                targetPosition = character.HumanoidRootPart.Position
                                local offset = (index - midPoint) * decoyOffset
                                local forward = character.HumanoidRootPart.CFrame.LookVector
                                local right = character.HumanoidRootPart.CFrame.RightVector
                                targetPosition = targetPosition - forward * decoyOffset + right * offset
                            end
                        else
                            local nearestPlayer = getNearestPlayer()
                            if nearestPlayer and nearestPlayer.Character and nearestPlayer.Character:FindFirstChild("HumanoidRootPart") then
                                local angle = math.rad((index - 1) * (360 / numDecoys))
                                targetPosition = nearestPlayer.Character.HumanoidRootPart.Position + Vector3.new(math.cos(angle) * circleRadius, 0, math.sin(angle) * circleRadius)
                                bodyGyro.CFrame = CFrame.new(torso.Position, nearestPlayer.Character.HumanoidRootPart.Position)
                            end
                        end

                        if targetPosition then
                            local distance = (targetPosition - torso.Position).Magnitude
                            if distance > stopDistance then
                                bodyPosition.Position = targetPosition
                                if followMode and character then -- <--- 修正: nilチェック
                                    bodyGyro.CFrame = CFrame.new(torso.Position, targetPosition)
                                end
                            else
                                bodyPosition.Position = torso.Position
                                bodyGyro.CFrame = torso.CFrame
                            end
                        end
                    end
                end
            end
        end

        local function setupDecoy(decoy)
            local torso = decoy:FindFirstChild("Torso")
            if torso then
                local bodyPosition = Instance.new("BodyPosition")
                local bodyGyro = Instance.new("BodyGyro")
                bodyPosition.Parent = torso
                bodyGyro.Parent = torso
                bodyPosition.MaxForce = Vector3.new(40000, 40000, 40000)
                bodyPosition.D = 100
                bodyPosition.P = 100
                bodyGyro.MaxTorque = Vector3.new(40000, 40000, 40000)
                bodyGyro.D = 100
                bodyGyro.P = 20000
                local connection = RunService.Heartbeat:Connect(function()
                    updateDecoyPositions()
                end)
                table.insert(connections, connection)
                
                local character = localPlayer.Character -- <--- [修正点 2]
                if character and character:FindFirstChild("Head") then
                    SetNetworkOwner:FireServer(torso, character.Head.CFrame)
                end
            end
        end

        for _, decoy in pairs(decoys) do
            setupDecoy(decoy)
        end
        OrionLib:MakeNotification({Name = "Notification", Content = "Got "..numDecoys.." units. Manually click each unit if they don't move", Image = "rbxassetid://4483345998", Time = 5})
    end
})

FunTab:AddButton({
    Name = "Toggle Mode",
    Callback = function()
        followMode = not followMode
    end
})

FunTab:AddButton({
    Name = "Disconnect Clones",
    Callback = function()
        cleanupConnections(connections)
        connections = {} 
    end
})

-- Script Tab
ScriptTab:AddButton({
    Name = "Infinite Yield",
    Callback = function()
       loadstring(game:HttpGet("https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source",true))()
    end
})

ScriptTab:AddButton({
    Name = "Infinite Yield REBORN",
    Callback = function()
        loadstring(game:HttpGet("https://github.com/fuckusfm/infiniteyield-reborn/raw/master/source"))()
    end
})

ScriptTab:AddButton({
    Name = "Dark Dex V3",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/Babyhamsta/RBLX_Scripts/main/Universal/BypassedDarkDexV3.lua", true))()
    end
})

-- Aura Tab
AuraTab:AddLabel("オーラ")

AuraTab:AddSlider({
    Name = "距離",
    Min = 5,
    Max = 100,
    Color = Color3.fromRGB(240, 0, 0),
    ValueName = ".",
    Increment = 1,
    Default = auraRadius,
    Callback = function(value)
        auraRadius = value
    end
})

AuraTab:AddToggle({
    Name = "エアサスペンドオーラ",
    Color = Color3.fromRGB(240, 0, 0),
    Default = false,
    Save = true,
    Callback = function(enabled)
        if enabled then
            if not auraCoroutine or coroutine.status(auraCoroutine) == "dead" then -- <--- 修正: 再開防止
                auraCoroutine = coroutine.create(function()
                    while true do -- <--- 修正: coroutine.closeで制御
                        local success, err = pcall(function()
                            local character = localPlayer.Character -- <--- [修正点 2]
                            if character and character:FindFirstChild("Head") and character:FindFirstChild("HumanoidRootPart") then
                                local humanoidRootPart = character.HumanoidRootPart

                                for _, player in pairs(Players:GetPlayers()) do
                                    coroutine.wrap(function()
                                        if player ~= localPlayer and player.Character then
                                            local playerCharacter = player.Character
                                            local playerTorso = playerCharacter:FindFirstChild("Torso")
                                            if playerTorso and playerCharacter:FindFirstChild("HumanoidRootPart") and playerCharacter.HumanoidRootPart:FindFirstChild("FirePlayerPart") then -- <--- 修正: nilチェック
                                                local distance = (playerTorso.Position - humanoidRootPart.Position).Magnitude
                                                if distance <= auraRadius then
                                                    SetNetworkOwner:FireServer(playerTorso, playerCharacter.HumanoidRootPart.FirePlayerPart.CFrame)
                                                    task.wait(0.1)
                                                    local velocity = playerTorso:FindFirstChild("l") or Instance.new("BodyVelocity", playerTorso)
                                                    velocity.Name = "l"
                                                    velocity.Velocity = Vector3.new(0, 50, 0)
                                                    velocity.MaxForce = Vector3.new(0, math.huge, 0)
                                                    Debris:AddItem(velocity, 5) -- <--- 修正: 100秒 -> 5秒
                                                end
                                            end
                                        end
                                    end)()
                                end
                            end
                        end)
                        if not success then
                            warn("Error in Air Suspend Aura: " .. tostring(err))
                        end
                        wait(0.02)
                    end
                end)
                coroutine.resume(auraCoroutine)
            end
        else
            if auraCoroutine and coroutine.status(auraCoroutine) ~= "dead" then -- <--- 修正: ステータスチェック
                coroutine.close(auraCoroutine)
                auraCoroutine = nil
            end
        end
    end
})

AuraTab:AddToggle({
    Name = "奈落オーラ",
    Default = false,
    Color = Color3.fromRGB(240, 0, 0),
    Save = true,
    Callback = function(enabled)
        if enabled then
            if not gravityCoroutine or coroutine.status(gravityCoroutine) == "dead" then -- <--- 修正: 再開防止
                gravityCoroutine = coroutine.create(function()
                    while true do -- <--- 修正: coroutine.closeで制御
                        local success, err = pcall(function()
                            local character = localPlayer.Character -- <--- [修正点 2]
                            if character and character:FindFirstChild("HumanoidRootPart") then
                                local humanoidRootPart = character.HumanoidRootPart

                                for _, player in pairs(Players:GetPlayers()) do
                                    if player ~= localPlayer and player.Character then
                                        local playerCharacter = player.Character
                                        local playerTorso = playerCharacter:FindFirstChild("Torso")
                                        if playerTorso and playerCharacter:FindFirstChild("HumanoidRootPart") and playerCharacter.HumanoidRootPart:FindFirstChild("FirePlayerPart") then -- <--- 修正: nilチェック
                                            local distance = (playerTorso.Position - humanoidRootPart.Position).Magnitude
                                            if distance <= auraRadius then
                                                SetNetworkOwner:FireServer(playerTorso, humanoidRootPart.FirePlayerPart.CFrame)
                                                task.wait(0.1)
                                                local force = playerTorso:FindFirstChild("GravityForce") or Instance.new("BodyForce")
                                                force.Parent = playerTorso
                                                force.Name = "GravityForce"
                                                for _, part in ipairs(playerCharacter:GetDescendants()) do
                                                    if part:IsA("BasePart") then
                                                        part.CanCollide = false
                                                    end
                                                end
                                                force.Force = Vector3.new(0, -1200, 0) 
                                            end
                                        end
                                    end
                                end
                            end
                        end)
                        if not success then
                            warn("Error in Hell send Aura: " .. tostring(err))
                        end
                        wait(0.02)
                    end
                end)
                coroutine.resume(gravityCoroutine)
            end
        elseif gravityCoroutine and coroutine.status(gravityCoroutine) ~= "dead" then -- <--- 修正: ステータスチェック
            coroutine.close(gravityCoroutine)
            gravityCoroutine = nil
        end
    end
})

AuraTab:AddToggle({
    Name = "キックオーラ",
    Color = Color3.fromRGB(240, 0, 0),
    Default = false,
    Save = true,
    Callback = function(enabled)
        if enabled then -- <--- 修正: enabledチェックを外側に
            if not kickCoroutine or coroutine.status(kickCoroutine) == "dead" then -- <--- 修正: 再開防止
                kickCoroutine = coroutine.create(function()
                    while true do -- <--- 修正: coroutine.closeで制御
                        if auraToggle == 1 then -- サイレント
                            local success, err = pcall(function()
                                local character = localPlayer.Character -- <--- [修正点 2]
                                if character and character:FindFirstChild("HumanoidRootPart") then
                                    local humanoidRootPart = character.HumanoidRootPart

                                    for _, player in pairs(Players:GetPlayers()) do
                                        if player ~= localPlayer and player.Character then
                                            local playerCharacter = player.Character
                                            local playerTorso = playerCharacter:FindFirstChild("Head")

                                            if playerTorso and playerCharacter:FindFirstChild("HumanoidRootPart") and playerCharacter.HumanoidRootPart:FindFirstChild("FirePlayerPart") then -- <--- 修正: nilチェック
                                                local distance = (playerTorso.Position - humanoidRootPart.Position).Magnitude
                                                if distance <= auraRadius then
                                                    SetNetworkOwner:FireServer(playerCharacter.HumanoidRootPart.FirePlayerPart, playerCharacter.HumanoidRootPart.FirePlayerPart.CFrame)
                                                    if not platforms[player] then
                                                        local platform = playerCharacter:FindFirstChild("FloatingPlatform") or Instance.new("Part")
                                                        platform.Name = "FloatingPlatform"
                                                        platform.Size = Vector3.new(5, 2, 5)
                                                        platform.Anchored = true
                                                        platform.Transparency = 1
                                                        platform.CanCollide = true
                                                        platform.Parent = playerCharacter
                                                        platforms[player] = platform
                                                    end
                                                end
                                            end
                                        end
                                    end
                                    for player, platform in pairs(platforms) do
                                        if player.Character and player.Character.Humanoid and player.Character.Humanoid.Health > 1 and player.Character:FindFirstChild("HumanoidRootPart") then -- <--- 修正: nilチェック
                                            local playerHumanoidRootPart = player.Character.HumanoidRootPart
                                            platform.Position = playerHumanoidRootPart.Position - Vector3.new(0, 3.994, 0)
                                        else
                                            if platform then platform:Destroy() end 
                                            platforms[player] = nil
                                        end
                                    end
                                end
                            end)
                            if not success then
                                warn("Error in Kick Aura (Silent): " .. tostring(err))
                            end
                        elseif auraToggle == 2 then -- 空
                            local success, err = pcall(function()
                                local character = localPlayer.Character -- <--- [修正点 2]
                                if character and character:FindFirstChild("HumanoidRootPart") then
                                    local humanoidRootPart = character.HumanoidRootPart

                                    for _, player in pairs(Players:GetPlayers()) do
                                        if player ~= localPlayer and player.Character then
                                            local playerCharacter = player.Character
                                            local playerTorso = playerCharacter:FindFirstChild("Head")

                                            if playerTorso and playerCharacter:FindFirstChild("HumanoidRootPart") and playerCharacter.HumanoidRootPart:FindFirstChild("FirePlayerPart") then -- <--- 修正: nilチェック
                                                local distance = (playerTorso.Position - humanoidRootPart.Position).Magnitude
                                                if distance <= auraRadius then
                                                    SetNetworkOwner:FireServer(playerCharacter.HumanoidRootPart.FirePlayerPart, playerCharacter.HumanoidRootPart.FirePlayerPart.CFrame)
                                                    if not playerCharacter.HumanoidRootPart.FirePlayerPart:FindFirstChild("BodyVelocity") then
                                                        local bodyVelocity = Instance.new("BodyVelocity")
                                                        bodyVelocity.Name = "BodyVelocity"
                                                        bodyVelocity.Velocity = Vector3.new(0, 20, 0) 
                                                        bodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                                                        bodyVelocity.Parent = playerCharacter.HumanoidRootPart.FirePlayerPart
                                                    end
                                                end
                                            end
                                        end
                                    end
                                end
                            end)
                            if not success then
                                warn("Error in Kick Aura (Sky mode): " .. tostring(err))
                            end
                        end
                        wait(0.02)
                    end
                end)
                coroutine.resume(kickCoroutine)
            end
        else -- enabled == false
            if kickCoroutine and coroutine.status(kickCoroutine) ~= "dead" then -- <--- 修正: ステータスチェック
                coroutine.close(kickCoroutine)
                kickCoroutine = nil
            end
            if auraToggle == 1 then -- サイレントモードだった場合のみプラットフォームを削除
                for _, platform in pairs(platforms) do
                    if platform then
                        platform:Destroy()
                    end
                end
                platforms = {}
            end
        end
    end
})


AuraTab:AddDropdown({
    Name = "キックの種類",
    Options = {"サイレント", "空"},
    Default = "サイレント", 
    Save = true,
    Flag = "KickModeFlag",
    Callback = function(selected)
        if selected == "空" then 
            auraToggle = 2 
        else 
            auraToggle = 1 
            -- <--- 修正: モード変更時に「空」モードのBodyVelocityをクリーンアップ（必要なら）
            -- ただし、現在のキックオーラロジックはトグルOFF時にクリーンアップしないため、
            -- ここでもクリーンアップしない方が一貫性があるかもしれない。
            -- もし「空」→「サイレント」に変更した際にBodyVelocityが残るのが問題なら、ここで全プレイヤーのFPPからBodyVelocityを削除する処理が必要。
        end
    end
})

AuraTab:AddToggle({
    Name = "放射線オーラ",
    Default = false,
    Color = Color3.fromRGB(240, 0, 0),
    Save = true,
    Callback = function(enabled)
        if enabled then
            if not poisonAuraCoroutine or coroutine.status(poisonAuraCoroutine) == "dead" then -- <--- 修正: 再開防止
                poisonAuraCoroutine = coroutine.create(function()
                    while true do -- <--- 修正: coroutine.closeで制御
                        local success, err = pcall(function()
                            local character = localPlayer.Character -- <--- [修正点 2]
                            if character and character:FindFirstChild("HumanoidRootPart") then
                                local humanoidRootPart = character.HumanoidRootPart

                                for _, player in pairs(Players:GetPlayers()) do
                                    if player ~= localPlayer and player.Character then
                                        local playerCharacter = player.Character
                                        local playerTorso = playerCharacter:FindFirstChild("Torso")
                                        if playerTorso and playerCharacter:FindFirstChild("HumanoidRootPart") then -- <--- 修正: nilチェック
                                            local distance = (playerTorso.Position - humanoidRootPart.Position).Magnitude
                                            if distance <= auraRadius then
                                                local head = playerCharacter:FindFirstChild("Head")
                                                if not head then continue end -- <--- 修正: headチェック
                                                
                                                -- <--- 修正: この内部ループは危険。プレイヤーが範囲内にいる限り外側のループをブロックする
                                                -- while distance <= auraRadius and player.Character and player.Character:FindFirstChild("Torso") do 
                                                -- 
                                                --     SetNetworkOwner:FireServer(playerTorso, playerCharacter.HumanoidRootPart.CFrame)
                                                --     distance = (playerTorso.Position - humanoidRootPart.Position).Magnitude
                                                --     for _, part in pairs(poisonHurtParts) do
                                                --         part.Size = Vector3.new(1, 3, 1)
                                                --         part.Transparency = 1
                                                --         part.Position = head.Position
                                                --     end
                                                --     wait()
                                                --     for _, part in pairs(poisonHurtParts) do
                                                --         part.Position = Vector3.new(0, -200, 0)
                                                --     end
                                                -- end
                                                
                                                -- <--- 修正案: 内部ループを削除し、1回だけ実行する
                                                SetNetworkOwner:FireServer(playerTorso, playerCharacter.HumanoidRootPart.CFrame)
                                                for _, part in pairs(poisonHurtParts) do
                                                    part.Size = Vector3.new(1, 3, 1)
                                                    part.Transparency = 1
                                                    part.Position = head.Position
                                                end
                                                task.wait() -- 1フレーム待機
                                                for _, part in pairs(poisonHurtParts) do
                                                    part.Position = Vector3.new(0, -200, 0)
                                                end
                                                -- <--- 修正案ここまで
                                                
                                            end
                                        end
                                    end
                                end
                            end
                        end)
                        if not success then
                            warn("Error in Poison Aura: " .. tostring(err))
                        end
                        wait(0.02)
                    end
                end)
                coroutine.resume(poisonAuraCoroutine)
            end
        elseif poisonAuraCoroutine and coroutine.status(poisonAuraCoroutine) ~= "dead" then -- <--- 修正: ステータスチェック
            coroutine.close(poisonAuraCoroutine)
            for _, part in pairs(poisonHurtParts) do
                part.Position = Vector3.new(0, -200, 0)
            end
            poisonAuraCoroutine = nil
        end
    end
})

-- Character Tab
CharacterTab:AddToggle({
    Name = "しゃがみ速度",
    Default = false,
    Save = true,
    Color = Color3.fromRGB(240, 0, 0),
    Flag = "CrouchSpeed",
    Callback = function(enabled)
        if enabled then
            if not crouchSpeedCoroutine or coroutine.status(crouchSpeedCoroutine) == "dead" then -- <--- 修正: 再開防止
                crouchSpeedCoroutine = coroutine.create(function()
                    while true do -- <--- 修正: coroutine.closeで制御
                        local success, err = pcall(function()
                            local character = localPlayer.Character -- <--- [修正点 2]
                            if not character or not character:FindFirstChild("Humanoid") then return end 
                            if character.Humanoid.WalkSpeed == 5 then
                                character.Humanoid.WalkSpeed = crouchWalkSpeed
                            end
                        end)
                        if not success then warn("Error in CrouchSpeed: "..tostring(err)) end
                        wait()
                    end
                end)
                coroutine.resume(crouchSpeedCoroutine)
            end
        elseif crouchSpeedCoroutine and coroutine.status(crouchSpeedCoroutine) ~= "dead" then -- <--- 修正: ステータスチェック
            coroutine.close(crouchSpeedCoroutine)
            crouchSpeedCoroutine = nil
            local character = localPlayer.Character -- <--- [修正点 2]
            if character and character:FindFirstChild("Humanoid") and character.Humanoid.WalkSpeed == crouchWalkSpeed then -- <--- 修正: 元に戻す
                character.Humanoid.WalkSpeed = 16
            end
        end
    end
})

CharacterTab:AddSlider({
    Name = "セットしゃがみ速度",
    Min = 6,
    Max = 1000,
    Color = Color3.fromRGB(240, 0, 0),
    ValueName = ".",
    Increment = 1,
    Default = crouchWalkSpeed,
    Save = true,
    Flag = "SetCrouchSpeed",
    Callback = function(value)
        crouchWalkSpeed = value
    end
})

CharacterTab:AddToggle({
    Name = "しゃがみジャンプ力",
    Default = false,
    Save = true,
    Flag = "CrouchJumpPower",
    Color = Color3.fromRGB(240, 0, 0),
    Callback = function(enabled)
        if enabled then
            if not crouchJumpCoroutine or coroutine.status(crouchJumpCoroutine) == "dead" then -- <--- 修正: 再開防止
                crouchJumpCoroutine = coroutine.create(function()
                    while true do -- <--- 修正: coroutine.closeで制御
                        local success, err = pcall(function()
                            local character = localPlayer.Character -- <--- [修正点 2]
                            if not character or not character:FindFirstChild("Humanoid") then return end 
                            if character.Humanoid.JumpPower == 12 then
                                character.Humanoid.JumpPower = crouchJumpPower
                            end
                        end)
                        if not success then warn("Error in CrouchJumpPower: "..tostring(err)) end
                        wait()
                    end
                end)
                coroutine.resume(crouchJumpCoroutine)
            end
        elseif crouchJumpCoroutine and coroutine.status(crouchJumpCoroutine) ~= "dead" then -- <--- 修正: ステータスチェック
            coroutine.close(crouchJumpCoroutine)
            crouchJumpCoroutine = nil
            local character = localPlayer.Character -- <--- [修正点 2]
            if character and character:FindFirstChild("Humanoid") and character.Humanoid.JumpPower == crouchJumpPower then -- <--- 修正: 元に戻す
                character.Humanoid.JumpPower = 24
            end
        end
    end
})

CharacterTab:AddSlider({
    Name = "セットしゃがみジャンプパワー",
    Min = 6,
    Max = 1000,
    Color = Color3.fromRGB(240, 0, 0),
    ValueName = ".",
    Increment = 1,
    Default = crouchJumpPower,
    Save = true,
    Flag = "SetCrouchJumpPower",
    Callback = function(value)
        crouchJumpPower = value
    end
})

-- Explosion Tab
ExplosionTab:AddDropdown({
    Name = "トイロード",
    Default = "BombMissile",
    Options = {"BombMissile", "FireworkMissile"},
    Callback = function(Value)
        _G.ToyToLoad = Value
    end    
})

ExplosionTab:AddSlider({
    Name = "Max amount of missiles",
    Min = 1,
    Max = (localPlayer:FindFirstChild("ToysLimitCap") and localPlayer.ToysLimitCap.Value / 10) or 9, -- <--- 修正: nilチェック
    Color = Color3.fromRGB(240, 0, 0),
    ValueName = "Missiles",
    Increment = 1,
    Default = _G.MaxMissiles,
    Save = true,
    Flag = "MaxMissilesSlider",
    Callback = function(value)
        _G.MaxMissiles = value
    end
})

ExplosionTab:AddToggle({
    Name = "オートリロードキャッシュ",
    Default = false,
    Color = Color3.fromRGB(240, 0, 0),
    Save = true,
    Flag = "AutoReloadBombs",
    Callback = function(enabled)
        reloadMissile(enabled)
    end
})

-- Keybinds Tab
local KeybindSection = KeybindsTab:AddSection({Name = "Player Keybinds"})
KeybindSection:AddParagraph("Tip", "Press while looking at a player")

KeybindSection:AddBind({
    Name = "奈落へ落とす",
    Default = "Z",
    Hold = false,
    Save = true,
    Flag = "SendToHellKeybind",
    Callback = function()
        local mouse = localPlayer:GetMouse()
        local target = mouse.Target
        if target and target:IsA("BasePart") then
            local character = target.Parent
            if target.Name == "FirePlayerPart" then
                character = target.Parent.Parent
            end
            if character:IsA("Model") and character:FindFirstChildOfClass("Humanoid") and character:FindFirstChild("Torso") and character:FindFirstChild("HumanoidRootPart") then -- <--- 修正: nilチェック
                SetNetworkOwner:FireServer(character.HumanoidRootPart, character.HumanoidRootPart.CFrame)
                for _, part in ipairs(character:GetDescendants()) do
                    if part:IsA("BasePart") or part:IsA("Part") then
                        part.CanCollide = false
                    end
                end

                local bodyVelocity = Instance.new("BodyVelocity")
                bodyVelocity.Parent = character.Torso
                bodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                bodyVelocity.Velocity = Vector3.new(0, -40, 0) 
                character.Torso.CanCollide = false
                task.wait(1)
                if character and character:FindFirstChild("Torso") then -- <--- 修正: 存在チェック
                    character.Torso.CanCollide = false
                end
            end
        end
    end
})

KeybindSection:AddBind({
    Name = "キック",
    Default = "X",
    Hold = false,
    Save = true,
    Flag = "KickKeybind",
    Callback = function()
        local mouse = localPlayer:GetMouse()
        local target = mouse.Target
        if target and target:IsA("BasePart") then
            local character = target.Parent
            if target.Name == "FirePlayerPart" then
                character = target.Parent.Parent
            end
            if character:IsA("Model") and character:FindFirstChildOfClass("Humanoid") and character:FindFirstChild("HumanoidRootPart") and character.HumanoidRootPart:FindFirstChild("FirePlayerPart") then -- <--- 修正: nilチェック
                if kickMode == 1 then   
                    SetNetworkOwner:FireServer(character.HumanoidRootPart.FirePlayerPart, character.HumanoidRootPart.FirePlayerPart.CFrame)
                    local bodyVelocity = Instance.new("BodyVelocity")
                    bodyVelocity.Parent = character.HumanoidRootPart.FirePlayerPart
                    bodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                    bodyVelocity.Velocity = Vector3.new(0, 20, 0)
                elseif kickMode == 2 then
                    SetNetworkOwner:FireServer(character.HumanoidRootPart.FirePlayerPart, character.HumanoidRootPart.FirePlayerPart.CFrame)
                    local platform = Instance.new("Part")
                    platform.Name = "FloatingPlatform"
                    platform.Size = Vector3.new(5, 2, 5)
                    platform.Anchored = true
                    platform.Transparency = 1
                    platform.CanCollide = true
                    platform.Parent = character
                    coroutine.wrap(function()
                        while character and character.Parent and platform and platform.Parent do
                            wait()
                            if character:FindFirstChild("HumanoidRootPart") then
                                platform.Position = character.HumanoidRootPart.Position - Vector3.new(0, 3.994, 0)
                            else
                                break 
                            end
                        end 
                        if platform then platform:Destroy() end 
                    end)()
                end
            end
        end
    end
})

KeybindSection:AddDropdown({
    Name = "キックモードを選択",
    Options = {"空", "サイレント"},
    Default = "サイレント",
    Callback = function(selected)
        if selected == "空" then kickMode = 1 else kickMode = 2 end
    end
})

KeybindSection:AddBind({
    Name = "キル(不安定)",
    Default = "C",
    Hold = false,
    Save = true,
    Flag = "KillKeybind",
    Callback = function()
        local mouse = localPlayer:GetMouse()
        local target = mouse.Target
        if target and target:IsA("BasePart") then
            local character = target.Parent
            if target.Name == "FirePlayerPart" then
                character = target.Parent.Parent
            end
            if character:IsA("Model") and character:FindFirstChildOfClass("Humanoid") and character:FindFirstChild("Torso") and character:FindFirstChild("Head") then -- <--- 修正: nilチェック
                SetNetworkOwner:FireServer(character.HumanoidRootPart, character.HumanoidRootPart.CFrame)
                SetNetworkOwner:FireServer(character.Head, character.Head.CFrame)
                for _, motor in pairs(character.Torso:GetChildren()) do
                    SetNetworkOwner:FireServer(character.Head, character.Head.CFrame)
                    if motor:IsA('Motor6D') then motor:Destroy() end
                end
                task.wait(0.5)
                if character and character:FindFirstChild("Head") then -- <--- 修正: 存在チェック
                    SetNetworkOwner:FireServer(character.Head, character.Head.CFrame)
                end
            end
        end
    end
})

KeybindSection:AddBind({
    Name = "炎",
    Default = "V",
    Hold = false,
    Save = true,
    Flag = "BurnKeybind",
    Callback = function()
        if not ownedToys["Campfire"] then 
            OrionLib:MakeNotification({Name = "Missing toy", Content = "あなたはキャンプファイヤーを所有していません ", Image = "rbxassetid://4483345998", Time = 3})
            return
        end
        local mouse = localPlayer:GetMouse()
        local target = mouse.Target
        if target and target:IsA("BasePart") then
            local character = target.Parent
            if target.Name == "FirePlayerPart" then
                character = target.Parent.Parent
            end
            if character:IsA("Model") and character:FindFirstChildOfClass("Humanoid") and character:FindFirstChild("Head") and character:FindFirstChild("HumanoidRootPart") then -- <--- 修正: nilチェック
                if not toysFolder then return end
                if not toysFolder:FindFirstChild("Campfire") then
                    spawnItem("Campfire", Vector3.new(-72.9304581, -5.96906614, -265.543732))
                end
                local campfire = toysFolder:WaitForChild("Campfire", 2) -- <--- 修正: 待機
                if not campfire then return end
                
                local firePlayerPart
                SetNetworkOwner:FireServer(character.HumanoidRootPart, character.HumanoidRootPart.CFrame)
                for _, part in pairs(campfire:GetChildren()) do
                    if part.Name == "FirePlayerPart" then
                        part.Size = Vector3.new(9, 9, 9)
                        firePlayerPart = part
                        break
                    end
                end
                if not firePlayerPart then return end -- <--- 修正: nilチェック
                
                firePlayerPart.Position = character.Head.Position or character.HumanoidRootPart.Position
                task.wait(0.5)
                firePlayerPart.Position = Vector3.new(0, -50, 0)
            end
        end
    end
})

local KeybindSection2 = KeybindsTab:AddSection({Name = "Missilea Keybinds"})
KeybindSection2:AddParagraph("Tip", "Press anywhere")
KeybindSection2:AddBind({
    Name = "爆弾",
    Default = "B",
    Hold = false,
    Save = true,
    Flag = "ExplodeBombKeybind",
    Callback = function()
        if not ownedToys["BombMissile"] then 
            OrionLib:MakeNotification({Name = "Missing toy", Content = "あなたは爆弾を持っていません ", Image = "rbxassetid://4483345998", Time = 3})
            return
        end
        if not toysFolder then return end
        
        local connection
        connection = toysFolder.ChildAdded:Connect(function(child)
            if child.Name == "BombMissile" then
                if child:WaitForChild("ThisToysNumber", 1) then
                    if child.ThisToysNumber.Value == (toysFolder.ToyNumber.Value - 1) then
                        connection:Disconnect()
                        
                        SetNetworkOwner:FireServer(child.PartHitDetector, child.PartHitDetector.CFrame)
                        local bomb = child
                        local args = {
                            [1] = {
                                ["Radius"] = 17.5,
                                ["TimeLength"] = 2,
                                ["Hitbox"] = child.PartHitDetector,
                                ["ExplodesByFire"] = false,
                                ["MaxForcePerStudSquared"] = 225,
                                ["Model"] = child,
                                ["ImpactSpeed"] = 100,
                                ["ExplodesByPointy"] = false,
                                ["DestroysModel"] = false,
                                ["PositionPart"] = child.Body
                            },
                            [2] = child.Body.Position
                        }
                        ReplicatedStorage:WaitForChild("BombEvents"):WaitForChild("BombExplode"):FireServer(unpack(args))

                    end
                end
            end
        end)
        
        local character = localPlayer.Character -- <--- [修正点 2]
        if not character or not (character:FindFirstChild("Head") or character:FindFirstChild("HumanoidRootPart")) then
            connection:Disconnect()
            return 
        end
        spawnItemCf("BombMissile", character.Head.CFrame or character.HumanoidRootPart.CFrame)
        wait(1)
        connection:Disconnect()
    end
})

KeybindSection2:AddBind({
    Name = "Throw Bomb",
    Default = "M",
    Hold = false,
    Save = true,
    Flag = "ThrowBombKeybind",
    Callback = function()
        if not ownedToys["BombMissile"] then 
            OrionLib:MakeNotification({Name = "Missing toy", Content = "You do not own the BombMissile toy. ", Image = "rbxassetid://4483345998", Time = 3})
            return
        end
        if not toysFolder then return end
        
        local connection
        connection = toysFolder.ChildAdded:Connect(function(child)
            if child.Name == "BombMissile" then
                if child:WaitForChild("ThisToysNumber", 1) then
               
                    if child.ThisToysNumber.Value == (toysFolder.ToyNumber.Value - 1) then
           
                        connection:Disconnect()

                        SetNetworkOwner:FireServer(child.PartHitDetector, child.PartHitDetector.CFrame)
                        local velocityObj = Instance.new("BodyVelocity", child.PartHitDetector)
                        velocityObj.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                        velocityObj.Velocity = workspace.CurrentCamera.CFrame.lookVector * 500
                        Debris:AddItem(velocityObj, 10)
                    end
                end
            end
        end)
        
        local character = localPlayer.Character -- <--- [修正点 2]
        if not character or not (character:FindFirstChild("Head") or character:FindFirstChild("HumanoidRootPart")) then
            connection:Disconnect()
            return 
        end
        spawnItemCf("BombMissile", character.Head.CFrame or character.HumanoidRootPart.CFrame)
    end
})

KeybindSection2:AddBind({
    Name = "Explode Firework",
    Default = "N",
    Hold = false,
    Save = true,
    Flag = "ExplodeFireworkKeybind",
    Callback = function()
        if not ownedToys["FireworkMissile"] then 
            OrionLib:MakeNotification({Name = "Missing toy", Content = "You do not own the FireworkMissile toy. ", Image = "rbxassetid://4483345998", Time = 3})
            return
        end
        if not toysFolder then return end
        
        local connection
        connection = toysFolder.ChildAdded:Connect(function(child)
            if child.Name == "FireworkMissile" then
                if child:WaitForChild("ThisToysNumber", 1) then
                    if child.ThisToysNumber.Value == (toysFolder.ToyNumber.Value - 1) then
                        connection:Disconnect()
                        
                        SetNetworkOwner:FireServer(child.PartHitDetector, child.PartHitDetector.CFrame)
                        local bomb = child
                        local args = {
                            [1] = {
                                ["Radius"] = 17.5,
                                ["TimeLength"] = 2,
                                ["Hitbox"] = child.PartHitDetector,
                                ["ExplodesByFire"] = false,
                                ["MaxForcePerStudSquared"] = 225,
                                ["Model"] = child,
                                ["ImpactSpeed"] = 100,
                                ["ExplodesByPointy"] = false,
                                ["DestroysModel"] = false,
                                ["PositionPart"] = child.Body
                            },
                            [2] = child.Body.Position
                        }
                        ReplicatedStorage:WaitForChild("BombEvents"):WaitForChild("BombExplode"):FireServer(unpack(args))

                    end
                end
            end
        end)
        
        local character = localPlayer.Character -- <--- [修正点 2]
        if not character or not (character:FindFirstChild("Head") or character:FindFirstChild("HumanoidRootPart")) then
            connection:Disconnect()
            return 
        end
        spawnItemCf("FireworkMissile", character.Head.CFrame or character.HumanoidRootPart.CFrame)
        wait(1)
        connection:Disconnect()
    end
})

KeybindSection2:AddParagraph("Tip", "Hold to reload bombs")

KeybindSection2:AddBind({
    Name = "ミサイルキャッシュリロード",
    Default = "R",
    Hold = true,
    Save = true,
    Flag = "BombCacheReload",
    Callback = function(bool)
        reloadMissile(bool)
    end
})

KeybindSection2:AddBind({
    Name = "爆弾キャッシュリロード",
    Default = "T",
    Hold = false,
    Save = true,
    Flag = "ExplodeCachedBombKeybind",
    Callback = function()
        if #bombList == 0 then 
            OrionLib:MakeNotification({Name = "No bombs", Content = "There are no cached bombs to explode", Image = "rbxassetid://4483345998", Time = 2})
            return
        end
        
        local character = localPlayer.Character -- <--- [修正点 2]
        if not character or not (character:FindFirstChild("HumanoidRootPart") or character:FindFirstChild("PrimaryPart")) then return end

        local bomb = table.remove(bombList, 1)
        if not bomb or not bomb.Parent then return end -- <--- 修正: 爆弾が存在するか確認

        local args = {
            [1] = {
                ["Radius"] = 17.5,
                ["TimeLength"] = 2,
                ["Hitbox"] = bomb.PartHitDetector,
                ["ExplodesByFire"] = false,
                ["MaxForcePerStudSquared"] = 225,
                ["Model"] = bomb,
                ["ImpactSpeed"] = 100,
                ["ExplodesByPointy"] = false,
                ["DestroysModel"] = false,
                    ["PositionPart"] = character.HumanoidRootPart or character.PrimaryPart
            },
            [2] = character.HumanoidRootPart.Position or character.PrimaryPart.Position
        }
        ReplicatedStorage:WaitForChild("BombEvents"):WaitForChild("BombExplode"):FireServer(unpack(args))
    end
})

KeybindSection2:AddBind({
    Name = "全ての爆弾キャッシュリロード",
    Default = "Y",
    Hold = false,
    Save = true,
    Flag = "ExplodeAllCachedBombsKeybind",
    Callback = function()
        if #bombList == 0 then 
            OrionLib:MakeNotification({Name = "No bombs", Content = "There are no cached bombs to explode", Image = "rbxassetid://4483345998", Time = 2})
            return
        end
        
        local character = localPlayer.Character -- <--- [修正点 2]
        if not character or not (character:FindFirstChild("HumanoidRootPart") or character:FindFirstChild("PrimaryPart")) then return end
        
        for i = #bombList, 1, -1 do
            local bomb = table.remove(bombList, i)
            if bomb and bomb.Parent then -- <--- 修正: 爆弾が存在するか確認
                local args = {
                    [1] = {
                        ["Radius"] = 17.5,
                        ["TimeLength"] = 2,
                        ["Hitbox"] = bomb.PartHitDetector,
                        ["ExplodesByFire"] = false,
                        ["MaxForcePerStudSquared"] = 225,
                        ["Model"] = bomb,
                        ["ImpactSpeed"] = 100,
                        ["ExplodesByPointy"] = false,
                        ["DestroysModel"] = false,
                        ["PositionPart"] = character.HumanoidRootPart or character.PrimaryPart
                    },
                    [2] = character.HumanoidRootPart.Position or character.PrimaryPart.Position
                }
                ReplicatedStorage:WaitForChild("BombEvents"):WaitForChild("BombExplode"):FireServer(unpack(args))
            end
        end
    end
})

KeybindSection2:AddBind({
    Name = "最も近いプレイヤーに隠されたミサイルをすべて爆発させる",
    Default = "U",
    Hold = false,
    Save = true,
    Flag = "ExplodeAllCachedBombsOnNearestPlayerKeybind",
    Callback = function()
        if #bombList == 0 then 
            OrionLib:MakeNotification({Name = "No bombs", Content = "There are no cached bombs to explode", Image = "rbxassetid://4483345998", Time = 2})
            return
        end
        local nearest = getNearestPlayer() 
        if not nearest or not nearest.Character then 
            OrionLib:MakeNotification({Name = "Error", Content = "最も近いプレイヤーが見つかりませんでした", Image = "rbxassetid://4483345998", Time = 2})
            return 
        end
        local char = nearest.Character
        if not (char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso") or char:FindFirstChild("PrimaryPart")) then return end -- <--- 修正: ターゲットのパーツチェック
        
        for i = #bombList, 1, -1 do
            local bomb = table.remove(bombList, i)
            if bomb and bomb.Parent then -- <--- 修正: 爆弾が存在するか確認
                local args = {
                    [1] = {
                        ["Radius"] = 17.5,
                        ["TimeLength"] = 2,
                        ["Hitbox"] = bomb.PartHitDetector,
                        ["ExplodesByFire"] = false,
                        ["MaxForcePerStudSquared"] = 225,
                        ["Model"] = bomb,
                        ["ImpactSpeed"] = 100,
                        ["ExplodesByPointy"] = false,
                        ["DestroysModel"] = false,
                        ["PositionPart"] = char.HumanoidRootPart or char.Torso or char.PrimaryPart
                    },
                    [2] = char.HumanoidRootPart.Position or char.Torso.Position or char.PrimaryPart.Position
                }
                ReplicatedStorage:WaitForChild("BombEvents"):WaitForChild("BombExplode"):FireServer(unpack(args))
            end
        end
    end
})

KeybindSection2:AddToggle({
    Name = "無視してください", 
    Default = false,
    Color = Color3.fromRGB(240, 0, 0),
    Save = false,
    Callback = function(enabled)
        if enabled then
            lightbitparts = {}
            bodyPositions = {}
            alignOrientations = {}
            
            if not toysFolder then return end
            
            for i, v in pairs(toysFolder:GetChildren()) do
                if v.Name ~= "ToyNumber" and v.PrimaryPart then
                    local part = v.PrimaryPart
                    table.insert(lightbitparts, part)
                    
                    for _, p in pairs(v:GetDescendants()) do
                        if p:IsA("BasePart") then
                            p.CanCollide = false
                        end
                    end
            
                    local bodyPosition = Instance.new("BodyPosition")
                    bodyPosition.P = 15000
                    bodyPosition.D = 200
                    bodyPosition.MaxForce = Vector3.new(5000000, 5000000, 5000000)
                    bodyPosition.Parent = part
                    bodyPosition.Position = part.Position
                    table.insert(bodyPositions, bodyPosition)

                    local alignOrientation = Instance.new("AlignOrientation")
                    alignOrientation.MaxTorque = 400000
                    alignOrientation.Mode = Enum.OrientationAlignmentMode.OneAttachment
                    alignOrientation.Responsiveness = 2000
                    alignOrientation.Parent = part
                    alignOrientation.PrimaryAxisOnly = false
                    table.insert(alignOrientations, alignOrientation)

                    local attachment = Instance.new("Attachment")
                    attachment.Parent = part
                    alignOrientation.Attachment0 = attachment
                    
                    SetNetworkOwner:FireServer(part, part.CFrame)
                end
            end
            
            lightorbitcon = RunService.Heartbeat:Connect(function()
                local character = localPlayer.Character -- <--- [修正点 2]
                if not character or not character.HumanoidRootPart then 
                    return 
                end
                lightbitoffset = lightbitoffset + lightbit
                lightbitpos = U.GetSurroundingVectors(character.HumanoidRootPart.Position, usingradius, #lightbitparts, lightbitoffset)

                for i, v in ipairs(lightbitpos) do
                    if bodyPositions[i] and alignOrientations[i] and lightbitparts[i] then
                        bodyPositions[i].Position = v
                        local part = lightbitparts[i]
                        local lookAtCFrame = CFrame.lookAt(part.Position, character.HumanoidRootPart.Position)
                        alignOrientations[i].CFrame = lookAtCFrame
                    end
                end
            end)
        else
            if lightorbitcon then
                pcall(function()
                    lightorbitcon:Disconnect()
                end)
                lightorbitcon = nil
            end
            
            for i, v in ipairs(lightbitparts) do
                if v and v.Parent then
                    for _, p in pairs(v:GetDescendants()) do
                        if p:IsA("BasePart") then
                            p.CanCollide = true
                        end
                    end
                    local attachment = v:FindFirstChild("Attachment")
                    if attachment then attachment:Destroy() end
                end
            end
            
            for _, v in ipairs(bodyPositions) do
                if v and v.Parent then v:Destroy() end
            end
            bodyPositions = {}
            
            for _, v in ipairs(alignOrientations) do
                if v and v.Parent then v:Destroy() end
            end
            alignOrientations = {}
            
            lightbitparts = {}
        end
    end
})

KeybindSection2:AddBind({
    Name = "開発者向けの秘密のキーバインド(あなたには何も起こりません)",
    Default = "K",
    Hold = true,
    Save = true,
    Flag = "LightBitSpeedUpDev",
    Callback = function(isHeld)
        if lightbitcon then
            pcall(function()
                lightbitcon:Disconnect()
            end)
        end
        lightbitcon = RunService.Heartbeat:Connect(function()
            if isHeld then
                lightbit = lightbit + 0.025
            else
                if lightbit > 0.3125 then
                    lightbit = lightbit - 0.0125
                end
            end
        end)
        Debris:AddItem(lightbitcon, 1)
    end
})

KeybindSection2:AddBind({
    Name = "開発者向けのもう一つの小さなキーバインド(あなたには何も影響しません)",
    Default = "J",
    Hold = true,
    Save = true,
    Flag = "LightBitRadiusUpDev",
    Callback = function(isHeld)
        if lightbitcon2 then
            pcall(function()
                lightbitcon2:Disconnect()
            end)
        end
        lightbitcon2 = RunService.Heartbeat:Connect(function()
            if isHeld then
                usingradius = usingradius + 1
            else 
                if usingradius > lightbitradius then
                    usingradius = usingradius - 1
                end
            end
        end)
        Debris:AddItem(lightbitcon2, 1)
    end
})


DevTab:AddToggle({
    Name = "ラグドールオール",
    Color = Color3.fromRGB(240, 0, 0),
    Default = false,
    Save = true,
    Callback = function(enabled)
        if enabled then
            if not ragdollAllCoroutine or coroutine.status(ragdollAllCoroutine) == "dead" then -- <--- 修正: 再開防止
                ragdollAllCoroutine = coroutine.create(ragdollAll)
                coroutine.resume(ragdollAllCoroutine)
            end
        else
            if ragdollAllCoroutine and coroutine.status(ragdollAllCoroutine) ~= "dead" then -- <--- 修正: ステータスチェック
                coroutine.close(ragdollAllCoroutine)
                ragdollAllCoroutine = nil
                if toysFolder and toysFolder:FindFirstChild("FoodBanana") then -- <--- 修正: クリーンアップ
                    DestroyT(toysFolder:FindFirstChild("FoodBanana"))
                end
            end
        end
    end
})

-- 自動で座る機能
RunService.Heartbeat:Connect(function(dt)
    if AutoSitEnabled then
        local success, err = pcall(function() -- <--- [修正点 3]
            local Character = localPlayer.Character -- <--- [修正点 2]
            -- キャラクター、Humanoid、HRPが存在し、かつ座っていない場合のみ処理
            if Character and Character:FindFirstChild("Humanoid") and Character.Humanoid.SeatPart == nil and Character:FindFirstChild("HumanoidRootPart") then
                
                local foundBlobman
                
                -- 周囲のブロブマンを探索
                for _, v in pairs(game.Workspace:GetDescendants()) do
                    if v:IsA("Model") and v.Name == "CreatureBlobman" and v:FindFirstChild("VehicleSeat") then
                        -- 誰も座っていないブロブマンが見つかったらそれをターゲットにする
                        if v.VehicleSeat.Occupant == nil then
                            foundBlobman = v
                            break
                        end
                    end
                end

                if foundBlobman then
                    -- 見つかったら座る
                    foundBlobman.VehicleSeat:Sit(Character.Humanoid)
                elseif not isSpawningBlobmanForSit and (tick() - lastSpawnAttempt) > SPAWN_COOLDOWN then -- クールダウンチェック
                    -- 見つからない場合、スポーン処理を開始 (連打防止 + クールダウン)
                    isSpawningBlobmanForSit = true
                    lastSpawnAttempt = tick() -- 最終試行時間を更新
                    spawnItemCf("CreatureBlobman", Character.HumanoidRootPart.CFrame)
                    
                    -- スポーンして認識されるまでの遅延 (1.5秒後にフラグ解除)
                    task.delay(1.5, function()
                        isSpawningBlobmanForSit = false
                    end)
                end
            end
        end)
        if not success then warn("Error in AutoSit: "..tostring(err)) end
    end
end)

game:GetService("Players").PlayerRemoving:Connect(function(player)
    if player == localPlayer then
        if loopTpCoroutine and coroutine.status(loopTpCoroutine) ~= "dead" then -- <--- 修正: ステータスチェック
            coroutine.close(loopTpCoroutine) 
        end
    end
end)

OrionLib:MakeNotification({
    Name = "Welcome", 
    Content = "ようこそ、野獣のおちんちんハブへ", 
    Image = "rbxassetid://4483345998", 
    Time = 5
})

OrionLib:Init()
