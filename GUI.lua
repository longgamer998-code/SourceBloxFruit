--[[
    GUI MODULE - Giao diện Auto Farm
]]

local GUI = {}

-- Services
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- References
local Settings, Functions

function GUI.Init(settings, functions)
    Settings = settings
    Functions = functions
end

--=== TẠO GUI ===--
function GUI.Create()
    -- Xóa GUI cũ nếu có
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
    main.Name = "Main"
    main.Size = UDim2.new(0, 300, 0, 380)
    main.Position = UDim2.new(0, 20, 0.5, -190)
    main.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    main.BorderSizePixel = 0
    main.Parent = screen
    
    Instance.new("UICorner", main).CornerRadius = UDim.new(0, 8)
    
    -- Title Bar
    local title = Instance.new("Frame")
    title.Name = "TitleBar"
    title.Size = UDim2.new(1, 0, 0, 35)
    title.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
    title.BorderSizePixel = 0
    title.Parent = main
    
    Instance.new("UICorner", title).CornerRadius = UDim.new(0, 8)
    
    local titleText = Instance.new("TextLabel")
    titleText.Size = UDim2.new(1, -70, 1, 0)
    titleText.Position = UDim2.new(0, 10, 0, 0)
    titleText.BackgroundTransparency = 1
    titleText.Text = "🍎 AUTO FARM HUB"
    titleText.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleText.TextSize = 14
    titleText.Font = Enum.Font.GothamBold
    titleText.TextXAlignment = Enum.TextXAlignment.Left
    titleText.Parent = title
    
    -- Close Button
    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 25, 0, 25)
    closeBtn.Position = UDim2.new(1, -30, 0.5, -12)
    closeBtn.BackgroundColor3 = Color3.fromRGB(255, 80, 80)
    closeBtn.Text = "X"
    closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeBtn.TextSize = 12
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.Parent = title
    Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 6)
    
    closeBtn.MouseButton1Click:Connect(function()
        Functions.StopFarm()
        screen:Destroy()
    end)
    
    -- Minimize Button
    local minBtn = Instance.new("TextButton")
    minBtn.Size = UDim2.new(0, 25, 0, 25)
    minBtn.Position = UDim2.new(1, -60, 0.5, -12)
    minBtn.BackgroundColor3 = Color3.fromRGB(255, 180, 50)
    minBtn.Text = "—"
    minBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    minBtn.TextSize = 12
    minBtn.Font = Enum.Font.GothamBold
    minBtn.Parent = title
    Instance.new("UICorner", minBtn).CornerRadius = UDim.new(0, 6)
    
    local minimized = false
    minBtn.MouseButton1Click:Connect(function()
        minimized = not minimized
        main.Size = minimized and UDim2.new(0, 300, 0, 35) or UDim2.new(0, 300, 0, 380)
    end)
    
    -- Content
    local content = Instance.new("Frame")
    content.Name = "Content"
    content.Size = UDim2.new(1, -20, 1, -45)
    content.Position = UDim2.new(0, 10, 0, 40)
    content.BackgroundTransparency = 1
    content.Parent = main
    
    --=== SECTION: AUTO FARM ===--
    local farmSection = GUI.CreateSection(content, "🎯 AUTO FARM", 0)
    
    GUI.CreateToggle(farmSection, "Auto Farm", 0, function(enabled)
        Settings.AutoFarm = enabled
        if enabled then
            Functions.StartFarm()
        else
            Functions.StopFarm()
        end
    end)
    
    GUI.CreateToggle(farmSection, "Auto Quest", 35, function(enabled)
        Settings.AutoQuest = enabled
    end)
    
    GUI.CreateToggle(farmSection, "Kill Aura", 70, function(enabled)
        Settings.KillAura = enabled
    end)
    
    GUI.CreateToggle(farmSection, "Bring Mob", 105, function(enabled)
        Settings.BringMob = enabled
    end)
    
    --=== SECTION: EQUIPMENT ===--
    local equipSection = GUI.CreateSection(content, "🗡️ EQUIPMENT", 160)
    
    GUI.CreateToggle(equipSection, "Auto Equip", 0, function(enabled)
        Settings.AutoEquip = enabled
    end)
    
    GUI.CreateDropdown(equipSection, "Weapon", 35, function(selected)
        Settings.SelectedWeapon = selected
    end)
    
    --=== SECTION: STATUS ===--
    local statusSection = GUI.CreateSection(content, "📊 STATUS", 250)
    
    local statusText = Instance.new("TextLabel")
    statusText.Name = "StatusText"
    statusText.Size = UDim2.new(1, -10, 0, 60)
    statusText.Position = UDim2.new(0, 5, 0, 5)
    statusText.BackgroundTransparency = 1
    statusText.Text = "Level: -- | Sea: --\nIsland: --\nMob: --"
    statusText.TextColor3 = Color3.fromRGB(180, 180, 180)
    statusText.TextSize = 11
    statusText.Font = Enum.Font.Gotham
    statusText.TextXAlignment = Enum.TextXAlignment.Left
    statusText.TextYAlignment = Enum.TextYAlignment.Top
    statusText.Parent = statusSection
    
    -- Update status loop
    spawn(function()
        while screen.Parent do
            statusText.Text = string.format(
                "Level: %d | Sea: %d\nIsland: %s\nMob: %s",
                Settings.CurrentLevel or 0,
                Settings.CurrentSea or 1,
                Settings.CurrentIsland or "--",
                Settings.CurrentMob or "--"
            )
            wait(0.5)
        end
    end)
    
    --=== DRAG ===--
    GUI.MakeDraggable(title, main)
    
    return screen
