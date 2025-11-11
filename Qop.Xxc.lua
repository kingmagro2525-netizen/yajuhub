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

-- 😈 新しいグローバル変数の追加
AutoSitEnabled = false
-- 😈 ループTP機能用の新しい変数の追加
LoopTpEnabled = false
local loopTpCoroutine 
local currentLoopTpPlayerIndex = 1
local tpAllCoroutine -- TP All トグル用のコルーチン
_G.TPDelay = 0.5 -- 😈 新しいグローバル変数: TP間の遅延 (秒)

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

local OrionLib = loadstring(game:HttpGet(("https://raw.githubusercontent.com/yua20170313a-pixel/Orion/e19e8236bde46c459fb0d617e4640aeb75878703/source")))()

--- Utilities (U) の実装 (途中までのコードから完全な定義を復元)
local Utilities = {}

-- Utilities.IsDescendantOf(child, parent)
function Utilities.IsDescendantOf(child, parent)
    local currentParent = child.Parent
    while currentParent do
        if currentParent == parent then
            return true
        end
        currentParent = currentParent.Parent
    end
    return false
end

-- Utilities.GetDescendant(parent, name, className)
function Utilities.GetDescendant(parent, name, className)
    for _, descendant in ipairs(parent:GetDescendants()) do
        if descendant.Name == name and (not className or descendant:IsA(className)) then
            return descendant
        end
    end
    return nil
end

-- Utilities.GetAncestor(child, name, className)
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

-- Utilities.FindFirstAncestorOfType(child, className)
function Utilities.FindFirstAncestorOfType(child, className)
    local currentParent = child.Parent
    while currentParent do
        if currentParent:IsA(className) then
            return currentParent
        end
        currentParent = currentParent.Parent
    end
    return nil
end

-- Utilities.GetChildrenByType(parent, className)
function Utilities.GetChildrenByType(parent, className)
    local results = {}
    for _, child in ipairs(parent:GetChildren()) do
        if child:IsA(className) then
            table.insert(results, child)
        end
    end
    return results
end

-- Utilities.GetDescendantsByType(parent, className)
function Utilities.GetDescendantsByType(parent, className)
    local results = {}
    for _, descendant in ipairs(parent:GetDescendants()) do
        if descendant:IsA(className) then
            table.insert(results, descendant)
        end
    end
    return results
end

-- Utilities.HasAttribute(instance, attributeName)
function Utilities.HasAttribute(instance, attributeName)
    return instance:GetAttribute(attributeName) ~= nil
end

-- Utilities.GetAttributeOrDefault(instance, attributeName, defaultValue)
function Utilities.GetAttributeOrDefault(instance, attributeName, defaultValue)
    local value = instance:GetAttribute(attributeName)
    return value ~= nil and value or defaultValue
end

-- Utilities.CloneInstance(instance, newParent)
function Utilities.CloneInstance(instance, newParent)
    local clone = instance:Clone()
    if newParent then
        clone.Parent = newParent
    end
    return clone
end

-- Utilities.WaitForChildOfType(parent, className, timeout)
function Utilities.WaitForChildOfType(parent, className, timeout)
    local startTime = tick()
    while timeout == nil or tick() - startTime < timeout do
        for _, child in ipairs(parent:GetChildren()) do
            if child:IsA(className) then
                return child
            end
        end
        RunService.Stepped:Wait() -- より正確な待機
    end
    return nil
end

-- Utilities.IsPointInPart(part, point)
function Utilities.IsPointInPart(part, point)
    local pointInPartSpace = part.CFrame:PointToObjectSpace(point)
    local size = part.Size
    return math.abs(pointInPartSpace.X) <= size.X / 2 and
           math.abs(pointInPartSpace.Y) <= size.Y / 2 and
           math.abs(pointInPartSpace.Z) <= size.Z / 2
end

-- Utilities.GetDistance(pointA, pointB)
function Utilities.GetDistance(pointA, pointB)
    return (pointA - pointB).Magnitude
end

-- Utilities.GetAngleBetweenVectors(vectorA, vectorB)
function Utilities.GetAngleBetweenVectors(vectorA, vectorB)
    local dotProduct = vectorA:Dot(vectorB)
    local magnitudeProduct = vectorA.Magnitude * vectorB.Magnitude
    if magnitudeProduct == 0 then return 0 end
    return math.acos(math.clamp(dotProduct / magnitudeProduct, -1, 1))
end

-- Utilities.RotateVectorY(vector, angle)
function Utilities.RotateVectorY(vector, angle)
    local cosA = math.cos(angle)
    local sinA = math.sin(angle)
    local x = vector.X * cosA - vector.Z * sinA
    local z = vector.X * sinA + vector.Z * cosA
    return Vector3.new(x, vector.Y, z)
end

-- Utilities.GetSurroundingVectors(target, radius, amount, offset)
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

