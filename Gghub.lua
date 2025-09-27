-- Rayfield の読み込み
local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

-- メインウィンドウ
local Window = Rayfield:CreateWindow({
    Name = "Gg Hub",
    LoadingTitle = "Loading Gg Hub",
    LoadingSubtitle = "by yajusaiko4545",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = nil,
        FileName = "AP_setting"
    }
})

---------------------------------------------------------------------
-- AP タブ
---------------------------------------------------------------------
local TabAP = Window:CreateTab("AP", 4483362458)
TabAP:CreateButton({
    Name = "AP",
    Callback = function()
        print("AP button clicked!")
    end
})

---------------------------------------------------------------------
-- ESP タブ
---------------------------------------------------------------------
local TabESP = Window:CreateTab("ESP", 4483362458)

-- ESP On
TabESP:CreateButton({
    Name = "ESP on",
    Callback = function()
        print("ESP on clicked!")

        local function applyESP(char, plr)
            local hrp = char:WaitForChild("HumanoidRootPart", 5)
            if not hrp then return end

            if not char:FindFirstChild("ESP_Highlight") then
                local highlight = Instance.new("Highlight")
                highlight.Name = "ESP_Highlight"
                highlight.FillColor = Color3.fromRGB(0, 255, 0)
                highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                highlight.Adornee = char
                highlight.Parent = char
            end

            if not char:FindFirstChild("ESP_NameTag") then
                local billboard = Instance.new("BillboardGui")
                billboard.Name = "ESP_NameTag"
                billboard.Size = UDim2.new(0, 100, 0, 20)
                billboard.StudsOffset = Vector3.new(0, 4, 0)
                billboard.AlwaysOnTop = true
                billboard.Parent = hrp

                local textLabel = Instance.new("TextLabel")
                textLabel.Size = UDim2.new(1, 0, 1, 0)
                textLabel.BackgroundTransparency = 1
                textLabel.Text = plr.Name
                textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
                textLabel.TextStrokeTransparency = 0
                textLabel.Font = Enum.Font.SourceSansBold
                textLabel.TextScaled = true
                textLabel.Parent = billboard
            end
        end

        local function addESP(plr)
            if plr ~= game.Players.LocalPlayer then
                plr.CharacterAdded:Connect(function(char)
                    applyESP(char, plr)
                end)
                if plr.Character then
                    applyESP(plr.Character, plr)
                end
            end
        end

        for _, plr in ipairs(game.Players:GetPlayers()) do
            addESP(plr)
        end

        game.Players.PlayerAdded:Connect(function(plr)
            addESP(plr)
        end)
    end
})

-- ESP Off（完全削除＋子要素も消す）
TabESP:CreateButton({
    Name = "ESP off",
    Callback = function()
        print("ESP off clicked!")
        for _, plr in ipairs(game.Players:GetPlayers()) do
            if plr.Character then
                -- Highlight 削除
                local highlight = plr.Character:FindFirstChild("ESP_Highlight")
                if highlight then
                    highlight:Destroy()
                end

                -- BillboardGui 削除（中のTextLabelも一緒に消える）
                local billboard = plr.Character:FindFirstChild("ESP_NameTag", true)
                if billboard then
                    billboard:Destroy()
                end
            end
        end
    end
})

---------------------------------------------------------------------
-- AUTO タブ
---------------------------------------------------------------------
local TabAuto = Window:CreateTab("AUTO", 4483362458)

TabAuto:CreateButton({
    Name = "AUTO join",
    Callback = function()
        print("AUTO join clicked!")
    end
})

TabAuto:CreateButton({
    Name = "ANTI afk",
    Callback = function()
        print("ANTI afk clicked!")
    end
})

---------------------------------------------------------------------
-- 作者タブ
---------------------------------------------------------------------
local TabAuthor = Window:CreateTab("作者", 4483362458)

TabAuthor:CreateButton({
    Name = "yajusaiko4545",
    Callback = function()
        print("作者 clicked!")
    end
})

local SectionTiktok = TabAuthor:CreateSection("Tiktok")
TabAuthor:CreateButton({
    Name = "yajusaiko4545",
    Callback = function()
        print("Tiktok clicked!")
    end
})

local SectionDiscord = TabAuthor:CreateSection("Discord")
TabAuthor:CreateButton({
    Name = "yajusaiko4545",
    Callback = function()
        print("Discord clicked!")
    end
})

TabAuthor:CreateSection(" ")
TabAuthor:CreateButton({
    Name = "sns系は大体この名前でやってるよ〜",
    Callback = function()
        print("SNS説明 clicked!")
    end
})