end

--=== HELPER FUNCTIONS ===--

function GUI.CreateSection(parent, title, yPos)
    local section = Instance.new("Frame")
    section.Size = UDim2.new(1, 0, 0, 80)
    section.Position = UDim2.new(0, 0, 0, yPos)
    section.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
    section.BorderSizePixel = 0
    section.Parent = parent
    Instance.new("UICorner", section).CornerRadius = UDim.new(0, 6)
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 0, 25)
    label.BackgroundTransparency = 1
    label.Text = "  " .. title
    label.TextColor3 = Color3.fromRGB(100, 150, 255)
    label.TextSize = 12
    label.Font = Enum.Font.GothamBold
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = section
    
    local content = Instance.new("Frame")
    content.Name = "Content"
    content.Size = UDim2.new(1, -10, 1, -30)
    content.Position = UDim2.new(0, 5, 0, 25)
    content.BackgroundTransparency = 1
    content.Parent = section
    
    return content
end

function GUI.CreateToggle(parent, text, yPos, callback)
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
    toggleBg.Size = UDim2.new(0, 45, 0, 22)
    toggleBg.Position = UDim2.new(1, -50, 0.5, -11)
    toggleBg.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
    toggleBg.Parent = container
    Instance.new("UICorner", toggleBg).CornerRadius = UDim.new(1, 0)
    
    local circle = Instance.new("Frame")
    circle.Size = UDim2.new(0, 18, 0, 18)
    circle.Position = UDim2.new(0, 2, 0.5, -9)
    circle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    circle.Parent = toggleBg
    Instance.new("UICorner", circle).CornerRadius = UDim.new(1, 0)
    
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 1, 0)
    btn.BackgroundTransparency = 1
    btn.Text = ""
    btn.Parent = toggleBg
    
    local enabled = false
    btn.MouseButton1Click:Connect(function()
        enabled = not enabled
        
        local targetPos = enabled and UDim2.new(1, -20, 0.5, -9) or UDim2.new(0, 2, 0.5, -9)
        local targetColor = enabled and Color3.fromRGB(80, 200, 120) or Color3.fromRGB(60, 60, 70)
        
        TweenService:Create(circle, TweenInfo.new(0.2), {Position = targetPos}):Play()
        TweenService:Create(toggleBg, TweenInfo.new(0.2), {BackgroundColor3 = targetColor}):Play()
        
        callback(enabled)
    end)
end

