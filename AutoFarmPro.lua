--[[
    ╔══════════════════════════════════════════════════════════════╗
    ║                  AUTO FARM GUI MODULE                        ║
    ║              Giao diện điều khiển Auto Farm                  ║
    ╚══════════════════════════════════════════════════════════════╝
    
    Module này cần được load SAU:
    1. BloxFruitsData.lua
    2. AutoFarmFunctions.lua
    
    Sử dụng shared data từ getgenv().AutoFarmPro
]]

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

--============================================
-- REFERENCES TỪ SHARED DATA
--============================================
local function getShared()
    return getgenv().AutoFarmPro or {
        Data = {Sea1 = {}, Sea2 = {}, Sea3 = {}},
        Functions = {},
        Settings = {},
        Connections = {}
    }
end

-- Sử dụng function để luôn lấy data mới nhất (tránh lỗi data rỗng khi load)
local function getBloxFruitsData()
    return getgenv().AutoFarmPro and getgenv().AutoFarmPro.Data or {}
end

local function getFunctions()
    return getgenv().AutoFarmPro and getgenv().AutoFarmPro.Functions or {}
end

local function getSettings()
    return getgenv().AutoFarmPro and getgenv().AutoFarmPro.Settings or {}
end

-- Backward compatibility - alias cho code cũ
local BloxFruitsData = setmetatable({}, {
    __index = function(_, key)
        return getBloxFruitsData()[key]
    end
})

local Functions = setmetatable({}, {
    __index = function(_, key)
        return getFunctions()[key]
    end
})

local Settings = setmetatable({}, {
    __index = function(_, key)
        return getSettings()[key]
    end,
    __newindex = function(_, key, value)
        local settings = getgenv().AutoFarmPro and getgenv().AutoFarmPro.Settings
        if settings then
            settings[key] = value
        end
    end
})

local attackConnection = nil

--============================================
-- TẠO GIAO DIỆN
--============================================

-- ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "AutoFarmPro"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = playerGui

-- Main Frame
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 350, 0, 450)
mainFrame.Position = UDim2.new(0, 20, 0.5, -225)
mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 10)
mainCorner.Parent = mainFrame

local mainStroke = Instance.new("UIStroke")
mainStroke.Color = Color3.fromRGB(70, 130, 180)
mainStroke.Thickness = 2
mainStroke.Parent = mainFrame

-- Shadow
local shadow = Instance.new("ImageLabel")
shadow.Name = "Shadow"
shadow.AnchorPoint = Vector2.new(0.5, 0.5)
shadow.BackgroundTransparency = 1
shadow.Position = UDim2.new(0.5, 0, 0.5, 4)
shadow.Size = UDim2.new(1, 20, 1, 20)
shadow.ZIndex = -1
shadow.Image = "rbxassetid://5028857472"
shadow.ImageColor3 = Color3.new(0, 0, 0)
shadow.ImageTransparency = 0.6
shadow.ScaleType = Enum.ScaleType.Slice
shadow.SliceCenter = Rect.new(24, 24, 276, 276)
shadow.Parent = mainFrame

--============================================
-- TITLE BAR
--============================================
local titleBar = Instance.new("Frame")
titleBar.Name = "TitleBar"
titleBar.Size = UDim2.new(1, 0, 0, 40)
titleBar.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
titleBar.BorderSizePixel = 0
titleBar.Parent = mainFrame

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 10)
titleCorner.Parent = titleBar

local titleFix = Instance.new("Frame")
titleFix.Size = UDim2.new(1, 0, 0, 15)
titleFix.Position = UDim2.new(0, 0, 1, -15)
titleFix.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
titleFix.BorderSizePixel = 0
titleFix.Parent = titleBar

local titleText = Instance.new("TextLabel")
titleText.Size = UDim2.new(1, -80, 1, 0)
titleText.Position = UDim2.new(0, 15, 0, 0)
titleText.BackgroundTransparency = 1
titleText.Text = "🎮 BLOX FRUITS AUTO FARM"
titleText.TextColor3 = Color3.fromRGB(255, 255, 255)
titleText.TextSize = 16
titleText.Font = Enum.Font.GothamBold
titleText.TextXAlignment = Enum.TextXAlignment.Left
titleText.Parent = titleBar

