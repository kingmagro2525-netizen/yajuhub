local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- 必要なリモートイベントとサービス
local GrabEvents = ReplicatedStorage:WaitForChild("GrabEvents")
local MenuToys = ReplicatedStorage:WaitForChild("MenuToys")
local localPlayer = Players.LocalPlayer
local playerCharacter = localPlayer.Character or localPlayer.CharacterAdded:Wait()

localPlayer.CharacterAdded:Connect(function(character)
    playerCharacter = character
end)

-- グローバル変数の定義
_G.BlobmanDelay = 0.05 -- 投げ飛ばし速度スライダーのデフォルト値

-- 😈 ブロブマン関連のローカル変数
local blobmanCoroutine
local blobman
local blobalter = 1
local yeetMode = false -- 投げ飛ばしモードの状態を管理

-- ユーティリティ関数 (U) の最小限の定義（ブロブマン機能の動作に必要なものだけ）
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
-- ユーティリティ関数ここまで

-- Blobman Grab Player Yeet function
-- Yeet ModeがONの場合、掴んだ後すぐに解除（または再試行/高速な掴み/解除）を行う
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
    pcall(function()
        blobman:WaitForChild("BlobmanSeatAndOwnerScript"):WaitForChild("CreatureGrab"):FireServer(unpack(args))
    end)
    
    if yeetMode then
        -- 投げ飛ばしモードがONの場合、掴んだ後すぐに解除/再試行
        wait(_G.BlobmanDelay) -- 投げ飛ばし速度スライダーの値を使用
        local releaseArgs = {
            [1] = detector,
            [2] = player.Character.HumanoidRootPart,
            [3] = weld
        }
        -- Yeet Modeの場合、同じ引数でもう一度FireServerを呼び出すことでGrabを即座に解除/再試行していると仮定
        pcall(function()
            blobman:WaitForChild("BlobmanSeatAndOwnerScript"):WaitForChild("CreatureGrab"):FireServer(unpack(releaseArgs))
        end)
    end
end

-- OrionLibのロードと初期設定
local OrionLib = loadstring(game:HttpGet(("https://raw.githubusercontent.com/yua20170313a-pixel/Orion/e19e8236bde46c459fb0d617e4640aeb75878703/source")))()

local Window = OrionLib:MakeWindow({
    Name = "最小限のブロブマングラブハブ", 
    HidePremium = false, 
    SaveConfig = true, 
    ConfigFolder = "最小限のブロブマングラブ", 
    IntroEnabled = true, 
    IntroText = "Minimal Blobman Grab Hub", 
    Icon = "rbxassetid://18624614127"
})

local BlobmanTab = Window:MakeTab({Name = "ブロブマン", Icon =  "rbxassetid://18624614127", PremiumOnly = false})

-- 1. ループグラブオール トグル
local blobmanToggle = BlobmanTab:AddToggle({
    Name = "ループグラブオール",
    Color = Color3.fromRGB(240, 0, 0),
    Default = false,
    Callback = function(enabled)
        if enabled then
            blobmanCoroutine = coroutine.create(function()
                local foundBlobman = false
                
                -- ブロブマンを見つける
                for i, v in pairs(game.Workspace:GetDescendants()) do
                    if v.Name == "CreatureBlobman" then
                        local vehicleSeat = v:FindFirstChild("VehicleSeat")
                        -- VehicleSeatが存在し、かつプレイヤーが座っていることを確認
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
                    -- トグルをOFFに戻す
                    blobmanToggle:Set(false)
                    blobman = nil
                    return
                end

                -- Yeet ModeがOFFの場合、Yeet Modeを自動的にONにする（ユーザーが意図したループ動作のため）
                if not yeetMode then
                    yeetMode = true
                end

                while true do
                    pcall(function()
                        for i, v in pairs(Players:GetChildren()) do
                            if blobman and v ~= localPlayer then
                                blobGrabPlayerYeet(v, blobman)
                                -- Yeet Mode ON時/OFF時で待機時間が異なるため、ここでは最低限の待機
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
                yeetMode = false -- ループが停止したらYeet ModeもOFFに戻す
            end
        end
    end
})

-- 2. Delay (投げ飛ばし速度) スライダー
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
    Default = false, -- ループグラブオールで自動的にONになる可能性がありますが、ここではユーザー操作のために残します
    Callback = function(enabled)
        yeetMode = enabled
    end
})

BlobmanTab:AddParagraph("使い方", "1. ブロブマンに乗る\n2. ループグラブオールをON\n3. 投げ飛ばしモードをONにすると相手が飛びます (ループグラブオールがONの時、このトグルもONにすることを推奨)")

OrionLib:MakeNotification({Name = "Welcome", Content = "最小限のブロブマングラブハブへようこそ", Image = "rbxassetid://4483345998", Time = 5})
OrionLib:Init()
