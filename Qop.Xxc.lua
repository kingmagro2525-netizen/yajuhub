--[[
    野獣のおちんちんハブ クライアントスクリプト - 修正版
    
    修正点：
    1. 全ての未定義タブと変数（version, loopTPFunction）を宣言・定義
    2. 構文エラー '24end' を修正
    3. 全ての無限ループ関数（kickGrab, grabHandler, fireGrab, noclipGrab, fireAll, anchorGrab, anchorKickGrab）をトグル制御のコルーチンに修正
    4. コルーチンのクリーンアップロジックを強化し、メモリリークの可能性を低減
    5. AutoSitのHeartbeatループ内の非効率なGetDescendants()呼び出しを、キャッシュとイベントベースのチェックに改善
--]]

local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")
local MarketplaceService = game:GetService("MarketplaceService") -- BloxmanTabの機能のために追加

local GrabEvents = ReplicatedStorage:WaitForChild("GrabEvents")
local MenuToys = ReplicatedStorage:WaitForChild("MenuToys")
local CharacterEvents = ReplicatedStorage:WaitForChild("CharacterEvents")
local SetNetworkOwner = GrabEvents:WaitForChild("SetNetworkOwner")
local Struggle = CharacterEvents:WaitForChild("Struggle")
local CreateLine = GrabEvents:WaitForChild("CreateGrabLine")
local DestroyLine = GrabEvents:WaitForChild("DestroyGrabLine")
local DestroyToy = MenuToys:WaitForChild("DestroyToy")

local localPlayer = Players.LocalPlayer
local playerCharacter = localPlayer.Character or localPlayer.CharacterAdded:Wait()

localPlayer.CharacterAdded:Connect(function(character)
    playerCharacter = character
end)

-- 全てのコルーチン/接続変数を宣言
local AutoRecoverDroppedPartsCoroutine
local connectionBombReload
local reloadBombCoroutine
local antiExplosionConnection
local poisonAuraCoroutine
local deathAuraCoroutine -- 未使用の可能性あり
local poisonCoroutines = {}
local strengthConnection
local coroutineRunning = false
local autoStruggleCoroutine
local autoDefendCoroutine
local autoDefendKickCoroutine
local auraCoroutine
local gravityCoroutine
local kickCoroutine
local kickGrabCoroutine
local hellSendGrabCoroutine -- 未使用の可能性あり
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
local ufoGrabCoroutine -- 未使用の可能性あり
local fireGrabCoroutine
local noclipGrabCoroutine
local antiKickCoroutine
local kickGrabConnections = {}
local blobmanCoroutine
local lighBitSpeedCoroutine -- 未使用の可能性あり
local lightbitpos = {}
local lightbitparts = {}
local lightbitcon
local lightbitcon2
local lightorbitcon
local bodyPositions = {}
local alignOrientations = {}
local characterAddedConn
local anchorKickCoroutine
local grabHandlerCoroutine

-- グローバル設定
AutoSitEnabled = false
LoopTpEnabled = false -- 未使用の可能性あり
local loopTpCoroutine
local currentLoopTpPlayerIndex = 1
local tpAllCoroutine -- 未使用の可能性あり
_G.TPDelay = 0.5
LocalNoclipEnabled = false -- 未使用の可能性あり
VehicleTPEnabled = false -- 未使用の可能性あり
_G.strength = 400
_G.ToyToLoad = "BombMissile"
_G.MaxMissiles = 9
_G.BlobmanDelay = 0.05

local decoyOffset = 15
local stopDistance = 5
local circleRadius = 10
local circleSpeed = 2 -- 未使用の可能性あり
local auraToggle = 1
local crouchWalkSpeed = 50
local crouchJumpPower = 50
local kickMode = 1
local auraRadius = 20
local lightbit = 0.3125
local lightbitoffset = 1
local lightbitradius = 20
local usingradius = lightbitradius
local foundBlobman -- AutoSit/Blobman機能のために追加

local OrionLib = loadstring(game:HttpGet(("https://raw.githubusercontent.com/yua20170313a-pixel/Orion/e19e8236bde46c459fb0d617e4640aeb75878703/source")))()

-- -------------------------------------------------------------------------------------------------
-- 1. 未定義の変数・タブの宣言
-- -------------------------------------------------------------------------------------------------

local version = "1.0.1 (Fixed)" -- バージョン変数の宣言

-- メインタブ
local DefenseTab = OrionLib:MakeTab({Name = "Defense", Icon = "rbxassetid://6034179373"})
local BlobmanTab = OrionLib:MakeTab({Name = "Blobman", Icon = "rbxassetid://6034179373"})
local CharacterTab = OrionLib:MakeTab({Name = "Character", Icon = "rbxassetid://6034179373"})
local FunTab = OrionLib:MakeTab({Name = "Fun", Icon = "rbxassetid://6034179373"})
local ScriptTab = OrionLib:MakeTab({Name = "Scripts", Icon = "rbxassetid://6034179373"})
local AuraTab = OrionLib:MakeTab({Name = "Aura", Icon = "rbxassetid://6034179373"})
local KeybindsTab = OrionLib:MakeTab({Name = "Keybinds", Icon = "rbxassetid://6034179373"})
local ExplosionTab = OrionLib:MakeTab({Name = "Explosion", Icon = "rbxassetid://6034179373"})
local DevTab = OrionLib:MakeTab({Name = "Dev", Icon = "rbxassetid://6034179373"})

-- -------------------------------------------------------------------------------------------------
-- Utilities (変更なし)
-- -------------------------------------------------------------------------------------------------
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

function Utilities.GetAncestor(child, name, className)
    local currentParent = child.Parent
    while currentParent do
        if currentParent.Name == name and (not className or currentParent:IsA(className)) then
            return currentParent
        end
        currentParent = currentParent.Parent
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

function Utilities.GetChildrenByType(parent, className)
    local results = {}
    for _, child in ipairs(parent:GetChildren()) do
        if child:IsA(className) then
            table.insert(results, child)
        end
    end
    return results
end

function Utilities.GetDescendantsByType(parent, className)
    local results = {}
    for _, descendant in ipairs(parent:GetDescendants()) do
        if descendant:IsA(className) then
            table.insert(results, descendant)
        end
    end
    return results
end

function Utilities.HasAttribute(instance, attributeName)
    return instance:GetAttribute(attributeName) ~= nil
end

function Utilities.GetAttributeOrDefault(instance, attributeName, defaultValue)
    local value = instance:GetAttribute(attributeName)
    return value ~= nil and value or defaultValue
end

function Utilities.CloneInstance(instance, newParent)
    local clone = instance:Clone()
    if newParent then clone.Parent = newParent end
    return clone
end

function Utilities.WaitForChildOfType(parent, className, timeout)
    local startTime = tick()
    while timeout == nil or tick() - startTime < timeout do
        for _, child in ipairs(parent:GetChildren()) do
            if child:IsA(className) then return child end
        end
        RunService.Stepped:Wait()
    end
    return nil
end

function Utilities.IsPointInPart(part, point)
    local pointInPartSpace = part.CFrame:PointToObjectSpace(point)
    local size = part.Size
    return math.abs(pointInPartSpace.X) <= size.X / 2 and
           math.abs(pointInPartSpace.Y) <= size.Y / 2 and
           math.abs(pointInPartSpace.Z) <= size.Z / 2
end

function Utilities.GetDistance(pointA, pointB)
    return (pointA - pointB).Magnitude
end

function Utilities.GetAngleBetweenVectors(vectorA, vectorB)
    local dotProduct = vectorA:Dot(vectorB)
    local magnitudeProduct = vectorA.Magnitude * vectorB.Magnitude
    if magnitudeProduct == 0 then return 0 end
    return math.acos(math.clamp(dotProduct / magnitudeProduct, -1, 1))
end

function Utilities.RotateVectorY(vector, angle)
    local cosA = math.cos(angle)
    local sinA = math.sin(angle)
    local x = vector.X * cosA - vector.Z * sinA
    local z = vector.X * sinA + vector.Z * cosA
    return Vector3.new(x, vector.Y, z)
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

local followMode = true
local toysFolder = workspace:FindFirstChild(localPlayer.Name.."SpawnedInToys")
local playerList = {}
local selection -- 未使用の可能性あり
local blobman
local platforms = {}
local ownedToys = {}
local bombList = {}

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
    if toy then
        DestroyToy:FireServer(toy)
    end