-- Minimize Button
local minimizeBtn = Instance.new("TextButton")
minimizeBtn.Size = UDim2.new(0, 30, 0, 30)
minimizeBtn.Position = UDim2.new(1, -70, 0, 5)
minimizeBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
minimizeBtn.Text = "—"
minimizeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
minimizeBtn.TextSize = 16
minimizeBtn.Font = Enum.Font.GothamBold
minimizeBtn.Parent = titleBar

local minimizeBtnCorner = Instance.new("UICorner")
minimizeBtnCorner.CornerRadius = UDim.new(0, 6)
minimizeBtnCorner.Parent = minimizeBtn

-- Close Button
local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 30, 0, 30)
closeBtn.Position = UDim2.new(1, -35, 0, 5)
closeBtn.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
closeBtn.Text = "×"
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.TextSize = 20
closeBtn.Font = Enum.Font.GothamBold
closeBtn.Parent = titleBar

local closeBtnCorner = Instance.new("UICorner")
closeBtnCorner.CornerRadius = UDim.new(0, 6)
closeBtnCorner.Parent = closeBtn

--============================================
-- TAB BUTTONS
--============================================
local tabContainer = Instance.new("Frame")
tabContainer.Size = UDim2.new(1, -20, 0, 35)
tabContainer.Position = UDim2.new(0, 10, 0, 50)
tabContainer.BackgroundTransparency = 1
tabContainer.Parent = mainFrame

local tabLayout = Instance.new("UIListLayout")
tabLayout.FillDirection = Enum.FillDirection.Horizontal
tabLayout.Padding = UDim.new(0, 5)
tabLayout.Parent = tabContainer

local function createTabButton(name, text, isActive)
    local btn = Instance.new("TextButton")
    btn.Name = name
    btn.Size = UDim2.new(0, 105, 1, 0)
    btn.BackgroundColor3 = isActive and Color3.fromRGB(70, 130, 180) or Color3.fromRGB(45, 45, 55)
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextSize = 13
    btn.Font = Enum.Font.GothamBold
    btn.Parent = tabContainer
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = btn
    
    return btn
end

local tabFarm = createTabButton("TabFarm", "🌾 Farm", true)
local tabQuest = createTabButton("TabQuest", "📋 Quest", false)
local tabSettings = createTabButton("TabSettings", "⚙️ Settings", false)

--============================================
-- CONTENT FRAMES
--============================================
local contentContainer = Instance.new("Frame")
contentContainer.Size = UDim2.new(1, -20, 1, -100)
contentContainer.Position = UDim2.new(0, 10, 0, 95)
contentContainer.BackgroundTransparency = 1
contentContainer.Parent = mainFrame

--============================================
-- FARM TAB CONTENT
--============================================
local farmContent = Instance.new("Frame")
farmContent.Name = "FarmContent"
farmContent.Size = UDim2.new(1, 0, 1, 0)
farmContent.BackgroundTransparency = 1
farmContent.Visible = true
farmContent.Parent = contentContainer

