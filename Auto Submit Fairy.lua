-- Fancy Fairy Offerings GUI with ultra-fast updates and single-fire wish
-- LocalScript

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Destroy old GUI
if playerGui:FindFirstChild("FairyOfferingsUI") then
    playerGui.FairyOfferingsUI:Destroy()
end

-- ScreenGui
local gui = Instance.new("ScreenGui")
gui.Name = "FairyOfferingsUI"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.Parent = playerGui
print("[Debug] Fairy Offerings UI Loaded")

-- Main frame
local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 520, 0, 280)
frame.Position = UDim2.new(0.5, -260, 0.7, -140)
frame.BackgroundColor3 = Color3.fromRGB(25,25,25)
frame.BorderSizePixel = 0
frame.ClipsDescendants = true


-- Rounded corners for main frame
local uicorner = Instance.new("UICorner", frame)
uicorner.CornerRadius = UDim.new(0, 15)


-- Gradient outline
local outline = Instance.new("UIStroke", frame)
outline.Thickness = 2
outline.ApplyStrokeMode = Enum.ApplyStrokeMode.Border


local function setOutline(on)
if on then
outline.Color = Color3.fromRGB(80,200,120) -- greenish glow
else
outline.Color = Color3.fromRGB(200,80,80) -- reddish glow
end
end
setOutline(false)

-- Topbar
local topbar = Instance.new("Frame", frame)
topbar.Size = UDim2.new(1,0,0,35)
topbar.BackgroundColor3 = Color3.fromRGB(40,40,40)
topbar.Position = UDim2.new(0,0,0,0)
topbar.BorderSizePixel = 0
Instance.new("UICorner", topbar).CornerRadius = UDim.new(0, 15)


-- Currency display (icon + amount) on the left
local currencyFrame = Instance.new("Frame", topbar)
currencyFrame.Size = UDim2.new(0, 160, 1, 0)
currencyFrame.Position = UDim2.new(0, 5, 0, 0)
currencyFrame.BackgroundTransparency = 1


local currencyIcon = Instance.new("ImageLabel", currencyFrame)
currencyIcon.Size = UDim2.new(0, 30, 0.8, 0)
currencyIcon.Position = UDim2.new(0, 0, 0.1, 0)
currencyIcon.BackgroundTransparency = 1


local currencyLabel = Instance.new("TextLabel", currencyFrame)
currencyLabel.Size = UDim2.new(1, -35, 1, 0)
currencyLabel.Position = UDim2.new(0, 35, 0, 0)
currencyLabel.TextColor3 = Color3.fromRGB(255,255,255)
currencyLabel.BackgroundTransparency = 1
currencyLabel.TextScaled = true
currencyLabel.Font = Enum.Font.GothamBold
currencyLabel.TextXAlignment = Enum.TextXAlignment.Left
currencyLabel.TextYAlignment = Enum.TextYAlignment.Center


-- GUI Title next to currency, centered in remaining space
local title = Instance.new("TextLabel", topbar)
title.Size = UDim2.new(1, -210, 1, 0) -- leave space for currency and close button
title.Position = UDim2.new(0, 170, 0, 0)
title.Text = "🌸 Fairy Manager"
title.TextColor3 = Color3.fromRGB(255,255,255)
title.BackgroundTransparency = 1
title.TextScaled = true
title.Font = Enum.Font.SourceSansBold
title.TextXAlignment = Enum.TextXAlignment.Center


-- Close button on the right
local closeBtn = Instance.new("TextButton", topbar)
closeBtn.Size = UDim2.new(0, 30, 0, 30)
closeBtn.Position = UDim2.new(1, -40, 0, 2)
closeBtn.Text = "X"
closeBtn.BackgroundColor3 = Color3.fromRGB(120,0,0)
closeBtn.TextColor3 = Color3.fromRGB(255,255,255)
closeBtn.Font = Enum.Font.SourceSansBold
closeBtn.TextScaled = true
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0,8)
closeBtn.MouseButton1Click:Connect(function()
gui:Destroy()
end)