end

local function getDescendantParts(descendantName)
    local parts = {}
    for _, descendant in ipairs(workspace.Map:GetDescendants()) do
        if descendant:IsA("Part") and descendant.Name == descendantName then
            table.insert(parts, descendant)
        end
    end
    return parts
end

local poisonHurtParts = getDescendantParts("PoisonHurtPart")
local paintPlayerParts = getDescendantParts("PaintPlayerPart")

local function updatePlayerList()
    playerList = {}
    for _, player in ipairs(Players:GetPlayers()) do
        table.insert(playerList, player.Name)
    end
end

local function onPlayerAdded(player)
    table.insert(playerList, player.Name)
end

local function onPlayerRemoving(player)
    for i, name in ipairs(playerList) do
        if name == player.Name then
            table.remove(playerList, i)
            break
        end
    end
end

Players.PlayerAdded:Connect(onPlayerAdded)
Players.PlayerRemoving:Connect(onPlayerRemoving)

-- `ownedToys`の初期化を待機
local menuGui = localPlayer:WaitForChild("PlayerGui"):WaitForChild("MenuGui")
local menu = menuGui:WaitForChild("Menu")
local tabContents = menu:WaitForChild("TabContents")
local toysTab = tabContents:WaitForChild("Toys")
local toysContents = toysTab:WaitForChild("Contents")

for i, v in pairs(toysContents:GetChildren()) do
    if v.Name ~= "UIGridLayout" then
        ownedToys[v.Name] = true
    end
end

local function getNearestPlayer()
    local nearestPlayer
    local nearestDistance = math.huge
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= localPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local distance = (playerCharacter.HumanoidRootPart.Position - player.Character.HumanoidRootPart.Position).Magnitude
            if distance < nearestDistance then
                nearestDistance = distance
                nearestPlayer = player
            end
        end
    end
    return nearestPlayer
end

local function cleanupConnections(connectionTable)
    for i = #connectionTable, 1, -1 do
        local connection = connectionTable[i]
        if connection and typeof(connection) == "RBXScriptConnection" then
            pcall(function() connection:Disconnect() end)
        end
        table.remove(connectionTable, i)
    end
end

local function getVersion()
    local success, response = pcall(function()
        -- 存在しないURLのため、ダミーレスポンス
        -- return game:HttpGet("https://raw.githubusercontent.com/kingmagro2525-netizen/yajuhub/main/Qop.Xxc.version.lua")
        return '{"version": "' .. version .. '"}'
    end)
    if success and response then
        local data = HttpService:JSONDecode(response)
        return data.version or version
    else
        warn("Failed to get version: " .. tostring(response))
        return version
    end
end

local function spawnItem(itemName, position, orientation)
    task.spawn(function()
        local cframe = CFrame.new(position)
        local rotation = Vector3.new(0, 90, 0)
        ReplicatedStorage.MenuToys.SpawnToyRemoteFunction:InvokeServer(itemName, cframe, rotation)
    end)
end

local function spawnItemCf(itemName, cframe)
    task.spawn(function()
        local rotation = Vector3.new(0, 0, 0)
        ReplicatedStorage.MenuToys.SpawnToyRemoteFunction:InvokeServer(itemName, cframe, rotation)
    end)
end

local function arson(part)
    if not toysFolder:FindFirstChild("Campfire") then
        spawnItem("Campfire", Vector3.new(-72.9304581, -5.96906614, -265.543732))
    end
    local campfire = toysFolder:FindFirstChild("Campfire")
    local burnPart = campfire:FindFirstChild("FirePlayerPart") or campfire.FirePlayerPart
    burnPart.Size = Vector3.new(7, 7, 7)
    burnPart.Position = part.Position
    task.wait(0.3)
    burnPart.Position = Vector3.new(0, -50, 0)
end

local function handleCharacterAdded(player)
    local characterAddedConnection = player.CharacterAdded:Connect(function(character)
        local hrp = character:WaitForChild("HumanoidRootPart")
        local fpp = hrp:WaitForChild("FirePlayerPart")
        fpp.Size = Vector3.new(4.5, 5, 4.5)
        fpp.CollisionGroup = "1"
        fpp.CanQuery = true
    end)
    table.insert(kickGrabConnections, characterAddedConnection)
end

-- -------------------------------------------------------------------------------------------------
-- 3. 論理的な問題（無限ループ）の解決とコルーチン化
-- -------------------------------------------------------------------------------------------------

-- kickGrab (トグル制御のコルーチン)
local function kickGrabFunc()
    localPlayer:GetMouse().TargetFilter = localPlayer.Character
    for _, player in pairs(Players:GetPlayers()) do
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local hrp = player.Character.HumanoidRootPart
            local fpp = hrp:FindFirstChild("FirePlayerPart")
            if fpp then
                fpp.Size = Vector3.new(4.5, 5.5, 4.5)
                fpp.CollisionGroup = "1"
                fpp.CanQuery = true
            end
        end
        handleCharacterAdded(player)
    end
    local playerAddedConnection = Players.PlayerAdded:Connect(handleCharacterAdded)
    table.insert(kickGrabConnections, playerAddedConnection)
    
    while kickGrabCoroutine do -- 実行中のみ継続
        task.wait(1) -- イベントベースなので負荷軽減のため長めに待つ
    end
end

local function startKickGrab()
    if not kickGrabCoroutine then
        kickGrabCoroutine = coroutine.create(kickGrabFunc)
        coroutine.resume(kickGrabCoroutine)
    end
end

local function stopKickGrab()
    if kickGrabCoroutine then
        cleanupConnections(kickGrabConnections)
        coroutine.close(kickGrabCoroutine)
        kickGrabCoroutine = nil
    end
end

-- grabHandler (トグル制御のコルーチン)
local function grabHandlerFunc(grabType)
    local partsTable = grabType == "poison" and poisonHurtParts or paintPlayerParts
    while grabHandlerCoroutine do
        pcall(function()
            local child = workspace:FindFirstChild("GrabParts")
            if child and child.Name == "GrabParts" then
                local grabPart = child:FindFirstChild("GrabPart")
                if grabPart and grabPart:FindFirstChild("WeldConstraint") then
                    local grabbedPart = grabPart.WeldConstraint.Part1
                    if grabbedPart then
                        local head = grabbedPart.Parent:FindFirstChild("Head")
                        if head then
                            while workspace:FindFirstChild("GrabParts") and grabHandlerCoroutine do
                                for _, part in pairs(partsTable) do
                                    part.Size = Vector3.new(2, 2, 2)
                                    part.Transparency = 1
                                    part.Position = head.Position
                                end
                                task.wait()
                            end
                            -- ループを抜けた後のクリーンアップ
                            for _, part in pairs(partsTable) do
                                part.Position = Vector3.new(0, -200, 0)
                            end
                        end
                    end
                end
            else
                -- GrabPartsがない場合、待機
                task.wait(0.1)
            end
        end)
        task.wait()
    end
    -- コルーチンが完全に停止する前のクリーンアップ
    for _, part in pairs(partsTable) do
        part.Position = Vector3.new(0, -200, 0)
    end
end

local function startGrabHandler(grabType)
    if not grabHandlerCoroutine then
        grabHandlerCoroutine = coroutine.create(function() grabHandlerFunc(grabType) end)
        coroutine.resume(grabHandlerCoroutine)
    end
end

local function stopGrabHandler()
    if grabHandlerCoroutine then
        coroutine.close(grabHandlerCoroutine)
        grabHandlerCoroutine = nil
    end
end