-- Utilities のエイリアス (既存コードとの互換性のため)
local U = Utilities
--- Utilities (U) の実装ここまで


local followMode = true
local toysFolder = workspace:FindFirstChild(localPlayer.Name.."SpawnedInToys")
local playerList = {}
local selection 
local blobman 
local platforms = {}
local ownedToys = {}
local bombList = {}
_G.ToyToLoad = "BombMissile"
_G.MaxMissiles = 9
_G.BlobmanDelay = 0.05 -- 0.005から0.05に変更してYeet Modeのデフォルト値を分かりやすく


local function isDescendantOf(target, other)
    local currentParent = target.Parent
    while currentParent do
        if currentParent == other then
            return true
        end
        currentParent = currentParent.Parent
    end
    return false
end
local function DestroyT(toy)
    local toy = toy or toysFolder:FindFirstChildWhichIsA("Model")
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
        connection:Disconnect()
    end
    connectionTable = {}
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
    if not toysFolder:FindFirstChild("Campfire") then
        spawnItem("Campfire", Vector3.new(-72.9304581, -5.96906614, -265.543732))
    end
    local campfire = toysFolder:FindFirstChild("Campfire")
    burnPart = campfire:FindFirstChild("FirePlayerPart") or campfire.FirePlayerPart
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
        local success, err = pcall(function()
            local child = workspace:FindFirstChild("GrabParts")
            if child and child.Name == "GrabParts" then
                local grabPart = child:FindFirstChild("GrabPart")
                local weldConstraint = grabPart:FindFirstChild("WeldConstraint")
                if weldConstraint and weldConstraint.Part1 then
                    local grabbedPart = weldConstraint.Part1
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
                local weldConstraint = grabPart:FindFirstChild("WeldConstraint")
                if weldConstraint and weldConstraint.Part1 then
                    local grabbedPart = weldConstraint.Part1
                    local head = grabbedPart.Parent:FindFirstChild("Head")
                    if head then
                        arson(head)
                    end
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
                local weldConstraint = grabPart:FindFirstChild("WeldConstraint")
                if weldConstraint and weldConstraint.Part1 then
                    local grabbedPart = weldConstraint.Part1
                    local character = grabbedPart.Parent
                    if character.HumanoidRootPart then
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
        local success, err = pcall(function()
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

            local primaryPart = weldConstraint.Part1.Name == "SoundPart" and weldConstraint.Part1 or weldConstraint.Part1.Parent and weldConstraint.Part1.Parent:FindFirstChild("SoundPart") or weldConstraint.Part1.Parent and weldConstraint.Part1.Parent.PrimaryPart or weldConstraint.Part1
            if not primaryPart then return end
            if primaryPart.Anchored then return end

            if isDescendantOf(primaryPart, workspace.Map) then return end
            for _, player in pairs(Players:GetChildren()) do
                if player.Character and isDescendantOf(primaryPart, player.Character) then return end
            end
            local t = true
            for _, v in pairs(primaryPart:GetDescendants()) do
                if table.find(anchoredParts, v) then
                    t = false
                    break
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
                
                print(target)
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
        if part and part.Parent then
            if part:FindFirstChild("BodyPosition") then
                part.BodyPosition:Destroy()
            end
            if part:FindFirstChild("BodyGyro") then
                part.BodyGyro:Destroy()
            end
            local highlight = part:FindFirstChild("Highlight") or (part.Parent:IsA("Model") and part.Parent:FindFirstChild("Highlight"))
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

    local targetModel = U.FindFirstAncestorOfType(primaryPart, "Model") or primaryPart.Parent
    local highlight =  primaryPart:FindFirstChild("Highlight") or (targetModel and targetModel:FindFirstChild("Highlight"))
    if not highlight then
        highlight = createHighlight(targetModel or primaryPart)
    end
    highlight.OutlineColor = Color3.new(0, 1, 0) 
    

    local group = {}
    for _, part in ipairs(anchoredParts) do
        if part and part ~= primaryPart then
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
            local targetModel = U.FindFirstAncestorOfType(groupData.primaryPart, "Model") or groupData.primaryPart.Parent
            local highlight = groupData.primaryPart:FindFirstChild("Highlight") or (targetModel and targetModel:FindFirstChild("Highlight"))
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
                if groupData.primaryPart and groupData.primaryPart.Parent then
                    updateBodyMovers(groupData.primaryPart)
                end
            end
        end)
        wait()
    end
end

local function unanchorPrimaryPart()
    local primaryPart = anchoredParts[1]
    if not primaryPart then 
        OrionLib:MakeNotification({Name = "Error", Content = "No primary part to unanchor (anchor a part first)", Image = "rbxassetid://4483345998", Time = 3})
        return
    end
    if primaryPart:FindFirstChild("BodyPosition") then
        primaryPart.BodyPosition:Destroy()
    end
    if primaryPart:FindFirstChild("BodyGyro") then
        primaryPart.BodyGyro:Destroy()
    end
    local targetModel = U.FindFirstAncestorOfType(primaryPart, "Model") or primaryPart.Parent
    local highlight = primaryPart:FindFirstChild("Highlight") or (targetModel and targetModel:FindFirstChild("Highlight"))
    if highlight then
        highlight:Destroy()
    end
    -- 配列からも削除
    for i, part in ipairs(anchoredParts) do
        if part == primaryPart then
            table.remove(anchoredParts, i)
            break
        end
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
                    coroutine.wrap(function()
                        if partModel and partModel.Parent then
                            local distance = (partModel.Position - humanoidRootPart.Position).Magnitude
                            if distance <= 30 then
                                local targetModel = U.FindFirstAncestorOfType(partModel, "Model") or partModel.Parent
                                local highlight = partModel:FindFirstChild("Highlight") or (targetModel and targetModel:FindFirstChild("Highlight"))
                                
                                if highlight and highlight.OutlineColor == Color3.new(1, 0, 0) then
                                    SetNetworkOwner:FireServer(partModel, partModel.CFrame)
                                    -- PartOwnerがLocalPlayerに設定されるのを待つ
                                    local partOwner = partModel:WaitForChild("PartOwner", 0.5)
                                    if partOwner and partOwner.Value == localPlayer.Name then
                                        highlight.OutlineColor = Color3.new(0, 0, 1)
                                        print("yoyoyo set and r eady")
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
        local success, err = pcall(function()
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
        if not success then
            warn("Error in ragdollAll: " .. tostring(err))
        end
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
                            Debris:AddItem(connection, 60) -- 修正: connectionBombReloadではなくconnection
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
local function blobGrabPlayer(player, blobman)
    if blobalter == 1 then
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local args = {
                [1] = blobman:FindFirstChild("LeftDetector"),
                [2] = player.Character:FindFirstChild("HumanoidRootPart"),
                [3] = blobman:FindFirstChild("LeftDetector"):FindFirstChild("LeftWeld")
            }
            blobman:WaitForChild("BlobmanSeatAndOwnerScript"):WaitForChild("CreatureGrab"):FireServer(unpack(args))
            blobalter = 2
        end
    else
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local args = {
                [1] = blobman:FindFirstChild("RightDetector"),
                [2] = player.Character:FindFirstChild("HumanoidRootPart"),
                [3] = blobman:FindFirstChild("RightDetector"):FindFirstChild("RightWeld")
            }
            blobman:WaitForChild("BlobmanSeatAndOwnerScript"):WaitForChild("CreatureGrab"):FireServer(unpack(args))
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
if localVersion ~= version then

OrionLib:MakeNotification({Name = "スクリプトバージョンが違います!", Content = "あなたは野獣のおちんちんハブの古いバージョンを使っているため開けません", Image = "rbxassetid:// 4483345998", Time = 8})    
    setclipboard('loadstring(game:HttpGet("https://raw.githubusercontent.com/Undebolted/FTAP/main/Script.lua",true))()')
    wait(12)
    OrionLib:Destroy()
    wait(9e9)
end

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
                    local weldConstraint = model.GrabPart:FindFirstChild("WeldConstraint")
                    if weldConstraint and weldConstraint.Part1 then
                        local partToImpulse = weldConstraint.Part1
                        
                        local velocityObj = Instance.new("BodyVelocity", partToImpulse)
                        velocityObj.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                        
                        -- GrabPartsが削除されたときにBodyVelocityを適用するロジック
                        local removedConn
                        removedConn = model.AncestryChanged:Connect(function(_, newParent)
                            if not newParent then
                                removedConn:Disconnect()
                                if UserInputService:GetLastInputType() == Enum.UserInputType.MouseButton2 then
                                    velocityObj.Velocity = workspace.CurrentCamera.CFrame.LookVector * _G.strength
                                    Debris:AddItem(velocityObj, 1)
                                else
                                    velocityObj:Destroy()
                                end
                            end
                        end)
                        Debris:AddItem(removedConn, 60)
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
                -- クリーンアップ: プレイヤーがスポーンさせたキャンプファイヤーがあれば削除
                if toysFolder:FindFirstChild("Campfire") then
                    DestroyT(toysFolder:FindFirstChild("Campfire"))
                end
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
        if not compileCoroutine or coroutine.status(compileCoroutine) == "dead" then
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
                        -- 掴まれている間は一時的にアンカー
                        for _, part in pairs(character:GetChildren()) do
                            if part:IsA("BasePart") then
                                part.Anchored = true
                            end
                        end
                        while localPlayer.IsHeld and localPlayer.IsHeld.Value do
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
                if character and character:FindFirstChild("HumanoidRootPart") and character.HumanoidRootPart:FindFirstChild("FirePlayerPart") then
                    local partOwner = character.HumanoidRootPart.FirePlayerPart:FindFirstChild("PartOwner")
                    if partOwner and partOwner.Value ~= localPlayer.Name then
                        -- Ragdollを送信してFirePlayerPartからの接続を解除
                        local args = {[1] = character:WaitForChild("HumanoidRootPart"), [2] = 0}
                        game:GetService("ReplicatedStorage"):WaitForChild("CharacterEvents"):WaitForChild("RagdollRemote"):FireServer(unpack(args))
                        print("grabbity shap!")
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

local characterAddedConn
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
            -- アンカー解除
            if localPlayer.Character then
                for _, part in ipairs(localPlayer.Character:GetChildren()) do
                    if part:IsA("BasePart") and part.Anchored then
                        part.Anchored = false
                    end
                end
            end
        end
    end
})



DefenseTab:AddLabel("自己防御")

local autoDefendKickCoroutine
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
                        if partOwner and partOwner.Value ~= localPlayer.Name then
                            local attacker = Players:FindFirstChild(partOwner.Value)
                            if attacker and attacker.Character then
                                Struggle:FireServer()
                                SetNetworkOwner:FireServer(attacker.Character.Head or attacker.Character.Torso, attacker.Character.HumanoidRootPart.FirePlayerPart.CFrame)
                                task.wait(0.1)
                                local target = attacker.Character:FindFirstChild("Torso")
                                if target then
                                    local velocity = target:FindFirstChild("l") or Instance.new("BodyVelocity", target)
                                    velocity.Name = "l"
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
                    if character and character:FindFirstChild("HumanoidRootPart") and character.HumanoidRootPart:FindFirstChild("FirePlayerPart") then
                        local head = character:FindFirstChild("Head")
                        if head then
                            local partOwner = head:FindFirstChild("PartOwner")
                            if partOwner and partOwner.Value ~= localPlayer.Name then
                                local attacker = Players:FindFirstChild(partOwner.Value)
                                if attacker and attacker.Character and attacker.Character.HumanoidRootPart and attacker.Character.HumanoidRootPart:FindFirstChild("FirePlayerPart") then
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
local yeetMode = false

local function blobGrabPlayerYeet(player, blobman)
    if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then
        return
    end
    
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
    
    -- 掴む
    blobman:WaitForChild("BlobmanSeatAndOwnerScript"):WaitForChild("CreatureGrab"):FireServer(unpack(args))
    
    if yeetMode then
        -- 投げ飛ばしモードがONの場合、掴んだ後すぐに解除（または再試行/高速な掴み/解除）を行う
        -- このロジックが掴み/解除の繰り返しを実現していると解釈
        wait(_G.BlobmanDelay) -- 投げ飛ばし速度スライダーの値を使用
        local releaseArgs = {
            [1] = detector,
            [2] = player.Character.HumanoidRootPart,
            [3] = weld
        }
        -- Yeet Modeの場合、同じ引数でもう一度FireServerを呼び出すことでGrabを即座に解除/再試行していると仮定
        blobman:WaitForChild("BlobmanSeatAndOwnerScript"):WaitForChild("CreatureGrab"):FireServer(unpack(releaseArgs))
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
            blobmanCoroutine = coroutine.create(function()
                local foundBlobman = false
                
                for i, v in pairs(game.Workspace:GetDescendants()) do
                    if v.Name == "CreatureBlobman" then
                        print("Found CreatureBlobman")
                        local vehicleSeat = v:FindFirstChild("VehicleSeat")
                        -- VehicleSeatが存在し、かつプレイヤーが座っている（SeatWeldのPart1がプレイヤーのキャラクタの一部）ことを確認
                        if vehicleSeat and vehicleSeat:FindFirstChild("SeatWeld") and isDescendantOf(vehicleSeat.SeatWeld.Part1, localPlayer.Character) then
                            print("Mounted on blobman")
                            blobman = v
                            foundBlobman = true
                            break
                        end
                    end
                end
                
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
                                wait(0.02) -- Yeet ModeがOFFの時はこの遅延で実行
                            end
                        end
                    end)
                    wait(0.02)
                end
            end)
            coroutine.resume(blobmanCoroutine)
        else
            if blobmanCoroutine then
                coroutine.close(blobmanCoroutine)
                blobmanCoroutine = nil
                blobman = nil
            end
        end
    end
})

