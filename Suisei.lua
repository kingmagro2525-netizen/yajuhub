--[[
==== SUISEI HUB ====
Made by Luna!! (Modified for Orion Library)
(https://luna0322.onrender.com)
]]

local service = setmetatable({}, {
    __index = function(self, k)
        local s = game:GetService(k)
        rawset(self, k, s)
        return s
    end,
})

-- Orion Libraryのロード
local OrionLib = nil
local ols, olr = pcall(function()
    OrionLib = loadstring(game:HttpGet('https://raw.githubusercontent.com/shlexware/Orion/main/source'))()
end)

if (not ols or not OrionLib) then
    local s, r = pcall(function()
        service.StarterGui:SetCore("MakeNotification", {
            Title = "Suisei Hub",
            Text = "Failed to Load OrionLib"
        })
    end)
    if (not s) then
        warn(r)
    end
    return warn("[Suisei Hub] Critical Error\nError Message: " .. olr)
end

-- WindUIの通知機能をOrionのNotifyに置き換えるためのラッパー関数
local function windNotify(data)
    OrionLib:MakeNotification({
        Name = data.Title,
        Content = data.Content,
        Time = data.Duration or 5,
        Image = data.Icon or "rbxassetid://13264628286", -- デフォルトの通知画像
        Callback = function() end
    })
end

local loop = Instance.new("BindableEvent")
service.RunService.Heartbeat:Connect(function(dt)
    loop:Fire(dt)
end)

do
    --// USELESS UTILS
    function hn(func, ...)
        if (service.RunService:IsStudio()) then print('hn call') end
        if (coroutine.status(task.spawn(hn, func, ...)) == "dead") then return end
        return pcall(func, ...)
    end
    function sn(depth, func, ...)
        if (depth >= 80) then return pcall(func, ...) end
        task.defer(sn, depth + 1, func, ...)
    end

    --// FUNCTIONS/VARIABLES/UTILS
    local get = game.FindFirstChild
    local cget = game.FindFirstChildOfClass
    local waitc = game.WaitForChild
    local function getLocalPlayer()
        return service.Players.LocalPlayer
    end
    local function getMouse()
        return getLocalPlayer():GetMouse()
    end
    local function getLookTarget()
        return getMouse().Target
    end
    local function getLocalChar()
        return getLocalPlayer().Character
    end
    local function getLocalRoot()
        if (not getLocalChar()) then return end
        return get(getLocalChar(), "HumanoidRootPart") or get(getLocalChar(), "Torso")
    end
    local function getLocalHum()
        if (not getLocalChar()) then return end
        return cget(getLocalChar(), "Humanoid")
    end
    local function Velocity(part, value)
        local b = Instance.new("BodyVelocity")
        b.MaxForce = Vector3.one * math.huge
        b.Velocity = value
        b.Parent = part
        task.spawn(task.delay, 1, game.Destroy, b)
    end
    local function SetNetworkOwner(part)
        service.ReplicatedStorage.GrabEvents.SetNetworkOwner:FireServer(part, getLocalRoot().CFrame)
    end
    local function GetNearParts(origin, radius)
        return workspace:GetPartBoundsInRadius(origin, radius)
    end
    local function IsInRadius(part, origin, radius)
        if ((part.Position - origin).Magnitude <= radius) then
            return true
        end
        return false
    end
    local function MoveTo(part, x)
        for _, v in ipairs(part.Parent:GetDescendants()) do
            if (v:IsA("BasePart")) then
                v.CanCollide = false
            end
        end
        local pos = typeof(x) == "CFrame" and x.Position or x
        local b = Instance.new("BodyPosition")
        b.MaxForce = Vector3.one * math.huge
        b.Position = pos
        b.P = 2e4
        b.D = 5e3
        b.Parent = part
        task.spawn(function()
            b.ReachedTarget:Wait()
            pcall(game.Destroy, b)
            for _, v in ipairs(part.Parent:GetDescendants()) do
                if (v:IsA("BasePart")) then
                    v.CanCollide = true
                end
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
        for _ = 1, value do
            service.ReplicatedStorage.GrabEvents.CreateGrabLine:FireServer()
        end
    end
    local function ping(value)
        for _ = 1, value do
            service.ReplicatedStorage.GrabEvents.ExtendGrabLine:FireServer(string.rep("Balls Balls Balls Balls", value))
        end
    end
    local function createLine(part)
        service.ReplicatedStorage.GrabEvents.CreateGrabLine:FireServer(part, CFrame.identity)
    end
    local function ungrab(part)
        service.ReplicatedStorage.GrabEvents.DestroyGrabLine:FireServer(part)
    end
    local function kickGrab(player)
        local char = player.Character
        if (not char) then return end
        local root = get(char, "HumanoidRootPart")
        local fpp = get(root, "FirePlayerPart")
        fpp.Size = Vector3.new(4.5, 5.5, 4.5)
        fpp.CollisionGroup = "1"
        fpp.CanQuery = true
    end
    local function getInv()
        return get(workspace, getLocalPlayer().Name .. "SpawnedInToys")
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
    curAntiDetectPart = nil
    local function AntiDetect()
        repeat task.wait() until getLocalChar() and getLocalRoot()
        local exists = false
        if (getInv()) then
            for _, v in pairs(getInv():GetChildren()) do
                if (v.Name == "NinjaShuriken") then
                    exists = true
                    if (get(v.StickyPart, "PartOwner")) then destroyToy(v) end
                    if (get(v.SoundPart, "PartOwner")) then destroyToy(v) end
                    if (v.StickyPart.StickyWeld.Part1 and v.StickyPart.StickyWeld.Part1:IsDescendantOf(getLocalChar())) then return end
                    destroyToy(v)
                    break
                end
            end
        end
        if (not exists) then
            curAntiDetectPart = spawntoy("NinjaShuriken", getLocalRoot().CFrame)
            repeat task.wait() until (get(getInv(), "NinjaShuriken"))
            SetNetworkOwner(curAntiDetectPart.SoundPart)
            curAntiDetectPart.SoundPart.CFrame = getLocalRoot().CFrame + Vector3.new(0, .5, 0)
        end
        repeat task.wait() until (get(getInv(), "NinjaShuriken"))
        curAntiDetectPart.SoundPart.CFrame = getLocalRoot().CFrame + Vector3.new(0, .5, 0)
        local w = Instance.new("WeldConstraint")
        w.Part0 = curAntiDetectPart.SoundPart
        w.Part1 = getLocalRoot()
        w.Parent = getLocalRoot()
    end
    local IsSafespot = false
    local function Safespot()
        if (not IsSafespot) then
            local p = Instance.new("Part", workspace)
            p.Material = Enum.Material.Grass
            p.Transparency = .5
            p.Anchored = true
            p.CFrame = CFrame.new(1e4, 1e4, 1e4)
            p.Size = Vector3.new(128, 4, 128)
            IsSafespot = true
        end
        getLocalRoot().CFrame = CFrame.new(1e4, 1e4 + 10, 1e4)
    end

    local function ragdoll()
        local args = {
            [1] = getLocalRoot(),
            [2] = 0
        }
        service.ReplicatedStorage.CharacterEvents.RagdollRemote:FireServer(unpack(args))
    end

    local function BlackBoxpos()
        return CFrame.new(32e32, 32e32, 32e32)
    end

    --// BLOBMAN
    local function getBlobman()
        local v = get(getInv(), "CreatureBlobman", true)
        if (not v) then
            for _, p in ipairs(workspace.PlotItems:GetChildren()) do
                if (p) then
                    local m = get(p, "CreatureBlobman")
                    if (not m) or (m and m.PlayerValue.Value ~= getLocalPlayer().Name) then
                        windNotify({
                            Title = "Suisei Hub",
                            Content = "Blobman not found!",
                            Duration = 5
                        })
                        return
                    end
                    v = m
                end
            end
        end
        if (v and v.ClassName ~= "Model") then return false end
        if (v and not get(v, "VehicleSeat")) then return false end
        --[[if(not get(v.VehicleSeat,"SeatWeld"))then return false end
        if(v.VehicleSeat.SeatWeld.Part1~=getLocalRoot())then return false end]]
        return v
    end
    local function spawnBlobman()
        local blobman = spawntoy("CreatureBlobman", getLocalRoot().CFrame)
        return blobman
    end
    local function blobGrab(blob, target, side)
        local args = {
            [1] = get(blob, side .. "Detector"),
            [2] = target,
            [3] = get(get(blob, side .. "Detector"), side .. "Weld")
        }
        blob.BlobmanSeatAndOwnerScript.CreatureGrab:FireServer(unpack(args))
    end
    local function blobDrop(blob, target, side)
        local args = {
            [1] = get(blob, side .. "Detector"),
            [2] = target
        }
        blob.BlobmanSeatAndOwnerScript.CreatureDrop:FireServer(unpack(args))
    end
    local function sirentBlobGrab(blob, target, side)
        local args = {
            [1] = get(blob, side .. "Detector"),
            [2] = target,
            [3] = get(blob, side .. "Detector").AttachPlayer
        }
        blob.BlobmanSeatAndOwnerScript.CreatureGrab:FireServer(unpack(args))
    end
    local function blobBring(blob, target, side)
        local pos = getLocalRoot().CFrame
        getLocalRoot().CFrame = target.CFrame
        task.wait(.25)
        blobGrab(blob, target, side)
        task.wait(.25)
        getLocalRoot().CFrame = pos
    end
    local function blobKick(blob, target, side)
        blobGrab(blob, getLocalRoot(), side)
        task.wait(.1)
        SetNetworkOwner(target)
        task.wait()
        target.CFrame = target.CFrame + Vector3.new(0, 16, 0)
        --MoveTo(target,target.CFrame*Vector3.new(0,24,0))
        task.wait(.1)
        ungrab(target)
        blobGrab(blob, target, side)
    end

    local function IsFriend(p)
        if (not p or not p.UserId or not getLocalPlayer()) then return end
        return getLocalPlayer():IsFriendsWith(p.UserId)
    end
    local function IsInPlot(p)
        return p.InPlot.Value
    end
    local function IsInOwnedPlot(p)
        return p.InOwnedPlot.Value
    end

    local function getPlayerFromName(name)
        local tplayer = nil
        local sname = name:lower()
        for _, player in pairs(service.Players:GetPlayers()) do
            if (player.DisplayName:lower():sub(1, #sname) == sname) then
                tplayer = player
                break
            elseif (player.Name:lower():sub(1, #sname) == sname) then
                if (not tplayer) then
                    tplayer = player
                end
            end
        end
        return tplayer
    end

    local function playSound(id)
        task.spawn(function()
            local s = Instance.new("Sound", service.JointsService)
            s.SoundId = id
            s:Play()
            return s
        end)
    end

    local function Snipefunc(root, func, ...)
        local pos = getLocalRoot().CFrame
        task.spawn(function(...)
            local parts = { "Head", "Torso", "HumanoidRootPart" }
            for _, p in pairs(parts) do get(getLocalChar(), p).CanCollide = false end
            getLocalRoot().CFrame = CFrame.new(root.Position - root.CFrame.LookVector * 15)
            task.wait(0.1)
            workspace.CurrentCamera.CFrame = CFrame.lookAt(workspace.CurrentCamera.CFrame.Position, root.Position)
            for _ = 1, 4 do SetNetworkOwner(root) task.wait(0.05) end
            local look = workspace.CurrentCamera.CFrame
            task.wait(0.1)
            func(...)
            workspace.CurrentCamera.CFrame = look
            task.wait(0.1)
            for _, p in pairs(parts) do get(getLocalChar(), p).CanCollide = true end
            getLocalRoot().CFrame = pos
            Velocity(getLocalRoot(), Vector3.zero)
        end, ...)
    end

    --//DEBUGGING
    if (not game:IsLoaded()) then
        windNotify({
            Title = "Suisei Hub",
            Content = "Game not loaded! Waiting...",
            Duration = 5
        })
        game.Loaded:Wait()
        windNotify({
            Title = "Suisei Hub",
            Content = "Game loaded!",
            Duration = 5
        })
    end

    --// MAIN GUI
    local IconURL = "rbxassetid://13264628286" -- Orion Libの標準画像IDを使用（WindUIのURLはここでは使えないため仮で置換）
    local ToggleKeybind = Enum.KeyCode.C

    -- OrionLib:Init()は不要
    -- OrionLib:SetTheme()のようなテーマ設定はOrionにはないか、Createで処理される

    local Window = OrionLib:CreateWindow({
        Name = "Suisei Hub | Luna",
        HideOnStart = false,
        SaveConfig = true,
        ConfigFolder = "SuiseiHub" -- ConfigFolderを設定
    })

    -- OrionLibにはConfigManagerの直接的な呼び出しはないため、グローバルなconfigテーブルを使用

    Window:SetFooter("Fling Thing And People (Beta)")

    Window:SetKey(ToggleKeybind) -- SetToggleKeyの代わりにSetKeyを使用

    windNotify({
        Title = "Suisei Hub",
        Content = "Hello, " .. getLocalPlayer().DisplayName,
        Duration = 5
    })
    windNotify({
        Title = "Suisei Hub",
        Content = ToggleKeybind.Name .. " to toggle the GUI",
        Duration = 5
    })

    local __movements = Window:AddTab({
        Name = "Movements",
        Icon = "rbxassetid://13264628286"
    }) -- Iconはrbxassetid形式または画像ID
    local __players = Window:AddTab({
        Name = "Players",
        Icon = "rbxassetid://13264628286"
    })
    local __visuals = Window:AddTab({
        Name = "Visuals",
        Icon = "rbxassetid://13264628286"
    })
    local __combats = Window:AddTab({
        Name = "Combats",
        Icon = "rbxassetid://13264628286"
    })
    local __auras = Window:AddTab({
        Name = "Auras",
        Icon = "rbxassetid://13264628286"
    })
    local __grabs = Window:AddTab({
        Name = "Grabs",
        Icon = "rbxassetid://13264628286"
    })
    local __miscs = Window:AddTab({
        Name = "Miscs",
        Icon = "rbxassetid://13264628286"
    })
    local __blobmans = Window:AddTab({
        Name = "Blobmans",
        Icon = "rbxassetid://13264628286"
    })
    local __snipes = Window:AddTab({
        Name = "Snipes",
        Icon = "rbxassetid://13264628286"
    })
    local __trolls = Window:AddTab({
        Name = "Trolls",
        Icon = "rbxassetid://13264628286"
    })
    -- WindUIのDividerはOrionにはないため省略
    local __settings = Window:AddTab({
        Name = "Settings",
        Icon = "rbxassetid://13264628286"
    })
    local __infos = Window:AddTab({
        Name = "Infos",
        Icon = "rbxassetid://13264628286"
    })
    --// CONFIG TABLE (OrionはConfigを自動で処理するため、初期値としてのみ使用)
    local config = {
        Movements = {
            CrouchSpeedHack = {
                Value = getLocalHum().WalkSpeed,
                Loop = false
            },
            SpeedHack = {
                Value = getLocalHum().WalkSpeed
            },
            JumppowerHack = {
                Value = getLocalHum().JumpPower
            },
            Freeze = {
                Value = false,
                CFrame = CFrame.new(0, 0, 0)
            },
            Infjump = {
                Value = false
            },
            Fly = {
                Value = false
            },
            Noclip = {
                Value = false
            },
            Teleports = {
                Target = {
                    Value = false
                },
                Barn = {
                    CFrame = CFrame.new(-234, 85, -311)
                },
                BlueBouse = {
                    CFrame = CFrame.new(525, 98, -375)
                },
                Factory = {
                    CFrame = CFrame.new(138, 365, 346)
                },
                GlassHouse = {
                    CFrame = CFrame.new(-325, 109, 337)
                },
                JapaneseHouse = {
                    CFrame = CFrame.new(584, 141, -100)
                },
                PinkRoofHouse = {
                    CFrame = CFrame.new(-525, 22, -165)
                },
                SpookyHouse = {
                    CFrame = CFrame.new(303, 14, 483)
                },
                TudorHouse = {
                    CFrame = CFrame.new(-572, 20, 89)
                },
                TrainCave = {
                    CFrame = CFrame.new(571, 48, -153)
                },
                SmallSecretCave = {
                    CFrame = CFrame.new(-50, -7, -298)
                },
                BigSecretCave = {
                    CFrame = CFrame.new(-130, -7, 575)
                }
            }
        },
        Players = {
            AntiDetect = {
                Value = false
            },
            AntiRagdoll = {
                Value = false
            },
            AntiTouch = {
                Value = false
            },
            AntiBanana = {
                Value = false
            },
            AutoSlot = {
                Value = false,
                Time = 0
            },
            Ragdoll = {
                Value = false
            },
            AntiGucci = {
                Value = false
            }
        },
        Visuals = {
            ESP = {
                Value = false,
                FillColor = Color3.new(0.25, 0, 1),
                OutlineColor = Color3.new(1, 1, 1)
            },
            FOV = {
                Value = 70
            },
            TPS = {
                Value = false
            },
            Spectate = {
                Value = false
            }
        },
        Combats = {
            AntiGrab = {
                Value = false
            },
            AntiVoid = {
                Value = false
            },
            AntiFar = {
                Value = false
            },
            AntiExplode = {
                Value = false
            },
            StrAntiGrab = {
                Value = false
            },
            Extinguisher = {
                Value = false
            },
            InvisLine = {
                Value = false
            },
            SuperStrength = {
                Value = false,
                Power = {
                    Value = 250
                }
            },
            InfLine = {
                Value = false,
                Dist = {
                    Value = 0
                }
            },
            Revenge = {
                Void = {
                    Value = false
                },
                Kill = {
                    Value = false
                },
                Poison = {
                    Value = false
                },
                Ragdoll = {
                    Value = false
                },
                Death = {
                    Value = false
                }
            },
            AimBot = {
                Value = false,
                Radius = {
                    Value = 30
                },
                Part = {
                    Value = "Torso"
                }
            }
        },
        Auras = {
            VoidAura = {
                Value = false
            },
            KillAura = {
                Value = false
            },
            PoisonAura = {
                Value = false
            },
            RagdollAura = {
                Value = false
            },
            DeathAura = {
                Value = false
            },
            FireAura = {
                Value = false
            },
            AnchorAura = {
                Value = false
            },
            NoclipAura = {
                Value = false
            }
        },
        Grabs = {
            VoidGrab = {
                Value = false
            },
            KillGrab = {
                Value = false
            },
            PoisonGrab = {
                Value = false
            },
            RagdollGrab = {
                Value = false
            },
            DeathGrab = {
                Value = false
            },
            AnchorGrab = {
                Value = false
            },
            KickGrab = {
                Value = false
            },
            NoclipGrab = {
                Value = false
            }
        },
        Miscs = {
            NWOAura = {
                Value = false
            },
            Control = {
                Target = {
                    Value = false
                },
                Value = false
            },
            NoTyping = {
                Value = false
            },
            AntiKickDisabler = {
                Value = false
            }
        },
        Blobman = {
            Target = {
                Value = nil
            },
            ArmSide = {
                Value = "Left"
            },
            Noclip = {
                Value = false
            },
            GrabAura = {
                Value = false
            },
            KickAura = {
                Value = false
            },
            LoopKick = {
                Value = false
            },
            LoopKickAll = {
                Value = false
            }
        },
        Snipes = {
            Target = {
                Value = nil
            },
            LoopVoid = {
                Value = false
            },
            LoopKill = {
                Value = false
            },
            LoopPoison = {
                Value = false
            },
            LoopRagdoll = {
                Value = false
            },
            LoopDeath = {
                Value = false
            }
        },
        Trolls = {
            LoudAll = {
                Value = false,
                SoundPart = {
                    Value = nil
                }
            },
            Lag = {
                Value = false
            },
            Ping = {
                Value = false
            },
            ServerDestroyer = {
                Value = false,
                CFrame = CFrame.new(0, 0, 0)
            },
            ChaosLine = {
                Value = false
            }
        },
        Settings = {
            OnlyPlayer = {
                Value = false
            },
            IgnoreFriend = {
                Value = false
            },
            IgnoreIsInPlot = {
                Value = false
            },
            AuraRadius = {
                Value = 32
            },
            AimBotSpeed = {
                Value = 5
            },
            Lag = {
                Value = 32
            },
            Ping = {
                Value = 32
            },
            KickMethod = {
                "Void"
            },
            SpeedHackMethod = {
                "CFrame"
            },
            AutoSpeedHackMethod = {
                Value = false
            },
            FlyMethod = {
                "Velocity"
            },
            DebugMode = {
                Value = false
            }
        },
    }

    local __esp = {}
    local function updateESP()
        for i = #__esp, 1, -1 do
            local v = __esp[i]
            if (not config.Visuals.ESP.Value or not v or not v.Parent) then
                pcall(game.Destroy, v)
                table.remove(__esp, i)
            else
                v.FillColor = config.Visuals.ESP.FillColor
                v.OutlineColor = config.Visuals.ESP.OutlineColor
            end
        end
    end
    local function addESP(character)
        if (get(character, "__esp.suiseihub")) then return end
        local h = Instance.new("Highlight", character)
        h.FillColor = config.Visuals.ESP.FillColor
        h.OutlineColor = config.Visuals.ESP.OutlineColor
        h.Name = "__esp.suiseihub"
        table.insert(__esp, h)
    end

    do
        --// MOVEMENTS
        -- WindUI Slider -> Orion Slider
        __movements:AddSlider("CrouchingSpeed", "Speed (Crouching)", "Speed (Crouching)",
            getLocalHum().WalkSpeed, 0, 150, 1, function(value)
                getLocalHum().WalkSpeed = value
                config.Movements.CrouchSpeedHack.Value = value
            end
        )
        -- WindUI Toggle (Checkbox) -> Orion Toggle
        __movements:AddToggle("CrouchingLoopSpeed", "Loop Speed (Crouching)", false, function(value)
            config.Movements.CrouchSpeedHack.Loop = value
        end)
        -- WindUI Slider -> Orion Slider
        __movements:AddSlider("Jumppower", "Jumppower", "Jumppower",
            getLocalHum().JumpPower, 0, 150, 1, function(value)
                getLocalHum().JumpPower = value
                config.Movements.JumppowerHack.Value = value
            end
        )
        -- WindUI Toggle (Checkbox) -> Orion Toggle
        __movements:AddToggle("LoopJumppower", "Loop Jumppower", false, function(value)
            config.Movements.JumppowerHack.Loop = value
        end)
        -- WindUI Slider -> Orion Slider
        __movements:AddSlider("Speed", "Speed", "Speed",
            getLocalHum().WalkSpeed, 0, 150, 1, function(value)
                config.Movements.SpeedHack.Value = value
            end
        )
        -- WindUI Toggle (Checkbox) -> Orion Toggle
        __movements:AddToggle("Infjump", "Inf jump", false, function(value)
            config.Movements.Infjump.Value = value
        end)
        -- WindUI Toggle (Checkbox) -> Orion Toggle
        __movements:AddToggle("Fly", "Fly (unstable)", false, function(value)
            config.Movements.Fly.Value = value
        end)
        -- WindUI Toggle (Checkbox) -> Orion Toggle
        __movements:AddToggle("Noclip", "Noclip", false, function(value)
            config.Movements.Noclip.Value = value
        end)
        -- WindUI Toggle (Checkbox) -> Orion Toggle
        __movements:AddToggle("Freeze", "Freeze", false, function(value)
            if (value) then
                config.Movements.Freeze.CFrame = getLocalRoot().CFrame
            end
            config.Movements.Freeze.Value = value
        end)

        __movements:AddLabel("Teleports") -- Dividerの代わりにLabelで区切り

        -- WindUI Input -> Orion Input
        __movements:AddInput("TPTarget", "Target", getLocalPlayer().Name, function(value)
            config.Movements.Teleports.Target.Value = value
        end)
        -- WindUI Button -> Orion Button
        __movements:AddButton("Teleport", function()
            local t = getPlayerFromName(config.Movements.Teleports.Target.Value)
            if (not t or not t.Character) then return end
            local root = get(t.Character, "HumanoidRootPart")
            if (not root) then return end
            getLocalRoot().CFrame = root.CFrame
        end)
        -- WindUI Button -> Orion Button
        __movements:AddButton("Spawn", function()
            if (not getLocalRoot()) then return end
            getLocalRoot().CFrame = CFrame.new(1, -10, -2)
        end)
        -- WindUI Button -> Orion Button
        __movements:AddButton("Barn", function()
            if (not getLocalRoot()) then return end
            getLocalRoot().CFrame = config.Movements.Teleports.Barn.CFrame
        end)
        __movements:AddButton("Blue Bouse", function()
            if (not getLocalRoot()) then return end
            getLocalRoot().CFrame = config.Movements.Teleports.BlueBouse.CFrame
        end)
        __movements:AddButton("Factory", function()
            if (not getLocalRoot()) then return end
            getLocalRoot().CFrame = config.Movements.Teleports.Factory.CFrame
        end)
        __movements:AddButton("Glass House", function()
            if (not getLocalRoot()) then return end
            getLocalRoot().CFrame = config.Movements.Teleports.GlassHouse.CFrame
        end)
        __movements:AddButton("Japanese House", function()
            if (not getLocalRoot()) then return end
            getLocalRoot().CFrame = config.Movements.Teleports.JapaneseHouse.CFrame
        end)
        __movements:AddButton("Pink Roof House", function()
            if (not getLocalRoot()) then return end
            getLocalRoot().CFrame = config.Movements.Teleports.PinkRoofHouse.CFrame
        end)
        __movements:AddButton("Spooky House", function()
            if (not getLocalRoot()) then return end
            getLocalRoot().CFrame = config.Movements.Teleports.SpookyHouse.CFrame
        end)
        __movements:AddButton("Tudor House", function()
            if (not getLocalRoot()) then return end
            getLocalRoot().CFrame = config.Movements.Teleports.TudorHouse.CFrame
        end)
        __movements:AddButton("Train Cave", function()
            if (not getLocalRoot()) then return end
            getLocalRoot().CFrame = config.Movements.Teleports.TrainCave.CFrame
        end)
        __movements:AddButton("Small Secret Cave", function()
            if (not getLocalRoot()) then return end
            getLocalRoot().CFrame = config.Movements.Teleports.SmallSecretCave.CFrame
        end)
        __movements:AddButton("Big Secret Cave", function()
            if (not getLocalRoot()) then return end
            getLocalRoot().CFrame = config.Movements.Teleports.BigSecretCave.CFrame
        end)
    end

    do
        --// PLAYERS
        local antiDetectToggle = __players:AddToggle("AntiDetect", "Anti Detect", false, function(value)
            config.Players.AntiDetect.Value = value
        end)
        __players:AddToggle("AntiRagdoll", "Anti Ragdoll", false, function(value)
            config.Players.AntiRagdoll.Value = value
        end)
        __players:AddToggle("AntiTouch", "Anti Touch", false, function(value)
            config.Players.AntiTouch.Value = value
        end)
        __players:AddToggle("AntiBanana", "Anti Banana", false, function(value)
            config.Players.AntiBanana.Value = value
        end)
        local autoSlotToggle = __players:AddToggle("AutoSlot", "Auto Slot", false, function(value)
            config.Players.AutoSlot.Value = value
        end)
        __players:AddToggle("Ragdoll", "Ragdoll", false, function(value)
            config.Players.Ragdoll.Value = value
        end)
        __players:AddToggle("AntiGucci", "Anti Gucci", false, function(value)
            config.Players.AntiGucci.Value = value
        end)
    end

    do
        --// VISUALS
        __visuals:AddToggle("ESP", "ESP", false, function(value)
            config.Visuals.ESP.Value = value
        end)
        -- WindUI ColorPicker -> Orion ColorPicker
        __visuals:AddColorPicker("FillColor", "Fill Color", Color3.new(0.25, 0, 1), function(value)
            config.Visuals.ESP.FillColor = value
        end)
        __visuals:AddColorPicker("OutlineColor", "Outline Color", Color3.new(1, 1, 1), function(value)
            config.Visuals.ESP.OutlineColor = value
        end)
        __visuals:AddSlider("FOV", "FOV", "Field Of View", 70, 30, 120, 1, function(value)
            config.Visuals.FOV.Value = value
        end)
        __visuals:AddToggle("TPS", "TPS", false, function(value)
            config.Visuals.TPS.Value = value
        end)
        -- Spectate機能のUIコンポーネントがコード内に見当たらないため、トグルのみ追加
        __visuals:AddToggle("Spectate", "Spectate", false, function(value)
            config.Visuals.Spectate.Value = value
        end)
    end

    do
        --// COMBATS
        __combats:AddToggle("AntiGrab", "Anti Grab", false, function(value)
            config.Combats.AntiGrab.Value = value
        end)
        __combats:AddToggle("AntiVoid", "Anti Void", false, function(value)
            config.Combats.AntiVoid.Value = value
        end)
        __combats:AddToggle("AntiFar", "Anti Far", false, function(value)
            config.Combats.AntiFar.Value = value
        end)
        __combats:AddToggle("AntiExplode", "Anti Explode", false, function(value)
            config.Combats.AntiExplode.Value = value
        end)
        __combats:AddToggle("StrAntiGrab", "Str Anti Grab (Sit Anti Grab)", false, function(value)
            config.Combats.StrAntiGrab.Value = value
        end)
        __combats:AddToggle("Extinguisher", "Extinguisher (Anti Fire)", false, function(value)
            config.Combats.Extinguisher.Value = value
        end)
        __combats:AddToggle("InvisLine", "Invisible Grab Line", false, function(value)
            config.Combats.InvisLine.Value = value
        end)

        __combats:AddLabel("Super Strength")
        __combats:AddToggle("SuperStrength", "Super Strength (RMB Fling)", false, function(value)
            config.Combats.SuperStrength.Value = value
        end)
        __combats:AddSlider("SuperStrengthPower", "Power", "Fling Power", 250, 0, 1000, 1, function(value)
            config.Combats.SuperStrength.Power.Value = value
        end)

        __combats:AddLabel("Infinite Line")
        __combats:AddToggle("InfLine", "Infinite Grab Line", false, function(value)
            config.Combats.InfLine.Value = value
        end)
        -- WindUIではMouseWheelでInfLine.Dist.Valueを操作しているため、ここでは設定値のみ表示
        __combats:AddSlider("InfLineDist", "Distance (Scroll)", "Distance (Scroll)", 0, 0, 1000, 1, function(value)
            config.Combats.InfLine.Dist.Value = value
        end)

        __combats:AddLabel("Revenge (When Grabbed)")
        __combats:AddToggle("RevengeVoid", "Void", false, function(value)
            config.Combats.Revenge.Void.Value = value
        end)
        __combats:AddToggle("RevengeKill", "Kill", false, function(value)
            config.Combats.Revenge.Kill.Value = value
        end)
        __combats:AddToggle("RevengePoison", "Poison", false, function(value)
            config.Combats.Revenge.Poison.Value = value
        end)
        __combats:AddToggle("RevengeRagdoll", "Ragdoll", false, function(value)
            config.Combats.Revenge.Ragdoll.Value = value
        end)
        __combats:AddToggle("RevengeDeath", "Death", false, function(value)
            config.Combats.Revenge.Death.Value = value
        end)

        __combats:AddLabel("AimBot")
        __combats:AddToggle("AimBot", "Aim Bot", false, function(value)
            config.Combats.AimBot.Value = value
        end)
        __combats:AddSlider("AimBotRadius", "Radius", "Aim Radius", 30, 0, 100, 1, function(value)
            config.Combats.AimBot.Radius.Value = value
        end)
        -- WindUI Input/Dropdown -> Orion Dropdown
        __combats:AddDropdown("AimPart", "Target Part", "Torso", { "Head", "Torso", "HumanoidRootPart" }, function(value)
            config.Combats.AimBot.Part.Value = value
        end)
    end

    do
        --// AURAS
        __auras:AddToggle("VoidAura", "Void Aura", false, function(value)
            config.Auras.VoidAura.Value = value
        end)
        __auras:AddToggle("KillAura", "Kill Aura", false, function(value)
            config.Auras.KillAura.Value = value
        end)
        __auras:AddToggle("PoisonAura", "Poison Aura", false, function(value)
            config.Auras.PoisonAura.Value = value
        end)
        __auras:AddToggle("RagdollAura", "Ragdoll Aura", false, function(value)
            config.Auras.RagdollAura.Value = value
        end)
        __auras:AddToggle("DeathAura", "Death Aura", false, function(value)
            config.Auras.DeathAura.Value = value
        end)
        __auras:AddToggle("FireAura", "Fire Aura", false, function(value)
            config.Auras.FireAura.Value = value
        end)
        __auras:AddToggle("AnchorAura", "Anchor Aura", false, function(value)
            config.Auras.AnchorAura.Value = value
        end)
        __auras:AddToggle("NoclipAura", "Noclip Aura", false, function(value)
            config.Auras.NoclipAura.Value = value
        end)
    end

    do
        --// GRABS (OnChildAddedイベント内で処理されるため、トグルのみ)
        __grabs:AddToggle("VoidGrab", "Void Grab", false, function(value)
            config.Grabs.VoidGrab.Value = value
        end)
        __grabs:AddToggle("KillGrab", "Kill Grab", false, function(value)
            config.Grabs.KillGrab.Value = value
        end)
        __grabs:AddToggle("PoisonGrab", "Poison Grab", false, function(value)
            config.Grabs.PoisonGrab.Value = value
        end)
        __grabs:AddToggle("RagdollGrab", "Ragdoll Grab", false, function(value)
            config.Grabs.RagdollGrab.Value = value
        end)
        __grabs:AddToggle("DeathGrab", "Death Grab", false, function(value)
            config.Grabs.DeathGrab.Value = value
        end)
        __grabs:AddToggle("AnchorGrab", "Anchor Grab", false, function(value)
            config.Grabs.AnchorGrab.Value = value
        end)
        __grabs:AddToggle("KickGrab", "Kick Grab", false, function(value)
            config.Grabs.KickGrab.Value = value
        end)
        __grabs:AddToggle("NoclipGrab", "Noclip Grab", false, function(value)
            config.Grabs.NoclipGrab.Value = value
        end)
    end

    do
        --// MISCS
        __miscs:AddToggle("NWOAura", "Network Owner Aura", false, function(value)
            config.Miscs.NWOAura.Value = value
        end)

        __miscs:AddLabel("Control")
        __miscs:AddToggle("Control", "Control Other Player", false, function(value)
            config.Miscs.Control.Value = value
        end)

        __miscs:AddToggle("NoTyping", "No Typing", false, function(value)
            config.Miscs.NoTyping.Value = value
        end)
        __miscs:AddToggle("AntiKickDisabler", "Anti Kick Disabler", false, function(value)
            config.Miscs.AntiKickDisabler.Value = value
        end)
    end

    do
        --// BLOBMAN
        __blobmans:AddInput("BlobmanTarget", "Target Name", getLocalPlayer().Name, function(value)
            config.Blobman.Target.Value = value
        end)
        __blobmans:AddDropdown("BlobmanArmSide", "Arm Side", "Left", { "Left", "Right" }, function(value)
            config.Blobman.ArmSide.Value = value
        end)
        __blobmans:AddButton("Spawn Blobman", function()
            local blob = getBlobman()
            if (not blob) then
                spawnBlobman()
            end
        end)
        __blobmans:AddButton("Sit Blobman", function()
            local blob = getBlobman()
            if (blob and not getLocalHum().Sit) then
                blob.VehicleSeat:Sit(getLocalHum())
            end
        end)
        __blobmans:AddButton("Unsit Blobman", function()
            local blob = getBlobman()
            if (blob and getLocalHum().Sit) then
                getLocalHum().Sit = false
            end
        end)
        __blobmans:AddButton("Delete Blobman", function()
            local blob = getBlobman()
            if (blob) then
                destroyToy(blob)
            end
        end)

        __blobmans:AddLabel("Blobman Exploits")
        __blobmans:AddToggle("NoclipBlobman", "Noclip", false, function(value)
            config.Blobman.Noclip.Value = value
        end)
        __blobmans:AddButton("Bring Target", function()
            local t = getPlayerFromName(config.Blobman.Target.Value)
            if (t) then
                task.spawn(function()
                    local root = get(t.Character, "HumanoidRootPart")
                    local b = getBlobman()
                    if (not root or not b) then return end
                    local pos = getLocalRoot().CFrame
                    getLocalRoot().CFrame = root.CFrame
                    blobBring(b, root, config.Blobman.ArmSide.Value)
                    task.wait()
                    getLocalRoot().CFrame = pos
                    task.spawn(function()
                        for _ = 1, 256 do
                            task.wait()
                            if (IsInRadius(root, getLocalRoot().Position, 12)) then
                                task.wait(1)
                                getLocalHum().Sit = false
                                break
                            end
                        end
                    end)
                end)
            end
        end)
        __blobmans:AddButton("Lock (OP Blobman)", function()
            task.spawn(function()
                local t = getPlayerFromName(config.Blobman.Target.Value)
                if (t) then
                    local root = get(t.Character, "HumanoidRootPart")
                    local b = getBlobman()
                    local pos = getLocalRoot().CFrame
                    blobBring(b, root, config.Blobman.ArmSide.Value)
                    task.wait()
                    getLocalRoot().CFrame = pos
                end
            end)
        end)
        __blobmans:AddButton("Slide Target", function()
            local t = getPlayerFromName(config.Blobman.Target.Value)
            if (t) then
                task.spawn(function()
                    local root = get(t.Character, "HumanoidRootPart")
                    local b = getBlobman()
                    if (not root or not b) then return end
                    local pos = getLocalRoot().CFrame
                    if (not getLocalHum().Sit) then b.VehicleSeat:Sit(getLocalHum()) task.wait(0.1) end -- 座る処理を追加
                    blobGrab(b, getLocalRoot(), config.Blobman.ArmSide.Value)
                    task.wait()
                    blobBring(b, root, config.Blobman.ArmSide.Value)
                    task.wait()
                    getLocalRoot().CFrame = pos
                    task.wait(.5)
                    destroyToy(b)
                end)
            end
        end)
        __blobmans:AddButton("Void Target", function()
            local t = getPlayerFromName(config.Blobman.Target.Value)
            if (t) then
                task.spawn(function()
                    local root = get(t.Character, "HumanoidRootPart")
                    local b = getBlobman()
                    if (not root or not b) then return end
                    local pos = getLocalRoot().CFrame
                    if (not getLocalHum().Sit) then b.VehicleSeat:Sit(getLocalHum()) task.wait(0.1) end -- 座る処理を追加
                    blobGrab(b, getLocalRoot(), config.Blobman.ArmSide.Value)
                    task.wait()
                    blobBring(b, root, config.Blobman.ArmSide.Value)
                    task.wait()
                    getLocalRoot().CFrame = CFrame.new(1e32, -16, 1e32)
                    task.wait(1)
                    getLocalHum().Sit = false
                    task.wait(.1)
                    getLocalRoot().CFrame = pos
                    task.wait()
                    destroyToy(b)
                end)
            end
        end)
        __blobmans:AddButton("Kick Target", function()
            local t = getPlayerFromName(config.Blobman.Target.Value)
            if (t) then
                task.spawn(function()
                    local root = get(t.Character, "HumanoidRootPart")
                    local b = getBlobman()
                    if (not root or not b) then return end
                    local pos = getLocalRoot().CFrame
                    if (not getLocalHum().Sit) then b.VehicleSeat:Sit(getLocalHum()) task.wait(0.1) end -- 座る処理を追加
                    task.wait(.5)
                    getLocalRoot().CFrame = root.CFrame
                    task.wait()
                    blobKick(b, root, config.Blobman.ArmSide.Value)
                    task.wait(.5)
                    getLocalRoot().CFrame = pos
                end)
            end
        end)
        __blobmans:AddButton("Slide All", function()
            local blob = getBlobman()
            if (not blob) then
                blob = spawnBlobman()
            end
            if (not getLocalHum().Sit) then
                blob.VehicleSeat:Sit(getLocalHum())
            end
            task.wait()
            local pos = getLocalRoot().CFrame
            if (blob and getLocalHum().Sit) then
                blobGrab(blob, getLocalRoot(), config.Blobman.ArmSide.Value)
                for _, v in ipairs(service.Players:GetPlayers()) do
                    if (v == getLocalPlayer()) then continue end
                    if (not config.Settings.IgnoreIsInPlot.Value and IsInPlot(v)) then continue end
                    if (config.Settings.IgnoreFriend.Value and IsFriend(v)) then continue end
                    local character = v.Character
                    if (not character) then continue end
                    local root = get(character, "HumanoidRootPart")
                    if (not root) then continue end
                    getLocalRoot().CFrame = root.CFrame
                    task.wait(.2)
                    blobGrab(blob, root, config.Blobman.ArmSide.Value)
                end
                task.wait(.1)
                getLocalRoot().CFrame = pos
                destroyToy(blob)
            end
        end)
        __blobmans:AddButton("Kick All", function()
            local blob = getBlobman()
            if (not blob) then
                blob = spawnBlobman()
            end
            if (not getLocalHum().Sit) then
                blob.VehicleSeat:Sit(getLocalHum())
            end
            task.wait()
            local pos = getLocalRoot().CFrame
            if (blob and getLocalHum().Sit) then
                blobGrab(blob, getLocalRoot(), config.Blobman.ArmSide.Value)
                for _, v in ipairs(service.Players:GetPlayers()) do
                    if (v == getLocalPlayer()) then continue end
                    if (not config.Settings.IgnoreIsInPlot.Value and IsInPlot(v)) then continue end
                    if (config.Settings.IgnoreFriend.Value and IsFriend(v)) then continue end
                    local character = v.Character
                    if (not character) then continue end
                    local root = get(character, "HumanoidRootPart")
                    if (not root) then continue end
                    getLocalRoot().CFrame = root.CFrame
                    task.wait(.25)
                    blobKick(blob, root, config.Blobman.ArmSide.Value)
                end
                task.wait(.1)
                getLocalRoot().CFrame = pos
                destroyToy(blob)
            end
        end)

        __blobmans:AddLabel("Blobman Aura/Loops")

        __blobmans:AddToggle("BlobGrabAura", "Grab Aura", false, function(value)
            config.Blobman.GrabAura.Value = value
        end)
        __blobmans:AddToggle("BlobKickAura", "Kick Aura", false, function(value)
            config.Blobman.KickAura.Value = value
        end)
        __blobmans:AddToggle("BlobLoopKick", "Loop Kick Target", false, function(value)
            config.Blobman.LoopKick.Value = value
        end)
        __blobmans:AddToggle("LoopKickAll", "Loop Kick All", false, function(value)
            config.Blobman.LoopKickAll.Value = value
        end)
    end

    do
        --// SNIPES
        __snipes:AddInput("SnipeTarget", "Target Name", getLocalPlayer().Name, function(value)
            config.Snipes.Target.Value = value
        end)

        __snipes:AddButton("Bring", function()
            local pos = getLocalRoot().CFrame
            local t = getPlayerFromName(config.Snipes.Target.Value)
            if (not t) then return end
            local root = get(t.Character, "HumanoidRootPart")
            if (not root) then return end
            task.spawn(function()
                Snipefunc(root, function()
                    task.wait(.01)
                    root.CFrame = pos
                    task.wait(.5)
                    ungrab(root)
                    getLocalRoot().CFrame = pos
                end)
            end)
        end)
        __snipes:AddButton("Void", function()
            task.spawn(function()
                local pos = getLocalRoot().CFrame
                local t = getPlayerFromName(config.Snipes.Target.Value)
                if (not t) then return end
                local root = get(t.Character, "HumanoidRootPart")
                if (not root) then return end
                Snipefunc(root, function()
                    Velocity(root, Vector3.new(0, 1e4, 0))
                    getLocalRoot().CFrame = pos
                end)
            end)
        end)
        __snipes:AddButton("Kill", function()
            task.spawn(function()
                local pos = getLocalRoot().CFrame
                local t = getPlayerFromName(config.Snipes.Target.Value)
                if (not t) then return end
                local root = get(t.Character, "HumanoidRootPart")
                if (not root) then return end
                Snipefunc(root, function()
                    MoveTo(root, CFrame.new(4096, -75, 4096))
                    Velocity(root, Vector3.new(0, -1e3, 0))
                    getLocalRoot().CFrame = pos
                end)
            end)
        end)
        __snipes:AddButton("Poison", function()
            task.spawn(function()
                local pos = getLocalRoot().CFrame
                local t = getPlayerFromName(config.Snipes.Target.Value)
                if (not t) then return end
                local root = get(t.Character, "HumanoidRootPart")
                if (not root) then return end
                Snipefunc(root, function()
                    MoveTo(root, CFrame.new(58, -70, 271))
                    getLocalRoot().CFrame = pos
                end)
            end)
        end)
        __snipes:AddButton("Ragdoll", function()
            task.spawn(function()
                local pos = getLocalRoot().CFrame
                local t = getPlayerFromName(config.Snipes.Target.Value)
                if (not t) then return end
                local root = get(t.Character, "HumanoidRootPart")
                if (not root) then return end
                Snipefunc(root, function()
                    local rpos = root.CFrame
                    Velocity(root, Vector3.new(0, -64, 0))
                    task.wait(.1)
                    getLocalRoot().CFrame = rpos
                    Velocity(root, Vector3.zero)
                    getLocalRoot().CFrame = pos
                end)
            end)
        end)
        __snipes:AddButton("Death", function()
            task.spawn(function()
                local pos = getLocalRoot().CFrame
                local t = getPlayerFromName(config.Snipes.Target.Value)
                if (not t) then return end
                local root = get(t.Character, "HumanoidRootPart")
                if (not root) then return end
                Snipefunc(root, function()
                    cget(root.Parent, "Humanoid"):ChangeState(Enum.HumanoidStateType.Dead)
                    task.wait(.5)
                    ungrab(root)
                    getLocalRoot().CFrame = pos
                end)
            end)
        end)
        __snipes:AddButton("Fling", function()
            local pos = getLocalRoot().CFrame
            local t = getPlayerFromName(config.Snipes.Target.Value)
            if (not t) then return end
            local root = get(t.Character, "HumanoidRootPart")
            if (not root) then return end
            local toy = spawntoy("YouDecoy", getLocalRoot().CFrame)
            task.wait(.3)
            getLocalRoot().CFrame = toy.PrimaryPart.CFrame
            task.wait(.1)
            SetNetworkOwner(toy.PrimaryPart)
            for _ = 1, 256 do
                SetNetworkOwner(toy.PrimaryPart)
                task.wait()
                local rx = math.rad(math.random(0, 360 * 32768))
                local ry = math.rad(math.random(0, 360 * 32768))
                local rz = math.rad(math.random(0, 360 * 32768))
                local rr = 1.5
                toy.PrimaryPart.CFrame = CFrame.new(root.Position + Vector3.one * math.random(-rr, rr)) * CFrame.Angles(rx, ry, rz)
                Velocity(toy.PrimaryPart, Vector3.one * 1e16)
            end
            task.wait(.5)
            getLocalRoot().CFrame = pos
            task.wait(.5)
            destroyToy(toy)
        end)

        __snipes:AddLabel("Snipe Loops")

        __snipes:AddToggle("LoopVoid", "Loop Void", false, function(value)
            config.Snipes.LoopVoid.Value = value
        end)
        __snipes:AddToggle("LoopKill", "Loop Kill", false, function(value)
            config.Snipes.LoopKill.Value = value
        end)
        __snipes:AddToggle("LoopPoison", "Loop Poison", false, function(value)
            config.Snipes.LoopPoison.Value = value
        end)
        __snipes:AddToggle("LoopRagdoll", "Loop Ragdoll", false, function(value)
            config.Snipes.LoopRagdoll.Value = value
        end)
        __snipes:AddToggle("LoopDeath", "Loop Death", false, function(value)
            config.Snipes.LoopDeath.Value = value
        end)
    end

    do
        --// TROLLS
        __trolls:AddButton("Burn All", function()
            local Oven = spawntoy("OvenDarkGray", getLocalRoot().CFrame)
            local Button = Oven.ButtonOven
            SetNetworkOwner(Button)
            ungrab(Button)
            task.wait(.1)
            SetNetworkOwner(Oven.SoundPart)
            for _, v in ipairs(service.Players:GetPlayers()) do
                if (v == getLocalPlayer()) then continue end
                if (not config.Settings.IgnoreIsInPlot.Value and IsInPlot(v)) then continue end
                if (config.Settings.IgnoreFriend.Value and IsFriend(v)) then continue end
                local character = v.Character
                if (not character) then continue end
                local root = get(character, "HumanoidRootPart")
                if (not root) then continue end
                task.wait(.25)
                Oven.SoundPart.CFrame = root.CFrame
            end
            task.wait(1)
            destroyToy(Oven)
        end)
        __trolls:AddButton("Fire All", function()
            local toy = spawntoy("Campfire", getLocalRoot().CFrame)
            SetNetworkOwner(toy.SoundPart)
            for _, v in ipairs(service.Players:GetPlayers()) do
                if (v == getLocalPlayer()) then continue end
                if (not config.Settings.IgnoreIsInPlot.Value and IsInPlot(v)) then continue end
                if (config.Settings.IgnoreFriend.Value and IsFriend(v)) then continue end
                local character = v.Character
                if (not character) then continue end
                local root = get(character, "HumanoidRootPart")
                if (not root) then continue end
                task.wait(.25)
                toy.SoundPart.CFrame = root.CFrame
            end
            task.wait(1)
            destroyToy(toy)
        end)
        __trolls:AddToggle("LoudAll", "Loud All", false, function(value)
            config.Trolls.LoudAll.Value = value
            if (value) then
                local SoundMain = spawntoy("BellBig", getLocalRoot().CFrame)
                task.wait(.5)
                config.Trolls.LoudAll.SoundPart.Value = SoundMain
                SetNetworkOwner(SoundMain.SoundPart)
            else
                if (config.Trolls.LoudAll.SoundPart.Value) then
                    destroyToy(config.Trolls.LoudAll.SoundPart.Value)
                    config.Trolls.LoudAll.SoundPart.Value = nil
                end
            end
        end)
        __trolls:AddToggle("Lag", "Lag", false, function(value)
            config.Trolls.Lag.Value = value
        end)
        __trolls:AddToggle("Ping", "Ping", false, function(value)
            config.Trolls.Ping.Value = value
        end)
        __trolls:AddToggle("ServerDestroyer", "Server Destroyer", false, function(value)
            config.Trolls.ServerDestroyer.Value = value
            if (value) then
                config.Trolls.ServerDestroyer.CFrame = getLocalRoot().CFrame
            end
        end)
        __trolls:AddToggle("ChaosLine", "Chaos Line", false, function(value)
            config.Trolls.ChaosLine.Value = value
        end)
        __trolls:AddButton("THE WORLD", function()
            local s = playSound("rbxassetid://7514417921")
            task.wait(1)
            local e = Instance.new("Part", workspace)
            e.Size = Vector3.one
            e.Shape = Enum.PartType.Ball
            e.Material = Enum.Material.ForceField
            e.Color = Color3.new(.5, .7, 0.2)
            e.CanCollide = false
            e.CanQuery = false
            e.CanTouch = false
            e.Locked = true
            task.spawn(function()
                while (true) do
                    e.Size = e.Size + Vector3.one / 2
                    e.CFrame = getLocalRoot().CFrame
                    e.Transparency = e.Transparency + .1
                    lag(4096)
                    task.wait()
                end
            end)
        end)
    end

    do
        --// SETTINGS
        -- OrionはConfigManagerを直接操作するUIを持たないため、Load/Save/DeleteボタンはOrionLibの機能に置き換え
        __settings:AddButton("Save Config", function()
            OrionLib:SaveConfiguration()
            windNotify({ Title = "Suisei Hub", Content = "Config saved!", Duration = 5 })
        end)
        __settings:AddButton("Load Config", function()
            OrionLib:LoadConfiguration()
            windNotify({ Title = "Suisei Hub", Content = "Config loaded!", Duration = 5 })
        end)
        __settings:AddButton("Delete Config", function()
            OrionLib:RemoveConfiguration()
            windNotify({ Title = "Suisei Hub", Content = "Config deleted!", Duration = 5 })
        end)

        local AuraRadius = __settings:AddSlider("AuraRadius", "Aura Radius", "Aura Radius", 32, 0, 128, 1, function(value)
            config.Settings.AuraRadius.Value = value
        end)
        __settings:AddButton("Infinite Aura Radius (NetworkOwner)", function()
            config.Settings.AuraRadius.Value = 10000
            AuraRadius:SetValue(10000) -- Orion SliderのSetValueを使用
        end)
        __settings:AddSlider("AimBotSpeed", "AimBot Speed", "AimBot Speed", 5, 1, 10, 1, function(value)
            config.Settings.AimBotSpeed.Value = value
        end)

        __settings:AddToggle("IgnoreFriend", "Ignore Friend", false, function(value)
            config.Settings.IgnoreFriend.Value = value
        end)
        __settings:AddToggle("IgnoreIsInPlot", "Ignore IsInPlot", false, function(value)
            config.Settings.IgnoreIsInPlot.Value = value
        end)
        __settings:AddToggle("OnlyPlayer", "Only Player", false, function(value)
            config.Settings.OnlyPlayer.Value = value
        end)

        __settings:AddSlider("LagAmount", "Lag Amount", "Lag Amount", 1024, 0, 4096, 1, function(value)
            config.Settings.Lag.Value = value
        end)
        __settings:AddSlider("PingAmount", "Ping Amount", "Ping Amount", 1024, 0, 4096, 1, function(value)
            config.Settings.Ping.Value = value
        end)

        -- WindUI Keybind -> Orion Keybind
        local keybindComponent = __settings:AddKeybind("ToggleKeybind", "Toggle Keybind", "C", function(key)
            local success, key_enum = pcall(function() return Enum.KeyCode[key] end)
            if success and key_enum then
                Window:SetKey(key_enum)
                ToggleKeybind = key_enum
            end
        end)

        -- WindUI Dropdown -> Orion Dropdown
        __settings:AddDropdown("KickMethod", "Kick Method", "Void", { "Void", "Float" }, function(value)
            config.Settings.KickMethod.Value = value
        end)
        __settings:AddDropdown("SpeedHackMethod", "SpeedHack Method", "CFrame", { "CFrame", "Velocity", "Disable" }, function(value)
            config.Settings.SpeedHackMethod.Value = value
        end)
        __settings:AddToggle("AutoSpeedHackMethod", "Auto SpeedHack Method", true, function(value)
            config.Settings.AutoSpeedHackMethod.Value = value
        end)
        __settings:AddDropdown("FlyMethod", "Fly Method", "Velocity", { "CFrame", "Velocity", "Disable" }, function(value)
            config.Settings.FlyMethod.Value = value
        end)
        __settings:AddToggle("DebugMode", "Debug Mode", false, function(value)
            config.Settings.DebugMode.Value = value
        end)

        __settings:AddButton("Rejoin", function()
            local s, r = pcall(function()
                windNotify({
                    Title = "Suisei Hub",
                    Content = "Rejoining...",
                    Duration = 5
                })
                service.TeleportService:Teleport(
                    game.PlaceId,
                    getLocalPlayer(),
                    game.JobId
                )
            end)
            if (not s) then
                windNotify({
                    Title = "Suisei Hub",
                    Content = "Failed to rejoin!\n" .. r,
                    Duration = 5
                })
            end
        end)
    end

    do
        --// INFOS
        __infos:AddLabel("Discord Link")
        __infos:AddTextbox("DiscordLink", "Discord Link", "https://discord.gg/ENnZ4W9eMN", true, function(value) end) -- 読み取り専用のテキストボックス

        __infos:AddLabel("Notes: Made by Luna!")
    end

    --// SYSTEM
    -- WindUIの通知機能（wind:Notify）をOrionの通知機能（windNotify）に置き換える作業は完了済み

    task.wait(.1)

    --// INPUTS
    service.UserInputService.JumpRequest:Connect(function()
        if (config.Movements.Infjump.Value and getLocalHum()) then
            getLocalHum():ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end)

    local keys = { W = false, A = false, S = false, D = false, Space = false, Shift = false }
    service.UserInputService.InputBegan:Connect(function(i, g)
        if (g) then return end
        local k = i.KeyCode
        if (k == Enum.KeyCode.W) then keys.W = true end
        if (k == Enum.KeyCode.A) then keys.A = true end
        if (k == Enum.KeyCode.S) then keys.S = true end
        if (k == Enum.KeyCode.D) then keys.D = true end
        if (k == Enum.KeyCode.Space) then keys.Space = true end
        if (k == Enum.KeyCode.LeftShift or k == Enum.KeyCode.RightShift) then keys.Shift = true end
    end)
    service.UserInputService.InputEnded:Connect(function(i, g)
        if (g) then return end
        local k = i.KeyCode
        if (k == Enum.KeyCode.W) then keys.W = false end
        if (k == Enum.KeyCode.A) then keys.A = false end
        if (k == Enum.KeyCode.S) then keys.S = false end
        if (k == Enum.KeyCode.D) then keys.D = false end
        if (k == Enum.KeyCode.Space) then keys.Space = false end
        if (k == Enum.KeyCode.LeftShift or k == Enum.KeyCode.RightShift) then keys.Shift = false end
    end)

    service.UserInputService.InputChanged:Connect(function(i)
        if (i.UserInputType == Enum.UserInputType.MouseWheel) then
            if (config.Combats.InfLine.Dist.Value < 11) then
                config.Combats.InfLine.Dist.Value = 11
            end
            if (i.Position.Z > 0) then
                config.Combats.InfLine.Dist.Value = config.Combats.InfLine.Dist.Value + 7
            elseif (i.Position.Z < 0) then
                config.Combats.InfLine.Dist.Value = config.Combats.InfLine.Dist.Value - 7
            end
        end
    end)

    --// SLOTS
    service.ReplicatedStorage.SlotEvents.SlotTime.OnClientEvent:Connect(function(i)
        task.spawn(function()
            config.Players.AutoSlot.Time = i
            if (config.Players.AutoSlot.Time == 0 and config.Players.AutoSlot.Value) then
                local p = getLocalRoot().CFrame
                while (config.Players.AutoSlot.Time == 0 and config.Players.AutoSlot.Value) do
                    for _, v in ipairs(workspace.Slots:GetChildren()) do
                        task.wait(.1)
                        local h = v.SlotHandle.Handle
                        getLocalRoot().CFrame = h.CFrame
                        task.wait(.2)
                        SetNetworkOwner(h)
                    end
                end
                task.wait(1.5)
                getLocalRoot().CFrame = p
            end
        end)
    end)

    --// GRABPARTS AND BLACKHOLE
    workspace.ChildAdded:Connect(function(v)
        --// ANTIEXPLODE
        if (config.Combats.AntiExplode.Value) then
            if (v.Name == "Part" and getLocalChar()) then
                local pos = (v.Position - getLocalRoot().Position).Magnitude
                if (pos >= 4) then
                    getLocalRoot().Anchored = true
                    task.wait(.05)
                    while (get(getLocalChar(), "Ragdolled") and get(getLocalChar(), "Ragdolled").Value) do
                        service.ReplicatedStorage.CharacterEvents.Struggle:FireServer(getLocalPlayer())
                        service.ReplicatedStorage.GameCorrectionEvents.StopAllVelocity:FireServer()
                        task.wait()
                    end
                    getLocalRoot().Anchored = false
                end
            end
        end

        --// GRABPARTS
        if (v.Name == "GrabParts" and v:IsA("Model")) then
            local Owner = get(v, "Owner")
            local BeamPart = get(v, "BeamPart")
            local DragPart = get(v, "DragPart")
            local GrabPart = get(v, "GrabPart")
            local GrabAttach = get(GrabPart, "GrabAttach")
            local Grabbing = get(GrabPart, "WeldConstraint").Part1

            if (config.Settings.DebugMode.Value) then
                windNotify({
                    Title = "Suisei Hub",
                    Content = "Found GrabParts",
                    Duration = 5
                })
            end

            if (Grabbing.Anchored) then
                if (config.Settings.DebugMode.Value) then
                    windNotify({
                        Title = "Suisei Hub",
                        Content = "Target is Anchored",
                        Duration = 5
                    })
                end
                return
            end

            local function Grabfunc(func, ...)
                task.spawn(function(...)
                    if (config.Settings.DebugMode.Value) then
                        windNotify({
                            Title = "Suisei Hub",
                            Content = "Running Grabfunc",
                            Duration = 5
                        })
                    end
                    func(...)
                end, ...)
            end

            --// MAINS

            Grabfunc(function()
                if (config.Combats.InfLine.Value) then
                    local DragPartC = DragPart:Clone()
                    DragPartC.AlignPosition.Attachment1 = DragPartC.DragAttach
                    DragPartC.Parent = v
                    config.Combats.InfLine.Dist.Value = (DragPartC.Position - workspace.CurrentCamera.CFrame.Position).Magnitude
                    DragPartC.AlignOrientation.Enabled = false
                    DragPart.AlignPosition.Enabled = false
                    task.spawn(function()
                        while (v.Parent) do
                            DragPartC.Position = workspace.CurrentCamera.CFrame.Position + workspace.CurrentCamera.CFrame.LookVector * config.Combats.InfLine.Dist.Value
                            task.wait()
                        end
                        config.Combats.InfLine.Dist.Value = 0
                    end)
                end
            end)

            Grabfunc(function()
                v:GetPropertyChangedSignal("Parent"):Connect(function()
                    if (not v.Parent and config.Combats.SuperStrength.Value) then
                        service.UserInputService.InputBegan:Once(function(i)
                            if (i.UserInputType == Enum.UserInputType.MouseButton2) then
                                local vel = Instance.new("BodyVelocity", Grabbing)
                                vel.MaxForce = Vector3.one * math.huge
                                vel.Velocity = workspace.CurrentCamera.CFrame.LookVector * config.Combats.SuperStrength.Power.Value
                                service.Debris:AddItem(vel, .1)
                            end
                        end)
                    end
                end)
            end)
            if (config.Grabs.VoidGrab.Value) then
                Grabfunc(function()
                    for _ = 1, 3 do
                        task.wait()
                        SetNetworkOwner(Grabbing)
                    end
                    task.wait()
                    Velocity(Grabbing, Vector3.new(0, 1e4, 0))
                end)
            end
            if (config.Grabs.KillGrab.Value) then
                Grabfunc(function()
                    for _ = 1, 3 do
                        task.wait()
                        SetNetworkOwner(Grabbing)
                    end
                    task.wait()
                    MoveTo(Grabbing, CFrame.new(4096, -75, 4096))
                    Velocity(Grabbing, Vector3.new(0, -1e3, 0))
                end)
            end
            if (config.Grabs.PoisonGrab.Value) then
                Grabfunc(function()
                    for _ = 1, 3 do
                        task.wait()
                        SetNetworkOwner(Grabbing)
                    end
                    task.wait()
                    local pos = Grabbing.CFrame
                    MoveTo(Grabbing, CFrame.new(58, -70, 271))
                end)
            end
            if (config.Grabs.RagdollGrab.Value) then
                Grabfunc(function()
                    local pos = Grabbing.CFrame
                    for _ = 1, 3 do
                        task.wait()
                        SetNetworkOwner(Grabbing)
                    end
                    task.wait()
                    Velocity(Grabbing, Vector3.new(0, -256, 0))
                    task.wait()
                    MoveTo(Grabbing, pos)
                    Velocity(Grabbing, Vector3.zero)
                end)
            end
            if (config.Grabs.AnchorGrab.Value) then
                Grabfunc(function()
                    anchor(Grabbing)
                end)
            end
            if (config.Grabs.DeathGrab.Value) then
                Grabfunc(function()
                    for _ = 1, 3 do
                        task.wait()
                        SetNetworkOwner(Grabbing)
                    end
                    task.wait(.1)
                    cget(Grabbing.Parent, "Humanoid"):ChangeState(Enum.HumanoidStateType.Dead)
                    task.wait(.5)
                    ungrab(Grabbing)
                end)
            end
            if (config.Grabs.NoclipGrab.Value) then
                Grabfunc(function()
                    while (Grabbing.Parent and v) do
                        for _, v in ipairs(Grabbing.Parent:GetDescendants()) do
                            if (v:IsA("BasePart")) then
                                v.CanCollide = false
                            end
                        end
                        task.wait()
                    end
                end)
            end
            if (config.Grabs.KickGrab.Value) then
                Grabfunc(function()
                    local p = service.Players:GetPlayerFromCharacter(Grabbing.Parent)
                    if (p) then
                        local character = p.Character
                        if (not character) then return end
                        local root = get(character, "HumanoidRootPart")
                        if (not root) then return end
                        local hum = cget(character, "Humanoid")
                        if (config.Settings.KickMethod.Value == "Void") then
                            task.wait(.5)
                            ungrab(Grabbing)
                            task.spawn(function()
                                while (p and root and root.Parent) do
                                    if (hum and hum.FloorMaterial ~= Enum.Material.Air) then
                                        local pos = getLocalRoot().CFrame
                                        task.wait()
                                        getLocalRoot().CFrame = root.CFrame
                                        task.wait(.1)
                                        SetNetworkOwner(root)
                                        task.wait(.1)
                                        MoveTo(Grabbing, CFrame.new(25e25, 25e25, 25e25))
                                        Velocity(root, root.AssemblyLinearVelocity * 25e25)
                                        task.wait()
                                        ungrab(root)
                                        getLocalRoot().CFrame = pos
                                    end
                                    task.wait()
                                end
                            end)
                        elseif (config.Settings.KickMethod.Value == "Float") then
                            for _ = 1, 32 do
                                SetNetworkOwner(root)
                                hum:ChangeState(Enum.HumanoidStateType.Ragdoll)
                                hum.Health = 0
                                ungrab(root)
                            end
                        end
                    end
                end)
            end
            if (config.Miscs.Control.Value) then
                local p = service.Players:GetPlayerFromCharacter(Grabbing.Parent)
                if (not p and cget(Grabbing.Parent, "Humanoid")) then
                    SetNetworkOwner(Grabbing.Parent.PrimaryPart)
                    config.Miscs.Control.Target.Value = Grabbing.Parent
                end
            end
        end
    end)

    --// LOOPS
    local AntiDetectTimer = 0
    local AntiBananaTimer = 0
    local AuraTimer = 0
    local ServerDestroyerTimer = 0
    local espTimer = 0
    local ExtinguisherTimer = 0
    local SnipeLoopTimer = 0
    local LoudAllTimer = 0
    local LoopKickTimer = 0
    local AntiKickDisablerTimer = 0
    loop.Event:Connect(function(dt)
        --//DELTATIME/TIMER
        local altdt = 1 / 60
        AntiDetectTimer = AntiDetectTimer + dt
        AntiBananaTimer = AntiBananaTimer + dt
        AuraTimer = AuraTimer + dt
        ServerDestroyerTimer = ServerDestroyerTimer + dt
        espTimer = espTimer + dt
        ExtinguisherTimer = ExtinguisherTimer + dt
        SnipeLoopTimer = SnipeLoopTimer + dt
        LoudAllTimer = LoudAllTimer + dt
        LoopKickTimer = LoopKickTimer + dt
        AntiKickDisablerTimer = AntiKickDisablerTimer + dt

        --//MOVEMENTS
        if (config.Settings.AutoSpeedHackMethod.Value) then
            if (getLocalHum() and getLocalHum().Sit) then
                config.Settings.SpeedHackMethod.Value = "Velocity"
            else
                config.Settings.SpeedHackMethod.Value = "CFrame"
            end
        end
        if (config.Movements.CrouchSpeedHack.Loop) then
            getLocalHum().WalkSpeed = config.Movements.CrouchSpeedHack.Value
        end
        if (config.Movements.JumppowerHack.Loop) then
            getLocalHum().JumpPower = config.Movements.JumppowerHack.Value
        end
        if (config.Movements.Freeze.Value) then
            if (getLocalRoot()) then
                getLocalRoot().CFrame = config.Movements.Freeze.CFrame
            end
        end
        if (config.Movements.Noclip.Value) then
            if (getLocalChar()) then
                for _, v in ipairs(getLocalChar():GetDescendants()) do
                    if (v:IsA("BasePart")) then
                        v.CanCollide = false
                    end
                end
            end
        end
        if (config.Movements.Fly.Value) then
            if (getLocalRoot() and getLocalHum()) then
                getLocalHum().PlatformStand = true -- Fly中はPlatformStand
                if (config.Settings.FlyMethod.Value == "Velocity") then
                    local dir = Vector3.zero
                    local look = workspace.CurrentCamera.CFrame.LookVector
                    local right = workspace.CurrentCamera.CFrame.RightVector
                    if (keys.W) then dir = dir + look end; if (keys.S) then dir = dir - look end
                    if (keys.A) then dir = dir - right end; if (keys.D) then dir = dir + right end
                    if (keys.Space) then dir = dir + Vector3.new(0, 1, 0) end; if (keys.Shift) then dir = dir - Vector3.new(0, 1, 0) end
                    if (dir.Magnitude > 0) then
                        dir = dir.Unit * config.Movements.SpeedHack.Value
                        getLocalRoot().AssemblyLinearVelocity = dir
                    else
                        getLocalRoot().AssemblyLinearVelocity = Vector3.zero
                        getLocalRoot().CFrame = CFrame.new(getLocalRoot().Position, getLocalRoot().Position + workspace.CurrentCamera.CFrame.LookVector)
                    end
                elseif (config.Settings.FlyMethod.Value == "CFrame") then
                    local dir = Vector3.zero
                    local look = workspace.CurrentCamera.CFrame.LookVector
                    local right = workspace.CurrentCamera.CFrame.RightVector
                    if (keys.W) then dir = dir + look end; if (keys.S) then dir = dir - look end
                    if (keys.A) then dir = dir - right end; if (keys.D) then dir = dir + right end
                    if (keys.Space) then dir = dir + Vector3.new(0, 1, 0) end; if (keys.Shift) then dir = dir - Vector3.new(0, 1, 0) end
                    if (dir.Magnitude > 0) then
                        dir = dir.Unit * config.Movements.SpeedHack.Value * altdt
                        local targetPos = getLocalRoot().Position + dir
                        getLocalRoot().CFrame = getLocalRoot().CFrame:Lerp(CFrame.new(targetPos, targetPos + workspace.CurrentCamera.CFrame.LookVector), .5)
                    else
                        getLocalRoot().AssemblyLinearVelocity = Vector3.zero
                        getLocalRoot().CFrame = CFrame.new(getLocalRoot().Position, getLocalRoot().Position + workspace.CurrentCamera.CFrame.LookVector)
                    end
                end
            else
                -- Flyがオフになった際の処理を追加 (もしあれば)
            end
        else
            if (getLocalHum()) then
                getLocalHum().PlatformStand = false
            end
        end

        --//PLAYERS
        if (AntiDetectTimer >= .5) then
            if (config.Players.AntiDetect.Value) then
                AntiDetect()
            end
            AntiDetectTimer = 0
        end
        if (config.Players.AntiRagdoll.Value) then
            if (getLocalHum() and ((getLocalHum():GetState() == Enum.HumanoidStateType.Ragdoll) or (getLocalHum():GetState() == Enum.HumanoidStateType.FallingDown))) then
                ragdoll()
                getLocalHum():ChangeState(Enum.HumanoidStateType.Running) -- 変更状態をRunningに変更
            end
        end
        if (config.Players.AntiTouch.Value) then
            if (getLocalChar()) then
                for _, v in ipairs(getLocalChar():GetDescendants()) do
                    if (v:IsA("BasePart")) then
                        v.Locked = true
                        v.CanTouch = false
                        v.CanQuery = false
                    end
                end
            end
        end
        if (AntiBananaTimer >= 1) then
            for _, v in ipairs(workspace:GetChildren()) do
                if (v:IsA("Folder") and v.Name:find("SpawnedInToys") and not v:IsDescendantOf(getInv())) then
                    local banana = get(v, "FoodBanana")
                    if (banana) then
                        for _, v in ipairs(banana:GetDescendants()) do
                            if (v:IsA("BasePart")) then
                                v.CanQuery = not config.Players.AntiBanana.Value
                                v.CanTouch = not config.Players.AntiBanana.Value
                                if (config.Players.AntiBanana.Value) then
                                    if (getLocalRoot() and IsInRadius(v, getLocalRoot().Position, 8)) then
                                        SetNetworkOwner(v)
                                    end
                                end
                            end
                        end
                    end
                end
            end
            AntiBananaTimer = 0
        end
        if (config.Players.Ragdoll.Value) then
            ragdoll()
            if (getLocalHum()) then
                getLocalHum().PlatformStand = true
            end
        end
        if (config.Players.AntiGucci.Value) then
            ragdoll()
        end

        --//VISUALS
        if (espTimer >= 1) then
            updateESP()
            if (config.Visuals.ESP.Value) then
                for _, p in ipairs(service.Players:GetPlayers()) do
                    local c = p.Character
                    if (c) then
                        addESP(c)
                    end
                end
            end
            espTimer = 0
        end
        if (workspace.CurrentCamera) then
            workspace.CurrentCamera.FieldOfView = config.Visuals.FOV.Value
        end
        if (config.Visuals.TPS.Value) then
            getLocalPlayer().CameraMaxZoomDistance = 100000
            getLocalPlayer().CameraMode = Enum.CameraMode.Classic
            if ((workspace.CurrentCamera.CFrame.Position - workspace.CurrentCamera.Focus.Position).Magnitude > getLocalPlayer().CameraMinZoomDistance) then
                service.UserInputService.MouseIconEnabled = true
            else
                service.UserInputService.MouseIconEnabled = false
            end
        else
            getLocalPlayer().CameraMode = Enum.CameraMode.LockFirstPerson
        end

        --//COMBATS
        do
            --// ANTIGRAB-REVENGE
            if (getLocalChar()) then
                local head = get(getLocalChar(), "Head")
                if (head) then
                    local owner = get(head, "PartOwner")
                    local target
                    if (owner and owner.Value) then
                        target = get(service.Players, owner.Value)
                    end
                    task.spawn(function()
                        while (owner and config.Combats.AntiGrab.Value) or (getLocalPlayer().IsHeld and getLocalPlayer().IsHeld.Value and config.Combats.AntiGrab.Value) do
                            if (getLocalRoot()) then
                                getLocalRoot().Anchored = true
                            end
                            service.ReplicatedStorage.CharacterEvents.Struggle:FireServer(getLocalPlayer())
                            service.ReplicatedStorage.GameCorrectionEvents.StopAllVelocity:FireServer()
                            task.wait()
                        end
                        if (getLocalRoot()) then
                            getLocalRoot().Anchored = false
                        end
                    end)

                    do
                        if (target) then
                            local character = target.Character
                            if (character) then
                                local root = get(character, "HumanoidRootPart")
                                if (root) then
                                    if (config.Combats.Revenge.Void.Value) then
                                        for _ = 1, 3 do
                                            SetNetworkOwner(root)
                                            task.wait(.1)
                                            Velocity(root, Vector3.new(0, 1e4, 0))
                                            task.wait()
                                        end
                                    end
                                    if (config.Combats.Revenge.Kill.Value) then
                                        for _ = 1, 3 do
                                            SetNetworkOwner(root)
                                            task.wait(.1)
                                            MoveTo(root, CFrame.new(4096, -75, 4096))
                                            Velocity(root, Vector3.new(0, -1e3, 0))
                                            task.wait()
                                        end
                                    end
                                    if (config.Combats.Revenge.Poison.Value) then
                                        for _ = 1, 3 do
                                            SetNetworkOwner(root)
                                            task.wait(.1)
                                            MoveTo(root, CFrame.new(58, -70, 271))
                                            task.wait()
                                        end
                                    end
                                    if (config.Combats.Revenge.Ragdoll.Value) then
                                        for _ = 1, 3 do
                                            local pos = root.CFrame
                                            SetNetworkOwner(root)
                                            task.wait(.1)
                                            Velocity(root, Vector3.new(0, -64, 0))
                                            task.wait()
                                            MoveTo(root, pos)
                                            Velocity(root, Vector3.zero)
                                            task.wait()
                                        end
                                    end
                                    if (config.Combats.Revenge.Death.Value) then
                                        for _ = 1, 3 do
                                            SetNetworkOwner(root)
                                            task.wait(.1)
                                            cget(root.Parent, "Humanoid"):ChangeState(Enum.HumanoidStateType.Dead)
                                            task.wait(.5)
                                            ungrab(root)
                                            task.wait()
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end

        if (config.Combats.StrAntiGrab.Value and getLocalHum() and getLocalHum().Sit) then
            service.ReplicatedStorage.CharacterEvents.Struggle:FireServer(getLocalPlayer())
            service.ReplicatedStorage.GameCorrectionEvents.StopAllVelocity:FireServer()
            getLocalHum().Sit = false
            SetNetworkOwner(getLocalRoot())
        end

        if (ExtinguisherTimer >= 1) then
            if (config.Combats.Extinguisher.Value) then
                if (getLocalChar() and get(getLocalHum(), "FireDebounce") and get(getLocalHum(), "FireDebounce").Value) then
                    local FireExtinguisher = spawntoy("FireExtinguisher", getLocalRoot().CFrame)
                    for _, v in ipairs(FireExtinguisher:GetDescendants()) do
                        if (v:IsA("BasePart")) then
                            v.CanCollide = false
                        end
                    end
                    local pos = getLocalRoot().Position - Vector3.new(0, 3, 0)
                    local look = getLocalRoot().CFrame.LookVector
                    FireExtinguisher.PrimaryPart.CFrame = CFrame.new(pos, pos + look)
                    task.delay(1, function()
                        destroyToy(FireExtinguisher)
                    end)
                end
            end
            ExtinguisherTimer = 0
        end

        if (AuraTimer >= .5) then
            if (not getLocalRoot()) then return end
            for _, v in ipairs(GetNearParts(getLocalRoot().Position, config.Settings.AuraRadius.Value)) do
                if (not v.Anchored and not v:IsDescendantOf(getLocalChar()) and (v.Name == "HumanoidRootPart" or v.Name == "Torso" or v.Name == "Head")) then
                    local p = service.Players:GetPlayerFromCharacter(v.Parent)
                    if (IsFriend(p) and config.Settings.IgnoreFriend.Value) then continue end
                    if (not p and config.Settings.OnlyPlayer.Value) then continue end
                    if (config.Auras.VoidAura.Value) then
                        task.spawn(function()
                            SetNetworkOwner(v)
                            v.CanCollide = false
                            Velocity(v, Vector3.new(0, 1e4, 0))
                        end)
                    end
                    if (config.Auras.KillAura.Value) then
                        task.spawn(function()
                            SetNetworkOwner(v)
                            v.CanCollide = false
                            MoveTo(v, CFrame.new(4096, -75, 4096))
                            Velocity(v, Vector3.new(0, -1e3, 0))
                        end)
                    end
                    if (config.Auras.PoisonAura.Value) then
                        task.spawn(function()
                            SetNetworkOwner(v)
                            local pos = v.CFrame
                            MoveTo(v, CFrame.new(58, -70, 271))
                        end)
                    end
                    if (config.Auras.RagdollAura.Value) then
                        task.spawn(function()
                            local pos = v.CFrame
                            SetNetworkOwner(v)
                            Velocity(v, Vector3.new(0, -256, 0))
                            task.wait()
                            MoveTo(v, pos)
                            Velocity(v, Vector3.zero)
                        end)
                    end
                    if (config.Auras.DeathAura.Value) then
                        task.spawn(function()
                            SetNetworkOwner(v)
                            task.wait(.1)
                            local hum = cget(v.Parent, "Humanoid")
                            if (hum) then
                                hum:ChangeState(Enum.HumanoidStateType.Dead)
                            end
                            task.wait(.5)
                            ungrab(v)
                        end)
                    end
                    if (config.Auras.AnchorAura.Value) then
                        task.spawn(function()
                            anchor(v)
                        end)
                    end
                    if (config.Auras.FireAura.Value) then
                        task.spawn(function()
                            local e = spawntoy("Campfire", getLocalRoot().CFrame).SoundPart
                            SetNetworkOwner(e)
                            task.wait(.1)
                            e.CFrame = v.CFrame
                            task.delay(.5, destroyToy, e.Parent)
                        end)
                    end
                    if (config.Auras.NoclipAura.Value) then
                        task.spawn(function()
                            SetNetworkOwner(v)
                            task.wait(.1)
                            v.CanCollide = false
                        end)
                    end
                end
            end
            AuraTimer = 0
        end

        if (config.Combats.AntiVoid.Value) then
            workspace.FallenPartsDestroyHeight = 0 / 0
            local rad = math.huge
            if (getLocalRoot()) then
                local height = -87.5
                local Y = getLocalRoot().CFrame.Y
                if (height >= Y) then
                    service.ReplicatedStorage.CharacterEvents.Struggle:FireServer()
                    service.ReplicatedStorage.GameCorrectionEvents.StopAllVelocity:FireServer()
                    local p = workspace.SpawnLocation
                    local pos = (p.Position + Vector3.new(math.random(-p.Size.X * 0.5, p.Size.X * 0.5), math.random(0, p.Size.Y), math.random(-p.Size.Z * 0.5, p.Size.Z * 0.5)))
                    getLocalRoot().CFrame = (CFrame.new(pos, getLocalRoot().CFrame.LookVector))
                    getLocalRoot().AssemblyLinearVelocity = Vector3.zero
                    getLocalRoot().AssemblyAngularVelocity = Vector3.zero
                    windNotify({
                        Title = "Suisei Hub",
                        Content = "Suisei saved you from the void!",
                        Duration = 5
                    })
                end
            end
        end

        if (config.Combats.AntiFar.Value) then
            if (getLocalRoot() and not IsInRadius(getLocalRoot(), Vector3.zero, 4096)) then
                service.ReplicatedStorage.CharacterEvents.Struggle:FireServer()
                service.ReplicatedStorage.GameCorrectionEvents.StopAllVelocity:FireServer()
                local p = workspace.SpawnLocation
                local pos = (p.Position + Vector3.new(math.random(-p.Size.X * 0.5, p.Size.X * 0.5), math.random(0, p.Size.Y), math.random(-p.Size.Z * 0.5, p.Size.Z * 0.5)))
                getLocalRoot().CFrame = (CFrame.new(pos, getLocalRoot().CFrame.LookVector))
                getLocalRoot().AssemblyLinearVelocity = Vector3.zero
                getLocalRoot().AssemblyAngularVelocity = Vector3.zero
                windNotify({
                    Title = "Suisei Hub",
                    Content = "Suisei saved you from being too far!",
                    Duration = 5
                })
            end
        end

        if (config.Combats.InvisLine.Value) then
            service.ReplicatedStorage.GrabEvents.DestroyGrabLine:FireServer()
        end

        if (config.Combats.AimBot.Value) then
            for _, v in ipairs(GetNearParts(getLocalRoot().CFrame.Position, config.Combats.AimBot.Radius.Value)) do
                if (not v.Anchored and not v:IsDescendantOf(getLocalChar())) then
                    local p = service.Players:GetPlayerFromCharacter(v.Parent)
                    if (IsFriend(p) and config.Settings.IgnoreFriend.Value) then continue end
                    if (not p and config.Settings.OnlyPlayer.Value) then continue end
                    if (v.Name ~= config.Combats.AimBot.Part.Value) then continue end
                    workspace.CurrentCamera.CFrame =
                        workspace.CurrentCamera.CFrame:Lerp(
                            CFrame.lookAt(
                                workspace.CurrentCamera.CFrame.Position,
                                v.Position
                            ),
                            config.Settings.AimBotSpeed.Value / 10
                        )
                end
            end
        end

        --// MISCS
        if (config.Miscs.Control.Value) then
            if (not config.Miscs.Control.Target.Value) then return end
            local root = config.Miscs.Control.Target.Value.PrimaryPart
            if (getLocalRoot()) then
                getLocalRoot().CFrame = root.CFrame + Vector3.new(0, -10, 0)
            end
            if (cget(root.Parent, "Humanoid")) then
                workspace.CurrentCamera.CameraSubject = cget(root.Parent, "Humanoid")
            end
            if (getLocalChar()) then
                for _, v in ipairs(getLocalChar():GetDescendants()) do
                    if (v:IsA("BasePart")) then
                        v.CanCollide = false
                    end
                end
            end
        end
        if (getLocalChar()) then
            local ChatTyping = get(getLocalChar(), "ChatTyping")
            if (ChatTyping) then
                ChatTyping.Enabled = not config.Miscs.NoTyping.Value
            end
        end
        if (AntiKickDisablerTimer >= .5) then
            if (config.Miscs.AntiKickDisabler.Value) then
                for _, v in ipairs(GetNearParts(getLocalRoot().Position, 16)) do
                    if (v.Name == "FirePlayerPart" and not v:IsDescendantOf(getLocalChar())) then
                        local p = service.Players:GetPlayerFromCharacter(v.Parent.Parent)
                        if (p) then
                            SetNetworkOwner(v)
                            v.CFrame = CFrame.new(0, -200, 0)
                        end
                    end
                end
            end
            AntiKickDisablerTimer = 0
        end
        if (config.Miscs.NWOAura.Value) then
            for _, v in ipairs(GetNearParts(getLocalRoot().Position, config.Settings.AuraRadius.Value)) do
                if (not v.Anchored and not v:IsDescendantOf(getLocalChar())) then
                    SetNetworkOwner(v)
                end
            end
        end

        --// BLOBMAN
        if (config.Blobman.Noclip.Value) then
            local blob = getBlobman()
            if (blob) then
                for _, v in ipairs(blob:GetDescendants()) do
                    if (v:IsA("BasePart")) then
                        v.CanCollide = false
                    end
                end
            end
        end
        if (config.Blobman.GrabAura.Value) then
            local blob = getBlobman()
            if (blob) then
                for _, v in ipairs(GetNearParts(getLocalRoot().Position, config.Settings.AuraRadius.Value)) do
                    if (not v.Anchored and not v:IsDescendantOf(getLocalChar()) and (v.Name == "HumanoidRootPart" or v.Name == "Torso")) then
                        local p = service.Players:GetPlayerFromCharacter(v.Parent)
                        if (IsFriend(p) and config.Settings.IgnoreFriend.Value) then continue end
                        if (not p and config.Settings.OnlyPlayer.Value) then continue end
                        blobGrab(blob, v, config.Blobman.ArmSide.Value)
                    end
                end
            end
        end
        if (config.Blobman.KickAura.Value) then
            local blob = getBlobman()
            if (blob) then
                for _, v in ipairs(GetNearParts(getLocalRoot().Position, config.Settings.AuraRadius.Value)) do
                    if (not v.Anchored and not v:IsDescendantOf(getLocalChar()) and (v.Name == "HumanoidRootPart" or v.Name == "Torso")) then
                        local p = service.Players:GetPlayerFromCharacter(v.Parent)
                        if (IsFriend(p) and config.Settings.IgnoreFriend.Value) then continue end
                        if (not p and config.Settings.OnlyPlayer.Value) then continue end
                        blobKick(blob, v, config.Blobman.ArmSide.Value)
                    end
                end
            end
        end
        if (config.Blobman.LoopKick.Value) then
            local t = getPlayerFromName(config.Blobman.Target.Value)
            if (t) then
                local root = get(t.Character, "HumanoidRootPart")
                local b = getBlobman()
                if (root and b) then
                    blobKick(b, root, config.Blobman.ArmSide.Value)
                end
            end
        end
        if (config.Blobman.LoopKickAll.Value) then
            local blob = getBlobman()
            if (blob) then
                for _, v in ipairs(service.Players:GetPlayers()) do
                    if (v == getLocalPlayer()) then continue end
                    if (not config.Settings.IgnoreIsInPlot.Value and IsInPlot(v)) then continue end
                    if (config.Settings.IgnoreFriend.Value and IsFriend(v)) then continue end
                    local character = v.Character
                    if (not character) then continue end
                    local root = get(character, "HumanoidRootPart")
                    if (not root) then continue end
                    blobKick(blob, root, config.Blobman.ArmSide.Value)
                end
            end
        end

        --// SNIPES
        if (SnipeLoopTimer >= 1) then
            if (config.Snipes.LoopVoid.Value) then
                local t = getPlayerFromName(config.Snipes.Target.Value)
                if (t) then
                    local root = get(t.Character, "HumanoidRootPart")
                    if (root) then
                        task.spawn(function()
                            local pos = getLocalRoot().CFrame
                            Snipefunc(root, function()
                                Velocity(root, Vector3.new(0, 1e4, 0))
                                getLocalRoot().CFrame = pos
                            end)
                        end)
                    end
                end
            end
            if (config.Snipes.LoopKill.Value) then
                local t = getPlayerFromName(config.Snipes.Target.Value)
                if (t) then
                    local root = get(t.Character, "HumanoidRootPart")
                    if (root) then
                        task.spawn(function()
                            local pos = getLocalRoot().CFrame
                            Snipefunc(root, function()
                                MoveTo(root, CFrame.new(4096, -75, 4096))
                                Velocity(root, Vector3.new(0, -1e3, 0))
                                getLocalRoot().CFrame = pos
                            end)
                        end)
                    end
                end
            end
            if (config.Snipes.LoopPoison.Value) then
                local t = getPlayerFromName(config.Snipes.Target.Value)
                if (t) then
                    local root = get(t.Character, "HumanoidRootPart")
                    if (root) then
                        task.spawn(function()
                            local pos = getLocalRoot().CFrame
                            Snipefunc(root, function()
                                MoveTo(root, CFrame.new(58, -70, 271))
                                getLocalRoot().CFrame = pos
                            end)
                        end)
                    end
                end
            end
            if (config.Snipes.LoopRagdoll.Value) then
                local t = getPlayerFromName(config.Snipes.Target.Value)
                if (t) then
                    local root = get(t.Character, "HumanoidRootPart")
                    if (root) then
                        task.spawn(function()
                            local pos = getLocalRoot().CFrame
                            Snipefunc(root, function()
                                local rpos = root.CFrame
                                Velocity(root, Vector3.new(0, -64, 0))
                                task.wait(.1)
                                getLocalRoot().CFrame = rpos
                                Velocity(root, Vector3.zero)
                                getLocalRoot().CFrame = pos
                            end)
                        end)
                    end
                end
            end
            if (config.Snipes.LoopDeath.Value) then
                local t = getPlayerFromName(config.Snipes.Target.Value)
                if (t) then
                    local root = get(t.Character, "HumanoidRootPart")
                    if (root) then
                        task.spawn(function()
                            local pos = getLocalRoot().CFrame
                            Snipefunc(root, function()
                                local hum = cget(root.Parent, "Humanoid")
                                if (hum) then
                                    hum:ChangeState(Enum.HumanoidStateType.Dead)
                                end
                                task.wait(.5)
                                ungrab(root)
                                getLocalRoot().CFrame = pos
                            end)
                        end)
                    end
                end
            end
            SnipeLoopTimer = 0
        end

        --// TROLLS
        if (LoudAllTimer >= .1) then
            if (config.Trolls.LoudAll.Value) then
                if (config.Trolls.LoudAll.SoundPart.Value) then
                    for _, v in ipairs(service.Players:GetPlayers()) do
                        if (v == getLocalPlayer()) then continue end
                        if (not config.Settings.IgnoreIsInPlot.Value and IsInPlot(v)) then continue end
                        if (config.Settings.IgnoreFriend.Value and IsFriend(v)) then continue end
                        local character = v.Character
                        if (not character) then continue end
                        local root = get(character, "HumanoidRootPart")
                        if (not root) then continue end
                        config.Trolls.LoudAll.SoundPart.Value.SoundPart.CFrame = root.CFrame
                    end
                end
            end
            LoudAllTimer = 0
        end
        if (config.Trolls.Lag.Value) then
            lag(config.Settings.Lag.Value)
        end
        if (config.Trolls.Ping.Value) then
            ping(config.Settings.Ping.Value)
        end
        if (ServerDestroyerTimer >= .1) then
            if (config.Trolls.ServerDestroyer.Value) then
                for _ = 1, 32 do
                    createLine(nil)
                    if (getLocalRoot()) then
                        getLocalRoot().CFrame = config.Trolls.ServerDestroyer.CFrame
                    end
                end
            end
            ServerDestroyerTimer = 0
        end
        if (config.Trolls.ChaosLine.Value) then
            for _ = 1, 32 do
                createLine(nil)
            end
        end
    end)
end

print("[Suisei Hub] Loaded successfully!")
