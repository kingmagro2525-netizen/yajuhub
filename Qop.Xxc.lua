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

local AutoSitEnabled = false
local loopTpCoroutine
local currentLoopTpPlayerIndex = 1

_G.strength = 400
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
        if connection and typeof(connection) == "RBXScriptConnection" then
            pcall(function() connection:Disconnect() end)
        end
    end
end

local function getVersion()
    local success, response = pcall(function()
        return game:HttpGet("https://raw.githubusercontent.com/kingmagro2525-netizen/yajuhub/main/Qop.Xxc.version.lua")
    end)
    if success then
        local data = HttpService:JSONDecode(response)
        return data.version
    else
        warn("Failed to get version: " .. tostring(response))
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
            blobman:WaitForChild("BlobmanSeatAndOwnerScript"):WaitForChild("CreatureGrab"):FireServer(unpack(args))
            blobalter = 2
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
            blobman:WaitForChild("BlobmanSeatAndOwnerScript"):WaitForChild("CreatureGrab"):FireServer(unpack(args))
            blobalter = 1
        end
    end
end

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
local version = getVersion()

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

local localVersion = "1-beta"
if localVersion ~= version then
    OrionLib:MakeNotification({Name = "スクリプトバージョンが違います!", Content = "あなたは野獣のおちんちんハブの古いバージョンを使っているため開けません", Image = "rbxassetid://4483345998", Time = 8})  
    setclipboard('loadstring(game:HttpGet("https://raw.githubusercontent.com/Undebolted/FTAP/main/Script.lua",true))()')
    wait(12)
    OrionLib:Destroy()
    wait(9e9)
end

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

local GrabTab = Window:MakeTab({Name = "グラブ", Icon = "rbxassetid://18624615643", PremiumOnly = false})
local ObjectGrabTab = Window:MakeTab({Name = "オブジェクトグラブ", Icon = "rbxassetid://18624606749", PremiumOnly = false})
local DefenseTab = Window:MakeTab({Name = "ディフェンス", Icon = "rbxassetid://18624604880", PremiumOnly = false})
local BlobmanTab = Window:MakeTab({Name = "ブロブマン", Icon = "rbxassetid://18624614127", PremiumOnly = false})
local FunTab = Window:MakeTab({Name = "楽しい", Icon = "rbxassetid://18624603093", PremiumOnly = false})
local ScriptTab = Window:MakeTab({Name = "他スクリプト", Icon = "rbxassetid://11570626783", PremiumOnly = false})
local AuraTab = Window:MakeTab({Name = "オーラ", Icon = "rbxassetid://18624608005", PremiumOnly = false})
local CharacterTab = Window:MakeTab({Name = "キャラクター", Icon = "rbxassetid://18624601543", PremiumOnly = false})
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

local blobman1
blobman1 = BlobmanTab:AddToggle({
    Name = "Loop TP & Grab (Player to Target)",
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
    Name = "TP & Grab Delay",
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

ExplosionTab:AddDropdown({
    Name = "トイロード",
    Default = "BombMissile",
    Options = {"BombMissile", "FireworkMissile"},
    Callback = function(Value)
        _G.ToyToLoad = Value
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
    end
end)

OrionLib:MakeNotification({
    Name = "Welcome", 
    Content = "ようこそ、野獣のおちんちんハブへ", 
    Image = "rbxassetid://4483345998", 
    Time = 5
})

OrionLib:Init()

print("🎮 野獣のおちんちんハブ - スクリプト読み込み完了!")
print("📌 バージョン: " .. version)
print("✅ すべての機能が正常に初期化されました")
