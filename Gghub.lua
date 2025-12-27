local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")

local antiLagEnabled = false
local oldNamecall
oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
    local method = getnamecallmethod()
    if antiLagEnabled and method == "FireServer" then
        if tostring(self) == "Look" then
            return
        end
    end
    return oldNamecall(self, ...)
end)

local GrabEvents = ReplicatedStorage:WaitForChild("GrabEvents", 5)
local MenuToys = ReplicatedStorage:WaitForChild("MenuToys", 5)
local CharacterEvents = ReplicatedStorage:WaitForChild("CharacterEvents", 5)
local SetNetworkOwner = GrabEvents and GrabEvents:WaitForChild("SetNetworkOwner", 5)
local Struggle = CharacterEvents and CharacterEvents:WaitForChild("Struggle", 5)
local CreateLine = GrabEvents and GrabEvents:WaitForChild("CreateGrabLine", 5)
local DestroyLine = GrabEvents and GrabEvents:WaitForChild("DestroyGrabLine", 5)
local DestroyToy = MenuToys and MenuToys:WaitForChild("DestroyToy", 5)

if not (SetNetworkOwner and Struggle and CreateLine and DestroyLine and DestroyToy) then
    warn("Failed to find necessary remote events/functions. Script may not function correctly.")
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

local antiVoidCoroutine
local antiFlingCoroutine
local excludeFriends = true 

local AutoSitEnabled = false
local loopTpCoroutine
local currentLoopTpPlayerIndex = 1
local blobman
local isSpawningBlobmanForSit = false 

_G.ToyToLoad = "BombMissile"
_G.MaxMissiles = 9
_G.BlobmanDelay = 0.05
_G.AntiGucciBlob = nil -- Added for Anti-Gucci

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

local OrionLib = loadstring(game:HttpGet(("https://raw.githubusercontent.com/Polinorsik/Orion-Z-Library/refs/heads/main/README.md")))()

local whitelistedPlayers = {} 
local selectedWhitelistPlayerName = ""
local selectedTeleportPlayerName = ""

local whitelistDropdown = nil
local teleportDropdown = nil
local whitelistLabel = nil

local function formatPlayerName(player)
    local name = player.DisplayName and player.DisplayName ~= "" and player.DisplayName or player.Name
    return name .. " (" .. player.Name .. ")"
end

local function parsePlayerName(formattedName)
    if not formattedName or formattedName == "No Players" or formattedName == "Loading..." then return "" end
    local playerName = string.match(formattedName, "%((.-)%)")
    if not playerName then
        local namePart = string.match(formattedName, "^(.-)%s*%(");
        if namePart then return namePart end
    end
    return playerName or formattedName
end

function isWhitelisted(player)
    if not player then return false end
    if player == localPlayer then return true end
    
    if excludeFriends then
        local success, isFriend = pcall(function()
            return localPlayer:IsFriendsWith(player.UserId)
        end)
        if success and isFriend then
            return true
        end
    end

    return whitelistedPlayers[player.Name]
end

function updateWhitelistLabel()
    if not whitelistLabel then return end
    local names = {}
    for name, _ in pairs(whitelistedPlayers) do
        table.insert(names, name)
    end
    if #names > 0 then
        whitelistLabel:Set("Current Whitelist: " .. table.concat(names, ", "))
    else
        whitelistLabel:Set("Current Whitelist: None")
    end
end

local function getPlayerOptions()
    local options = {}
    local pList = Players:GetPlayers()
    
    table.sort(pList, function(a, b) 
        local nameA = a.DisplayName or a.Name
        local nameB = b.DisplayName or b.Name
        return nameA < nameB
    end)

    for _, player in ipairs(pList) do
        if player ~= localPlayer then
            table.insert(options, formatPlayerName(player))
        end
    end

    if #options == 0 then
        return {"No Players"}
    end
    return options
end

function updatePlayerDropdowns()
    if not teleportDropdown or not whitelistDropdown then return end
    local newOptions = getPlayerOptions()
    teleportDropdown:Refresh(newOptions, true)
    whitelistDropdown:Refresh(newOptions, true)
end

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

local function getLocalRoot()
    if not playerCharacter then return nil end
    return playerCharacter:FindFirstChild("HumanoidRootPart") or playerCharacter:FindFirstChild("Torso")
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
    if not DestroyToy or not toy then return end
    toy = toy or toysFolder:FindFirstChildWhichIsA("Model")
    if toy then
        DestroyToy:FireServer(toy)
    end
end

local function getDescendantParts(descendantName)
    local parts = {}
    if not workspace.Map then return parts end
    for _, descendant in ipairs(workspace.Map:GetDescendants()) do
        if descendant:IsA("Part") and descendant.Name == descendantName then
            table.insert(parts, descendant)
        end
    end
    return parts
end

local poisonHurtParts = getDescendantParts("PoisonHurtPart")
local paintPlayerParts = getDescendantParts("PaintPlayerPart")

local menuGui = localPlayer:WaitForChild("PlayerGui", 10):FindFirstChild("MenuGui")
if menuGui then
    local toysContent = menuGui:FindFirstChild("Menu"):FindFirstChild("TabContents"):FindFirstChild("Toys"):FindFirstChild("Contents")
    if toysContent then
        for _, v in pairs(toysContent:GetChildren()) do
            if v.Name ~= "UIGridLayout" then
                ownedToys[v.Name] = true
            end
        end
    else
         warn("Could not find Toys Contents in MenuGui.")
    end
else
    warn("Could not find MenuGui.")
end

local function getNearestPlayer()
    local nearestPlayer
    local nearestDistance = math.huge
    local localHRP = playerCharacter and playerCharacter:FindFirstChild("HumanoidRootPart")
    
    if not localHRP then return nil end

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= localPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") and not isWhitelisted(player) then
            local distance = (localHRP.Position - player.Character.HumanoidRootPart.Position).Magnitude
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

local function spawnItem(itemName, position, orientation)
    if not ReplicatedStorage.MenuToys.SpawnToyRemoteFunction then 
        warn("SpawnToyRemoteFunction not found.")
        return 
    end
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
    if not campfire then return end

    local burnPart = campfire:FindFirstChild("FirePlayerPart") or campfire.FirePlayerPart
    if not burnPart then return end
    
    burnPart.Size = Vector3.new(7, 7, 7)
    burnPart.Position = part.Position
    task.wait(0.3)
    burnPart.Position = Vector3.new(0, -50, 0)
end

local function handleCharacterAdded(player)
    local connection = player.CharacterAdded:Connect(function(character)
        local hrp = character:WaitForChild("HumanoidRootPart", 5)
        if not hrp then return end
        
        local fpp = hrp:WaitForChild("FirePlayerPart", 5)
        if fpp then
            fpp.Size = Vector3.new(4.5, 5, 4.5)
            fpp.CollisionGroup = "1"
            fpp.CanQuery = true
        end
    end)
    table.insert(kickGrabConnections, connection)
end

local function kickGrab()
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
end

