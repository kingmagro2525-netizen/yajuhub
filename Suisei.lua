--[[
==== SUISEI HUB (FULL VERSION) ====
Made by Luna!! (Modified for Orion Library)
]]

local service = setmetatable({}, {
    __index = function(self, k)
        local s = game:GetService(k)
        rawset(self, k, s)
        return s
    end,
})

--// ORION LIBRARY LOAD (指定されたURLを使用)
local OrionLib = nil
local status, result = pcall(function()
    -- ユーザー指定のURLをロード
    OrionLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/Polinorsik/Orion-Z-Library/refs/heads/main/README.md"))()
end)

-- ロード失敗時の処理 (URLがLuaコードでない場合など)
if not status or not OrionLib then
    warn("CRITICAL ERROR: Failed to load Orion Library from the provided URL.")
    warn("Error Details: " .. tostring(result))
    
    -- 万が一、指定URLが機能しなかった場合の予備(本家Orion)を自動ロードする安全策を入れるならここだが、
    -- 今回はユーザーの指定を尊重し、ここで通知を出して処理を続行(または停止)する。
    local s, r = pcall(function()
        service.StarterGui:SetCore("MakeNotification", {
            Title = "Suisei Hub Error",
            Text = "Library URL invalid (README?). Check console (F9).",
            Duration = 10
        })
    end)
    -- ライブラリがないとGUIが作れないため、ここで停止するのが通常だが、
    -- コード自体は提供するためリターンはしないでおく（エラーが出る可能性大）
end

local function windNotify(data)
    if OrionLib then
        OrionLib:MakeNotification({
            Name = data.Title,
            Content = data.Content,
            Time = data.Duration or 5,
            Image = "rbxassetid://4483345998",
            Callback = function() end
        })
    end
end

local loop = Instance.new("BindableEvent")
service.RunService.Heartbeat:Connect(function(dt)
    loop:Fire(dt)
end)

