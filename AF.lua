-- Enhanced Fairy Offerings GUI with improved modularity and tracking
-- LocalScript

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer

-- Configuration
local CONFIG = {
    GUI_NAME = "FairyOfferingsUI",
    MAIN_SIZE = {520, 420}, -- Increased height for reward selection
    COLORS = {
        BACKGROUND = Color3.fromRGB(25, 25, 25),
        TOPBAR = Color3.fromRGB(40, 40, 40),
        SLOT_PRIMARY = Color3.fromRGB(35, 35, 35),
        SLOT_GRADIENT_1 = Color3.fromRGB(50, 50, 60),
        SLOT_GRADIENT_2 = Color3.fromRGB(30, 30, 40),
        TEXT_PRIMARY = Color3.fromRGB(255, 255, 255),
        TEXT_SECONDARY = Color3.fromRGB(220, 220, 255),
        ACCENT_ON = Color3.fromRGB(50, 200, 120),
        ACCENT_OFF = Color3.fromRGB(200, 60, 60),
        TRACKER_BG = Color3.fromRGB(45, 45, 55),
        PRIORITY_1 = Color3.fromRGB(50, 255, 100),  -- Green
        PRIORITY_2 = Color3.fromRGB(255, 215, 0),   -- Gold
        PRIORITY_3 = Color3.fromRGB(255, 80, 80)    -- Red
    },
    OFFERING_ORDER = {"Offering_2", "Offering_1", "Offering_3"},
    REWARD_TYPES = {
        "Enchanted Seed Pack",
        "Fairy Points", 
        "Enchanted Crate Egg",
        "Enchanted Egg",
        "Mutation Spray",
        "Glimmering",
        "Glimmering Radar",
        "Fairy Targeter"
    },
    UPDATE_RATE = 0.05
}

-- State Management
local State = {
    autoSubmitEnabled = false,
    totalOfferings = 0,
    currentSet = 0,
    slots = {},
    gui = nil,
    connections = {},
    rewardPriorities = {"Fairy Points", "Enchanted Seed Pack", "Glimmering"},
    isWaitingForRewards = false,
    currentRewards = {}
}

-- Utility Functions
local Utils = {}

function Utils.createCorner(parent, radius)
    local corner = Instance.new("UICorner", parent)
    corner.CornerRadius = UDim.new(0, radius or 12)
    return corner
end

function Utils.createGradient(parent, colors, rotation)
    local gradient = Instance.new("UIGradient", parent)
    gradient.Color = ColorSequence.new(colors)
    gradient.Rotation = rotation or 0
    return gradient
end

function Utils.createStroke(parent, thickness, color)
    local stroke = Instance.new("UIStroke", parent)
    stroke.Thickness = thickness or 2
    stroke.Color = color or CONFIG.COLORS.ACCENT_OFF
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    return stroke
end

function Utils.cleanupConnections()
    for _, connection in pairs(State.connections) do
        if connection then
            connection:Disconnect()
        end
    end
    State.connections = {}
end

-- GUI Components
local Components = {}

function Components.createMainFrame()
    local gui = Instance.new("ScreenGui")
    gui.Name = CONFIG.GUI_NAME
    gui.Parent = player.PlayerGui
    gui.ResetOnSpawn = false
    
    local frame = Instance.new("Frame", gui)
    frame.Size = UDim2.new(0, CONFIG.MAIN_SIZE[1], 0, CONFIG.MAIN_SIZE[2])
    frame.Position = UDim2.new(0.5, -CONFIG.MAIN_SIZE[1]/2, 0.7, -CONFIG.MAIN_SIZE[2]/2)
    frame.BackgroundColor3 = CONFIG.COLORS.BACKGROUND
    frame.BorderSizePixel = 0
    frame.ClipsDescendants = true
    Utils.createCorner(frame, 15)
    
    State.gui = gui
    return gui, frame
end