-- Toggle Function
local function createToggle(parent, name, text, yPos, callback)
    local container = Instance.new("Frame")
    container.Name = name
    container.Size = UDim2.new(1, 0, 0, 45)
    container.Position = UDim2.new(0, 0, 0, yPos)
    container.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    container.BorderSizePixel = 0
    container.Parent = parent
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = container
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.65, 0, 1, 0)
    label.Position = UDim2.new(0, 15, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.fromRGB(220, 220, 220)
    label.TextSize = 14
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = container
    
    local toggleBg = Instance.new("Frame")
    toggleBg.Name = "ToggleBg"
    toggleBg.Size = UDim2.new(0, 55, 0, 28)
    toggleBg.Position = UDim2.new(1, -70, 0.5, -14)
    toggleBg.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
    toggleBg.BorderSizePixel = 0
    toggleBg.Parent = container
    
    local toggleBgCorner = Instance.new("UICorner")
    toggleBgCorner.CornerRadius = UDim.new(1, 0)
    toggleBgCorner.Parent = toggleBg
    
    local circle = Instance.new("Frame")
    circle.Name = "Circle"
    circle.Size = UDim2.new(0, 22, 0, 22)
    circle.Position = UDim2.new(0, 3, 0.5, -11)
    circle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    circle.BorderSizePixel = 0
    circle.Parent = toggleBg
    
    local circleCorner = Instance.new("UICorner")
    circleCorner.CornerRadius = UDim.new(1, 0)
    circleCorner.Parent = circle
    
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 1, 0)
    btn.BackgroundTransparency = 1
    btn.Text = ""
    btn.Parent = toggleBg
    
    local enabled = false
    
    btn.MouseButton1Click:Connect(function()
        enabled = not enabled
        local targetBg = enabled and Color3.fromRGB(0, 180, 100) or Color3.fromRGB(60, 60, 70)
        local targetPos = enabled and UDim2.new(1, -25, 0.5, -11) or UDim2.new(0, 3, 0.5, -11)
        
        TweenService:Create(toggleBg, TweenInfo.new(0.2), {BackgroundColor3 = targetBg}):Play()
        TweenService:Create(circle, TweenInfo.new(0.2), {Position = targetPos}):Play()
        
        if callback then
            callback(enabled)
        end
    end)
    
    return container, btn, enabled
end

-- Farm Toggles
createToggle(farmContent, "AutoFarmToggle", "🎯 Auto Farm", 0, function(enabled)
    Settings.AutoFarm = enabled
    print("Auto Farm:", enabled and "BẬT" or "TẮT")
end)

createToggle(farmContent, "AutoQuestToggle", "📜 Auto Quest", 55, function(enabled)
    Settings.AutoQuest = enabled
    print("Auto Quest:", enabled and "BẬT" or "TẮT")
end)

createToggle(farmContent, "BringMobToggle", "🧲 Bring Mob", 110, function(enabled)
    Settings.BringMob = enabled
    print("Bring Mob:", enabled and "BẬT" or "TẮT")
end)

createToggle(farmContent, "KillAuraToggle", "⚔️ Kill Aura", 165, function(enabled)
    Settings.KillAura = enabled
    print("Kill Aura:", enabled and "BẬT" or "TẮT")
end)

-- Status Display
local statusFrame = Instance.new("Frame")
statusFrame.Size = UDim2.new(1, 0, 0, 80)
statusFrame.Position = UDim2.new(0, 0, 0, 230)
statusFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
statusFrame.BorderSizePixel = 0
statusFrame.Parent = farmContent

local statusCorner = Instance.new("UICorner")
statusCorner.CornerRadius = UDim.new(0, 8)
statusCorner.Parent = statusFrame

local statusTitle = Instance.new("TextLabel")
statusTitle.Size = UDim2.new(1, 0, 0, 25)
statusTitle.BackgroundTransparency = 1
statusTitle.Text = "📊 TRẠNG THÁI"
statusTitle.TextColor3 = Color3.fromRGB(70, 130, 180)
statusTitle.TextSize = 12
statusTitle.Font = Enum.Font.GothamBold
statusTitle.Parent = statusFrame

local statusText = Instance.new("TextLabel")
statusText.Name = "StatusText"
statusText.Size = UDim2.new(1, -20, 1, -30)
statusText.Position = UDim2.new(0, 10, 0, 25)
statusText.BackgroundTransparency = 1
statusText.Text = "Island: Chưa chọn\nMob: Chưa chọn\nLevel: --"
statusText.TextColor3 = Color3.fromRGB(180, 180, 180)
statusText.TextSize = 12
statusText.Font = Enum.Font.Gotham
statusText.TextXAlignment = Enum.TextXAlignment.Left
statusText.TextYAlignment = Enum.TextYAlignment.Top
statusText.Parent = statusFrame