local function grabHandler(grabType)
    while true do
        pcall(function()
            local grabParts = workspace:FindFirstChild("GrabParts")
            if not grabParts then RunService.Heartbeat:Wait(); return end

            local grabPart = grabParts:FindFirstChild("GrabPart")
            if not grabPart then RunService.Heartbeat:Wait(); return end
            
            local weldConstraint = grabPart:FindFirstChild("WeldConstraint")
            if not weldConstraint or not weldConstraint.Part1 then RunService.Heartbeat:Wait(); return end
            
            local grabbedPart = weldConstraint.Part1
            local character = grabbedPart.Parent
            local head = character:FindFirstChild("Head")

            if head then
                local player = Players:GetPlayerFromCharacter(character)
                if isWhitelisted(player) then RunService.Heartbeat:Wait(); return end

                local partsTable = grabType == "poison" and poisonHurtParts or paintPlayerParts
                
                while workspace:FindFirstChild("GrabParts") do
                    for _, part in pairs(partsTable) do
                        part.Size = Vector3.new(2, 2, 2)
                        part.Transparency = 1
                        part.Position = head.Position
                    end
                    RunService.Heartbeat:Wait()
                end
                
                for _, part in pairs(partsTable) do
                    part.Position = Vector3.new(0, -200, 0)
                end
            end
        end)
        RunService.Heartbeat:Wait()
    end
end

local function fireGrab()
    while true do
        pcall(function()
            local grabParts = workspace:FindFirstChild("GrabParts")
            if not grabParts then RunService.Heartbeat:Wait(); return end
            
            local grabPart = grabParts:FindFirstChild("GrabPart")
            if not grabPart then RunService.Heartbeat:Wait(); return end
            
            local weldConstraint = grabPart:FindFirstChild("WeldConstraint")
            if not weldConstraint or not weldConstraint.Part1 then RunService.Heartbeat:Wait(); return end
            
            local grabbedPart = weldConstraint.Part1
            local character = grabbedPart.Parent
            local head = character:FindFirstChild("Head")

            if head then
                local player = Players:GetPlayerFromCharacter(character)
                if isWhitelisted(player) then RunService.Heartbeat:Wait(); return end 
                arson(head)
            end
        end)
        RunService.Heartbeat:Wait()
    end
end

local function noclipGrab()
    while true do
        pcall(function()
            local grabParts = workspace:FindFirstChild("GrabParts")
            if not grabParts then RunService.Heartbeat:Wait(); return end
            
            local grabPart = grabParts:FindFirstChild("GrabPart")
            if not grabPart then RunService.Heartbeat:Wait(); return end
            
            local weldConstraint = grabPart:FindFirstChild("WeldConstraint")
            if not weldConstraint or not weldConstraint.Part1 then RunService.Heartbeat:Wait(); return end
        
            local character = weldConstraint.Part1.Parent
            if character and character:FindFirstChild("HumanoidRootPart") then
                local player = Players:GetPlayerFromCharacter(character)
                if isWhitelisted(player) then RunService.Heartbeat:Wait(); return end

                local partsToToggle = {}
                for _, part in pairs(character:GetChildren()) do
                    if part:IsA("BasePart") then
                        table.insert(partsToToggle, part)
                    end
                end

                while workspace:FindFirstChild("GrabParts") do
                    for _, part in pairs(partsToToggle) do
                        part.CanCollide = false
                    end
                    RunService.Heartbeat:Wait()
                end
                
                for _, part in pairs(partsToToggle) do
                    part.CanCollide = true
                end
            end
        end)
        RunService.Heartbeat:Wait()
    end
end

local function spawnItemCf(itemName, cframe)
    if not ReplicatedStorage.MenuToys.SpawnToyRemoteFunction then 
        warn("SpawnToyRemoteFunction not found.")
        return 
    end
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
                task.wait(0.5)
            end
             
            local localHRP = getLocalRoot()
            if not localHRP then return end
            
            spawnItemCf("Campfire", localHRP.CFrame)
            
            local campfire = toysFolder:WaitForChild("Campfire", 5)
            if not campfire then return end
            
            local firePlayerPart = campfire:FindFirstChild("FirePlayerPart")
            if not firePlayerPart then 
                for _, part in pairs(campfire:GetChildren()) do
                    if part.Name == "FirePlayerPart" then
                        firePlayerPart = part
                        break
                    end
                end
            end
            if not firePlayerPart then return end

            firePlayerPart.Size = Vector3.new(10, 10, 10)
            
            local originalPosition = localHRP.Position
            
            if SetNetworkOwner then
                SetNetworkOwner:FireServer(firePlayerPart, firePlayerPart.CFrame)
            end
            
            localHRP:MoveTo(firePlayerPart.Position)
            task.wait(0.3)
            localHRP:MoveTo(originalPosition)
            
            local bodyPosition = Instance.new("BodyPosition")
            bodyPosition.P = 20000
            bodyPosition.Position = localHRP.Position + Vector3.new(0, 600, 0)
            bodyPosition.Parent = campfire.Main
            
            while true do
                for _, player in pairs(Players:GetChildren()) do
                    pcall(function()
                        local currentHRP = getLocalRoot()
                        if not currentHRP then return end
                        bodyPosition.Position = currentHRP.Position + Vector3.new(0, 600, 0)
                        
                        if player.Character and player.Character.HumanoidRootPart and player.Character ~= playerCharacter and not isWhitelisted(player) then
                            firePlayerPart.Position = player.Character.HumanoidRootPart.Position or player.Character.Head.Position
                            RunService.Heartbeat:Wait()
                        end
                    end)
                end  
                RunService.Heartbeat:Wait()
            end
        end)
        task.wait(0.1)
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
    if descendant.Name == "PartOwner" and primaryPart and primaryPart:FindFirstChild("Highlight") then
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
            if not grabParts then RunService.Heartbeat:Wait(); return end
            
            local grabPart = grabParts:FindFirstChild("GrabPart")
            if not grabPart then RunService.Heartbeat:Wait(); return end
            
            local weldConstraint = grabPart:FindFirstChild("WeldConstraint")
            if not weldConstraint or not weldConstraint.Part1 then RunService.Heartbeat:Wait(); return end
            
            local grabbedPart = weldConstraint.Part1
            local primaryPart = grabbedPart.Name == "SoundPart" and grabbedPart or grabbedPart.Parent.SoundPart or grabbedPart.Parent.PrimaryPart or grabbedPart
            
            if not primaryPart then RunService.Heartbeat:Wait(); return end
            if primaryPart.Anchored then RunService.Heartbeat:Wait(); return end
            if isDescendantOf(primaryPart, workspace.Map) then RunService.Heartbeat:Wait(); return end
            for _, player in pairs(Players:GetChildren()) do
                if isDescendantOf(primaryPart, player.Character) then RunService.Heartbeat:Wait(); return end
            end
            
            local isAlreadyTracked = false
            for _, v in pairs(anchoredParts) do
                if v == primaryPart then isAlreadyTracked = true; break end
            end
            
            if not isAlreadyTracked then
                local target = U.FindFirstAncestorOfType(primaryPart, "Model") or primaryPart
                local highlight = createHighlight(target)
                table.insert(anchoredParts, primaryPart)
                local connection = target.DescendantAdded:Connect(function(descendant)
                    onPartOwnerAdded(descendant, primaryPart)
                end)
                table.insert(anchoredConnections, connection)
            end
            
            local modelToClean = U.FindFirstAncestorOfType(primaryPart, "Model") or primaryPart
            for _, child in ipairs(modelToClean:GetDescendants()) do
                if child:IsA("BodyPosition") or child:IsA("BodyGyro") then
                    child:Destroy()
                end
            end
            
            while workspace:FindFirstChild("GrabParts") do
                RunService.Heartbeat:Wait()
            end
            
            createBodyMovers(primaryPart, primaryPart.Position, primaryPart.CFrame)
        end)
        RunService.Heartbeat:Wait()
    end