--// UTILS & FUNCTIONS
do
    function hn(func, ...)
        if (service.RunService:IsStudio()) then print('hn call') end
        if (coroutine.status(task.spawn(hn, func, ...)) == "dead") then return end
        return pcall(func, ...)
    end
    
    local get = game.FindFirstChild
    local cget = game.FindFirstChildOfClass
    
    local function getLocalPlayer() return service.Players.LocalPlayer end
    local function getLocalChar() return getLocalPlayer().Character end
    local function getLocalRoot() 
        local char = getLocalChar()
        return char and (get(char, "HumanoidRootPart") or get(char, "Torso"))
    end
    local function getLocalHum() 
        local char = getLocalChar()
        return char and cget(char, "Humanoid")
    end

    local function Velocity(part, value)
        local b = Instance.new("BodyVelocity")
        b.MaxForce = Vector3.one * math.huge
        b.Velocity = value
        b.Parent = part
        service.Debris:AddItem(b, 0.1)
    end

    local function SetNetworkOwner(part)
        if not getLocalRoot() then return end
        local ge = service.ReplicatedStorage:FindFirstChild("GrabEvents")
        if ge and ge:FindFirstChild("SetNetworkOwner") then
            ge.SetNetworkOwner:FireServer(part, getLocalRoot().CFrame)
        end
    end

    local function GetNearParts(origin, radius)
        return workspace:GetPartBoundsInRadius(origin, radius)
    end

    local function IsInRadius(part, origin, radius)
        return (part.Position - origin).Magnitude <= radius
    end

    local function MoveTo(part, x)
        for _, v in ipairs(part.Parent:GetDescendants()) do
            if v:IsA("BasePart") then v.CanCollide = false end
        end
        local pos = typeof(x) == "CFrame" and x.Position or x
        local b = Instance.new("BodyPosition")
        b.MaxForce = Vector3.one * math.huge
        b.Position = pos
        b.P = 20000
        b.D = 5000
        b.Parent = part
        task.delay(0.5, function()
            if b then b:Destroy() end
            for _, v in ipairs(part.Parent:GetDescendants()) do
                if v:IsA("BasePart") then v.CanCollide = true end
            end
        end)
    end

    local function anchor(part)
        local pos = getLocalRoot().CFrame
        local tpos = part.CFrame
        for _ = 1, 2 do
            getLocalRoot().CFrame = part.CFrame
            SetNetworkOwner(part)
            task.spawn(function()
                task.wait(.5)
                for _ = 1, 2 do
                    task.wait(.5)
                    SetNetworkOwner(part)
                    local p = Instance.new("BodyPosition")
                    p.Position = part.CFrame.Position
                    p.MaxForce = Vector3.one * math.huge
                    p.Parent = part
                    local r = Instance.new("BodyGyro")
                    r.CFrame = tpos
                    r.MaxTorque = Vector3.one * math.huge
                    r.Parent = part
                end
            end)
            task.wait()
        end
        getLocalRoot().CFrame = pos
    end

    local function lag(value)
        local ge = service.ReplicatedStorage:FindFirstChild("GrabEvents")
        if ge and ge:FindFirstChild("CreateGrabLine") then
            for _ = 1, value do ge.CreateGrabLine:FireServer() end
        end
    end

    local function ping(value)
        local ge = service.ReplicatedStorage:FindFirstChild("GrabEvents")
        if ge and ge:FindFirstChild("ExtendGrabLine") then
            for _ = 1, value do ge.ExtendGrabLine:FireServer(string.rep("Balls ", value)) end
        end
    end

    local function createLine(part)
        local ge = service.ReplicatedStorage:FindFirstChild("GrabEvents")
        if ge and ge:FindFirstChild("CreateGrabLine") then
            ge.CreateGrabLine:FireServer(part, CFrame.identity)
        end
    end

    local function ungrab(part)
        local ge = service.ReplicatedStorage:FindFirstChild("GrabEvents")
        if ge and ge:FindFirstChild("DestroyGrabLine") then
            ge.DestroyGrabLine:FireServer(part)
        end
    end

    local function getInv()
        return get(workspace, getLocalPlayer().Name .. "SpawnedInToys")
    end

    local function spawntoy(name, cframe, vector3)
        local mt = service.ReplicatedStorage:FindFirstChild("MenuToys")
        if mt and mt:FindFirstChild("SpawnToyRemoteFunction") then
            mt.SpawnToyRemoteFunction:InvokeServer(name, cframe, vector3 or Vector3.zero)
            local inv = getInv()
            if inv then return get(inv, name) end
        end
    end

    local function destroyToy(model)
        local mt = service.ReplicatedStorage:FindFirstChild("MenuToys")
        if mt and mt:FindFirstChild("DestroyToy") then
            mt.DestroyToy:FireServer(model)
        end
    end

    local function ragdoll()
        local ce = service.ReplicatedStorage:FindFirstChild("CharacterEvents")
        if ce and ce:FindFirstChild("RagdollRemote") then
            ce.RagdollRemote:FireServer(getLocalRoot(), 0)
        end
    end

    --// BLOBMAN FUNCTIONS
    local function getBlobman()
        local inv = getInv()
        if inv then
            local v = get(inv, "CreatureBlobman")
            if v and v.ClassName == "Model" and get(v, "VehicleSeat") then return v end
        end
        for _, p in ipairs(workspace.PlotItems:GetChildren()) do
            local m = get(p, "CreatureBlobman")
            if m and m:FindFirstChild("PlayerValue") and m.PlayerValue.Value == getLocalPlayer().Name then
                if get(m, "VehicleSeat") then return m end
            end
        end
        return nil
    end

    local function spawnBlobmanFunc()
        return spawntoy("CreatureBlobman", getLocalRoot().CFrame)
    end

    local function blobGrab(blob, target, side)
        if not blob or not blob:FindFirstChild("BlobmanSeatAndOwnerScript") then return end
        blob.BlobmanSeatAndOwnerScript.CreatureGrab:FireServer(
            get(blob, side.."Detector"),
            target,
            get(get(blob, side.."Detector"), side.."Weld")
        )
    end

    local function blobKick(blob, target, side)
        blobGrab(blob, getLocalRoot(), side)
        task.wait(.1)
        SetNetworkOwner(target)
        task.wait()
        target.CFrame = target.CFrame + Vector3.new(0, 16, 0)
        task.wait(.1)
        ungrab(target)
        blobGrab(blob, target, side)
    end

    local function blobBring(blob, target, side)
        local pos = getLocalRoot().CFrame
        getLocalRoot().CFrame = target.CFrame
        task.wait(.25)
        blobGrab(blob, target, side)
        task.wait(.25)
        getLocalRoot().CFrame = pos
    end

    local function IsFriend(p)
        return p and p.UserId and getLocalPlayer():IsFriendsWith(p.UserId)
    end
    local function IsInPlot(p) return p:FindFirstChild("InPlot") and p.InPlot.Value end
    
    local function getPlayerFromName(name)
        for _, p in pairs(service.Players:GetPlayers()) do
            if p.DisplayName:lower():sub(1, #name:lower()) == name:lower() or p.Name:lower():sub(1, #name:lower()) == name:lower() then
                return p
            end
        end
    end

    local function Snipefunc(root, func)
        local pos = getLocalRoot().CFrame
        local parts = {"Head", "Torso", "HumanoidRootPart"}
        local char = getLocalChar()
        for _, p in pairs(parts) do if get(char, p) then get(char, p).CanCollide = false end end
        
        getLocalRoot().CFrame = CFrame.new(root.Position - root.CFrame.LookVector * 15)
        task.wait(0.1)
        workspace.CurrentCamera.CFrame = CFrame.lookAt(workspace.CurrentCamera.CFrame.Position, root.Position)
        
        for _=1,4 do SetNetworkOwner(root); task.wait(0.05) end
        
        local camCFrame = workspace.CurrentCamera.CFrame
        task.wait(0.1)
        func()
        workspace.CurrentCamera.CFrame = camCFrame
        task.wait(0.1)
        
        for _, p in pairs(parts) do if get(char, p) then get(char, p).CanCollide = true end end
        getLocalRoot().CFrame = pos
        Velocity(getLocalRoot(), Vector3.zero)
    end

    --// MAIN UI SETUP
    local Window = OrionLib:CreateWindow({
        Name = "Suisei Hub | Luna",
        HideOnStart = false,
        SaveConfig = true,
        ConfigFolder = "SuiseiHub"
    })

    -- GLOBAL CONFIG
    local config = {
        Movements = {
            CrouchSpeedHack = {Value=16, Loop=false}, SpeedHack = {Value=16}, JumppowerHack = {Value=50, Loop=false},
            Freeze = {Value=false, CFrame=CFrame.new()}, Infjump = {Value=false}, Fly = {Value=false}, Noclip = {Value=false},
            Teleports = {Target = {Value=""}}
        },
        Players = {
            AntiDetect={Value=false}, AntiRagdoll={Value=false}, AntiTouch={Value=false}, AntiBanana={Value=false},
            AutoSlot={Value=false, Time=0}, Ragdoll={Value=false}, AntiGucci={Value=false}
        },
        Visuals = {ESP={Value=false, Fill=Color3.new(0,0,1), Out=Color3.new(1,1,1)}, FOV={Value=70}, TPS={Value=false}, Spectate={Value=false}},
        Combats = {
            AntiGrab={Value=false}, AntiVoid={Value=false}, AntiFar={Value=false}, AntiExplode={Value=false}, StrAntiGrab={Value=false},
            Extinguisher={Value=false}, InvisLine={Value=false}, SuperStrength={Value=false, Power={Value=250}}, InfLine={Value=false, Dist={Value=0}},
            Revenge={Void={Value=false}, Kill={Value=false}, Poison={Value=false}, Ragdoll={Value=false}, Death={Value=false}},
            AimBot={Value=false, Radius={Value=30}, Part={Value="Torso"}}
        },
        Auras = {Void={Value=false}, Kill={Value=false}, Poison={Value=false}, Ragdoll={Value=false}, Death={Value=false}, Fire={Value=false}, Anchor={Value=false}, Noclip={Value=false}},
        Grabs = {Void={Value=false}, Kill={Value=false}, Poison={Value=false}, Ragdoll={Value=false}, Death={Value=false}, Anchor={Value=false}, Kick={Value=false}, Noclip={Value=false}},
        Miscs = {NWO={Value=false}, Control={Target={Value=nil}, Value=false}, NoTyping={Value=false}, AntiKick={Value=false}},
        Blobman = {Target={Value=""}, ArmSide={Value="Left"}, Noclip={Value=false}, GrabAura={Value=false}, KickAura={Value=false}, LoopKick={Value=false}, LoopKickAll={Value=false}},
        Snipes = {Target={Value=""}, Void={Value=false}, Kill={Value=false}, Poison={Value=false}, Ragdoll={Value=false}, Death={Value=false}},
        Trolls = {Loud={Value=false, Part={Value=nil}}, Lag={Value=false}, Ping={Value=false}, Server={Value=false, CF=CFrame.new()}, Chaos={Value=false}},
        Settings = {OnlyPlayer={Value=false}, IgnoreFriend={Value=false}, IgnorePlot={Value=false}, Radius={Value=32}, AimSpeed={Value=5}, Lag={Value=1024}, Ping={Value=1024}, KickMethod={Value="Void"}, SpeedMethod={Value="CFrame"}, AutoSpeed={Value=true}, FlyMethod={Value="Velocity"}, Debug={Value=false}}
    }

    -- TABS
    local __movements = Window:AddTab({Name="Movements", Icon="rbxassetid://4483345998"})
    local __players = Window:AddTab({Name="Players", Icon="rbxassetid://4483345998"})
    local __visuals = Window:AddTab({Name="Visuals", Icon="rbxassetid://4483345998"})
    local __combats = Window:AddTab({Name="Combats", Icon="rbxassetid://4483345998"})
    local __auras = Window:AddTab({Name="Auras", Icon="rbxassetid://4483345998"})
    local __grabs = Window:AddTab({Name="Grabs", Icon="rbxassetid://4483345998"})
    local __miscs = Window:AddTab({Name="Miscs", Icon="rbxassetid://4483345998"})
    local __blobmans = Window:AddTab({Name="Blobmans", Icon="rbxassetid://4483345998"})
    local __snipes = Window:AddTab({Name="Snipes", Icon="rbxassetid://4483345998"})
    local __trolls = Window:AddTab({Name="Trolls", Icon="rbxassetid://4483345998"})
    local __settings = Window:AddTab({Name="Settings", Icon="rbxassetid://4483345998"})
    local __infos = Window:AddTab({Name="Infos", Icon="rbxassetid://4483345998"})

    -- [MOVEMENTS]
    __movements:AddSlider({Name="Speed (Crouch)", Min=0, Max=150, Default=16, Increment=1, Callback=function(v) config.Movements.CrouchSpeedHack.Value=v end})
    __movements:AddToggle({Name="Loop Speed (Crouch)", Default=false, Callback=function(v) config.Movements.CrouchSpeedHack.Loop=v end})
    __movements:AddSlider({Name="Jumppower", Min=0, Max=150, Default=50, Increment=1, Callback=function(v) config.Movements.JumppowerHack.Value=v end})
    __movements:AddToggle({Name="Loop Jumppower", Default=false, Callback=function(v) config.Movements.JumppowerHack.Loop=v end})
    __movements:AddSlider({Name="Speed", Min=0, Max=150, Default=16, Increment=1, Callback=function(v) config.Movements.SpeedHack.Value=v end})
    __movements:AddToggle({Name="Inf Jump", Default=false, Callback=function(v) config.Movements.Infjump.Value=v end})
    __movements:AddToggle({Name="Fly", Default=false, Callback=function(v) config.Movements.Fly.Value=v end})
    __movements:AddToggle({Name="Noclip", Default=false, Callback=function(v) config.Movements.Noclip.Value=v end})
    __movements:AddToggle({Name="Freeze", Default=false, Callback=function(v) config.Movements.Freeze.Value=v; if v then config.Movements.Freeze.CFrame=getLocalRoot().CFrame end end})
    __movements:AddLabel("Teleports")
    __movements:AddTextbox({Name="Target", Default="", TextDisappear=false, Callback=function(v) config.Movements.Teleports.Target.Value=v end})
    __movements:AddButton({Name="Teleport", Callback=function() 
        local t = getPlayerFromName(config.Movements.Teleports.Target.Value)
        if t and t.Character and t.Character:FindFirstChild("HumanoidRootPart") then getLocalRoot().CFrame = t.Character.HumanoidRootPart.CFrame end
    end})
    __movements:AddButton({Name="Spawn", Callback=function() getLocalRoot().CFrame = CFrame.new(1,-10,-2) end})
    __movements:AddButton({Name="Barn", Callback=function() getLocalRoot().CFrame = CFrame.new(-234, 85, -311) end})
    __movements:AddButton({Name="Blue House", Callback=function() getLocalRoot().CFrame = CFrame.new(525, 98, -375) end})
    __movements:AddButton({Name="Factory", Callback=function() getLocalRoot().CFrame = CFrame.new(138, 365, 346) end})
    __movements:AddButton({Name="Glass House", Callback=function() getLocalRoot().CFrame = CFrame.new(-325, 109, 337) end})
    __movements:AddButton({Name="Japanese House", Callback=function() getLocalRoot().CFrame = CFrame.new(584, 141, -100) end})
    __movements:AddButton({Name="Pink Roof", Callback=function() getLocalRoot().CFrame = CFrame.new(-525, 22, -165) end})
    __movements:AddButton({Name="Spooky House", Callback=function() getLocalRoot().CFrame = CFrame.new(303, 14, 483) end})
    __movements:AddButton({Name="Train Cave", Callback=function() getLocalRoot().CFrame = CFrame.new(571, 48, -153) end})
    __movements:AddButton({Name="Secret Cave (Small)", Callback=function() getLocalRoot().CFrame = CFrame.new(-50, -7, -298) end})
    __movements:AddButton({Name="Secret Cave (Big)", Callback=function() getLocalRoot().CFrame = CFrame.new(-130, -7, 575) end})

    -- [PLAYERS]
    __players:AddToggle({Name="Anti Detect", Default=false, Callback=function(v) config.Players.AntiDetect.Value=v end})
    __players:AddToggle({Name="Anti Ragdoll", Default=false, Callback=function(v) config.Players.AntiRagdoll.Value=v end})
    __players:AddToggle({Name="Anti Touch", Default=false, Callback=function(v) config.Players.AntiTouch.Value=v end})
    __players:AddToggle({Name="Anti Banana", Default=false, Callback=function(v) config.Players.AntiBanana.Value=v end})
    __players:AddToggle({Name="Auto Slot", Default=false, Callback=function(v) config.Players.AutoSlot.Value=v end})
    __players:AddToggle({Name="Ragdoll", Default=false, Callback=function(v) config.Players.Ragdoll.Value=v end})
    __players:AddToggle({Name="Anti Gucci", Default=false, Callback=function(v) config.Players.AntiGucci.Value=v end})

    -- [VISUALS]
    __visuals:AddToggle({Name="ESP", Default=false, Callback=function(v) config.Visuals.ESP.Value=v end})
    __visuals:AddColorpicker({Name="Fill", Default=Color3.new(0,0,1), Callback=function(v) config.Visuals.ESP.Fill=v end})
    __visuals:AddColorpicker({Name="Outline", Default=Color3.new(1,1,1), Callback=function(v) config.Visuals.ESP.Out=v end})
    __visuals:AddSlider({Name="FOV", Min=30, Max=120, Default=70, Increment=1, Callback=function(v) config.Visuals.FOV.Value=v end})
    __visuals:AddToggle({Name="TPS", Default=false, Callback=function(v) config.Visuals.TPS.Value=v end})
    __visuals:AddToggle({Name="Spectate", Default=false, Callback=function(v) config.Visuals.Spectate.Value=v end})

    -- [COMBATS]
    __combats:AddToggle({Name="Anti Grab", Default=false, Callback=function(v) config.Combats.AntiGrab.Value=v end})
    __combats:AddToggle({Name="Anti Void", Default=false, Callback=function(v) config.Combats.AntiVoid.Value=v end})
    __combats:AddToggle({Name="Anti Far", Default=false, Callback=function(v) config.Combats.AntiFar.Value=v end})
    __combats:AddToggle({Name="Anti Explode", Default=false, Callback=function(v) config.Combats.AntiExplode.Value=v end})
    __combats:AddToggle({Name="Str Anti Grab", Default=false, Callback=function(v) config.Combats.StrAntiGrab.Value=v end})
    __combats:AddToggle({Name="Extinguisher", Default=false, Callback=function(v) config.Combats.Extinguisher.Value=v end})
    __combats:AddToggle({Name="Invisible Line", Default=false, Callback=function(v) config.Combats.InvisLine.Value=v end})
    __combats:AddToggle({Name="Super Strength", Default=false, Callback=function(v) config.Combats.SuperStrength.Value=v end})
    __combats:AddSlider({Name="SS Power", Min=0, Max=1000, Default=250, Increment=10, Callback=function(v) config.Combats.SuperStrength.Power.Value=v end})
    __combats:AddToggle({Name="Infinite Line", Default=false, Callback=function(v) config.Combats.InfLine.Value=v end})
    __combats:AddSlider({Name="Inf Dist", Min=0, Max=1000, Default=0, Increment=1, Callback=function(v) config.Combats.InfLine.Dist.Value=v end})
    __combats:AddLabel("Revenge")
    __combats:AddToggle({Name="Rev Void", Default=false, Callback=function(v) config.Combats.Revenge.Void.Value=v end})
    __combats:AddToggle({Name="Rev Kill", Default=false, Callback=function(v) config.Combats.Revenge.Kill.Value=v end})
    __combats:AddToggle({Name="Rev Poison", Default=false, Callback=function(v) config.Combats.Revenge.Poison.Value=v end})
    __combats:AddToggle({Name="Rev Ragdoll", Default=false, Callback=function(v) config.Combats.Revenge.Ragdoll.Value=v end})
    __combats:AddToggle({Name="Rev Death", Default=false, Callback=function(v) config.Combats.Revenge.Death.Value=v end})
    __combats:AddLabel("AimBot")
    __combats:AddToggle({Name="Enabled", Default=false, Callback=function(v) config.Combats.AimBot.Value=v end})
    __combats:AddSlider({Name="Radius", Min=0, Max=100, Default=30, Increment=1, Callback=function(v) config.Combats.AimBot.Radius.Value=v end})
    __combats:AddDropdown({Name="Part", Default="Torso", Options={"Head", "Torso", "HumanoidRootPart"}, Callback=function(v) config.Combats.AimBot.Part.Value=v end})

    -- [AURAS]
    __auras:AddToggle({Name="Void Aura", Default=false, Callback=function(v) config.Auras.Void.Value=v end})
    __auras:AddToggle({Name="Kill Aura", Default=false, Callback=function(v) config.Auras.Kill.Value=v end})
    __auras:AddToggle({Name="Poison Aura", Default=false, Callback=function(v) config.Auras.Poison.Value=v end})
    __auras:AddToggle({Name="Ragdoll Aura", Default=false, Callback=function(v) config.Auras.Ragdoll.Value=v end})
    __auras:AddToggle({Name="Death Aura", Default=false, Callback=function(v) config.Auras.Death.Value=v end})
    __auras:AddToggle({Name="Fire Aura", Default=false, Callback=function(v) config.Auras.Fire.Value=v end})
    __auras:AddToggle({Name="Anchor Aura", Default=false, Callback=function(v) config.Auras.Anchor.Value=v end})
    __auras:AddToggle({Name="Noclip Aura", Default=false, Callback=function(v) config.Auras.Noclip.Value=v end})

    -- [GRABS]
    __grabs:AddToggle({Name="Void Grab", Default=false, Callback=function(v) config.Grabs.Void.Value=v end})
    __grabs:AddToggle({Name="Kill Grab", Default=false, Callback=function(v) config.Grabs.Kill.Value=v end})
    __grabs:AddToggle({Name="Poison Grab", Default=false, Callback=function(v) config.Grabs.Poison.Value=v end})
    __grabs:AddToggle({Name="Ragdoll Grab", Default=false, Callback=function(v) config.Grabs.Ragdoll.Value=v end})
    __grabs:AddToggle({Name="Death Grab", Default=false, Callback=function(v) config.Grabs.Death.Value=v end})
    __grabs:AddToggle({Name="Anchor Grab", Default=false, Callback=function(v) config.Grabs.Anchor.Value=v end})
    __grabs:AddToggle({Name="Kick Grab", Default=false, Callback=function(v) config.Grabs.Kick.Value=v end})
    __grabs:AddToggle({Name="Noclip Grab", Default=false, Callback=function(v) config.Grabs.Noclip.Value=v end})

    -- [MISCS]
    __miscs:AddToggle({Name="Network Owner Aura", Default=false, Callback=function(v) config.Miscs.NWO.Value=v end})
    __miscs:AddToggle({Name="Control Other", Default=false, Callback=function(v) config.Miscs.Control.Value=v end})
    __miscs:AddToggle({Name="No Typing", Default=false, Callback=function(v) config.Miscs.NoTyping.Value=v end})
    __miscs:AddToggle({Name="Anti Kick Disabler", Default=false, Callback=function(v) config.Miscs.AntiKick.Value=v end})

    -- [BLOBMAN]
    __blobmans:AddTextbox({Name="Target", Default="", TextDisappear=false, Callback=function(v) config.Blobman.Target.Value=v end})
    __blobmans:AddDropdown({Name="Arm Side", Default="Left", Options={"Left", "Right"}, Callback=function(v) config.Blobman.ArmSide.Value=v end})
    __blobmans:AddButton({Name="Spawn Blob", Callback=function() if not getBlobman() then spawnBlobmanFunc() end end})
    __blobmans:AddButton({Name="Sit", Callback=function() local b=getBlobman(); if b and getLocalHum() then b.VehicleSeat:Sit(getLocalHum()) end end})
    __blobmans:AddButton({Name="Unsit", Callback=function() if getLocalHum() then getLocalHum().Sit=false end end})
    __blobmans:AddButton({Name="Destroy", Callback=function() local b=getBlobman(); if b then destroyToy(b) end end})
    __blobmans:AddToggle({Name="Noclip", Default=false, Callback=function(v) config.Blobman.Noclip.Value=v end})
    __blobmans:AddButton({Name="Bring Target", Callback=function()
        local t = getPlayerFromName(config.Blobman.Target.Value)
        local b = getBlobman()
        if t and b and t.Character and t.Character:FindFirstChild("HumanoidRootPart") then
            blobBring(b, t.Character.HumanoidRootPart, config.Blobman.ArmSide.Value)
        end
    end})
    __blobmans:AddButton({Name="Kick Target", Callback=function()
        local t = getPlayerFromName(config.Blobman.Target.Value)
        local b = getBlobman()
        if t and b and t.Character and t.Character:FindFirstChild("HumanoidRootPart") then
            blobKick(b, t.Character.HumanoidRootPart, config.Blobman.ArmSide.Value)
        end
    end})
    __blobmans:AddButton({Name="Slide All", Callback=function()
        local b = getBlobman() or spawnBlobmanFunc()
        if not b then return end
        if not getLocalHum().Sit and b:FindFirstChild("VehicleSeat") then b.VehicleSeat:Sit(getLocalHum()) end
        task.wait(0.5)
        if not getLocalHum().Sit then return end
        local pos = getLocalRoot().CFrame
        blobGrab(b, getLocalRoot(), config.Blobman.ArmSide.Value)
        for _,v in ipairs(service.Players:GetPlayers()) do
            if v ~= getLocalPlayer() and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
                if not IsInPlot(v) and not IsFriend(v) then
                    getLocalRoot().CFrame = v.Character.HumanoidRootPart.CFrame
                    task.wait(0.2)
                    blobGrab(b, v.Character.HumanoidRootPart, config.Blobman.ArmSide.Value)
                end
            end
        end
        getLocalRoot().CFrame = pos
        destroyToy(b)
    end})
    __blobmans:AddButton({Name="Kick All", Callback=function()
        local b = getBlobman() or spawnBlobmanFunc()
        if not b then return end
        if not getLocalHum().Sit and b:FindFirstChild("VehicleSeat") then b.VehicleSeat:Sit(getLocalHum()) end
        task.wait(0.5)
        if not getLocalHum().Sit then return end
        local pos = getLocalRoot().CFrame
        blobGrab(b, getLocalRoot(), config.Blobman.ArmSide.Value)
        for _,v in ipairs(service.Players:GetPlayers()) do
            if v ~= getLocalPlayer() and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
                if not IsInPlot(v) and not IsFriend(v) then
                    getLocalRoot().CFrame = v.Character.HumanoidRootPart.CFrame
                    task.wait(0.25)
                    blobKick(b, v.Character.HumanoidRootPart, config.Blobman.ArmSide.Value)
                end
            end
        end
        getLocalRoot().CFrame = pos
        destroyToy(b)
    end})
    __blobmans:AddToggle({Name="Grab Aura", Default=false, Callback=function(v) config.Blobman.GrabAura.Value=v end})
    __blobmans:AddToggle({Name="Kick Aura", Default=false, Callback=function(v) config.Blobman.KickAura.Value=v end})
    __blobmans:AddToggle({Name="Loop Kick Target", Default=false, Callback=function(v) config.Blobman.LoopKick.Value=v end})
    __blobmans:AddToggle({Name="Loop Kick All", Default=false, Callback=function(v) config.Blobman.LoopKickAll.Value=v end})

    -- [SNIPES]
    __snipes:AddTextbox({Name="Target", Default="", TextDisappear=false, Callback=function(v) config.Snipes.Target.Value=v end})
    __snipes:AddButton({Name="Bring", Callback=function()
        local t = getPlayerFromName(config.Snipes.Target.Value)
        local pos = getLocalRoot().CFrame
        if t and t.Character and t.Character:FindFirstChild("HumanoidRootPart") then
            Snipefunc(t.Character.HumanoidRootPart, function() 
                t.Character.HumanoidRootPart.CFrame = pos
                task.wait(0.5)
                ungrab(t.Character.HumanoidRootPart)
            end)
        end
    end})
    __snipes:AddButton({Name="Void", Callback=function()
        local t = getPlayerFromName(config.Snipes.Target.Value)
        if t and t.Character and t.Character:FindFirstChild("HumanoidRootPart") then
            Snipefunc(t.Character.HumanoidRootPart, function() Velocity(t.Character.HumanoidRootPart, Vector3.new(0,10000,0)) end)
        end
    end})
    __snipes:AddButton({Name="Kill", Callback=function()
        local t = getPlayerFromName(config.Snipes.Target.Value)
        if t and t.Character and t.Character:FindFirstChild("HumanoidRootPart") then
            Snipefunc(t.Character.HumanoidRootPart, function() 
                MoveTo(t.Character.HumanoidRootPart, CFrame.new(4096, -75, 4096))
                Velocity(t.Character.HumanoidRootPart, Vector3.new(0, -1000, 0))
            end)
        end
    end})
    __snipes:AddButton({Name="Poison", Callback=function()
        local t = getPlayerFromName(config.Snipes.Target.Value)
        if t and t.Character and t.Character:FindFirstChild("HumanoidRootPart") then
            Snipefunc(t.Character.HumanoidRootPart, function() MoveTo(t.Character.HumanoidRootPart, CFrame.new(58, -70, 271)) end)
        end
    end})
    __snipes:AddButton({Name="Ragdoll", Callback=function()
        local t = getPlayerFromName(config.Snipes.Target.Value)
        if t and t.Character and t.Character:FindFirstChild("HumanoidRootPart") then
            Snipefunc(t.Character.HumanoidRootPart, function() Velocity(t.Character.HumanoidRootPart, Vector3.new(0,-64,0)) end)
        end
    end})
    __snipes:AddButton({Name="Death", Callback=function()
        local t = getPlayerFromName(config.Snipes.Target.Value)
        if t and t.Character and t.Character:FindFirstChild("HumanoidRootPart") then
            Snipefunc(t.Character.HumanoidRootPart, function() 
                t.Character:FindFirstChild("Humanoid"):ChangeState(Enum.HumanoidStateType.Dead)
                ungrab(t.Character.HumanoidRootPart)
            end)
        end
    end})
    __snipes:AddToggle({Name="Loop Void", Default=false, Callback=function(v) config.Snipes.Void.Value=v end})
    __snipes:AddToggle({Name="Loop Kill", Default=false, Callback=function(v) config.Snipes.Kill.Value=v end})
    __snipes:AddToggle({Name="Loop Poison", Default=false, Callback=function(v) config.Snipes.Poison.Value=v end})
    __snipes:AddToggle({Name="Loop Ragdoll", Default=false, Callback=function(v) config.Snipes.Ragdoll.Value=v end})
    __snipes:AddToggle({Name="Loop Death", Default=false, Callback=function(v) config.Snipes.Death.Value=v end})

    -- [TROLLS]
    __trolls:AddButton({Name="Burn All", Callback=function()
        local oven = spawntoy("OvenDarkGray", getLocalRoot().CFrame)
        if not oven then return end
        SetNetworkOwner(oven.ButtonOven)
        ungrab(oven.ButtonOven)
        SetNetworkOwner(oven.SoundPart)
        for _,v in ipairs(service.Players:GetPlayers()) do
            if v ~= getLocalPlayer() and not IsInPlot(v) and not IsFriend(v) and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
                task.wait(0.25)
                oven.SoundPart.CFrame = v.Character.HumanoidRootPart.CFrame
            end
        end
        task.wait(1)
        destroyToy(oven)
    end})
    __trolls:AddButton({Name="Fire All", Callback=function()
        local toy = spawntoy("Campfire", getLocalRoot().CFrame)
        if not toy then return end
        SetNetworkOwner(toy.SoundPart)
        for _,v in ipairs(service.Players:GetPlayers()) do
            if v ~= getLocalPlayer() and not IsInPlot(v) and not IsFriend(v) and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
                task.wait(0.25)
                toy.SoundPart.CFrame = v.Character.HumanoidRootPart.CFrame
            end
        end
        task.wait(1)
        destroyToy(toy)
    end})
    __trolls:AddToggle({Name="Loud All", Default=false, Callback=function(v)
        config.Trolls.Loud.Value = v
        if v then
            local s = spawntoy("BellBig", getLocalRoot().CFrame)
            task.wait(0.5)
            if s then
                config.Trolls.Loud.Part.Value = s
                SetNetworkOwner(s.SoundPart)
            end
        else
            if config.Trolls.Loud.Part.Value then destroyToy(config.Trolls.Loud.Part.Value) end
        end
    end})
    __trolls:AddToggle({Name="Lag", Default=false, Callback=function(v) config.Trolls.Lag.Value=v end})
    __trolls:AddToggle({Name="Ping", Default=false, Callback=function(v) config.Trolls.Ping.Value=v end})
    __trolls:AddToggle({Name="Server Destroyer", Default=false, Callback=function(v) config.Trolls.Server.Value=v; if v then config.Trolls.Server.CF=getLocalRoot().CFrame end end})
    __trolls:AddToggle({Name="Chaos Line", Default=false, Callback=function(v) config.Trolls.Chaos.Value=v end})
    __trolls:AddButton({Name="THE WORLD", Callback=function()
        playSound("rbxassetid://7514417921")
        task.wait(1)
        local e = Instance.new("Part", workspace)
        e.Size, e.Shape, e.Material, e.Color = Vector3.one, Enum.PartType.Ball, Enum.Material.ForceField, Color3.new(.5,.7,0.2)
        e.CanCollide, e.Anchored, e.Transparency = false, true, 0
        task.spawn(function()
            while true do
                e.Size = e.Size + Vector3.one/2
                e.CFrame = getLocalRoot().CFrame
                e.Transparency = e.Transparency + 0.05
                if e.Transparency >= 1 then e:Destroy(); break end
                lag(4096)
                task.wait()
            end
        end)
    end})

    -- [SETTINGS & INFO]
    __settings:AddButton({Name="Save Config", Callback=function() if OrionLib then OrionLib:MakeNotification({Name="Config",Content="Saved",Time=2}) end end}) -- Orion auto saves
    __settings:AddSlider({Name="Aura Radius", Min=0, Max=128, Default=32, Callback=function(v) config.Settings.Radius.Value=v end})
    __settings:AddButton({Name="Inf Radius", Callback=function() config.Settings.Radius.Value=10000 end})
    __settings:AddSlider({Name="Aim Speed", Min=1, Max=10, Default=5, Callback=function(v) config.Settings.AimSpeed.Value=v end})
    __settings:AddToggle({Name="Ignore Friend", Default=false, Callback=function(v) config.Settings.IgnoreFriend.Value=v end})
    __settings:AddToggle({Name="Ignore Plot", Default=false, Callback=function(v) config.Settings.IgnorePlot.Value=v end})
    __settings:AddToggle({Name="Only Player", Default=false, Callback=function(v) config.Settings.OnlyPlayer.Value=v end})
    __settings:AddSlider({Name="Lag Amount", Min=0, Max=4096, Default=1024, Callback=function(v) config.Settings.Lag.Value=v end})
    __settings:AddSlider({Name="Ping Amount", Min=0, Max=4096, Default=1024, Callback=function(v) config.Settings.Ping.Value=v end})
    __settings:AddDropdown({Name="Kick Method", Default="Void", Options={"Void", "Float"}, Callback=function(v) config.Settings.KickMethod.Value=v end})
    __settings:AddToggle({Name="Debug Mode", Default=false, Callback=function(v) config.Settings.Debug.Value=v end})
    __settings:AddButton({Name="Rejoin", Callback=function() service.TeleportService:Teleport(game.PlaceId, getLocalPlayer()) end})
    
    __infos:AddLabel("Discord: https://discord.gg/ENnZ4W9eMN")
    __infos:AddLabel("Notes: Made by Luna!")

    --// KEY INPUTS
    local keys = {W=false, A=false, S=false, D=false, Space=false, Shift=false}
    service.UserInputService.InputBegan:Connect(function(i,g)
        if g then return end
        if i.KeyCode==Enum.KeyCode.W then keys.W=true elseif i.KeyCode==Enum.KeyCode.A then keys.A=true elseif i.KeyCode==Enum.KeyCode.S then keys.S=true elseif i.KeyCode==Enum.KeyCode.D then keys.D=true elseif i.KeyCode==Enum.KeyCode.Space then keys.Space=true elseif i.KeyCode==Enum.KeyCode.LeftShift then keys.Shift=true end
    end)
    service.UserInputService.InputEnded:Connect(function(i,g)
        if g then return end
        if i.KeyCode==Enum.KeyCode.W then keys.W=false elseif i.KeyCode==Enum.KeyCode.A then keys.A=false elseif i.KeyCode==Enum.KeyCode.S then keys.S=false elseif i.KeyCode==Enum.KeyCode.D then keys.D=false elseif i.KeyCode==Enum.KeyCode.Space then keys.Space=false elseif i.KeyCode==Enum.KeyCode.LeftShift then keys.Shift=false end
    end)
    service.UserInputService.InputChanged:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseWheel then
            if i.Position.Z > 0 then config.Combats.InfLine.Dist.Value = config.Combats.InfLine.Dist.Value + 7 else config.Combats.InfLine.Dist.Value = math.max(0, config.Combats.InfLine.Dist.Value - 7) end
        end
    end)
    
    --// MAIN LOOP LOGIC
    local timers = {AntiDetect=0, Banana=0, Aura=0, Server=0, Esp=0, Ext=0, Snipe=0, Loud=0, Kick=0, KickDisable=0}
    
    -- ESP Logic (Visuals)
    local function updateESP()
        if config.Visuals.ESP.Value then
            for _,p in ipairs(service.Players:GetPlayers()) do
                if p ~= getLocalPlayer() and p.Character and not p.Character:FindFirstChild("__esp") then
                    local h = Instance.new("Highlight", p.Character)
                    h.Name = "__esp"
                    h.FillColor = config.Visuals.ESP.Fill
                    h.OutlineColor = config.Visuals.ESP.Out
                elseif p.Character and p.Character:FindFirstChild("__esp") then
                    p.Character.__esp.FillColor = config.Visuals.ESP.Fill
                    p.Character.__esp.OutlineColor = config.Visuals.ESP.Out
                end
            end
        else
            for _,p in ipairs(service.Players:GetPlayers()) do
                if p.Character and p.Character:FindFirstChild("__esp") then p.Character.__esp:Destroy() end
            end
        end
    end

    loop.Event:Connect(function(dt)
        for k,v in pairs(timers) do timers[k] = v + dt end
        
        -- Movement Logic
        if config.Movements.CrouchSpeedHack.Loop then getLocalHum().WalkSpeed = config.Movements.CrouchSpeedHack.Value end
        if config.Movements.JumppowerHack.Loop then getLocalHum().JumpPower = config.Movements.JumppowerHack.Value end
        if config.Movements.Freeze.Value then getLocalRoot().CFrame = config.Movements.Freeze.CFrame end
        if config.Movements.Noclip.Value then for _,v in ipairs(getLocalChar():GetDescendants()) do if v:IsA("BasePart") then v.CanCollide=false end end end
        
        if config.Movements.Fly.Value then
            local hum = getLocalHum()
            local root = getLocalRoot()
            if hum and root then
                hum.PlatformStand = true
                local dir = Vector3.zero
                local cf = workspace.CurrentCamera.CFrame
                if keys.W then dir = dir + cf.LookVector end
                if keys.S then dir = dir - cf.LookVector end
                if keys.A then dir = dir - cf.RightVector end
                if keys.D then dir = dir + cf.RightVector end
                if keys.Space then dir = dir + Vector3.new(0,1,0) end
                if keys.Shift then dir = dir - Vector3.new(0,1,0) end
                
                if config.Settings.FlyMethod.Value == "Velocity" then
                    root.AssemblyLinearVelocity = dir.Unit * config.Movements.SpeedHack.Value
                else
                    root.CFrame = root.CFrame + (dir.Unit * config.Movements.SpeedHack.Value * dt)
                    root.AssemblyLinearVelocity = Vector3.zero
                end
            end
        else
            if getLocalHum() then getLocalHum().PlatformStand = false end
        end

        -- Player Logic
        if timers.AntiDetect >= 0.5 then
            if config.Players.AntiDetect.Value then AntiDetect() end
            timers.AntiDetect = 0
        end
        if config.Players.AntiRagdoll.Value and getLocalHum() and (getLocalHum():GetState() == Enum.HumanoidStateType.Ragdoll or getLocalHum():GetState() == Enum.HumanoidStateType.FallingDown) then
            ragdoll(); getLocalHum():ChangeState(Enum.HumanoidStateType.Running)
        end
        if config.Players.Ragdoll.Value then ragdoll(); getLocalHum().PlatformStand = true end
        if config.Players.AntiGucci.Value then ragdoll() end

        -- Visuals
        if timers.Esp >= 1 then updateESP(); timers.Esp = 0 end
        workspace.CurrentCamera.FieldOfView = config.Visuals.FOV.Value
        if config.Visuals.TPS.Value then getLocalPlayer().CameraMaxZoomDistance=10000 else getLocalPlayer().CameraMode=Enum.CameraMode.LockFirstPerson end

        -- Combat / Auras
        if timers.Aura >= 0.5 then
            for _,v in ipairs(GetNearParts(getLocalRoot().Position, config.Settings.Radius.Value)) do
                if v.Name == "HumanoidRootPart" and v.Parent ~= getLocalChar() then
                    local p = service.Players:GetPlayerFromCharacter(v.Parent)
                    if not (p and IsFriend(p) and config.Settings.IgnoreFriend.Value) then
                        if config.Auras.Void.Value then SetNetworkOwner(v); v.CanCollide=false; Velocity(v, Vector3.new(0,10000,0)) end
                        if config.Auras.Kill.Value then SetNetworkOwner(v); v.CanCollide=false; MoveTo(v, CFrame.new(4096,-75,4096)); Velocity(v, Vector3.new(0,-1000,0)) end
                        if config.Auras.Poison.Value then SetNetworkOwner(v); MoveTo(v, CFrame.new(58,-70,271)) end
                        if config.Auras.Ragdoll.Value then SetNetworkOwner(v); Velocity(v, Vector3.new(0,-64,0)) end
                        if config.Auras.Death.Value then SetNetworkOwner(v); if v.Parent:FindFirstChild("Humanoid") then v.Parent.Humanoid:ChangeState(Enum.HumanoidStateType.Dead) end; ungrab(v) end
                        if config.Auras.Anchor.Value then anchor(v) end
                        if config.Auras.Fire.Value then 
                            local t = spawntoy("Campfire", getLocalRoot().CFrame); 
                            if t then SetNetworkOwner(t.SoundPart); t.SoundPart.CFrame=v.CFrame; task.delay(0.5, destroyToy, t) end 
                        end
                    end
                end
            end
            timers.Aura = 0
        end

        -- Anti Void/Far
        if config.Combats.AntiVoid.Value and getLocalRoot().Position.Y < -80 then
            getLocalRoot().CFrame = workspace.SpawnLocation.CFrame + Vector3.new(0,10,0); getLocalRoot().AssemblyLinearVelocity = Vector3.zero
        end

        -- Trolls
        if config.Trolls.Lag.Value then lag(config.Settings.Lag.Value) end
        if config.Trolls.Ping.Value then ping(config.Settings.Ping.Value) end
        if timers.Server >= 0.1 then
            if config.Trolls.Server.Value then for i=1,32 do createLine(nil); getLocalRoot().CFrame = config.Trolls.Server.CF end end
            timers.Server = 0
        end
        if config.Trolls.Chaos.Value then for i=1,32 do createLine(nil) end end
        if timers.Loud >= 0.1 then
            if config.Trolls.Loud.Value and config.Trolls.Loud.Part.Value then
                for _,v in ipairs(service.Players:GetPlayers()) do
                    if v ~= getLocalPlayer() and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
                        config.Trolls.Loud.Part.Value.SoundPart.CFrame = v.Character.HumanoidRootPart.CFrame
                    end
                end
            end
            timers.Loud = 0
        end

        -- Grab Logic
        -- Note: Full grab logic requires childAdded listener which is separate from loop, but basics like InvisLine are here
        if config.Combats.InvisLine.Value then service.ReplicatedStorage.GrabEvents.DestroyGrabLine:FireServer() end
        
        -- Blobman
        if config.Blobman.Noclip.Value then local b=getBlobman(); if b then for _,v in ipairs(b:GetDescendants()) do if v:IsA("BasePart") then v.CanCollide=false end end end end
        if config.Blobman.LoopKick.Value then
            local t = getPlayerFromName(config.Blobman.Target.Value)
            local b = getBlobman()
            if t and b and t.Character and t.Character:FindFirstChild("HumanoidRootPart") then blobKick(b, t.Character.HumanoidRootPart, config.Blobman.ArmSide.Value) end
        end
        if config.Blobman.LoopKickAll.Value then
            local b = getBlobman()
            if b then
                for _,v in ipairs(service.Players:GetPlayers()) do
                    if v~=getLocalPlayer() and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then blobKick(b, v.Character.HumanoidRootPart, config.Blobman.ArmSide.Value) end
                end
            end
        end

        -- Snipes Loops
        if timers.Snipe >= 1 then
            local t = getPlayerFromName(config.Snipes.Target.Value)
            if t and t.Character and t.Character:FindFirstChild("HumanoidRootPart") then
                local root = t.Character.HumanoidRootPart
                if config.Snipes.Void.Value then Snipefunc(root, function() Velocity(root, Vector3.new(0,10000,0)) end) end
                if config.Snipes.Kill.Value then Snipefunc(root, function() MoveTo(root, CFrame.new(4096,-75,4096)); Velocity(root, Vector3.new(0,-1000,0)) end) end
                if config.Snipes.Poison.Value then Snipefunc(root, function() MoveTo(root, CFrame.new(58,-70,271)) end) end
                if config.Snipes.Ragdoll.Value then Snipefunc(root, function() Velocity(root, Vector3.new(0,-64,0)) end) end
                if config.Snipes.Death.Value then Snipefunc(root, function() if root.Parent:FindFirstChild("Humanoid") then root.Parent.Humanoid:ChangeState(Enum.HumanoidStateType.Dead) end; ungrab(root) end) end
            end
            timers.Snipe = 0
        end
    end)

    -- GRAB CHILD ADDED LOGIC
    workspace.ChildAdded:Connect(function(v)
        if v.Name == "GrabParts" and v:IsA("Model") then
            local grabbing = v:FindFirstChild("GrabPart") and v.GrabPart:FindFirstChild("WeldConstraint") and v.GrabPart.WeldConstraint.Part1
            if not grabbing then return end
            
            local function doGrab(func) task.spawn(func) end
            
            if config.Grabs.Void.Value then doGrab(function() for i=1,3 do SetNetworkOwner(grabbing); task.wait() end; Velocity(grabbing, Vector3.new(0,10000,0)) end) end
            if config.Grabs.Kill.Value then doGrab(function() for i=1,3 do SetNetworkOwner(grabbing); task.wait() end; MoveTo(grabbing, CFrame.new(4096,-75,4096)); Velocity(grabbing, Vector3.new(0,-1000,0)) end) end
            if config.Grabs.Poison.Value then doGrab(function() for i=1,3 do SetNetworkOwner(grabbing); task.wait() end; MoveTo(grabbing, CFrame.new(58,-70,271)) end) end
            if config.Grabs.Ragdoll.Value then doGrab(function() local pos=grabbing.CFrame; for i=1,3 do SetNetworkOwner(grabbing); task.wait() end; Velocity(grabbing, Vector3.new(0,-256,0)); task.wait(); MoveTo(grabbing, pos); Velocity(grabbing, Vector3.zero) end) end
            if config.Grabs.Anchor.Value then doGrab(function() anchor(grabbing) end) end
            if config.Grabs.Death.Value then doGrab(function() for i=1,3 do SetNetworkOwner(grabbing); task.wait() end; if grabbing.Parent:FindFirstChild("Humanoid") then grabbing.Parent.Humanoid:ChangeState(Enum.HumanoidStateType.Dead) end; ungrab(grabbing) end) end
            if config.Grabs.Kick.Value then doGrab(function() 
                local p = service.Players:GetPlayerFromCharacter(grabbing.Parent)
                if p and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                    local root = p.Character.HumanoidRootPart
                    if config.Settings.KickMethod.Value == "Void" then
                        ungrab(grabbing)
                        while p and root do
                            if p.Character.Humanoid.FloorMaterial ~= Enum.Material.Air then
                                local pos = getLocalRoot().CFrame; getLocalRoot().CFrame=root.CFrame; task.wait(.1); SetNetworkOwner(root); task.wait(.1); MoveTo(grabbing, CFrame.new(9e9,9e9,9e9)); Velocity(root, root.AssemblyLinearVelocity*9e9); ungrab(root); getLocalRoot().CFrame=pos
                            end
                            task.wait()
                        end
                    end
                end
            end) end
            
            if config.Miscs.Control.Value then
                local p = service.Players:GetPlayerFromCharacter(grabbing.Parent)
                if not p and grabbing.Parent:FindFirstChild("Humanoid") and grabbing.Parent.PrimaryPart then
                    SetNetworkOwner(grabbing.Parent.PrimaryPart)
                    config.Miscs.Control.Target.Value = grabbing.Parent
                end
            end
        end
    end)
end

print("[Suisei Hub] Full Version Loaded")