--============================================
-- QUEST TAB CONTENT
--============================================
local questContent = Instance.new("Frame")
questContent.Name = "QuestContent"
questContent.Size = UDim2.new(1, 0, 1, 0)
questContent.BackgroundTransparency = 1
questContent.Visible = false
questContent.Parent = contentContainer

-- Sea Selector
local seaLabel = Instance.new("TextLabel")
seaLabel.Size = UDim2.new(1, 0, 0, 25)
seaLabel.BackgroundTransparency = 1
seaLabel.Text = "🌊 CHỌN VÙNG BIỂN"
seaLabel.TextColor3 = Color3.fromRGB(70, 130, 180)
seaLabel.TextSize = 14
seaLabel.Font = Enum.Font.GothamBold
seaLabel.TextXAlignment = Enum.TextXAlignment.Left
seaLabel.Parent = questContent

local seaContainer = Instance.new("Frame")
seaContainer.Size = UDim2.new(1, 0, 0, 35)
seaContainer.Position = UDim2.new(0, 0, 0, 30)
seaContainer.BackgroundTransparency = 1
seaContainer.Parent = questContent

local seaLayout = Instance.new("UIListLayout")
seaLayout.FillDirection = Enum.FillDirection.Horizontal
seaLayout.Padding = UDim.new(0, 5)
seaLayout.Parent = seaContainer

local seaButtons = {}

local function createSeaButton(seaNum)
    local btn = Instance.new("TextButton")
    btn.Name = "Sea" .. seaNum
    btn.Size = UDim2.new(0, 105, 1, 0)
    btn.BackgroundColor3 = seaNum == 1 and Color3.fromRGB(70, 130, 180) or Color3.fromRGB(45, 45, 55)
    btn.Text = "Sea " .. seaNum
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextSize = 13
    btn.Font = Enum.Font.GothamBold
    btn.Parent = seaContainer
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = btn
    
    seaButtons[seaNum] = btn
    return btn
end

for i = 1, 3 do
    createSeaButton(i)
end

-- Island Dropdown
local islandLabel = Instance.new("TextLabel")
islandLabel.Size = UDim2.new(1, 0, 0, 25)
islandLabel.Position = UDim2.new(0, 0, 0, 75)
islandLabel.BackgroundTransparency = 1
islandLabel.Text = "🏝️ CHỌN ĐẢO"
islandLabel.TextColor3 = Color3.fromRGB(70, 130, 180)
islandLabel.TextSize = 14
islandLabel.Font = Enum.Font.GothamBold
islandLabel.TextXAlignment = Enum.TextXAlignment.Left
islandLabel.Parent = questContent

local islandDropdown = Instance.new("Frame")
islandDropdown.Size = UDim2.new(1, 0, 0, 40)
islandDropdown.Position = UDim2.new(0, 0, 0, 100)
islandDropdown.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
islandDropdown.BorderSizePixel = 0
islandDropdown.Parent = questContent

local islandCorner = Instance.new("UICorner")
islandCorner.CornerRadius = UDim.new(0, 8)
islandCorner.Parent = islandDropdown

local islandSelected = Instance.new("TextLabel")
islandSelected.Name = "Selected"
islandSelected.Size = UDim2.new(1, -40, 1, 0)
islandSelected.Position = UDim2.new(0, 15, 0, 0)
islandSelected.BackgroundTransparency = 1
islandSelected.Text = "Chọn đảo..."
islandSelected.TextColor3 = Color3.fromRGB(180, 180, 180)
islandSelected.TextSize = 13
islandSelected.Font = Enum.Font.Gotham
islandSelected.TextXAlignment = Enum.TextXAlignment.Left
islandSelected.Parent = islandDropdown

local islandArrow = Instance.new("TextLabel")
islandArrow.Size = UDim2.new(0, 30, 1, 0)
islandArrow.Position = UDim2.new(1, -35, 0, 0)
islandArrow.BackgroundTransparency = 1
islandArrow.Text = "▼"
islandArrow.TextColor3 = Color3.fromRGB(150, 150, 150)
islandArrow.TextSize = 12
islandArrow.Font = Enum.Font.GothamBold
islandArrow.Parent = islandDropdown