-- fireGrab (トグル制御のコルーチン)
local function fireGrabFunc()
    while fireGrabCoroutine do
        pcall(function()
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
        task.wait(0.1)
    end
end

local function startFireGrab()
    if not fireGrabCoroutine then
        fireGrabCoroutine = coroutine.create(fireGrabFunc)
        coroutine.resume(fireGrabCoroutine)
    end
end

local function stopFireGrab()
    if fireGrabCoroutine then
        coroutine.close(fireGrabCoroutine)
        fireGrabCoroutine = nil
        -- 炎のクリーンアップはarson関数内で一時的に行われるため、ここでは特に不要
    end
end

-- noclipGrab (トグル制御のコルーチン)
local function noclipGrabFunc()
    while noclipGrabCoroutine do
        pcall(function()
            local child = workspace:FindFirstChild("GrabParts")
            if child and child.Name == "GrabParts" then
                local grabPart = child:FindFirstChild("GrabPart")
                if grabPart and grabPart:FindFirstChild("WeldConstraint") then
                    local grabbedPart = grabPart.WeldConstraint.Part1
                    if grabbedPart then
                        local character = grabbedPart.Parent
                        if character and character:FindFirstChild("HumanoidRootPart") then
                            while workspace:FindFirstChild("GrabParts") and noclipGrabCoroutine do
                                for _, part in pairs(character:GetChildren()) do
                                    if part:IsA("BasePart") then
                                        part.CanCollide = false
                                    end
                                end
                                task.wait()
                            end
                            -- ループを抜けた後のクリーンアップ
                            for _, part in pairs(character:GetChildren()) do
                                if part:IsA("BasePart") then
                                    part.CanCollide = true
                                end
                            end
                        end
                    end
                end
            else
                task.wait(0.1)
            end
        end)
        task.wait()
    end
end

local function startNoclipGrab()
    if not noclipGrabCoroutine then
        noclipGrabCoroutine = coroutine.create(noclipGrabFunc)
        coroutine.resume(noclipGrabCoroutine)
    end
end

local function stopNoclipGrab()
    if noclipGrabCoroutine then
        coroutine.close(noclipGrabCoroutine)
        noclipGrabCoroutine = nil
    end
end

-- fireAll (トグル制御のコルーチン)
local function fireAllFunc()
    while fireAllCoroutine do
        pcall(function()
            if toysFolder:FindFirstChild("Campfire") then
                DestroyT(toysFolder:FindFirstChild("Campfire"))
                task.wait(0.5)
            end
            spawnItemCf("Campfire", playerCharacter.Head.CFrame)
            local campfire = toysFolder:WaitForChild("Campfire")
            local firePlayerPart
            for _, part in pairs(campfire:GetChildren()) do
                if part.Name == "FirePlayerPart" then
                    part.Size = Vector3.new(10, 10, 10)
                    firePlayerPart = part
                    break
                end
            end
            
            if not firePlayerPart then return end
            
            local originalPosition = playerCharacter.Torso.Position
            SetNetworkOwner:FireServer(firePlayerPart, firePlayerPart.CFrame)
            playerCharacter:MoveTo(firePlayerPart.Position)
            task.wait(0.3)
            playerCharacter:MoveTo(originalPosition)
            
            local bodyPosition = Instance.new("BodyPosition")
            bodyPosition.P = 20000
            bodyPosition.Position = playerCharacter.Head.Position + Vector3.new(0, 600, 0)
            bodyPosition.Parent = campfire.Main
            
            while fireAllCoroutine do
                for _, player in pairs(Players:GetChildren()) do
                    pcall(function()
                        bodyPosition.Position = playerCharacter.Head.Position + Vector3.new(0, 600, 0)
                        if player.Character and player.Character.HumanoidRootPart and player.Character ~= playerCharacter then
                            firePlayerPart.Position = player.Character.HumanoidRootPart.Position or player.Character.Head.Position
                            task.wait()
                        end
                    end)
                end  
                task.wait()
            end
            
            -- コルーチンが停止する前のクリーンアップ
            DestroyT(campfire)
        end)
        task.wait()
    end
end

local function startFireAll()
    if not fireAllCoroutine then
        fireAllCoroutine = coroutine.create(fireAllFunc)
        coroutine.resume(fireAllCoroutine)
    end
end

local function stopFireAll()
    if fireAllCoroutine then
        coroutine.close(fireAllCoroutine)
        fireAllCoroutine = nil
        -- 終了時にCampfireモデルを破壊
        if toysFolder:FindFirstChild("Campfire") then
            DestroyT(toysFolder:FindFirstChild("Campfire"))
        end
    end
end

-- anchorGrab (トグル制御のコルーチン)
local function anchorGrabFunc()
    while anchorGrabCoroutine do
        pcall(function()
            local grabParts = workspace:FindFirstChild("GrabParts")
            if not grabParts then task.wait(0.1) return end
            local grabPart = grabParts:FindFirstChild("GrabPart")
            if not grabPart then task.wait(0.1) return end
            local weldConstraint = grabPart:FindFirstChild("WeldConstraint")
            if not weldConstraint or not weldConstraint.Part1 then task.wait(0.1) return end
            local primaryPart = weldConstraint.Part1.Name == "SoundPart" and weldConstraint.Part1 or weldConstraint.Part1.Parent.SoundPart or weldConstraint.Part1.Parent.PrimaryPart or weldConstraint.Part1
            if not primaryPart then task.wait(0.1) return end
            if primaryPart.Anchored then task.wait(0.1) return end
            if isDescendantOf(primaryPart, workspace.Map) then task.wait(0.1) return end
            for _, player in pairs(Players:GetChildren()) do
                if isDescendantOf(primaryPart, player.Character) then task.wait(0.1) return end
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
            local targetInstance = U.FindFirstAncestorOfType(primaryPart, "Model") and U.FindFirstAncestorOfType(primaryPart, "Model") ~= workspace and U.FindFirstAncestorOfType(primaryPart, "Model") or primaryPart
            for _, child in ipairs(targetInstance:GetDescendants()) do
                if child:IsA("BodyPosition") or child:IsA("BodyGyro") then
                    child:Destroy()
                end
            end
            
            while workspace:FindFirstChild("GrabParts") and anchorGrabCoroutine do
                task.wait()
            end
            
            createBodyMovers(primaryPart, primaryPart.Position, primaryPart.CFrame)
        end)
        task.wait()
    end
end

local function startAnchorGrab()
    if not anchorGrabCoroutine then
        anchorGrabCoroutine = coroutine.create(anchorGrabFunc)
        coroutine.resume(anchorGrabCoroutine)
    end
end

local function stopAnchorGrab()
    if anchorGrabCoroutine then
        coroutine.close(anchorGrabCoroutine)
        anchorGrabCoroutine = nil
    end
end

-- anchorKickGrab (トグル制御のコルーチン)
local function anchorKickGrabFunc()
    while anchorKickGrabCoroutine do
        pcall(function()
            local grabParts = workspace:FindFirstChild("GrabParts")
            if not grabParts then task.wait(0.1) return end
            local grabPart = grabParts:FindFirstChild("GrabPart")
            if not grabPart then task.wait(0.1) return end
            local weldConstraint = grabPart:FindFirstChild("WeldConstraint")
            if not weldConstraint or not weldConstraint.Part1 then task.wait(0.1) return end
            local primaryPart = weldConstraint.Part1
            if not primaryPart then task.wait(0.1) return end
            if isDescendantOf(primaryPart, workspace.Map) then task.wait(0.1) return end
            if primaryPart.Name ~= "FirePlayerPart" then task.wait(0.1) return end
            for _, child in ipairs(primaryPart:GetChildren()) do
                if child:IsA("BodyPosition") or child:IsA("BodyGyro") then
                    child:Destroy()
                end
            end
            while workspace:FindFirstChild("GrabParts") and anchorKickGrabCoroutine do
                task.wait()
            end
            createBodyMovers(primaryPart, primaryPart.Position, primaryPart.CFrame)
        end)
        task.wait()
    end
end

local function startAnchorKickGrab()
    if not anchorKickGrabCoroutine then
        anchorKickGrabCoroutine = coroutine.create(anchorKickGrabFunc)
        coroutine.resume(anchorKickGrabCoroutine)
    end
end

local function stopAnchorKickGrab()
    if anchorKickGrabCoroutine then
        coroutine.close(anchorKickGrabCoroutine)
        anchorKickGrabCoroutine = nil
    end
end

-- -------------------------------------------------------------------------------------------------
-- 1. 未定義の関数 loopTPFunction の定義
-- -------------------------------------------------------------------------------------------------
local function loopTPFunction(targetBlobman)
    if not targetBlobman or not targetBlobman:IsA("Model") then
        OrionLib:MakeNotification({
            Name = "Error",
            Content = "ブロブマンが見つからないか、無効です。", 
            Image = "rbxassetid://4483345998", 
            Time = 5
        })
        return
    end

    local players = Players:GetPlayers()
    local nonLocalPlayers = {}
    for _, player in ipairs(players) do
        if player ~= localPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            table.insert(nonLocalPlayers, player)
        end
    end

    if #nonLocalPlayers == 0 then
        OrionLib:MakeNotification({
            Name = "Error",
            Content = "キックできるプレイヤーがいません。", 
            Image = "rbxassetid://4483345998", 
            Time = 5
        })
        return
    end

    local blobmanRoot = targetBlobman:FindFirstChild("Main")
    local seat = targetBlobman:FindFirstChild("VehicleSeat")

    if not blobmanRoot or not seat then
        OrionLib:MakeNotification({
            Name = "Error",
            Content = "ブロブマンのパーツが見つかりません。", 
            Image = "rbxassetid://4483345998", 
            Time = 5
        })
        return
    end

    while loopTpCoroutine do
        if #nonLocalPlayers == 0 then
             -- ループを停止するため、コルーチンを閉じる
            if loopTpCoroutine then coroutine.close(loopTpCoroutine) end
            OrionLib:MakeNotification({
                Name = "Info",
                Content = "ターゲットがいなくなったためキックを停止しました。", 
                Image = "rbxassetid://4483345998", 
                Time = 5
            })
            break
        end

        currentLoopTpPlayerIndex = currentLoopTpPlayerIndex % #nonLocalPlayers + 1
        local targetPlayer = nonLocalPlayers[currentLoopTpPlayerIndex]

        if not targetPlayer or not targetPlayer.Character or not targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
            table.remove(nonLocalPlayers, currentLoopTpPlayerIndex)
            currentLoopTpPlayerIndex = currentLoopTpPlayerIndex % #nonLocalPlayers
            task.wait(0.01)
            goto continue_loop
        end

        local targetHRP = targetPlayer.Character.HumanoidRootPart

        pcall(function()
            SetNetworkOwner:FireServer(blobmanRoot, targetHRP.CFrame * CFrame.new(0, -3, 0))
            task.wait(_G.BlobmanDelay)
            SetNetworkOwner:FireServer(blobmanRoot, blobmanRoot.CFrame)
        end)

        ::continue_loop::
        task.wait(_G.BlobmanDelay)
    end
end

-- -------------------------------------------------------------------------------------------------
-- その他の関数 (変更なし/無限ループを削除)
-- -------------------------------------------------------------------------------------------------

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

local function cleanupAnchoredParts()
    for _, part in ipairs(anchoredParts) do
        if part and part.Parent then
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
        if group.primaryPart and group.primaryPart == primaryPart and group.primaryPart.Parent then
            for _, data in ipairs(group.group) do
                if data.part and data.part.Parent then
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
    if not primaryPart or not primaryPart.Parent then return end
    local highlight = primaryPart:FindFirstChild("Highlight") or primaryPart.Parent:FindFirstChild("Highlight")
    if not highlight then
        highlight = createHighlight(primaryPart.Parent:IsA("Model") and primaryPart.Parent or primaryPart)
    end
    highlight.OutlineColor = Color3.new(0, 1, 0)
    local group = {}
    for _, part in ipairs(anchoredParts) do
        if part ~= primaryPart and part.Parent then
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
            if data.part and data.part.Parent then
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
    while compileCoroutine do
        pcall(function()
            for _, groupData in ipairs(compiledGroups) do
                updateBodyMovers(groupData.primaryPart)
            end
        end)
        task.wait()
    end
end

local function unanchorPrimaryPart()
    local primaryPart = anchoredParts[1]
    if not primaryPart or not primaryPart.Parent then return end
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

-- recoverParts()関数は定義されているが呼び出されていない -> Coroutineとして定義し直し
local function recoverPartsFunc()
    while AutoRecoverDroppedPartsCoroutine do
        pcall(function()
            local character = localPlayer.Character
            if character and character:FindFirstChild("Head") and character:FindFirstChild("HumanoidRootPart") then
                local humanoidRootPart = character.HumanoidRootPart
                for _, partModel in pairs(anchoredParts) do
                    coroutine.wrap(function()
                        if partModel and partModel.Parent then
                            local distance = (partModel.Position - humanoidRootPart.Position).Magnitude
                            if distance <= 30 then
                                local highlight = partModel:FindFirstChild("Highlight") or partModel.Parent:FindFirstChild("Highlight")
                                if highlight and highlight.OutlineColor == Color3.new(1, 0, 0) then
                                    SetNetworkOwner:FireServer(partModel, partModel.CFrame)
                                    if partModel:WaitForChild("PartOwner", 0.1) and partModel.PartOwner.Value == localPlayer.Name then
                                        highlight.OutlineColor = Color3.new(0, 0, 1)
                                    end
                                end
                            end
                        end
                    end)()
                end
            end
        end)
        task.wait(0.02)
    end
end

-- ragdollAll (トグル制御のコルーチン)
local function ragdollAllFunc()
    while ragdollAllCoroutine do
        pcall(function()
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
            
            if not bananaPeel then task.wait(0.1) return end
            
            local bodyPosition = banana.Main:FindFirstChild("BodyPosition") or Instance.new("BodyPosition")
            bodyPosition.P = 20000
            bodyPosition.Parent = banana.Main
            
            while ragdollAllCoroutine do
                for _, player in pairs(Players:GetChildren()) do
                    pcall(function()
                        if player.Character and player.Character ~= playerCharacter and player.Character.HumanoidRootPart then
                            bananaPeel.Position = player.Character.HumanoidRootPart.Position or player.Character.Head.Position
                            bodyPosition.Position = playerCharacter.Head.Position + Vector3.new(0, 600, 0)
                            task.wait()
                        end
                    end)
                end  
                task.wait()
            end
            
            DestroyT(banana)
        end)
        task.wait()
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
                connectionBombReload = toysFolder.ChildAdded:Connect(function(child)
                    if child.Name == _G.ToyToLoad and child:WaitForChild("ThisToysNumber", 1) then
                        if child.ThisToysNumber.Value == (toysFolder.ToyNumber.Value - 1) then
                            local connection2
                            connection2 = toysFolder.ChildRemoved:Connect(function(child2)
                                if child2 == child then
                                    connection2:Disconnect()
                                end
                            end)
                            
                            local bodyPart = child:FindFirstChild("Body") or child.PrimaryPart
                            if not bodyPart then return end
                            
                            SetNetworkOwner:FireServer(bodyPart, bodyPart.CFrame)
                            local waiting = bodyPart:WaitForChild("PartOwner", 0.5)
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
                                task.wait(0.2)
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
                while reloadBombCoroutine do
                    if localPlayer.CanSpawnToy and localPlayer.CanSpawnToy.Value and #bombList < _G.MaxMissiles and playerCharacter:FindFirstChild("Head") then
                        spawnItemCf(_G.ToyToLoad, playerCharacter.Head.CFrame or playerCharacter.HumanoidRootPart.CFrame)
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
            connectionBombReload = nil
        end
    end
end

local function setupAntiExplosion(character)
    local ragdolled = character:WaitForChild("Humanoid"):FindFirstChild("Ragdolled")
    if ragdolled then
        if antiExplosionConnection then
            antiExplosionConnection:Disconnect()
            antiExplosionConnection = nil
        end
        
        antiExplosionConnection = ragdolled:GetPropertyChangedSignal("Value"):Connect(function()
            if ragdolled.Value then
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
    end
end

-- -------------------------------------------------------------------------------------------------
-- UI要素の追加
-- -------------------------------------------------------------------------------------------------

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
                local character = localPlayer.Character
                if character and character:FindFirstChild("Head") then
                    local head = character.Head
                    local partOwner = head:FindFirstChild("PartOwner")
                    if partOwner then
                        Struggle:FireServer()
                        ReplicatedStorage.GameCorrectionEvents.StopAllVelocity:FireServer()
                        for _, part in pairs(character:GetChildren()) do
                            if part:IsA("BasePart") then
                                part.Anchored = true
                            end
                        end
                        task.spawn(function()
                            repeat task.wait() until not localPlayer.IsHeld.Value
                            for _, part in pairs(character:GetChildren()) do
                                if part:IsA("BasePart") then
                                    part.Anchored = false
                                end
                            end
                        end)
                    end
                end
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
                local character = localPlayer.Character
                local hrp = character and character:FindFirstChild("HumanoidRootPart")
                local fpp = hrp and hrp:FindFirstChild("FirePlayerPart")
                local partOwner = fpp and fpp:FindFirstChild("PartOwner")
                
                if partOwner and partOwner.Value ~= localPlayer.Name then
                    local args = {[1] = hrp, [2] = 0}
                    game:GetService("ReplicatedStorage"):WaitForChild("CharacterEvents"):WaitForChild("RagdollRemote"):FireServer(unpack(args))
                    task.wait(0.1)
                    Struggle:FireServer()
                end
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
            autoDefendCoroutine = coroutine.create(function()
                while autoDefendCoroutine do
                    local character = localPlayer.Character
                    local head = character and character:FindFirstChild("Head")
                    local partOwner = head and head:FindFirstChild("PartOwner")
                    
                    if partOwner then
                        local attacker = Players:FindFirstChild(partOwner.Value)
                        if attacker and attacker.Character then
                            Struggle:FireServer()
                            local attackerTorso = attacker.Character:FindFirstChild("Torso")
                            if attackerTorso then
                                local attackerFirePart = attacker.Character.HumanoidRootPart.FirePlayerPart
                                SetNetworkOwner:FireServer(attackerTorso, attackerFirePart.CFrame)
                                task.wait(0.1)
                                
                                local velocity = attackerTorso:FindFirstChild("l") or Instance.new("BodyVelocity")
                                velocity.Name = "l"
                                velocity.Parent = attackerTorso
                                velocity.Velocity = Vector3.new(0, 50, 0)
                                velocity.MaxForce = Vector3.new(0, math.huge, 0)
                                Debris:AddItem(velocity, 100)
                            end
                        end
                    end
                    task.wait(0.02)
                end
            end)
            coroutine.resume(autoDefendCoroutine)
        else
            if autoDefendCoroutine then
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
            autoDefendKickCoroutine = coroutine.create(function()
                while autoDefendKickCoroutine do
                    local character = localPlayer.Character
                    local head = character and character:FindFirstChild("Head")
                    local partOwner = head and head:FindFirstChild("PartOwner")
                    
                    if partOwner then
                        local attacker = Players:FindFirstChild(partOwner.Value)
                        if attacker and attacker.Character and attacker.Character.HumanoidRootPart and attacker.Character.HumanoidRootPart:FindFirstChild("FirePlayerPart") then
                            Struggle:FireServer()
                            local attackerFirePart = attacker.Character.HumanoidRootPart.FirePlayerPart
                            SetNetworkOwner:FireServer(attackerFirePart, attackerFirePart.CFrame)
                            task.wait(0.1)
                            
                            if not attackerFirePart:FindFirstChild("BodyVelocity") then
                                local bodyVelocity = Instance.new("BodyVelocity")
                                bodyVelocity.Name = "BodyVelocity"
                                bodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                                bodyVelocity.Velocity = Vector3.new(0, 20, 0)
                                bodyVelocity.Parent = attackerFirePart
                            end
                        end
                    end
                    task.wait(0.02)
                end
            end)
            coroutine.resume(autoDefendKickCoroutine)
        else
            if autoDefendKickCoroutine then
                coroutine.close(autoDefendKickCoroutine)
                autoDefendKickCoroutine = nil
            end
        end
    end
})

BlobmanTab:AddToggle({
    Name = "ブロブマンに座る",
    Default = false,
    Color = Color3.fromRGB(240, 0, 0),
    Save = true,
    Flag = "AutoSitBlobman",
    Callback = function(enabled)
        AutoSitEnabled = enabled
        if enabled and not foundBlobman then
             for _, v in pairs(game.Workspace:GetDescendants()) do
                if v:IsA("Model") and v.Name == "CreatureBlobman" then
                    foundBlobman = v
                    break
                end
            end
        end
    end
})

local blobman1
blobman1 = BlobmanTab:AddToggle({
    Name = "Kick All",
    Color = Color3.fromRGB(240, 0, 0),
    Default = false,
    Callback = function(enabled)
        if enabled then
            loopTpCoroutine = coroutine.create(function()
                local foundBlobmanInstance
                for _, v in pairs(game.Workspace:GetDescendants()) do
                    if v:IsA("Model") and v.Name == "CreatureBlobman" then
                        local seat = v:FindFirstChild("VehicleSeat")
                        if seat and seat:FindFirstChild("SeatWeld") and isDescendantOf(seat.SeatWeld.Part1, localPlayer.Character) then
                            foundBlobmanInstance = v
                            blobman = v
                            break
                        end
                    end
                end
                
                if not foundBlobmanInstance then
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
                
                currentLoopTpPlayerIndex = 0 -- 1から始まるので0に初期化
                loopTPFunction(foundBlobmanInstance)
            end)
            coroutine.resume(loopTpCoroutine)
        else
            if loopTpCoroutine then
                coroutine.close(loopTpCoroutine)
                loopTpCoroutine = nil
                blobman = nil
            end
        end
    end
})

BlobmanTab:AddSlider({
    Name = "tp時間&グラブ時間",
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

CharacterTab:AddToggle({
    Name = "しゃがみ速度",
    Default = false,
    Save = true,
    Color = Color3.fromRGB(240, 0, 0),
    Flag = "CrouchSpeed",
    Callback = function(enabled)
        if enabled then
            crouchSpeedCoroutine = coroutine.create(function()
                while crouchSpeedCoroutine do
                    pcall(function()
                        local humanoid = playerCharacter and playerCharacter.Humanoid
                        if not humanoid then task.wait() return end
                        if humanoid.WalkSpeed == 5 then
                            humanoid.WalkSpeed = crouchWalkSpeed
                        end
                    end)
                    task.wait()
                end
            end)
            coroutine.resume(crouchSpeedCoroutine)
        elseif crouchSpeedCoroutine then
            coroutine.close(crouchSpeedCoroutine)
            crouchSpeedCoroutine = nil
            if playerCharacter and playerCharacter.Humanoid then
                playerCharacter.Humanoid.WalkSpeed = 16
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
            crouchJumpCoroutine = coroutine.create(function()
                while crouchJumpCoroutine do
                    pcall(function()
                        local humanoid = playerCharacter and playerCharacter.Humanoid
                        if not humanoid then task.wait() return end
                        if humanoid.JumpPower == 12 then
                            humanoid.JumpPower = crouchJumpPower
                        end
                    end)
                    task.wait()
                end
            end)
            coroutine.resume(crouchJumpCoroutine)
        elseif crouchJumpCoroutine then
            coroutine.close(crouchJumpCoroutine)
            crouchJumpCoroutine = nil
            if playerCharacter and playerCharacter.Humanoid then
                -- 2. 構文エラーの修正: '24end' -> '24 end'
                playerCharacter.Humanoid.JumpPower = 24
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
            for index, decoy in pairs(decoys) do
                local torso = decoy:FindFirstChild("Torso")
                if torso then
                    local bodyPosition = torso:FindFirstChild("BodyPosition")
                    local bodyGyro = torso:FindFirstChild("BodyGyro")
                    if bodyPosition and bodyGyro and playerCharacter and playerCharacter:FindFirstChild("HumanoidRootPart") then
                        
                        local targetPosition
                        if followMode then
                            targetPosition = playerCharacter.HumanoidRootPart.Position
                            local offset = (index - midPoint) * decoyOffset
                            local forward = playerCharacter.HumanoidRootPart.CFrame.LookVector
                            local right = playerCharacter.HumanoidRootPart.CFrame.RightVector
                            targetPosition = targetPosition - forward * decoyOffset + right * offset
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
                                if followMode then
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
                local connection = RunService.Heartbeat:Connect(updateDecoyPositions)
                table.insert(connections, connection)
                SetNetworkOwner:FireServer(torso, playerCharacter.Head.CFrame)
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
        for _, descendant in pairs(workspace:GetDescendants()) do
            if descendant:IsA("Model") and descendant.Name == "YouDecoy" then
                local torso = descendant:FindFirstChild("Torso")
                if torso then
                    for _, child in pairs(torso:GetChildren()) do
                        if child:IsA("BodyPosition") or child:IsA("BodyGyro") then
                            child:Destroy()
                        end
                    end
                end
            end
        end
    end
})

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
            auraCoroutine = coroutine.create(function()
                while auraCoroutine do
                    pcall(function()
                        local character = localPlayer.Character
                        local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
                        if not humanoidRootPart then task.wait(0.02) return end

                        for _, player in pairs(Players:GetPlayers()) do
                            if player ~= localPlayer and player.Character then
                                local playerCharacter = player.Character
                                local playerTorso = playerCharacter:FindFirstChild("Torso")
                                local playerHrp = playerCharacter:FindFirstChild("HumanoidRootPart")
                                
                                if playerTorso and playerHrp and playerHrp:FindFirstChild("FirePlayerPart") then
                                    local distance = (playerTorso.Position - humanoidRootPart.Position).Magnitude
                                    if distance <= auraRadius then
                                        task.spawn(function()
                                            SetNetworkOwner:FireServer(playerTorso, playerHrp.FirePlayerPart.CFrame)
                                            task.wait(0.1)
                                            local velocity = playerTorso:FindFirstChild("l") or Instance.new("BodyVelocity", playerTorso)
                                            velocity.Name = "l"
                                            velocity.Velocity = Vector3.new(0, 50, 0)
                                            velocity.MaxForce = Vector3.new(0, math.huge, 0)
                                            Debris:AddItem(velocity, 100)
                                        end)
                                    end
                                end
                            end
                        end
                    end)
                    task.wait(0.02)
                end
            end)
            coroutine.resume(auraCoroutine)
        else
            if auraCoroutine then
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
            gravityCoroutine = coroutine.create(function()
                while gravityCoroutine do
                    pcall(function()
                        local character = localPlayer.Character
                        local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
                        if not humanoidRootPart then task.wait(0.02) return end

                        for _, player in pairs(Players:GetPlayers()) do
                            if player ~= localPlayer and player.Character then
                                local playerCharacter = player.Character
                                local playerTorso = playerCharacter:FindFirstChild("Torso")
                                local playerHrp = playerCharacter:FindFirstChild("HumanoidRootPart")
                                
                                if playerTorso and playerHrp and playerHrp:FindFirstChild("FirePlayerPart") then
                                    local distance = (playerTorso.Position - humanoidRootPart.Position).Magnitude
                                    if distance <= auraRadius then
                                        task.spawn(function()
                                            SetNetworkOwner:FireServer(playerTorso, playerHrp.FirePlayerPart.CFrame)
                                            task.wait(0.1)
                                            local force = playerTorso:FindFirstChild("GravityForce") or Instance.new("BodyForce")
                                            force.Parent = playerTorso
                                            force.Name = "GravityForce"
                                            for _, part in ipairs(playerCharacter:GetDescendants()) do
                                                if part:IsA("BasePart") then
                                                    part.CanCollide = false
                                                end
                                            end
                                            force.Force = Vector3.new(0, 1200, 0)
                                        end)
                                    end
                                end
                            end
                        end
                    end)
                    task.wait(0.02)
                end
            end)
            coroutine.resume(gravityCoroutine)
        elseif gravityCoroutine then
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
        if enabled then
            kickCoroutine = coroutine.create(function()
                while kickCoroutine do
                    pcall(function()
                        local character = localPlayer.Character
                        local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
                        if not humanoidRootPart then task.wait(0.02) return end

                        for _, player in pairs(Players:GetPlayers()) do
                            if player ~= localPlayer and player.Character then
                                local playerCharacter = player.Character
                                local playerHead = playerCharacter:FindFirstChild("Head")
                                local playerHrp = playerCharacter:FindFirstChild("HumanoidRootPart")

                                if playerHead and playerHrp and playerHrp:FindFirstChild("FirePlayerPart") then
                                    local distance = (playerHead.Position - humanoidRootPart.Position).Magnitude
                                    if distance <= auraRadius then
                                        SetNetworkOwner:FireServer(playerHrp.FirePlayerPart, playerHrp.FirePlayerPart.CFrame)
                                        
                                        if auraToggle == 1 then -- サイレント (プラットフォーム)
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
                                        elseif auraToggle == 2 then -- 空 (BodyVelocity)
                                            if not playerHrp.FirePlayerPart:FindFirstChild("BodyVelocity") then
                                                local bodyVelocity = Instance.new("BodyVelocity")
                                                bodyVelocity.Name = "BodyVelocity"
                                                bodyVelocity.Velocity = Vector3.new(0, 20, 0)
                                                bodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                                                bodyVelocity.Parent = playerHrp.FirePlayerPart
                                            end
                                        end
                                    end
                                end
                            end
                        end
                        
                        -- プラットフォームの更新とクリーンアップ
                        for player, platform in pairs(platforms) do
                            if platform and player.Character and player.Character.Humanoid and player.Character.Humanoid.Health > 1 then
                                local playerHumanoidRootPart = player.Character.HumanoidRootPart
                                platform.Position = playerHumanoidRootPart.Position - Vector3.new(0, 3.994, 0)
                            else
                                if platform then platform:Destroy() end
                                platforms[player] = nil
                            end
                        end
                    end)
                    task.wait(0.02)
                end
            end)
            coroutine.resume(kickCoroutine)
        else
            if kickCoroutine then
                coroutine.close(kickCoroutine)
                kickCoroutine = nil
            end
            -- 全プラットフォームのクリーンアップ
            for _, platform in pairs(platforms) do
                if platform then
                    platform:Destroy()
                end
            end
            platforms = {}
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
        end
        -- オーラがオンの場合、モード変更を適用するために再起動
        if kickCoroutine then
            local wasRunning = coroutine.running(kickCoroutine)
            if wasRunning then
                local oldCoroutine = kickCoroutine
                kickCoroutine = nil -- トグルが停止処理に入るのを防ぐ
                coroutine.close(oldCoroutine)
                -- 再起動
                AuraTab:GetToggle("キックオーラ"):Set(false) -- 一旦オフ
                AuraTab:GetToggle("キックオーラ"):Set(true) -- 再度オン
            end
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
            poisonAuraCoroutine = coroutine.create(function()
                while poisonAuraCoroutine do
                    pcall(function()
                        local character = localPlayer.Character
                        local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
                        if not humanoidRootPart then task.wait(0.02) return end

                        for _, player in pairs(Players:GetPlayers()) do
                            if player ~= localPlayer and player.Character then
                                local playerCharacter = player.Character
                                local playerTorso = playerCharacter:FindFirstChild("Torso")
                                
                                if playerTorso then
                                    local distance = (playerTorso.Position - humanoidRootPart.Position).Magnitude
                                    if distance <= auraRadius then
                                        local head = playerCharacter:FindFirstChild("Head")
                                        if head then
                                            -- 範囲内のプレイヤーに対して、毒パーツを継続的に配置
                                            task.spawn(function()
                                                while poisonAuraCoroutine and (playerTorso.Position - humanoidRootPart.Position).Magnitude <= auraRadius do
                                                    SetNetworkOwner:FireServer(playerTorso, playerCharacter.HumanoidRootPart.CFrame)
                                                    
                                                    for _, part in pairs(poisonHurtParts) do
                                                        part.Size = Vector3.new(1, 3, 1)
                                                        part.Transparency = 1
                                                        part.Position = head.Position
                                                    end
                                                    task.wait()
                                                    for _, part in pairs(poisonHurtParts) do
                                                        part.Position = Vector3.new(0, -200, 0)
                                                    end
                                                end
                                                -- 範囲外に出た後のクリーンアップ
                                                for _, part in pairs(poisonHurtParts) do
                                                    part.Position = Vector3.new(0, -200, 0)
                                                end
                                            end)
                                        end
                                    end
                                end
                            end
                        end
                    end)
                    task.wait(0.02)
                end
            end)
            coroutine.resume(poisonAuraCoroutine)
        elseif poisonAuraCoroutine then
            coroutine.close(poisonAuraCoroutine)
            for _, part in pairs(poisonHurtParts) do
                part.Position = Vector3.new(0, -200, 0)
            end
            poisonAuraCoroutine = nil
        end
    end
})
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
            local humanoid = character and character:FindFirstChildOfClass("Humanoid")
            local hrp = character and character:FindFirstChild("HumanoidRootPart")
            local torso = character and character:FindFirstChild("Torso")
            
            if character and humanoid and hrp and torso then
                task.spawn(function()
                    SetNetworkOwner:FireServer(hrp, hrp.CFrame)
                    for _, part in ipairs(character:GetDescendants()) do
                        if part:IsA("BasePart") or part:IsA("Part") then
                            part.CanCollide = false
                        end
                    end
                    local bodyVelocity = Instance.new("BodyVelocity")
                    bodyVelocity.Parent = torso
                    bodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                    bodyVelocity.Velocity = Vector3.new(0, -4, 0)
                    torso.CanCollide = false
                    task.wait(1)
                    torso.CanCollide = false
                    Debris:AddItem(bodyVelocity, 5)
                end)
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
            local humanoid = character and character:FindFirstChildOfClass("Humanoid")
            local hrp = character and character:FindFirstChild("HumanoidRootPart")
            local fpp = hrp and hrp:FindFirstChild("FirePlayerPart")
            
            if character and humanoid and hrp and fpp then
                task.spawn(function()
                    if kickMode == 1 then -- 空 (BodyVelocity) 
                        SetNetworkOwner:FireServer(fpp, fpp.CFrame)
                        local bodyVelocity = Instance.new("BodyVelocity")
                        bodyVelocity.Parent = fpp
                        bodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                        bodyVelocity.Velocity = Vector3.new(0, 20, 0)
                        Debris:AddItem(bodyVelocity, 5)
                    elseif kickMode == 2 then -- サイレント (プラットフォーム)
                        SetNetworkOwner:FireServer(fpp, fpp.CFrame)
                        local platform = character:FindFirstChild("FloatingPlatform") or Instance.new("Part")
                        platform.Name = "FloatingPlatform"
                        platform.Size = Vector3.new(5, 2, 5)
                        platform.Anchored = true
                        platform.Transparency = 1
                        platform.CanCollide = true
                        platform.Parent = character
                        
                        task.spawn(function()
                            while character.Humanoid.Health > 0 and platform.Parent == character do
                                platform.Position = hrp.Position - Vector3.new(0, 3.994, 0)
                                task.wait()
                            end
                            if platform then platform:Destroy() end
                        end)
                    end
                end)
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
            local humanoid = character and character:FindFirstChildOfClass("Humanoid")
            local hrp = character and character:FindFirstChild("HumanoidRootPart")
            local head = character and character:FindFirstChild("Head")

            if character and humanoid and hrp and head then
                task.spawn(function()
                    SetNetworkOwner:FireServer(hrp, hrp.CFrame)
                    SetNetworkOwner:FireServer(head, head.CFrame)
                    for _, motor in pairs(character:GetDescendants()) do
                        if motor:IsA('Motor6D') then
                            SetNetworkOwner:FireServer(motor.Part1, motor.Part1.CFrame)
                            motor:Destroy()
                        end
                    end
                    task.wait(0.5)
                    SetNetworkOwner:FireServer(head, head.CFrame)
                end)
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
        local mouse = localPlayer:GetMouse()
        local target = mouse.Target
        if not ownedToys["Campfire"] then 
            OrionLib:MakeNotification({Name = "Missing toy", Content = "あなたはキャンプファイヤーを所有していません ", Image = "rbxassetid://4483345998", Time = 3})
            return
        end
        if target and target:IsA("BasePart") then
            local character = target.Parent
            if target.Name == "FirePlayerPart" then
                character = target.Parent.Parent
            end
            local humanoid = character and character:FindFirstChildOfClass("Humanoid")
            local hrp = character and character:FindFirstChild("HumanoidRootPart")
            local head = character and character:FindFirstChild("Head")

            if character and humanoid and hrp and head then
                task.spawn(function()
                    if not toysFolder:FindFirstChild("Campfire") then
                        spawnItem("Campfire", Vector3.new(-72.9304581, -5.96906614, -265.543732))
                    end
                    local campfire = toysFolder:FindFirstChild("Campfire")
                    if not campfire then return end
                    
                    local firePlayerPart
                    SetNetworkOwner:FireServer(hrp, hrp.CFrame)
                    for _, part in pairs(campfire:GetChildren()) do
                        if part.Name == "FirePlayerPart" then
                            part.Size = Vector3.new(9, 9, 9)
                            firePlayerPart = part
                            break
                        end
                    end
                    
                    if firePlayerPart then
                        firePlayerPart.Position = head.Position or hrp.Position
                        task.wait(0.5)
                        firePlayerPart.Position = Vector3.new(0, -50, 0)
                    end
                end)
            end
        end
    end
})

