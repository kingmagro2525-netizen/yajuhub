local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")

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

local AutoRecoverDroppedPartsCoroutine
local connectionBombReload
local reloadBombCoroutine -- 😈 1回目
local antiExplosionConnection
local poisonAuraCoroutine
local deathAuraCoroutine
-- local reloadBombCoroutine -- 😈 2回目 (削除)
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
local NoclipToggleConnection -- 😈 Noclip接続用変数
local NoclipToggleEnabled = false -- 😈 Noclipトグルの状態変数
local characterAddedConn -- 😈 欠けていた変数宣言
local autoDefendKickCoroutine -- 😈 欠けていた変数宣言
local anchorKickCoroutine -- 😈 欠けていた変数宣言


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

-- 😈 toysFolderの安全な初期化 (問題点2の修正)
local toysFolder = workspace:WaitForChild(localPlayer.Name.."SpawnedInToys", 5)
if not toysFolder then
    warn("Failed to find toysFolder. Script will be limited.")
    -- 😈 スクリプトをクラッシュさせる代わりに警告を出し、一部機能を制限する
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


local function DestroyT(toy)
    local toy = toy or (toysFolder and toysFolder:FindFirstChildWhichIsA("Model"))
    if toy then
        DestroyToy:FireServer(toy)
    end
end


local function getDescendantParts(descendantName)
    local parts = {}
    -- workspace.Mapの存在チェック
    local map = workspace:FindFirstChild("Map")
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
    local menuGui = localPlayer:WaitForChild("PlayerGui"):WaitForChild("MenuGui"):WaitForChild("Menu"):WaitForChild("TabContents"):WaitForChild("Toys"):WaitForChild("Contents")
    for _, v in pairs(menuGui:GetChildren()) do
        if v.Name ~= "UIGridLayout" then
            ownedToys[v.Name] = true
        end
    end
end)
if not success then
    warn("Failed to initialize ownedToys: " .. tostring(result))
    -- ownedToysが空のままになるが、クラッシュはしない
end
-- /ownedToysの初期化にエラーハンドリング追加

local function getNearestPlayer()
    local nearestPlayer
    local nearestDistance = math.huge

    for _, player in pairs(Players:GetPlayers()) do
        -- 😈 playerCharacterの存在チェックを追加
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
    for _, connection in ipairs(connectionTable) do
        if connection and connection.Connected then -- 接続の有効性を確認
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
        local data = HttpService:JSONDecode(response)
        return data.version
    else
        warn("Failed to get version: " .. response)
        return "Unknown"
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
    if not toysFolder then return end -- 😈 toysFolderチェック

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
    local characterAddedConnection = player.CharacterAdded:Connect(function(character)
        local hrp = character:WaitForChild("HumanoidRootPart")
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
                if not grabPart then return end -- grabPartチェック
                
                local weldConstraint = grabPart:FindFirstChild("WeldConstraint")
                if not weldConstraint or not weldConstraint.Part1 then return end -- weldConstraint/Part1チェック
                
                local grabbedPart = weldConstraint.Part1
                local character = grabbedPart.Parent -- Part1の親をキャラクターと想定
                local head = character:FindFirstChild("Head") -- キャラクターの子のHeadを探す
                
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
        end)
        wait()
    end
end

local function fireGrab()
    while true do
        local success, err = pcall(function()
            local child = workspace:FindFirstChild("GrabParts")
            if child and child.Name == "GrabParts" then
                local grabPart = child:FindFirstChild("GrabPart")
                if not grabPart then return end
                
                local weldConstraint = grabPart:FindFirstChild("WeldConstraint")
                if not weldConstraint or not weldConstraint.Part1 then return end
                
                local grabbedPart = weldConstraint.Part1
                local character = grabbedPart.Parent
                local head = character:FindFirstChild("Head")
                
                if head and toysFolder then -- 😈 toysFolderチェック
                    arson(head)
                end
            end
        end)
        wait()
    end
end

local function noclipGrab()
    while true do
        local success, err = pcall(function()
            local child = workspace:FindFirstChild("GrabParts")
            if child and child.Name == "GrabParts" then
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
            end
        end)
        wait()
    end
end

-- 😈 Noclip トグル機能の実装
local function togglePlayerNoclip(enabled)
    NoclipToggleEnabled = enabled
    if enabled then
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
        local rotation = Vector3.new(0, 0, 0)
        ReplicatedStorage.MenuToys.SpawnToyRemoteFunction:InvokeServer(itemName, cframe, rotation)
    end)
end