-- 😈 自動着席トグルの追加
BlobmanTab:AddToggle({
    Name = "Auto Sit",
    Desc = "オンにすると、ブロブマンを召喚したとき、または降りた後に自動的に座ります。",
    Type = "Toggle",
    Default = AutoSitEnabled,
    Color = Color3.fromRGB(240, 0, 0),
    Save = true,
    Flag = "AutoSitToggle",
    Callback = function(State)
        AutoSitEnabled = State
    end
})


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
    Default = _G.BlobmanDelay,
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

-- 😈 TP All 機能の追加
BlobmanTab:AddParagraph("TP All 機能", "全プレイヤーを一人ずつ少し下にテレポートさせます。")

local tpAllToggle = BlobmanTab:AddToggle({
    Name = "TP All",
    Color = Color3.fromRGB(0, 200, 255),
    Default = false,
    Callback = function(enabled)
        if enabled then
            tpAllCoroutine = coroutine.create(function()
                while enabled do
                    local playersToTP = Players:GetPlayers()
                    -- 自分自身を除外
                    local filteredPlayers = {}
                    for _, player in ipairs(playersToTP) do
                        if player ~= localPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                            table.insert(filteredPlayers, player)
                        end
                    end
                    
                    for _, player in ipairs(filteredPlayers) do
                        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                            local hrp = player.Character.HumanoidRootPart
                            -- プレイヤーの現在の位置から少し下の位置を計算
                            local targetPosition = hrp.Position - Vector3.new(0, 1, 0)
                            
                            -- テレポート処理
                            -- 通常、テレポートはCFrameを直接設定することで行います
                            -- ただし、セキュリティ上の理由からCFrameの設定がブロックされる場合があるため、MoveToを使用する可能性も考慮しますが、ここではCFrameを設定します
                            -- サーバー側の処理がないため、クライアント側で可能な限り動作させる
                            
                            -- ネットワーク所有権を取得してからテレポートを試みる（ほとんどの環境では無効なことが多いが、一応試みる）
                            SetNetworkOwner:FireServer(hrp, hrp.CFrame)
                            
                            -- クライアント側のテレポート
                            pcall(function()
                                hrp.CFrame = CFrame.new(targetPosition)
                            end)
                            
                            -- テレポート間隔で待機
                            wait(_G.TPDelay)
                        end
                    end
                    
                    -- 全プレイヤーをテレポートした後、次のサイクルまで短い間隔で待機
                    wait(0.1) 
                end
            end)
            coroutine.resume(tpAllCoroutine)
        else
            if tpAllCoroutine then
                coroutine.close(tpAllCoroutine)
                tpAllCoroutine = nil
            end
        end
    end
})