local islandBtn = Instance.new("TextButton")
islandBtn.Size = UDim2.new(1, 0, 1, 0)
islandBtn.BackgroundTransparency = 1
islandBtn.Text = ""
islandBtn.Parent = islandDropdown

-- Island Options Container (hidden by default)
local islandOptions = Instance.new("ScrollingFrame")
islandOptions.Name = "Options"
islandOptions.Size = UDim2.new(1, 0, 0, 150)
islandOptions.Position = UDim2.new(0, 0, 1, 5)
islandOptions.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
islandOptions.BorderSizePixel = 0
islandOptions.ScrollBarThickness = 4
islandOptions.Visible = false
islandOptions.ZIndex = 10
islandOptions.Parent = islandDropdown

local islandOptionsCorner = Instance.new("UICorner")
islandOptionsCorner.CornerRadius = UDim.new(0, 8)
islandOptionsCorner.Parent = islandOptions

local islandOptionsLayout = Instance.new("UIListLayout")
islandOptionsLayout.Padding = UDim.new(0, 2)
islandOptionsLayout.Parent = islandOptions

-- Mob Dropdown
local mobLabel = Instance.new("TextLabel")
mobLabel.Size = UDim2.new(1, 0, 0, 25)
mobLabel.Position = UDim2.new(0, 0, 0, 150)
mobLabel.BackgroundTransparency = 1
mobLabel.Text = "👾 CHỌN QUÁI"
mobLabel.TextColor3 = Color3.fromRGB(70, 130, 180)
mobLabel.TextSize = 14
mobLabel.Font = Enum.Font.GothamBold
mobLabel.TextXAlignment = Enum.TextXAlignment.Left
mobLabel.Parent = questContent

local mobDropdown = Instance.new("Frame")
mobDropdown.Size = UDim2.new(1, 0, 0, 40)
mobDropdown.Position = UDim2.new(0, 0, 0, 175)
mobDropdown.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
mobDropdown.BorderSizePixel = 0
mobDropdown.Parent = questContent

local mobCorner = Instance.new("UICorner")
mobCorner.CornerRadius = UDim.new(0, 8)
mobCorner.Parent = mobDropdown

local mobSelected = Instance.new("TextLabel")
mobSelected.Name = "Selected"
mobSelected.Size = UDim2.new(1, -40, 1, 0)
mobSelected.Position = UDim2.new(0, 15, 0, 0)
mobSelected.BackgroundTransparency = 1
mobSelected.Text = "Chọn quái..."
mobSelected.TextColor3 = Color3.fromRGB(180, 180, 180)
mobSelected.TextSize = 13
mobSelected.Font = Enum.Font.Gotham
mobSelected.TextXAlignment = Enum.TextXAlignment.Left
mobSelected.Parent = mobDropdown

local mobArrow = Instance.new("TextLabel")
mobArrow.Size = UDim2.new(0, 30, 1, 0)
mobArrow.Position = UDim2.new(1, -35, 0, 0)
mobArrow.BackgroundTransparency = 1
mobArrow.Text = "▼"
mobArrow.TextColor3 = Color3.fromRGB(150, 150, 150)
mobArrow.TextSize = 12
mobArrow.Font = Enum.Font.GothamBold
mobArrow.Parent = mobDropdown

local mobBtn = Instance.new("TextButton")
mobBtn.Size = UDim2.new(1, 0, 1, 0)
mobBtn.BackgroundTransparency = 1
mobBtn.Text = ""
mobBtn.Parent = mobDropdown

-- Mob Options Container
local mobOptions = Instance.new("ScrollingFrame")
mobOptions.Name = "Options"
mobOptions.Size = UDim2.new(1, 0, 0, 120)
mobOptions.Position = UDim2.new(0, 1, 1, 5)
mobOptions.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
mobOptions.BorderSizePixel = 0
mobOptions.ScrollBarThickness = 4
mobOptions.Visible = false
mobOptions.ZIndex = 10
mobOptions.Parent = mobDropdown

local mobOptionsCorner = Instance.new("UICorner")
mobOptionsCorner.CornerRadius = UDim.new(0, 8)
mobOptionsCorner.Parent = mobOptions

