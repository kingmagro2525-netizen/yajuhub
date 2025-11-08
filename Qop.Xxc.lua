local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")

-- 🔧 ReplicatedStorageの子要素の存在確認
local GrabEvents = ReplicatedStorage:WaitForChild("GrabEvents", 5)
local MenuToys = ReplicatedStorage:WaitForChild("MenuToys", 5)
local CharacterEvents = ReplicatedStorage:WaitForChild("CharacterEvents", 5)

if not GrabEvents or not MenuToys or not CharacterEvents then
    warn("Failed to find essential ReplicatedStorage children. Script will terminate.")
    return
end

-- 🔧 イベント/関数リファレンスの存在確認
local SetNetworkOwner = GrabEvents:WaitForChild("SetNetworkOwner", 5)
local Struggle = CharacterEvents:WaitForChild("Struggle", 5)
local CreateLine = GrabEvents:WaitForChild("CreateGrabLine", 5)
local DestroyLine = GrabEvents:WaitForChild("DestroyGrabLine", 5)
local DestroyToy = MenuToys:WaitForChild("DestroyToy", 5)

if not SetNetworkOwner or not Struggle or not DestroyToy then
    warn("Failed to find essential RemoteFunctions/Events. Script will terminate.")
    return
end


local localPlayer = Players.LocalPlayer
local playerCharacter = localPlayer.Character or localPlayer.CharacterAdded:Wait()

localPlayer.CharacterAdded:Connect(function(character)
    playerCharacter = character
end)

local AutoRecoverDroppedPartsCoroutine
local connectionBombReload
local reloadBombCoroutine
local antiExplosionConnection
local poisonAuraCoroutine
local deathAuraCoroutine
local poisonCoroutines = {}
local strengthConnection
local coroutineRunning = false
local autoStruggleCoroutine
local autoDefendCoroutine
local auraCoroutine
local gravityCoroutine
local kickCoroutine
local kickGrabCoroutine
local hellSendGrabCoroutine
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
local burnPart
local fireGrabCoroutine
local noclipGrabCoroutine
local antiKickCoroutine
local kickGrabConnections = {}
local blobmanCoroutine
local lighBitSpeedCoroutine
local lightbitpos = {}
local lightbitparts = {}
local lightbitcon
local lightbitcon2
local lightorbitcon
local bodyPositions = {}
local alignOrientations = {}
local NoclipToggleConnection 
local NoclipToggleEnabled = false 
local characterAddedConn 
local autoDefendKickCoroutine
local anchorKickCoroutine

-- 😈 新しいグローバル変数の追加
local AutoSitEnabled = false
local reloadBlobmanCoroutine -- ブロブマン自動スポーン用コルーチン
local connectionBlobmanReload -- ブロブマン自動スポーンの接続
local blobmanList = {} -- スポーンしたブロブマンのキャッシュリスト
_G.MaxBlobmen = 1 -- 最大ブロブマン数
_G.BlobmanToyName = "CreatureBlobman" -- ブロブマンのトイ名

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

-- 😈 OrionLibの安全な読み込み
local OrionLibSuccess, OrionLib
pcall(function()
    OrionLib = loadstring(game:HttpGet(("https://raw.githubusercontent.com/yua20170313a-pixel/Orion/e19e8236bde46c459fb0d617e4640aeb75878703/source")))()
end)

if not OrionLib then
    warn("Failed to load OrionLib.")
    return -- 😈 読み込み失敗時にスクリプトを停止
end
-- /OrionLibの安全な読み込み

-- 🛠️ ユーティリティ関数の定義をここに追加 🛠️

local function isDescendantOf(target, other)
    if not target or not other then return false end -- 😈 nilチェックを追加
    local currentParent = target.Parent
    while currentParent do
        if currentParent == other then
            return true
        end
        currentParent = currentParent.Parent
    end
    return false
end

local function findFirstAncestorOfType(instance, className)
    local current = instance.Parent
    while current and not current:IsA(className) do
        current = current.Parent
    end
    return current
end

local function findDescendant(parent, name, className)
    -- 🔴 nilチェックが欠けているため追加
    if not parent then return nil end
    for _, descendant in ipairs(parent:GetDescendants()) do
        if (not name or descendant.Name == name) and (not className or descendant:IsA(className)) then
            return descendant
        end
    end
    return nil
end

local function getSurroundingVectors(targetPosition, radius, amount, offset)
    local vectors = {}
    local angleStep = (2 * math.pi) / amount
    for i = 1, amount do
        local angle = (i - 1) * angleStep + offset
        local x = targetPosition.X + radius * math.cos(angle)
        local z = targetPosition.Z + radius * math.sin(angle)
        -- Y座標はターゲットの中心に合わせる
        table.insert(vectors, Vector3.new(x, targetPosition.Y, z))
    end
    return vectors
end

-- 🛠️ ユーティリティ関数の定義ここまで 🛠️

-- 😈 toysFolderの安全な初期化 (問題点2の修正 - ゲーム固有オブジェクトの存在確認)
local toysFolder = workspace:WaitForChild(localPlayer.Name.."SpawnedInToys", 5)
if not toysFolder then
    warn("Failed to find toysFolder. Script will be limited.")
end
-- /toysFolderの安全な初期化

local followMode = true
local playerList = {}
local selection 
local blobman 
local platforms = {}
local ownedToys = {}
local bombList = {}
_G.ToyToLoad = "BombMissile"
_G.MaxMissiles = 9
_G.BlobmanDelay = 0.005

-- 🔧 workspace.Mapの存在チェック (ゲーム固有オブジェクトの存在確認)
local map = workspace:WaitForChild("Map", 5)
if not map then
    warn("Failed to find Map in workspace. Game-specific features may not work.")
end

local function DestroyT(toy)
    -- 🔴 nilチェックを追加
    if not DestroyToy then return end
    local toy = toy or (toysFolder and toysFolder:FindFirstChildWhichIsA("Model"))
    if toy then
        DestroyToy:FireServer(toy)
    end
end


local function getDescendantParts(descendantName)
    local parts = {}
    -- workspace.Mapの存在チェック
    if map then
        for _, descendant in ipairs(map:GetDescendants()) do
            if descendant:IsA("Part") and descendant.Name == descendantName then
                table.insert(parts, descendant)
            end
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

-- 😈 ownedToysの初期化にエラーハンドリング追加 (問題点5の修正)
local success, result = pcall(function()
    local playerGui = localPlayer:WaitForChild("PlayerGui", 5)
    if not playerGui then return end
    local menuGui = playerGui:WaitForChild("MenuGui", 5)
    if not menuGui then return end
    local menu = menuGui:WaitForChild("Menu", 5)
    if not menu then return end
    local tabContents = menu:WaitForChild("TabContents", 5)
    if not tabContents then return end
    local toys = tabContents:WaitForChild("Toys", 5)
    if not toys then return end
    local contents = toys:WaitForChild("Contents", 5)
    if not contents then return end

    for _, v in pairs(contents:GetChildren()) do
        if v.Name ~= "UIGridLayout" then
            ownedToys[v.Name] = true
        end
    end
end)
if not success then
    warn("Failed to initialize ownedToys: " .. tostring(result))
end
-- /ownedToysの初期化にエラーハンドリング追加

local function getNearestPlayer()
    local nearestPlayer
    local nearestDistance = math.huge

    for _, player in pairs(Players:GetPlayers()) do
        -- 🔴 nilチェックを追加
        if player ~= localPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") and playerCharacter and playerCharacter:FindFirstChild("HumanoidRootPart") then
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
    -- 🔴 nilチェックと接続状態の確認を強化
    for _, connection in ipairs(connectionTable) do
        if connection and typeof(connection) == "Instance" and connection.Connected then 
            connection:Disconnect()
        elseif connection and typeof(connection) == "RBXScriptConnection" and connection.Connected then
            connection:Disconnect()
        end
    end
    -- テーブルをクリア
    for i = #connectionTable, 1, -1 do
        table.remove(connectionTable, i)
    end
end

local function getVersion()
    local url = "https://raw.githubusercontent.com/kingmagro2525-netizen/yajuhub/main/Qop.Xxc.version.lua"
    local success, response = pcall(function()
        return game:HttpGet(url)
    end)

    if success then
        -- 🔴 JSONDecodeの引数nilチェック
        if not response or response == "" then return "Unknown" end
        local data = HttpService:JSONDecode(response)
        -- 🔴 data.versionのnilチェック
        return data and data.version or "Unknown"
    else
        warn("Failed to get version: " .. tostring(response))
        return "Unknown"
    end
end

local function spawnItem(itemName, position, orientation)
    task.spawn(function()
        -- 🔴 MenuToysのSpawnToyRemoteFunctionのnilチェック
        local remote = ReplicatedStorage.MenuToys:FindFirstChild("SpawnToyRemoteFunction")
        if not remote then warn("SpawnToyRemoteFunction not found.") return end

        local cframe = CFrame.new(position)
        local rotation = Vector3.new(0, 90, 0)
        remote:InvokeServer(itemName, cframe, rotation)
    end)
end