BlobmanTab:AddSlider({
    Name = "TP Delay (秒)",
    Min = 0.05,
    Max = 3,
    Color = Color3.fromRGB(0, 200, 255),
    ValueName = "秒",
    Increment = 0.05,
    Default = _G.TPDelay,
    Callback = function(value)
        _G.TPDelay = value
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
                                            force.Force = Vector3.new(0, 1200, 0)
                                        else
                                            local force = playerTorso:FindFirstChild("GravityForce")
                                            if force then
                                                force:Destroy()
                                                for _, part in ipairs(playerCharacter:GetDescendants()) do
                                                    if part:IsA("BasePart") then
                                                        part.CanCollide = true
                                                    end
                                                end
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
        elseif gravityCoroutine then
            coroutine.close(gravityCoroutine)
            gravityCoroutine = nil
            -- クリーンアップ
            for _, player in pairs(Players:GetPlayers()) do
                if player.Character then
                    local playerTorso = player.Character:FindFirstChild("Torso")
                    if playerTorso then
                        local force = playerTorso:FindFirstChild("GravityForce")
                        if force then
                            force:Destroy()
                        end
                    end
                    for _, part in ipairs(player.Character:GetDescendants()) do
                        if part:IsA("BasePart") then
                            part.CanCollide = true
                        end
                    end
                end
            end
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
            if auraToggle == 1 then -- サイレント
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
                                        if platform then platform:Destroy() end
                                        platforms[player] = nil
                                    end
                                end
                            end
                        end)
                        if not success then
                            warn("Error in Kick Aura (Silent mode): " .. tostring(err))
                        end
                        wait(0.02)
                    end
                end)
                coroutine.resume(kickCoroutine)
            elseif auraToggle == 2 then -- 空
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
                                                local fpp = playerCharacter.HumanoidRootPart.FirePlayerPart
                                                if not fpp:FindFirstChild("BodyVelocity") then
                                                    local bodyVelocity = Instance.new("BodyVelocity")
                                                    bodyVelocity.Name = "BodyVelocity"
                                                    bodyVelocity.Velocity = Vector3.new(0, 20, 0) 
                                                    bodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                                                    bodyVelocity.Parent = fpp
                                                end
                                            else
                                                -- 距離外に出たらBodyVelocityを削除
                                                local fpp = playerCharacter.HumanoidRootPart.FirePlayerPart
                                                local bodyVelocity = fpp:FindFirstChild("BodyVelocity")
                                                if bodyVelocity then bodyVelocity:Destroy() end
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
                -- クリーンアップ: サイレントモードで作成されたプラットフォームを削除
                for _, platform in pairs(platforms) do
                    if platform then
                        platform:Destroy()
                    end
                end
                platforms = {}
                -- クリーンアップ: 空モードで作成されたBodyVelocityを削除
                for _, player in pairs(Players:GetPlayers()) do
                    if player.Character and player.Character.HumanoidRootPart and player.Character.HumanoidRootPart:FindFirstChild("FirePlayerPart") then
                        local bodyVelocity = player.Character.HumanoidRootPart.FirePlayerPart:FindFirstChild("BodyVelocity")
                        if bodyVelocity then bodyVelocity:Destroy() end
                    end
                end
            end
        end
    end
})

