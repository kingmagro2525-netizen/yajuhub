local H=game:GetService("HttpService")
local s,R=pcall(function() return loadstring(game:HttpGet("https://sirius.menu/rayfield"))() end)
if not s then warn("Rayfield失敗") return end
local W=R:CreateWindow({Name="やじゅうの花火",LoadingTitle="ロード中 やじゅうの花火",LoadingSubtitle="by yajusaiko4545",ConfigurationSaving={Enabled=false}})
local P=game.Players.LocalPlayer
local C=P.Character or P.CharacterAdded:Wait()
local H1=C:WaitForChild("Head")
local M=nil
local E=false
local S={}
local A=0
local D,O,T={}, {}, {}
local MODES={"星","丸","変化","マジック"}
local CFG={}

for _,m in ipairs(MODES) do
    local f=m.."_config.json"
    if isfile(f) then CFG[m]=H:JSONDecode(readfile(f)) else CFG[m]={Height=10,Size=10,Speed=2} end
end
local function sv(m) writefile(m.."_config.json",H:JSONEncode(CFG[m])) end

local function F(r)
    local t={}
    for _,o in pairs(workspace:GetDescendants()) do
        if o:IsA("BasePart") and o.Name:lower():find("base") then
            if (o.Position-H1.Position).Magnitude<r then
                pcall(function() o:SetNetworkOwner(nil) end)
                o.Anchored=true
                table.insert(t,o)
            end
        end
    end
    return t
end

local function G1(i,t)
    local p={} local s=math.pi*2/5
    for k=1,5 do p[k]=Vector3.new(math.cos(s*(k-1)),0,math.sin(s*(k-1))) end
    local o={1,3,5,2,4,1} local ts=#o-1
    local seg=((i+t/10)%ts)+1
    local idx=math.floor(seg)
    local r=seg-idx
    local pos=p[o[idx]]:Lerp(p[o[idx+1]],r)*CFG["星"].Size
    return Vector3.new(pos.X,CFG["星"].Height,pos.Z)
end

local function G2(m,i,t)
    local c=CFG[m]
    if m=="星" then return G1(i,t)
    elseif m=="丸" then local cnt=math.max(1,#S) local rad=math.rad((i-1)*(360/cnt)+t) return Vector3.new(math.cos(rad)*c.Size,c.Height,math.sin(rad)*c.Size)
    elseif m=="変化" then local rad=math.rad(t+i*15) local sp=c.Size*0.8 + i*0.3 return Vector3.new(math.cos(rad)*sp,c.Height + math.sin(rad*2)*3,math.sin(rad)*sp)
    elseif m=="マジック" then local cur=T[i] or Vector3.new() local dir=D[i] local off=O[i] local tgt=dir*(math.sin(t*0.05*c.Speed+off)*c.Size) T[i]=cur:Lerp(tgt,0.1) return T[i] end
end

task.spawn(function()
    while task.wait(0.02) do
        if E and M and #S>0 then
            if not H1 or not H1.Parent then continue end
            A+=CFG[M].Speed
            for i,b in ipairs(S) do if b and b.Parent then b.CFrame=CFrame.new(H1.Position+G2(M,i,A),H1.Position) end end
        end
    end
end)

local function CMT(n,icon)
    local t=W:CreateTab(n,icon)
    local c=CFG[n]
    t:CreateSlider({Name="高さ",Range={1,200},Increment=1,CurrentValue=c.Height,Callback=function(v) c.Height=v sv(n) end})
    t:CreateSlider({Name="大きさ",Range={1,1000},Increment=1,CurrentValue=c.Size,Callback=function(v) c.Size=v sv(n) end})
    t:CreateSlider({Name="スピード",Range={1,1000},Increment=1,CurrentValue=c.Speed,Callback=function(v) c.Speed=v sv(n) end})
    t:CreateToggle({Name="つける",CurrentValue=false,Callback=function(v)
        if v then
            M=n E=true S=F(100) T={}
            if n=="マジック" then
                D={} O={} for i,_ in ipairs(S) do D[i]=Vector3.new(math.random(-100,100)/100,math.random(-100,100)/100,math.random(-100,100)/100).Unit O[i]=math.random()*math.pi*2 T[i]=Vector3.new() end
            end
        else E=false S={} end
    end})
end

for _,m in ipairs(MODES) do CMT(m,4483362458) end