end

local function anchorKickGrab()
    while true do
        pcall(function()
            local grabParts = workspace:FindFirstChild("GrabParts")
            if not grabParts then RunService.Heartbeat:Wait(); return end
            
            local grabPart = grabParts:FindFirstChild("GrabPart")
            if not grabPart then RunService.Heartbeat:Wait(); return end
            
            local weldConstraint = grabPart:FindFirstChild("WeldConstraint")
            if not weldConstraint or not weldConstraint.Part1 then RunService.Heartbeat:Wait(); return end
            
            local primaryPart = weldConstraint.Part1
            if not primaryPart then RunService.Heartbeat:Wait(); return end
            if isDescendantOf(primaryPart, workspace.Map) then RunService.Heartbeat:Wait(); return end
            if primaryPart.Name ~= "FirePlayerPart" then RunService.Heartbeat:Wait(); return end
            
            for _, child in ipairs(primaryPart:GetChildren()) do
                if child:IsA("BodyPosition") or child:IsA("BodyGyro") then
                    child:Destroy()
                end
            end
            
            while workspace:FindFirstChild("GrabParts") do
                RunService.Heartbeat:Wait()
            end
            
            createBodyMovers(primaryPart, primaryPart.Position, primaryPart.CFrame)
        end)
        RunService.Heartbeat:Wait()
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
            
            local highlight = part:FindFirstChild("Highlight") 
            if not highlight then 
                local parentModel = U.FindFirstAncestorOfType(part, "Model")
                if parentModel and parentModel ~= workspace then
                    highlight = parentModel:FindFirstChild("Highlight")
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
    for _, group in ipairs(compiledGroups) do
        if group.primaryPart and group.primaryPart == primaryPart then
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
    
    local primaryPart = anchoredParts[1]
    if not primaryPart or not primaryPart.Parent then return end
    
    local isAlreadyCompiled = false
    for _, groupData in ipairs(compiledGroups) do
        if groupData.primaryPart == primaryPart then
            isAlreadyCompiled = true
            break
        end
    end
    if isAlreadyCompiled then
         OrionLib:MakeNotification({Name = "Info", Content = "This primary part is already compiled.", Image = "rbxassetid://4483345998", Time = 3})
         return
    end

    OrionLib:MakeNotification({Name = "Success", Content = "Compiled "..#anchoredParts.." Toys together", Image = "rbxassetid://4483345998", Time = 5})
    
    local highlight = primaryPart:FindFirstChild("Highlight") or primaryPart.Parent:FindFirstChild("Highlight")
    if not highlight then
        highlight = createHighlight(primaryPart.Parent:IsA("Model") and primaryPart.Parent or primaryPart)
    end
    highlight.OutlineColor = Color3.new(0, 1, 0)
    
    local group = {}
    for _, part in ipairs(anchoredParts) do
        if part and part.Parent and part ~= primaryPart then
            local offset = primaryPart.CFrame:toObjectSpace(part.CFrame)
            table.insert(group, {part = part, offset = offset})
        end
    end
    
    table.insert(compiledGroups, {primaryPart = primaryPart, group = group})
    
    local connection = primaryPart:GetPropertyChangedSignal("CFrame"):Connect(function()
        updateBodyMovers(primaryPart)
    end)
    table.insert(compileConnections, connection)
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
            local highlight = groupData.primaryPart:FindFirstChild("Highlight") or (groupData.primaryPart.Parent:IsA("Model") and groupData.primaryPart.Parent:FindFirstChild("Highlight"))
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
        RunService.Heartbeat:Wait()
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
    
    local highlight = primaryPart:FindFirstChild("Highlight") or (primaryPart.Parent:IsA("Model") and primaryPart.Parent:FindFirstChild("Highlight"))
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
                        if partModel and partModel.Parent then
                            local distance = (partModel.Position - humanoidRootPart.Position).Magnitude
                            if distance <= 30 then
                                local highlight = partModel:FindFirstChild("Highlight") or partModel.Parent:FindFirstChild("Highlight")
                                if highlight and highlight.OutlineColor == Color3.new(1, 0, 0) then
                                    if SetNetworkOwner then
                                        SetNetworkOwner:FireServer(partModel, partModel.CFrame)
                                    end
                                    local partOwner = partModel:WaitForChild("PartOwner", 1)
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
        task.wait(0.02)
    end
end

local function ragdollAll()
    while true do
        pcall(function()
            if not toysFolder:FindFirstChild("FoodBanana") then
                spawnItem("FoodBanana", Vector3.new(-72.9304581, -5.96906614, -265.543732))
            end
            local banana = toysFolder:WaitForChild("FoodBanana", 5)
            if not banana then return end

            local bananaPeel = banana:FindFirstChild("BananaPeel")
            if not bananaPeel or not bananaPeel:FindFirstChild("TouchInterest") then 
                for _, part in pairs(banana:GetChildren()) do
                    if part.Name == "BananaPeel" and part:FindFirstChild("TouchInterest") then
                        bananaPeel = part
                        break
                    end
                end
            end

            if not bananaPeel then return end
            
            bananaPeel.Size = Vector3.new(10, 10, 10)
            bananaPeel.Transparency = 1
            
            local bodyPosition = banana.Main:FindFirstChild("BodyPosition")
            if not bodyPosition then
                bodyPosition = Instance.new("BodyPosition")
                bodyPosition.P = 20000
                bodyPosition.Parent = banana.Main
            end

            local localHRP = getLocalRoot()
            if not localHRP then return end
            
            while true do
                for _, player in pairs(Players:GetChildren()) do
                    pcall(function()
                        if player.Character and player.Character ~= playerCharacter and not isWhitelisted(player) then
                            local playerHRP = player.Character:FindFirstChild("HumanoidRootPart")
                            local playerHead = player.Character:FindFirstChild("Head")
                            
                            if playerHRP or playerHead then
                                bananaPeel.Position = (playerHRP and playerHRP.Position) or (playerHead and playerHead.Position) or Vector3.new(0, -50, 0)
                                bodyPosition.Position = localHRP.Position + Vector3.new(0, 600, 0)
                                RunService.Heartbeat:Wait()
                            end
                        end
                    end)
                end  
                RunService.Heartbeat:Wait()
            end
        end)
        task.wait(0.1)
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
        
        if reloadBombCoroutine then return end

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
                        
                        if SetNetworkOwner then
                           SetNetworkOwner:FireServer(child.Body, child.Body.CFrame)
                        end
                        
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
            
            while true do
                if localPlayer:FindFirstChild("CanSpawnToy") and localPlayer.CanSpawnToy.Value and #bombList < _G.MaxMissiles and playerCharacter:FindFirstChild("Head") then
                    spawnItemCf(_G.ToyToLoad, playerCharacter.Head.CFrame or playerCharacter.HumanoidRootPart.CFrame)
                end
                RunService.Heartbeat:Wait()
            end
        end)
        coroutine.resume(reloadBombCoroutine)
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
    local humanoid = character:WaitForChild("Humanoid", 5)
    if not humanoid then return end

    local ragdolled = humanoid:FindFirstChild("Ragdolled")
    if not ragdolled then 
        warn("Ragdolled IntValue not found in Humanoid.")
        return 
    end
    
    local partOwnerChangedConn
    partOwnerChangedConn = ragdolled:GetPropertyChangedSignal("Value"):Connect(function()
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
    antiExplosionConnection = partOwnerChangedConn
end

local blobalter = 1
local function blobGrabPlayerTP(targetPlayer, blobman)
    if not targetPlayer or targetPlayer == localPlayer or not targetPlayer.Character or not targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
        return
    end
    
    if isWhitelisted(targetPlayer) then return end
    
    local targetHRP = targetPlayer.Character.HumanoidRootPart
    local playerHRP = localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart")
    
    if not playerHRP or not SetNetworkOwner then return end
    
    SetNetworkOwner:FireServer(targetHRP, targetHRP.CFrame)

    local targetPos = targetHRP.CFrame
    
    playerHRP.CFrame = targetPos * CFrame.new(0, 5, 0)
    task.wait(_G.BlobmanDelay / 2)
    
    local blobmanHRP = blobman.PrimaryPart or blobman:FindFirstChild("Head") or blobman:FindFirstChild("Body")
    if blobmanHRP then
        blobmanHRP.CFrame = targetPos * CFrame.new(0, 1, 0)
    end
    task.wait(_G.BlobmanDelay / 2)
    
    local script = blobman:WaitForChild("BlobmanSeatAndOwnerScript", 0.5)
    if not script then return end
    local creatureGrab = script:WaitForChild("CreatureGrab", 0.5)
    if not creatureGrab then return end

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
            creatureGrab:FireServer(unpack(args))
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
            creatureGrab:FireServer(unpack(args))
            blobalter = 1
        end
    end
end

local function loopTPFunction(blobman)
    if not blobman then return end
    while true do
        local playersToTarget = {}
        for _, p in pairs(Players:GetPlayers()) do
            local isHeldValue = p:FindFirstChild("IsHeld")
            if p ~= localPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") and (isHeldValue and isHeldValue.Value == false) and not isWhitelisted(p) then
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
            task.wait(0.5)
        end
        
        task.wait(_G.BlobmanDelay)
    end
end

local Window = OrionLib:MakeWindow({
    Name = "野獣ハブ", 
    HidePremium = false,
    SaveConfig = true,
    ConfigFolder = "YajuuHubGemini",
    IntroEnabled = true,
    IntroText = "野獣ハブ", 
    IntroIcon = "rbxassetid://4483345998",
    Icon = "rbxassetid://4483345998"
})

local GrabTab = Window:MakeTab({Name = "グラブ", Icon = "rbxassetid://18624615643", PremiumOnly = false})
local ObjectGrabTab = Window:MakeTab({Name = "オブジェクトグラブ", Icon = "rbxassetid://18624606749", PremiumOnly = false})
local DefenseTab = Window:MakeTab({Name = "ディフェンス", Icon = "rbxassetid://18624604880", PremiumOnly = false})
local BlobmanTab = Window:MakeTab({Name = "ブロブマン", Icon = "rbxassetid://18624614127", PremiumOnly = false})
local FunTab = Window:MakeTab({Name = "楽しい", Icon = "rbxassetid://18624603093", PremiumOnly = false})
local ScriptTab = Window:MakeTab({Name = "他スクリプト", Icon = "rbxassetid://11570626783", PremiumOnly = false})
local AuraTab = Window:MakeTab({Name = "オーラ", Icon = "rbxassetid://18624608005", PremiumOnly = false})
local CharacterTab = Window:MakeTab({Name = "キャラクター", Icon = "rbxassetid://18624601543", PremiumOnly = false})
local TeleportTab = Window:MakeTab({Name = "テレポート", Icon = "rbxassetid://4483345998", PremiumOnly = false}) 
local WhitelistTab = Window:MakeTab({Name = "ホワイトリスト", Icon = "rbxassetid://18624604880", PremiumOnly = false}) 
local ExplosionTab = Window:MakeTab({Name = "爆弾", Icon = "rbxassetid://18624610285", PremiumOnly = false})
local KeybindsTab = Window:MakeTab({Name = "キービエンス", Icon = "rbxassetid://18624616682", PremiumOnly = false})
local DevTab = Window:MakeTab({Name = "デベロッパーテスト", Icon = "rbxassetid://18624599762", PremiumOnly = false})

local ThrowPower = 400

local TeleportSec = TeleportTab:AddSection({Name = "テレポート"})

teleportDropdown = TeleportSec:AddDropdown({
    Name = "テレポートしたいプレイヤー",
    Options = getPlayerOptions(),
    Default = "プレイヤーが選択されていない",
    Callback = function(formattedName)
        selectedTeleportPlayerName = parsePlayerName(formattedName)
    end
})

TeleportSec:AddButton({Name = "選択プレイヤーにテレポート", Callback = function()
    local t = selectedTeleportPlayerName ~= "" and Players:FindFirstChild(selectedTeleportPlayerName)
    local root = getLocalRoot()
    if t and t.Character and t.Character:FindFirstChild("HumanoidRootPart") and root then
        root.CFrame = t.Character.HumanoidRootPart.CFrame
    else
        OrionLib:MakeNotification({Name = "Error", Content = "Could not find player: " .. selectedTeleportPlayerName, Image = "rbxassetid://4483345998", Time = 3})
    end
end})

TeleportSec:AddButton({Name = "スポーン地点", Callback = function() if getLocalRoot() then getLocalRoot().CFrame = CFrame.new(1, -10, -2) end end})

local TPs = {
    {Name="農場の家", CF=CFrame.new(-234, 85, -311)},
    {Name="青い家", CF=CFrame.new(525, 98, -375)},
    {Name="空の家", CF=CFrame.new(138, 365, 346)},
    {Name="丘の上にある家", CF=CFrame.new(-325, 109, 337)},
    {Name="赤い家", CF=CFrame.new(584, 141, -100)},
    {Name="ピンクの家", CF=CFrame.new(-525, 22, -165)},
    {Name="黒い家", CF=CFrame.new(303, 14, 483)},
    {Name="緑の家", CF=CFrame.new(-572, 20, 89)},
    {Name="汽車の洞窟", CF=CFrame.new(571, 48, -153)},
    {Name="小さい洞窟", CF=CFrame.new(-50, -7, -298)},
    {Name="でかい洞窟", CF=CFrame.new(-130, -7, 575)}
}
for _, tp in ipairs(TPs) do
    TeleportSec:AddButton({Name = tp.Name, Callback = function() if getLocalRoot() then getLocalRoot().CFrame = tp.CF end end})
end

local WhitelistSec = WhitelistTab:AddSection({Name = "ホワイトリスト選択"})

WhitelistSec:AddParagraph("ホワイトリストに入れるプレイヤーを選択します")

WhitelistSec:AddToggle({
    Name = "フレンド自動除外",
    Default = true,
    Save = true,
    Flag = "AutoExcludeFriends",
    Callback = function(enabled)
        excludeFriends = enabled
    end
})

whitelistDropdown = WhitelistSec:AddDropdown({
    Name = "プレイヤー選択",
    Options = getPlayerOptions(),
    Default = "プレイヤーがいない",
    Callback = function(formattedName)
        selectedWhitelistPlayerName = parsePlayerName(formattedName)
    end
})

WhitelistSec:AddButton({
    Name = "ホワイトリストに追加",
    Callback = function()
        if selectedWhitelistPlayerName ~= "" and not whitelistedPlayers[selectedWhitelistPlayerName] then
            whitelistedPlayers[selectedWhitelistPlayerName] = true
            OrionLib:MakeNotification({Name = "Whitelist", Content = "Added " .. selectedWhitelistPlayerName .. " to whitelist.", Image = "rbxassetid://4483345998", Time = 3})
            updateWhitelistLabel()
        elseif selectedWhitelistPlayerName == "" then
             OrionLib:MakeNotification({Name = "Error", Content = "No player selected.", Image = "rbxassetid://4483345998", Time = 3})
        else
             OrionLib:MakeNotification({Name = "Info", Content = selectedWhitelistPlayerName .. " is already whitelisted.", Image = "rbxassetid://4483345998", Time = 3})
        end
    end
})

WhitelistSec:AddButton({
    Name = "ホワイトリストから削除",
    Callback = function()
        if selectedWhitelistPlayerName ~= "" and whitelistedPlayers[selectedWhitelistPlayerName] then
            whitelistedPlayers[selectedWhitelistPlayerName] = nil
            OrionLib:MakeNotification({Name = "Whitelist", Content = "Removed " .. selectedWhitelistPlayerName .. " from whitelist.", Image = "rbxassetid://4483345998", Time = 3})
            updateWhitelistLabel()
        elseif selectedWhitelistPlayerName == "" then
             OrionLib:MakeNotification({Name = "Error", Content = "プレイヤーが選択されていない", Image = "rbxassetid://4483345998", Time = 3})
        else
             OrionLib:MakeNotification({Name = "Info", Content = selectedWhitelistPlayerName .. " is not in the whitelist.", Image = "rbxassetid://4483345998", Time = 3})
        end
    end
})

whitelistLabel = WhitelistSec:AddLabel("Current Whitelist: None")

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
    Name = "アンチラグ",
    Default = false,
    Save = true,
    Color = Color3.fromRGB(240, 0, 0),
    Flag = "AntiLagLook",
    Callback = function(enabled)
        antiLagEnabled = enabled
    end
})