-- Update currency constantly
task.spawn(function()
while gui.Parent do
local currencyUI = playerGui:FindFirstChild("FairyCurrency_UI")
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

-- Dragging topbar
local dragging, dragInput, dragStart, startPos

topbar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = frame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)
topbar.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then
        dragInput = input
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X,
            startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- Offering slots
local slots = {}
local order = {"Offering_2","Offering_1","Offering_3"}
for i = 1,3 do
    local slot = Instance.new("Frame", frame)
    slot.Size = UDim2.new(1/3, -15, 0, 200)
    slot.Position = UDim2.new((i-1)/3, 5 + (i-1)*5, 0, 45)
    slot.BackgroundColor3 = Color3.fromRGB(35,35,35)
    slot.BorderSizePixel = 0
    slot.ClipsDescendants = true
    Instance.new("UICorner", slot).CornerRadius = UDim.new(0,12)

    local slotGradient = Instance.new("UIGradient", slot)
    slotGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(50,50,60)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(30,30,40))
    })
    slotGradient.Rotation = 45

    local img = Instance.new("ImageLabel", slot)
    img.Size = UDim2.new(0.7,0,0.6,0)
    img.Position = UDim2.new(0.15,0,0.05,0)
    img.BackgroundTransparency = 1
    img.Image = ""

    local nameLabel = Instance.new("TextLabel", slot)
    nameLabel.Size = UDim2.new(1, -20, 0, 50)
    nameLabel.Position = UDim2.new(0,10,0.65,0)
    nameLabel.Text = ""
    nameLabel.TextScaled = true
    nameLabel.BackgroundTransparency = 1
    nameLabel.TextColor3 = Color3.fromRGB(220,220,255)
    nameLabel.TextStrokeTransparency = 0.8
    nameLabel.Font = Enum.Font.GothamBold

    slots[i] = {slot=slot, img=img, name=nameLabel, lastText="", wishAlreadyFired=false, canAutoSubmit=true}
end

-- Auto-submit toggle
local toggleBtn = Instance.new("TextButton", frame)
toggleBtn.Size = UDim2.new(0, 220, 0, 35)
toggleBtn.Position = UDim2.new(0.5, -110, 1, -45)
toggleBtn.Text = "Auto Submit: OFF"
toggleBtn.BackgroundColor3 = Color3.fromRGB(60,60,70)
toggleBtn.TextColor3 = Color3.fromRGB(255,255,255)
toggleBtn.Font = Enum.Font.GothamBold
toggleBtn.TextScaled = true
Instance.new("UICorner", toggleBtn).CornerRadius = UDim.new(0,10)

local autoSubmitEnabled = false
toggleBtn.MouseButton1Click:Connect(function()
    autoSubmitEnabled = not autoSubmitEnabled
    toggleBtn.Text = autoSubmitEnabled and "Auto Submit: ON" or "Auto Submit: OFF"
    setOutline(autoSubmitEnabled)
end)

-- Remote events
local submitEvent = ReplicatedStorage:WaitForChild("GameEvents"):WaitForChild("FairyService"):WaitForChild("SubmitFairyFountainHeldPlant")
local makeWishEvent = ReplicatedStorage:WaitForChild("GameEvents"):WaitForChild("FairyService"):WaitForChild("MakeFairyWish")
local restartEvent = ReplicatedStorage:WaitForChild("GameEvents"):WaitForChild("FairyService"):WaitForChild("RestartFairyTrack")

-- Helper: find matching fruit in backpack, ignoring favorited ones
local function findMatchingFruit(fruitType)
    for _, item in ipairs(player.Backpack:GetChildren()) do
        local itemString = item:FindFirstChild("Item_String")
        if itemString and itemString.Value == fruitType then
            if string.find(item.Name, "Glimmering") and not item:GetAttribute("d") then
                return item
            end
        end
    end
    return nil