local mobOptionsLayout = Instance.new("UIListLayout")
mobOptionsLayout.Padding = UDim.new(0, 2)
mobOptionsLayout.Parent = mobOptions

-- Quest Info
local questInfoFrame = Instance.new("Frame")
questInfoFrame.Size = UDim2.new(1, 0, 0, 60)
questInfoFrame.Position = UDim2.new(0, 0, 0, 230)
questInfoFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
questInfoFrame.BorderSizePixel = 0
questInfoFrame.Parent = questContent

local questInfoCorner = Instance.new("UICorner")
questInfoCorner.CornerRadius = UDim.new(0, 8)
questInfoCorner.Parent = questInfoFrame

local questInfoText = Instance.new("TextLabel")
questInfoText.Name = "QuestInfo"
questInfoText.Size = UDim2.new(1, -20, 1, 0)
questInfoText.Position = UDim2.new(0, 10, 0, 0)
questInfoText.BackgroundTransparency = 1
questInfoText.Text = "📌 Chọn đảo và quái để bắt đầu farm\n💡 Auto Quest sẽ tự động nhận nhiệm vụ"
questInfoText.TextColor3 = Color3.fromRGB(150, 150, 150)
questInfoText.TextSize = 12
questInfoText.Font = Enum.Font.Gotham
questInfoText.TextXAlignment = Enum.TextXAlignment.Left
questInfoText.TextWrapped = true
questInfoText.Parent = questInfoFrame

--============================================
-- SETTINGS TAB CONTENT
--============================================
local settingsContent = Instance.new("Frame")
settingsContent.Name = "SettingsContent"
settingsContent.Size = UDim2.new(1, 0, 1, 0)
settingsContent.BackgroundTransparency = 1
settingsContent.Visible = false
settingsContent.Parent = contentContainer

local settingsTitle = Instance.new("TextLabel")
settingsTitle.Size = UDim2.new(1, 0, 0, 25)
settingsTitle.BackgroundTransparency = 1
settingsTitle.Text = "⚙️ CÀI ĐẶT"
settingsTitle.TextColor3 = Color3.fromRGB(70, 130, 180)
settingsTitle.TextSize = 14
settingsTitle.Font = Enum.Font.GothamBold
settingsTitle.TextXAlignment = Enum.TextXAlignment.Left
settingsTitle.Parent = settingsContent

-- Farm Distance Slider
local distanceLabel = Instance.new("TextLabel")
distanceLabel.Size = UDim2.new(1, 0, 0, 20)
distanceLabel.Position = UDim2.new(0, 0, 0, 35)
distanceLabel.BackgroundTransparency = 1
distanceLabel.Text = "Khoảng cách Farm: 15"
distanceLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
distanceLabel.TextSize = 13
distanceLabel.Font = Enum.Font.Gotham
distanceLabel.TextXAlignment = Enum.TextXAlignment.Left
distanceLabel.Parent = settingsContent

-- Attack Range Slider
local rangeLabel = Instance.new("TextLabel")
rangeLabel.Size = UDim2.new(1, 0, 0, 20)
rangeLabel.Position = UDim2.new(0, 0, 0, 85)
rangeLabel.BackgroundTransparency = 1
rangeLabel.Text = "Phạm vi tấn công: 50"
rangeLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
rangeLabel.TextSize = 13
rangeLabel.Font = Enum.Font.Gotham
rangeLabel.TextXAlignment = Enum.TextXAlignment.Left
rangeLabel.Parent = settingsContent

-- Credits
local credits = Instance.new("TextLabel")
credits.Size = UDim2.new(1, 0, 0, 50)
credits.Position = UDim2.new(0, 0, 1, -60)
credits.BackgroundTransparency = 1
credits.Text = "🔧 Auto Farm Pro v1.0\n📌 Hỗ trợ Sea 1 - Sea 3"
credits.TextColor3 = Color3.fromRGB(100, 100, 100)
credits.TextSize = 11
credits.Font = Enum.Font.Gotham
credits.Parent = settingsContent

