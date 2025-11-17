--[[
    野獣のおちんちんハブ クライアントスクリプト - 完全修正版
    
    主な修正点:
    1. フラグベースのループ制御に変更
    2. すべてのコルーチンと接続を適切に管理
    3. エラーハンドリングの強化
    4. nil チェックの追加
    5. グローバル変数をローカルに変更
    6. メモリリークの防止
    7. 非効率なコードの最適化
--]]

local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")
local MarketplaceService = game:GetService("MarketplaceService")

-- サービスの安全な取得
local function getService(serviceName)
    local success, service = pcall(function()
        return game:GetService(serviceName)
    end)
    if not success then
        warn("Failed to get service: " .. serviceName)
        return nil
    end
    return service
end

-- リモートの安全な取得
local GrabEvents = ReplicatedStorage:WaitForChild("GrabEvents", 10)
local MenuToys = ReplicatedStorage:WaitForChild("MenuToys", 10)
local CharacterEvents = ReplicatedStorage:WaitForChild("CharacterEvents", 10)

if not GrabEvents or not MenuToys or not CharacterEvents then
    warn("Failed to load required RemoteEvents")
    return
end

local SetNetworkOwner = GrabEvents:WaitForChild("SetNetworkOwner")
local Struggle = CharacterEvents:WaitForChild("Struggle")
local CreateLine = GrabEvents:WaitForChild("CreateGrabLine")
local DestroyLine = GrabEvents:WaitForChild("DestroyGrabLine")
local DestroyToy = MenuToys:WaitForChild("DestroyToy")

local localPlayer = Players.LocalPlayer
local playerCharacter = localPlayer.Character or localPlayer.CharacterAdded:Wait()

-- キャラクター更新の管理
local characterConnection
characterConnection = localPlayer.CharacterAdded:Connect(function(character)
    playerCharacter = character
end)

-- バージョン情報
local version = "1.0.2 (Fully Fixed)"

-- ローカル変数に変更（グローバル汚染を防ぐ）
local AutoSitEnabled = false
local LoopTpEnabled = false
local LocalNoclipEnabled = false
local VehicleTPEnabled = false

-- 実行フラグ（コルーチン制御用）
local flags = {
    kickGrabRunning = false,
    grabHandlerRunning = false,
    fireGrabRunning = false,
    noclipGrabRunning = false,
    fireAllRunning = false,
    anchorGrabRunning = false,
    anchorKickGrabRunning = false,
    poisonAuraRunning = false,
    auraRunning = false,
    gravityRunning = false,
    kickRunning = false,
    ragdollAllRunning = false,
    loopTpRunning = false,
    recoverPartsRunning = false,
    crouchSpeedRunning = false,
    crouchJumpRunning = false,
}

-- コルーチン/接続の管理テーブル
local coroutines = {}
local connections = {
    kickGrab = {},
    general = {},
    renderStepped = {},
    anchored = {},
    compile = {},
}

-- その他の状態変数
local anchoredParts = {}
local compiledGroups = {}
local bombList = {}
local platforms = {}
local ownedToys = {}
local playerList = {}
local poisonHurtParts = {}
local paintPlayerParts = {}
local lightbitparts = {}
local bodyPositions = {}
local alignOrientations = {}

-- 設定変数
_G.TPDelay = 0.5
_G.strength = 400
_G.ToyToLoad = "BombMissile"
_G.MaxMissiles = 9
_G.BlobmanDelay = 0.05

local decoyOffset = 15
local stopDistance = 5
local circleRadius = 10
local circleSpeed = 2
local auraToggle = 1
local crouchWalkSpeed = 50
local crouchJumpPower = 50
local kickMode = 1
local auraRadius = 20
local lightbit = 0.3125
local lightbitoffset = 1
local lightbitradius = 20
local usingradius = lightbitradius
local foundBlobman = nil
local blobman = nil
local followMode = true
local currentLoopTpPlayerIndex = 1

-- Utilities
local Utilities = {}
local U = Utilities

function Utilities.IsDescendantOf(child, parent)
    if not child or not parent then return false end
    local currentParent = child.Parent
    while currentParent do
        if currentParent == parent then return true end
        currentParent = currentParent.Parent
    end
    return false
end

function Utilities.GetDescendant(parent, name, className)
    if not parent then return nil end
    for _, descendant in ipairs(parent:GetDescendants()) do
        if descendant.Name == name and (not className or descendant:IsA(className)) then
            return descendant
        end
    end
    return nil
end

function Utilities.GetAncestor(child, name, className)
    if not child then return nil end
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
    if not child then return nil end
    local currentParent = child.Parent
    while currentParent do
        if currentParent:IsA(className) then return currentParent end
        currentParent = currentParent.Parent
    end
    return nil
end

function Utilities.GetChildrenByType(parent, className)
    if not parent then return {} end
    local results = {}
    for _, child in ipairs(parent:GetChildren()) do
        if child:IsA(className) then
            table.insert(results, child)
        end
    end
    return results
end

function Utilities.GetDescendantsByType(parent, className)
    if not parent then return {} end
    local results = {}
    for _, descendant in ipairs(parent:GetDescendants()) do
        if descendant:IsA(className) then
            table.insert(results, descendant)
        end
    end
    return results
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

-- 接続のクリーンアップ関数（強化版）
local function cleanupConnections(connectionTable)
    if not connectionTable then return end
    for i = #connectionTable, 1, -1 do
        local connection = connectionTable[i]
        if connection then
            local success, err = pcall(function()
                if typeof(connection) == "RBXScriptConnection" then
                    connection:Disconnect()
                end
            end)
            if not success then
                warn("Failed to disconnect connection:", err)
            end
        end
        table.remove(connectionTable, i)
    end
end

-- コルーチンのクリーンアップ関数
local function cleanupCoroutine(coroutineName)
    if coroutines[coroutineName] then
        local success, err = pcall(function()
            if coroutine.status(coroutines[coroutineName]) ~= "dead" then
                coroutine.close(coroutines[coroutineName])
            end
        end)
        if not success then
            warn("Failed to close coroutine " .. coroutineName .. ":", err)
        end
        coroutines[coroutineName] = nil
    end
end

-- エラーハンドリング付きpcall
local function safePcall(func, context)
    local success, err = pcall(func)
    if not success then
        warn(context and (context .. ": " .. tostring(err)) or ("Error: " .. tostring(err)))
    end
    return success, err
end

-- プレイヤーリストの更新
local function updatePlayerList()
    playerList = {}
    for _, player in ipairs(Players:GetPlayers()) do
        table.insert(playerList, player.Name)
    end
end

Players.PlayerAdded:Connect(function(player)
    table.insert(playerList, player.Name)
end)

Players.PlayerRemoving:Connect(function(player)
    for i, name in ipairs(playerList) do
        if name == player.Name then
            table.remove(playerList, i)
            break
        end
    end
end)

updatePlayerList()

-- 最も近いプレイヤーを取得（nil チェック強化）
local function getNearestPlayer()
    if not playerCharacter or not playerCharacter:FindFirstChild("HumanoidRootPart") then
        return nil
    end
    
    local nearestPlayer = nil
    local nearestDistance = math.huge
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= localPlayer and player.Character then
            local hrp = player.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                local distance = (playerCharacter.HumanoidRootPart.Position - hrp.Position).Magnitude
                if distance < nearestDistance then
                    nearestDistance = distance
                    nearestPlayer = player
                end
            end
        end
    end
    
    return nearestPlayer
end
-- toysFolder の取得
local toysFolder = workspace:WaitForChild(localPlayer.Name.."SpawnedInToys", 10)
if not toysFolder then
    warn("Failed to find toys folder")
end

-- ownedToys の初期化
local function initializeOwnedToys()
    local success, err = safePcall(function()
        local menuGui = localPlayer:WaitForChild("PlayerGui"):WaitForChild("MenuGui", 10)
        if not menuGui then return end
        
        local menu = menuGui:WaitForChild("Menu", 5)
        if not menu then return end
        
        local tabContents = menu:WaitForChild("TabContents", 5)
        if not tabContents then return end
        
        local toysTab = tabContents:WaitForChild("Toys", 5)
        if not toysTab then return end
        
        local toysContents = toysTab:WaitForChild("Contents", 5)
        if not toysContents then return end
        
        for _, v in pairs(toysContents:GetChildren()) do
            if v.Name ~= "UIGridLayout" then
                ownedToys[v.Name] = true
            end
        end
    end, "Initialize owned toys")
    
    if not success then
        warn("Failed to initialize owned toys")
    end
end

initializeOwnedToys()

-- descendant parts の取得（エラーハンドリング追加）
local function getDescendantParts(descendantName)
    local parts = {}
    local success, err = safePcall(function()
        local map = workspace:FindFirstChild("Map")
        if not map then return end
        
        for _, descendant in ipairs(map:GetDescendants()) do
            if descendant:IsA("Part") and descendant.Name == descendantName then
                table.insert(parts, descendant)
            end
        end
    end, "Get descendant parts")
    
    return parts
end

poisonHurtParts = getDescendantParts("PoisonHurtPart")
paintPlayerParts = getDescendantParts("PaintPlayerPart")

-- アイテムのスポーン（エラーハンドリング追加）
local function spawnItem(itemName, position, orientation)
    task.spawn(function()
        safePcall(function()
            local cframe = CFrame.new(position)
            local rotation = orientation or Vector3.new(0, 90, 0)
            ReplicatedStorage.MenuToys.SpawnToyRemoteFunction:InvokeServer(itemName, cframe, rotation)
        end, "Spawn item: " .. itemName)
    end)
end

local function spawnItemCf(itemName, cframe)
    task.spawn(function()
        safePcall(function()
            local rotation = Vector3.new(0, 0, 0)
            ReplicatedStorage.MenuToys.SpawnToyRemoteFunction:InvokeServer(itemName, cframe, rotation)
        end, "Spawn item CF: " .. itemName)
    end)
end

-- おもちゃの破壊
local function DestroyT(toy)
    if not toy then
        toy = toysFolder and toysFolder:FindFirstChildWhichIsA("Model")
    end
    if toy then
        safePcall(function()
            DestroyToy:FireServer(toy)
        end, "Destroy toy")
    end
