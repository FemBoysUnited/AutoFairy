local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- Destroy previous UI safely
if PlayerGui:FindFirstChild("FairyRewardsUI") then
    pcall(function()
        PlayerGui.FairyRewardsUI:Destroy()
    end)
end

-- Reward list
local rewardList = {
    "Enchanted Seed Pack","Fairy Points","Enchanted Crate","Enchanted Egg",
    "Mutation Spray Glimmering","Glimmering Radar","Fairy Targeter","Pet Shard Glimmering"
}

-- Priority settings (high-contrast)
local prioritySettings = {
    [1]={Color=Color3.fromRGB(0,255,255),Thickness=6}, -- Cyan
    [2]={Color=Color3.fromRGB(255,0,255),Thickness=5}, -- Magenta
    [3]={Color=Color3.fromRGB(255,165,0),Thickness=4}, -- Orange
    [4]={Color=Color3.fromRGB(0,255,0),Thickness=3},   -- Lime
}

local function make(props)
    local inst = Instance.new(props.Class or "Frame")
    for k,v in pairs(props) do
        if k ~= "Class" then
            inst[k] = v
        end
    end
    return inst
end

-- ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "FairyRewardsUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = PlayerGui

-- Main frame
local mainFrame = make{
    Class="Frame",
    Parent=screenGui,
    Size=UDim2.new(0,460,0,220),
    AnchorPoint=Vector2.new(0.5,0.5),
    Position=UDim2.new(0.5,0,0.5,0),
    BackgroundColor3=Color3.fromRGB(25,25,25)
}
Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0,10)

local mainStroke = Instance.new("UIStroke", mainFrame)
mainStroke.Color = Color3.fromRGB(255,50,50)
mainStroke.Thickness = 2

-- Topbar
local topbar = make{
    Class="Frame",
    Parent=mainFrame,
    Size=UDim2.new(1,0,0,28),
    BackgroundColor3=Color3.fromRGB(35,35,35)
}
Instance.new("UICorner", topbar).CornerRadius = UDim.new(0,10)

-- Currency tracker left
local currencyLabel = make{
    Class="TextLabel",
    Parent=topbar,
    Size=UDim2.new(0,80,1,0),
    Position=UDim2.new(0,4,0,0),
    BackgroundTransparency=1,
    Text="0",
    TextColor3=Color3.fromRGB(255,255,255),
    Font=Enum.Font.SourceSansBold,
    TextScaled=true
}
local currencyIcon = make{
    Class="ImageLabel",
    Parent=topbar,
    Size=UDim2.new(0,20,0,20),
    Position=UDim2.new(0,90,0,4),
    BackgroundTransparency=1,
    Image=""
}

-- Centered title
local titleLabel = make{
    Class="TextLabel",
    Parent=topbar,
    Size=UDim2.new(0,200,1,0),
    Position=UDim2.new(0.5,-100,0,0),
    BackgroundTransparency=1,
    Text="Fairy Rewards",
    TextColor3=Color3.fromRGB(240,240,240),
    Font=Enum.Font.SourceSansBold,
    TextScaled=true
}

-- Close button
local closeBtn = make{
    Class="TextButton",
    Parent=topbar,
    Size=UDim2.new(0,28,0,20),
    Position=UDim2.new(1,-34,0,4),
    BackgroundColor3=Color3.fromRGB(200,60,60),
    Text="X",
    TextColor3=Color3.new(1,1,1),
    Font=Enum.Font.SourceSansBold
}
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0,6)
closeBtn.MouseButton1Click:Connect(function()
    screenGui:Destroy()
end)

-- Drag and minimize logic
local dragging, dragStart, startPos, minimized = false, nil, nil, false
topbar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = mainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    elseif input.UserInputType == Enum.UserInputType.MouseButton2 then
        if minimized then
            mainFrame.Size = UDim2.new(0,460,0,220)
            minimized = false
        else
            mainFrame.Size = UDim2.new(0,460,0,28)
            minimized = true
        end
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        mainFrame.Position = UDim2.new(
            startPos.X.Scale, startPos.X.Offset + delta.X,
            startPos.Y.Scale, startPos.Y.Offset + delta.Y
        )
    end