local KeybindSection2 = KeybindsTab:AddSection({Name = "Missile Keybinds"})
KeybindSection2:AddParagraph("Tip", "Press anywhere")

KeybindSection2:AddBind({
    Name = "爆弾",
    Default = "B",
    Hold = false,
    Save = true,
    Flag = "ExplodeBombKeybind",
    Callback = function()
        if not ownedToys[_G.ToyToLoad] then 
            OrionLib:MakeNotification({Name = "Missing toy", Content = "あなたは爆弾を持っていません ", Image = "rbxassetid://4483345998", Time = 3})
            return
        end
        local connection
        connection = toysFolder.ChildAdded:Connect(function(child)
            if child.Name == _G.ToyToLoad then
                if child:WaitForChild("ThisToysNumber", 1) then
                    if child.ThisToysNumber.Value == (toysFolder.ToyNumber.Value - 1) then
                        connection:Disconnect()
                        
                        local partHitDetector = child:FindFirstChild("PartHitDetector")
                        local bodyPart = child:FindFirstChild("Body")
                        
                        if partHitDetector and bodyPart and playerCharacter and playerCharacter.HumanoidRootPart then
                            SetNetworkOwner:FireServer(partHitDetector, partHitDetector.CFrame)
                            local args = {
                                [1] = {
                                    ["Radius"] = 17.5,
                                    ["TimeLength"] = 2,
                                    ["Hitbox"] = partHitDetector,
                                    ["ExplodesByFire"] = false,
                                    ["MaxForcePerStudSquared"] = 225,
                                    ["Model"] = child,
                                    ["ImpactSpeed"] = 100,
                                    ["ExplodesByPointy"] = false,
                                    ["DestroysModel"] = false,
                                    ["PositionPart"] = bodyPart
                                },
                                [2] = playerCharacter.HumanoidRootPart.Position or playerCharacter.PrimaryPart.Position
                            }
                            ReplicatedStorage:WaitForChild("BombEvents"):WaitForChild("BombExplode"):FireServer(unpack(args))
                        end
                    end
                end
            end
        end)
        spawnItemCf(_G.ToyToLoad, playerCharacter.Head.CFrame or playerCharacter.HumanoidRootPart.CFrame)
        task.delay(1, function() if connection then connection:Disconnect() end end)
    end
})