function Components.createTopbar(parent)
    local topbar = Instance.new("Frame", parent)
    topbar.Size = UDim2.new(1, 0, 0, 40)
    topbar.BackgroundColor3 = CONFIG.COLORS.TOPBAR
    topbar.Position = UDim2.new(0, 0, 0, 0)
    topbar.BorderSizePixel = 0
    Utils.createCorner(topbar, 15)
    
    local title = Instance.new("TextLabel", topbar)
    title.Size = UDim2.new(1, -50, 1, 0)
    title.Position = UDim2.new(0, 10, 0, 0)
    title.Text = "Fairy Offerings Manager"
    title.TextColor3 = CONFIG.COLORS.TEXT_PRIMARY
    title.BackgroundTransparency = 1
    title.TextScaled = true
    title.Font = Enum.Font.GothamBold
    title.TextXAlignment = Enum.TextXAlignment.Left
    
    local closeBtn = Instance.new("TextButton", topbar)
    closeBtn.Size = UDim2.new(0, 35, 0, 35)
    closeBtn.Position = UDim2.new(1, -40, 0, 2.5)
    closeBtn.Text = "Ã—"
    closeBtn.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
    closeBtn.TextColor3 = CONFIG.COLORS.TEXT_PRIMARY
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.TextScaled = true
    Utils.createCorner(closeBtn, 8)
    
    State.connections[#State.connections + 1] = closeBtn.MouseButton1Click:Connect(function()
        Utils.cleanupConnections()
        State.gui:Destroy()
    end)
    
    return topbar
end

function Components.createTrackerPanel(parent)
    local trackerPanel = Instance.new("Frame", parent)
    trackerPanel.Size = UDim2.new(1, -20, 0, 60)
    trackerPanel.Position = UDim2.new(0, 10, 0, 50)
    trackerPanel.BackgroundColor3 = CONFIG.COLORS.TRACKER_BG
    trackerPanel.BorderSizePixel = 0
    Utils.createCorner(trackerPanel, 10)
    
    -- Currency display (centered)
    local currencyFrame = Instance.new("Frame", trackerPanel)
    currencyFrame.Size = UDim2.new(1, 0, 1, 0)
    currencyFrame.Position = UDim2.new(0, 0, 0, 0)
    currencyFrame.BackgroundTransparency = 1
    
    local currencyIcon = Instance.new("ImageLabel", currencyFrame)
    currencyIcon.Size = UDim2.new(0, 40, 0, 40)
    currencyIcon.Position = UDim2.new(0.5, -70, 0.5, -20)
    currencyIcon.BackgroundTransparency = 1
    currencyIcon.Image = ""
    
    local currencyLabel = Instance.new("TextLabel", currencyFrame)
    currencyLabel.Size = UDim2.new(0, 200, 1, 0)
    currencyLabel.Position = UDim2.new(0.5, -25, 0, 0)
    currencyLabel.Text = "Fairy Points: 0"
    currencyLabel.TextColor3 = CONFIG.COLORS.TEXT_PRIMARY
    currencyLabel.BackgroundTransparency = 1
    currencyLabel.TextScaled = true
    currencyLabel.Font = Enum.Font.GothamBold
    currencyLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    return trackerPanel, currencyIcon, currencyLabel
end