end)

-- Reward cards
local cardsFrame = make{
    Class="Frame",
    Parent=mainFrame,
    Size=UDim2.new(1,-10,0,80),
    Position=UDim2.new(0,5,0,32),
    BackgroundTransparency=1
}
local hl = Instance.new("UIListLayout", cardsFrame)
hl.FillDirection = Enum.FillDirection.Horizontal
hl.SortOrder = Enum.SortOrder.LayoutOrder
hl.Padding = UDim.new(0,8)

local cardTemplates = {}
for i = 1,3 do
    local card = make{
        Class="Frame",
        Parent=cardsFrame,
        Size=UDim2.new(0,130,1,0),
        BackgroundColor3=Color3.fromRGB(30,30,30)
    }
    Instance.new("UICorner", card).CornerRadius = UDim.new(0,8)
    make{
        Class="ImageLabel",
        Parent=card,
        Name="Vector",
        Size=UDim2.new(0,60,0,60),
        Position=UDim2.new(0.5,-30,0.5,-30),
        BackgroundTransparency=1,
        ScaleType=Enum.ScaleType.Fit
    }
    make{
        Class="TextLabel",
        Parent=card,
        Name="Title",
        Size=UDim2.new(1,-4,0,18),
        Position=UDim2.new(0,2,1,-18),
        BackgroundTransparency=1,
        Text="Empty",
        TextColor3=Color3.new(1,1,1),
        Font=Enum.Font.SourceSans,
        TextScaled=true,
        TextWrapped=true,
        TextXAlignment=Enum.TextXAlignment.Center
    }
    cardTemplates[i] = card
end

-- Priority boxes
local priorityFrame = make{
    Class="Frame",
    Parent=mainFrame,
    Size=UDim2.new(1,-10,0,70),
    Position=UDim2.new(0,5,0,120),
    BackgroundTransparency=1
}
local pLabels = make{
    Class="Frame",
    Parent=priorityFrame,
    Size=UDim2.new(1,0,0,20),
    BackgroundTransparency=1
}
local pBoxes = make{
    Class="Frame",
    Parent=priorityFrame,
    Size=UDim2.new(1,0,0,40),
    Position=UDim2.new(0,0,0,25),
    BackgroundTransparency=1
}
local labelLayout = Instance.new("UIListLayout", pLabels)
labelLayout.FillDirection = Enum.FillDirection.Horizontal
labelLayout.SortOrder = Enum.SortOrder.LayoutOrder
labelLayout.Padding = UDim.new(0,8)

local boxLayout = Instance.new("UIListLayout", pBoxes)
boxLayout.FillDirection = Enum.FillDirection.Horizontal
boxLayout.SortOrder = Enum.SortOrder.LayoutOrder
boxLayout.Padding = UDim.new(0,8)

local selectedPriorities = {}
for i = 1,4 do
    make{
        Class="TextLabel",
        Parent=pLabels,
        Size=UDim2.new(0,100,1,0),
        BackgroundTransparency=1,
        Text="Priority "..i,
        TextColor3=prioritySettings[i].Color,
        Font=Enum.Font.SourceSans,
        TextScaled=true,
        TextXAlignment=Enum.TextXAlignment.Center
    }

    local box = make{
        Class="Frame",
        Parent=pBoxes,
        Size=UDim2.new(0,100,1,0),
        BackgroundColor3=Color3.fromRGB(45,45,45)
    }
    Instance.new("UICorner", box).CornerRadius = UDim.new(0,6)

    local label = make{
        Class="TextLabel",
        Parent=box,
        Size=UDim2.new(1,-40,1,0),
        Position=UDim2.new(0,4,0,0),
        BackgroundTransparency=1,
        Text="None",
        TextColor3=Color3.new(1,1,1),
        Font=Enum.Font.SourceSans,
        TextScaled=true,
        TextXAlignment=Enum.TextXAlignment.Center
    }

    local btn = make{
        Class="TextButton",
        Parent=box,
        Size=UDim2.new(0,36,0.7,0),
        Position=UDim2.new(1,-40,0.15,0),
        BackgroundColor3=Color3.fromRGB(70,70,70),
        Text="▶",
        TextColor3=Color3.new(1,1,1),
        Font=Enum.Font.SourceSansBold,
        TextScaled=true
    }
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0,4)

    local idx = 0
    btn.MouseButton1Click:Connect(function()
        idx = idx + 1
        if idx > #rewardList then
            idx = 0
        end

        if idx == 0 then
            selectedPriorities[i] = nil
            label.Text = "None"
        else
            selectedPriorities[i] = rewardList[idx]
            label.Text = rewardList[idx]
        end
    end)