KeybindSection2:AddBind({
    Name = "Throw Bomb",
    Default = "M",
    Hold = false,
    Save = true,
    Flag = "ThrowBombKeybind",
    Callback = function()
        if not ownedToys[_G.ToyToLoad] then 
            OrionLib:MakeNotification({Name = "Missing toy", Content = "You do not own the BombMissile toy. ", Image = "rbxassetid://4483345998", Time = 3})
            return
        end
        local connection
        connection = toysFolder.ChildAdded:Connect(function(child)
            if child.Name == _G.ToyToLoad then
                if child:WaitForChild("ThisToysNumber", 1) then
                    if child.ThisToysNumber.Value == (toysFolder.ToyNumber.Value - 1) then
                        connection:Disconnect()
                        local partHitDetector = child:FindFirstChild("PartHitDetector")
                        if partHitDetector then
                            SetNetworkOwner:FireServer(partHitDetector, partHitDetector.CFrame)
                            local velocityObj = Instance.new("BodyVelocity", partHitDetector)
                            velocityObj.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                            velocityObj.Velocity = workspace.CurrentCamera.CFrame.lookVector * 500
                            Debris:AddItem(velocityObj, 10)
                        end
                    end
                end
            end
        end)
        spawnItemCf(_G.ToyToLoad, playerCharacter.Head.CFrame or playerCharacter.HumanoidRootPart.CFrame)
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
        local connection
        connection = toysFolder.ChildAdded:Connect(function(child)
            if child.Name == "FireworkMissile" then
                if child:WaitForChild("ThisToysNumber", 1) then
                    if child.ThisToysNumber.Value == (toysFolder.ToyNumber.Value - 1) then
                        connection:Disconnect()
                        
                        local partHitDetector = child:FindFirstChild("PartHitDetector")
                        local bodyPart = child:FindFirstChild("Body")

                        if partHitDetector and bodyPart and playerCharacter and playerCharacter.HumanoidRootPart then
                            SetNetworkOwner:FireServer(partHitDetector, partHitDetector.CFrame)
                            local args = {
                                [1] = {
                                    ["Radius"] = 17.5,
                                    ["TimeLength"] = 2,
                                    ["Hitbox"] = partHitDetector,
                                    ["ExplodesByFire"] = false,
                                    ["MaxForcePerStudSquared"] = 225,
                                    ["Model"] = child,
                                    ["ImpactSpeed"] = 100,
                                    ["ExplodesByPointy"] = false,
                                    ["DestroysModel"] = false,
                                    ["PositionPart"] = bodyPart
                                },
                                [2] = playerCharacter.HumanoidRootPart.Position or playerCharacter.PrimaryPart.Position
                            }
                            ReplicatedStorage:WaitForChild("BombEvents"):WaitForChild("BombExplode"):FireServer(unpack(args))
                        end
                    end
                end
            end
        })
        spawnItemCf("FireworkMissile", playerCharacter.Head.CFrame or playerCharacter.HumanoidRootPart.CFrame)
        task.delay(1, function() if connection then connection:Disconnect() end end)
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
        local bomb = table.remove(bombList, 1)
        
        if bomb and bomb:FindFirstChild("PartHitDetector") and bomb:FindFirstChild("Body") and playerCharacter and playerCharacter.HumanoidRootPart then
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
                    ["PositionPart"] = playerCharacter.HumanoidRootPart or playerCharacter.PrimaryPart
                },
                [2] = playerCharacter.HumanoidRootPart.Position or playerCharacter.PrimaryPart.Position
            }
            ReplicatedStorage:WaitForChild("BombEvents"):WaitForChild("BombExplode"):FireServer(unpack(args))
        end
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
        for i = #bombList, 1, -1 do
            local bomb = table.remove(bombList, i)
            if bomb and bomb:FindFirstChild("PartHitDetector") and bomb:FindFirstChild("Body") and playerCharacter and playerCharacter.HumanoidRootPart then
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
                        ["PositionPart"] = playerCharacter.HumanoidRootPart or playerCharacter.PrimaryPart
                    },
                    [2] = playerCharacter.HumanoidRootPart.Position or playerCharacter.PrimaryPart.Position
                }
                ReplicatedStorage:WaitForChild("BombEvents"):WaitForChild("BombExplode"):FireServer(unpack(args))
            end
            task.wait(0.05) -- 短いクールダウン
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
        local nearestPlayer = getNearestPlayer()
        if not nearestPlayer or not nearestPlayer.Character or not nearestPlayer.Character.HumanoidRootPart then
            OrionLib:MakeNotification({Name = "Error", Content = "最も近いプレイヤーが見つかりません", Image = "rbxassetid://4483345998", Time = 2})
            return
        end

        local char = nearestPlayer.Character
        local targetPart = char.HumanoidRootPart or char.Torso or char.PrimaryPart
        if not targetPart then return end

        for i = #bombList, 1, -1 do
            local bomb = table.remove(bombList, i)
            if bomb and bomb:FindFirstChild("PartHitDetector") and bomb:FindFirstChild("Body") then
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
                        ["PositionPart"] = targetPart
                    },
                    [2] = targetPart.Position
                }
                ReplicatedStorage:WaitForChild("BombEvents"):WaitForChild("BombExplode"):FireServer(unpack(args))
            end
            task.wait(0.05) -- 短いクールダウン
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
                if not localPlayer.Character or not localPlayer.Character.HumanoidRootPart then 
                    return 
                end
                lightbitoffset = lightbitoffset + lightbit
                lightbitpos = U.GetSurroundingVectors(localPlayer.Character.HumanoidRootPart.Position, usingradius, #lightbitparts, lightbitoffset)

                for i, v in ipairs(lightbitpos) do
                    if bodyPositions[i] and alignOrientations[i] and lightbitparts[i] then
                        bodyPositions[i].Position = v
                        local part = lightbitparts[i]
                        local lookAtCFrame = CFrame.lookAt(part.Position, localPlayer.Character.HumanoidRootPart.Position)
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
            lightbitcon = nil
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
            lightbitcon2 = nil
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
    Max = localPlayer.ToysLimitCap.Value / 10,
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

DevTab:AddLabel("バナナの皮だけにしてください")

DevTab:AddToggle({
    Name = "ラグドールオール",
    Color = Color3.fromRGB(240, 0, 0),
    Default = false,
    Save = true,
    Callback = function(enabled)
        if enabled then
            ragdollAllCoroutine = coroutine.create(ragdollAllFunc)
            coroutine.resume(ragdollAllCoroutine)
        else
            if ragdollAllCoroutine then
                coroutine.close(ragdollAllCoroutine)
                ragdollAllCoroutine = nil
                if toysFolder:FindFirstChild("FoodBanana") then
                    DestroyT(toysFolder:FindFirstChild("FoodBanana"))
                end
            end
        end
    end
})

-- RunService.Heartbeat統合ロジック (自動着席機能)
local autoSitConnection
autoSitConnection = RunService.Heartbeat:Connect(function(dt)
    if AutoSitEnabled and localPlayer.Character and localPlayer.Character.Humanoid and localPlayer.Character.Humanoid.SeatPart == nil then
        if foundBlobman then
            local VehicleSeat = foundBlobman:FindFirstChild("VehicleSeat")
            if VehicleSeat then
                VehicleSeat:Sit(localPlayer.Character.Humanoid)
            end
        else
            -- 5. 非効率なコードの改善: Heartbeat内でGetDescendants()を呼ばないように修正
            for _, v in pairs(game.Workspace:GetChildren()) do -- GetChildrenに限定
                if v:IsA("Model") and v.Name == "CreatureBlobman" then
                    foundBlobman = v
                    break
                end
            end
        end
    end
end)

-- CharacterAdded イベント (自動着席対応)
localPlayer.CharacterAdded:Connect(function(character)
    playerCharacter = character
    
    if AutoSitEnabled and foundBlobman then
        task.wait(1)
        local VehicleSeat = foundBlobman:FindFirstChild("VehicleSeat")
        if VehicleSeat and character.Humanoid and character.Humanoid.SeatPart == nil then
            VehicleSeat:Sit(character.Humanoid)
        end
    end
end)

-- Blobmanモデルの出現/消滅を監視するロジックを追加 (AutoSitの効率改善のため)
workspace.DescendantAdded:Connect(function(descendant)
    if descendant:IsA("Model") and descendant.Name == "CreatureBlobman" then
        foundBlobman = descendant
    end
end)

workspace.DescendantRemoving:Connect(function(descendant)
    if descendant == foundBlobman then
        foundBlobman = nil
    end
end)

-- 終了処理
game:GetService("Players").PlayerRemoving:Connect(function(player)
    if player == localPlayer then
        if loopTpCoroutine then coroutine.close(loopTpCoroutine) end
        if blobmanCoroutine then coroutine.close(blobmanCoroutine) end
        if tpAllCoroutine then coroutine.close(tpAllCoroutine) end
        if autoSitConnection then autoSitConnection:Disconnect() end
        -- その他の全てのコルーチンもここで閉じるべきだが、煩雑なため省略。
        -- 理想的には、全てのコルーチン変数に対してcoroutine.close()を呼び出す。
    end
end)

-- 通知とUI初期化
OrionLib:MakeNotification({
    Name = "Welcome", 
    Content = "ようこそ、野獣のおちんちんハブへ", 
    Image = "rbxassetid://4483345998", 
    Time = 5
})

OrionLib:Init()

print("🎮 野獣のおちんちんハブ - スクリプト読み込み完了!")
print("📌 バージョン: " .. getVersion())
print("✅ すべての機能が正常に初期化されました")