function GUI.CreateDropdown(parent, text, yPos, callback)
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, 0, 0, 30)
    container.Position = UDim2.new(0, 0, 0, yPos)
    container.BackgroundTransparency = 1
    container.Parent = parent
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.35, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = text .. ":"
    label.TextColor3 = Color3.fromRGB(200, 200, 200)
    label.TextSize = 12
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = container
    
    local dropdown = Instance.new("Frame")
    dropdown.Size = UDim2.new(0.6, 0, 0, 25)
    dropdown.Position = UDim2.new(0.38, 0, 0.5, -12)
    dropdown.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
    dropdown.Parent = container
    Instance.new("UICorner", dropdown).CornerRadius = UDim.new(0, 4)
    
    local selected = Instance.new("TextLabel")
    selected.Name = "Selected"
    selected.Size = UDim2.new(1, -25, 1, 0)
    selected.Position = UDim2.new(0, 8, 0, 0)
    selected.BackgroundTransparency = 1
    selected.Text = "Auto"
    selected.TextColor3 = Color3.fromRGB(180, 180, 180)
    selected.TextSize = 11
    selected.Font = Enum.Font.Gotham
    selected.TextXAlignment = Enum.TextXAlignment.Left
    selected.Parent = dropdown
    
    local arrow = Instance.new("TextLabel")
    arrow.Size = UDim2.new(0, 20, 1, 0)
    arrow.Position = UDim2.new(1, -22, 0, 0)
    arrow.BackgroundTransparency = 1
    arrow.Text = "▼"
    arrow.TextColor3 = Color3.fromRGB(150, 150, 150)
    arrow.TextSize = 10
    arrow.Parent = dropdown
    
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 1, 0)
    btn.BackgroundTransparency = 1
    btn.Text = ""
    btn.Parent = dropdown
    
    local options = Instance.new("Frame")
    options.Name = "Options"
    options.Size = UDim2.new(1, 0, 0, 0)
    options.Position = UDim2.new(0, 0, 1, 2)
    options.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    options.Visible = false
    options.ZIndex = 10
    options.Parent = dropdown
    Instance.new("UICorner", options).CornerRadius = UDim.new(0, 4)
    
    local listLayout = Instance.new("UIListLayout")
    listLayout.Parent = options
    
    local isOpen = false
    
    local function refreshOptions()
        for _, child in pairs(options:GetChildren()) do
            if child:IsA("TextButton") then child:Destroy() end
        end
        
        -- Option: Auto
        local autoOpt = Instance.new("TextButton")
        autoOpt.Size = UDim2.new(1, 0, 0, 25)
        autoOpt.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
        autoOpt.Text = "  Auto"
        autoOpt.TextColor3 = Color3.fromRGB(100, 255, 100)
        autoOpt.TextSize = 11
        autoOpt.Font = Enum.Font.Gotham
        autoOpt.TextXAlignment = Enum.TextXAlignment.Left
        autoOpt.ZIndex = 11
        autoOpt.Parent = options
        
        autoOpt.MouseButton1Click:Connect(function()
            selected.Text = "Auto"
            options.Visible = false
            isOpen = false
            callback(nil)
        end)
        
        -- Lấy weapons từ Backpack
        local backpack = player:FindFirstChild("Backpack")
        if backpack then
            for _, tool in pairs(backpack:GetChildren()) do
                if tool:IsA("Tool") then
                    local opt = Instance.new("TextButton")
                    opt.Size = UDim2.new(1, 0, 0, 25)
                    opt.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
                    opt.Text = "  " .. tool.Name
                    opt.TextColor3 = Color3.fromRGB(200, 200, 200)
                    opt.TextSize = 11
                    opt.Font = Enum.Font.Gotham
                    opt.TextXAlignment = Enum.TextXAlignment.Left
                    opt.ZIndex = 11
                    opt.Parent = options
                    
                    opt.MouseButton1Click:Connect(function()
                        selected.Text = tool.Name
                        options.Visible = false
                        isOpen = false
                        callback(tool.Name)
                    end)
                end
            end
        end
        
        options.Size = UDim2.new(1, 0, 0, listLayout.AbsoluteContentSize.Y)
    end
    
    btn.MouseButton1Click:Connect(function()
        isOpen = not isOpen
        options.Visible = isOpen
        arrow.Text = isOpen and "▲" or "▼"
        if isOpen then refreshOptions() end
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
            targetFrame.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)
end

return GUI
