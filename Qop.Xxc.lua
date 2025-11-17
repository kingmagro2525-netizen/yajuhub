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

-- ▼▼▼ 古い版から移植 (不足変数) ▼▼▼
local deathAuraCoroutine
local poisonCoroutines = {}
local coroutineRunning = false
local kickGrabCoroutine
local hellSendGrabCoroutine
local blobmanCoroutine
local lighBitSpeedCoroutine
local tpAllCoroutine
local autoDefendKickCoroutine -- DefenseTab移植で必要
-- ▲▲▲ 移植完了 ▲▲▲

-- ▼▼▼ Blobmanタブ用 グローバル変数 ▼▼▼
local selectedBlobmanTargetName = nil
local blobmanPlayerDropdown -- ドロップダウンオブジェクトを保持するための変数
local blobmanKickLoopCoroutine = nil -- 追加: 個別キックループ用コルーチン
local blobmanKickLoopTargetPlayer = nil -- 追加: 個別キックループの対象プレイヤー
-- ▲▲▲ 追加・修正完了 ▲▲▲

local AutoSitEnabled = false
local loopTpCoroutine
local currentLoopTpPlayerIndex = 1

_G.strength = 400
_G.ToyToLoad = "BombMissile"
_G.MaxMissiles = 9
_G.BlobmanDelay = 0.05
-- 追加: 高速射出キックの設定
_G.KickVelocityMagnitude = 1000000 -- 100万ブロック分飛ばすための速度
_G.KickLoopDelay = 0.5 -- ループ間の待機時間

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

local OrionLib = loadstring(game:HttpGet(("https://raw.githubusercontent.com/yua20170313a-pixel/Orion/e19e8236bde46c459fb0d617e4640aeb75878703/source")))()

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

local followMode = true
local toysFolder = workspace:FindFirstChild(localPlayer.Name.."SpawnedInToys")
local playerList = {}
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
    DestroyToy:FireServer(toy)
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

-- ▼▼▼ Blobmanタブ用のプレイヤーリスト更新関数 (修正: 表示名(ユーザーID)形式) ▼▼▼
-- プレイヤー名を「表示名(ユーザーID)」形式で取得
local function getPlayerNamesForDropdown()
    local names = {}
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= localPlayer then
            -- 形式を「表示名(ユーザーID)」に修正 (RobloxのPlayer.Nameは表示名ではなく、変更にRobuxが必要なユーザー名の方だが、ここでは「表示名」として扱う)
            table.insert(names, player.Name .. " (" .. player.UserId .. ")")
        end
    end
    if #names == 0 then
        table.insert(names, "（自分以外いません）")
    end
    return names
end

-- プレイヤーリストを更新し、ドロップダウンを再設定する関数
local function updateBlobmanDropdown()
    local newNames = getPlayerNamesForDropdown()
    
    -- ドロップダウンが存在し、かつプレイヤーが1人以上いる場合
    if blobmanPlayerDropdown and #newNames > 0 and newNames[1] ~= "（自分以外いません）" then
        blobmanPlayerDropdown:SetOptions(newNames)
        
        -- 現在の選択肢が新しいリストに存在しない場合は、最初の要素を選択する
        local isSelectedTargetStillExists = false
        for _, name in ipairs(newNames) do
            if name == selectedBlobmanTargetName then
                isSelectedTargetStillExists = true
                break
            end
        end

        if not isSelectedTargetStillExists then
            selectedBlobmanTargetName = newNames[1]
            blobmanPlayerDropdown:Set(newNames[1])
        end
    elseif blobmanPlayerDropdown then
        -- プレイヤーがいない場合は「（自分以外いません）」のみにする
        blobmanPlayerDropdown:SetOptions(newNames)
        selectedBlobmanTargetName = newNames[1]
        blobmanPlayerDropdown:Set(newNames[1])
    end
end

-- PlayerAdded, PlayerRemovingイベントでリストを自動更新
Players.PlayerAdded:Connect(function(player)
    task.wait(0.5) -- プレイヤーのキャラクターが完全にロードされるのを待つ
    updateBlobmanDropdown()
end)

Players.PlayerRemoving:Connect(function(player)
    -- ループキック対象が退出した場合、コルーチンを停止
    if blobmanKickLoopCoroutine and blobmanKickLoopTargetPlayer and blobmanKickLoopTargetPlayer == player then
        coroutine.close(blobmanKickLoopCoroutine)
        blobmanKickLoopCoroutine = nil
        blobmanKickLoopTargetPlayer = nil
        OrionLib:MakeNotification({
            Name = "Kick Loop Stop",
            Content = player.Name .. " が退出しました。個別キックループを停止します。", 
            Image = "rbxassetid://4483345998", 
            Time = 5
        })
        -- トグルがあればオフにする処理をここに追加 (ただしコード内にトグルがないため保留)
    end
    updateBlobmanDropdown()
end)
-- ▲▲▲ Blobmanタブ用のプレイヤーリスト修正・自動更新処理完了 ▲▲▲