local function arson(part)
    if not toysFolder or not part or not part.Parent then return end -- 😈 toysFolder, partチェック

    if not toysFolder:FindFirstChild("Campfire") then
        spawnItem("Campfire", Vector3.new(-72.9304581, -5.96906614, -265.543732))
    end
    local campfire = toysFolder:FindFirstChild("Campfire")
    if not campfire then return end -- 😈 campfireチェック
    
    burnPart = campfire:FindFirstChild("FirePlayerPart") or campfire.FirePlayerPart
    if not burnPart then return end -- 😈 burnPartチェック
    
    burnPart.Size = Vector3.new(7, 7, 7)
    burnPart.Position = part.Position
    task.wait(0.3)
    burnPart.Position = Vector3.new(0, -50, 0)
end

local function handleCharacterAdded(player)
    -- 🔴 playerのnilチェック
    if not player then return end

    local characterAddedConnection = player.CharacterAdded:Connect(function(character)
        -- 🔴 characterのnilチェック
        if not character then return end
        local hrp = character:WaitForChild("HumanoidRootPart", 5)
        if not hrp then return end
        local fpp = hrp:WaitForChild("FirePlayerPart", 5) -- タイムアウトを追加
        if fpp then
            fpp.Size = Vector3.new(4.5, 5, 4.5)
            fpp.CollisionGroup = "1"
            fpp.CanQuery = true
        end
    end)
    table.insert(kickGrabConnections, characterAddedConnection)
end

local function kickGrab()
    for _, player in pairs(Players:GetPlayers()) do
        -- 🔴 player.Characterのnilチェック
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
    -- 🔴 コルーチンの状態チェックは、コルーチンの開始前に呼び出し元で行われているため、ここでは無限ループとnilチェックに集中する
    while true do
        local success, err = pcall(function()
            local child = workspace:FindFirstChild("GrabParts")
            -- 🔴 GrabPartsのnilチェックと名前チェックを強化
            if not child or child.Name ~= "GrabParts" then return end
            
            local grabPart = child:FindFirstChild("GrabPart")
            if not grabPart then return end -- grabPartチェック
            
            local weldConstraint = grabPart:FindFirstChild("WeldConstraint")
            if not weldConstraint or not weldConstraint.Part1 then return end -- weldConstraint/Part1チェック
            
            local grabbedPart = weldConstraint.Part1
            local character = grabbedPart.Parent -- Part1の親をキャラクターと想定
            -- 🔴 characterのnilチェック
            if not character then return end
            local head = character:FindFirstChild("Head") -- キャラクターの子のHeadを探す
            
            if head then
                while workspace:FindFirstChild("GrabParts") do
                    local partsTable = grabType == "poison" and poisonHurtParts or paintPlayerParts
                    -- 🔴 partsTableのnilチェック
                    if partsTable then
                        for _, part in pairs(partsTable) do
                            -- 🔴 partのnilチェック
                            if part and part.Parent then
                                part.Size = Vector3.new(2, 2, 2)
                                part.Transparency = 1
                                part.Position = head.Position
                            end
                        end
                    end
                    wait()
                    if partsTable then
                        for _, part in pairs(partsTable) do
                            if part and part.Parent then
                                part.Position = Vector3.new(0, -200, 0)
                            end
                        end
                    end
                end
                local partsTable = grabType == "poison" and poisonHurtParts or paintPlayerParts
                if partsTable then
                    for _, part in pairs(partsTable) do
                        if part and part.Parent then
                            part.Position = Vector3.new(0, -200, 0)
                        end
                    end
                end
            end
        end)
        wait()
    end
end

local function fireGrab()
    -- 🔴 コルーチンの状態チェックは、コルーチンの開始前に呼び出し元で行われているため、ここでは無限ループとnilチェックに集中する
    while true do
        local success, err = pcall(function()
            local child = workspace:FindFirstChild("GrabParts")
            if not child or child.Name ~= "GrabParts" then return end
            
            local grabPart = child:FindFirstChild("GrabPart")
            if not grabPart then return end
            
            local weldConstraint = grabPart:FindFirstChild("WeldConstraint")
            if not weldConstraint or not weldConstraint.Part1 then return end
            
            local grabbedPart = weldConstraint.Part1
            local character = grabbedPart.Parent
            -- 🔴 characterのnilチェック
            if not character then return end
            local head = character:FindFirstChild("Head")
            
            if head and toysFolder then -- 😈 toysFolderチェック
                arson(head)
            end
        end)
        wait()
    end
end

local function noclipGrab()
    -- 🔴 コルーチンの状態チェックは、コルーチンの開始前に呼び出し元で行われているため、ここでは無限ループとnilチェックに集中する
    while true do
        local success, err = pcall(function()
            local child = workspace:FindFirstChild("GrabParts")
            if not child or child.Name ~= "GrabParts" then return end
            
            local grabPart = child:FindFirstChild("GrabPart")
            if not grabPart then return end
            
            local weldConstraint = grabPart:FindFirstChild("WeldConstraint")
            if not weldConstraint or not weldConstraint.Part1 then return end
            
            local character = weldConstraint.Part1.Parent
            
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
        end)
        wait()
    end
end

-- 😈 Noclip トグル機能の実装
local function togglePlayerNoclip(enabled)
    NoclipToggleEnabled = enabled
    if enabled then
        -- 🔴 コルーチンの開始前に既存のチェックを追加
        if NoclipToggleConnection and NoclipToggleConnection.Connected then 
            NoclipToggleConnection:Disconnect() 
            NoclipToggleConnection = nil
        end

        -- Heartbeatで継続的にCanCollideを設定
        NoclipToggleConnection = RunService.Heartbeat:Connect(function()
            if not playerCharacter then return end

            -- プレイヤーのパーツを処理
            for _, part in ipairs(playerCharacter:GetDescendants()) do
                if part:IsA("BasePart") and part.CanCollide == true and not part.Anchored then
                    part.CanCollide = false
                end
            end
            
            -- 乗り物に乗っているか確認
            local humanoid = playerCharacter:FindFirstChildOfClass("Humanoid")
            if humanoid and humanoid.SeatPart and humanoid.SeatPart.Parent then
                local vehicle = humanoid.SeatPart.Parent
                -- 乗り物のパーツを処理
                for _, part in ipairs(vehicle:GetDescendants()) do
                    if part:IsA("BasePart") and part.CanCollide == true and not part.Anchored then
                        part.CanCollide = false
                    end
                end
            end
        end)
    else
        -- トグルがオフになったら接続を切断し、CanCollideを元に戻す
        if NoclipToggleConnection then
            NoclipToggleConnection:Disconnect()
            NoclipToggleConnection = nil
        end

        -- プレイヤーのパーツを元に戻す
        if playerCharacter then
            for _, part in ipairs(playerCharacter:GetDescendants()) do
                if part:IsA("BasePart") and part.CanCollide == false and not part.Anchored then
                    part.CanCollide = true
                end
            end
        end

        -- 乗り物のパーツを元に戻す
        local humanoid = playerCharacter and playerCharacter:FindFirstChildOfClass("Humanoid")
        if humanoid and humanoid.SeatPart and humanoid.SeatPart.Parent then
            local vehicle = humanoid.SeatPart.Parent
            for _, part in ipairs(vehicle:GetDescendants()) do
                if part:IsA("BasePart") and part.CanCollide == false and not part.Anchored then
                    part.CanCollide = true
                end
            end
        end
    end
end
-- 😈 /Noclip トグル機能の実装

local function spawnItemCf(itemName, cframe)
    task.spawn(function()
        -- 🔴 MenuToysのSpawnToyRemoteFunctionのnilチェック
        local remote = ReplicatedStorage.MenuToys:FindFirstChild("SpawnToyRemoteFunction")
        if not remote then warn("SpawnToyRemoteFunction not found.") return end

        local rotation = Vector3.new(0, 0, 0)
        remote:InvokeServer(itemName, cframe, rotation)
    end)
end

local function fireAll()
    if not toysFolder then return end -- 😈 toysFolderチェック
    
    -- 🔴 コルーチンの状態チェックは、コルーチンの開始前に呼び出し元で行われているため、ここでは無限ループとnilチェックに集中する

    while true do
        local success, err = pcall(function()
            if toysFolder:FindFirstChild("Campfire") then
                DestroyT(toysFolder:FindFirstChild("Campfire"))
                wait(0.5)
            end
            
            if not playerCharacter or not playerCharacter:FindFirstChild("Head") then return end
            spawnItemCf("Campfire", playerCharacter.Head.CFrame)
            
            local campfire = toysFolder:WaitForChild("Campfire", 5)
            if not campfire then return end -- campfireがスポーンしなかった場合のチェック
            
            local firePlayerPart
            for _, part in pairs(campfire:GetChildren()) do
                if part.Name == "FirePlayerPart" and part:IsA("BasePart") then
                    part.Size = Vector3.new(10, 10, 10)
                    firePlayerPart = part
                    break
                end
            end
            
            if not firePlayerPart then return end -- firePlayerPartチェック
            
            local torso = playerCharacter:FindFirstChild("Torso")
            if not torso then return end

            local originalPosition = torso.Position
            SetNetworkOwner:FireServer(firePlayerPart, firePlayerPart.CFrame)
            playerCharacter:MoveTo(firePlayerPart.Position)
            wait(0.3)
            playerCharacter:MoveTo(originalPosition)
            
            local bodyPosition = Instance.new("BodyPosition")
            bodyPosition.P = 20000
            
            local campfireMain = campfire:FindFirstChild("Main")
            if not campfireMain then return end -- MainPartチェック
            bodyPosition.Parent = campfireMain
            
            while true do
                for _, player in pairs(Players:GetChildren()) do
                    pcall(function()
                        if not playerCharacter or not playerCharacter:FindFirstChild("Head") then return end
                        bodyPosition.Position = playerCharacter.Head.Position + Vector3.new(0, 600, 0)
                        
                        -- 🔴 player.Characterのnilチェック
                        if player.Character and player.Character ~= localPlayer.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                            firePlayerPart.Position = player.Character.HumanoidRootPart.Position or player.Character.Head.Position
                            wait()
                        end
                    end)
                end  
                wait()
            end
        end)
        if not success then
            warn("Error in fireAll: " .. tostring(err))
        end
        wait()
    end