end

-- Auto Pick toggle centered
local toggleBtn = make{
    Class="TextButton",
    Parent=mainFrame,
    Size=UDim2.new(0,140,0,28),
    Position=UDim2.new(0.5,-70,0,mainFrame.Size.Y.Offset-38),
    BackgroundColor3=Color3.fromRGB(70,70,70),
    Text="Auto Pick: OFF",
    TextColor3=Color3.new(1,1,1),
    Font=Enum.Font.SourceSansBold,
    TextScaled=true
}
Instance.new("UICorner", toggleBtn).CornerRadius = UDim.new(0,6)

local isHighlighting = false
toggleBtn.MouseButton1Click:Connect(function()
    isHighlighting = not isHighlighting
    toggleBtn.Text = isHighlighting and "Auto Pick: ON" or "Auto Pick: OFF"
    mainStroke.Color = isHighlighting and Color3.fromRGB(0,255,0) or Color3.fromRGB(255,50,50)
end)

-- Reward functions
local function getIngameRewards()
    local root = PlayerGui:FindFirstChild("ChooseFairyRewards_UI")
    if not root or not root.Enabled then return {} end
    local items = root:FindFirstChild("Frame") and root.Frame.Main and root.Frame.Main.Items
    if not items then return {} end
    local rewards = {}
    local kids = items:GetChildren()
    if #kids >= 3 then table.insert(rewards, kids[3]) end
    if items:FindFirstChild("Template") then table.insert(rewards, items.Template) end
    if #kids >= 4 then table.insert(rewards, kids[4]) end
    return rewards
end

local function copyRewards()
    local rewards = getIngameRewards()
    for i = 1,3 do
        local src = rewards[i]
        local dst = cardTemplates[i]
        if src and dst then
            dst.Vector.Image = (src:FindFirstChild("Vector") and src.Vector.Image) or ""
            dst.Title.Text = (src:FindFirstChild("Title") and src.Title.Text) or "Empty"
        end
    end
end

RunService.Heartbeat:Connect(function()
    local root = PlayerGui:FindFirstChild("ChooseFairyRewards_UI")
    if root and root.Enabled then
        copyRewards()
    end
end)

-- Highlight loop
RunService.Heartbeat:Connect(function()
    if not isHighlighting then return end
    local rewards = getIngameRewards()
    for _, frame in ipairs(rewards) do
        local name = frame:FindFirstChild("Title") and frame.Title.Text
        local matched
        for i = 1,4 do
            if selectedPriorities[i] == name then
                matched = i
                break
            end
        end

        local stroke = frame:FindFirstChild("FairyUIStroke")
        if matched and not stroke then
            stroke = Instance.new("UIStroke")
            stroke.Name = "FairyUIStroke"
            stroke.Parent = frame
            stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
            stroke.Color = prioritySettings[matched].Color
            stroke.Thickness = prioritySettings[matched].Thickness
        elseif not matched and stroke then
            stroke:Destroy()
        end
    end
end)

-- Currency tracker updater
task.spawn(function()
    while screenGui.Parent do
        local currencyUI = PlayerGui:FindFirstChild("FairyCurrency_UI")
        if currencyUI and currencyUI:FindFirstChild("Frame") then
            local frameUI = currencyUI.Frame
            local txtLabel = frameUI:FindFirstChild("TextLabel1")
            local imgLabel = frameUI:FindFirstChild("ImageLabel")
            if txtLabel and imgLabel then
                currencyLabel.Text = txtLabel.Text
                currencyIcon.Image = imgLabel.Image
            end
        end
        task.wait(0.1)
    end
end)

print("[FairyRewardsUI] Full UI with currency tracker, minimize, toggle, high-contrast highlights ready.")
