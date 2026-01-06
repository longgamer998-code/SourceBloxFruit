--[[
    ╔══════════════════════════════════════════════════════════════╗
    ║                    AUTO FARM PRO v1.0                        ║
    ║                   Main Loader Script                         ║
    ║              Hỗ trợ: Sea 1 - Sea 2 - Sea 3                   ║
    ╚══════════════════════════════════════════════════════════════╝
    
    File này sẽ load 3 module theo thứ tự:
    1. BloxFruitsData.lua - Data Module (Sea 1-3)
    2. AutoFarmFunctions.lua - Logic Module (Farm, Quest, Attack)
    3. AutoFarmGUI.lua - GUI Module (Giao diện)
]]

--============================================
-- CONFIGURATION - THAY ĐỔI LINK CỦA BẠN Ở ĐÂY
--============================================
local Config = {
    -- Chế độ load: "local" hoặc "url"
    -- "local" = load từ file trong cùng thư mục (dùng cho test)
    -- "url" = load từ raw link (dùng cho publish)
    LoadMode = "local",
    
    -- Raw links cho từng module (Github, Pastebin, etc.)
    -- Chỉ cần điền nếu LoadMode = "url"
    DataModuleURL = "YOUR_RAW_LINK/BloxFruitsData.lua",
    FunctionsModuleURL = "YOUR_RAW_LINK/AutoFarmFunctions.lua", 
    GUIModuleURL = "YOUR_RAW_LINK/AutoFarmGUI.lua",
    
    -- Tên file local (dùng khi LoadMode = "local")
    DataModuleFile = "BloxFruitsData.lua",
    FunctionsModuleFile = "AutoFarmFunctions.lua",
    GUIModuleFile = "AutoFarmGUI.lua",
    
    -- Debug mode - hiển thị log
    Debug = true,
    
    -- Thời gian chờ giữa các module (giây)
    LoadDelay = 0.5,
}

--============================================
-- SERVICES
--============================================
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

--============================================
-- SHARED VARIABLES (Chia sẻ giữa các module)
--============================================
getgenv().AutoFarmPro = {
    -- Data sẽ được load từ BloxFruitsData.lua
    Data = nil,
    
    -- Functions sẽ được load từ AutoFarmFunctions.lua
    Functions = nil,
    
    -- Settings chia sẻ
    Settings = {
        AutoFarm = false,
        AutoQuest = false,
        BringMob = false,
        KillAura = false,
        CurrentSea = 1,
        SelectedIsland = nil,
        SelectedMob = nil,
        FarmDistance = 15,
        AttackRange = 50,
    },
    
    -- Connections
    Connections = {},
    
    -- Loaded status
    Loaded = {
        Data = false,
        Functions = false,
        GUI = false,
    }
}

--============================================
-- UTILITY FUNCTIONS
--============================================
local function log(message, messageType)
    if not Config.Debug then return end
    
    local prefix = "[AutoFarm] "
    
    if messageType == "success" then
        prefix = "[✓] "
    elseif messageType == "error" then
        prefix = "[✗] "
    elseif messageType == "warning" then
        prefix = "[!] "
    elseif messageType == "info" then
        prefix = "[i] "
    elseif messageType == "loading" then
        prefix = "[...] "
    end
    
    print(prefix .. message)
end

local function loadModule(urlOrFile, moduleName, isLocal)
    log("Đang tải " .. moduleName .. "...", "loading")
    
    local success, result
    
    if isLocal or Config.LoadMode == "local" then
        -- Load từ file local (sử dụng readfile của executor)
        success, result = pcall(function()
            if readfile then
                return loadstring(readfile(urlOrFile))()
            else
                -- Fallback: thử dùng loadfile nếu có
                local fn, err = loadfile(urlOrFile)
                if fn then
                    return fn()
                else
                    error("Không thể đọc file: " .. tostring(err))
                end
            end
        end)
    else
        -- Load từ URL
        success, result = pcall(function()
            return loadstring(game:HttpGet(urlOrFile))()
        end)
    end
    
    if success and result then
        log(moduleName .. " đã tải thành công!", "success")
        return result
    else
        log("Lỗi khi tải " .. moduleName .. ": " .. tostring(result), "error")
        return nil
    end
end