local function fireAll()
    if not toysFolder then return end -- 😈 toysFolderチェック

    while true do
        local success, err = pcall(function()
            if toysFolder:FindFirstChild("Campfire") then
                DestroyT(toysFolder:FindFirstChild("Campfire"))
                wait(0.5)
            end
            spawnItemCf("Campfire", playerCharacter.Head.CFrame)
            
            local campfire = toysFolder:WaitForChild("Campfire", 5)
            if not campfire then return end -- campfireがスポーンしなかった場合のチェック
            
            local firePlayerPart
            for _, part in pairs(campfire:GetChildren()) do
                if part.Name == "FirePlayerPart" then
                    part.Size = Vector3.new(10, 10, 10)
                    firePlayerPart = part
                    break
                end
            end
            
            if not firePlayerPart then return end -- firePlayerPartチェック
            
            local originalPosition = playerCharacter.Torso.Position
            SetNetworkOwner:FireServer(firePlayerPart, firePlayerPart.CFrame)
            playerCharacter:MoveTo(firePlayerPart.Position)
            wait(0.3)
            playerCharacter:MoveTo(originalPosition)
            
            local bodyPosition = Instance.new("BodyPosition")
            bodyPosition.P = 20000
            bodyPosition.Position = playerCharacter.Head.Position + Vector3.new(0, 600, 0)
            
            local campfireMain = campfire:FindFirstChild("Main")
            if not campfireMain then return end -- MainPartチェック
            bodyPosition.Parent = campfireMain
            
            while true do
                for _, player in pairs(Players:GetChildren()) do
                    pcall(function()
                        bodyPosition.Position = playerCharacter.Head.Position + Vector3.new(0, 600, 0)
                        if player.Character and player.Character.HumanoidRootPart and player.Character ~= playerCharacter then
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

            if isDescendantOf(primaryPart, workspace:FindFirstChild("Map")) then return end -- Mapチェック
            
            local isCharacterPart = false
            for _, player in pairs(Players:GetChildren()) do
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
                local connection = target.DescendantAdded:Connect(function(descendant)
                    onPartOwnerAdded(descendant, primaryPart)
                end)
                table.insert(anchoredConnections, connection)
            end

            if modelAncestor and modelAncestor ~= workspace then 
                for _, child in ipairs(modelAncestor:GetDescendants()) do
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
        wait()
    end
end

local function anchorKickGrab()
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

            if isDescendantOf(primaryPart, workspace:FindFirstChild("Map")) then return end -- Mapチェック
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
    while true do
        pcall(function()
            for _, groupData in ipairs(compiledGroups) do
                updateBodyMovers(groupData.primaryPart)
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
                        if player.Character and player.Character ~= localPlayer.Character and player.Character.HumanoidRootPart then
                            bananaPeel.Position = player.Character.HumanoidRootPart.Position or player.Character.Head.Position
                            bodyPosition.Position = localPlayer.Character.Head.Position + Vector3.new(0, 600, 0)
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
                                if AutoSitEnabled then
                                    local VehicleSeat = child:FindFirstChild("VehicleSeat")
                                    if VehicleSeat and playerCharacter and playerCharacter.Humanoid and playerCharacter.Humanoid.SeatPart == nil then
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
                    -- 最大数より少なければスポーン
                    if localPlayer.CanSpawnToy and localPlayer.CanSpawnToy.Value and #blobmanList < _G.MaxBlobmen and playerCharacter:FindFirstChild("Head") then
                        spawnItemCf(_G.BlobmanToyName, playerCharacter.Head.CFrame or playerCharacter.HumanoidRootPart.CFrame)
                    end
                    RunService.Heartbeat:Wait()
                end
            end)
            coroutine.resume(reloadBlobmanCoroutine)
        end
    else
        if reloadBlobmanCoroutine then
            coroutine.close(reloadBlobmanCoroutine)
            reloadBlobmanCoroutine = nil
        end
        if connectionBlobmanReload then
            connectionBlobmanReload:Disconnect()
        end
    end
end
-- 😈 /ブロブマン自動スポーン/キャッシュ関数

local function setupAntiExplosion(character)
    local humanoid = character:WaitForChild("Humanoid", 5)
    if not humanoid then return end -- Humanoidチェック

    local partOwner = humanoid:FindFirstChild("Ragdolled")
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
local function blobGrabPlayer(player, blobman)
    if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then return end
    if not blobman or not blobman.Parent then return end -- blobmanの存在チェック

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

local whitelistIdsStr = game:HttpGet("https://raw.githubusercontent.com/Undebolted/FTAP/main/WhitelistedUserId.txt")
local whitelistIdsTbl = HttpService:JSONDecode(whitelistIdsStr)
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
-- if localVersion ~= version then

-- OrionLib:MakeNotification({Name = "スクリプトバージョンが違います!", Content = "あなたは野獣のおちんちんハブの古いバージョンを使っているため開けません", Image = "rbxassetid:// 4483345998", Time = 8})    
--     setclipboard('loadstring(game:HttpGet("https://raw.githubusercontent.com/Undebolted/FTAP/main/Script.lua",true))()')
--     wait(12)
--     OrionLib:Destroy()
--     wait(9e9)
-- end

-- if isWhitelisted then
--     OrionLib:MakeNotification({Name = "You're whitelisted!", Content = "Enjoy your stay! (https://discord.gg/Ga8GnkDdrh)", Image = "rbxassetid://4483345998", Time = 5})
-- else
--     OrionLib:MakeNotification({Name = "You're not whitelisted!", Content = "Please purchase the script in our discord server! Invite has been copied (https://discord.gg/Ga8GnkDdrh)", Image = "rbxassetid://4483345998", Time = 8})
--     setclipboard('https://discord.gg/Ga8GnkDdrh')
--     wait(12)
--     OrionLib:Destroy()
--     wait(9e9)
-- end

local Window = OrionLib:MakeWindow({
    Name = "野獣のおちんちんハブ" .. version, 
    HidePremium = false, 
    SaveConfig = true, 
    ConfigFolder = "野獣のおちんちんハブ", 
    IntroEnabled = true, 
    IntroText = "野獣のおちんちんハブ" ..version, 
    IntroIcon = "https://ibb.co/NgBCXdB6", 
    Icon = "https://ibb.co/NgBCXdB6"
})

local GrabTab = Window:MakeTab({Name = "グラブ", Icon =  "rbxassetid://18624615643", PremiumOnly = false})

local ObjectGrabTab = Window:MakeTab({Name = "オブジェクトグラブ", Icon =  "rbxassetid://18624606749", PremiumOnly = false})
local DefenseTab = Window:MakeTab({Name = "ディフェンス", Icon =  "rbxassetid://18624604880", PremiumOnly = false})
local BlobmanTab = Window:MakeTab({Name = "ブロブマン", Icon =  "rbxassetid://18624614127", PremiumOnly = false})
local FunTab = Window:MakeTab({Name = "楽しい", Icon =  "rbxassetid://18624603093", PremiumOnly = false})
local ScriptTab = Window:MakeTab({Name = "他スクリプト", Icon =  "rbxassetid://11570626783", PremiumOnly = false})
local AuraTab = Window:MakeTab({Name = "オーラ", Icon =  "rbxassetid://18624608005", PremiumOnly = false})
local CharacterTab = Window:MakeTab({Name = "キャラクター", Icon =  "rbxassetid://18624601543", PremiumOnly = false})
local ExplosionTab = Window:MakeTab({Name = "爆弾", Icon =  "rbxassetid://18624610285", PremiumOnly = false})
local KeybindsTab = Window:MakeTab({Name = "キービエンス", Icon =  "rbxassetid://18624616682", PremiumOnly = false})
local DevTab = Window:MakeTab({Name = "デベロッパーテスト", Icon =  "rbxassetid://18624599762", PremiumOnly = false})



_G.strength = 400


GrabTab:AddSlider({
    Name = "強さ",
    Min = 300,
    Max = 4000,
    Color = Color3.fromRGB(240, 0, 0),
    ValueName = ".",
    Increment = 1,
    Default = _G.strength,
    Save = true,
    Flag = "強さスライダー",
    Callback = function(value)
        _G.strength = value
    end
})

GrabTab:AddToggle({
    Name = "強さ",
    Default = false,
    Color = Color3.fromRGB(240, 0, 0),
    Save = true,
    Flag = "強さトグル",
    Callback = function(enabled)
        if enabled then
            strengthConnection = workspace.ChildAdded:Connect(function(model)
                if model.Name == "GrabParts" then
                    local grabPart = model:FindFirstChild("GrabPart")
                    if not grabPart then return end
                    
                    local weldConstraint = grabPart:FindFirstChild("WeldConstraint")
                    if not weldConstraint or not weldConstraint.Part1 then return end
                    
                    local partToImpulse = weldConstraint.Part1
                    
                    if partToImpulse then
                        local velocityObj = Instance.new("BodyVelocity", partToImpulse)
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
            if not poisonGrabCoroutine or coroutine.status(poisonGrabCoroutine) == "dead" then
                poisonGrabCoroutine = coroutine.create(function() grabHandler("poison") end)
                coroutine.resume(poisonGrabCoroutine)
            end
        else
            if poisonGrabCoroutine and coroutine.status(poisonGrabCoroutine) ~= "dead" then
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
            if not ufoGrabCoroutine or coroutine.status(ufoGrabCoroutine) == "dead" then
                ufoGrabCoroutine = coroutine.create(function() grabHandler("radioactive") end)
                coroutine.resume(ufoGrabCoroutine)
            end
        else
            if ufoGrabCoroutine and coroutine.status(ufoGrabCoroutine) ~= "dead" then
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
            if not fireGrabCoroutine or coroutine.status(fireGrabCoroutine) == "dead" then
                fireGrabCoroutine = coroutine.create(fireGrab)
                coroutine.resume(fireGrabCoroutine)
            end
        else
            if fireGrabCoroutine and coroutine.status(fireGrabCoroutine) ~= "dead" then
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
            if not noclipGrabCoroutine or coroutine.status(noclipGrabCoroutine) == "dead" then
                noclipGrabCoroutine = coroutine.create(noclipGrab)
                coroutine.resume(noclipGrabCoroutine)
            end
        else
            if noclipGrabCoroutine and coroutine.status(noclipGrabCoroutine) ~= "dead" then
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
            cleanupConnections(kickGrabConnections)
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
            if not fireAllCoroutine or coroutine.status(fireAllCoroutine) == "dead" then
                fireAllCoroutine = coroutine.create(fireAll)
                coroutine.resume(fireAllCoroutine)
            end
        else
            if fireAllCoroutine and coroutine.status(fireAllCoroutine) ~= "dead" then
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
                        local isHeldValue = localPlayer:FindFirstChild("IsHeld")
                        while isHeldValue and isHeldValue.Value do
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
                if character and character:FindFirstChild("HumanoidRootPart") then
                    local fpp = character.HumanoidRootPart:FindFirstChild("FirePlayerPart")
                    if fpp then
                        local partOwner = fpp:FindFirstChild("PartOwner")
                        if partOwner and partOwner.Value ~= localPlayer.Name then
                            local args = {[1] = character.HumanoidRootPart, [2] = 0}
                            local ragdollRemote = game:GetService("ReplicatedStorage"):WaitForChild("CharacterEvents", 5) and game.ReplicatedStorage.CharacterEvents:WaitForChild("RagdollRemote", 5)
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
            -- 😈 characterAddedConnの定義 (問題点3の修正)
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
            if not autoDefendCoroutine or coroutine.status(autoDefendCoroutine) == "dead" then
                autoDefendCoroutine = coroutine.create(function()
                    while wait(0.02) do
                        local character = localPlayer.Character
                        if character and character:FindFirstChild("Head") then
                            local head = character.Head
                            local partOwner = head:FindFirstChild("PartOwner")
                            if partOwner then
                                local attacker = Players:FindFirstChild(partOwner.Value)
                                if attacker and attacker.Character then
                                    Struggle:FireServer()
                                    local attackerFPP = attacker.Character.HumanoidRootPart:FindFirstChild("FirePlayerPart")
                                    if attackerFPP then
                                        SetNetworkOwner:FireServer(attacker.Character.Head or attacker.Character.Torso, attackerFPP.CFrame)
                                    end
                                    task.wait(0.1)
                                    local target = attacker.Character:FindFirstChild("Torso")
                                    if target then
                                        local velocity = target:FindFirstChild("l") or Instance.new("BodyVelocity")
                                        velocity.Name = "l"
                                        velocity.Parent = target
                                        velocity.Velocity = Vector3.new(0, 50, 0)
                                        velocity.MaxForce = Vector3.new(0, math.huge, 0)
                                        Debris:AddItem(velocity, 100)
                                    end
                                end
                            end
                        end
                    end
                end)
                coroutine.resume(autoDefendCoroutine)
            end
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
            -- 😈 autoDefendKickCoroutineの定義 (問題点3の修正)
            if not autoDefendKickCoroutine or coroutine.status(autoDefendKickCoroutine) == "dead" then
                autoDefendKickCoroutine = coroutine.create(function()
                    while enabled do
                        local character = localPlayer.Character
                        if character and character:FindFirstChild("HumanoidRootPart") then
                            local humanoidRootPart = character.HumanoidRootPart
                            local head = character:FindFirstChild("Head")
                            if head then
                                local partOwner = head:FindFirstChild("PartOwner")
                                if partOwner then
                                    local attacker = Players:FindFirstChild(partOwner.Value)
                                    if attacker and attacker.Character then
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
            if autoDefendKickCoroutine then
                coroutine.close(autoDefendKickCoroutine)
                autoDefendKickCoroutine = nil
            end
        end
    end
})
local yeetMode = false

local function blobGrabPlayerYeet(player, blobman)
    if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then
        return
    end
    if not blobman or not blobman.Parent then return end -- blobmanの存在チェック
    
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
    local creatureGrab = blobman:WaitForChild("BlobmanSeatAndOwnerScript", 5) and blobman.BlobmanSeatAndOwnerScript:WaitForChild("CreatureGrab", 5)
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
            if not blobmanCoroutine or coroutine.status(blobmanCoroutine) == "dead" then
                blobmanCoroutine = coroutine.create(function()
                    local foundBlobman = false
                    
                    -- キャッシュされたブロブマンリストから探す
                    local currentBlobman = nil
                    for _, b in ipairs(blobmanList) do
                        local seat = b:FindFirstChild("VehicleSeat")
                        if seat and seat.Occupant and isDescendantOf(seat.Occupant.Parent, localPlayer.Character) then
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
                                if seat and seat.Occupant and isDescendantOf(seat.Occupant.Parent, localPlayer.Character) then
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
            if blobmanCoroutine then
                coroutine.close(blobmanCoroutine)
                blobmanCoroutine = nil
                blobman = nil
            end
        end
    end
})

-- 😈 自動着席トグルのロジック変更 (Heartbeatから切り離すため、状態の更新のみ)
BlobmanTab:AddToggle({
    Name = "Auto Sit",
    Desc = "オンにすると、ブロブマンを召喚したとき、または降りた後に自動的に座ります。",
    Type = "Toggle",
    Default = false,
    Color = Color3.fromRGB(240, 0, 0),
    Save = true,
    Flag = "AutoSitToggle",
    Callback = function(State)
        AutoSitEnabled = State
    end
})
-- /自動着席トグルのロジック変更

-- 😈 ブロブマン自動スポーンのUI要素を追加
BlobmanTab:AddToggle({
    Name = "ブロブマン自動スポーン",
    Default = false,
    Color = Color3.fromRGB(0, 240, 0),
    Save = true,
    Flag = "AutoReloadBlobman",
    Callback = function(enabled)
       reloadBlobman(enabled)
    end
})

BlobmanTab:AddSlider({
    Name = "Max amount of Blobmen",
    Min = 1,
    Max = localPlayer.ToysLimitCap.Value / 10,
    Color = Color3.fromRGB(240, 0, 0),
    ValueName = "Blobmen",
    Increment = 1,
    Default = _G.MaxBlobmen,
    Save = true,
    Flag = "NaxBlobmenSlider",
    Callback = function(value)
        _G.MaxBlobmen = value
    end
})
-- /ブロブマン自動スポーンのUI要素を追加

BlobmanTab:AddToggle({
    Name = "投げ飛ばしモード (Yeet Mode)",
    Color = Color3.fromRGB(255, 100, 0),
    Default = false,
    Callback = function(enabled)
        yeetMode = enabled
        if enabled then
            OrionLib:MakeNotification({
                Name = "Yeet Mode ON",
                Content = "相手を超高速で投げ飛ばします！",
                Image = "rbxassetid://4483345998",
                Time = 3
            })
        end
    end
})

BlobmanTab:AddSlider({
    Name = "Delay (投げ飛ばし速度)",
    Min = 0.001,
    Max = 0.5,
    Color = Color3.fromRGB(240, 0, 0),
    ValueName = "秒",
    Increment = 0.001,
    Default = 0.05,
    Callback = function(value)
        _G.BlobmanDelay = value
    end
})

BlobmanTab:AddToggle({
    Name = "超加速モード (極限)",
    Color = Color3.fromRGB(255, 0, 0),
    Default = false,
    Callback = function(enabled)
        if enabled then
            _G.BlobmanDelay = 0.001
            yeetMode = true
            OrionLib:MakeNotification({
                Name = "⚠️ 超加速モード",
                Content = "警告: 最速でプレイヤーを投げ飛ばします！",
                Image = "rbxassetid://4483345998",
                Time = 3
            })
        else
            _G.BlobmanDelay = 0.05
            yeetMode = false
        end
    end
})

BlobmanTab:AddParagraph("使い方", "1. ブロブマンに乗る\n2. ループグラブオールをON\n3. 投げ飛ばしモードをONにすると相手がめちゃくちゃ飛びます")

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
            if not auraCoroutine or coroutine.status(auraCoroutine) == "dead" then
                auraCoroutine = coroutine.create(function()
                    while true do
                        local success, err = pcall(function()
                            local character = localPlayer.Character
                            if character and character:FindFirstChild("Head") and character:FindFirstChild("HumanoidRootPart") then
                                local head = character.Head
                                local humanoidRootPart = character.HumanoidRootPart

                                for _, player in pairs(Players:GetPlayers()) do
                                    if player ~= localPlayer and player.Character then
                                        local playerCharacter = player.Character
                                        local playerTorso = playerCharacter:FindFirstChild("Torso")
                                        if playerTorso then
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
            if not gravityCoroutine or coroutine.status(gravityCoroutine) == "dead" then
                gravityCoroutine = coroutine.create(function()
                    while enabled do
                        local success, err = pcall(function()
                            local character = localPlayer.Character
                            if character and character:FindFirstChild("HumanoidRootPart") then
                                local humanoidRootPart = character.HumanoidRootPart

                                for _, player in pairs(Players:GetPlayers()) do
                                    if player ~= localPlayer and player.Character then
                                        local playerCharacter = player.Character
                                        local playerTorso = playerCharacter:FindFirstChild("Torso")
                                        if playerTorso then
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
        if auraToggle == 1 then
            if enabled then
                if not kickCoroutine or coroutine.status(kickCoroutine) == "dead" then
                    kickCoroutine = coroutine.create(function()
                        while enabled do
                            local success, err = pcall(function()
                                local character = localPlayer.Character
                                if character and character:FindFirstChild("HumanoidRootPart") then
                                    local humanoidRootPart = character.HumanoidRootPart

                                    for _, player in pairs(Players:GetPlayers()) do
                                        if player ~= localPlayer and player.Character then
                                            local playerCharacter = player.Character
                                            local playerTorso = playerCharacter:FindFirstChild("Head")

                                            if playerTorso then
                                                local distance = (playerTorso.Position - humanoidRootPart.Position).Magnitude
                                                if distance <= auraRadius then
                                                    local fpp = playerCharacter:WaitForChild("HumanoidRootPart", 5) and playerCharacter.HumanoidRootPart:FindFirstChild("FirePlayerPart")
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
            elseif kickCoroutine then
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
                if not kickCoroutine or coroutine.status(kickCoroutine) == "dead" then
                    kickCoroutine = coroutine.create(function()
                        while enabled do
                            local success, err = pcall(function()
                                local character = localPlayer.Character
                                if character and character:FindFirstChild("HumanoidRootPart") then
                                    local humanoidRootPart = character.HumanoidRootPart

                                    for _, player in pairs(Players:GetPlayers()) do
                                        if player ~= localPlayer and player.Character then
                                            local playerCharacter = player.Character
                                            local playerTorso = playerCharacter:FindFirstChild("Head")

                                            if playerTorso then
                                                local distance = (playerTorso.Position - humanoidRootPart.Position).Magnitude
                                                if distance <= auraRadius then
                                                    local fpp = playerCharacter:WaitForChild("HumanoidRootPart", 5) and playerCharacter.HumanoidRootPart:FindFirstChild("FirePlayerPart")
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
                if kickCoroutine then
                    coroutine.close(kickCoroutine)
                    kickCoroutine = nil
                end
            end
        end
    end
})

AuraTab:AddDropdown({
    Name = "キックの種類",
    Options = {"空", "サイレント"},
    Default = "サイレント", -- 😈 デフォルトを日本語で修正
    Save = true,
    Flag = "KickModeFlag",
    Callback = function(selected)
        if selected == "空" then -- 😈 選択肢の文字列を修正
            auraToggle = 2 
        else 
            auraToggle = 1 
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
            if not poisonAuraCoroutine or coroutine.status(poisonAuraCoroutine) == "dead" then
                poisonAuraCoroutine = coroutine.create(function()
                    while enabled do
                        local success, err = pcall(function()
                            local character = localPlayer.Character
                            if character and character:FindFirstChild("HumanoidRootPart") then
                                local humanoidRootPart = character.HumanoidRootPart

                                for _, player in pairs(Players:GetPlayers()) do
                                    if player ~= localPlayer and player.Character then
                                        local playerCharacter = player.Character
                                        local playerTorso = playerCharacter:FindFirstChild("Torso")
                                        if playerTorso then
                                            local distance = (playerTorso.Position - humanoidRootPart.Position).Magnitude
                                            if distance <= auraRadius then
                                                local head = playerCharacter:FindFirstChild("Head")
                                                while distance <= auraRadius do
                                                    SetNetworkOwner:FireServer(playerTorso, playerCharacter.HumanoidRootPart.CFrame)
                                                    distance = (playerTorso.Position - humanoidRootPart.Position).Magnitude
                                                    if head then -- Headの存在チェック
                                                        for _, part in pairs(poisonHurtParts) do
                                                            part.Size = Vector3.new(1, 3, 1)
                                                            part.Transparency = 1
                                                            part.Position = head.Position
                                                        end
                                                    end
                                                    wait()
                                                    for _, part in pairs(poisonHurtParts) do
                                                        part.Position = Vector3.new(0, -200, 0)
                                                    end
                                                end
                                                for _, part in pairs(poisonHurtParts) do
                                                    part.Position = Vector3.new(0, -200, 0)
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
        elseif poisonAuraCoroutine then
            coroutine.close(poisonAuraCoroutine)
            for _, part in pairs(poisonHurtParts) do
                part.Position = Vector3.new(0, -200, 0)
            end
            poisonAuraCoroutine = nil
        end
    end
})


CharacterTab:AddToggle({
    Name = "自分と乗り物のNoclip", -- 😈 Noclip トグル
    Default = false,
    Save = true,
    Color = Color3.fromRGB(255, 100, 0),
    Flag = "SelfVehicleNoclip",
    Callback = togglePlayerNoclip -- 😈 Noclip 関数を直接コールバックに設定
})

CharacterTab:AddToggle({
    Name = "しゃがみ速度",
    Default = false,
    Save = true,
    Color = Color3.fromRGB(240, 0, 0),
    Flag = "CrouchSpeed",
    Callback = function(enabled)
        if enabled then
            if not crouchSpeedCoroutine or coroutine.status(crouchSpeedCoroutine) == "dead" then
                crouchSpeedCoroutine = coroutine.create(function()
                    while true do
                        pcall(function()
                            if not playerCharacter.Humanoid then return end
                            if playerCharacter.Humanoid.WalkSpeed == 5 then
                                playerCharacter.Humanoid.WalkSpeed = crouchWalkSpeed
                            end
                        end)
                        wait()
                    end
                end)
                coroutine.resume(crouchSpeedCoroutine)
            end
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
            if not crouchJumpCoroutine or coroutine.status(crouchJumpCoroutine) == "dead" then
                crouchJumpCoroutine = coroutine.create(function()
                    while true do
                        pcall(function()
                            if not playerCharacter.Humanoid then return end
                            if playerCharacter.Humanoid.JumpPower == 12 then
                                playerCharacter.Humanoid.JumpPower = crouchJumpPower
                            end
                        end)
                        wait()
                    end
                end)
                coroutine.resume(crouchJumpCoroutine)
            end
        elseif crouchJumpCoroutine then
            coroutine.close(crouchJumpCoroutine)
            crouchJumpCoroutine = nil
            if playerCharacter and playerCharacter.Humanoid then
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
                    if bodyPosition and bodyGyro then
                        local targetPosition
                        if followMode then
                            if playerCharacter and playerCharacter:FindFirstChild("HumanoidRootPart") then
                                targetPosition = playerCharacter.HumanoidRootPart.Position
                                local offset = (index - midPoint) * decoyOffset
                                local forward = playerCharacter.HumanoidRootPart.CFrame.LookVector
                                local right = playerCharacter.HumanoidRootPart.CFrame.RightVector
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
                if playerCharacter and playerCharacter:FindFirstChild("Head") then
                    SetNetworkOwner:FireServer(torso, playerCharacter.Head.CFrame)
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
        OrionLib:MakeNotification({Name = "Mode Toggled", Content = "Current mode: "..(followMode and "Follow" or "Surround"), Image = "rbxassetid://4483345998", Time = 3})
    end
})

FunTab:AddButton({
    Name = "Disconnect Clones",
    Callback = function()
        cleanupConnections(connections)
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
            if target.Name == "FirePlayerPart" and target.Parent and target.Parent.Parent then
                character = target.Parent.Parent
            end
            
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            if character:IsA("Model") and humanoid then
                local hrp = character:FindFirstChild("HumanoidRootPart")
                if hrp then
                    SetNetworkOwner:FireServer(hrp, hrp.CFrame)
                    for _, part in ipairs(character:GetDescendants()) do
                        if part:IsA("BasePart") or part:IsA("Part") then
                            part.CanCollide = false
                        end
                    end

                    local torso = character:FindFirstChild("Torso")
                    if torso then
                        local bodyVelocity = Instance.new("BodyVelocity")
                        bodyVelocity.Parent = torso
                        bodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                        bodyVelocity.Velocity = Vector3.new(0, -4, 0)
                        torso.CanCollide = false
                        Debris:AddItem(bodyVelocity, 5) -- 速度制御を削除
                        task.wait(1)
                        torso.CanCollide = false
                    end
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
            if target.Name == "FirePlayerPart" and target.Parent and target.Parent.Parent then
                character = target.Parent.Parent
            end
            
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            if character:IsA("Model") and humanoid then
                local hrp = character:FindFirstChild("HumanoidRootPart")
                if not hrp then return end
                
                local fpp = hrp:FindFirstChild("FirePlayerPart")
                if not fpp then return end
                
                if kickMode == 1 then   
                    SetNetworkOwner:FireServer(fpp, fpp.CFrame)
                    local bodyVelocity = Instance.new("BodyVelocity")
                    bodyVelocity.Parent = fpp
                    bodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                    bodyVelocity.Velocity = Vector3.new(0, 20, 0)
                    Debris:AddItem(bodyVelocity, 5)
                elseif kickMode == 2 then
                    SetNetworkOwner:FireServer(fpp, fpp.CFrame)
                    local platform = Instance.new("Part")
                    platform.Name = "FloatingPlatform"
                    platform.Size = Vector3.new(5, 2, 5)
                    platform.Anchored = true
                    platform.Transparency = 1
                    platform.CanCollide = true
                    platform.Parent = character
                    local platformConn = RunService.Heartbeat:Connect(function()
                        if character and character:FindFirstChild("HumanoidRootPart") and character.HumanoidRootPart:FindFirstChild("FirePlayerPart") then
                            platform.Position = character.HumanoidRootPart.Position - Vector3.new(0, 3.994, 0)
                        else
                            platform:Destroy()
                            platformConn:Disconnect()
                        end
                    end)
                    Debris:AddItem(platform, 60)
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
            if target.Name == "FirePlayerPart" and target.Parent and target.Parent.Parent then
                character = target.Parent.Parent
            end
            
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            if character:IsA("Model") and humanoid then
                local hrp = character:FindFirstChild("HumanoidRootPart")
                local head = character:FindFirstChild("Head")
                
                if hrp and head then
                    SetNetworkOwner:FireServer(hrp, hrp.CFrame)
                    SetNetworkOwner:FireServer(head, head.CFrame)
                    
                    local torso = character:FindFirstChild("Torso")
                    if torso then
                        for _, motor in pairs(torso:GetChildren()) do
                            if motor:IsA('Motor6D') then motor:Destroy() end
                        end
                    end
                    
                    task.wait(0.5)
                    SetNetworkOwner:FireServer(head, head.CFrame)
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
        if not toysFolder then return end -- toysFolderチェック

        local mouse = localPlayer:GetMouse()
        local target = mouse.Target
        if target and target:IsA("BasePart") then
            local character = target.Parent
            if target.Name == "FirePlayerPart" and target.Parent and target.Parent.Parent then
                character = target.Parent.Parent
            end
            
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            if character:IsA("Model") and humanoid then
                if not toysFolder:FindFirstChild("Campfire") then
                    spawnItem("Campfire", Vector3.new(-72.9304581, -5.96906614, -265.543732))
                end
                
                local campfire = toysFolder:FindFirstChild("Campfire")
                local hrp = character:FindFirstChild("HumanoidRootPart")
                local head = character:FindFirstChild("Head")

                if campfire and hrp and head then
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
                end
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
        
        local connection
        connection = toysFolder.ChildAdded:Connect(function(child)
            if child.Name == "BombMissile" then
                if child:WaitForChild("ThisToysNumber", 1) then
                    if child.ThisToysNumber.Value == (toysFolder.ToyNumber.Value - 1) then
                        connection:Disconnect()
                        
                        local partHitDetector = child:FindFirstChild("PartHitDetector")
                        local body = child:FindFirstChild("Body")
                        if not partHitDetector or not body then return end

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
                                ["PositionPart"] = body
                            },
                            [2] = body.Position
                        }
                        ReplicatedStorage:WaitForChild("BombEvents"):WaitForChild("BombExplode"):FireServer(unpack(args))

                    end
                end
            end
        end)
        spawnItemCf("BombMissile", playerCharacter.Head.CFrame or playerCharacter.HumanoidRootPart.CFrame)
        task.wait(1)
        if connection.Connected then
            connection:Disconnect()
        end
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
        
        local connection
        connection = toysFolder.ChildAdded:Connect(function(child)
            if child.Name == "BombMissile" then
                if child:WaitForChild("ThisToysNumber", 1) then
               
                    if child.ThisToysNumber.Value == (toysFolder.ToyNumber.Value - 1) then
           
                        connection:Disconnect()
                        
                        local partHitDetector = child:FindFirstChild("PartHitDetector")
                        if not partHitDetector then return end

                        SetNetworkOwner:FireServer(partHitDetector, partHitDetector.CFrame)
                        local velocityObj = Instance.new("BodyVelocity", partHitDetector)
                        velocityObj.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                        velocityObj.Velocity = workspace.CurrentCamera.CFrame.lookVector * 500
                        Debris:AddItem(velocityObj, 10)
                    end
                end
            end
        })
        spawnItemCf("BombMissile", playerCharacter.Head.CFrame or playerCharacter.HumanoidRootPart.CFrame)
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
                        local body = child:FindFirstChild("Body")
                        if not partHitDetector or not body then return end
                        
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
                                ["PositionPart"] = body
                            },
                            [2] = body.Position
                        }
                        ReplicatedStorage:WaitForChild("BombEvents"):WaitForChild("BombExplode"):FireServer(unpack(args))

                    end
                end
            end
        })
        spawnItemCf("FireworkMissile", playerCharacter.Head.CFrame or playerCharacter.HumanoidRootPart.CFrame)
        task.wait(1)
        if connection.Connected then
            connection:Disconnect()
        end
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
        
        local partHitDetector = bomb:FindFirstChild("PartHitDetector")
        local primaryPart = localPlayer.Character and (localPlayer.Character.HumanoidRootPart or localPlayer.Character.PrimaryPart)
        if not partHitDetector or not primaryPart then return end

        local args = {
            [1] = {
                ["Radius"] = 17.5,
                ["TimeLength"] = 2,
                ["Hitbox"] = partHitDetector,
                ["ExplodesByFire"] = false,
                ["MaxForcePerStudSquared"] = 225,
                ["Model"] = bomb,
                ["ImpactSpeed"] = 100,
                ["ExplodesByPointy"] = false,
                ["DestroysModel"] = false,
                ["PositionPart"] = primaryPart
            },
            [2] = primaryPart.Position
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
        
        local primaryPart = localPlayer.Character and (localPlayer.Character.HumanoidRootPart or localPlayer.Character.PrimaryPart)
        if not primaryPart then return end

        for i = #bombList, 1, -1 do
            local bomb = table.remove(bombList, i)
            local partHitDetector = bomb:FindFirstChild("PartHitDetector")
            if not partHitDetector then continue end
            
            local args = {
                [1] = {
                    ["Radius"] = 17.5,
                    ["TimeLength"] = 2,
                    ["Hitbox"] = partHitDetector,
                    ["ExplodesByFire"] = false,
                    ["MaxForcePerStudSquared"] = 225,
                    ["Model"] = bomb,
                    ["ImpactSpeed"] = 100,
                    ["ExplodesByPointy"] = false,
                    ["DestroysModel"] = false,
                    ["PositionPart"] = primaryPart
                },
                [2] = primaryPart.Position
            }
            ReplicatedStorage:WaitForChild("BombEvents"):WaitForChild("BombExplode"):FireServer(unpack(args))
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
        if not nearestPlayer or not nearestPlayer.Character then return end
        
        local char = nearestPlayer.Character
        local targetPart = char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso") or char:FindFirstChild("PrimaryPart")
        if not targetPart then return end
        
        for i = #bombList, 1, -1 do
            local bomb = table.remove(bombList, i)
            local partHitDetector = bomb:FindFirstChild("PartHitDetector")
            if not partHitDetector then continue end
            
            local args = {
                [1] = {
                    ["Radius"] = 17.5,
                    ["TimeLength"] = 2,
                    ["Hitbox"] = partHitDetector,
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
    end
})

KeybindSection2:AddToggle({
    Name = "無視してください",
    Default = false,
    Color = Color3.fromRGB(240, 0, 0),
    Save = false,
    Callback = function(enabled)
		if enabled then
            if not toysFolder then 
                OrionLib:MakeNotification({Name = "Error", Content = "Toys folder not found.", Image = "rbxassetid://4483345998", Time = 3})
                return 
            end

			for i, v in pairs(toysFolder:GetChildren()) do
				if v.Name ~= "ToyNumber" and v:IsA("Model") then
                    local part
                    if v:FindFirstChild("SoundPart") then
                        part = v.SoundPart
                    elseif v.PrimaryPart then
                        part = v.PrimaryPart
                    else
                        -- Fallback to finding a basepart
                        for _, desc in pairs(v:GetDescendants()) do
                            if desc:IsA("BasePart") then
                                part = desc
                                break
                            end
                        end
                    end
                    
                    if not part then continue end -- Partが見つからなければスキップ
                    
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
				end
			end
            
            if #lightbitparts == 0 then
                 OrionLib:MakeNotification({Name = "Error", Content = "No toys found to orbit.", Image = "rbxassetid://4483345998", Time = 3})
                 return
            end
            
			lightorbitcon = RunService.Heartbeat:Connect(function()
				if not localPlayer.Character or not localPlayer.Character.HumanoidRootPart then return end
				lightbitoffset = lightbitoffset + lightbit
                
				lightbitpos = getSurroundingVectors(localPlayer.Character.HumanoidRootPart.Position, usingradius, #lightbitparts, lightbitoffset)

				for i, v in ipairs(lightbitpos) do
					if bodyPositions[i] and alignOrientations[i] then -- 存在チェック
                        bodyPositions[i].Position = v
                        local direction = (localPlayer.Character.HumanoidRootPart.Position - bodyPositions[i].Position).unit
                        local lookAtCFrame = CFrame.lookAt(bodyPositions[i].Position, localPlayer.Character.HumanoidRootPart.Position)
                        alignOrientations[i].CFrame = lookAtCFrame
                    end
				end
			end)
		else
            if lightorbitcon and lightorbitcon.Connected then
                lightorbitcon:Disconnect()
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
                    if attachment then
                        attachment:Destroy()
                    end
                end
			end
			for _, v in ipairs(bodyPositions) do
                if v then v:Destroy() end
			end
			bodyPositions = {}
			for _, v in ipairs(alignOrientations) do
                if v then v:Destroy() end
			end
			alignOrientations = {}
			lightbitparts = {}
		end
    end
})


KeybindSection2:AddBind({
    Name = "開発者向けの秘密のキーバインド（あなたには何も起こりません）",
    Default = "K",
    Hold = true,
    Save = true,
    Flag = "LightBitSpeedUpDev",
    Callback = function(isHeld)
        if lightbitcon and lightbitcon.Connected then
            lightbitcon:Disconnect()
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
    end
})
KeybindSection2:AddBind({
    Name = "開発者向けのもう一つの小さなキーバインド（あなたには何も影響しません）",
    Default = "J",
    Hold = true,
    Save = true,
    Flag = "LightBitRadiusUpDev",
    Callback = function(isHeld)
        if lightbitcon2 and lightbitcon2.Connected then
            lightbitcon2:Disconnect()
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
    Flag = "NaxMissilesSlider",
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
            if not ragdollAllCoroutine or coroutine.status(ragdollAllCoroutine) == "dead" then
                ragdollAllCoroutine = coroutine.create(ragdollAll)
                coroutine.resume(ragdollAllCoroutine)
            end
        else
            if ragdollAllCoroutine then
                coroutine.close(ragdollAllCoroutine)
                ragdollAllCoroutine = nil
            end
        end
    end
})

-- 😈 自動着席ロジックをHeartbeatから切り離す (修正済み)
-- プレイヤーが座席から降りたときのイベントを監視
localPlayer.CharacterAdded:Connect(function(character)
    if character:FindFirstChildOfClass("Humanoid") then
        character.Humanoid.Changed:Connect(function(property)
            if property == "SeatPart" then
                -- SeatPartがnilになった（降りた）時
                if character.Humanoid.SeatPart == nil and AutoSitEnabled then
                    task.wait(0.1) -- 処理待ちのため少し待つ
                    
                    -- ブロブマンを探す (特にキャッシュリストから)
                    local targetBlobman = nil
                    for _, b in ipairs(blobmanList) do
                        if b and b:FindFirstChild("VehicleSeat") then
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
                    if targetBlobman then
                        local VehicleSeat = targetBlobman:FindFirstChild("VehicleSeat")
                        if VehicleSeat and character.Humanoid.SeatPart == nil then
                            VehicleSeat:Sit(character.Humanoid)
                        end
                    end
                end
            end
        end)
    end
end)
-- /自動着席ロジックをHeartbeatから切り離す


OrionLib:MakeNotification({Name = "Welcome", Content = "ようこそ、野獣のおちんちんハブへ", Image = "rbxassetid://4483345998", Time = 5})
OrionLib:Init()