end

-- 炎攻撃
local function arson(part)
    if not part then return end
    
    safePcall(function()
        if not toysFolder:FindFirstChild("Campfire") then
            spawnItem("Campfire", Vector3.new(-72.9304581, -5.96906614, -265.543732))
            task.wait(0.5)
        end
        
        local campfire = toysFolder:FindFirstChild("Campfire")
        if not campfire then return end
        
        local burnPart = campfire:FindFirstChild("FirePlayerPart")
        if not burnPart then return end
        
        burnPart.Size = Vector3.new(7, 7, 7)
        burnPart.Position = part.Position
        task.wait(0.3)
        burnPart.Position = Vector3.new(0, -50, 0)
    end, "Arson")
end

-- isDescendantOf helper
local function isDescendantOf(target, other)
    if not target or not other then return false end
    return Utilities.IsDescendantOf(target, other)
end

-- バージョン取得
local function getVersion()
    return version
end

-- ハイライト作成
local function createHighlight(parent)
    if not parent then return nil end
    
    local highlight = Instance.new("Highlight")
    highlight.DepthMode = Enum.HighlightDepthMode.Occluded
    highlight.FillTransparency = 1
    highlight.Name = "Highlight"
    highlight.OutlineColor = Color3.new(0, 0, 1)
    highlight.OutlineTransparency = 0.5
    highlight.Parent = parent
    return highlight
end

-- BodyMovers作成
local function createBodyMovers(part, position, rotation)
    if not part or not position or not rotation then return end
    
    safePcall(function()
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
    end, "Create body movers")
end

-- =============================================
-- キックグラブ機能（フラグベース）
-- =============================================
local function handleCharacterAdded(player)
    if not player then return end
    
    local conn = player.CharacterAdded:Connect(function(character)
        safePcall(function()
            local hrp = character:WaitForChild("HumanoidRootPart", 5)
            if not hrp then return end
            
            local fpp = hrp:WaitForChild("FirePlayerPart", 5)
            if not fpp then return end
            
            fpp.Size = Vector3.new(4.5, 5, 4.5)
            fpp.CollisionGroup = "1"
            fpp.CanQuery = true
        end, "Handle character added")
    end)
    
    table.insert(connections.kickGrab, conn)
end

local function kickGrabFunc()
    -- 初期設定
    safePcall(function()
        if localPlayer:GetMouse() then
            localPlayer:GetMouse().TargetFilter = playerCharacter
        end
        
        for _, player in pairs(Players:GetPlayers()) do
            if player.Character then
                local hrp = player.Character:FindFirstChild("HumanoidRootPart")
                if hrp then
                    local fpp = hrp:FindFirstChild("FirePlayerPart")
                    if fpp then
                        fpp.Size = Vector3.new(4.5, 5.5, 4.5)
                        fpp.CollisionGroup = "1"
                        fpp.CanQuery = true
                    end
                end
            end
            handleCharacterAdded(player)
        end
        
        local playerAddedConn = Players.PlayerAdded:Connect(handleCharacterAdded)
        table.insert(connections.kickGrab, playerAddedConn)
    end, "Kick grab init")
    
    -- メインループ
    while flags.kickGrabRunning do
        task.wait(1)
    end
end

local function startKickGrab()
    if flags.kickGrabRunning then return end
    
    flags.kickGrabRunning = true
    coroutines.kickGrab = coroutine.create(kickGrabFunc)
    coroutine.resume(coroutines.kickGrab)
end

local function stopKickGrab()
    flags.kickGrabRunning = false
    cleanupConnections(connections.kickGrab)
    cleanupCoroutine("kickGrab")
end

-- =============================================
-- グラブハンドラー（フラグベース）
-- =============================================
local currentGrabType = nil

local function grabHandlerFunc(grabType)
    currentGrabType = grabType
    local partsTable = grabType == "poison" and poisonHurtParts or paintPlayerParts
    
    while flags.grabHandlerRunning do
        safePcall(function()
            local grabParts = workspace:FindFirstChild("GrabParts")
            if not grabParts then
                task.wait(0.1)
                return
            end
            
            local grabPart = grabParts:FindFirstChild("GrabPart")
            if not grabPart then
                task.wait(0.1)
                return
            end
            
            local weldConstraint = grabPart:FindFirstChild("WeldConstraint")
            if not weldConstraint or not weldConstraint.Part1 then
                task.wait(0.1)
                return
            end
            
            local grabbedPart = weldConstraint.Part1
            if not grabbedPart or not grabbedPart.Parent then
                task.wait(0.1)
                return
            end
            
            local head = grabbedPart.Parent:FindFirstChild("Head")
            if not head then
                task.wait(0.1)
                return
            end
            
            -- グラブ中のループ
            while workspace:FindFirstChild("GrabParts") and flags.grabHandlerRunning do
                for _, part in pairs(partsTable) do
                    if part and part.Parent then
                        part.Size = Vector3.new(2, 2, 2)
                        part.Transparency = 1
                        part.Position = head.Position
                    end
                end
                task.wait()
            end
            
            -- クリーンアップ
            for _, part in pairs(partsTable) do
                if part and part.Parent then
                    part.Position = Vector3.new(0, -200, 0)
                end
            end
        end, "Grab handler")
        
        task.wait()
    end
    
    -- 最終クリーンアップ
    local partsTable = currentGrabType == "poison" and poisonHurtParts or paintPlayerParts
    for _, part in pairs(partsTable) do
        if part and part.Parent then
            part.Position = Vector3.new(0, -200, 0)
        end
    end
end

local function startGrabHandler(grabType)
    if flags.grabHandlerRunning then
        stopGrabHandler()
    end
    
    flags.grabHandlerRunning = true
    coroutines.grabHandler = coroutine.create(function()
        grabHandlerFunc(grabType)
    end)
    coroutine.resume(coroutines.grabHandler)
end

local function stopGrabHandler()
    flags.grabHandlerRunning = false
    cleanupCoroutine("grabHandler")
    
    -- 即座にクリーンアップ
    if currentGrabType then
        local partsTable = currentGrabType == "poison" and poisonHurtParts or paintPlayerParts
        for _, part in pairs(partsTable) do
            if part and part.Parent then
                part.Position = Vector3.new(0, -200, 0)
            end
        end
    end
end

-- =============================================
-- ファイアグラブ（フラグベース）
-- =============================================
local function fireGrabFunc()
    while flags.fireGrabRunning do
        safePcall(function()
            local grabParts = workspace:FindFirstChild("GrabParts")
            if not grabParts then return end
            
            local grabPart = grabParts:FindFirstChild("GrabPart")
            if not grabPart then return end
            
            local weldConstraint = grabPart:FindFirstChild("WeldConstraint")
            if not weldConstraint or not weldConstraint.Part1 then return end
            
            local grabbedPart = weldConstraint.Part1
            if not grabbedPart or not grabbedPart.Parent then return end
            
            local head = grabbedPart.Parent:FindFirstChild("Head")
            if head then
                arson(head)
            end
        end, "Fire grab")
        
        task.wait(0.1)
    end
end

local function startFireGrab()
    if flags.fireGrabRunning then return end
    
    flags.fireGrabRunning = true
    coroutines.fireGrab = coroutine.create(fireGrabFunc)
    coroutine.resume(coroutines.fireGrab)
end

local function stopFireGrab()
    flags.fireGrabRunning = false
    cleanupCoroutine("fireGrab")
end