--============================================
-- LOADING SCREEN
--============================================
local function createLoadingScreen()
    -- Xóa loading screen cũ nếu có
    if playerGui:FindFirstChild("AutoFarmLoader") then
        playerGui.AutoFarmLoader:Destroy()
    end
    
    local loadingGui = Instance.new("ScreenGui")
    loadingGui.Name = "AutoFarmLoader"
    loadingGui.ResetOnSpawn = false
    loadingGui.Parent = playerGui
    
    local background = Instance.new("Frame")
    background.Size = UDim2.new(1, 0, 1, 0)
    background.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    background.BackgroundTransparency = 0.5
    background.Parent = loadingGui
    
    local container = Instance.new("Frame")
    container.Size = UDim2.new(0, 320, 0, 180)
    container.Position = UDim2.new(0.5, -160, 0.5, -90)
    container.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    container.BorderSizePixel = 0
    container.Parent = loadingGui
    
    local containerCorner = Instance.new("UICorner")
    containerCorner.CornerRadius = UDim.new(0, 12)
    containerCorner.Parent = container
    
    local containerStroke = Instance.new("UIStroke")
    containerStroke.Color = Color3.fromRGB(70, 130, 180)
    containerStroke.Thickness = 2
    containerStroke.Parent = container
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 40)
    title.Position = UDim2.new(0, 0, 0, 15)
    title.BackgroundTransparency = 1
    title.Text = "🎮 AUTO FARM PRO"
    title.TextColor3 = Color3.fromRGB(70, 130, 180)
    title.TextSize = 22
    title.Font = Enum.Font.GothamBold
    title.Parent = container
    
    local statusText = Instance.new("TextLabel")
    statusText.Name = "Status"
    statusText.Size = UDim2.new(1, -20, 0, 25)
    statusText.Position = UDim2.new(0, 10, 0, 60)
    statusText.BackgroundTransparency = 1
    statusText.Text = "Đang khởi động..."
    statusText.TextColor3 = Color3.fromRGB(200, 200, 200)
    statusText.TextSize = 14
    statusText.Font = Enum.Font.Gotham
    statusText.Parent = container
    
    -- Module status labels
    local moduleStatus = Instance.new("Frame")
    moduleStatus.Size = UDim2.new(1, -40, 0, 60)
    moduleStatus.Position = UDim2.new(0, 20, 0, 90)
    moduleStatus.BackgroundTransparency = 1
    moduleStatus.Parent = container
    
    local moduleLayout = Instance.new("UIListLayout")
    moduleLayout.Padding = UDim.new(0, 5)
    moduleLayout.Parent = moduleStatus
    
    local function createModuleLabel(name)
        local label = Instance.new("TextLabel")
        label.Name = name
        label.Size = UDim2.new(1, 0, 0, 16)
        label.BackgroundTransparency = 1
        label.Text = "⏳ " .. name
        label.TextColor3 = Color3.fromRGB(150, 150, 150)
        label.TextSize = 12
        label.Font = Enum.Font.Gotham
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Parent = moduleStatus
        return label
    end
    
    local dataLabel = createModuleLabel("BloxFruitsData")
    local funcLabel = createModuleLabel("AutoFarmFunctions")
    local guiLabel = createModuleLabel("AutoFarmGUI")
    
    -- Progress bar
    local progressBg = Instance.new("Frame")
    progressBg.Size = UDim2.new(1, -40, 0, 6)
    progressBg.Position = UDim2.new(0, 20, 1, -25)
    progressBg.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    progressBg.BorderSizePixel = 0
    progressBg.Parent = container
    
    local progressBgCorner = Instance.new("UICorner")
    progressBgCorner.CornerRadius = UDim.new(1, 0)
    progressBgCorner.Parent = progressBg
    
    local progressFill = Instance.new("Frame")
    progressFill.Name = "Fill"
    progressFill.Size = UDim2.new(0, 0, 1, 0)
    progressFill.BackgroundColor3 = Color3.fromRGB(70, 130, 180)
    progressFill.BorderSizePixel = 0
    progressFill.Parent = progressBg
    
    local progressFillCorner = Instance.new("UICorner")
    progressFillCorner.CornerRadius = UDim.new(1, 0)
    progressFillCorner.Parent = progressFill
    
    return {
        gui = loadingGui,
        status = statusText,
        progressFill = progressFill,
        dataLabel = dataLabel,
        funcLabel = funcLabel,
        guiLabel = guiLabel,
        
        updateStatus = function(self, text)
            self.status.Text = text
        end,
        
        updateProgress = function(self, percent)
            TweenService:Create(self.progressFill, TweenInfo.new(0.3), {
                Size = UDim2.new(percent / 100, 0, 1, 0)
            }):Play()
        end,
        
        setModuleStatus = function(self, module, success)
            local label = self[module .. "Label"]
            if label then
                if success then
                    label.Text = "✅ " .. label.Name
                    label.TextColor3 = Color3.fromRGB(0, 200, 100)
                else
                    label.Text = "❌ " .. label.Name
                    label.TextColor3 = Color3.fromRGB(200, 60, 60)
                end
            end
        end,
        
        destroy = function(self)
            TweenService:Create(self.gui, TweenInfo.new(0.5), {}):Play()
            wait(0.3)
            self.gui:Destroy()
        end
    }