AuraTab:AddDropdown({
    Name = "キックの種類",
    Options = {"サイレント", "空"}, -- オプションの順序を修正して、Toggleのロジックに合わせる
    Default = "サイレント",
    Save = true,
    Flag = "KickModeFlag",
    Callback = function(selected)
        -- 'サイレント'がauraToggle = 1、'空'がauraToggle = 2に対応
        if selected == "空" then 
            auraToggle = 2 
        else 
            auraToggle = 1 
        end
        -- Kick AuraがONの場合、モード切り替えを反映するために一度OFF/ONを行う必要があるかもしれないが、
        -- ここではトグルを切る操作は行わない。ユーザーに再起動を促す。
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
                                    local head = playerCharacter:FindFirstChild("Head")
                                    if playerTorso and head then
                                        local distance = (playerTorso.Position - humanoidRootPart.Position).Magnitude
                                        if distance <= auraRadius then
                                            SetNetworkOwner:FireServer(playerTorso, playerCharacter.HumanoidRootPart.CFrame)
                                            -- 距離内にとどまっている間、毒パーツを頭部に移動
                                            while distance <= auraRadius and playerCharacter.Parent do
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
                        if not playerCharacter.Humanoid then return end
                        -- プレイヤーが通常歩行速度（16）からしゃがみ速度（5）に切り替わった場合を検出
                        if playerCharacter.Humanoid.WalkSpeed < 10 and playerCharacter.Humanoid.WalkSpeed > 0 then
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
            if playerCharacter.Humanoid then
                -- クリーンアップとしてデフォルト速度に戻す
                if playerCharacter.Humanoid.WalkSpeed == crouchWalkSpeed then
                    playerCharacter.Humanoid.WalkSpeed = 16
                end
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
                        if not playerCharacter.Humanoid then return end
                        -- プレイヤーが通常ジャンプ力（50）からしゃがみジャンプ力（12）に切り替わった場合を検出
                        if playerCharacter.Humanoid.JumpPower < 20 then
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
            if playerCharacter.Humanoid then
                 -- クリーンアップとしてデフォルトジャンプ力に戻す
                if playerCharacter.Humanoid.JumpPower == crouchJumpPower then
                    playerCharacter.Humanoid.JumpPower = 50 
                end
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
    Default = tostring(circleRadius),
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
        
        cleanupConnections(connections) -- 古い接続をクリア

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
                local bodyPosition = torso:FindFirstChild("BodyPosition") or Instance.new("BodyPosition")
                local bodyGyro = torso:FindFirstChild("BodyGyro") or Instance.new("BodyGyro")
                
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
        OrionLib:MakeNotification({
            Name = "Mode Toggled",
            Content = followMode and "Mode: Follow" or "Mode: Surround",
            Image = "rbxassetid://4483345998", 
            Time = 2
        })
    end
})