-- =============================================
-- ノークリップグラブ（フラグベース）
-- =============================================
local function noclipGrabFunc()
    while flags.noclipGrabRunning do
        safePcall(function()
            local grabParts = workspace:FindFirstChild("GrabParts")
            if not grabParts then
                task.wait(0.1)
                return
            end
            
            local grabPart = grabParts:FindFirstChild("GrabPart")
            if not grabPart then
                task.wait(0.1)
                return
            end
            
            local weldConstraint = grabPart:FindFirstChild("WeldConstraint")
            if not weldConstraint or not weldConstraint.Part1 then
                task.wait(0.1)
                return
            end
            
            local grabbedPart = weldConstraint.Part1
            if not grabbedPart or not grabbedPart.Parent then
                task.wait(0.1)
                return
            end
            
            local character = grabbedPart.Parent
            local hrp = character:FindFirstChild("HumanoidRootPart")
            if not hrp then
                task.wait(0.1)
                return
            end
            
            -- ノークリップループ
            while workspace:FindFirstChild("GrabParts") and flags.noclipGrabRunning do
                for _, part in pairs(character:GetChildren()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                    end
                end
                task.wait()
            end
            
            -- 復元
            for _, part in pairs(character:GetChildren()) do
                if part:IsA("BasePart") then
                    part.CanCollide = true
                end
            end
        end, "Noclip grab")
        
        task.wait()
    end
end

local function startNoclipGrab()
    if flags.noclipGrabRunning then return end
    
    flags.noclipGrabRunning = true
    coroutines.noclipGrab = coroutine.create(noclipGrabFunc)
    coroutine.resume(coroutines.noclipGrab)
end

local function stopNoclipGrab()
    flags.noclipGrabRunning = false
    cleanupCoroutine("noclipGrab")
end
-- =============================================
-- ファイアオール（フラグベース）
-- =============================================
local function fireAllFunc()
    while flags.fireAllRunning do
        safePcall(function()
            -- 既存のキャンプファイアを破壊
            if toysFolder and toysFolder:FindFirstChild("Campfire") then
                DestroyT(toysFolder:FindFirstChild("Campfire"))
                task.wait(0.5)
            end
            
            if not playerCharacter or not playerCharacter:FindFirstChild("Head") then
                task.wait(0.5)
                return
            end
            
            -- 新しいキャンプファイアをスポーン
            spawnItemCf("Campfire", playerCharacter.Head.CFrame)
            task.wait(0.5)
            
            if not toysFolder then return end
            local campfire = toysFolder:WaitForChild("Campfire", 5)
            if not campfire then return end
            
            local firePlayerPart = nil
            for _, part in pairs(campfire:GetChildren()) do
                if part.Name == "FirePlayerPart" then
                    part.Size = Vector3.new(10, 10, 10)
                    firePlayerPart = part
                    break
                end
            end
            
            if not firePlayerPart or not playerCharacter:FindFirstChild("Torso") then
                return
            end
            
            local originalPosition = playerCharacter.Torso.Position
            SetNetworkOwner:FireServer(firePlayerPart, firePlayerPart.CFrame)
            playerCharacter:MoveTo(firePlayerPart.Position)
            task.wait(0.3)
            playerCharacter:MoveTo(originalPosition)
            
            -- BodyPosition作成
            local bodyPosition = Instance.new("BodyPosition")
            bodyPosition.P = 20000
            bodyPosition.Position = playerCharacter.Head.Position + Vector3.new(0, 600, 0)
            bodyPosition.Parent = campfire.Main
            
            -- メインループ
            while flags.fireAllRunning and campfire.Parent do
                for _, player in pairs(Players:GetPlayers()) do
                    if player ~= localPlayer and player.Character then
                        safePcall(function()
                            local hrp = player.Character:FindFirstChild("HumanoidRootPart")
                            local head = player.Character:FindFirstChild("Head")
                            
                            if hrp and playerCharacter and playerCharacter:FindFirstChild("Head") then
                                bodyPosition.Position = playerCharacter.Head.Position + Vector3.new(0, 600, 0)
                                firePlayerPart.Position = hrp.Position or head.Position
                            end
                        end, "Fire all player loop")
                    end
                end
                task.wait()
            end
            
            -- クリーンアップ
            if bodyPosition and bodyPosition.Parent then
                bodyPosition:Destroy()
            end
            DestroyT(campfire)
        end, "Fire all")
        
        task.wait()
    end
    
    -- 最終クリーンアップ
    if toysFolder and toysFolder:FindFirstChild("Campfire") then
        DestroyT(toysFolder:FindFirstChild("Campfire"))
    end
end

local function startFireAll()
    if flags.fireAllRunning then return end
    
    flags.fireAllRunning = true
    coroutines.fireAll = coroutine.create(fireAllFunc)
    coroutine.resume(coroutines.fireAll)
end

local function stopFireAll()
    flags.fireAllRunning = false
    cleanupCoroutine("fireAll")
    
    if toysFolder and toysFolder:FindFirstChild("Campfire") then
        DestroyT(toysFolder:FindFirstChild("Campfire"))
    end
end

-- =============================================
-- アンカーグラブ（フラグベース）
-- =============================================
local function onPartOwnerAdded(descendant, primaryPart)
    if not descendant or not primaryPart then return end
    
    safePcall(function()
        if descendant.Name == "PartOwner" and descendant.Value ~= localPlayer.Name then
            local highlight = primaryPart:FindFirstChild("Highlight")
            if not highlight and primaryPart.Parent and primaryPart.Parent:IsA("Model") then
                highlight = U.GetDescendant(primaryPart.Parent, "Highlight", "Highlight")
            end
            
            if highlight then
                if descendant.Value ~= localPlayer.Name then
                    highlight.OutlineColor = Color3.new(1, 0, 0)
                else
                    highlight.OutlineColor = Color3.new(0, 0, 1)
                end
            end
        end
    end, "Part owner added")
end

local function anchorGrabFunc()
    while flags.anchorGrabRunning do
        safePcall(function()
            local grabParts = workspace:FindFirstChild("GrabParts")
            if not grabParts then
                task.wait(0.1)
                return
            end
            
            local grabPart = grabParts:FindFirstChild("GrabPart")
            if not grabPart then
                task.wait(0.1)
                return
            end
            
            local weldConstraint = grabPart:FindFirstChild("WeldConstraint")
            if not weldConstraint or not weldConstraint.Part1 then
                task.wait(0.1)
                return
            end
            
            local primaryPart = weldConstraint.Part1
            if primaryPart.Name == "SoundPart" then
                -- SoundPartの場合は調整
            elseif primaryPart.Parent then
                local soundPart = primaryPart.Parent:FindFirstChild("SoundPart")
                local primPart = primaryPart.Parent:FindFirstChild("PrimaryPart")
                if soundPart then
                    primaryPart = soundPart
                elseif primPart then
                    primaryPart = primPart
                end
            end
            
            if not primaryPart or primaryPart.Anchored then
                task.wait(0.1)
                return
            end
            
            if isDescendantOf(primaryPart, workspace.Map) then
                task.wait(0.1)
                return
            end
            
            for _, player in pairs(Players:GetPlayers()) do
                if player.Character and isDescendantOf(primaryPart, player.Character) then
                    task.wait(0.1)
                    return
                end
            end
            
            -- 既にアンカーされているかチェック
            local alreadyAnchored = false
            for _, v in pairs(primaryPart:GetDescendants()) do
                if table.find(anchoredParts, v) then
                    alreadyAnchored = true
                    break
                end
            end
            
            if not alreadyAnchored and not table.find(anchoredParts, primaryPart) then
                local target
                if U.FindFirstAncestorOfType(primaryPart, "Model") and 
                   U.FindFirstAncestorOfType(primaryPart, "Model") ~= workspace then
                    target = U.FindFirstAncestorOfType(primaryPart, "Model")
                else
                    target = primaryPart
                end
                
                local highlight = createHighlight(target)
                table.insert(anchoredParts, primaryPart)
                
                local connection = target.DescendantAdded:Connect(function(descendant)
                    onPartOwnerAdded(descendant, primaryPart)
                end)
                table.insert(connections.anchored, connection)
            end
            
            -- BodyMoversを削除
            local targetInstance = U.FindFirstAncestorOfType(primaryPart, "Model")
            if targetInstance and targetInstance ~= workspace then
                -- Model の場合
            else
                targetInstance = primaryPart
            end
            
            for _, child in ipairs(targetInstance:GetDescendants()) do
                if child:IsA("BodyPosition") or child:IsA("BodyGyro") then
                    child:Destroy()
                end
            end
            
            -- グラブが解除されるまで待つ
            while workspace:FindFirstChild("GrabParts") and flags.anchorGrabRunning do
                task.wait()
            end
            
            -- BodyMovers作成
            createBodyMovers(primaryPart, primaryPart.Position, primaryPart.CFrame)
        end, "Anchor grab")
        
        task.wait()
    end
end

local function startAnchorGrab()
    if flags.anchorGrabRunning then return end
    
    flags.anchorGrabRunning = true
    coroutines.anchorGrab = coroutine.create(anchorGrabFunc)
    coroutine.resume(coroutines.anchorGrab)
end

local function stopAnchorGrab()
    flags.anchorGrabRunning = false
    cleanupCoroutine("anchorGrab")
end

-- =============================================
-- アンカーキックグラブ（フラグベース）
-- =============================================
local function anchorKickGrabFunc()
    while flags.anchorKickGrabRunning do
        safePcall(function()
            local grabParts = workspace:FindFirstChild("GrabParts")
            if not grabParts then
                task.wait(0.1)
                return
            end
            
            local grabPart = grabParts:FindFirstChild("GrabPart")
            if not grabPart then
                task.wait(0.1)
                return
            end
            
            local weldConstraint = grabPart:FindFirstChild("WeldConstraint")
            if not weldConstraint or not weldConstraint.Part1 then
                task.wait(0.1)
                return
            end
            
            local primaryPart = weldConstraint.Part1
            if not primaryPart then
                task.wait(0.1)
                return
            end
            
            if isDescendantOf(primaryPart, workspace.Map) then
                task.wait(0.1)
                return
            end
            
            if primaryPart.Name ~= "FirePlayerPart" then
                task.wait(0.1)
                return
            end
            
            -- BodyMoversを削除
            for _, child in ipairs(primaryPart:GetChildren()) do
                if child:IsA("BodyPosition") or child:IsA("BodyGyro") then
                    child:Destroy()
                end
            end
            
            -- グラブが解除されるまで待つ
            while workspace:FindFirstChild("GrabParts") and flags.anchorKickGrabRunning do
                task.wait()
            end
            
            -- BodyMovers作成
            createBodyMovers(primaryPart, primaryPart.Position, primaryPart.CFrame)
        end, "Anchor kick grab")
        
        task.wait()
    end
end

local function startAnchorKickGrab()
    if flags.anchorKickGrabRunning then return end
    
    flags.anchorKickGrabRunning = true
    coroutines.anchorKickGrab = coroutine.create(anchorKickGrabFunc)
    coroutine.resume(coroutines.anchorKickGrab)
end

local function stopAnchorKickGrab()
    flags.anchorKickGrabRunning = false
    cleanupCoroutine("anchorKickGrab")
end

-- =============================================
-- オーラシステム（フラグベース）
-- =============================================

-- エアサスペンドオーラ
local function auraFunc()
    while flags.auraRunning do
        safePcall(function()
            if not playerCharacter or not playerCharacter:FindFirstChild("HumanoidRootPart") then
                task.wait(0.02)
                return
            end
            
            local humanoidRootPart = playerCharacter.HumanoidRootPart
            
            for _, player in pairs(Players:GetPlayers()) do
                if player ~= localPlayer and player.Character then
                    local playerTorso = player.Character:FindFirstChild("Torso")
                    local playerHrp = player.Character:FindFirstChild("HumanoidRootPart")
                    
                    if playerTorso and playerHrp then
                        local fpp = playerHrp:FindFirstChild("FirePlayerPart")
                        if fpp then
                            local distance = (playerTorso.Position - humanoidRootPart.Position).Magnitude
                            if distance <= auraRadius then
                                task.spawn(function()
                                    safePcall(function()
                                        SetNetworkOwner:FireServer(playerTorso, fpp.CFrame)
                                        task.wait(0.1)
                                        
                                        local velocity = playerTorso:FindFirstChild("l")
                                        if not velocity then
                                            velocity = Instance.new("BodyVelocity")
                                            velocity.Name = "l"
                                            velocity.Parent = playerTorso
                                        end
                                        
                                        velocity.Velocity = Vector3.new(0, 50, 0)
                                        velocity.MaxForce = Vector3.new(0, math.huge, 0)
                                        Debris:AddItem(velocity, 100)
                                    end, "Aura effect")
                                end)
                            end
                        end
                    end
                end
            end
        end, "Aura")
        
        task.wait(0.02)
    end
end

local function startAura()
    if flags.auraRunning then return end
    
    flags.auraRunning = true
    coroutines.aura = coroutine.create(auraFunc)
    coroutine.resume(coroutines.aura)
end

local function stopAura()
    flags.auraRunning = false
    cleanupCoroutine("aura")
end

-- 奈落オーラ
local function gravityFunc()
    while flags.gravityRunning do
        safePcall(function()
            if not playerCharacter or not playerCharacter:FindFirstChild("HumanoidRootPart") then
                task.wait(0.02)
                return
            end
            
            local humanoidRootPart = playerCharacter.HumanoidRootPart
            
            for _, player in pairs(Players:GetPlayers()) do
                if player ~= localPlayer and player.Character then
                    local playerTorso = player.Character:FindFirstChild("Torso")
                    local playerHrp = player.Character:FindFirstChild("HumanoidRootPart")
                    
                    if playerTorso and playerHrp then
                        local fpp = playerHrp:FindFirstChild("FirePlayerPart")
                        if fpp then
                            local distance = (playerTorso.Position - humanoidRootPart.Position).Magnitude
                            if distance <= auraRadius then
                                task.spawn(function()
                                    safePcall(function()
                                        SetNetworkOwner:FireServer(playerTorso, fpp.CFrame)
                                        task.wait(0.1)
                                        
                                        local force = playerTorso:FindFirstChild("GravityForce")
                                        if not force then
                                            force = Instance.new("BodyForce")
                                            force.Name = "GravityForce"
                                            force.Parent = playerTorso
                                        end
                                        
                                        for _, part in ipairs(player.Character:GetDescendants()) do
                                            if part:IsA("BasePart") then
                                                part.CanCollide = false
                                            end
                                        end
                                        
                                        force.Force = Vector3.new(0, 1200, 0)
                                    end, "Gravity effect")
                                end)
                            end
                        end
                    end
                end
            end
        end, "Gravity")
        
        task.wait(0.02)
    end
end

local function startGravity()
    if flags.gravityRunning then return end
    
    flags.gravityRunning = true
    coroutines.gravity = coroutine.create(gravityFunc)
    coroutine.resume(coroutines.gravity)
end

local function stopGravity()
    flags.gravityRunning = false
    cleanupCoroutine("gravity")
end

-- キックオーラ
local function kickFunc()
    while flags.kickRunning do
        safePcall(function()
            if not playerCharacter or not playerCharacter:FindFirstChild("HumanoidRootPart") then
                task.wait(0.02)
                return
            end
            
            local humanoidRootPart = playerCharacter.HumanoidRootPart
            
            for _, player in pairs(Players:GetPlayers()) do
                if player ~= localPlayer and player.Character then
                    local playerHead = player.Character:FindFirstChild("Head")
                    local playerHrp = player.Character:FindFirstChild("HumanoidRootPart")
                    
                    if playerHead and playerHrp then
                        local fpp = playerHrp:FindFirstChild("FirePlayerPart")
                        if fpp then
                            local distance = (playerHead.Position - humanoidRootPart.Position).Magnitude
                            if distance <= auraRadius then
                                SetNetworkOwner:FireServer(fpp, fpp.CFrame)
                                
                                if auraToggle == 1 then -- サイレント（プラットフォーム）
                                    if not platforms[player] then
                                        local platform = player.Character:FindFirstChild("FloatingPlatform")
                                        if not platform then
                                            platform = Instance.new("Part")
                                            platform.Name = "FloatingPlatform"
                                            platform.Size = Vector3.new(5, 2, 5)
                                            platform.Anchored = true
                                            platform.Transparency = 1
                                            platform.CanCollide = true
                                            platform.Parent = player.Character
                                        end
                                        platforms[player] = platform
                                    end
                                elseif auraToggle == 2 then -- 空（BodyVelocity）
                                    if not fpp:FindFirstChild("BodyVelocity") then
                                        local bodyVelocity = Instance.new("BodyVelocity")
                                        bodyVelocity.Name = "BodyVelocity"
                                        bodyVelocity.Velocity = Vector3.new(0, 20, 0)
                                        bodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                                        bodyVelocity.Parent = fpp
                                    end
                                end
                            end
                        end
                    end
                end
            end
            
            -- プラットフォームの更新
            for player, platform in pairs(platforms) do
                if platform and platform.Parent and player.Character then
                    local humanoid = player.Character:FindFirstChild("Humanoid")
                    local hrp = player.Character:FindFirstChild("HumanoidRootPart")
                    
                    if humanoid and hrp and humanoid.Health > 1 then
                        platform.Position = hrp.Position - Vector3.new(0, 3.994, 0)
                    else
                        platform:Destroy()
                        platforms[player] = nil
                    end
                end
            end
        end, "Kick aura")
        
        task.wait(0.02)
    end
    
    -- クリーンアップ
    for _, platform in pairs(platforms) do
        if platform and platform.Parent then
            platform:Destroy()
        end
    end
    platforms = {}
end

local function startKick()
    if flags.kickRunning then return end
    
    flags.kickRunning = true
    coroutines.kick = coroutine.create(kickFunc)
    coroutine.resume(coroutines.kick)
end

local function stopKick()
    flags.kickRunning = false
    cleanupCoroutine("kick")
    
    for _, platform in pairs(platforms) do
        if platform and platform.Parent then
            platform:Destroy()
        end
    end
    platforms = {}
end

-- 放射線オーラ
local function poisonAuraFunc()
    while flags.poisonAuraRunning do
        safePcall(function()
            if not playerCharacter or not playerCharacter:FindFirstChild("HumanoidRootPart") then
                task.wait(0.02)
                return
            end
            
            local humanoidRootPart = playerCharacter.HumanoidRootPart
            
            for _, player in pairs(Players:GetPlayers()) do
                if player ~= localPlayer and player.Character then
                    local playerTorso = player.Character:FindFirstChild("Torso")
                    
                    if playerTorso then
                        local distance = (playerTorso.Position - humanoidRootPart.Position).Magnitude
                        if distance <= auraRadius then
                            local head = player.Character:FindFirstChild("Head")
                            if head then
                                task.spawn(function()
                                    local playerHrp = player.Character:FindFirstChild("HumanoidRootPart")
                                    while flags.poisonAuraRunning and 
                                          playerTorso and playerTorso.Parent and 
                                          humanoidRootPart and humanoidRootPart.Parent and
                                          (playerTorso.Position - humanoidRootPart.Position).Magnitude <= auraRadius do
                                        
                                        safePcall(function()
                                            if playerHrp then
                                                SetNetworkOwner:FireServer(playerTorso, playerHrp.CFrame)
                                            end
                                            
                                            for _, part in pairs(poisonHurtParts) do
                                                if part and part.Parent then
                                                    part.Size = Vector3.new(1, 3, 1)
                                                    part.Transparency = 1
                                                    part.Position = head.Position
                                                end
                                            end
                                        end, "Poison aura effect")
                                        
                                        task.wait()
                                        
                                        for _, part in pairs(poisonHurtParts) do
                                            if part and part.Parent then
                                                part.Position = Vector3.new(0, -200, 0)
                                            end
                                        end
                                    end
                                    
                                    -- 範囲外クリーンアップ
                                    for _, part in pairs(poisonHurtParts) do
                                        if part and part.Parent then
                                            part.Position = Vector3.new(0, -200, 0)
                                        end
                                    end
                                end)
                            end
                        end
                    end
                end
            end
        end, "Poison aura")
        
        task.wait(0.02)
    end
    
    -- 最終クリーンアップ
    for _, part in pairs(poisonHurtParts) do
        if part and part.Parent then
            part.Position = Vector3.new(0, -200, 0)
        end
    end
end

local function startPoisonAura()
    if flags.poisonAuraRunning then return end
    
    flags.poisonAuraRunning = true
    coroutines.poisonAura = coroutine.create(poisonAuraFunc)
    coroutine.resume(coroutines.poisonAura)
end

local function stopPoisonAura()
    flags.poisonAuraRunning = false
    cleanupCoroutine("poisonAura")
    
    for _, part in pairs(poisonHurtParts) do
        if part and part.Parent then
            part.Position = Vector3.new(0, -200, 0)
        end
    end
end
-- =============================================
-- ラグドールオール（フラグベース）
-- =============================================
local function ragdollAllFunc()
    while flags.ragdollAllRunning do
        safePcall(function()
            if not toysFolder then
                task.wait(0.5)
                return
            end
            
            if not toysFolder:FindFirstChild("FoodBanana") then
                spawnItem("FoodBanana", Vector3.new(-72.9304581, -5.96906614, -265.543732))
                task.wait(0.5)
            end
            
            local banana = toysFolder:WaitForChild("FoodBanana", 5)
            if not banana then return end
            
            local bananaPeel = nil
            for _, part in pairs(banana:GetChildren()) do
                if part.Name == "BananaPeel" and part:FindFirstChild("TouchInterest") then
                    part.Size = Vector3.new(10, 10, 10)
                    part.Transparency = 1
                    bananaPeel = part
                    break
                end
            end
            
            if not bananaPeel or not banana:FindFirstChild("Main") then
                task.wait(0.1)
                return
            end
            
            local bodyPosition = banana.Main:FindFirstChild("BodyPosition")
            if not bodyPosition then
                bodyPosition = Instance.new("BodyPosition")
                bodyPosition.P = 20000
                bodyPosition.Parent = banana.Main
            end
            
            while flags.ragdollAllRunning and banana.Parent do
                for _, player in pairs(Players:GetPlayers()) do
                    if player ~= localPlayer and player.Character then
                        safePcall(function()
                            local hrp = player.Character:FindFirstChild("HumanoidRootPart")
                            local head = player.Character:FindFirstChild("Head")
                            
                            if hrp and playerCharacter and playerCharacter:FindFirstChild("Head") then
                                bananaPeel.Position = hrp.Position or head.Position
                                bodyPosition.Position = playerCharacter.Head.Position + Vector3.new(0, 600, 0)
                            end
                        end, "Ragdoll all player")
                    end
                end
                task.wait()
            end
            
            DestroyT(banana)
        end, "Ragdoll all")
        
        task.wait()
    end
    
    if toysFolder and toysFolder:FindFirstChild("FoodBanana") then
        DestroyT(toysFolder:FindFirstChild("FoodBanana"))
    end
end

local function startRagdollAll()
    if flags.ragdollAllRunning then return end
    
    flags.ragdollAllRunning = true
    coroutines.ragdollAll = coroutine.create(ragdollAllFunc)
    coroutine.resume(coroutines.ragdollAll)
end

local function stopRagdollAll()
    flags.ragdollAllRunning = false
    cleanupCoroutine("ragdollAll")
    
    if toysFolder and toysFolder:FindFirstChild("FoodBanana") then
        DestroyT(toysFolder:FindFirstChild("FoodBanana"))
    end
end

-- =============================================
-- ループTP機能（フラグベース）
-- =============================================
local function loopTPFunction(targetBlobman)
    if not targetBlobman or not targetBlobman:IsA("Model") then
        warn("Invalid blobman target")
        return
    end
    
    local blobmanRoot = targetBlobman:FindFirstChild("Main")
    local seat = targetBlobman:FindFirstChild("VehicleSeat")
    
    if not blobmanRoot or not seat then
        warn("Blobman parts not found")
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
        warn("No players to kick")
        return
    end
    
    while flags.loopTpRunning do
        if #nonLocalPlayers == 0 then
            flags.loopTpRunning = false
            break
        end
        
        currentLoopTpPlayerIndex = currentLoopTpPlayerIndex % #nonLocalPlayers + 1
        local targetPlayer = nonLocalPlayers[currentLoopTpPlayerIndex]
        
        if not targetPlayer or not targetPlayer.Character or not targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
            table.remove(nonLocalPlayers, currentLoopTpPlayerIndex)
            if currentLoopTpPlayerIndex > #nonLocalPlayers then
                currentLoopTpPlayerIndex = 1
            end
            task.wait(0.01)
        else
            local targetHRP = targetPlayer.Character.HumanoidRootPart
            
            safePcall(function()
                SetNetworkOwner:FireServer(blobmanRoot, targetHRP.CFrame * CFrame.new(0, -3, 0))
                task.wait(_G.BlobmanDelay)
                SetNetworkOwner:FireServer(blobmanRoot, blobmanRoot.CFrame)
            end, "Loop TP")
            
            task.wait(_G.BlobmanDelay)
        end
    end
end

local function startLoopTP(targetBlobman)
    if flags.loopTpRunning then return end
    
    flags.loopTpRunning = true
    currentLoopTpPlayerIndex = 0
    
    coroutines.loopTp = coroutine.create(function()
        loopTPFunction(targetBlobman)
    end)
    coroutine.resume(coroutines.loopTp)
end

local function stopLoopTP()
    flags.loopTpRunning = false
    cleanupCoroutine("loopTp")
    blobman = nil
end

-- =============================================
-- その他のヘルパー機能
-- =============================================

-- しゃがみ速度
local function crouchSpeedFunc()
    while flags.crouchSpeedRunning do
        safePcall(function()
            if playerCharacter and playerCharacter:FindFirstChild("Humanoid") then
                local humanoid = playerCharacter.Humanoid
                if humanoid.WalkSpeed == 5 then
                    humanoid.WalkSpeed = crouchWalkSpeed
                end
            end
        end, "Crouch speed")
        
        task.wait()
    end
end

local function startCrouchSpeed()
    if flags.crouchSpeedRunning then return end
    
    flags.crouchSpeedRunning = true
    coroutines.crouchSpeed = coroutine.create(crouchSpeedFunc)
    coroutine.resume(coroutines.crouchSpeed)
end

local function stopCrouchSpeed()
    flags.crouchSpeedRunning = false
    cleanupCoroutine("crouchSpeed")
    
    if playerCharacter and playerCharacter:FindFirstChild("Humanoid") then
        playerCharacter.Humanoid.WalkSpeed = 16
    end
end

-- しゃがみジャンプ
local function crouchJumpFunc()
    while flags.crouchJumpRunning do
        safePcall(function()
            if playerCharacter and playerCharacter:FindFirstChild("Humanoid") then
                local humanoid = playerCharacter.Humanoid
                if humanoid.JumpPower == 12 then
                    humanoid.JumpPower = crouchJumpPower
                end
            end
        end, "Crouch jump")
        
        task.wait()
    end
end

local function startCrouchJump()
    if flags.crouchJumpRunning then return end
    
    flags.crouchJumpRunning = true
    coroutines.crouchJump = coroutine.create(crouchJumpFunc)
    coroutine.resume(coroutines.crouchJump)
end

local function stopCrouchJump()
    flags.crouchJumpRunning = false
    cleanupCoroutine("crouchJump")
    
    if playerCharacter and playerCharacter:FindFirstChild("Humanoid") then
        playerCharacter.Humanoid.JumpPower = 24
    end
end

-- 爆弾リロード
local function reloadMissile(enabled)
    if enabled then
        if not ownedToys[_G.ToyToLoad] then
            warn("You do not own the " .. _G.ToyToLoad .. " toy")
            return
        end
        
        if flags.reloadBombRunning then return end
        flags.reloadBombRunning = true
        
        local bombReloadConn = toysFolder.ChildAdded:Connect(function(child)
            safePcall(function()
                if child.Name ~= _G.ToyToLoad then return end
                
                local toyNumber = child:WaitForChild("ThisToysNumber", 1)
                if not toyNumber then return end
                
                if toyNumber.Value == (toysFolder.ToyNumber.Value - 1) then
                    local bodyPart = child:FindFirstChild("Body") or child.PrimaryPart
                    if not bodyPart then return end
                    
                    SetNetworkOwner:FireServer(bodyPart, bodyPart.CFrame)
                    local waiting = bodyPart:WaitForChild("PartOwner", 0.5)
                    
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
                    else
                        DestroyT(child)
                    end
                end
            end, "Bomb reload")
        end)
        
        table.insert(connections.general, bombReloadConn)
        
        coroutines.reloadBomb = coroutine.create(function()
            while flags.reloadBombRunning do
                if localPlayer.CanSpawnToy and localPlayer.CanSpawnToy.Value and 
                   #bombList < _G.MaxMissiles and 
                   playerCharacter and playerCharacter:FindFirstChild("Head") then
                    spawnItemCf(_G.ToyToLoad, playerCharacter.Head.CFrame)
                end
                RunService.Heartbeat:Wait()
            end
        end)
        
        coroutine.resume(coroutines.reloadBomb)
    else
        flags.reloadBombRunning = false
        cleanupCoroutine("reloadBomb")
    end
end

-- アンチ爆発
local function setupAntiExplosion(character)
    if not character then return end
    
    safePcall(function()
        local humanoid = character:WaitForChild("Humanoid", 5)
        if not humanoid then return end
        
        local ragdolled = humanoid:FindFirstChild("Ragdolled")
        if not ragdolled then return end
        
        local antiExplosionConn = ragdolled:GetPropertyChangedSignal("Value"):Connect(function()
            safePcall(function()
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
            end, "Anti explosion effect")
        end)
        
        table.insert(connections.general, antiExplosionConn)
    end, "Setup anti explosion")
end

-- アンカーされたパーツのクリーンアップ
local function cleanupAnchoredParts()
    for _, part in ipairs(anchoredParts) do
        if part and part.Parent then
            safePcall(function()
                if part:FindFirstChild("BodyPosition") then
                    part.BodyPosition:Destroy()
                end
                if part:FindFirstChild("BodyGyro") then
                    part.BodyGyro:Destroy()
                end
                
                local highlight = part:FindFirstChild("Highlight")
                if not highlight and part.Parent and part.Parent:IsA("Model") then
                    highlight = part.Parent:FindFirstChild("Highlight")
                end
                if highlight then
                    highlight:Destroy()
                end
            end, "Cleanup anchored part")
        end
    end
    
    cleanupConnections(connections.anchored)
    anchoredParts = {}
end

-- コンパイルされたグループのクリーンアップ
local function cleanupCompiledGroups()
    for _, groupData in ipairs(compiledGroups) do
        for _, data in ipairs(groupData.group) do
            if data.part and data.part.Parent then
                safePcall(function()
                    if data.part:FindFirstChild("BodyPosition") then
                        data.part.BodyPosition:Destroy()
                    end
                    if data.part:FindFirstChild("BodyGyro") then
                        data.part.BodyGyro:Destroy()
                    end
                end, "Cleanup compiled group part")
            end
        end
        
        if groupData.primaryPart and groupData.primaryPart.Parent then
            safePcall(function()
                local highlight = groupData.primaryPart:FindFirstChild("Highlight")
                if not highlight and groupData.primaryPart.Parent:IsA("Model") then
                    highlight = groupData.primaryPart.Parent:FindFirstChild("Highlight")
                end
                if highlight then
                    highlight:Destroy()
                end
            end, "Cleanup compiled group highlight")
        end
    end
    
    cleanupConnections(connections.compile)
    cleanupConnections(connections.renderStepped)
    compiledGroups = {}
end

-- =============================================
-- UI初期化（Orion Library）
-- =============================================
local OrionLib = loadstring(game:HttpGet(("https://raw.githubusercontent.com/yua20170313a-pixel/Orion/e19e8236bde46c459fb0d617e4640aeb75878703/source")))()

if not OrionLib then
    warn("Failed to load Orion Library")
    return
end

local Window = OrionLib:MakeWindow({
    Name = "野獣のおちんちんハブ v" .. version,
    HidePremium = false,
    SaveConfig = true,
    ConfigFolder = "YajuuHub"
})

-- タブの作成
local DefenseTab = Window:MakeTab({Name = "Defense", Icon = "rbxassetid://6034179373", PremiumOnly = false})
local BlobmanTab = Window:MakeTab({Name = "Blobman", Icon = "rbxassetid://6034179373", PremiumOnly = false})
local CharacterTab = Window:MakeTab({Name = "Character", Icon = "rbxassetid://6034179373", PremiumOnly = false})
local FunTab = Window:MakeTab({Name = "Fun", Icon = "rbxassetid://6034179373", PremiumOnly = false})
local ScriptTab = Window:MakeTab({Name = "Scripts", Icon = "rbxassetid://6034179373", PremiumOnly = false})
local AuraTab = Window:MakeTab({Name = "Aura", Icon = "rbxassetid://6034179373", PremiumOnly = false})
local KeybindsTab = Window:MakeTab({Name = "Keybinds", Icon = "rbxassetid://6034179373", PremiumOnly = false})
local ExplosionTab = Window:MakeTab({Name = "Explosion", Icon = "rbxassetid://6034179373", PremiumOnly = false})
local DevTab = Window:MakeTab({Name = "Dev", Icon = "rbxassetid://6034179373", PremiumOnly = false})

-- =============================================
-- Defense Tab
-- =============================================
DefenseTab:AddLabel("グラブディフェンス")

DefenseTab:AddToggle({
    Name = "アンチグラブ",
    Default = false,
    Save = true,
    Flag = "AutoStruggle",
    Callback = function(enabled)
        if enabled then
            local autoStruggleConn = RunService.Heartbeat:Connect(function()
                safePcall(function()
                    if not playerCharacter or not playerCharacter:FindFirstChild("Head") then return end
                    
                    local head = playerCharacter.Head
                    local partOwner = head:FindFirstChild("PartOwner")
                    
                    if partOwner then
                        Struggle:FireServer()
                        ReplicatedStorage.GameCorrectionEvents.StopAllVelocity:FireServer()
                        
                        for _, part in pairs(playerCharacter:GetChildren()) do
                            if part:IsA("BasePart") then
                                part.Anchored = true
                            end
                        end
                        
                        task.spawn(function()
                            repeat task.wait() until not localPlayer.IsHeld.Value
                            
                            for _, part in pairs(playerCharacter:GetChildren()) do
                                if part:IsA("BasePart") then
                                    part.Anchored = false
                                end
                            end
                        end)
                    end
                end, "Auto struggle")
            end)
            
            table.insert(connections.general, autoStruggleConn)
        else
            -- 接続を削除
            cleanupConnections(connections.general)
        end
    end
})

DefenseTab:AddToggle({
    Name = "アンチキックグラブ",
    Default = false,
    Save = true,
    Flag = "AntiKickGrab",
    Callback = function(enabled)
        if enabled then
            local antiKickConn = RunService.Heartbeat:Connect(function()
                safePcall(function()
                    if not playerCharacter then return end
                    
                    local hrp = playerCharacter:FindFirstChild("HumanoidRootPart")
                    if not hrp then return end
                    
                    local fpp = hrp:FindFirstChild("FirePlayerPart")
                    if not fpp then return end
                    
                    local partOwner = fpp:FindFirstChild("PartOwner")
                    if not partOwner then return end
                    
                    if partOwner.Value ~= localPlayer.Name then
                        local args = {[1] = hrp, [2] = 0}
                        ReplicatedStorage.CharacterEvents.RagdollRemote:FireServer(unpack(args))
                        task.wait(0.1)
                        Struggle:FireServer()
                    end
                end, "Anti kick grab")
            end)
            
            table.insert(connections.general, antiKickConn)
        else
            cleanupConnections(connections.general)
        end
    end
})

DefenseTab:AddToggle({
    Name = "アンチ爆弾",
    Default = false,
    Save = true,
    Flag = "AntiExplosion",
    Callback = function(enabled)
        if enabled then
            if playerCharacter then
                setupAntiExplosion(playerCharacter)
            end
            
            local charAddedConn = localPlayer.CharacterAdded:Connect(function(character)
                playerCharacter = character
                setupAntiExplosion(character)
            end)
            
            table.insert(connections.general, charAddedConn)
        else
            cleanupConnections(connections.general)
        end
    end
})

DefenseTab:AddLabel("自己防御")

DefenseTab:AddToggle({
    Name = "エアサスペンション",
    Default = false,
    Save = true,
    Flag = "SelfDefenseAirSuspend",
    Callback = function(enabled)
        if enabled then
            coroutines.autoDefend = coroutine.create(function()
                while coroutines.autoDefend do
                    safePcall(function()
                        if not playerCharacter or not playerCharacter:FindFirstChild("Head") then
                            task.wait(0.02)
                            return
                        end
                        
                        local head = playerCharacter.Head
                        local partOwner = head:FindFirstChild("PartOwner")
                        
                        if partOwner then
                            local attacker = Players:FindFirstChild(partOwner.Value)
                            if attacker and attacker.Character then
                                Struggle:FireServer()
                                
                                local attackerTorso = attacker.Character:FindFirstChild("Torso")
                                if attackerTorso then
                                    local attackerHRP = attacker.Character:FindFirstChild("HumanoidRootPart")
                                    if attackerHRP and attackerHRP:FindFirstChild("FirePlayerPart") then
                                        SetNetworkOwner:FireServer(attackerTorso, attackerHRP.FirePlayerPart.CFrame)
                                        task.wait(0.1)
                                        
                                        local velocity = attackerTorso:FindFirstChild("l")
                                        if not velocity then
                                            velocity = Instance.new("BodyVelocity")
                                            velocity.Name = "l"
                                            velocity.Parent = attackerTorso
                                        end
                                        
                                        velocity.Velocity = Vector3.new(0, 50, 0)
                                        velocity.MaxForce = Vector3.new(0, math.huge, 0)
                                        Debris:AddItem(velocity, 100)
                                    end
                                end
                            end
                        end
                    end, "Auto defend")
                    
                    task.wait(0.02)
                end
            end)
            
            coroutine.resume(coroutines.autoDefend)
        else
            cleanupCoroutine("autoDefend")
        end
    end
})

DefenseTab:AddToggle({
    Name = "アンチキック-サイレント",
    Default = false,
    Save = true,
    Flag = "SelfDefenseKick",
    Callback = function(enabled)
        if enabled then
            coroutines.autoDefendKick = coroutine.create(function()
                while coroutines.autoDefendKick do
                    safePcall(function()
                        if not playerCharacter or not playerCharacter:FindFirstChild("Head") then
                            task.wait(0.02)
                            return
                        end
                        
                        local head = playerCharacter.Head
                        local partOwner = head:FindFirstChild("PartOwner")
                        
                        if partOwner then
                            local attacker = Players:FindFirstChild(partOwner.Value)
                            if attacker and attacker.Character then
                                local attackerHRP = attacker.Character:FindFirstChild("HumanoidRootPart")
                                if attackerHRP and attackerHRP:FindFirstChild("FirePlayerPart") then
                                    Struggle:FireServer()
                                    
                                    local fpp = attackerHRP.FirePlayerPart
                                    SetNetworkOwner:FireServer(fpp, fpp.CFrame)
                                    task.wait(0.1)
                                    
                                    if not fpp:FindFirstChild("BodyVelocity") then
                                        local bodyVelocity = Instance.new("BodyVelocity")
                                        bodyVelocity.Name = "BodyVelocity"
                                        bodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                                        bodyVelocity.Velocity = Vector3.new(0, 20, 0)
                                        bodyVelocity.Parent = fpp
                                    end
                                end
                            end
                        end
                    end, "Auto defend kick")
                    
                    task.wait(0.02)
                end
            end)
            
            coroutine.resume(coroutines.autoDefendKick)
        else
            cleanupCoroutine("autoDefendKick")
        end
    end
})

-- =============================================
-- Blobman Tab
-- =============================================
BlobmanTab:AddToggle({
    Name = "ブロブマンに座る",
    Default = false,
    Save = true,
    Flag = "AutoSitBlobman",
    Callback = function(enabled)
        AutoSitEnabled = enabled
        
        if enabled and not foundBlobman then
            for _, v in pairs(workspace:GetDescendants()) do
                if v:IsA("Model") and v.Name == "CreatureBlobman" then
                    foundBlobman = v
                    break
                end
            end
        end
    end
})

local blobman1Toggle

blobman1Toggle = BlobmanTab:AddToggle({
    Name = "Kick All",
    Default = false,
    Callback = function(enabled)
        if enabled then
            local foundBlobmanInstance = nil
            
            for _, v in pairs(workspace:GetDescendants()) do
                if v:IsA("Model") and v.Name == "CreatureBlobman" then
                    local seat = v:FindFirstChild("VehicleSeat")
                    if seat and seat:FindFirstChild("SeatWeld") then
                        local part1 = seat.SeatWeld.Part1
                        if part1 and isDescendantOf(part1, playerCharacter) then
                            foundBlobmanInstance = v
                            blobman = v
                            break
                        end
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
                
                if blobman1Toggle then
                    blobman1Toggle:Set(false)
                end
                
                return
            end
            
            startLoopTP(foundBlobmanInstance)
        else
            stopLoopTP()
        end
    end
})

BlobmanTab:AddSlider({
    Name = "tp時間&グラブ時間",
    Min = 0.0005,
    Max = 1,
    ValueName = "sec",
    Increment = 0.001,
    Default = _G.BlobmanDelay,
    Callback = function(value)
        _G.BlobmanDelay = value
    end
})

-- =============================================
-- Character Tab
-- =============================================
CharacterTab:AddToggle({
    Name = "しゃがみ速度",
    Default = false,
    Save = true,
    Flag = "CrouchSpeed",
    Callback = function(enabled)
        if enabled then
            startCrouchSpeed()
        else
            stopCrouchSpeed()
        end
    end
})

CharacterTab:AddSlider({
    Name = "セットしゃがみ速度",
    Min = 6,
    Max = 1000,
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
    Callback = function(enabled)
        if enabled then
            startCrouchJump()
        else
            stopCrouchJump()
        end
    end
})

CharacterTab:AddSlider({
    Name = "セットしゃがみジャンプパワー",
    Min = 6,
    Max = 1000,
    ValueName = ".",
    Increment = 1,
    Default = crouchJumpPower,
    Save = true,
    Flag = "SetCrouchJumpPower",
    Callback = function(value)
        crouchJumpPower = value
    end
})

-- =============================================
-- Fun Tab（デコイコントロール）
-- =============================================
FunTab:AddLabel("クローン操作")

FunTab:AddSlider({
    Name = "Offset",
    Min = 1,
    Max = 10,
    ValueName = ".",
    Increment = 1,
    Default = decoyOffset,
    Callback = function(value)
        decoyOffset = value
    end
})

FunTab:AddTextbox({
    Name = "Circle Radius",
    Default = tostring(circleRadius),
    TextDisappear = false,
    Callback = function(value)
        local num = tonumber(value)
        if num then
            circleRadius = num
        end
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
        if numDecoys == 0 then
            OrionLib:MakeNotification({
                Name = "Error",
                Content = "デコイが見つかりません",
                Image = "rbxassetid://4483345998",
                Time = 3
            })
            return
        end
        
        local midPoint = math.ceil(numDecoys / 2)
        
        local function updateDecoyPositions()
            for index, decoy in pairs(decoys) do
                safePcall(function()
                    local torso = decoy:FindFirstChild("Torso")
                    if not torso then return end
                    
                    local bodyPosition = torso:FindFirstChild("BodyPosition")
                    local bodyGyro = torso:FindFirstChild("BodyGyro")
                    
                    if not bodyPosition or not bodyGyro then return end
                    if not playerCharacter or not playerCharacter:FindFirstChild("HumanoidRootPart") then return end
                    
                    local targetPosition
                    
                    if followMode then
                        targetPosition = playerCharacter.HumanoidRootPart.Position
                        local offset = (index - midPoint) * decoyOffset
                        local forward = playerCharacter.HumanoidRootPart.CFrame.LookVectorlocal right = playerCharacter.HumanoidRootPart.CFrame.RightVector
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
                end, "Update decoy position")
            end
        end
        
        local function setupDecoy(decoy)
            safePcall(function()
                local torso = decoy:FindFirstChild("Torso")
                if not torso then return end
                
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
                table.insert(connections.general, connection)
                
                if playerCharacter and playerCharacter:FindFirstChild("Head") then
                    SetNetworkOwner:FireServer(torso, playerCharacter.Head.CFrame)
                end
            end, "Setup decoy")
        end
        
        for _, decoy in pairs(decoys) do
            setupDecoy(decoy)
        end
        
        OrionLib:MakeNotification({
            Name = "Success",
            Content = "Got " .. numDecoys .. " units",
            Image = "rbxassetid://4483345998",
            Time = 3
        })
    end
})

FunTab:AddButton({
    Name = "Toggle Mode",
    Callback = function()
        followMode = not followMode
        OrionLib:MakeNotification({
            Name = "Mode Changed",
            Content = followMode and "Follow Mode" or "Surround Mode",
            Image = "rbxassetid://4483345998",
            Time = 2
        })
    end
})

FunTab:AddButton({
    Name = "Disconnect Clones",
    Callback = function()
        cleanupConnections(connections.general)
        
        for _, descendant in pairs(workspace:GetDescendants()) do
            if descendant:IsA("Model") and descendant.Name == "YouDecoy" then
                safePcall(function()
                    local torso = descendant:FindFirstChild("Torso")
                    if torso then
                        for _, child in pairs(torso:GetChildren()) do
                            if child:IsA("BodyPosition") or child:IsA("BodyGyro") then
                                child:Destroy()
                            end
                        end
                    end
                end, "Disconnect clone")
            end
        end
    end
})

-- =============================================
-- Scripts Tab
-- =============================================
ScriptTab:AddButton({
    Name = "Infinite Yield",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source", true))()
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

-- =============================================
-- Aura Tab
-- =============================================
AuraTab:AddLabel("オーラ")

AuraTab:AddSlider({
    Name = "距離",
    Min = 5,
    Max = 100,
    ValueName = ".",
    Increment = 1,
    Default = auraRadius,
    Callback = function(value)
        auraRadius = value
    end
})

AuraTab:AddToggle({
    Name = "エアサスペンドオーラ",
    Default = false,
    Save = true,
    Callback = function(enabled)
        if enabled then
            startAura()
        else
            stopAura()
        end
    end
})

AuraTab:AddToggle({
    Name = "奈落オーラ",
    Default = false,
    Save = true,
    Callback = function(enabled)
        if enabled then
            startGravity()
        else
            stopGravity()
        end
    end
})

AuraTab:AddToggle({
    Name = "キックオーラ",
    Default = false,
    Save = true,
    Callback = function(enabled)
        if enabled then
            startKick()
        else
            stopKick()
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
    end
})

AuraTab:AddToggle({
    Name = "放射線オーラ",
    Default = false,
    Save = true,
    Callback = function(enabled)
        if enabled then
            startPoisonAura()
        else
            stopPoisonAura()
        end
    end
})

-- =============================================
-- Keybinds Tab
-- =============================================
KeybindsTab:AddLabel("Player Keybinds")
KeybindsTab:AddParagraph("Tip", "Press while looking at a player")

KeybindsTab:AddBind({
    Name = "奈落へ落とす",
    Default = Enum.KeyCode.Z,
    Hold = false,
    Save = true,
    Flag = "SendToHellKeybind",
    Callback = function()
        safePcall(function()
            local mouse = localPlayer:GetMouse()
            local target = mouse.Target
            
            if not target or not target:IsA("BasePart") then return end
            
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
        end, "Send to hell keybind")
    end
})

KeybindsTab:AddBind({
    Name = "キック",
    Default = Enum.KeyCode.X,
    Hold = false,
    Save = true,
    Flag = "KickKeybind",
    Callback = function()
        safePcall(function()
            local mouse = localPlayer:GetMouse()
            local target = mouse.Target
            
            if not target or not target:IsA("BasePart") then return end
            
            local character = target.Parent
            if target.Name == "FirePlayerPart" then
                character = target.Parent.Parent
            end
            
            local humanoid = character and character:FindFirstChildOfClass("Humanoid")
            local hrp = character and character:FindFirstChild("HumanoidRootPart")
            local fpp = hrp and hrp:FindFirstChild("FirePlayerPart")
            
            if character and humanoid and hrp and fpp then
                task.spawn(function()
                    if kickMode == 1 then
                        SetNetworkOwner:FireServer(fpp, fpp.CFrame)
                        local bodyVelocity = Instance.new("BodyVelocity")
                        bodyVelocity.Parent = fpp
                        bodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                        bodyVelocity.Velocity = Vector3.new(0, 20, 0)
                        Debris:AddItem(bodyVelocity, 5)
                    elseif kickMode == 2 then
                        SetNetworkOwner:FireServer(fpp, fpp.CFrame)
                        local platform = character:FindFirstChild("FloatingPlatform")
                        if not platform then
                            platform = Instance.new("Part")
                            platform.Name = "FloatingPlatform"
                            platform.Size = Vector3.new(5, 2, 5)
                            platform.Anchored = true
                            platform.Transparency = 1
                            platform.CanCollide = true
                            platform.Parent = character
                        end
                        
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
        end, "Kick keybind")
    end
})

KeybindsTab:AddDropdown({
    Name = "キックモードを選択",
    Options = {"空", "サイレント"},
    Default = "サイレント",
    Callback = function(selected)
        if selected == "空" then
            kickMode = 1
        else
            kickMode = 2
        end
    end
})

KeybindsTab:AddBind({
    Name = "キル(不安定)",
    Default = Enum.KeyCode.C,
    Hold = false,
    Save = true,
    Flag = "KillKeybind",
    Callback = function()
        safePcall(function()
            local mouse = localPlayer:GetMouse()
            local target = mouse.Target
            
            if not target or not target:IsA("BasePart") then return end
            
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
        end, "Kill keybind")
    end
})

KeybindsTab:AddBind({
    Name = "炎",
    Default = Enum.KeyCode.V,
    Hold = false,
    Save = true,
    Flag = "BurnKeybind",
    Callback = function()
        if not ownedToys["Campfire"] then
            OrionLib:MakeNotification({
                Name = "Missing toy",
                Content = "あなたはキャンプファイヤーを所有していません",
                Image = "rbxassetid://4483345998",
                Time = 3
            })
            return
        end
        
        safePcall(function()
            local mouse = localPlayer:GetMouse()
            local target = mouse.Target
            
            if not target or not target:IsA("BasePart") then return end
            
            local character = target.Parent
            if target.Name == "FirePlayerPart" then
                character = target.Parent.Parent
            end
            
            local humanoid = character and character:FindFirstChildOfClass("Humanoid")
            local hrp = character and character:FindFirstChild("HumanoidRootPart")
            local head = character and character:FindFirstChild("Head")
            
            if character and humanoid and hrp and head then
                task.spawn(function()
                    if head then
                        arson(head)
                    end
                end)
            end
        end, "Burn keybind")
    end
})

KeybindsTab:AddLabel("Missile Keybinds")
KeybindsTab:AddParagraph("Tip", "Press anywhere")

KeybindsTab:AddBind({
    Name = "爆弾",
    Default = Enum.KeyCode.B,
    Hold = false,
    Save = true,
    Flag = "ExplodeBombKeybind",
    Callback = function()
        if not ownedToys[_G.ToyToLoad] then
            OrionLib:MakeNotification({
                Name = "Missing toy",
                Content = "あなたは爆弾を持っていません",
                Image = "rbxassetid://4483345998",
                Time = 3
            })
            return
        end
        
        safePcall(function()
            local connection
            connection = toysFolder.ChildAdded:Connect(function(child)
                if child.Name == _G.ToyToLoad then
                    local toyNumber = child:WaitForChild("ThisToysNumber", 1)
                    if toyNumber and toyNumber.Value == (toysFolder.ToyNumber.Value - 1) then
                        connection:Disconnect()
                        
                        local partHitDetector = child:FindFirstChild("PartHitDetector")
                        local bodyPart = child:FindFirstChild("Body")
                        
                        if partHitDetector and bodyPart and playerCharacter and playerCharacter:FindFirstChild("HumanoidRootPart") then
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
                                [2] = playerCharacter.HumanoidRootPart.Position
                            }
                            
                            ReplicatedStorage.BombEvents.BombExplode:FireServer(unpack(args))
                        end
                    end
                end
            end)
            
            if playerCharacter and playerCharacter:FindFirstChild("Head") then
                spawnItemCf(_G.ToyToLoad, playerCharacter.Head.CFrame)
            end
            
            task.delay(1, function()
                if connection then
                    connection:Disconnect()
                end
            end)
        end, "Explode bomb keybind")
    end
})

KeybindsTab:AddBind({
    Name = "Throw Bomb",
    Default = Enum.KeyCode.M,
    Hold = false,
    Save = true,
    Flag = "ThrowBombKeybind",
    Callback = function()
        if not ownedToys[_G.ToyToLoad] then
            OrionLib:MakeNotification({
                Name = "Missing toy",
                Content = "You do not own the " .. _G.ToyToLoad .. " toy",
                Image = "rbxassetid://4483345998",
                Time = 3
            })
            return
        end
        
        safePcall(function()
            local connection
            connection = toysFolder.ChildAdded:Connect(function(child)
                if child.Name == _G.ToyToLoad then
                    local toyNumber = child:WaitForChild("ThisToysNumber", 1)
                    if toyNumber and toyNumber.Value == (toysFolder.ToyNumber.Value - 1) then
                        connection:Disconnect()
                        
                        local partHitDetector = child:FindFirstChild("PartHitDetector")
                        if partHitDetector then
                            SetNetworkOwner:FireServer(partHitDetector, partHitDetector.CFrame)
                            
                            local velocityObj = Instance.new("BodyVelocity")
                            velocityObj.Parent = partHitDetector
                            velocityObj.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                            velocityObj.Velocity = workspace.CurrentCamera.CFrame.lookVector * 500
                            Debris:AddItem(velocityObj, 10)
                        end
                    end
                end
            end)
            
            if playerCharacter and playerCharacter:FindFirstChild("Head") then
                spawnItemCf(_G.ToyToLoad, playerCharacter.Head.CFrame)
            end
        end, "Throw bomb keybind")
    end
})

KeybindsTab:AddParagraph("Tip", "Hold to reload bombs")

KeybindsTab:AddBind({
    Name = "ミサイルキャッシュリロード",
    Default = Enum.KeyCode.R,
    Hold = true,
    Save = true,
    Flag = "BombCacheReload",
    Callback = function(isHeld)
        reloadMissile(isHeld)
    end
})

KeybindsTab:AddBind({
    Name = "爆弾キャッシュリロード",
    Default = Enum.KeyCode.T,
    Hold = false,
    Save = true,
    Flag = "ExplodeCachedBombKeybind",
    Callback = function()
        if #bombList == 0 then
            OrionLib:MakeNotification({
                Name = "No bombs",
                Content = "There are no cached bombs to explode",
                Image = "rbxassetid://4483345998",
                Time = 2
            })
            return
        end
        
        safePcall(function()
            local bomb = table.remove(bombList, 1)
            
            if bomb and bomb:FindFirstChild("PartHitDetector") and bomb:FindFirstChild("Body") then
                if playerCharacter and playerCharacter:FindFirstChild("HumanoidRootPart") then
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
                            ["PositionPart"] = playerCharacter.HumanoidRootPart
                        },
                        [2] = playerCharacter.HumanoidRootPart.Position
                    }
                    
                    ReplicatedStorage.BombEvents.BombExplode:FireServer(unpack(args))
                end
            end
        end, "Explode cached bomb")
    end
})

KeybindsTab:AddBind({
    Name = "全ての爆弾キャッシュリロード",
    Default = Enum.KeyCode.Y,
    Hold = false,
    Save = true,
    Flag = "ExplodeAllCachedBombsKeybind",
    Callback = function()
        if #bombList == 0 then
            OrionLib:MakeNotification({
                Name = "No bombs",
                Content = "There are no cached bombs to explode",
                Image = "rbxassetid://4483345998",
                Time = 2
            })
            return
        end
        
        safePcall(function()
            for i = #bombList, 1, -1 do
                local bomb = table.remove(bombList, i)
                
                if bomb and bomb:FindFirstChild("PartHitDetector") and bomb:FindFirstChild("Body") then
                    if playerCharacter and playerCharacter:FindFirstChild("HumanoidRootPart") then
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
                                ["PositionPart"] = playerCharacter.HumanoidRootPart
                            },
                            [2] = playerCharacter.HumanoidRootPart.Position
                        }
                        
                        ReplicatedStorage.BombEvents.BombExplode:FireServer(unpack(args))
                    end
                end
                
                task.wait(0.05)
            end
        end, "Explode all cached bombs")
    end
})