DefenseTab:AddToggle({
    Name = "アンチヴォイド",
    Default = false,
    Save = true,
    Color = Color3.fromRGB(240, 0, 0),
    Flag = "AntiVoid",
    Callback = function(enabled)
        if enabled then
            antiVoidCoroutine = RunService.Heartbeat:Connect(function()
                if localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart") then
                    local hrp = localPlayer.Character.HumanoidRootPart
                    if hrp.Position.Y < -50 then
                        hrp.CFrame = CFrame.new(hrp.Position.X, 100, hrp.Position.Z)
                        hrp.Velocity = Vector3.new(0,0,0)
                    end
                end
            end)
        else
            if antiVoidCoroutine then antiVoidCoroutine:Disconnect() end
        end
    end
})

DefenseTab:AddToggle({
    Name = "アンチフライング",
    Default = false,
    Save = true,
    Color = Color3.fromRGB(240, 0, 0),
    Flag = "AntiFling",
    Callback = function(enabled)
        if enabled then
            antiFlingCoroutine = RunService.Heartbeat:Connect(function()
                if localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart") then
                    local hrp = localPlayer.Character.HumanoidRootPart
                    if hrp.AssemblyLinearVelocity.Magnitude > 300 then
                        hrp.AssemblyLinearVelocity = Vector3.new(0,0,0)
                        hrp.AssemblyAngularVelocity = Vector3.new(0,0,0)
                    end
                end
            end)
        else
            if antiFlingCoroutine then antiFlingCoroutine:Disconnect() end
        end
    end
})

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
                if character and character:FindFirstChild("Head") and Struggle and ReplicatedStorage.GameCorrectionEvents:FindFirstChild("StopAllVelocity") then
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
                            RunService.Heartbeat:Wait()
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
            local ragdollRemote = game:GetService("ReplicatedStorage"):WaitForChild("CharacterEvents", 5):WaitForChild("RagdollRemote", 5)
            if not ragdollRemote then return end
            antiKickCoroutine = RunService.Heartbeat:Connect(function()
                local character = localPlayer.Character
                if character and character:FindFirstChild("HumanoidRootPart") and character:FindFirstChild("HumanoidRootPart"):FindFirstChild("FirePlayerPart") then
                    local partOwner = character:FindFirstChild("HumanoidRootPart"):FindFirstChild("FirePlayerPart"):FindFirstChild("PartOwner")
                    if partOwner and partOwner.Value ~= localPlayer.Name then
                        local args = {[1] = character:WaitForChild("HumanoidRootPart"), [2] = 0}
                        ragdollRemote:FireServer(unpack(args))
                        task.wait(0.1)
                        if Struggle then Struggle:FireServer() end
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

DefenseTab:AddToggle({
    Name = "アンチグッチ",
    Default = false,
    Save = true,
    Flag = "AntiGucci",
    Callback = function(enabled)
        if enabled then
            local root = getLocalRoot()
            if not root then return end
            local oldPos = root.CFrame

            if not toysFolder:FindFirstChild("CreatureBlobman") then
                 spawnItemCf("CreatureBlobman", root.CFrame)
                 task.wait(0.5)
            end

            local blob = nil
            for _, v in pairs(toysFolder:GetChildren()) do
                if v.Name == "CreatureBlobman" and v:FindFirstChild("Head") and v:FindFirstChild("VehicleSeat") then
                    blob = v
                    break
                end
            end

            if blob then
                _G.AntiGucciBlob = blob
                local head = blob.Head
                head.Anchored = true
                head.CFrame = CFrame.new(100000, 100000, 100000)
                
                task.wait(0.25)
                local hum = playerCharacter:FindFirstChild("Humanoid")
                if hum and blob.VehicleSeat then
                     root.CFrame = blob.VehicleSeat.CFrame + Vector3.new(0, 2, 0)
                     blob.VehicleSeat:Sit(hum)
                end
                
                task.wait(0.25)
                if hum then
                    hum:ChangeState(Enum.HumanoidStateType.Jumping)
                end
                
                task.wait(0.25)
                root.CFrame = oldPos
            end
        else
            if _G.AntiGucciBlob then
                DestroyT(_G.AntiGucciBlob)
                _G.AntiGucciBlob = nil
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
                while enabled do
                    task.wait(0.02)
                    local character = localPlayer.Character
                    if character and character:FindFirstChild("Head") then
                        local head = character.Head
                        local partOwner = head:FindFirstChild("PartOwner")
                        if partOwner then
                            local attacker = Players:FindFirstChild(partOwner.Value)
                            if attacker and attacker.Character and not isWhitelisted(attacker) and SetNetworkOwner then
                                if Struggle then Struggle:FireServer() end
                                local attackerRoot = attacker.Character:FindFirstChild("HumanoidRootPart")
                                local attackerFirePart = attackerRoot and attackerRoot:FindFirstChild("FirePlayerPart")
                                
                                if attackerFirePart then
                                    SetNetworkOwner:FireServer(attackerFirePart, attackerFirePart.CFrame)
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
                    if character and character:FindFirstChild("HumanoidRootPart") and SetNetworkOwner then
                        local humanoidRootPart = character.HumanoidRootPart
                        local head = character:FindFirstChild("Head")
                        if head then
                            local partOwner = head:FindFirstChild("PartOwner")
                            if partOwner then
                                local attacker = Players:FindFirstChild(partOwner.Value)
                                if attacker and attacker.Character and not isWhitelisted(attacker) then
                                    if Struggle then Struggle:FireServer() end
                                    local attackerFirePart = attacker.Character.HumanoidRootPart:FindFirstChild("FirePlayerPart")
                                    
                                    if attackerFirePart then
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
            loopTpCoroutine = coroutine.create(function()
                local foundBlobman = false
                for i, v in pairs(game.Workspace:GetDescendants()) do
                    if v:IsA("Model") and v.Name == "CreatureBlobman" then
                        if v:FindFirstChild("VehicleSeat") and v.VehicleSeat:FindFirstChild("SeatWeld") and v.VehicleSeat.SeatWeld.Part1.Parent == localPlayer.Character then
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
        local localHRP = getLocalRoot()
        if not localHRP then return end

        local function updateDecoyPositions()
            for index, decoy in pairs(decoys) do
                local torso = decoy:FindFirstChild("Torso")
                if torso then
                    local bodyPosition = torso:FindFirstChild("BodyPosition")
                    local bodyGyro = torso:FindFirstChild("BodyGyro")
                    if bodyPosition and bodyGyro then
                        local targetPosition
                        if followMode then
                            if playerCharacter and localHRP then
                                targetPosition = localHRP.Position
                                local offset = (index - midPoint) * decoyOffset
                                local forward = localHRP.CFrame.LookVector
                                local right = localHRP.CFrame.RightVector
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

        for _, conn in ipairs(connections) do conn:Disconnect() end
        connections = {}

        for _, decoy in pairs(decoys) do
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
                if SetNetworkOwner then SetNetworkOwner:FireServer(torso, localHRP.CFrame) end
            end
        end
        OrionLib:MakeNotification({Name = "Notification", Content = "Got "..numDecoys.." units. Manually click each unit if they don't move", Image = "rbxassetid://4483345998", Time = 5})
    end
})

FunTab:AddButton({
    Name = "トグルモード",
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
                while enabled do
                    task.wait(0.02)
                    local success, err = pcall(function()
                        local character = localPlayer.Character
                        if character and character:FindFirstChild("Head") and character:FindFirstChild("HumanoidRootPart") and SetNetworkOwner then
                            local head = character.Head
                            local humanoidRootPart = character.HumanoidRootPart

                            for _, player in pairs(Players:GetPlayers()) do
                                coroutine.wrap(function()
                                    if player ~= localPlayer and player.Character and not isWhitelisted(player) then
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
                    task.wait(0.02)
                    local success, err = pcall(function()
                        local character = localPlayer.Character
                        if character and character:FindFirstChild("HumanoidRootPart") and SetNetworkOwner then
                            local humanoidRootPart = character.HumanoidRootPart

                            for _, player in pairs(Players:GetPlayers()) do
                                if player ~= localPlayer and player.Character and not isWhitelisted(player) then
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
                                            force.Force = Vector3.new(0, -1200, 0) 
                                        else
                                            local force = playerTorso:FindFirstChild("GravityForce")
                                            if force then force:Destroy() end
                                        end
                                    end
                                end
                            end
                        end
                    end)
                    if not success then
                        warn("Error in Hell send Aura: " .. tostring(err))
                    end
                end
            end)
            coroutine.resume(gravityCoroutine)
        elseif gravityCoroutine then
            coroutine.close(gravityCoroutine)
            gravityCoroutine = nil
            for _, player in pairs(Players:GetPlayers()) do
                if player.Character then
                    local playerTorso = player.Character:FindFirstChild("Torso")
                    if playerTorso then
                        local force = playerTorso:FindFirstChild("GravityForce")
                        if force then force:Destroy() end
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
        if auraToggle == 1 then
            if enabled then
                kickCoroutine = coroutine.create(function()
                    while enabled do
                        task.wait(0.02)
                        local success, err = pcall(function()
                            local character = localPlayer.Character
                            if character and character:FindFirstChild("HumanoidRootPart") and SetNetworkOwner then
                                local humanoidRootPart = character.HumanoidRootPart

                                for _, player in pairs(Players:GetPlayers()) do
                                    if player ~= localPlayer and player.Character and not isWhitelisted(player) then
                                        local playerCharacter = player.Character
                                        local playerTorso = playerCharacter:FindFirstChild("Head")

                                        if playerTorso then
                                            local distance = (playerTorso.Position - humanoidRootPart.Position).Magnitude
                                            if distance <= auraRadius then
                                                local playerHRP = playerCharacter:WaitForChild("HumanoidRootPart", 0.1)
                                                if playerHRP and playerHRP:FindFirstChild("FirePlayerPart") then
                                                    SetNetworkOwner:FireServer(playerHRP.FirePlayerPart, playerHRP.FirePlayerPart.CFrame)
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
                                end
                                for player, platform in pairs(platforms) do
                                    if player.Character and player.Character.Humanoid and player.Character.Humanoid.Health > 1 then
                                        local playerHumanoidRootPart = player.Character.HumanoidRootPart
                                        if playerHumanoidRootPart then
                                            platform.Position = playerHumanoidRootPart.Position - Vector3.new(0, 3.994, 0)
                                        end
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
                    end
                end)
                coroutine.resume(kickCoroutine)
            elseif kickCoroutine then
                coroutine.close(kickCoroutine)
                kickCoroutine = nil
                for _, platform in pairs(platforms) do
                    if platform and platform.Parent then
                        platform:Destroy()
                    end
                end
                platforms = {}
            end
        elseif auraToggle == 2 then
            if enabled then
                kickCoroutine = coroutine.create(function()
                    while enabled do
                        task.wait(0.02)
                        local success, err = pcall(function()
                            local character = localPlayer.Character
                            if character and character:FindFirstChild("HumanoidRootPart") and SetNetworkOwner then
                                local humanoidRootPart = character.HumanoidRootPart

                                for _, player in pairs(Players:GetPlayers()) do
                                    if player ~= localPlayer and player.Character and not isWhitelisted(player) then
                                        local playerCharacter = player.Character
                                        local playerTorso = playerCharacter:FindFirstChild("Head")

                                        if playerTorso then
                                            local distance = (playerTorso.Position - humanoidRootPart.Position).Magnitude
                                            if distance <= auraRadius then
                                                local playerHRP = playerCharacter:WaitForChild("HumanoidRootPart", 0.1)
                                                if playerHRP and playerHRP:FindFirstChild("FirePlayerPart") then
                                                    SetNetworkOwner:FireServer(playerHRP.FirePlayerPart, playerHRP.FirePlayerPart.CFrame)
                                                    if not playerHRP.FirePlayerPart:FindFirstChild("BodyVelocity") then
                                                        local bodyVelocity = Instance.new("BodyVelocity")
                                                        bodyVelocity.Name = "BodyVelocity"
                                                        bodyVelocity.Velocity = Vector3.new(0, 20, 0) 
                                                        bodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                                                        bodyVelocity.Parent = playerHRP.FirePlayerPart
                                                    end
                                                end
                                            else
                                                local playerHRP = playerCharacter:FindFirstChild("HumanoidRootPart")
                                                if playerHRP and playerHRP:FindFirstChild("FirePlayerPart") then
                                                    local bodyVelocity = playerHRP.FirePlayerPart:FindFirstChild("BodyVelocity")
                                                    if bodyVelocity then bodyVelocity:Destroy() end
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
                end)
                coroutine.resume(kickCoroutine)
            else
                if kickCoroutine then
                    coroutine.close(kickCoroutine)
                    kickCoroutine = nil
                end
                for _, player in pairs(Players:GetPlayers()) do
                    if player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character.HumanoidRootPart:FindFirstChild("FirePlayerPart") then
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
    Color = Color3.fromRGB(240, 0, 0),
    Save = true,
    Callback = function(enabled)
        if enabled then
            poisonAuraCoroutine = coroutine.create(function()
                while enabled do
                    task.wait(0.02)
                    local success, err = pcall(function()
                        local character = localPlayer.Character
                        if character and character:FindFirstChild("HumanoidRootPart") and SetNetworkOwner then
                            local humanoidRootPart = character.HumanoidRootPart

                            for _, player in pairs(Players:GetPlayers()) do
                                if player ~= localPlayer and player.Character and not isWhitelisted(player) then
                                    local playerCharacter = player.Character
                                    local playerTorso = playerCharacter:FindFirstChild("Torso")
                                    if playerTorso then
                                        local distance = (playerTorso.Position - humanoidRootPart.Position).Magnitude
                                        if distance <= auraRadius then
                                            local head = playerCharacter:FindFirstChild("Head")
                                            while player.Character and player.Character:FindFirstChild("Torso") and (playerCharacter.HumanoidRootPart.Position - humanoidRootPart.Position).Magnitude <= auraRadius do 
                                                SetNetworkOwner:FireServer(playerTorso, playerCharacter.HumanoidRootPart.CFrame)
                                                for _, part in pairs(poisonHurtParts) do
                                                    part.Size = Vector3.new(1, 3, 1)
                                                    part.Transparency = 1
                                                    part.Position = head.Position
                                                end
                                                task.wait(0.1)
                                                for _, part in pairs(poisonHurtParts) do
                                                    part.Position = Vector3.new(0, -200, 0)
                                                end
                                                task.wait(0.1)
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
                    task.wait()
                    pcall(function()
                        if not playerCharacter or not playerCharacter:FindFirstChild("Humanoid") then return end 
                        if playerCharacter.Humanoid.WalkSpeed < 10 then
                            playerCharacter.Humanoid.WalkSpeed = crouchWalkSpeed
                        elseif playerCharacter.Humanoid.WalkSpeed == crouchWalkSpeed and UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) == false then
                            playerCharacter.Humanoid.WalkSpeed = 16
                        end
                    end)
                end
            end)
            coroutine.resume(crouchSpeedCoroutine)
        elseif crouchSpeedCoroutine then
            coroutine.close(crouchSpeedCoroutine)
            crouchSpeedCoroutine = nil
            if playerCharacter and playerCharacter:FindFirstChild("Humanoid") then 
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
                    task.wait()
                    pcall(function()
                        if not playerCharacter or not playerCharacter:FindFirstChild("Humanoid") then return end 
                        if playerCharacter.Humanoid.JumpPower < 20 then 
                            playerCharacter.Humanoid.JumpPower = crouchJumpPower
                        elseif playerCharacter.Humanoid.JumpPower == crouchJumpPower and UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) == false then
                            playerCharacter.Humanoid.JumpPower = 24
                        end
                    end)
                end
            end)
            coroutine.resume(crouchJumpCoroutine)
        elseif crouchJumpCoroutine then
            coroutine.close(crouchJumpCoroutine)
            crouchJumpCoroutine = nil
            if playerCharacter and playerCharacter:FindFirstChild("Humanoid") then 
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

CharacterTab:AddSlider({
    Name = "FOV",
    Min = 70,
    Max = 120,
    Default = 70,
    Color = Color3.fromRGB(240, 0, 0),
    ValueName = ".",
    Save = true,
    Flag = "FOV",
    Callback = function(Value)
        workspace.CurrentCamera.FieldOfView = Value
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
    Max = (localPlayer:FindFirstChild("ToysLimitCap") and localPlayer.ToysLimitCap.Value / 10) or 10,
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
            local player = Players:GetPlayerFromCharacter(character)
            if character and character:IsA("Model") and character:FindFirstChildOfClass("Humanoid") and not isWhitelisted(player) and SetNetworkOwner then
                local hrp = character:FindFirstChild("HumanoidRootPart")
                local torso = character:FindFirstChild("Torso")
                if hrp and torso then
                    SetNetworkOwner:FireServer(hrp, hrp.CFrame)
                    for _, part in ipairs(character:GetDescendants()) do
                        if part:IsA("BasePart") or part:IsA("Part") then
                            part.CanCollide = false
                        end
                    end
    
                    local bodyVelocity = Instance.new("BodyVelocity")
                    bodyVelocity.Parent = torso
                    bodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                    bodyVelocity.Velocity = Vector3.new(0, -40, 0) 
                    torso.CanCollide = false
                    task.wait(1)
                    torso.CanCollide = false
                    Debris:AddItem(bodyVelocity, 5) 
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
            local player = Players:GetPlayerFromCharacter(character)
            local hrp = character:FindFirstChild("HumanoidRootPart")
            if character and character:IsA("Model") and character:FindFirstChildOfClass("Humanoid") and not isWhitelisted(player) and hrp and SetNetworkOwner then
                local firePart = hrp:FindFirstChild("FirePlayerPart")
                if not firePart then return end
                
                if kickMode == 1 then
                    SetNetworkOwner:FireServer(firePart, firePart.CFrame)
                    local bodyVelocity = Instance.new("BodyVelocity")
                    bodyVelocity.Parent = firePart
                    bodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                    bodyVelocity.Velocity = Vector3.new(0, 20, 0)
                    Debris:AddItem(bodyVelocity, 1)
                elseif kickMode == 2 then
                    SetNetworkOwner:FireServer(firePart, firePart.CFrame)
                    local platform = Instance.new("Part")
                    platform.Name = "FloatingPlatform"
                    platform.Size = Vector3.new(5, 2, 5)
                    platform.Anchored = true
                    platform.Transparency = 1
                    platform.CanCollide = true
                    platform.Parent = character
                    coroutine.wrap(function()
                        local isAlive = true
                        local humanoid = character:FindFirstChildOfClass("Humanoid")
                        if humanoid then
                            humanoid.Died:Connect(function() isAlive = false end)
                        end
                        while isAlive and character and character.Parent and platform and platform.Parent do
                            task.wait()
                            local currentHRP = character:FindFirstChild("HumanoidRootPart")
                            if currentHRP then
                                platform.Position = currentHRP.Position - Vector3.new(0, 3.994, 0)
                            else
                                break 
                            end
                        end 
                        if platform and platform.Parent then platform:Destroy() end 
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
            local player = Players:GetPlayerFromCharacter(character)
            if character and character:IsA("Model") and character:FindFirstChildOfClass("Humanoid") and not isWhitelisted(player) and SetNetworkOwner then
                local hrp = character:FindFirstChild("HumanoidRootPart")
                local head = character:FindFirstChild("Head")
                local torso = character:FindFirstChild("Torso")
                if hrp and head and torso then
                    SetNetworkOwner:FireServer(hrp, hrp.CFrame)
                    SetNetworkOwner:FireServer(head, head.CFrame)
                    for _, motor in pairs(torso:GetChildren()) do
                        if motor:IsA('Motor6D') then motor:Destroy() end
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
        local mouse = localPlayer:GetMouse()
        local target = mouse.Target
        if target and target:IsA("BasePart") then
            local character = target.Parent
            if target.Name == "FirePlayerPart" then
                character = target.Parent.Parent
            end
            local player = Players:GetPlayerFromCharacter(character)
            local hrp = character:FindFirstChild("HumanoidRootPart")
            local head = character:FindFirstChild("Head")
            
            if character and character:IsA("Model") and character:FindFirstChildOfClass("Humanoid") and not isWhitelisted(player) and hrp and head and SetNetworkOwner then
                if not toysFolder:FindFirstChild("Campfire") then
                    spawnItem("Campfire", Vector3.new(-72.9304581, -5.96906614, -265.543732))
                end
                local campfire = toysFolder:WaitForChild("Campfire", 5) 
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
        if not ownedToys[_G.ToyToLoad] then 
            OrionLib:MakeNotification({Name = "Missing toy", Content = "あなたは爆弾を所有していません ", Image = "rbxassetid://4483345998", Time = 3})
            return
        end
        local connection
        local bombEvents = ReplicatedStorage:WaitForChild("BombEvents", 5)
        if not bombEvents or not bombEvents:FindFirstChild("BombExplode") then return end
        
        connection = toysFolder.ChildAdded:Connect(function(child)
            if child.Name == _G.ToyToLoad then
                if child:WaitForChild("ThisToysNumber", 1) then
                    if child.ThisToysNumber.Value == (toysFolder.ToyNumber.Value - 1) then
                        connection:Disconnect()
                        
                        if SetNetworkOwner then SetNetworkOwner:FireServer(child.PartHitDetector, child.PartHitDetector.CFrame) end
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
                        bombEvents.BombExplode:FireServer(unpack(args))
                    end
                end
            end
        end)
        spawnItemCf(_G.ToyToLoad, playerCharacter.Head.CFrame or playerCharacter.HumanoidRootPart.CFrame)
        Debris:AddItem(connection, 5) 
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
            OrionLib:MakeNotification({Name = "Missing toy", Content = "You do not own the BombMissile toy.", Image = "rbxassetid://4483345998", Time = 3})
            return
        end
        
        local connection
        connection = toysFolder.ChildAdded:Connect(function(child)
            if child.Name == _G.ToyToLoad then
                if child:WaitForChild("ThisToysNumber", 1) then
                    if child.ThisToysNumber.Value == (toysFolder.ToyNumber.Value - 1) then
                        connection:Disconnect()

                        if SetNetworkOwner then SetNetworkOwner:FireServer(child.PartHitDetector, child.PartHitDetector.CFrame) end
                        local velocityObj = Instance.new("BodyVelocity", child.PartHitDetector)
                        velocityObj.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                        velocityObj.Velocity = workspace.CurrentCamera.CFrame.lookVector * 500
                        Debris:AddItem(velocityObj, 10)
                    end
                end
            end
        end)
        spawnItemCf(_G.ToyToLoad, playerCharacter.Head.CFrame or playerCharacter.HumanoidRootPart.CFrame)
        Debris:AddItem(connection, 5)
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
            OrionLib:MakeNotification({Name = "Missing toy", Content = "You do not own the FireworkMissile toy.", Image = "rbxassetid://4483345998", Time = 3})
            return
        end
        local connection
        local bombEvents = ReplicatedStorage:WaitForChild("BombEvents", 5)
        if not bombEvents or not bombEvents:FindFirstChild("BombExplode") then return end
        
        connection = toysFolder.ChildAdded:Connect(function(child)
            if child.Name == "FireworkMissile" then
                if child:WaitForChild("ThisToysNumber", 1) then
                    if child.ThisToysNumber.Value == (toysFolder.ToyNumber.Value - 1) then
                        connection:Disconnect()
                        
                        if SetNetworkOwner then SetNetworkOwner:FireServer(child.PartHitDetector, child.PartHitDetector.CFrame) end
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
                        bombEvents.BombExplode:FireServer(unpack(args))

                    end
                end
            end
        end)
        spawnItemCf("FireworkMissile", playerCharacter.Head.CFrame or playerCharacter.HumanoidRootPart.CFrame)
        Debris:AddItem(connection, 5)
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
        local bombEvents = ReplicatedStorage:WaitForChild("BombEvents", 5)
        if not bombEvents or not bombEvents:FindFirstChild("BombExplode") then return end

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
                ["PositionPart"] = playerCharacter.HumanoidRootPart or playerCharacter.PrimaryPart
            },
            [2] = (playerCharacter.HumanoidRootPart or playerCharacter.PrimaryPart).Position
        }
        bombEvents.BombExplode:FireServer(unpack(args))
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
        local bombEvents = ReplicatedStorage:WaitForChild("BombEvents", 5)
        if not bombEvents or not bombEvents:FindFirstChild("BombExplode") then return end
        
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
                    ["PositionPart"] = playerCharacter.HumanoidRootPart or playerCharacter.PrimaryPart
                },
                [2] = (playerCharacter.HumanoidRootPart or playerCharacter.PrimaryPart).Position
            }
            bombEvents.BombExplode:FireServer(unpack(args))
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
        local bombEvents = ReplicatedStorage:WaitForChild("BombEvents", 5)
        if not bombEvents or not bombEvents:FindFirstChild("BombExplode") then return end
        
        local char = nearest.Character
        local targetPart = char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso") or char:FindFirstChild("PrimaryPart")
        if not targetPart then return end
        
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
            bombEvents.BombExplode:FireServer(unpack(args))
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
                    
                    if SetNetworkOwner then SetNetworkOwner:FireServer(part, part.CFrame) end
                end
            end
            
            lightorbitcon = RunService.Heartbeat:Connect(function()
                if not localPlayer.Character or not localPlayer.Character.HumanoidRootPart then 
                    return 
                end
                lightbitoffset = lightbitoffset + lightbit
                local HRP = localPlayer.Character.HumanoidRootPart
                lightbitpos = U.GetSurroundingVectors(HRP.Position, usingradius, #lightbitparts, lightbitoffset)

                for i, v in ipairs(lightbitpos) do
                    if bodyPositions[i] and alignOrientations[i] and lightbitparts[i] and lightbitparts[i].Parent then
                        bodyPositions[i].Position = v
                        local part = lightbitparts[i]
                        local lookAtCFrame = CFrame.lookAt(part.Position, HRP.Position)
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
        local Character = localPlayer.Character
        if Character and Character:FindFirstChild("Humanoid") and Character.Humanoid.SeatPart == nil and Character:FindFirstChild("HumanoidRootPart") then
            local foundBlobman
            for _, v in pairs(game.Workspace:GetDescendants()) do
                if v:IsA("Model") and v.Name == "CreatureBlobman" and v:FindFirstChild("VehicleSeat") then
                    if v.VehicleSeat.Occupant == nil then
                        foundBlobman = v
                        break
                    end
                end
            end

            if foundBlobman then
                foundBlobman.VehicleSeat:Sit(Character.Humanoid)
            elseif not isSpawningBlobmanForSit and localPlayer:FindFirstChild("CanSpawnToy") and localPlayer.CanSpawnToy.Value then
                isSpawningBlobmanForSit = true
                spawnItemCf("CreatureBlobman", Character.HumanoidRootPart.CFrame)
                task.delay(1.5, function()
                    isSpawningBlobmanForSit = false
                end)
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
    Content = "ようこそ、野獣ハブ", 
    Image = "rbxassetid://4483345998", 
    Time = 5
})

Players.PlayerAdded:Connect(function(player)
    updatePlayerDropdowns()
end)

Players.PlayerRemoving:Connect(function(player)
    if whitelistedPlayers[player.Name] then
        whitelistedPlayers[player.Name] = nil
        updateWhitelistLabel()
    end
    updatePlayerDropdowns()
end)

OrionLib:Init()