function Components.createOfferingSlots(parent)
    local slotsFrame = Instance.new("Frame", parent)
    slotsFrame.Size = UDim2.new(1, -20, 0, 130)
    slotsFrame.Position = UDim2.new(0, 10, 0, 120)
    slotsFrame.BackgroundTransparency = 1
    
    local slots = {}
    
    for i = 1, 3 do
        local slot = Instance.new("Frame", slotsFrame)
        slot.Size = UDim2.new(1/3, -10, 1, 0)
        slot.Position = UDim2.new((i-1)/3, 5, 0, 0)
        slot.BackgroundColor3 = CONFIG.COLORS.SLOT_PRIMARY
        slot.BorderSizePixel = 0
        slot.ClipsDescendants = true
        Utils.createCorner(slot, 12)
        
        Utils.createGradient(slot, {
            ColorSequenceKeypoint.new(0, CONFIG.COLORS.SLOT_GRADIENT_1),
            ColorSequenceKeypoint.new(1, CONFIG.COLORS.SLOT_GRADIENT_2)
        }, 45)
        
        local img = Instance.new("ImageLabel", slot)
        img.Size = UDim2.new(0.6, 0, 0.5, 0)
        img.Position = UDim2.new(0.2, 0, 0.05, 0)
        img.BackgroundTransparency = 1
        img.Image = ""
        
        local nameLabel = Instance.new("TextLabel", slot)
        nameLabel.Size = UDim2.new(1, -10, 0.4, 0)
        nameLabel.Position = UDim2.new(0, 5, 0.55, 0)
        nameLabel.Text = "Empty Slot"
        nameLabel.TextScaled = true
        nameLabel.BackgroundTransparency = 1
        nameLabel.TextColor3 = CONFIG.COLORS.TEXT_SECONDARY
        nameLabel.TextStrokeTransparency = 0.8
        nameLabel.Font = Enum.Font.GothamBold
        nameLabel.TextWrapped = true
        
        slots[i] = {
            slot = slot,
            img = img,
            name = nameLabel,
            lastText = "",
            wishAlreadyFired = false,
            canAutoSubmit = true
        }
    end
    
    return slots
end

function Components.createRewardSelector(parent)
    local rewardFrame = Instance.new("Frame", parent)
    rewardFrame.Size = UDim2.new(1, -20, 0, 80)
    rewardFrame.Position = UDim2.new(0, 10, 0, 260)
    rewardFrame.BackgroundColor3 = CONFIG.COLORS.TRACKER_BG
    rewardFrame.BorderSizePixel = 0
    Utils.createCorner(rewardFrame, 10)
    
    local title = Instance.new("TextLabel", rewardFrame)
    title.Size = UDim2.new(1, 0, 0, 25)
    title.Position = UDim2.new(0, 0, 0, 5)
    title.Text = "Reward Priority Settings"
    title.TextColor3 = CONFIG.COLORS.TEXT_PRIMARY
    title.BackgroundTransparency = 1
    title.TextScaled = true
    title.Font = Enum.Font.GothamBold
    title.TextXAlignment = Enum.TextXAlignment.Center
    
    local dropdowns = {}
    local priorityColors = {CONFIG.COLORS.PRIORITY_1, CONFIG.COLORS.PRIORITY_2, CONFIG.COLORS.PRIORITY_3}
    local priorityLabels = {"Priority 1", "Priority 2", "Priority 3"}
    
    for i = 1, 3 do
        local priorityFrame = Instance.new("Frame", rewardFrame)
        priorityFrame.Size = UDim2.new(1/3, -5, 0, 45)
        priorityFrame.Position = UDim2.new((i-1)/3, 2.5, 0, 30)
        priorityFrame.BackgroundTransparency = 1
        
        local label = Instance.new("TextLabel", priorityFrame)
        label.Size = UDim2.new(1, 0, 0, 15)
        label.Position = UDim2.new(0, 0, 0, 0)
        label.Text = priorityLabels[i]
        label.TextColor3 = priorityColors[i]
        label.BackgroundTransparency = 1
        label.TextScaled = true
        label.Font = Enum.Font.GothamBold
        label.TextXAlignment = Enum.TextXAlignment.Center
        
        local dropdown = Instance.new("TextButton", priorityFrame)
        dropdown.Size = UDim2.new(1, -4, 0, 25)
        dropdown.Position = UDim2.new(0, 2, 0, 18)
        dropdown.Text = State.rewardPriorities[i]
        dropdown.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
        dropdown.TextColor3 = CONFIG.COLORS.TEXT_PRIMARY
        dropdown.Font = Enum.Font.Gotham
        dropdown.TextScaled = true
        Utils.createCorner(dropdown, 5)
        Utils.createStroke(dropdown, 2, priorityColors[i])
        
        -- Dropdown functionality (simplified for now)
        State.connections[#State.connections + 1] = dropdown.MouseButton1Click:Connect(function()
            -- Cycle through reward types
            local currentIndex = 1
            for j, reward in ipairs(CONFIG.REWARD_TYPES) do
                if reward == State.rewardPriorities[i] then
                    currentIndex = j
                    break
                end
            end
            currentIndex = currentIndex % #CONFIG.REWARD_TYPES + 1
            State.rewardPriorities[i] = CONFIG.REWARD_TYPES[currentIndex]
            dropdown.Text = State.rewardPriorities[i]
        end)
        
        dropdowns[i] = dropdown
    end
    
    return rewardFrame, dropdowns