end

local function createHighlight(parent)
    -- 🔴 parentのnilチェック
    if not parent then return nil end

    local highlight = Instance.new("Highlight")
    highlight.DepthMode = Enum.HighlightDepthMode.Occluded
    highlight.FillTransparency = 1
    highlight.Name = "Highlight"
    highlight.OutlineColor = Color3.new(0, 0, 1)
    highlight.OutlineTransparency = 0.5
    highlight.Parent = parent
    print("created highlight and set on "..parent.Name)
    return highlight
end

local function onPartOwnerAdded(descendant, primaryPart)
    -- 🔴 descendant, primaryPartのnilチェック
    if not descendant or not primaryPart then return end

    if descendant.Name == "PartOwner" and descendant.Value ~= localPlayer.Name then
        local modelAncestor = findFirstAncestorOfType(primaryPart, "Model")
        local highlight = primaryPart:FindFirstChild("Highlight") or (modelAncestor and findDescendant(modelAncestor, "Highlight", "Highlight"))
        
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
    -- 🔴 partのnilチェック
    if not part or not part.Parent then return end

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
    -- 🔴 コルーチンの状態チェックは、コルーチンの開始前に呼び出し元で行われているため、ここでは無限ループとnilチェックに集中する
    while true do
        pcall(function()
            local grabParts = workspace:FindFirstChild("GrabParts")
            if not grabParts then return end

            local grabPart = grabParts:FindFirstChild("GrabPart")
            if not grabPart then return end

            local weldConstraint = grabPart:FindFirstChild("WeldConstraint")
            if not weldConstraint or not weldConstraint.Part1 then return end

            local part1 = weldConstraint.Part1
            local modelAncestor = findFirstAncestorOfType(part1, "Model")
            
            -- PrimaryPartを特定
            local primaryPart = part1
            if part1.Name == "SoundPart" then
                primaryPart = part1
            elseif modelAncestor and modelAncestor.PrimaryPart then
                primaryPart = modelAncestor.PrimaryPart
            elseif part1.Parent and part1.Parent:FindFirstChild("SoundPart") then
                primaryPart = part1.Parent.SoundPart
            end

            if not primaryPart or primaryPart.Anchored then return end
            -- 🔴 Mapの存在チェック
            if map and isDescendantOf(primaryPart, map) then return end
            
            local isCharacterPart = false
            for _, player in pairs(Players:GetChildren()) do
                -- 🔴 player.Characterのnilチェック
                if player.Character and isDescendantOf(primaryPart, player.Character) then
                    isCharacterPart = true
                    break
                end
            end
            if isCharacterPart then return end


            local t = true
            for _, v in pairs(primaryPart:GetDescendants()) do
                if table.find(anchoredParts, v) then
                    t = false
                    break
                end
            end
            
            if t and not table.find(anchoredParts, primaryPart) then
                local target 
                if modelAncestor and modelAncestor ~= workspace then
                    target = modelAncestor
                else
                    target = primaryPart
                end
                
                -- HighlightをprimaryPartまたはmodelAncestorに追加
                local highlightTarget = target.PrimaryPart or target
                if highlightTarget then
                    local highlight = createHighlight(highlightTarget)
                end
                
                table.insert(anchoredParts, primaryPart)
                
                print(target)
                -- 🔴 targetのnilチェック
                if target then
                    local connection = target.DescendantAdded:Connect(function(descendant)
                        onPartOwnerAdded(descendant, primaryPart)
                    end)
                    table.insert(anchoredConnections, connection)
                end
            end
            
            -- 🔴 BodyMovers削除時のnilチェック
            local partToDeleteMovers = modelAncestor or primaryPart
            if partToDeleteMovers then
                for _, child in ipairs(partToDeleteMovers:GetDescendants()) do
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
        wait()
    end
end

local function anchorKickGrab()
    -- 🔴 コルーチンの状態チェックは、コルーチンの開始前に呼び出し元で行われているため、ここでは無限ループとnilチェックに集中する
    while true do
        pcall(function()
            local grabParts = workspace:FindFirstChild("GrabParts")
            if not grabParts then return end

            local grabPart = grabParts:FindFirstChild("GrabPart")
            if not grabPart then return end

            local weldConstraint = grabPart:FindFirstChild("WeldConstraint")
            if not weldConstraint or not weldConstraint.Part1 then return end

            local primaryPart = weldConstraint.Part1
            if not primaryPart then return end

            -- 🔴 Mapの存在チェック
            if map and isDescendantOf(primaryPart, map) then return end
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
        wait()
    end
end

local function cleanupAnchoredParts()
    for _, part in ipairs(anchoredParts) do
        if part and part.Parent then -- 存在チェックとParentチェック
            -- 🔴 nilチェックを追加
            if part:FindFirstChild("BodyPosition") then
                part.BodyPosition:Destroy()
            end
            if part:FindFirstChild("BodyGyro") then
                part.BodyGyro:Destroy()
            end
            -- Highlightを探すロジックを改善
            local highlight = part:FindFirstChild("Highlight") 
            if not highlight and part.Parent and part.Parent:IsA("Model") then
                local primary = part.Parent.PrimaryPart
                if primary then
                    highlight = primary:FindFirstChild("Highlight")
                end
            end
            if highlight then
                highlight:Destroy()
            end
        end
    end

    cleanupConnections(anchoredConnections)
    anchoredParts = {}
end

local function updateBodyMovers(primaryPart)
    if not primaryPart or not primaryPart.Parent then return end -- primaryPartの存在チェック

    for _, group in ipairs(compiledGroups) do
        if group.primaryPart and group.primaryPart == primaryPart then
            for _, data in ipairs(group.group) do
                -- 🔴 data.partのnilチェック
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
    else
        OrionLib:MakeNotification({Name = "Success", Content = "Compiled "..#anchoredParts.." Toys together", Image = "rbxassetid://4483345998", Time = 5})
    end

    local primaryPart = anchoredParts[1]
    if not primaryPart or not primaryPart.Parent then return end -- primaryPartの存在チェック

    local highlight = primaryPart:FindFirstChild("Highlight")
    if not highlight and primaryPart.Parent and primaryPart.Parent:IsA("Model") then
        highlight = primaryPart.Parent:FindFirstChild("Highlight")
    end

    if not highlight then
        local targetParent = findFirstAncestorOfType(primaryPart, "Model") or primaryPart
        local highlightTarget = targetParent.PrimaryPart or targetParent
        if highlightTarget then
            highlight = createHighlight(highlightTarget)
        end
    end
    
    if highlight then
        highlight.OutlineColor = Color3.new(0, 1, 0) 
    end
    

    local group = {}
    for _, part in ipairs(anchoredParts) do
        if part and part.Parent and part ~= primaryPart then -- partの存在チェック
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
        if groupData.primaryPart and groupData.primaryPart.Parent then
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

            -- PrimaryPartのHighlightを削除
            local highlight = groupData.primaryPart:FindFirstChild("Highlight") 
            if not highlight and groupData.primaryPart.Parent and groupData.primaryPart.Parent:IsA("Model") then
                highlight = groupData.primaryPart.Parent:FindFirstChild("Highlight")
            end
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
    -- 🔴 コルーチンの状態チェックは、コルーチンの開始前に呼び出し元で行われているため、ここでは無限ループとnilチェックに集中する
    while true do
        pcall(function()
            for _, groupData in ipairs(compiledGroups) do
                -- 🔴 groupData.primaryPartのnilチェック
                if groupData.primaryPart then
                    updateBodyMovers(groupData.primaryPart)
                end
            end
        end)
        wait()
    end
end

local function unanchorPrimaryPart()
    local primaryPart = anchoredParts[1]
    if not primaryPart or not primaryPart.Parent then return end -- primaryPartの存在チェック
    
    if primaryPart:FindFirstChild("BodyPosition") then
        primaryPart.BodyPosition:Destroy()
    end
    if primaryPart:FindFirstChild("BodyGyro") then
        primaryPart.BodyGyro:Destroy()
    end
    
    -- Highlightを削除
    local highlight = primaryPart:FindFirstChild("Highlight") 
    if not highlight and primaryPart.Parent and primaryPart.Parent:IsA("Model") then
        highlight = primaryPart.Parent:FindFirstChild("Highlight")
    end
    if highlight then
        highlight:Destroy()
    end
end

local function recoverParts()
    -- 🔴 コルーチンの状態チェックは、コルーチンの開始前に呼び出し元で行われているため、ここでは無限ループとnilチェックに集中する
    while true do
        local success, err = pcall(function()
            local character = localPlayer.Character
            if character and character:FindFirstChild("Head") and character:FindFirstChild("HumanoidRootPart") then
                local head = character.Head
                local humanoidRootPart = character.HumanoidRootPart

                for _, partModel in pairs(anchoredParts) do
                    if not partModel or not partModel.Parent then continue end -- Partの存在チェック
                    
                    coroutine.wrap(function()
                        local distance = (partModel.Position - humanoidRootPart.Position).Magnitude
                        if distance <= 30 then
                            -- HighlightをprimaryPartまたはその親から探す
                            local highlight = partModel:FindFirstChild("Highlight")
                            if not highlight and partModel.Parent and partModel.Parent:IsA("Model") then
                                local primary = partModel.Parent.PrimaryPart
                                if primary then
                                    highlight = primary:FindFirstChild("Highlight")
                                end
                            end

                            if highlight and highlight.OutlineColor == Color3.new(1, 0, 0) then
                                SetNetworkOwner:FireServer(partModel, partModel.CFrame)
                                local partOwnerValue = partModel:WaitForChild("PartOwner", 0.5)
                                if partOwnerValue and partOwnerValue.Value == localPlayer.Name then
                                    highlight.OutlineColor = Color3.new(0, 0, 1)
                                    print("yoyoyo set and r eady")
                                end
                            end
                        end
                    end)()
                end
            end
        end)
        wait(0.02)
    end
end
local function ragdollAll()
    if not toysFolder then return end -- 😈 toysFolderチェック

    -- 🔴 コルーチンの状態チェックは、コルーチンの開始前に呼び出し元で行われているため、ここでは無限ループとnilチェックに集中する
    while true do
        local success, err = pcall(function()
            if not toysFolder:FindFirstChild("FoodBanana") then
                spawnItem("FoodBanana", Vector3.new(-72.9304581, -5.96906614, -265.543732))
            end
            local banana = toysFolder:WaitForChild("FoodBanana", 5)
            if not banana then return end -- bananaチェック
            
            local bananaPeel
            for _, part in pairs(banana:GetChildren()) do
                if part.Name == "BananaPeel" and part:FindFirstChild("TouchInterest") then
                    part.Size = Vector3.new(10, 10, 10)
                    part.Transparency = 1
                    bananaPeel = part
                    break
                end
            end
            
            if not bananaPeel then return end -- bananaPeelチェック
            
            local bodyPosition = Instance.new("BodyPosition")
            bodyPosition.P = 20000
            
            local bananaMain = banana:FindFirstChild("Main")
            if not bananaMain then return end -- MainPartチェック
            bodyPosition.Parent = bananaMain
            
            while true do
                for _, player in pairs(Players:GetChildren()) do
                    pcall(function()
                        -- 🔴 player.Characterのnilチェック
                        if player.Character and player.Character ~= localPlayer.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                            bananaPeel.Position = player.Character.HumanoidRootPart.Position or player.Character.Head.Position
                            
                            -- 🔴 localPlayer.Characterのnilチェック
                            if localPlayer.Character and localPlayer.Character:FindFirstChild("Head") then
                                bodyPosition.Position = localPlayer.Character.Head.Position + Vector3.new(0, 600, 0)
                            end
                            wait()
                        end
                    end)
                end   
                wait()
            end
        end)
        if not success then
            warn("Error in ragdollAll: " .. tostring(err))
        end
        wait()
    end
end

local function reloadMissile(bool)
    if not toysFolder then return end -- 😈 toysFolderチェック

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

        -- 🔴 コルーチンの開始前に既存のチェックを追加
        if reloadBombCoroutine and coroutine.status(reloadBombCoroutine) ~= "dead" then
            return -- 既に実行中または一時停止中
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
                            
                            local bodyPart = child:FindFirstChild("Body")
                            if not bodyPart then DestroyT(child); return end -- BodyPartチェック

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
                                -- 🔴 SetPrimaryPartCFrameの前にPrimaryPartのnilチェック
                                if child.PrimaryPart then
                                    child:SetPrimaryPartCFrame(CFrame.new(-72.9304581, -3.96906614, -265.543732))
                                end
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
                    -- 🔴 localPlayer.CanSpawnToyのnilチェック (ゲーム固有オブジェクトの存在確認)
                    if localPlayer:FindFirstChild("CanSpawnToy") and localPlayer.CanSpawnToy.Value and #bombList < _G.MaxMissiles and playerCharacter:FindFirstChild("Head") then
                        spawnItemCf(_G.ToyToLoad, playerCharacter.Head.CFrame or playerCharacter.HumanoidRootPart.CFrame)
                    end
                    RunService.Heartbeat:Wait()
                end
            end)
            coroutine.resume(reloadBombCoroutine)
        end
    else
        if reloadBombCoroutine then
            -- 🔴 coroutine.statusのチェックを追加
            if coroutine.status(reloadBombCoroutine) ~= "dead" then
                coroutine.close(reloadBombCoroutine)
            end
            reloadBombCoroutine = nil
        end
        if connectionBombReload then
            connectionBombReload:Disconnect()
            connectionBombReload = nil
        end
    end
end

-- 😈 ブロブマン自動スポーン/キャッシュ関数 (修正済み)
local function reloadBlobman(bool)
    if not toysFolder then return end -- 😈 toysFolderチェック

    if bool then
        if not ownedToys[_G.BlobmanToyName] then
            OrionLib:MakeNotification({
                Name = "Missing toy",
                Content = "You do not own the ".._G.BlobmanToyName.." toy.",
                Image = "rbxassetid://4483345998",
                Time = 3
            })
            return
        end
        
        -- 🔴 コルーチンの開始前に既存のチェックを追加
        if reloadBlobmanCoroutine and coroutine.status(reloadBlobmanCoroutine) ~= "dead" then
            return -- 既に実行中または一時停止中
        end

        if not reloadBlobmanCoroutine then
            reloadBlobmanCoroutine = coroutine.create(function()
                connectionBlobmanReload = toysFolder.ChildAdded:Connect(function(child)
                    if child.Name == _G.BlobmanToyName and child:WaitForChild("ThisToysNumber", 1) then
                        if child.ThisToysNumber.Value == (toysFolder.ToyNumber.Value - 1) then
                            local connection2
                            connection2 = toysFolder.ChildRemoved:Connect(function(child2)
                                if child2 == child then
                                    connection2:Disconnect()
                                end
                            end)

                            -- ブロブマンのBodyパーツを探してNetworkOwnerを設定する
                            local bodyPart = child:FindFirstChild("Body") or child.PrimaryPart
                            if not bodyPart then DestroyT(child); return end -- BodyPartチェック

                            SetNetworkOwner:FireServer(bodyPart, bodyPart.CFrame)
                            
                            local waiting = bodyPart and bodyPart:WaitForChild("PartOwner", 0.5)
                            
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
                                -- キャッシュ処理
                                for _, v in pairs(child:GetChildren()) do
                                    if v:IsA("BasePart") then
                                        v.CanCollide = false
                                    end
                                end
                                if child.PrimaryPart then
                                    child:SetPrimaryPartCFrame(CFrame.new(-72.9304581, -3.96906614, -265.543732)) -- 見えない位置に移動
                                end
                                wait(0.2)
                                for _, v in pairs(child:GetChildren()) do
                                    if v:IsA("BasePart") then
                                        v.Anchored = true -- アンカーして静止させる
                                    end
                                end
                                table.insert(blobmanList, child)
                                
                                -- 😈 オートシットのトリガー (スポーン時)
                                if AutoSitEnabled and playerCharacter and playerCharacter:FindFirstChildOfClass("Humanoid") then
                                    local VehicleSeat = child:FindFirstChild("VehicleSeat")
                                    if VehicleSeat and playerCharacter.Humanoid.SeatPart == nil then
                                        VehicleSeat:Sit(playerCharacter.Humanoid)
                                    end
                                end
                                
                                child.AncestryChanged:Connect(function()
                                    if not child.Parent then
                                        for i, blobmanItem in ipairs(blobmanList) do
                                            if blobmanItem == child then
                                                table.remove(blobmanList, i)
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
                    -- 🔴 localPlayer.CanSpawnToyのnilチェック
                    if localPlayer:FindFirstChild("CanSpawnToy") and localPlayer.CanSpawnToy.Value and #blobmanList < _G.MaxBlobmen and playerCharacter:FindFirstChild("Head") then
                        spawnItemCf(_G.BlobmanToyName, playerCharacter.Head.CFrame or playerCharacter.HumanoidRootPart.CFrame)
                    end
                    RunService.Heartbeat:Wait()
                end
            end)
            coroutine.resume(reloadBlobmanCoroutine)
        end
    else
        if reloadBlobmanCoroutine then
            -- 🔴 coroutine.statusのチェックを追加
            if coroutine.status(reloadBlobmanCoroutine) ~= "dead" then
                coroutine.close(reloadBlobmanCoroutine)
            end
            reloadBlobmanCoroutine = nil
        end
        if connectionBlobmanReload then
            connectionBlobmanReload:Disconnect()
            connectionBlobmanReload = nil
        end
    end
end
-- 😈 /ブロブマン自動スポーン/キャッシュ関数

local function setupAntiExplosion(character)
    -- 🔴 characterのnilチェック
    if not character then return end
    local humanoid = character:WaitForChild("Humanoid", 5)
    if not humanoid then return end -- Humanoidチェック

    local ragdolledValue = humanoid:FindFirstChild("Ragdolled")
    if ragdolledValue then
        local partOwnerChangedConn
        -- 🔴 Humanoid.Changedの代わりにGetPropertyChangedSignalを使用
        partOwnerChangedConn = ragdolledValue:GetPropertyChangedSignal("Value"):Connect(function()
            if ragdolledValue.Value then
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
local function blobGrabPlayer(player, blobman)
    -- 🔴 player, blobmanのnilチェック
    if not player or not blobman then return end
    if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then return end
    if not blobman.Parent then return end -- blobmanの存在チェック

    if blobalter == 1 then
        local leftDetector = blobman:FindFirstChild("LeftDetector")
        local leftWeld = leftDetector and leftDetector:FindFirstChild("LeftWeld")
        if leftDetector and leftWeld then
            local args = {
                [1] = leftDetector,
                [2] = player.Character:FindFirstChild("HumanoidRootPart"),
                [3] = leftWeld
            }
            local creatureGrab = blobman:WaitForChild("BlobmanSeatAndOwnerScript", 5) and blobman.BlobmanSeatAndOwnerScript:WaitForChild("CreatureGrab", 5)
            if creatureGrab then
                creatureGrab:FireServer(unpack(args))
            end
            blobalter = 2
        end
    else
        local rightDetector = blobman:FindFirstChild("RightDetector")
        local rightWeld = rightDetector and rightDetector:FindFirstChild("RightWeld")
        if rightDetector and rightWeld then
            local args = {
                [1] = rightDetector,
                [2] = player.Character:FindFirstChild("HumanoidRootPart"),
                [3] = rightWeld
            }
            local creatureGrab = blobman:WaitForChild("BlobmanSeatAndOwnerScript", 5) and blobman.BlobmanSeatAndOwnerScript:WaitForChild("CreatureGrab", 5)
            if creatureGrab then
                creatureGrab:FireServer(unpack(args))
            end
            blobalter = 1
        end
    end
end


local version = getVersion()

-- 🔴 nilチェックを追加
if not HttpService then warn("HttpService not available.") return end

local whitelistIdsStr, whitelistSuccess = pcall(function()
    return game:HttpGet("https://raw.githubusercontent.com/Undebolted/FTAP/main/WhitelistedUserId.txt")
end)

local whitelistIdsTbl = {}
if whitelistSuccess and whitelistIdsStr then
    pcall(function()
        whitelistIdsTbl = HttpService:JSONDecode(whitelistIdsStr)
    end)
end

local whitelistIds = {}
for id, _ in pairs(whitelistIdsTbl) do
    if tonumber(id) then
        table.insert(whitelistIds, tonumber(id))
        print(id)
    end
end

local isWhitelisted = false
for _, v in pairs(whitelistIds) do
    if v == localPlayer.UserId then
        isWhitelisted = true
        break
    end
end

local localVersion = "1-beta"
-- 😈 バージョンチェックロジックを一時的にコメントアウト (問題点4の修正)
-- ... [バージョンチェックとホワイトリストのロジックは省略] ...

local Window = OrionLib:MakeWindow({
-- ... [UI定義は省略] ...
})

local GrabTab = Window:MakeTab({Name = "グラブ", Icon =  "rbxassetid://18624615643", PremiumOnly = false})
-- ... [他のタブ定義は省略] ...
local DevTab = Window:MakeTab({Name = "デベロッパーテスト", Icon =  "rbxassetid://18624599762", PremiumOnly = false})


_G.strength = 400


GrabTab:AddSlider({
-- ... [強さスライダーの定義は省略] ...
})

GrabTab:AddToggle({
    Name = "強さ",
    Default = false,
    Color = Color3.fromRGB(240, 0, 0),
    Save = true,
    Flag = "強さトグル",
    Callback = function(enabled)
        if enabled then
            -- 🔴 コルーチンの開始前に既存のチェックを追加 (Heartbeatではないが、接続の重複チェックとして機能)
            if strengthConnection and strengthConnection.Connected then 
                strengthConnection:Disconnect()
            end

            strengthConnection = workspace.ChildAdded:Connect(function(model)
                if model.Name == "GrabParts" then
                    local grabPart = model:FindFirstChild("GrabPart")
                    if not grabPart then return end
                    
                    local weldConstraint = grabPart:FindFirstChild("WeldConstraint")
                    if not weldConstraint or not weldConstraint.Part1 then return end
                    
                    local partToImpulse = weldConstraint.Part1
                    
                    if partToImpulse then
                        local velocityObj = Instance.new("BodyVelocity", partToImpulse)
                        -- 🔴 modelのnilチェック
                        if model then
                            model:GetPropertyChangedSignal("Parent"):Connect(function()
                                if not model.Parent then
                                    if UserInputService:GetLastInputType() == Enum.UserInputType.MouseButton2 then
                                        velocityObj.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                                        velocityObj.Velocity = workspace.CurrentCamera.CFrame.LookVector * _G.strength
                                        Debris:AddItem(velocityObj, 1)
                                    else
                                        velocityObj:Destroy()
                                    end
                                end
                            end)
                        end
                    end
                end
            end)
        elseif strengthConnection then
            strengthConnection:Disconnect()
            strengthConnection = nil
        end
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
            -- 🔴 コルーチンの状態チェックを追加
            if not poisonGrabCoroutine or coroutine.status(poisonGrabCoroutine) == "dead" then
                poisonGrabCoroutine = coroutine.create(function() grabHandler("poison") end)
                coroutine.resume(poisonGrabCoroutine)
            end
        else
            if poisonGrabCoroutine and coroutine.status(poisonGrabCoroutine) ~= "dead" then
                -- 🔴 coroutine.statusが"dead"でない場合のみclose
                coroutine.close(poisonGrabCoroutine)
                poisonGrabCoroutine = nil
                for _, part in pairs(poisonHurtParts) do
                    -- 🔴 partのnilチェック
                    if part and part.Parent then
                        part.Position = Vector3.new(0, -200, 0)
                    end
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
            -- 🔴 コルーチンの状態チェックを追加
            if not ufoGrabCoroutine or coroutine.status(ufoGrabCoroutine) == "dead" then
                ufoGrabCoroutine = coroutine.create(function() grabHandler("radioactive") end)
                coroutine.resume(ufoGrabCoroutine)
            end
        else
            if ufoGrabCoroutine and coroutine.status(ufoGrabCoroutine) ~= "dead" then
                -- 🔴 coroutine.statusのチェックを追加
                coroutine.close(ufoGrabCoroutine)
                ufoGrabCoroutine = nil
                for _, part in pairs(paintPlayerParts) do
                    if part and part.Parent then
                        part.Position = Vector3.new(0, -200, 0)
                    end
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
            -- 🔴 コルーチンの状態チェックを追加
            if not fireGrabCoroutine or coroutine.status(fireGrabCoroutine) == "dead" then
                fireGrabCoroutine = coroutine.create(fireGrab)
                coroutine.resume(fireGrabCoroutine)
            end
        else
            if fireGrabCoroutine and coroutine.status(fireGrabCoroutine) ~= "dead" then
                -- 🔴 coroutine.statusのチェックを追加
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
            -- 🔴 コルーチンの状態チェックを追加
            if not noclipGrabCoroutine or coroutine.status(noclipGrabCoroutine) == "dead" then
                noclipGrabCoroutine = coroutine.create(noclipGrab)
                coroutine.resume(noclipGrabCoroutine)
            end
        else
            if noclipGrabCoroutine and coroutine.status(noclipGrabCoroutine) ~= "dead" then
                -- 🔴 coroutine.statusのチェックを追加
                coroutine.close(noclipGrabCoroutine)
                noclipGrabCoroutine = nil
            end
        end
    end
})

-- ... [Kick GrabのUI定義は省略] ...

GrabTab:AddToggle({
    Name = "キックグラブ固定 (使うにはキックグラブをオンにして)",
    Default = false,
    Save = true,
    Color = Color3.fromRGB(240, 0, 0),
    Flag = "AnchorKickGrab",
    Callback = function(enabled)
        if enabled then
            -- 🔴 コルーチンの状態チェックを追加
            if not anchorKickCoroutine or coroutine.status(anchorKickCoroutine) == "dead" then
                anchorKickCoroutine = coroutine.create(anchorKickGrab)
                coroutine.resume(anchorKickCoroutine)
            end
        else
            if anchorKickCoroutine and coroutine.status(anchorKickCoroutine) ~= "dead" then
                -- 🔴 coroutine.statusのチェックを追加
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
            -- 🔴 コルーチンの状態チェックを追加
            if not fireAllCoroutine or coroutine.status(fireAllCoroutine) == "dead" then
                fireAllCoroutine = coroutine.create(fireAll)
                coroutine.resume(fireAllCoroutine)
            end
        else
            if fireAllCoroutine and coroutine.status(fireAllCoroutine) ~= "dead" then
                -- 🔴 coroutine.statusのチェックを追加
                coroutine.close(fireAllCoroutine)
                fireAllCoroutine = nil
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
            -- 🔴 コルーチンの状態チェックを追加
            if not anchorGrabCoroutine or coroutine.status(anchorGrabCoroutine) == "dead" then
                anchorGrabCoroutine = coroutine.create(anchorGrab)
                coroutine.resume(anchorGrabCoroutine)
            end
        else
            if anchorGrabCoroutine and coroutine.status(anchorGrabCoroutine) ~= "dead" then
                -- 🔴 coroutine.statusのチェックを追加
                coroutine.close(anchorGrabCoroutine)
                anchorGrabCoroutine = nil
            end
        end
    end
})

ObjectGrabTab:AddParagraph("固んだオブジェクトを誰かが掴んだ場合もう一度掴み直す必要があります")

ObjectGrabTab:AddButton({
    Name = "全て解除",
    Callback = cleanupAnchoredParts
})

ObjectGrabTab:AddParagraph("(新機能)コンパイルしたら固めたオブジェクトを一つのオブジェクトとして扱うことができます")

ObjectGrabTab:AddButton({
    Name = "コンパイル",
    Callback = function()
        compileGroup()
        -- 🔴 コルーチンの状態チェックを追加
        if #anchoredParts > 0 and (not compileCoroutine or coroutine.status(compileCoroutine) == "dead") then
            compileCoroutine = coroutine.create(compileCoroutineFunc)
            coroutine.resume(compileCoroutine)
        end
    end
})

ObjectGrabTab:AddParagraph("固めたものを逆コンパイルします")

ObjectGrabTab:AddButton({
    Name = "Disassemble Parts",
    Callback = function()
        cleanupCompiledGroups()
        cleanupAnchoredParts()

        if compileCoroutine and coroutine.status(compileCoroutine) ~= "dead" then
            -- 🔴 coroutine.statusのチェックを追加
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
            -- 🔴 コルーチンの状態チェックを追加
            if not AutoRecoverDroppedPartsCoroutine or coroutine.status(AutoRecoverDroppedPartsCoroutine) == "dead" then
                AutoRecoverDroppedPartsCoroutine = coroutine.create(recoverParts)
                coroutine.resume(AutoRecoverDroppedPartsCoroutine)
            end
        else
            if AutoRecoverDroppedPartsCoroutine and coroutine.status(AutoRecoverDroppedPartsCoroutine) ~= "dead" then
                -- 🔴 coroutine.statusのチェックを追加
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
            -- 🔴 コルーチンの開始前に既存のチェックを追加
            if autoStruggleCoroutine and autoStruggleCoroutine.Connected then 
                autoStruggleCoroutine:Disconnect() 
            end

            autoStruggleCoroutine = RunService.Heartbeat:Connect(function()
                local character = localPlayer.Character
                if character and character:FindFirstChild("Head") then
                    local head = character.Head
                    local partOwner = head:FindFirstChild("PartOwner")
                    if partOwner then
                        Struggle:FireServer()
                        -- 🔴 ReplicatedStorage.GameCorrectionEventsのnilチェック
                        local stopVelocityRemote = ReplicatedStorage:FindFirstChild("GameCorrectionEvents") and ReplicatedStorage.GameCorrectionEvents:FindFirstChild("StopAllVelocity")
                        if stopVelocityRemote then
                            stopVelocityRemote:FireServer()
                        end

                        for _, part in pairs(character:GetChildren()) do
                            if part:IsA("BasePart") then
                                part.Anchored = true
                            end
                        end
                        -- 🔴 localPlayer.IsHeldの問題の修正
                        local isHeldValue = localPlayer:FindFirstChild("IsHeld")
                        while isHeldValue and isHeldValue:IsA("BoolValue") and isHeldValue.Value do
                            wait()
                        end
                        -- 🔴 IsHeldが見つからない/正しくない型の場合はすぐにループを抜ける
                        if not isHeldValue or not isHeldValue:IsA("BoolValue") then
                            -- 1秒待ってグラブが解除されたと見なす
                            task.wait(1) 
                        end
                        
                        for _, part in pairs(character:GetChildren()) do
                            if part:IsA("BasePart") then
                                part.Anchored = false
                            end
                        end
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
            -- 🔴 コルーチンの開始前に既存のチェックを追加
            if antiKickCoroutine and antiKickCoroutine.Connected then 
                antiKickCoroutine:Disconnect() 
            end

            antiKickCoroutine = RunService.Heartbeat:Connect(function()
                local character = localPlayer.Character
                if character and character:FindFirstChild("HumanoidRootPart") then
                    local fpp = character.HumanoidRootPart:FindFirstChild("FirePlayerPart")
                    if fpp then
                        local partOwner = fpp:FindFirstChild("PartOwner")
                        if partOwner and partOwner.Value ~= localPlayer.Name then
                            local args = {[1] = character.HumanoidRootPart, [2] = 0}
                            -- 🔴 ReplicatedStorageの子要素の存在確認
                            local ragdollRemote = ReplicatedStorage:WaitForChild("CharacterEvents", 1) and ReplicatedStorage.CharacterEvents:WaitForChild("RagdollRemote", 1)
                            if ragdollRemote then
                                ragdollRemote:FireServer(unpack(args))
                            end
                            print("grabbity shap!")
                            task.wait(0.1)
                            Struggle:FireServer()
                        end
                    end
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
        local localPlayer = game.Players.LocalPlayer

        if enabled then
            if localPlayer.Character then
                setupAntiExplosion(localPlayer.Character)
            end
            
            -- 🔴 characterAddedConnの定義と既存接続のチェック
            if characterAddedConn and characterAddedConn.Connected then
                characterAddedConn:Disconnect()
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
            -- 🔴 コルーチンの状態チェックを追加
            if not autoDefendCoroutine or coroutine.status(autoDefendCoroutine) == "dead" then
                autoDefendCoroutine = coroutine.create(function()
                    -- 🔴 無限ループの条件を修正
                    while enabled do
                        local character = localPlayer.Character
                        if character and character:FindFirstChild("Head") then
                            local head = character.Head
                            local partOwner = head:FindFirstChild("PartOwner")
                            if partOwner then
                                local attacker = Players:FindFirstChild(partOwner.Value)
                                -- 🔴 attacker.Characterのnilチェック
                                if attacker and attacker.Character and attacker.Character:FindFirstChild("HumanoidRootPart") then
                                    Struggle:FireServer()
                                    local attackerFPP = attacker.Character.HumanoidRootPart:FindFirstChild("FirePlayerPart")
                                    
                                    -- 🔴 SetNetworkOwnerの前に attacker.Character.Head/Torsoのnilチェック
                                    local targetPart = attacker.Character:FindFirstChild("Head") or attacker.Character:FindFirstChild("Torso")
                                    if attackerFPP and targetPart then
                                        SetNetworkOwner:FireServer(targetPart, attackerFPP.CFrame)
                                    end
                                    
                                    task.wait(0.1)
                                    local torso = attacker.Character:FindFirstChild("Torso")
                                    if torso then
                                        local velocity = torso:FindFirstChild("l") or Instance.new("BodyVelocity")
                                        velocity.Name = "l"
                                        velocity.Parent = torso
                                        velocity.Velocity = Vector3.new(0, 50, 0)
                                        velocity.MaxForce = Vector3.new(0, math.huge, 0)
                                        Debris:AddItem(velocity, 100)
                                    end
                                end
                            end
                        end
                        wait(0.02)
                    end
                end)
                coroutine.resume(autoDefendCoroutine)
            end
        else
            if autoDefendCoroutine and coroutine.status(autoDefendCoroutine) ~= "dead" then
                -- 🔴 coroutine.statusのチェックを追加
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
            -- 🔴 コルーチンの状態チェックを追加
            if not autoDefendKickCoroutine or coroutine.status(autoDefendKickCoroutine) == "dead" then
                autoDefendKickCoroutine = coroutine.create(function()
                    -- 🔴 無限ループの条件を修正
                    while enabled do
                        local character = localPlayer.Character
                        if character and character:FindFirstChild("HumanoidRootPart") then
                            local humanoidRootPart = character.HumanoidRootPart
                            local head = character:FindFirstChild("Head")
                            if head then
                                local partOwner = head:FindFirstChild("PartOwner")
                                if partOwner then
                                    local attacker = Players:FindFirstChild(partOwner.Value)
                                    -- 🔴 attacker.Characterのnilチェック
                                    if attacker and attacker.Character and attacker.Character:FindFirstChild("HumanoidRootPart") then
                                        Struggle:FireServer()
                                        local attackerFPP = attacker.Character.HumanoidRootPart:FindFirstChild("FirePlayerPart")
                                        if attackerFPP then
                                            SetNetworkOwner:FireServer(attackerFPP, attackerFPP.CFrame)
                                            task.wait(0.1)
                                            if not attackerFPP:FindFirstChild("BodyVelocity") then
                                                local bodyVelocity = Instance.new("BodyVelocity")
                                                bodyVelocity.Name = "BodyVelocity"
                                                bodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                                                bodyVelocity.Velocity = Vector3.new(0, 20, 0)
                                                bodyVelocity.Parent = attackerFPP
                                            end
                                        end
                                    end
                                end
                            end
                        end
                        wait(0.02)
                    end
                end)
                coroutine.resume(autoDefendKickCoroutine)
            end
        else
            if autoDefendKickCoroutine and coroutine.status(autoDefendKickCoroutine) ~= "dead" then
                -- 🔴 coroutine.statusのチェックを追加
                coroutine.close(autoDefendKickCoroutine)
                autoDefendKickCoroutine = nil
            end
        end
    end
})
local yeetMode = false

local function blobGrabPlayerYeet(player, blobman)
    -- 🔴 player, blobmanのnilチェック
    if not player or not blobman then return end
    if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then
        return
    end
    if not blobman.Parent then return end -- blobmanの存在チェック
    
    local detector, weld
    if blobalter == 1 then
        detector = blobman:FindFirstChild("LeftDetector")
        weld = detector and detector:FindFirstChild("LeftWeld")
        blobalter = 2
    else
        detector = blobman:FindFirstChild("RightDetector")
        weld = detector and detector:FindFirstChild("RightWeld")
        blobalter = 1
    end
    
    if not detector or not weld then return end
    
    local args = {
        [1] = detector,
        [2] = player.Character.HumanoidRootPart,
        [3] = weld
    }
    -- 🔴 BlobmanSeatAndOwnerScriptの子要素の存在確認
    local scriptContainer = blobman:WaitForChild("BlobmanSeatAndOwnerScript", 1)
    local creatureGrab = scriptContainer and scriptContainer:WaitForChild("CreatureGrab", 1)
    if creatureGrab then
        creatureGrab:FireServer(unpack(args))
    end
    
    if yeetMode then
        wait(0.05)
        local releaseArgs = {
            [1] = detector,
            [2] = player.Character.HumanoidRootPart,
            [3] = weld
        }
        if creatureGrab then
            creatureGrab:FireServer(unpack(releaseArgs))
        end
    end
end

local blobman1
blobman1 = BlobmanTab:AddToggle({
    Name = "ループグラブオール",
    Color = Color3.fromRGB(240, 0, 0),
    Default = false,
    Callback = function(enabled)
        if enabled then
            print("Toggle enabled")
            -- 🔴 コルーチンの状態チェックを追加
            if not blobmanCoroutine or coroutine.status(blobmanCoroutine) == "dead" then
                blobmanCoroutine = coroutine.create(function()
                    local foundBlobman = false
                    
                    -- キャッシュされたブロブマンリストから探す
                    local currentBlobman = nil
                    for _, b in ipairs(blobmanList) do
                        local seat = b:FindFirstChild("VehicleSeat")
                        -- 🔴 seat.Occupantのnilチェック
                        if seat and seat.Occupant and seat.Occupant.Parent and isDescendantOf(seat.Occupant.Parent, localPlayer.Character) then
                            currentBlobman = b
                            foundBlobman = true
                            break
                        end
                    end
                    
                    -- もし自動スポーンがオフなら、ワークスペース全体から探す
                    if not foundBlobman then
                        for i, v in pairs(game.Workspace:GetDescendants()) do
                            if v.Name == "CreatureBlobman" then
                                local seat = v:FindFirstChild("VehicleSeat")
                                -- 🔴 seat.Occupantのnilチェック
                                if seat and seat.Occupant and seat.Occupant.Parent and isDescendantOf(seat.Occupant.Parent, localPlayer.Character) then
                                    currentBlobman = v
                                    foundBlobman = true
                                    break
                                end
                            end
                        end
                    end
                    
                    blobman = currentBlobman -- グローバル変数に設定
                    
                    if not foundBlobman then
                        print("No mount found")
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

                    while true do
                        pcall(function()
                            for i, v in pairs(Players:GetChildren()) do
                                if blobman and v ~= localPlayer then
                                    blobGrabPlayerYeet(v, blobman)
                                    print(v.Name)
                                    wait(_G.BlobmanDelay)
                                end
                            end
                        end)
                        wait(0.02)
                    end
                end)
                coroutine.resume(blobmanCoroutine)
            end
        else
            if blobmanCoroutine and coroutine.status(blobmanCoroutine) ~= "dead" then
                -- 🔴 coroutine.statusのチェックを追加
                coroutine.close(blobmanCoroutine)
                blobmanCoroutine = nil
                blobman = nil
            end
        end
    end
})

-- ... [ブロブマンタブのUI定義は省略] ...

AuraTab:AddLabel("オーラ")

-- ... [距離スライダーのUI定義は省略] ...

AuraTab:AddToggle({
    Name = "エアサスペンドオーラ",
    Color = Color3.fromRGB(240, 0, 0),
    Default = false,
    Save = true,
    Callback = function(enabled)
        if enabled then
            -- 🔴 コルーチンの状態チェックを追加
            if not auraCoroutine or coroutine.status(auraCoroutine) == "dead" then
                auraCoroutine = coroutine.create(function()
                    -- 🔴 無限ループの条件を修正
                    while enabled do
                        local success, err = pcall(function()
                            local character = localPlayer.Character
                            if character and character:FindFirstChild("Head") and character:FindFirstChild("HumanoidRootPart") then
                                local head = character.Head
                                local humanoidRootPart = character.HumanoidRootPart

                                for _, player in pairs(Players:GetPlayers()) do
                                    if player ~= localPlayer and player.Character then
                                        local playerCharacter = player.Character
                                        local playerTorso = playerCharacter:FindFirstChild("Torso")
                                        if playerTorso and playerCharacter:FindFirstChild("HumanoidRootPart") then
                                            local distance = (playerTorso.Position - humanoidRootPart.Position).Magnitude
                                            if distance <= auraRadius then
                                                local attackerFPP = playerCharacter.HumanoidRootPart:FindFirstChild("FirePlayerPart")
                                                if attackerFPP then
                                                    SetNetworkOwner:FireServer(playerTorso, attackerFPP.CFrame)
                                                    task.wait(0.1)
                                                    local velocity = playerTorso:FindFirstChild("l") or Instance.new("BodyVelocity", playerTorso)
                                                    velocity.Name = "l"
                                                    velocity.Velocity = Vector3.new(0, 50, 0)
                                                    velocity.MaxForce = Vector3.new(0, math.huge, 0)
                                                    Debris:AddItem(velocity, 100)
                                                end
                                            end
                                        end
                                    end
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
            if auraCoroutine and coroutine.status(auraCoroutine) ~= "dead" then
                -- 🔴 coroutine.statusのチェックを追加
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
            -- 🔴 コルーチンの状態チェックを追加
            if not gravityCoroutine or coroutine.status(gravityCoroutine) == "dead" then
                gravityCoroutine = coroutine.create(function()
                    -- 🔴 無限ループの条件を修正
                    while enabled do
                        local success, err = pcall(function()
                            local character = localPlayer.Character
                            if character and character:FindFirstChild("HumanoidRootPart") then
                                local humanoidRootPart = character.HumanoidRootPart

                                for _, player in pairs(Players:GetPlayers()) do
                                    if player ~= localPlayer and player.Character then
                                        local playerCharacter = player.Character
                                        local playerTorso = playerCharacter:FindFirstChild("Torso")
                                        if playerTorso and playerCharacter:FindFirstChild("HumanoidRootPart") then
                                            local distance = (playerTorso.Position - humanoidRootPart.Position).Magnitude
                                            if distance <= auraRadius then
                                                local attackerFPP = humanoidRootPart:FindFirstChild("FirePlayerPart")
                                                if attackerFPP then
                                                    SetNetworkOwner:FireServer(playerTorso, attackerFPP.CFrame)
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
                                                end
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
        elseif gravityCoroutine and coroutine.status(gravityCoroutine) ~= "dead" then
            -- 🔴 coroutine.statusのチェックを追加
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
        if auraToggle == 1 then
            if enabled then
                -- 🔴 コルーチンの状態チェックを追加
                if not kickCoroutine or coroutine.status(kickCoroutine) == "dead" then
                    kickCoroutine = coroutine.create(function()
                        -- 🔴 無限ループの条件を修正
                        while enabled do
                            local success, err = pcall(function()
                                local character = localPlayer.Character
                                if character and character:FindFirstChild("HumanoidRootPart") then
                                    local humanoidRootPart = character.HumanoidRootPart

                                    for _, player in pairs(Players:GetPlayers()) do
                                        if player ~= localPlayer and player.Character then
                                            local playerCharacter = player.Character
                                            local playerTorso = playerCharacter:FindFirstChild("Head")

                                            if playerTorso and playerCharacter:FindFirstChild("HumanoidRootPart") then
                                                local distance = (playerTorso.Position - humanoidRootPart.Position).Magnitude
                                                if distance <= auraRadius then
                                                    local fpp = playerCharacter.HumanoidRootPart:FindFirstChild("FirePlayerPart")
                                                    if fpp then
                                                        SetNetworkOwner:FireServer(fpp, fpp.CFrame)
                                                    end
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
                                        -- 🔴 player.Characterのnilチェック
                                        if player.Character and player.Character.Humanoid and player.Character.Humanoid.Health > 1 then
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
                                warn("Error in Kick Aura: " .. tostring(err))
                            end
                            wait(0.02)
                        end
                    end)
                    coroutine.resume(kickCoroutine)
                end
            elseif kickCoroutine and coroutine.status(kickCoroutine) ~= "dead" then
                -- 🔴 coroutine.statusのチェックを追加
                coroutine.close(kickCoroutine)
                kickCoroutine = nil
                for _, platform in pairs(platforms) do
                    if platform then
                        platform:Destroy()
                    end
                end
                platforms = {}
            end
        elseif auraToggle == 2 then
            if enabled then
                -- 🔴 コルーチンの状態チェックを追加
                if not kickCoroutine or coroutine.status(kickCoroutine) == "dead" then
                    kickCoroutine = coroutine.create(function()
                        -- 🔴 無限ループの条件を修正
                        while enabled do
                            local success, err = pcall(function()
                                local character = localPlayer.Character
                                if character and character:FindFirstChild("HumanoidRootPart") then
                                    local humanoidRootPart = character.HumanoidRootPart

                                    for _, player in pairs(Players:GetPlayers()) do
                                        if player ~= localPlayer and player.Character then
                                            local playerCharacter = player.Character
                                            local playerTorso = playerCharacter:FindFirstChild("Head")

                                            if playerTorso and playerCharacter:FindFirstChild("HumanoidRootPart") then
                                                local distance = (playerTorso.Position - humanoidRootPart.Position).Magnitude
                                                if distance <= auraRadius then
                                                    local fpp = playerCharacter.HumanoidRootPart:FindFirstChild("FirePlayerPart")
                                                    if fpp then
                                                        SetNetworkOwner:FireServer(fpp, fpp.CFrame)
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
                            end)
                            if not success then
                                warn("Error in Kick Aura (Sky mode): " .. tostring(err))
                            end
                            wait(0.02)
                        end
                    end)
                    coroutine.resume(kickCoroutine)
                end
            else
                if kickCoroutine and coroutine.status(kickCoroutine) ~= "dead" then
                    -- 🔴 coroutine.statusのチェックを追加
                    coroutine.close(kickCoroutine)
                    kickCoroutine = nil
                end
            end
        end
    end
})

-- ... [キックの種類のUI定義は省略] ...

AuraTab:AddToggle({
    Name = "放射線オーラ",
    Default = false,
    Color = Color3.fromRGB(240, 0, 0),
    Save = true,
    Callback = function(enabled)
        if enabled then
            -- 🔴 コルーチンの状態チェックを追加
            if not poisonAuraCoroutine or coroutine.status(poisonAuraCoroutine) == "dead" then
                poisonAuraCoroutine = coroutine.create(function()
                    -- 🔴 無限ループの条件を修正
                    while enabled do
                        local success, err = pcall(function()
                            local character = localPlayer.Character
                            if character and character:FindFirstChild("HumanoidRootPart") then
                                local humanoidRootPart = character.HumanoidRootPart

                                for _, player in pairs(Players:GetPlayers()) do
                                    if player ~= localPlayer and player.Character then
                                        local playerCharacter = player.Character
                                        local playerTorso = playerCharacter:FindFirstChild("Torso")
                                        if playerTorso and playerCharacter:FindFirstChild("HumanoidRootPart") then
                                            local distance = (playerTorso.Position - humanoidRootPart.Position).Magnitude
                                            if distance <= auraRadius then
                                                local head = playerCharacter:FindFirstChild("Head")
                                                -- 🔴 whileループの条件を修正 (distanceの更新があることを確認)
                                                while head and playerTorso and humanoidRootPart and (playerTorso.Position - humanoidRootPart.Position).Magnitude <= auraRadius do
                                                    SetNetworkOwner:FireServer(playerTorso, playerCharacter.HumanoidRootPart.CFrame)
                                                    
                                                    -- distanceの再計算
                                                    distance = (playerTorso.Position - humanoidRootPart.Position).Magnitude
                                                    
                                                    -- 🔴 Headのnilチェック
                                                    if head then
                                                        for _, part in pairs(poisonHurtParts) do
                                                            -- 🔴 partのnilチェック
                                                            if part and part.Parent then
                                                                part.Size = Vector3.new(1, 3, 1)
                                                                part.Transparency = 1
                                                                part.Position = head.Position
                                                            end
                                                        end
                                                    end
                                                    wait()
                                                    for _, part in pairs(poisonHurtParts) do
                                                        if part and part.Parent then
                                                            part.Position = Vector3.new(0, -200, 0)
                                                        end
                                                    end
                                                end
                                                for _, part in pairs(poisonHurtParts) do
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
                        if not success then
                            warn("Error in Poison Aura: " .. tostring(err))
                        end
                        wait(0.02)
                    end
                end)
                coroutine.resume(poisonAuraCoroutine)
            end
        elseif poisonAuraCoroutine and coroutine.status(poisonAuraCoroutine) ~= "dead" then
            -- 🔴 coroutine.statusのチェックを追加
            coroutine.close(poisonAuraCoroutine)
            for _, part in pairs(poisonHurtParts) do
                if part and part.Parent then
                    part.Position = Vector3.new(0, -200, 0)
                end
            end
            poisonAuraCoroutine = nil
        end
    end
})

-- ... [CharacterTabのUI定義は省略] ...
-- ... [FunTabのUI定義は省略] ...
-- ... [ScriptTabのUI定義は省略] ...
-- ... [KeybindsTabのUI定義は省略] ...
-- ... [ExplosionTabのUI定義は省略] ...

DevTab:AddLabel("バナナの皮だけにしてください")

DevTab:AddToggle({
    Name = "ラグドールオール",
    Color = Color3.fromRGB(240, 0, 0),
    Default = false,
    Save = true,
    Callback = function(enabled)
        if enabled then
            -- 🔴 コルーチンの状態チェックを追加
            if not ragdollAllCoroutine or coroutine.status(ragdollAllCoroutine) == "dead" then
                ragdollAllCoroutine = coroutine.create(ragdollAll)
                coroutine.resume(ragdollAllCoroutine)
            end
        else
            if ragdollAllCoroutine and coroutine.status(ragdollAllCoroutine) ~= "dead" then
                -- 🔴 coroutine.statusのチェックを追加
                coroutine.close(ragdollAllCoroutine)
                ragdollAllCoroutine = nil
            end
        end
    end
})

-- 😈 自動着席ロジックをHeartbeatから切り離す (修正済み)
-- 🔴 致命的な問題1: characterAddedConnの修正エラー
-- 🔴 `character.Humanoid.Changed`を`character.Humanoid:GetPropertyChangedSignal("SeatPart")`に修正
localPlayer.CharacterAdded:Connect(function(character)
    -- 🔴 characterのnilチェック
    if not character then return end
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if humanoid then
        humanoid:GetPropertyChangedSignal("SeatPart"):Connect(function() -- 修正
            -- SeatPartがnilになった（降りた）時
            if humanoid.SeatPart == nil and AutoSitEnabled then
                task.wait(0.1) -- 処理待ちのため少し待つ
                
                -- ブロブマンを探す (特にキャッシュリストから)
                local targetBlobman = nil
                for _, b in ipairs(blobmanList) do
                    local seat = b and b:FindFirstChild("VehicleSeat")
                    if seat then
                        targetBlobman = b
                        break
                    end
                end
                
                -- キャッシュになければ、ワークスペースから探す（これは最後の手段でラグの原因になりうる）
                if not targetBlobman then
                    for _, v in pairs(game.Workspace:GetDescendants()) do
                        if v.Name == _G.BlobmanToyName and v:FindFirstChild("VehicleSeat") then
                            targetBlobman = v
                            break
                        end
                    end
                end

                -- 見つかったブロブマンに座る
                if targetBlobman and character:FindFirstChildOfClass("Humanoid") then
                    local VehicleSeat = targetBlobman:FindFirstChild("VehicleSeat")
                    if VehicleSeat and humanoid.SeatPart == nil then
                        VehicleSeat:Sit(humanoid)
                    end
                end
            end
        end)
    end
end)
-- /自動着席ロジックをHeartbeatから切り離す


OrionLib:MakeNotification({Name = "Welcome", Content = "ようこそ、野獣のおちんちんハブへ", Image = "rbxassetid://4483345998", Time = 5})
OrionLib:Init()
