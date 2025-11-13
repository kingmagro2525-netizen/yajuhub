local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GrabEvents = ReplicatedStorage:WaitForChild("GrabEvents")
local MenuToys = ReplicatedStorage:WaitForChild("MenuToys")
local localPlayer = Players.LocalPlayer
local playerCharacter = localPlayer.Character or localPlayer.CharacterAdded:Wait()

localPlayer.CharacterAdded:Connect(function(character)
    playerCharacter = character
end)




local blobmanCoroutine
local blobman
local blobalter = 1
local yeetMode = false -- 投げ飛ばしモードの状態を管理


local Utilities = {}

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

local U = Utilities


-- Blobman Grab Player Yeet function

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
    
    
    pcall(function()
        blobman:WaitForChild("BlobmanSeatAndOwnerScript"):WaitForChild("CreatureGrab"):FireServer(unpack(args))
    end)
    
    if yeetMode then
        
        wait(_G.BlobmanDelay) 
        local releaseArgs = {
            [1] = detector,
            [2] = player.Character.HumanoidRootPart,
            [3] = weld
        }
        
        pcall(function()
            blobman:WaitForChild("BlobmanSeatAndOwnerScript"):WaitForChild("CreatureGrab"):FireServer(unpack(releaseArgs))
        end)
    end
end


local OrionLib = loadstring(game:HttpGet(("https://raw.githubusercontent.com/yua20170313a-pixel/Orion/e19e8236bde46c459fb0d617e4640aeb75878703/source")))()

local Window = OrionLib:MakeWindow({
    Name = "野獣のブロブマングラブハブ", 
    HidePremium = false, 
    SaveConfig = true, 
    ConfigFolder = "最小限のブロブマングラブ", 
    IntroEnabled = true, 
    IntroText = "Minimal Blobman Grab Hub", 
    Icon = "rbxassetid://18624614127"
})

local BlobmanTab = Window:MakeTab({Name = "ブロブマン", Icon =  "rbxassetid://18624614127", PremiumOnly = false})


local blobmanToggle = BlobmanTab:AddToggle({
    Name = "ループグラブオール",
    Color = Color3.fromRGB(240, 0, 0),
    Default = false,
    Callback = function(enabled)
        if enabled then
            blobmanCoroutine = coroutine.create(function()
                local foundBlobman = false
                
                
                for i, v in pairs(game.Workspace:GetDescendants()) do
                    if v.Name == "CreatureBlobman" then
                        local vehicleSeat = v:FindFirstChild("VehicleSeat")
                        
                        if vehicleSeat and vehicleSeat:FindFirstChild("SeatWeld") and vehicleSeat.SeatWeld.Part1 and vehicleSeat.SeatWeld.Part1.Parent and vehicleSeat.SeatWeld.Part1.Parent:FindFirstChild("Humanoid") then
                            blobman = v
                            foundBlobman = true
                            break
                        end
                    end
                end
                
                if not foundBlobman then
                    OrionLib:MakeNotification({
                        Name = "エラー",
                        Content = "ブロブマンに乗ってからトグルをオンにしてください", 
                        Image = "rbxassetid://4483345998", 
                        Time = 5
                    })
                    
                    blobmanToggle:Set(false)
                    blobman = nil
                    return
                end

                ）
                if not yeetMode then
                    yeetMode = true
                end

                while true do
                    pcall(function()
                        for i, v in pairs(Players:GetChildren()) do
                            if blobman and v ~= localPlayer then
                                blobGrabPlayerYeet(v, blobman)
                                
                                wait() 
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
                yeetMode = false 
            end
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

-- 3. 投げ飛ばしモード (Yeet Mode) トグル (ループグラブオールがこのモードを利用しているため残します)
BlobmanTab:AddToggle({
    Name = "投げ飛ばしモード (Yeet Mode)",
    Color = Color3.fromRGB(255, 100, 0),
    Default = false, 
    Callback = function(enabled)
        yeetMode = enabled
    end
})

BlobmanTab:AddParagraph("使い方", "1. ブロブマンに乗る\n2. ループグラブオールをON\n3. 投げ飛ばしモードをONにすると相手が飛びます (ループグラブオールがONの時、このトグルもONにすることを推奨)")

OrionLib:MakeNotification({Name = "Welcome", Content = "野獣のブロブマングラブハブへようこそ", Image = "rbxassetid://4483345998", Time = 5})
OrionLib:Init()