for i, v in pairs(localPlayer:WaitForChild("PlayerGui"):WaitForChild("MenuGui"):WaitForChild("Menu"):WaitForChild("TabContents"):WaitForChild("Toys"):WaitForChild("Contents"):GetChildren()) do
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
    for _, connection in ipairs(connectionTable) do
        if connection and typeof(connection) == "RBXScriptConnection" then
            pcall(function() connection:Disconnect() end)
        end
    end
end

-- ▼▼▼ 削除: getVersion() 関数 ▼▼▼
-- local function getVersion() ... end
-- ▲▲▲ 削除完了 ▼▼▼

local function spawnItem(itemName, position, orientation)
    task.spawn(function()
        local cframe = CFrame.new(position)
        local rotation = Vector3.new(0, 90, 0)
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
        pcall(function()
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
        wait()
    end
end

local function fireGrab()
    while true do
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
        wait()
    end
end

local function noclipGrab()
    while true do
        pcall(function()
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
        pcall(function()
            if toysFolder:FindFirstChild("Campfire") then
                DestroyT(toysFolder:FindFirstChild("Campfire"))
                wait(0.5)
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
            local originalPosition = playerCharacter.Torso.Position
            SetNetworkOwner:FireServer(firePlayerPart, firePlayerPart.CFrame)
            playerCharacter:MoveTo(firePlayerPart.Position)
            wait(0.3)
            playerCharacter:MoveTo(originalPosition)
            local bodyPosition = Instance.new("BodyPosition")
            bodyPosition.P = 20000
            bodyPosition.Position = playerCharacter.Head.Position + Vector3.new(0, 600, 0)
            bodyPosition.Parent = campfire.Main
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
        pcall(function()
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
                if isDescendantOf(primaryPart, player.Character) then return end
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
        wait()
    end
end

local function cleanupAnchoredParts()
    for _, part in ipairs(anchoredParts) do
        if part then
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
    end
    OrionLib:MakeNotification({Name = "Success", Content = "Compiled "..#anchoredParts.." Toys together", Image = "rbxassetid://4483345998", Time = 5})
    local primaryPart = anchoredParts[1]
    if not primaryPart then return end
    local highlight = primaryPart:FindFirstChild("Highlight") or primaryPart.Parent:FindFirstChild("Highlight")
    if not highlight then
        highlight = createHighlight(primaryPart.Parent:IsA("Model") and primaryPart.Parent or primaryPart)
    end
    highlight.OutlineColor = Color3.new(0, 1, 0)
    local group = {}
    for _, part in ipairs(anchoredParts) do
        if part ~= primaryPart then
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
            if data.part then
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
    if not primaryPart then return end
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
        pcall(function()
            local character = localPlayer.Character
            if character and character:FindFirstChild("Head") and character:FindFirstChild("HumanoidRootPart") then
                local humanoidRootPart = character.HumanoidRootPart
                for _, partModel in pairs(anchoredParts) do
                    coroutine.wrap(function()
                        if partModel then
                            local distance = (partModel.Position - humanoidRootPart.Position).Magnitude
                            if distance <= 30 then
                                local highlight = partModel:FindFirstChild("Highlight") or partModel.Parent:FindFirstChild("Highlight")
                                if highlight and highlight.OutlineColor == Color3.new(1, 0, 0) then
                                    SetNetworkOwner:FireServer(partModel, partModel.CFrame)
                                    if partModel:WaitForChild("PartOwner") and partModel.PartOwner.Value == localPlayer.Name then
                                        highlight.OutlineColor = Color3.new(0, 0, 1)
                                    end
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
    while true do
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
            local bodyPosition = Instance.new("BodyPosition")
            bodyPosition.P = 20000
            bodyPosition.Parent = banana.Main
            while true do
                for _, player in pairs(Players:GetChildren()) do
                    pcall(function()
                        if player.Character and player.Character ~= playerCharacter then
                            bananaPeel.Position = player.Character.HumanoidRootPart.Position or player.Character.Head.Position
                            bodyPosition.Position = playerCharacter.Head.Position + Vector3.new(0, 600, 0)
                            wait()
                        end
                    end)
                end  
                wait()
            end
        end)
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

local function setupAntiExplosion(character)
    local partOwner = character:WaitForChild("Humanoid"):FindFirstChild("Ragdolled")
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
    
    -- プレイヤー名からユーザーIDを抽出してPlayerオブジェクトを取得
    local targetPlayerName = targetPlayer.Name 
    local targetPlayerObject = Players:FindFirstChild(targetPlayerName)
    
    if not targetPlayerObject or not targetPlayerObject.Character then return end
    
    -- プレイヤーが掴まれていないかチェック
    if targetPlayerObject.IsHeld and targetPlayerObject.IsHeld.Value == true then
        -- ループキックの場合は掴まれていても続行の可能性があるため、ここでは通知のみ
        if not blobmanKickLoopCoroutine then
            OrionLib:MakeNotification({
                Name = "Info",
                Content = targetPlayerName .. " は既に掴まれています。", 
                Image = "rbxassetid://4483345998", 
                Time = 3
            })
        end
        return
    end

    local targetPos = targetHRP.CFrame
    playerHRP.CFrame = targetPos * CFrame.new(0, 5, 0)
    task.wait(_G.BlobmanDelay / 2)
    local blobmanHRP = blobman.PrimaryPart or blobman:FindFirstChild("Head") or blobman:FindFirstChild("Body")
    if blobmanHRP then
        blobmanHRP.CFrame = targetPos * CFrame.new(0, 1, 0)
    end
    task.wait(_G.BlobmanDelay / 2)
    
    -- グロブマンの掴みロジックを修正
    local targetDetector
    local targetWeld
    if blobalter == 1 then
        targetDetector = blobman:FindFirstChild("LeftDetector")
        targetWeld = targetDetector and targetDetector:FindFirstChild("LeftWeld")
        blobalter = 2
    else
        targetDetector = blobman:FindFirstChild("RightDetector")
        targetWeld = targetDetector and targetDetector:FindFirstChild("RightWeld")
        blobalter = 1
    end

    if targetDetector and targetWeld then
        targetHRP.CFrame = targetDetector.CFrame * CFrame.new(0, 0, -3)
        task.wait(0.05)
        local args = {
            [1] = targetDetector,
            [2] = targetHRP,
            [3] = targetWeld
        }
        local script = blobman:WaitForChild("BlobmanSeatAndOwnerScript", 0.5)
        if script then
            local creatureGrab = script:WaitForChild("CreatureGrab", 0.5)
            if creatureGrab then
                creatureGrab:FireServer(unpack(args))
            end
        end
    end
end

-- ▼▼▼ 追加: 個別プレイヤー高速射出キックのループ関数 ▼▼▼
local function blobmanKickLoop(targetPlayer, blobman)
    if not targetPlayer or not targetPlayer.Character or not targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
        warn("ターゲットプレイヤーが見つかりません。")
        return
    end

    local characterAddedConnection = nil

    local function waitForPlayerRespawn()
        if characterAddedConnection then characterAddedConnection:Disconnect() end
        local playerRespawned = Instance.new("BindableEvent")
        characterAddedConnection = targetPlayer.CharacterAdded:Connect(function()
            playerRespawned:Fire()
        end)
        playerRespawned.Event:Wait()
        if characterAddedConnection then characterAddedConnection:Disconnect() end
        playerRespawned:Destroy()
        task.wait(0.1) -- 新しいHRPがセットされるのを待つ
        
        -- 新しいCharacterを待つ
        while not targetPlayer.Character or not targetPlayer.Character:FindFirstChild("HumanoidRootPart") do
            task.wait(0.05)
        end
        return targetPlayer.Character
    end

    local function getTargetHRP(char)
        return char:FindFirstChild("HumanoidRootPart")
    end

    local function kickTarget(char, blobmanModel)
        local hrp = getTargetHRP(char)
        if not hrp then return end
        local blobmanHRP = blobmanModel.PrimaryPart or blobmanModel:FindFirstChild("Head") or blobmanModel:FindFirstChild("Body")

        -- 1. テレポート
        local targetPos = hrp.CFrame
        if localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart") then
            localPlayer.Character.HumanoidRootPart.CFrame = targetPos * CFrame.new(0, 5, 0)
        end
        task.wait(0.05)
        if blobmanHRP then
            blobmanHRP.CFrame = targetPos * CFrame.new(0, 1, 0)
        end
        task.wait(0.05)

        -- 2. いつも通り掴む
        blobGrabPlayerTP(targetPlayer, blobmanModel)
        
        task.wait(0.1) -- 掴み動作完了を待つ

        -- 3. ブロブマンのメインパートを使い、強力な勢いで飛ばす
        if blobmanHRP then
            -- ネットワークオーナーシップを取得
            SetNetworkOwner:FireServer(blobmanHRP, blobmanHRP.CFrame)
            task.wait(0.05)

            local bodyVelocity = Instance.new("BodyVelocity")
            bodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
            
            -- 飛ばす方向を設定 (空: Vector3.y, 下: Vector3.yをマイナス、横: Vector3.x, z)
            -- 例: 空中への超高速射出
            bodyVelocity.Velocity = Vector3.new(0, _G.KickVelocityMagnitude, 0) 
            
            bodyVelocity.Parent = blobmanHRP
            Debris:AddItem(bodyVelocity, 0.5) -- 速度適用後すぐに破棄されるように設定

            task.wait(0.5) -- 射出に時間を与える
            
            -- 掴みを解除 (これでプレイヤーは射出されたブロブマンと一緒に飛んでいく)
            local grabParts = workspace:FindFirstChild("GrabParts")
            if grabParts then
                 for _, weld in pairs(grabParts:GetDescendants()) do
                    if weld:IsA("WeldConstraint") then
                        weld:Destroy()
                    end
                end
                grabParts:Destroy()
            end
            
            -- ブロブマンのBodyVelocityを停止 (プレイヤーは飛んでいる状態)
            if bodyVelocity and bodyVelocity.Parent then bodyVelocity:Destroy() end

            -- プレイヤーのHRPにBodyVelocityを付与して加速を補助（オプション）
            if hrp and hrp.Parent then
                local playerBV = Instance.new("BodyVelocity")
                playerBV.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                playerBV.Velocity = Vector3.new(0, _G.KickVelocityMagnitude, 0) * 0.5 -- 補助的な速度
                playerBV.Parent = hrp
                Debris:AddItem(playerBV, 0.5)
            end
            
        else
            warn("ブロブマンのメインパートが見つかりません。")
        end
        
        -- 4. ターゲットプレイヤーがリスポーンするまで待つ
        local humanoid = char:FindFirstChildOfClass("Humanoid")
        if humanoid then
            repeat
                task.wait(0.1)
            until humanoid.Health <= 0
        end

        -- 5. リスポーン待ち
        char = waitForPlayerRespawn()
        
        task.wait(_G.KickLoopDelay)
        
        -- 6. ループ
        kickTarget(char, blobmanModel)

    end
    
    -- 初回実行
    kickTarget(targetPlayer.Character, blobman)
end
-- ▲▲▲ 追加: 個別プレイヤー高速射出キックのループ関数 ▲▲▲


local function loopTPFunction(blobman)
    while true do
        local playersToTarget = {}
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= localPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") and p.IsHeld and p.IsHeld.Value == false then
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
        wait(_G.BlobmanDelay)
    end
end

-- ▼▼▼ 削除: バージョン取得とチェック ▼▼▼
-- local version = getVersion() 
-- ▲▲▲ 削除完了 ▼▲▲

local whitelistIdsStr = game:HttpGet("https://raw.githubusercontent.com/Undebolted/FTAP/main/WhitelistedUserId.txt")
local whitelistIdsTbl = HttpService:JSONDecode(whitelistIdsStr)
local whitelistIds = {}

for id, _ in pairs(whitelistIdsTbl) do
    if tonumber(id) then
        table.insert(whitelistIds, tonumber(id))
    end
end

local isWhitelisted = false
for _, v in pairs(whitelistIds) do
    if v == localPlayer.UserId then
        isWhitelisted = true
        break
    end
end

-- ▼▼▼ 削除: バージョン確認ブロック ▼▼▼
-- local localVersion = "1-beta"
-- if localVersion ~= version then
--    ...
-- end
-- ▲▲▲ 削除完了 ▼▼▼

local Window = OrionLib:MakeWindow({
    Name = "野獣のおちんちんハブ", -- 修正: version変数を削除
    HidePremium = false,
    SaveConfig = true,
    ConfigFolder = "野獣のおちんちんハブ",
    IntroEnabled = true,
    IntroText = "野獣のおちんちんハブ", -- 修正: version変数を削除
    IntroIcon = "https://ibb.co/NgBCXdB6",
    Icon = "https://ibb.co/NgBCXdB6"
})

local GrabTab = Window:MakeTab({Name = "グラブ", Icon = "rbxassetid://18624615643", PremiumOnly = false})
local ObjectGrabTab = Window:MakeTab({Name = "オブジェクトグラブ", Icon = "rbxassetid://18624606749", PremiumOnly = false})
local DefenseTab = Window:MakeTab({Name = "ディフェンス", Icon = "rbxassetid://18624604880", PremiumOnly = false})
local BlobmanTab = Window:MakeTab({Name = "ブロブマン", Icon = "rbxassetid://18624614127", PremiumOnly = false})
-- ▼▼▼ 古い版から移植 (不足タブ) ▼▼▼
local FunTab = Window:MakeTab({Name = "楽しい", Icon = "rbxassetid://18624603093", PremiumOnly = false})
local ScriptTab = Window:MakeTab({Name = "他スクリプト", Icon = "rbxassetid://11570626783", PremiumOnly = false})
local AuraTab = Window:MakeTab({Name = "オーラ", Icon = "rbxassetid://18624608005", PremiumOnly = false})
local CharacterTab = Window:MakeTab({Name = "キャラクター", Icon = "rbxassetid://18624601543", PremiumOnly = false})
-- ▲▲▲ 移植完了 ▲▲▲
local ExplosionTab = Window:MakeTab({Name = "爆弾", Icon = "rbxassetid://18624610285", PremiumOnly = false})
local KeybindsTab = Window:MakeTab({Name = "キービエンス", Icon = "rbxassetid://18624616682", PremiumOnly = false})
local DevTab = Window:MakeTab({Name = "デベロッパーテスト", Icon = "rbxassetid://18624599762", PremiumOnly = false})

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
                    local partToImpulse = model.GrabPart.WeldConstraint.Part1
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
            for _, connection in pairs(kickGrabConnections) do
                connection:Disconnect()
            end
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
            kickGrabConnections = {}
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
            fireAllCoroutine = coroutine.create(fireAll)
            coroutine.resume(fireAllCoroutine)
        else
            if fireAllCoroutine then
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
                        while localPlayer.IsHeld.Value do
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
                if character and character:FindFirstChild("HumanoidRootPart") and character:FindFirstChild("HumanoidRootPart"):FindFirstChild("FirePlayerPart") then
                    local partOwner = character:FindFirstChild("HumanoidRootPart"):FindFirstChild("FirePlayerPart"):FindFirstChild("PartOwner")
                    if partOwner and partOwner.Value ~= localPlayer.Name then
                        local args = {[1] = character:WaitForChild("HumanoidRootPart"), [2] = 0}
                        game:GetService("ReplicatedStorage"):WaitForChild("CharacterEvents"):WaitForChild("RagdollRemote"):FireServer(unpack(args))
                        wait(0.1)
                        Struggle:FireServer()
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

-- ▼▼▼ 古い版から移植 (DefenseTab 自己防御) ▼▼▼
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
                while wait(0.02) do
                    local character = localPlayer.Character
                    if character and character:FindFirstChild("Head") then
                        local head = character.Head
                        local partOwner = head:FindFirstChild("PartOwner")
                        if partOwner then
                            local attacker = Players:FindFirstChild(partOwner.Value)
                            if attacker and attacker.Character then
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
                                    Debris:AddItem(velocity, 100)
                                end
                            end
                        end
                    end
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
                    wait(0.02)
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
-- ▲▲▲ 移植完了 ▲▲▲


BlobmanTab:AddToggle({
    Name = "Auto Sit on Blobman",
    Default = false,
    Color = Color3.fromRGB(240, 0, 0),
    Save = true,
    Flag = "AutoSitBlobman",
    Callback = function(enabled)
        AutoSitEnabled = enabled
    end
})

-- ▼▼▼ Blobmanタブの修正 (自動更新対応) ▼▼▼

local playerNames = getPlayerNamesForDropdown()

-- プレイヤー選択ドロップダウン
blobmanPlayerDropdown = BlobmanTab:AddDropdown({ -- グローバル変数に代入
    Name = "対象プレイヤー選択",
    Options = playerNames,
    Default = playerNames[1],
    Callback = function(selectedName)
        selectedBlobmanTargetName = selectedName
    end
})
-- 最初のプレイヤーをデフォルトで選択状態にする
selectedBlobmanTargetName = playerNames[1]

-- 選択キックボタン
local kickLoopToggle
local function getTargetPlayerFromDropdown()
    if not selectedBlobmanTargetName or selectedBlobmanTargetName == "（自分以外いません）" then
        return nil
    end
    
    -- 表示形式「名前 (UserID)」からUserIDを抽出
    local userIdStr = selectedBlobmanTargetName:match("%((%d+)%)$")
    
    if userIdStr then
        local userId = tonumber(userIdStr)
        for _, player in pairs(Players:GetPlayers()) do
            if player.UserId == userId then
                return player
            end
        end
    end
    
    -- 念のため、UserIDで検索できなかった場合のフォールバック（RobloxのPlayer.Nameはユーザー名の方なので）
    local playerName = selectedBlobmanTargetName:match("^(.*)%s%(") or selectedBlobmanTargetName
    return Players:FindFirstChild(playerName)
end

-- ▼▼▼ 追加: 個別プレイヤー高速射出キックのトグル ▼▼▼
kickLoopToggle = BlobmanTab:AddToggle({
    Name = "選択プレイヤーを高速射出ループキック (New)", -- 名前を分かりやすく変更
    Default = false,
    Color = Color3.fromRGB(240, 0, 0),
    Save = false, -- 保存しない
    Callback = function(enabled)
        if enabled then
            -- 1. ブロブマンに乗っているか確認
            local foundBlobman = nil
            for i, v in pairs(game.Workspace:GetDescendants()) do
                if v:IsA("Model") and v.Name == "CreatureBlobman" then
                    if v:FindFirstChild("VehicleSeat") and v.VehicleSeat:FindFirstChild("SeatWeld") and isDescendantOf(v.VehicleSeat.SeatWeld.Part1, localPlayer.Character) then
                        foundBlobman = v
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
                kickLoopToggle:Set(false)
                return
            end

            -- 2. 対象プレイヤーを取得
            local targetPlayer = getTargetPlayerFromDropdown()

            if not targetPlayer or targetPlayer == localPlayer or not targetPlayer.Character then
                OrionLib:MakeNotification({
                    Name = "Error",
                    Content = "対象プレイヤーが見つからないか、無効です: " .. tostring(selectedBlobmanTargetName), 
                    Image = "rbxassetid://4483345998", 
                    Time = 5
                })
                kickLoopToggle:Set(false)
                return
            end
            
            -- 3. 実行
            blobmanKickLoopTargetPlayer = targetPlayer
            blobmanKickLoopCoroutine = coroutine.create(function()
                pcall(blobmanKickLoop, targetPlayer, foundBlobman)
                -- コルーチンが終了したらトグルをオフにする
                if kickLoopToggle and kickLoopToggle:Get() then
                     kickLoopToggle:Set(false)
                end
            end)
            coroutine.resume(blobmanKickLoopCoroutine)
            
        else
            -- 停止処理
            if blobmanKickLoopCoroutine then
                coroutine.close(blobmanKickLoopCoroutine)
                blobmanKickLoopCoroutine = nil
            end
            blobmanKickLoopTargetPlayer = nil
            OrionLib:MakeNotification({
                Name = "Stop",
                Content = "高速射出ループキックを停止しました", 
                Image = "rbxassetid://4483345998", 
                Time = 3
            })
        end
    end
})

-- 選択キック速度スライダー
BlobmanTab:AddSlider({
    Name = "射出速度の大きさ",
    Min = 1000,
    Max = 10000000,
    Color = Color3.fromRGB(240, 0, 0),
    ValueName = "Velocity",
    Increment = 1000,
    Default = _G.KickVelocityMagnitude,
    Save = true,
    Flag = "KickVelocityMagnitudeSlider",
    Callback = function(value)
        _G.KickVelocityMagnitude = value
    end
})

-- 選択キックループディレイスライダー
BlobmanTab:AddSlider({
    Name = "キックループ待機時間",
    Min = 0.1,
    Max = 5,
    Color = Color3.fromRGB(240, 0, 0),
    ValueName = "sec",
    Increment = 0.1,
    Default = _G.KickLoopDelay,
    Save = true,
    Flag = "KickLoopDelaySlider",
    Callback = function(value)
        _G.KickLoopDelay = value
    end
})


BlobmanTab:AddParagraph("注意: プレイヤーの入退室があった場合、リストは自動で更新されます。")

-- 手動更新ボタンを追加 (自動更新が失敗した場合のフォールバック)
BlobmanTab:AddButton({
    Name = "プレイヤーリストを更新",
    Callback = updateBlobmanDropdown
})

-- ▲▲▲ BlobmanTabの修正完了 ▲▲▲

local blobman1
blobman1 = BlobmanTab:AddToggle({
    Name = "Loop TP & Grab (全員対象)", -- 名前を分かりやすく変更
    Color = Color3.fromRGB(240, 0, 0),
    Default = false,
    Callback = function(enabled)
        if enabled then
            loopTpCoroutine = coroutine.create(function()
                local foundBlobman = false
                for i, v in pairs(game.Workspace:GetDescendants()) do
                    if v:IsA("Model") and v.Name == "CreatureBlobman" then
                        if v:FindFirstChild("VehicleSeat") and v.VehicleSeat:FindFirstChild("SeatWeld") and isDescendantOf(v.VehicleSeat.SeatWeld.Part1, localPlayer.Character) then
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
    Name = "TP & Grab Delay (全員対象ループ用)", -- 名前を分かりやすく変更
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

-- ▼▼▼ 古い版から移植 (FunTab) ▼▼▼
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
                local connection = RunService.Heartbeat:Connect(function()
                    updateDecoyPositions()
                end)
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
        connections = {} -- 接続テーブルをクリア
    end
})
-- ▲▲▲ 移植完了 ▲▲▲

-- ▼▼▼ 古い版から移植 (ScriptTab) ▼▼▼
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
-- ▲▲▲ 移植完了 ▲▲▲

-- ▼▼▼ 古い版から移植 (AuraTab) ▼▼▼
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
                while true do
                    local success, err = pcall(function()
                        local character = localPlayer.Character
                        if character and character:FindFirstChild("Head") and character:FindFirstChild("HumanoidRootPart") then
                            local head = character.Head
                            local humanoidRootPart = character.HumanoidRootPart

                            for _, player in pairs(Players:GetPlayers()) do
                                coroutine.wrap(function()
                                    if player ~= localPlayer and player.Character then
                                        local playerCharacter = player.Character
                                        local playerTorso = playerCharacter:FindFirstChild("Torso")
                                        if playerTorso then
                                            local distance = (playerTorso.Position - humanoidRootPart.Position).Magnitude
                                            if distance <= auraRadius then
                                                SetNetworkOwner:FireServer(playerTorso, playerCharacter.HumanoidRootPart.FirePlayerPart.CFrame)
                                                task.wait(0.1)
                                                local velocity = playerTorso:FindFirstChild("l") or Instance.new("BodyVelocity", playerTorso)
                                                velocity.Name = "l"
                                                velocity.Velocity = Vector3.new(0, 50, 0)
                                                velocity.MaxForce = Vector3.new(0, math.huge, 0)
                                                Debris:AddItem(velocity, 100)
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
                                            force.Force = Vector3.new(0, -1200, 0) -- 修正: 奈落なのでマイナス方向
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
                                                SetNetworkOwner:FireServer(playerCharacter:WaitForChild("HumanoidRootPart").FirePlayerPart, playerCharacter.HumanoidRootPart.FirePlayerPart.CFrame)
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
                                        if platform then platform:Destroy() end -- 修正: nilチェック
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
                })
                coroutine.resume(kickCoroutine)
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
                                                SetNetworkOwner:FireServer(playerCharacter:WaitForChild("HumanoidRootPart").FirePlayerPart, playerCharacter.HumanoidRootPart.FirePlayerPart.CFrame)
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
                        wait(0.02)
                    end
                end)
                coroutine.resume(kickCoroutine)
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
    Options = {"サイレント", "空"},
    Default = "サイレント", -- 修正: デフォルト値を設定
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
    Color = Color3.fromRGB(240, 0, 0),
    Save = true,
    Callback = function(enabled)
        if enabled then
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
                                            while distance <= auraRadius and player.Character and player.Character:FindFirstChild("Torso") do -- 修正: ループ条件追加
                                                SetNetworkOwner:FireServer(playerTorso, playerCharacter.HumanoidRootPart.CFrame)
                                                distance = (playerTorso.Position - humanoidRootPart.Position).Magnitude
                                                for _, part in pairs(poisonHurtParts) do
                                                    part.Size = Vector3.new(1, 3, 1)
                                                    part.Transparency = 1
                                                    part.Position = head.Position
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
        elseif poisonAuraCoroutine then
            coroutine.close(poisonAuraCoroutine)
            for _, part in pairs(poisonHurtParts) do
                part.Position = Vector3.new(0, -200, 0)
            end
            poisonAuraCoroutine = nil
        end
    end
})
-- ▲▲▲ 移植完了 ▲▲▲

-- ▼▼▼ 古い版から移植 (CharacterTab) ▼▼▼
CharacterTab:AddToggle({
    Name = "しゃがみ速度",
    Default = false,
    Save = true,
    Color = Color3.fromRGB(240, 0, 0),
    Flag = "CrouchSpeed",
    Callback = function(enabled)
        if enabled then
            crouchSpeedCoroutine = coroutine.create(function()
                while true do
                    pcall(function()
                        if not playerCharacter or not playerCharacter:FindFirstChild("Humanoid") then return end -- 修正: playerCharacter nilチェック
                        if playerCharacter.Humanoid.WalkSpeed == 5 then
                            playerCharacter.Humanoid.WalkSpeed = crouchWalkSpeed
                        end
                    end)
                    wait()
                end
            end)
            coroutine.resume(crouchSpeedCoroutine)
        elseif crouchSpeedCoroutine then
            coroutine.close(crouchSpeedCoroutine)
            crouchSpeedCoroutine = nil
            if playerCharacter and playerCharacter:FindFirstChild("Humanoid") then -- 修正: nilチェック
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
                while true do
                    pcall(function()
                        if not playerCharacter or not playerCharacter:FindFirstChild("Humanoid") then return end -- 修正: nilチェック
                        if playerCharacter.Humanoid.JumpPower == 12 then
                            playerCharacter.Humanoid.JumpPower = crouchJumpPower
                        end
                    end)
                    wait()
                end
            end)
            coroutine.resume(crouchJumpCoroutine)
        elseif crouchJumpCoroutine then
            coroutine.close(crouchJumpCoroutine)
            crouchJumpCoroutine = nil
            if playerCharacter and playerCharacter:FindFirstChild("Humanoid") then -- 修正: nilチェック
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
-- ▲▲▲ 移植完了 ▲▲▲


ExplosionTab:AddDropdown({
    Name = "トイロード",
    Default = "BombMissile",
    Options = {"BombMissile", "FireworkMissile"},
    Callback = function(Value)
        _G.ToyToLoad = Value
    end    
})

-- ▼▼▼ 古い版から移植 (ExplosionTab Max missiles) ▼▼▼
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
-- ▲▲▲ 移植完了 ▲▲▲

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

-- ▼▼▼ 古い版から移植 (KeybindsTab) ▼▼▼
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
            if character:IsA("Model") and character:FindFirstChildOfClass("Humanoid") then
                SetNetworkOwner:FireServer(character.HumanoidRootPart, character.HumanoidRootPart.CFrame)
                for _, part in ipairs(character:GetDescendants()) do
                    if part:IsA("BasePart") or part:IsA("Part") then
                        part.CanCollide = false
                    end
                end

                local bodyVelocity = Instance.new("BodyVelocity")
                bodyVelocity.Parent = character.Torso
                bodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                bodyVelocity.Velocity = Vector3.new(0, -40, 0) -- 修正: 速度を少し上げた
                character.Torso.CanCollide = false
                task.wait(1)
                character.Torso.CanCollide = false
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
            if character:IsA("Model") and character:FindFirstChildOfClass("Humanoid") then
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
                    -- 修正: ループが止まらない問題を修正 (コルーチン化)
                    coroutine.wrap(function()
                        while character and character.Parent and platform and platform.Parent do
                            wait()
                            if character:FindFirstChild("HumanoidRootPart") then
                                platform.Position = character.HumanoidRootPart.Position - Vector3.new(0, 3.994, 0)
                            else
                                break -- HRPがなくなったら終了
                            end
                        end 
                        if platform then platform:Destroy() end -- ループ終了時にプラットフォーム削除
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
            if character:IsA("Model") and character:FindFirstChildOfClass("Humanoid") then
                SetNetworkOwner:FireServer(character.HumanoidRootPart, character.HumanoidRootPart.CFrame)
                SetNetworkOwner:FireServer(character.Head, character.Head.CFrame)
                for _, motor in pairs(character.Torso:GetChildren()) do
                    SetNetworkOwner:FireServer(character.Head, character.Head.CFrame)
                    if motor:IsA('Motor6D') then motor:Destroy() end
                end
                task.wait(0.5)
                SetNetworkOwner:FireServer(character.Head, character.Head.CFrame)
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
            if character:IsA("Model") and character:FindFirstChildOfClass("Humanoid") then
                if not toysFolder:FindFirstChild("Campfire") then
                    spawnItem("Campfire", Vector3.new(-72.9304581, -5.96906614, -265.543732))
                end
                local campfire = toysFolder:WaitForChild("Campfire") -- 修正: WaitForChild
                local firePlayerPart
                SetNetworkOwner:FireServer(character.HumanoidRootPart, character.HumanoidRootPart.CFrame)
                for _, part in pairs(campfire:GetChildren()) do
                    if part.Name == "FirePlayerPart" then
                        part.Size = Vector3.new(9, 9, 9)
                        firePlayerPart = part
                        break
                    end
                end
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
        spawnItemCf("BombMissile", playerCharacter.Head.CFrame or playerCharacter.HumanoidRootPart.CFrame)
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
        spawnItemCf("FireworkMissile", playerCharacter.Head.CFrame or playerCharacter.HumanoidRootPart.CFrame)
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

        local bomb = table.remove(bombList, 1)

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
                    ["PositionPart"] = localPlayer.Character.HumanoidRootPart or localPlayer.Character.PrimaryPart
            },
            [2] = localPlayer.Character.HumanoidRootPart.Position or localPlayer.Character.PrimaryPart.Position
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
        for i = #bombList, 1, -1 do
            local bomb = table.remove(bombList, i)
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
                    ["PositionPart"] = localPlayer.Character.HumanoidRootPart or localPlayer.Character.PrimaryPart
                },
                [2] = localPlayer.Character.HumanoidRootPart.Position or localPlayer.Character.PrimaryPart.Position
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
        local nearest = getNearestPlayer() -- 修正: 先にプレイヤー取得
        if not nearest or not nearest.Character then 
            OrionLib:MakeNotification({Name = "Error", Content = "最も近いプレイヤーが見つかりませんでした", Image = "rbxassetid://4483345998", Time = 2})
            return 
        end
        local char = nearest.Character
        for i = #bombList, 1, -1 do
            local bomb = table.remove(bombList, i)
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
-- ▲▲▲ 移植完了 ▲▲▲


DevTab:AddToggle({
    Name = "ラグドールオール",
    Color = Color3.fromRGB(240, 0, 0),
    Default = false,
    Save = true,
    Callback = function(enabled)
        if enabled then
            ragdollAllCoroutine = coroutine.create(ragdollAll)
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

RunService.Heartbeat:Connect(function(dt)
    if AutoSitEnabled then
        local foundBlobman
        for _, v in pairs(game.Workspace:GetDescendants()) do
            if v:IsA("Model") and v.Name == "CreatureBlobman" then
                foundBlobman = v
                break
            end
        end
        if foundBlobman then
            local VehicleSeat = foundBlobman:FindFirstChild("VehicleSeat")
            local Character = localPlayer.Character
            if VehicleSeat and Character and Character.Humanoid and Character.Humanoid.SeatPart == nil then
                VehicleSeat:Sit(Character.Humanoid)
            end
        end
    end
end)

localPlayer.CharacterAdded:Connect(function(character)
    playerCharacter = character
    if AutoSitEnabled then
        wait(1)
        local foundBlobman
        for _, v in pairs(game.Workspace:GetDescendants()) do
            if v:IsA("Model") and v.Name == "CreatureBlobman" then
                foundBlobman = v
                break
            end
        end
        if foundBlobman then
            local VehicleSeat = foundBlobman:FindFirstChild("VehicleSeat")
            if VehicleSeat and character.Humanoid and character.Humanoid.SeatPart == nil then
                VehicleSeat:Sit(character.Humanoid)
            end
        end
    end
end)

game:GetService("Players").PlayerRemoving:Connect(function(player)
    if player == localPlayer then
        if loopTpCoroutine then coroutine.close(loopTpCoroutine) end
        if blobmanCoroutine then coroutine.close(blobmanCoroutine) end -- 移植された可能性のあるコルーチンを閉じる
        if blobmanKickLoopCoroutine then coroutine.close(blobmanKickLoopCoroutine) end -- 追加: 新規コルーチンを閉じる
    end
    -- PlayerRemoving の自動更新処理は冒頭のPlayers.PlayerRemoving:Connectで対応済み
end)

OrionLib:MakeNotification({
    Name = "Welcome", 
    Content = "ようこそ、野獣のおちんちんハブへ", 
    Image = "rbxassetid://4483345998", 
    Time = 5
})

OrionLib:Init()

-- スクリプト起動時に一度ドロップダウンを初期化
updateBlobmanDropdown()

print("🎮 野獣のおちんちんハブ - スクリプト読み込み完了!")
print("✅ すべての機能が正常に初期化されました")