end

-- Keep Teleport_UI panels visible
task.spawn(function()
    while gui.Parent do
        local teleportUI = player.PlayerGui:FindFirstChild("Teleport_UI")
        if teleportUI and teleportUI:FindFirstChild("Frame") then
            local frameUI = teleportUI.Frame
            if frameUI:FindFirstChild("Gear") then frameUI.Gear.Visible = true end
            if frameUI:FindFirstChild("Pets") then frameUI.Pets.Visible = true end
        end
        task.wait(0.1)
    end
end)

-- Debounce flags
local wishTriggered = false

-- Constantly check Restart visibility
task.spawn(function()
    while gui.Parent do
        if autoSubmitEnabled then
            local restartTask = player.PlayerGui:FindFirstChild("FairyQuests_UI")
            if restartTask then
                local frameMain = restartTask:FindFirstChild("Frame")
                if frameMain and frameMain:FindFirstChild("Main") and frameMain.Main:FindFirstChild("Holder") and frameMain.Main.Holder:FindFirstChild("Tasks") then
                    local restartBtn = frameMain.Main.Holder.Tasks:FindFirstChild("Restart")
                    if restartBtn and restartBtn.Visible then
                        restartEvent:FireServer()
                    end
                    local makeWishBtn = frameMain.Main.Holder.Tasks:FindFirstChild("MakeAWish")
                    if makeWishBtn then
                        if makeWishBtn.Visible and not wishTriggered then
                            wishTriggered = true
                            makeWishEvent:FireServer()
                            print("[Debug] MakeAWish remote fired")
                        elseif not makeWishBtn.Visible and wishTriggered then
                            wishTriggered = false
                        end
                    end
                end
            end
        end
        task.wait(0.05)
    end
end)

-- Main loop for offerings
task.spawn(function()
    local offeringsFolder = workspace:WaitForChild("Interaction"):WaitForChild("UpdateItems"):WaitForChild("FairyEvent"):WaitForChild("WishFountain")

    while gui.Parent do
        local displayedCount = 0
        local allCollected = true

        for i, offeringName in ipairs(order) do
            local offering = offeringsFolder:FindFirstChild(offeringName)
            local slot = slots[i]
            if offering and offering:FindFirstChild("GUI") then
                local surf = offering.GUI:FindFirstChild("SurfaceGui")
                if surf and surf.Enabled then
                    local imgObj = surf:FindFirstChild("ImageLabel")
                    local txtObj = surf:FindFirstChild("TextLabel")
                    if imgObj and txtObj then
                        if slots[i].lastText ~= txtObj.Text then
                            slots[i].slot.Visible = true
                            slots[i].img.Image = imgObj.Image
                            slots[i].name.Text = txtObj.Text
                            slots[i].lastText = txtObj.Text
                            slots[i].wishAlreadyFired = false
                            slots[i].canAutoSubmit = true
                        end

                        displayedCount = displayedCount + 1
                        local _, rest = txtObj.Text:match("(%d/%d)%s+(.+)")
                        local fruitType = rest and rest:gsub("Glimmering%s+", "")
                        local countText = txtObj.Text:match("(%d/%d)")
                        if countText ~= "1/1" then
                            allCollected = false
                        else
                            slot.canAutoSubmit = false
                        end

                        if autoSubmitEnabled and fruitType and slot.canAutoSubmit then
                            local fruit = findMatchingFruit(fruitType)
                            if fruit and player.Character then
                                local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
                                if humanoid then
                                    humanoid:EquipTool(fruit)
                                    task.wait(0.3)
                                    submitEvent:FireServer()
                                    task.wait(1)
                                end
                            end
                        end
                    else
                        slot.slot.Visible = false
                    end
                else
                    slot.slot.Visible = false
                end
            else
                slot.slot.Visible = false
            end
        end

        task.wait(0.05)
    end
end)
