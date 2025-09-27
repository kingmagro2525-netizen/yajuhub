local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()
local Window = Rayfield:CreateWindow({
Name = "Gg Hub",
LoadingTitle = "Loading Gg Hub",
LoadingSubtitle = "by yajusaiko4545",
ConfigurationSaving = {
Enabled = true,
FolderName = nil,
FileName = "AP setting"
}
})
local Tab = Window:CreateTab("AP", 4483362458)
local Section = Tab:CreateSection("AP")
Tab:CreateButton({
Name = "AP",
Callback = function()
print("Button clicked!")
end
})
local Tab = Window:CreateTab("ESP", 4483362458)
local Section = Tab:CreateSection("ESP")
Tab:CreateButton({
Name = "ESP on",
Callback = function()
print("Button clicked!")
local function applyESP(char, plr)
    -- HumanoidRootPart を確実に待つ
    local hrp = char:WaitForChild("HumanoidRootPart", 10)
    if not hrp then return end

    -- Highlight
    if not char:FindFirstChild("ESP_Highlight") then
        local highlight = Instance.new("Highlight")
        highlight.Name = "ESP_Highlight"
        highlight.FillColor = Color3.fromRGB(0, 255, 0)
        highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
        highlight.Adornee = char
        highlight.Parent = char
    end

    -- BillboardGui（名前）
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

-- プレイヤーに ESP をセットする関数
local function addESP(plr)
    if plr ~= game.Players.LocalPlayer then
        -- キャラが追加されたら必ず処理
        plr.CharacterAdded:Connect(function(char)
            applyESP(char, plr)
        end)

        -- すでにキャラがいるならすぐに付ける
        if plr.Character then
            applyESP(plr.Character, plr)
        end
    end
end

-- 既存のプレイヤーに適用
for _, plr in ipairs(game.Players:GetPlayers()) do
    addESP(plr)
end

-- 新規参加プレイヤーにも適用
game.Players.PlayerAdded:Connect(function(plr)
    addESP(plr)
end)
Tab:CreateButton({
Name = "ESP off",
Callback = function()
print("Button clicked!")
for _, plr in ipairs(game.Players:GetPlayers()) do
    if plr.Character then
        local highlight = plr.Character:FindFirstChild("ESP_Highlight")
        if highlight then
            highlight:Destroy()
        end

        local billboard = plr.Character:FindFirstChild("ESP_NameTag")
        if billboard then
            billboard:Destroy()
        end
    end
end
end
})
Tab:CreateButton({
Name = "ESP off",
Callback = function()
print("Button clicked!")
local Tab = Window:CreateTab("AUTO", 4483362458)
local Section = Tab:CreateSection("AUTO")
Tab:CreateButton({
Name = "AUTO join",
Callback = function()
print("Button clicked!")
end
})
Tab:CreateButton({
Name = "ANTI afk",
Callback = function()
print("Button clicked!")
end
})
local Tab = Window:CreateTab("作者", 4483362458)
local Section = Tab:CreateSection("作者")
Tab:CreateButton({
Name = "yajusaiko4545",
Callback = function()
print("Button clicked!")
end
})
local Section = Tab:CreateSection("Tiktok")
Tab:CreateButton({
Name = "yajusaiko4545",
Callback = function()
print("Button clicked!")
end
})
local Section = Tab:CreateSection("Discord")
Tab:CreateButton({
Name = "yajusaiko4545",
Callback = function()
print("Button clicked!")
end
})
Tab:CreateSection(" ")
Tab:CreateButton({
Name = "sns系は大体この名前でやってるよ〜",
Callback = function()
print("Button clicked!")
end
})