KeybindsTab:AddBind({
    Name = "最も近いプレイヤーに隠されたミサイルをすべて爆発させる",
    Default = Enum.KeyCode.U,
    Hold = false,
    Save = true,
    Flag = "ExplodeAllCachedBombsOnNearestPlayerKeybind",
    Callback = function()
        if #bombList == 0 then
            OrionLib:MakeNotification({
                Name = "No bombs",
                Content = "There are no cached bombs to explode",
                Image = "rbxassetid://4483345998",
                Time = 2
            })
            return
        end
        
        safePcall(function()
            local nearestPlayer = getNearestPlayer()
            
            if not nearestPlayer or not nearestPlayer.Character or not nearestPlayer.Character:FindFirstChild("HumanoidRootPart") then
                OrionLib:MakeNotification({
                    Name = "Error",
                    Content = "最も近いプレイヤーが見つかりません",
                    Image = "rbxassetid://4483345998",
                    Time = 2
                })
                return
            end
            
            local targetPart = nearestPlayer.Character.HumanoidRootPart
            
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
                    
                    ReplicatedStorage.BombEvents.BombExplode:FireServer(unpack(args))
                end
                
                task.wait(0.05)
            end
        end, "Explode all on nearest player")
    end
})

-- =============================================
-- Explosion Tab
-- =============================================
ExplosionTab:AddDropdown({
    Name = "トイロード",
    Default = "BombMissile",
    Options = {"BombMissile", "FireworkMissile"},
    Callback = function(value)
        _G.ToyToLoad = value
    end
})