FunTab:AddButton({
    Name = "Disconnect Clones",
    Callback = function() 
        cleanupConnections(connections)
        -- BodyMoversの削除
        for _, descendant in pairs(workspace:GetDescendants()) do
            if descendant:IsA("Model") and descendant.Name == "YouDecoy" then
                local torso = descendant:FindFirstChild("Torso")
                if torso then
                    for _, child in ipairs(torso:GetChildren()) do
                        if child:IsA("BodyMover") then
                            child:Destroy()
                        end
                    end
                end
            end
        end
        connections = {}
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
            local character = U.FindFirstAncestorOfType(target, "Model")
            if target.Name == "FirePlayerPart" then
                character = target.Parent and U.FindFirstAncestorOfType(target.Parent, "Model")
            end
            if character and character:FindFirstChildOfClass("Humanoid") and character ~= playerCharacter then
                SetNetworkOwner:FireServer(character.HumanoidRootPart, character.HumanoidRootPart.CFrame)
                for _, part in ipairs(character:GetDescendants()) do
                    if part:IsA("BasePart") or part:IsA("Part") then
                        part.CanCollide = false
                    end
                end

                local bodyVelocity = Instance.new("BodyVelocity")
                bodyVelocity.Parent = character.Torso
                bodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                bodyVelocity.Velocity = Vector3.new(0, -4, 0)
                character.Torso.CanCollide = false
                Debris:AddItem(bodyVelocity, 5) -- 5秒後に削除
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
            local character = U.FindFirstAncestorOfType(target, "Model")
            if target.Name == "FirePlayerPart" then
                character = target.Parent and U.FindFirstAncestorOfType(target.Parent, "Model")
            end
            if character and character:FindFirstChildOfClass("Humanoid") and character ~= playerCharacter and character:FindFirstChild("HumanoidRootPart") then
                local hrp = character.HumanoidRootPart
                if kickMode == 1 then -- 空 (Sky)
                    SetNetworkOwner:FireServer(hrp.FirePlayerPart, hrp.FirePlayerPart.CFrame)
                    local bodyVelocity = Instance.new("BodyVelocity")
                    bodyVelocity.Parent = hrp.FirePlayerPart
                    bodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                    bodyVelocity.Velocity = Vector3.new(0, 20, 0)
                    Debris:AddItem(bodyVelocity, 1) -- 短時間で削除
                elseif kickMode == 2 then -- サイレント (Silent)
                    SetNetworkOwner:FireServer(hrp.FirePlayerPart, hrp.FirePlayerPart.CFrame)
                    local platform = Instance.new("Part")
                    platform.Name = "FloatingPlatform"
                    platform.Size = Vector3.new(5, 2, 5)
                    platform.Anchored = true
                    platform.Transparency = 1
                    platform.CanCollide = true
                    platform.Parent = character
                    local platformCoroutine 
                    platformCoroutine = RunService.Heartbeat:Connect(function()
                        if character.Humanoid and character.Humanoid.Health > 0 and character.HumanoidRootPart then
                            platform.Position = character.HumanoidRootPart.Position - Vector3.new(0, 3.994, 0)
                        else
                            platformCoroutine:Disconnect()
                            platform:Destroy()
                        end
                    end)
                    Debris:AddItem(platformCoroutine, 10) -- 接続を短時間で削除
                    Debris:AddItem(platform, 10) -- プラットフォームを短時間で削除
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
            local character = U.FindFirstAncestorOfType(target, "Model")
            if target.Name == "FirePlayerPart" then
                character = target.Parent and U.FindFirstAncestorOfType(target.Parent, "Model")
            end
            if character and character:FindFirstChildOfClass("Humanoid") and character ~= playerCharacter then
                SetNetworkOwner:FireServer(character.HumanoidRootPart, character.HumanoidRootPart.CFrame)
                SetNetworkOwner:FireServer(character.Head, character.Head.CFrame)
                -- Motor6Dを破壊することでラグドール状態にする（キルにはならない可能性あり）
                for _, motor in pairs(character.Torso:GetChildren()) do
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
            local character = U.FindFirstAncestorOfType(target, "Model")
            if target.Name == "FirePlayerPart" then
                character = target.Parent and U.FindFirstAncestorOfType(target.Parent, "Model")
            end
            if character and character:FindFirstChildOfClass("Humanoid") and character ~= playerCharacter and character:FindFirstChild("HumanoidRootPart") then
                if not toysFolder:FindFirstChild("Campfire") then
                    spawnItem("Campfire", Vector3.new(-72.9304581, -5.96906614, -265.543732))
                end
                local campfire = toysFolder.Campfire
                local firePlayerPart
                SetNetworkOwner:FireServer(character.HumanoidRootPart, character.HumanoidRootPart.CFrame)
                for _, part in pairs(campfire:GetChildren()) do
                    if part.Name == "FirePlayerPart" then
                        part.Size = Vector3.new(9, 9, 9)
                        firePlayerPart = part
                        break
                    end
                end
                if firePlayerPart then
                    firePlayerPart.Position = character.Head.Position or character.HumanoidRootPart.Position
                    task.wait(0.5)
                    firePlayerPart.Position = Vector3.new(0, -50, 0)
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
        Debris:AddItem(connection, 2) -- 2秒後に接続を削除
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
        Debris:AddItem(connection, 2) -- 2秒後に接続を削除
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
        Debris:AddItem(connection, 2) -- 2秒後に接続を削除
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
                    ["PositionPart"] = localPlayer.Character and (localPlayer.Character.HumanoidRootPart or localPlayer.Character.PrimaryPart)
            },
            [2] = localPlayer.Character and (localPlayer.Character.HumanoidRootPart.Position or localPlayer.Character.PrimaryPart.Position)
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
                    ["PositionPart"] = localPlayer.Character and (localPlayer.Character.HumanoidRootPart or localPlayer.Character.PrimaryPart)
                },
                [2] = localPlayer.Character and (localPlayer.Character.HumanoidRootPart.Position or localPlayer.Character.PrimaryPart.Position)
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
        if not nearestPlayer or not nearestPlayer.Character then
            OrionLib:MakeNotification({Name = "No Player", Content = "No nearest player found", Image = "rbxassetid://4483345998", Time = 2})
            return
        end

        local char = nearestPlayer.Character
        local targetPart = char.HumanoidRootPart or char.Torso or char.PrimaryPart
        if not targetPart then
             OrionLib:MakeNotification({Name = "No Target Part", Content = "Target player has no primary part", Image = "rbxassetid://4483345998", Time = 2})
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
                    ["PositionPart"] = targetPart
                },
                [2] = targetPart.Position
            }
            ReplicatedStorage:WaitForChild("BombEvents"):WaitForChild("BombExplode"):FireServer(unpack(args))
        end
    end
})