end

--============================================
-- MAIN LOADER
--============================================
local function main()
    log("═══════════════════════════════════════", "info")
    log("       AUTO FARM PRO - LOADER          ", "info")
    log("═══════════════════════════════════════", "info")
    
    -- Tạo loading screen
    local loader = createLoadingScreen()
    
    -- STEP 1: Load Data Module
    loader:updateStatus("Đang tải BloxFruitsData...")
    loader:updateProgress(10)
    wait(Config.LoadDelay)
    
    local dataSource = Config.LoadMode == "local" and Config.DataModuleFile or Config.DataModuleURL
    local dataModule = loadModule(dataSource, "BloxFruitsData")
    if dataModule then
        getgenv().AutoFarmPro.Data = dataModule
        getgenv().AutoFarmPro.Loaded.Data = true
        loader:setModuleStatus("data", true)
    else
        loader:setModuleStatus("data", false)
        log("Không thể tải Data Module! Dừng lại.", "error")
        loader:updateStatus("❌ Lỗi: Không tải được Data Module")
        return
    end
    
    loader:updateProgress(33)
    wait(Config.LoadDelay)
    
    -- STEP 2: Load Functions Module
    loader:updateStatus("Đang tải AutoFarmFunctions...")
    
    local funcSource = Config.LoadMode == "local" and Config.FunctionsModuleFile or Config.FunctionsModuleURL
    local functionsModule = loadModule(funcSource, "AutoFarmFunctions")
    if functionsModule then
        getgenv().AutoFarmPro.Functions = functionsModule
        getgenv().AutoFarmPro.Loaded.Functions = true
        loader:setModuleStatus("func", true)
    else
        loader:setModuleStatus("func", false)
        log("Không thể tải Functions Module! Dừng lại.", "error")
        loader:updateStatus("❌ Lỗi: Không tải được Functions Module")
        return
    end
    
    loader:updateProgress(66)
    wait(Config.LoadDelay)
    
    -- STEP 3: Load GUI Module
    loader:updateStatus("Đang tải AutoFarmGUI...")
    
    local guiSource = Config.LoadMode == "local" and Config.GUIModuleFile or Config.GUIModuleURL
    local guiModule = loadModule(guiSource, "AutoFarmGUI")
    if guiModule then
        getgenv().AutoFarmPro.Loaded.GUI = true
        loader:setModuleStatus("gui", true)
    else
        loader:setModuleStatus("gui", false)
        log("Không thể tải GUI Module! Dừng lại.", "error")
        loader:updateStatus("❌ Lỗi: Không tải được GUI Module")
        return
    end
    
    loader:updateProgress(100)
    loader:updateStatus("✅ Tải hoàn tất!")
    
    wait(1)
    
    -- Đóng loading screen
    loader:destroy()
    
    -- Hoàn tất
    log("═══════════════════════════════════════", "success")
    log("   ✅ TẤT CẢ MODULE ĐÃ ĐƯỢC TẢI!      ", "success")
    log("═══════════════════════════════════════", "success")
    log("📌 Hướng dẫn:", "info")
    log("   1. Vào Tab Quest để chọn đảo và quái", "info")
    log("   2. Bật Auto Farm trong Tab Farm", "info")
    log("   3. Enjoy! 🎮", "info")
end

--============================================
-- RUN
--============================================
main()