--============================================
-- TAB SWITCHING LOGIC
--============================================
local function switchTab(tabName)
    -- Reset all tabs
    tabFarm.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
    tabQuest.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
    tabSettings.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
    
    farmContent.Visible = false
    questContent.Visible = false
    settingsContent.Visible = false
    
    -- Activate selected tab
    if tabName == "Farm" then
        tabFarm.BackgroundColor3 = Color3.fromRGB(70, 130, 180)
        farmContent.Visible = true
    elseif tabName == "Quest" then
        tabQuest.BackgroundColor3 = Color3.fromRGB(70, 130, 180)
        questContent.Visible = true
    elseif tabName == "Settings" then
        tabSettings.BackgroundColor3 = Color3.fromRGB(70, 130, 180)
        settingsContent.Visible = true
    end
end

tabFarm.MouseButton1Click:Connect(function() switchTab("Farm") end)
tabQuest.MouseButton1Click:Connect(function() switchTab("Quest") end)
tabSettings.MouseButton1Click:Connect(function() switchTab("Settings") end)

--============================================
-- DROPDOWN LOGIC
--============================================
local function populateIslands(seaNum)
    -- Clear existing options
    for _, child in pairs(islandOptions:GetChildren()) do
        if child:IsA("TextButton") then
            child:Destroy()
        end
    end
    
    local seaData = BloxFruitsData["Sea" .. seaNum]
    if not seaData then return end
    
    for i, islandData in ipairs(seaData) do
        local option = Instance.new("TextButton")
        option.Size = UDim2.new(1, -10, 0, 30)
        option.Position = UDim2.new(0, 5, 0, 0)
        option.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
        option.Text = islandData.Island .. " (Lv." .. islandData.LevelRange[1] .. "-" .. islandData.LevelRange[2] .. ")"
        option.TextColor3 = Color3.fromRGB(220, 220, 220)
        option.TextSize = 12
        option.Font = Enum.Font.Gotham
        option.ZIndex = 11
        option.Parent = islandOptions
        
        local optionCorner = Instance.new("UICorner")
        optionCorner.CornerRadius = UDim.new(0, 4)
        optionCorner.Parent = option
        
        option.MouseButton1Click:Connect(function()
            islandSelected.Text = islandData.Island
            islandSelected.TextColor3 = Color3.fromRGB(255, 255, 255)
            Settings.SelectedIsland = islandData
            islandOptions.Visible = false
            
            -- Populate mobs for this island
            populateMobs(islandData)
            
            -- Update status
            updateStatus()
        end)
    end
    
    islandOptions.CanvasSize = UDim2.new(0, 0, 0, #seaData * 32)
end

local function populateMobs(islandData)
    -- Clear existing options
    for _, child in pairs(mobOptions:GetChildren()) do
        if child:IsA("TextButton") then
            child:Destroy()
        end
    end
    
    if not islandData or not islandData.Mobs then return end
    
    for i, mobData in ipairs(islandData.Mobs) do
        local option = Instance.new("TextButton")
        option.Size = UDim2.new(1, -10, 0, 30)
        option.Position = UDim2.new(0, 5, 0, 0)
        option.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
        option.Text = mobData.Name .. " (Lv." .. mobData.Level .. ")"
        option.TextColor3 = Color3.fromRGB(220, 220, 220)
        option.TextSize = 12
        option.Font = Enum.Font.Gotham
        option.ZIndex = 11
        option.Parent = mobOptions
        
        local optionCorner = Instance.new("UICorner")
        optionCorner.CornerRadius = UDim.new(0, 4)
        optionCorner.Parent = option
        
        option.MouseButton1Click:Connect(function()
            mobSelected.Text = mobData.Name .. " (Lv." .. mobData.Level .. ")"
            mobSelected.TextColor3 = Color3.fromRGB(255, 255, 255)
            Settings.SelectedMob = mobData
            mobOptions.Visible = false
            
            -- Update status
            updateStatus()
        end)
    end
    
    mobOptions.CanvasSize = UDim2.new(0, 0, 0, #islandData.Mobs * 32)
end

-- Toggle dropdowns
islandBtn.MouseButton1Click:Connect(function()
    islandOptions.Visible = not islandOptions.Visible
    mobOptions.Visible = false
end)

mobBtn.MouseButton1Click:Connect(function()
    mobOptions.Visible = not mobOptions.Visible
    islandOptions.Visible = false
end)

-- Sea button clicks
for seaNum, btn in pairs(seaButtons) do
    btn.MouseButton1Click:Connect(function()
        Settings.CurrentSea = seaNum
        
        -- Update button colors
        for num, b in pairs(seaButtons) do
            b.BackgroundColor3 = num == seaNum and Color3.fromRGB(70, 130, 180) or Color3.fromRGB(45, 45, 55)
        end
        
        -- Reset selections
        islandSelected.Text = "Chọn đảo..."
        islandSelected.TextColor3 = Color3.fromRGB(180, 180, 180)
        mobSelected.Text = "Chọn quái..."
        mobSelected.TextColor3 = Color3.fromRGB(180, 180, 180)
        Settings.SelectedIsland = nil
        Settings.SelectedMob = nil
        
        -- Populate islands
        populateIslands(seaNum)
    end)
end

-- Initialize with Sea 1
populateIslands(1)

--============================================
-- UPDATE STATUS
--============================================
function updateStatus()
    local island = Settings.SelectedIsland and Settings.SelectedIsland.Island or "Chưa chọn"
    local mob = Settings.SelectedMob and Settings.SelectedMob.Name or "Chưa chọn"
    local level = Settings.SelectedMob and Settings.SelectedMob.Level or "--"
    
    statusText.Text = "Island: " .. island .. "\nMob: " .. mob .. "\nLevel: " .. level
end

--============================================
-- AUTO FARM LOGIC (Sử dụng Functions Module)
--============================================
local function startAutoFarm()
    if Functions and Functions.StartAutoFarm then
        Functions.StartAutoFarm()
    end
end

local function stopAutoFarm()
    if Functions and Functions.StopAutoFarm then
        Functions.StopAutoFarm()
    end
end

--============================================
-- DRAG FUNCTIONALITY
--============================================
local dragging = false
local dragInput, dragStart, startPos

titleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = mainFrame.Position
        
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

titleBar.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

game:GetService("UserInputService").InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

--============================================
-- BUTTON EVENTS
--============================================
local isMinimized = false

minimizeBtn.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized
    
    if isMinimized then
        TweenService:Create(mainFrame, TweenInfo.new(0.3), {Size = UDim2.new(0, 350, 0, 40)}):Play()
        contentContainer.Visible = false
        tabContainer.Visible = false
    else
        TweenService:Create(mainFrame, TweenInfo.new(0.3), {Size = UDim2.new(0, 350, 0, 450)}):Play()
        wait(0.3)
        contentContainer.Visible = true
        tabContainer.Visible = true
    end
end)

closeBtn.MouseButton1Click:Connect(function()
    stopAutoFarm()
    screenGui:Destroy()
end)

-- Hover effects
local function addHover(btn, normalColor, hoverColor)
    btn.MouseEnter:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = hoverColor}):Play()
    end)
    btn.MouseLeave:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = normalColor}):Play()
    end)
end

addHover(closeBtn, Color3.fromRGB(200, 60, 60), Color3.fromRGB(230, 70, 70))
addHover(minimizeBtn, Color3.fromRGB(60, 60, 70), Color3.fromRGB(80, 80, 90))

--============================================
-- START FARM WHEN SETTINGS CHANGE
--============================================
spawn(function()
    while wait(0.5) do
        if Settings.AutoFarm and Settings.SelectedMob then
            startAutoFarm()
        else
            stopAutoFarm()
        end
    end
end)

print("✅ Auto Farm GUI đã được tải thành công!")
print("📌 Hỗ trợ: Sea 1, Sea 2, Sea 3")
print("🎮 Chọn đảo và quái trong tab Quest để bắt đầu!")

-- Return để Main.lua biết đã load xong
return true