KeybindSection2:AddToggle({
    Name = "無視してください", -- lightbit (UFO) 機能のトグル
    Default = false,
    Color = Color3.fromRGB(240, 0, 0),
    Save = false,
    Callback = function(enabled)
		if enabled then
			-- 初期化とセットアップ
            lightbitparts = {}
            bodyPositions = {}
            alignOrientations = {}
            
			for i, v in pairs(toysFolder:GetChildren()) do
				if v.Name ~= "ToyNumber" and v.PrimaryPart then
                    local part = v.PrimaryPart
					table.insert(lightbitparts, part)
					
					-- 衝突を無効化
					for _, p in pairs(v:GetDescendants()) do
						if p:IsA("BasePart") then
							p.CanCollide = false
						end
					end
            
                    -- BodyPosition
					local bodyPosition = Instance.new("BodyPosition")
					bodyPosition.P = 15000
					bodyPosition.D = 200
					bodyPosition.MaxForce = Vector3.new(5000000, 5000000, 5000000)
					bodyPosition.Parent = part
					bodyPosition.Position = part.Position
					table.insert(bodyPositions, bodyPosition)

                    -- AlignOrientation
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
                    
                    SetNetworkOwner:FireServer(part, part.CFrame) -- ネットワーク所有権を取得
				end
			end
            
            -- メインループ
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
                        -- プレイヤーのHumanoidRootPartの位置に向ける
                        local lookAtCFrame = CFrame.lookAt(part.Position, localPlayer.Character.HumanoidRootPart.Position)
                        alignOrientations[i].CFrame = lookAtCFrame
                    end
				end
			end)
		else
            -- クリーンアップ
            if lightorbitcon then
                pcall(function()
                    lightorbitcon:Disconnect()
                end)
                lightorbitcon = nil
            end
			
			for i, v in ipairs(lightbitparts) do
                if v and v.Parent then
                    -- 衝突を有効化
                    for _, p in pairs(v:GetDescendants()) do
                        if p:IsA("BasePart") then
                            p.CanCollide = true
                        end
                    end
                    -- Attachmentを削除
                    local attachment = v:FindFirstChild("Attachment")
                    if attachment then attachment:Destroy() end
                end
			end
            
            -- BodyMoversの削除
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
    Name = "開発者向けの秘密のキーバインド（あなたには何も起こりません）",
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
        Debris:AddItem(lightbitcon, 1) -- 短期間で切断されるように設定
    end
})
KeybindSection2:AddBind({
    Name = "開発者向けのもう一つの小さなキーバインド（あなたには何も影響しません）",
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
        Debris:AddItem(lightbitcon2, 1) -- 短期間で切断されるように設定
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
            ragdollAllCoroutine = coroutine.create(ragdollAll)
            coroutine.resume(ragdollAllCoroutine)
        else
            if ragdollAllCoroutine then
                coroutine.close(ragdollAllCoroutine)
                ragdollAllCoroutine = nil
                -- クリーンアップ: プレイヤーがスポーンさせたバナナがあれば削除
                if toysFolder:FindFirstChild("FoodBanana") then
                    DestroyT(toysFolder:FindFirstChild("FoodBanana"))
                end
            end
        end
    end
})