ExplosionTab:AddSlider({
    Name = "Max amount of missiles",
    Min = 1,
    Max = localPlayer.ToysLimitCap.Value / 10,
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
    Save = true,
    Flag = "AutoReloadBombs",
    Callback = function(enabled)
        reloadMissile(enabled)
    end
})

-- =============================================
-- Dev Tab
-- =============================================
DevTab:AddLabel("バナナの皮だけにしてください")

DevTab:AddToggle({
    Name = "ラグドールオール",
    Default = false,
    Save = true,
    Callback = function(enabled)
        if enabled then
            startRagdollAll()
        else
            stopRagdollAll()
        end
    end
})

-- =============================================
-- AutoSit機能（Heartbeatループ）
-- =============================================
local autoSitConnection = RunService.Heartbeat:Connect(function()
    if AutoSitEnabled and playerCharacter then
        local humanoid = playerCharacter:FindFirstChild("Humanoid")
        
        if humanoid and humanoid.SeatPart == nil then
            if foundBlobman then
                local vehicleSeat = foundBlobman:FindFirstChild("VehicleSeat")
                if vehicleSeat then
                    vehicleSeat:Sit(humanoid)
                end
            end
        end
    end
end)

-- Blobmanの監視
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

-- キャラクター追加時の処理
localPlayer.CharacterAdded:Connect(function(character)
    playerCharacter = character
    
    if AutoSitEnabled and foundBlobman then
        task.wait(1)
        local vehicleSeat = foundBlobman:FindFirstChild("VehicleSeat")
        if vehicleSeat then
            local humanoid = character:FindFirstChild("Humanoid")
            if humanoid and humanoid.SeatPart == nil then
                vehicleSeat:Sit(humanoid)
            end
        end
    end
end)