end

function Components.createControlPanel(parent)
    local controlPanel = Instance.new("Frame", parent)
    controlPanel.Size = UDim2.new(1, -20, 0, 50)
    controlPanel.Position = UDim2.new(0, 10, 1, -60)
    controlPanel.BackgroundTransparency = 1
    
    local toggleBtn = Instance.new("TextButton", controlPanel)
    toggleBtn.Size = UDim2.new(0.6, 0, 1, 0)
    toggleBtn.Position = UDim2.new(0.2, 0, 0, 0)
    toggleBtn.Text = "Auto Submit: OFF"
    toggleBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
    toggleBtn.TextColor3 = CONFIG.COLORS.TEXT_PRIMARY
    toggleBtn.Font = Enum.Font.GothamBold
    toggleBtn.TextScaled = true
    Utils.createCorner(toggleBtn, 10)
    
    local outline = Utils.createStroke(parent, 3, CONFIG.COLORS.ACCENT_OFF)
    
    State.connections[#State.connections + 1] = toggleBtn.MouseButton1Click:Connect(function()
        State.autoSubmitEnabled = not State.autoSubmitEnabled
        toggleBtn.Text = State.autoSubmitEnabled and "Auto Submit: ON" or "Auto Submit: OFF"
        
        local newColor = State.autoSubmitEnabled and CONFIG.COLORS.ACCENT_ON or CONFIG.COLORS.ACCENT_OFF
        local tween = TweenService:Create(outline, TweenInfo.new(0.3), {Color = newColor})
        tween:Play()
    end)
    
    return controlPanel, outline
end