-- Qopテーブルはここでは不要ですが、一応残します
local Qop = {} 

-- RunService.HeartbeatにQop.Updateのロジックと自動着席ロジックを統合
RunService.Heartbeat:Connect(function(dt)
    -- 😈 自動着席ロジックの実行
    if AutoSitEnabled then
        local foundBlobman
        for _, v in pairs(game.Workspace:GetDescendants()) do
            if v.Name == "CreatureBlobman" then
                -- 車両のネットワーク所有者がLocalPlayerであることを確認する方が安全かもしれないが、ここでは単純化
                foundBlobman = v
                break
            end
        end
        
        if foundBlobman then
            local VehicleSeat = foundBlobman:FindFirstChild("VehicleSeat")
            local Character = localPlayer.Character
            
            -- VehicleSeatが存在し、かつプレイヤーが乗り物などに座っていないことを確認
            if VehicleSeat and Character and Character.Humanoid and Character.Humanoid.SeatPart == nil then
                -- ブロブマンのSeatに座る
                VehicleSeat:Sit(Character.Humanoid)
            end
        end
    end
end)


OrionLib:MakeNotification({Name = "Welcome", Content = "ようこそ、野獣のおちんちんハブへ", Image = "rbxassetid://4483345998", Time = 5})
OrionLib:Init()