-- =============================================
-- クリーンアップと終了処理
-- =============================================
local function cleanupAll()
    -- すべてのフラグを停止
    for key, _ in pairs(flags) do
        flags[key] = false
    end
    
    -- すべてのコルーチンを停止
    for name, _ in pairs(coroutines) do
        cleanupCoroutine(name)
    end
    
    -- すべての接続を切断
    for _, connectionTable in pairs(connections) do
        cleanupConnections(connectionTable)
    end
    
    -- 特殊なクリーンアップ
    cleanupAnchoredParts()
    cleanupCompiledGroups()
    
    -- プラットフォームのクリーンアップ
    for _, platform in pairs(platforms) do
        if platform and platform.Parent then
            platform:Destroy()
        end
    end
    platforms = {}
    
    -- 毒パーツのクリーンアップ
    for _, part in pairs(poisonHurtParts) do
        if part and part.Parent then
            part.Position = Vector3.new(0, -200, 0)
        end
    end
    
    -- AutoSit接続の切断
    if autoSitConnection then
        autoSitConnection:Disconnect()
    end
    
    -- キャラクター接続の切断
    if characterConnection then
        characterConnection:Disconnect()
    end
    
    print("✅ すべてのリソースがクリーンアップされました")
end

-- プレイヤー退出時のクリーンアップ
Players.PlayerRemoving:Connect(function(player)
    if player == localPlayer then
        cleanupAll()
    end
end)

-- ゲーム終了時のクリーンアップ
game:BindToClose(function()
    cleanupAll()
end)

-- =============================================
-- 初期化完了
-- =============================================
OrionLib:MakeNotification({
    Name = "Welcome",
    Content = "ようこそ、野獣のおちんちんハブへ",
    Image = "rbxassetid://4483345998",
    Time = 5
})

OrionLib:Init()

print("🎮 野獣のおちんちんハブ - スクリプト読み込み完了!")
