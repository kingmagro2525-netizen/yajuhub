--// Services & Setup
local service = setmetatable({}, {
    __index = function(self, k)
        local s = game:GetService(k)
        rawset(self, k, s)
        return s
    end,
})

--// Utils required for Barrier Destroyer
local get = game.FindFirstChild
local function getLocalPlayer()
    return service.Players.LocalPlayer
end
local function getLocalChar()
    return getLocalPlayer().Character
end
local function getLocalRoot()
    if (not getLocalChar()) then return end
    return get(getLocalChar(), "HumanoidRootPart") or get(getLocalChar(), "Torso")
end
local function getInv()
    return get(workspace, getLocalPlayer().Name .. "SpawnedInToys")
end
local function SetNetworkOwner(part)
    service.ReplicatedStorage.GrabEvents.SetNetworkOwner:FireServer(part, getLocalRoot().CFrame)
end
local function spawntoy(name, cframe, vector3)
    local toy = service.ReplicatedStorage.MenuToys.SpawnToyRemoteFunction:InvokeServer(table.unpack({
        [1] = name,
        [2] = cframe,
        [3] = vector3 or Vector3.zero
    }))
    local r = get(getInv(), name)
    return r
end
local function destroyToy(model)
    service.ReplicatedStorage.MenuToys.DestroyToy:FireServer(model)
end

--// Orion Library Setup
local OrionLib = loadstring(game:HttpGet('https://raw.githubusercontent.com/Polinorsik/Orion-Z-Library/refs/heads/main/README.md'))()

local Window = OrionLib:MakeWindow({
    Name = "Barrier Destroyer",
    HidePremium = false,
    SaveConfig = false,
    ConfigFolder = "BarrierConfig"
})

local Tab = Window:MakeTab({
    Name = "Main",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

--// Notification Adapter (Removed "Suisei Hub" title)
local function Notify(content)
    OrionLib:MakeNotification({
        Name = " ", -- タイトルを空白に設定
        Content = content,
        Image = "rbxassetid://4483345998",
        Time = 5
    })
end

--// Core Logic Function (Returns true if success, false if failed)
local function AttemptBarrierDestroy(showFailNotify)
    local root = getLocalRoot()
    if not root then return false end

    local pos = root.CFrame
    
    -- 1. Spawn Hamburger and teleport logic
    local toy = spawntoy("FoodHamburger", root.CFrame)
    local args = {
        [1] = toy,
        [2] = getLocalChar()
    }
    
    -- Hold item logic
    if toy and toy:FindFirstChild("HoldPart") and toy.HoldPart:FindFirstChild("HoldItemRemoteFunction") then
         toy.HoldPart.HoldItemRemoteFunction:InvokeServer(unpack(args))
    end
    
    task.wait(.05)
    -- Teleport to provided coordinates
    root.CFrame = CFrame.new(-521.46, 12.27, -175.27)
    task.wait(.05)
    destroyToy(toy)
    task.wait(.05)
    root.CFrame = pos
    
    -- 2. Barrier Manipulation (Local)
    for _, v in ipairs(workspace.Plots:GetChildren()) do
        local b = v:FindFirstChild("Barrier")
        if b then
            for _, p in ipairs(b:GetChildren()) do
                p.CanCollide = false
            end
        end
    end
    
    task.wait(1)
    
    -- 3. CHECK Logic
    local p = spawntoy("FireExtinguisher", root.CFrame)
    if p and p:FindFirstChild("SoundPart") then
        SetNetworkOwner(p.SoundPart)
        task.wait(.5)
        p.SoundPart.CFrame = CFrame.new(-521.46, 12.27, -175.27)
        task.wait(.75)
        
        if (p.Parent) then
            -- Success
            Notify("バリア破壊成功！")
            destroyToy(p)
            return true
        else
            -- Fail
            if showFailNotify then
                Notify("バリア破壊失敗")
            end
            pcall(function() destroyToy(p) end) 
            return false
        end
    else
         -- Spawn error
         if showFailNotify then
             Notify("アイテムエラー")
         end
         return false
    end
end

--// UI Elements
Tab:AddLabel("バリア破壊を開始したらあまり動かないでください\n判定がバグる可能性があります")

Tab:AddButton({
    Name = "バリア破壊(1回)",
    Callback = function()
        AttemptBarrierDestroy(true)
    end
})

--// Loop Toggle
local LoopEnabled = false
Tab:AddToggle({
    Name = "バリア破壊(ループ)",
    Default = false,
    Callback = function(Value)
        LoopEnabled = Value
        if LoopEnabled then
            task.spawn(function()
                while LoopEnabled do
                    local success = AttemptBarrierDestroy(false)
                    if success then
                        LoopEnabled = false
                        break
                    else
                        task.wait(1.5)
                    end
                    if not LoopEnabled then break end
                end
            end)
        end
    end
})

OrionLib:Init()
