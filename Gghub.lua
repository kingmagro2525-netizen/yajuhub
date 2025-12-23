-- FTAP完全統合版 v7.1 - デバッグログ強化版
print("[FTAP Debug] スクリプトの実行を開始しました...")

local success_orion, OrionLib = pcall(function()
    return loadstring(game:HttpGet("https://raw.githubusercontent.com/Polinorsik/Orion-Z-Library/refs/heads/main/README.md"))()
end)

if not success_orion or not OrionLib then
    warn("[FTAP Debug] Orion Libraryの読み込みに失敗しました。URLが変更されているか、通信エラーの可能性があります。")
    return
else
    print("[FTAP Debug] Orion Library の読み込みに成功しました。")
end

print("[FTAP Debug] サービスの取得を開始...")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")
local Lighting = game:GetService("Lighting")
local HttpService = game:GetService("HttpService")
print("[FTAP Debug] サービスの取得が完了しました。")

-- キャラクター取得（ここで止まる場合があるためタイムアウト付きでログ出力）
print("[FTAP Debug] キャラクターを待機中...")
local LocalCharacter = LocalPlayer.Character
if not LocalCharacter then
    LocalCharacter = LocalPlayer.CharacterAdded:Wait()
end
print("[FTAP Debug] キャラクターを認識しました: " .. LocalCharacter.Name)

LocalPlayer.CharacterAdded:Connect(function(character)
    LocalCharacter = character
    print("[FTAP Debug] キャラクターが更新されました。")
end)

-- サーバーリモートの確認
print("[FTAP Debug] リモートイベントを検索中 (最大10秒待機)...")
local GrabEvents = ReplicatedStorage:WaitForChild("GrabEvents", 10)
local MenuToys = ReplicatedStorage:WaitForChild("MenuToys", 10)
local CharacterEvents = ReplicatedStorage:WaitForChild("CharacterEvents", 10)

if not GrabEvents or not MenuToys or not CharacterEvents then
    warn("[FTAP Debug] 必要なリモートイベントが見つかりません。ゲームがアップデートされた可能性があります。")
    return
end
print("[FTAP Debug] 全てのリモートイベントを確認しました。")

-- 各種リモートの取得
local SetNetworkOwner = GrabEvents:WaitForChild("SetNetworkOwner", 5)
local Struggle = CharacterEvents:WaitForChild("Struggle", 5)
local CreateGrabLine = GrabEvents:WaitForChild("CreateGrabLine", 5)
local DestroyGrabLine = GrabEvents:WaitForChild("DestroyGrabLine", 5)
local DestroyToy = MenuToys:WaitForChild("DestroyToy", 5)
local RagdollRemote = CharacterEvents:WaitForChild("RagdollRemote", 5)
local BombEvents = ReplicatedStorage:FindFirstChild("BombEvents")
print("[FTAP Debug] 個別のファンクション/イベントを取得しました。")

local toysFolder = workspace:FindFirstChild(LocalPlayer.Name.."SpawnedInToys")

-- 変数初期化（省略せず既存のものを維持）
_G.strength = 450
_G.BlobmanDelay = 0.001
_G.ToyToLoad = "BombMissile"
_G.MaxMissiles = 9
_G.flySpeed = 100
_G.kickForce = 150
_G.ufoRotationSpeed = 5
_G.ufoHeight = 10

local strength = 450
local auraRadius = 20
local whiteListEnabled = false
local espObjects = {}
local connections = {}
local anchoredParts = {}
local compiledGroups = {}
local bombList = {}
local ownedToys = {}
local decoyOffset = 5
local circleRadius = 10
local followMode = true
local crouchWalkSpeed = 50
local crouchJumpPower = 50
local infJump = false
local antiVoidEnabled = false
local defenseStrength = 25
local blobDelay = 0.001

-- 🆕 新機能用変数
local antiGrabCreatureEnabled = false
local antiGrabTestInvisibleEnabled = false
local antiLagLookEnabled = false
local lineLagEnabled = false
local lineLagAllEnabled = false
local lineLagTarget = nil
local lineLagSpeed = 0.05
local invisibleLineEnabled = false
local randomLineEnabled = false
local gradientRandomEnabled = false
local presetSegments = 10

-- ターゲット選択用
local TargetSelected = nil
local selectedTarget = nil

-- Coroutine管理
local coroutineFlags = {
    PoisonGrab = false, PoisonAura = false, GrabAura = false, RadiactiveGrab = false, 
    BurnGrab = false, FireAura = false, LoopFireAura = false, KillGrab = false, 
    KickGrab = false, UfoGrab = false, NoclipGrab = false, AnchorGrab = false, 
    AntiGrab = false, LoopKill = false, OrbitPlayer = false, BringAll = false, 
    CrouchSpeed = false, CrouchJump = false, FireAll = false, RagdollAll = false, 
    BlobmanAuto = false, HeavenGrab = false, CrazyGrab = false, DeleteAura = false, 
    ServerBreak = false, AntiGrabCreature = false, AntiGrabTestInvisible = false
}

-- [関数定義部分は元のコードと同じため、中略してUI作成部分へ進みます]
-- (実際の提供時には、お手元のスクリプトの全関数をここに含めてください)

print("[FTAP Debug] UIの構築を開始します...")

local Window = OrionLib:MakeWindow({
    Name = "FTAP完全統合版 v7.1 [Debug Mode]",
    HidePremium = false,
    SaveConfig = true,
    ConfigFolder = "FTAPMergedV71",
    IntroEnabled = false
})

-- 攻撃タブ
local AttackTab = Window:MakeTab({Name = "⚔️ 攻撃", Icon = "rbxassetid://4483345998"})
print("[FTAP Debug] 攻撃タブを作成しました。")

-- [タブ内コンテンツの作成コードをここに配置]

-- グラブタブ
local GrabTab = Window:MakeTab({Name = "🎯 グラブ", Icon = "rbxassetid://4483345998"})
print("[FTAP Debug] グラブタブを作成しました。")

-- オーラタブ
local AuraTab = Window:MakeTab({Name = "🔥 オーラ", Icon = "rbxassetid://4483345998"})
print("[FTAP Debug] オーラタブを作成しました。")

-- 最終初期化
print("[FTAP Debug] 最終セットアップを実行中...")
OrionLib:Init()

task.wait(0.5)
OrionLib:MakeNotification({
    Name = "🎉 FTAP Debug 起動完了",
    Content = "コンソール(F9)を確認してください",
    Image = "rbxassetid://4483345998",
    Time = 5
})

print("========================================")
print("FTAP v7.1 Loaded Successfully!")
print("もしUIが出ていない場合は、上記ログのどこで止まっているか教えてください。")
print("========================================")
