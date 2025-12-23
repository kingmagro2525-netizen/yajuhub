-- FTAP完全統合版 v7.1 - デバッグGUI搭載版
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")

-- === 1. デバッグGUIの作成 ===
local debugGui = Instance.new("ScreenGui")
debugGui.Name = "FTAP_DebugGui"
debugGui.Parent = CoreGui -- プレイヤーが死んでも消えないようにCoreGuiへ

local mainFrame = Instance.new("ScrollingFrame")
mainFrame.Size = UDim2.new(0, 300, 0, 400)
mainFrame.Position = UDim2.new(1, -310, 0, 50)
mainFrame.BackgroundColor3 = Color3.new(0, 0, 0)
mainFrame.BackgroundTransparency = 0.3
mainFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
mainFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
mainFrame.Parent = debugGui

local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0, 2)
layout.Parent = mainFrame

local function debugLog(text, color)
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -10, 0, 20)
    label.BackgroundTransparency = 1
    label.TextColor3 = color or Color3.new(1, 1, 1)
    label.Text = "[" .. os.date("%X") .. "] " .. text
    label.TextSize = 12
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = mainFrame
    mainFrame.CanvasPosition = Vector2.new(0, mainFrame.AbsoluteCanvasSize.Y)
    print("[FTAP Debug] " .. text) -- 念のためコンソールにも
end

debugLog("スクリプト起動開始...", Color3.new(1, 1, 0))

-- === 2. ライブラリとサービスの読み込み ===
debugLog("Orion Libraryを読み込み中...")
local success_orion, OrionLib = pcall(function()
    return loadstring(game:HttpGet("https://raw.githubusercontent.com/Polinorsik/Orion-Z-Library/refs/heads/main/README.md"))()
end)

if not success_orion or not OrionLib then
    debugLog("エラー: Orion Libraryの読み込みに失敗", Color3.new(1, 0, 0))
    return
end
debugLog("Orion Library 読み込み完了")

local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")
local Lighting = game:GetService("Lighting")
local HttpService = game:GetService("HttpService")

debugLog("サービス取得完了")

-- リモート待機 (ここで止まることが多いです)
debugLog("リモートイベントを待機中...")
local GrabEvents = ReplicatedStorage:WaitForChild("GrabEvents", 5)
local MenuToys = ReplicatedStorage:WaitForChild("MenuToys", 5)
local CharacterEvents = ReplicatedStorage:WaitForChild("CharacterEvents", 5)

if not GrabEvents or not MenuToys or not CharacterEvents then
    debugLog("致命的エラー: リモートが見つかりません", Color3.new(1, 0, 0))
    return
end
debugLog("リモート接続成功")

-- [中略：既存の関数定義部分は元のコードと同じです]
-- ※お手元のスクリプトの各関数（executeCreatureAntiGrab 等）をここに配置してください

-- === 3. UI構築セクション ===
debugLog("ウィンドウを作成中...")
local Window = OrionLib:MakeWindow({
    Name = "FTAP完全統合版 v7.1 [Debug]",
    HidePremium = false,
    SaveConfig = true,
    ConfigFolder = "FTAPMergedV71",
    IntroEnabled = false
})

debugLog("攻撃タブを作成中...")
local AttackTab = Window:MakeTab({Name = "⚔️ 攻撃", Icon = "rbxassetid://4483345998"})
-- (AttackTabの内容...)
debugLog("攻撃タブ完了")

debugLog("グラブタブを作成中...")
local GrabTab = Window:MakeTab({Name = "🎯 グラブ", Icon = "rbxassetid://4483345998"})
-- (GrabTabの内容...)
debugLog("グラブタブ完了")

debugLog("オーラタブを作成中...")
local AuraTab = Window:MakeTab({Name = "🔥 オーラ", Icon = "rbxassetid://4483345998"})
-- (AuraTabの内容...)
debugLog("オーラタブ完了")

-- ここからが停止している可能性が高い場所です
debugLog("クリーチャータブ(Blobman)を作成中...")
local CreatureTab = Window:MakeTab({Name = "👾 クリーチャー", Icon = "rbxassetid://4483345998"})
-- ここにBlobman系のコードを記述
debugLog("クリーチャータブ完了")

debugLog("新機能タブ(Line/AntiGrab)を作成中...")
local NewFeatTab = Window:MakeTab({Name = "🆕 新機能", Icon = "rbxassetid://4483345998"})
-- ここに新機能のコードを記述
debugLog("新機能タブ完了")

debugLog("プレイヤー情報タブを作成中...")
-- (PlayerInfoの内容...)
debugLog("全タブの作成が終了しました")

-- === 4. 最終初期化 ===
debugLog("OrionLib:Init() を実行中...")
OrionLib:Init()
debugLog("すべてのロードが完了しました！", Color3.new(0, 1, 0))

-- 5秒後にデバッグGUIを消したい場合は以下を有効化 (任意)
-- task.wait(10)
-- debugGui:Destroy()
