--[[
    GUI MODULE - Simple Interface
]]

local GUI = {}

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local Settings = nil
local FSM = nil

function GUI.Init(settings, fsm)
    Settings = settings
    FSM = fsm
end

function GUI.Create()
    if playerGui:FindFirstChild("AutoFarmHub") then
        playerGui.AutoFarmHub:Destroy()
    end
    
    -- ScreenGui
    local screen = Instance.new("ScreenGui")
    screen.Name = "AutoFarmHub"
    screen.ResetOnSpawn = false
    screen.Parent = playerGui
    
    -- Main Frame
    local main = Instance.new("Frame")
    main.Size = UDim2.new(0, 260, 0, 220)
    main.Position = UDim2.new(0, 20, 0.5, -110)
    main.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    main.BorderSizePixel = 0
    main.Parent = screen
    Instance.new("UICorner", main).CornerRadius = UDim.new(0, 8)
    
    -- Title Bar
    local title = Instance.new("Frame")
    title.Size = UDim2.new(1, 0, 0, 32)
    title.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
    title.BorderSizePixel = 0
    title.Parent = main
    Instance.new("UICorner", title).CornerRadius = UDim.new(0, 8)
    
    local titleText = Instance.new("TextLabel")
    titleText.Size = UDim2.new(1, -60, 1, 0)
    titleText.Position = UDim2.new(0, 10, 0, 0)
    titleText.BackgroundTransparency = 1
    titleText.Text = "🍎 AUTO FARM FSM"
    titleText.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleText.TextSize = 13
    titleText.Font = Enum.Font.GothamBold
    titleText.TextXAlignment = Enum.TextXAlignment.Left
    titleText.Parent = title
    
    -- Close Button
    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 22, 0, 22)
    closeBtn.Position = UDim2.new(1, -27, 0.5, -11)
    closeBtn.BackgroundColor3 = Color3.fromRGB(255, 80, 80)
    closeBtn.Text = "X"
    closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeBtn.TextSize = 11
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.Parent = title
    Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 6)
    
    closeBtn.MouseButton1Click:Connect(function()
        Settings.AutoFarm = false
        FSM.Stop()
        screen:Destroy()
    end)
    
    -- Content
    local content = Instance.new("Frame")
    content.Size = UDim2.new(1, -16, 1, -40)
    content.Position = UDim2.new(0, 8, 0, 36)
    content.BackgroundTransparency = 1
    content.Parent = main
    
    -- Toggle: Auto Farm (synced with Settings.AutoFarm)
    GUI.CreateToggle(content, "Auto Farm", 0, "AutoFarm")
    
    -- Toggle: Auto Equip (synced with Settings.AutoEquip)
    GUI.CreateToggle(content, "Auto Equip", 35, "AutoEquip")
    
    -- Status Frame
    local statusFrame = Instance.new("Frame")
    statusFrame.Size = UDim2.new(1, 0, 0, 95)
    statusFrame.Position = UDim2.new(0, 0, 0, 80)
    statusFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
    statusFrame.BorderSizePixel = 0
    statusFrame.Parent = content
    Instance.new("UICorner", statusFrame).CornerRadius = UDim.new(0, 6)
    
    local statusText = Instance.new("TextLabel")
    statusText.Size = UDim2.new(1, -10, 1, -6)
    statusText.Position = UDim2.new(0, 5, 0, 3)
    statusText.BackgroundTransparency = 1
    statusText.Text = "State: IDLE\nLevel: -- | Sea: --\nIsland: --\nMob: --"
    statusText.TextColor3 = Color3.fromRGB(160, 160, 160)
    statusText.TextSize = 11
    statusText.Font = Enum.Font.Gotham
    statusText.TextXAlignment = Enum.TextXAlignment.Left
    statusText.TextYAlignment = Enum.TextYAlignment.Top
    statusText.Parent = statusFrame
    
    -- Update status loop
    task.spawn(function()
        while screen.Parent do
            statusText.Text = string.format(
                "State: %s\nLevel: %d | Sea: %d\nIsland: %s\nMob: %s",
                FSM.GetState(),
                Settings.CurrentLevel or 0,
                Settings.CurrentSea or 1,
                Settings.CurrentIsland or "--",
                Settings.CurrentMob or "--"
            )
            task.wait(0.3)
        end
    end)
    
    -- Drag
    GUI.MakeDraggable(title, main)
    
    return screen
end

function GUI.CreateToggle(parent, text, yPos, settingKey)
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, 0, 0, 30)
    container.Position = UDim2.new(0, 0, 0, yPos)
    container.BackgroundTransparency = 1
    container.Parent = parent
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.7, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.fromRGB(200, 200, 200)
    label.TextSize = 12
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = container
    
    local toggleBg = Instance.new("Frame")
    toggleBg.Size = UDim2.new(0, 42, 0, 20)
    toggleBg.Position = UDim2.new(1, -47, 0.5, -10)
    toggleBg.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
    toggleBg.Parent = container
    Instance.new("UICorner", toggleBg).CornerRadius = UDim.new(1, 0)
    
    local circle = Instance.new("Frame")
    circle.Size = UDim2.new(0, 16, 0, 16)
    circle.Position = UDim2.new(0, 2, 0.5, -8)
    circle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    circle.Parent = toggleBg
    Instance.new("UICorner", circle).CornerRadius = UDim.new(1, 0)
    
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 1, 0)
    btn.BackgroundTransparency = 1
    btn.Text = ""
    btn.Parent = toggleBg
    
    -- Read initial state from Settings
    local function UpdateVisual(enabled)
        local targetPos = enabled and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
        local targetColor = enabled and Color3.fromRGB(80, 200, 120) or Color3.fromRGB(60, 60, 70)
        TweenService:Create(circle, TweenInfo.new(0.15), {Position = targetPos}):Play()
        TweenService:Create(toggleBg, TweenInfo.new(0.15), {BackgroundColor3 = targetColor}):Play()
    end
    
    -- Initialize visual from Settings
    local initialValue = Settings[settingKey] or false
    if initialValue then
        circle.Position = UDim2.new(1, -18, 0.5, -8)
        toggleBg.BackgroundColor3 = Color3.fromRGB(80, 200, 120)
    end
    
    -- Toggle click handler
    btn.MouseButton1Click:Connect(function()
        local newValue = not Settings[settingKey]
        Settings[settingKey] = newValue
        UpdateVisual(newValue)
    end)
end

function GUI.MakeDraggable(dragFrame, targetFrame)
    local dragging, dragStart, startPos
    
    dragFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = targetFrame.Position
        end
    end)
    
    dragFrame.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            targetFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

return GUI