function Components.setupDragging(topbar, frame)
    local dragging, dragInput, dragStart, startPos
    
    State.connections[#State.connections + 1] = topbar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
            
            State.connections[#State.connections + 1] = input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    
    State.connections[#State.connections + 1] = topbar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)
    
    State.connections[#State.connections + 1] = UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)
end

-- Core Logic
local Logic = {}

function Logic.updateCurrencyDisplay(currencyIcon, currencyLabel)
    local success, result = pcall(function()
        local fairyCurrencyUI = player.PlayerGui:FindFirstChild("FairyCurrency_UI")
        if fairyCurrencyUI and fairyCurrencyUI:FindFirstChild("Frame") then
            local frame = fairyCurrencyUI.Frame
            local textLabel = frame:FindFirstChild("TextLabel1")
            local imageLabel = frame:FindFirstChild("ImageLabel")
            
            if textLabel and imageLabel then
                currencyLabel.Text = "Fairy Points: " .. textLabel.Text
                currencyIcon.Image = imageLabel.Image
                return true
            end
        end
        return false
    end)
    
    if not success then
        currencyLabel.Text = "Fairy Points: N/A"
        currencyIcon.Image = ""
    end
end

function Logic.findMatchingFruit(fruitType)
    for _, item in ipairs(player.Backpack:GetChildren()) do
        local itemString = item:FindFirstChild("Item_String")
        if itemString and itemString.Value == fruitType then
            if string.find(item.Name, "Glimmering") then
                return item
            end
        end
    end
    return nil
end

function Logic.checkForRewardSelection()
    if not State.isWaitingForRewards then
        return
    end
    
    local success, result = pcall(function()
        local rewardUI = player.PlayerGui:FindFirstChild("ChooseFairyRewards_UI")
        if rewardUI and rewardUI.Enabled then
            local items = rewardUI.Frame.Main.Items
            local rewards = {}
            
            -- Get Template (reward 1)
            local template = items:FindFirstChild("Template")
            if template and template:FindFirstChild("Vector") and template:FindFirstChild("Title") then
                rewards[1] = {
                    element = template,
                    image = template.Vector.Image,
                    title = template.Title.Text
                }
            end
            
            -- Get other rewards from children
            local children = items:GetChildren()
            local rewardIndex = 2
            for _, child in ipairs(children) do
                if child ~= template and child:FindFirstChild("Vector") and child:FindFirstChild("Title") then
                    rewards[rewardIndex] = {
                        element = child,
                        image = child.Vector.Image,
                        title = child.Title.Text
                    }
                    rewardIndex = rewardIndex + 1
                    if rewardIndex > 3 then break end
                end
            end
            
            State.currentRewards = rewards
            State.isWaitingForRewards = false
            
            -- Highlight rewards based on priority
            Logic.highlightRewards()
            return true
        end
        return false
    end)
    
    return success and result
end

function Logic.highlightRewards()
    local priorityColors = {CONFIG.COLORS.PRIORITY_1, CONFIG.COLORS.PRIORITY_2, CONFIG.COLORS.PRIORITY_3}
    
    for i, reward in pairs(State.currentRewards) do
        if reward and reward.element then
            -- Find priority for this reward
            local priority = nil
            for p, rewardType in ipairs(State.rewardPriorities) do
                if string.find(reward.title, rewardType) then
                    priority = p
                    break
                end
            end
            
            if priority then
                -- Add glowing outline
                local existingStroke = reward.element:FindFirstChild("PriorityStroke")
                if existingStroke then
                    existingStroke:Destroy()
                end
                
                local stroke = Instance.new("UIStroke", reward.element)
                stroke.Name = "PriorityStroke"
                stroke.Thickness = 4
                stroke.Color = priorityColors[priority]
                stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
                
                -- Animate glow
                task.spawn(function()
                    while stroke.Parent and State.currentRewards[i] then
                        local tween1 = TweenService:Create(stroke, TweenInfo.new(0.8, Enum.EasingStyle.Sine), {Transparency = 0.3})
                        tween1:Play()
                        tween1.Completed:Wait()
                        local tween2 = TweenService:Create(stroke, TweenInfo.new(0.8, Enum.EasingStyle.Sine), {Transparency = 0})
                        tween2:Play()
                        tween2.Completed:Wait()
                    end
                end)
            end
        end
    end
end

function Logic.updateOfferingsDisplay()
    local offeringsFolder = workspace:WaitForChild("Interaction"):WaitForChild("UpdateItems"):WaitForChild("FairyEvent"):WaitForChild("WishFountain")
    local displayedCount = 0
    local allCollected = true
    local currentSetOfferings = 0
    
    for i, offeringName in ipairs(CONFIG.OFFERING_ORDER) do
        local offering = offeringsFolder:FindFirstChild(offeringName)
        local slot = State.slots[i]
        
        if offering and offering:FindFirstChild("GUI") then
            local surf = offering.GUI:FindFirstChild("SurfaceGui")
            if surf and surf.Enabled then
                local imgObj = surf:FindFirstChild("ImageLabel")
                local txtObj = surf:FindFirstChild("TextLabel")
                
                if imgObj and txtObj then
                    if slot.lastText ~= txtObj.Text then
                        slot.slot.Visible = true
                        slot.img.Image = imgObj.Image
                        slot.name.Text = txtObj.Text
                        slot.lastText = txtObj.Text
                        slot.wishAlreadyFired = false
                        slot.canAutoSubmit = true
                    end
                    
                    displayedCount = displayedCount + 1
                    currentSetOfferings = currentSetOfferings + 1
                    
                    local countText = txtObj.Text:match("(%d/%d)")
                    if countText == "1/1" then
                        State.totalOfferings = State.totalOfferings + 1
                        slot.canAutoSubmit = false
                    else
                        allCollected = false
                    end
                    
                    -- Auto-submit logic
                    if State.autoSubmitEnabled and slot.canAutoSubmit and countText ~= "1/1" then
                        local _, rest = txtObj.Text:match("(%d/%d)%s+(.+)")
                        local fruitType = rest and rest:gsub("Glimmering%s+", "")
                        
                        if fruitType then
                            local fruit = Logic.findMatchingFruit(fruitType)
                            if fruit and player.Character then
                                local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
                                if humanoid then
                                    humanoid:EquipTool(fruit)
                                    task.wait(0.3)
                                    
                                    local submitEvent = ReplicatedStorage:WaitForChild("GameEvents"):WaitForChild("FairyService"):WaitForChild("SubmitFairyFountainHeldPlant")
                                    submitEvent:FireServer()
                                    task.wait(1)
                                end
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
    
    -- Update set counter
    if currentSetOfferings > 0 then
        State.currentSet = math.ceil(State.totalOfferings / 3)
    end
    
    -- Handle wish making
    if State.autoSubmitEnabled and displayedCount > 0 and allCollected then
        local alreadyFired = true
        for _, s in ipairs(State.slots) do
            if not s.wishAlreadyFired then
                alreadyFired = false
                break
            end
        end
        
        if not alreadyFired then
            for _, s in ipairs(State.slots) do
                s.wishAlreadyFired = true
            end
            
            task.spawn(function()
                local fairyUI = player.PlayerGui:WaitForChild("FairyQuests_UI")
                while State.autoSubmitEnabled and State.gui.Parent and not fairyUI.Enabled do
                    task.wait(0.05)
                end
                if fairyUI.Enabled then
                    task.wait(0.2)
                    local makeWishEvent = ReplicatedStorage:WaitForChild("GameEvents"):WaitForChild("FairyService"):WaitForChild("MakeFairyWish")
                    makeWishEvent:FireServer()
                    
                    -- Start monitoring for reward selection UI
                    State.isWaitingForRewards = true
                    State.currentRewards = {}
                end
            end)
        end
    end
end

-- Main Initialization
local function initializeGUI()
    -- Clean up existing GUI
    if player.PlayerGui:FindFirstChild(CONFIG.GUI_NAME) then
        player.PlayerGui[CONFIG.GUI_NAME]:Destroy()
    end
    
    -- Create main components
    local gui, mainFrame = Components.createMainFrame()
    local topbar = Components.createTopbar(mainFrame)
    local trackerPanel, currencyIcon, currencyLabel = Components.createTrackerPanel(mainFrame)
    State.slots = Components.createOfferingSlots(mainFrame)
    local rewardFrame, dropdowns = Components.createRewardSelector(mainFrame)
    local controlPanel, outline = Components.createControlPanel(mainFrame)
    
    -- Setup dragging
    Components.setupDragging(topbar, mainFrame)
    
    -- Main update loop
    State.connections[#State.connections + 1] = RunService.Heartbeat:Connect(function()
        if not State.gui or not State.gui.Parent then
            Utils.cleanupConnections()
            return
        end
        
        Logic.updateCurrencyDisplay(currencyIcon, currencyLabel)
        Logic.checkForRewardSelection()
    end)
    
    -- Offerings update loop
    task.spawn(function()
        while State.gui and State.gui.Parent do
            Logic.updateOfferingsDisplay()
            task.wait(CONFIG.UPDATE_RATE)
        end
    end)
    
    -- Keep Teleport_UI visible
    task.spawn(function()
        while State.gui and State.gui.Parent do
            local teleportUI = player.PlayerGui:FindFirstChild("Teleport_UI")
            if teleportUI and teleportUI:FindFirstChild("Frame") then
                local frame = teleportUI.Frame
                if frame:FindFirstChild("Gear") then frame.Gear.Visible = true end
                if frame:FindFirstChild("Pets") then frame.Pets.Visible = true end
            end
            task.wait(0.1)
        end
    end)
end

-- Initialize the GUI
initializeGUI()
