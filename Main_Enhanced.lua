--[[
    ╔══════════════════════════════════════════════════════════════╗
    ║                    AUTO FARM PRO v2.0                        ║
    ║                   Main Loader Script                         ║
    ║              Hỗ trợ: Sea 1 - Sea 2 - Sea 3                   ║
    ║                   Enhanced with Retry Logic                  ║
    ╚══════════════════════════════════════════════════════════════╝
    
    File này sẽ load 3 module theo thứ tự:
    1. BloxFruitsData.lua - Data Module (Sea 1-3)
    2. AutoFarmFunctions.lua - Logic Module (Farm, Quest, Attack)
    3. AutoFarmGUI.lua - GUI Module (Giao diện)
    
    UPDATES v2.0:
    - ✅ Retry mechanism (3 attempts)
    - ✅ Data validation
    - ✅ Better error messages
    - ✅ Fallback URLs
    - ✅ Version checking
]]

--============================================
-- CONFIGURATION - THAY ĐỔI LINK CỦA BẠN Ở ĐÂY
--============================================
local Config = {
    -- Raw links cho từng module (Github, Pastebin, etc.)
    -- PRIMARY URLs
    DataModuleURL = "YOUR_RAW_LINK/BloxFruitsData_Fixed.lua",
    FunctionsModuleURL = "YOUR_RAW_LINK/AutoFarmFunctions.lua", 
    GUIModuleURL = "YOUR_RAW_LINK/AutoFarmGUI.lua",
    
    -- FALLBACK URLs (backup nếu primary fail)
    DataModuleFallback = "YOUR_BACKUP_LINK/BloxFruitsData_Fixed.lua",
    FunctionsModuleFallback = "YOUR_BACKUP_LINK/AutoFarmFunctions.lua",
    GUIModuleFallback = "YOUR_BACKUP_LINK/AutoFarmGUI.lua",
    
    -- Debug mode - hiển thị log
    Debug = true,
    
    -- Retry settings
    MaxRetries = 3,
    RetryDelay = 2, -- seconds
    
    -- Thời gian chờ giữa các module (giây)
    LoadDelay = 0.5,
    
    -- Expected version
    ExpectedDataVersion = "1.0.0",
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
    },
    
    -- Version info
    Version = "2.0.0",
    LoadTimestamp = os.time(),
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

-- Enhanced module loader with retry
local function loadModule(url, fallbackUrl, moduleName)
    log("Đang tải " .. moduleName .. "...", "loading")
    
    local attempts = 0
    local lastError = nil
    
    -- Try primary URL first, then fallback
    local urls = {url}
    if fallbackUrl and fallbackUrl ~= "" and fallbackUrl ~= "YOUR_BACKUP_LINK/" .. moduleName .. ".lua" then
        table.insert(urls, fallbackUrl)
    end
    
    for _, tryUrl in ipairs(urls) do
        attempts = 0
        while attempts < Config.MaxRetries do
            attempts = attempts + 1
            
            local urlType = (_ == 1) and "Primary" or "Fallback"
            log(string.format("Thử tải %s (Attempt %d/%d, %s URL)...", 
                moduleName, attempts, Config.MaxRetries, urlType), "loading")
            
            local success, result = pcall(function()
                return loadstring(game:HttpGet(tryUrl))()
            end)
            
            if success and result then
                log(moduleName .. " đã tải thành công!", "success")
                return result
            else
                lastError = tostring(result)
                log(string.format("Thất bại: %s", lastError), "warning")
                
                if attempts < Config.MaxRetries then
                    log(string.format("Chờ %ds trước khi thử lại...", Config.RetryDelay), "info")
                    wait(Config.RetryDelay)
                end
            end
        end
    end
    
    -- All attempts failed
    log("Lỗi khi tải " .. moduleName .. " sau " .. (Config.MaxRetries * #urls) .. " lần thử", "error")
    log("Lỗi cuối: " .. tostring(lastError), "error")
    return nil
end

-- Validate Data Module
local function validateDataModule(dataModule)
    if not dataModule then
        return false, "Module is nil"
    end
    
    -- Check basic structure
    if not dataModule.Sea1 or not dataModule.Sea2 or not dataModule.Sea3 then
        return false, "Missing Sea data"
    end
    
    -- Check if tables are not empty
    if #dataModule.Sea1 == 0 or #dataModule.Sea2 == 0 or #dataModule.Sea3 == 0 then
        return false, "Sea data is empty"
    end
    
    -- Check version if available
    if dataModule.Version and Config.ExpectedDataVersion then
        if dataModule.Version ~= Config.ExpectedDataVersion then
            log(string.format("Version mismatch: Expected %s, got %s", 
                Config.ExpectedDataVersion, dataModule.Version), "warning")
        end
    end
    
    -- Count islands
    local sea1Count = #dataModule.Sea1
    local sea2Count = #dataModule.Sea2
    local sea3Count = #dataModule.Sea3
    
    log(string.format("Data loaded: Sea1=%d islands, Sea2=%d islands, Sea3=%d islands", 
        sea1Count, sea2Count, sea3Count), "info")
    
    return true, "Valid"
end

-- Helper to convert table position to Vector3
getgenv().ToVector3 = function(pos)
    if type(pos) == "table" then
        if pos.X and pos.Y and pos.Z then
            return Vector3.new(pos.X, pos.Y, pos.Z)
        elseif pos[1] and pos[2] and pos[3] then
            return Vector3.new(pos[1], pos[2], pos[3])
        end
    end
    return pos -- Return as-is if already Vector3
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
    container.Size = UDim2.new(0, 340, 0, 200)
    container.Position = UDim2.new(0.5, -170, 0.5, -100)
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
    title.Text = "🎮 AUTO FARM PRO v2.0"
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
        
        setModuleStatus = function(self, module, success, details)
            local label = self[module .. "Label"]
            if label then
                if success then
                    label.Text = "✅ " .. label.Name
                    label.TextColor3 = Color3.fromRGB(0, 200, 100)
                    if details then
                        label.Text = label.Text .. " " .. details
                    end
                else
                    label.Text = "❌ " .. label.Name
                    label.TextColor3 = Color3.fromRGB(200, 60, 60)
                    if details then
                        label.Text = label.Text .. " (" .. details .. ")"
                    end
                end
            end
        end,
        
        destroy = function(self)
            TweenService:Create(self.gui, TweenInfo.new(0.5), {
                BackgroundTransparency = 1
            }):Play()
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
    log("     AUTO FARM PRO v2.0 - LOADER       ", "info")
    log("═══════════════════════════════════════", "info")
    
    -- Tạo loading screen
    local loader = createLoadingScreen()
    
    -- STEP 1: Load Data Module
    loader:updateStatus("Đang tải BloxFruitsData...")
    loader:updateProgress(10)
    wait(Config.LoadDelay)
    
    local dataModule = loadModule(
        Config.DataModuleURL, 
        Config.DataModuleFallback,
        "BloxFruitsData"
    )
    
    if dataModule then
        -- Validate data
        local isValid, validationMsg = validateDataModule(dataModule)
        
        if isValid then
            getgenv().AutoFarmPro.Data = dataModule
            getgenv().AutoFarmPro.Loaded.Data = true
            
            local details = string.format("(%d+%d+%d islands)", 
                #dataModule.Sea1, #dataModule.Sea2, #dataModule.Sea3)
            loader:setModuleStatus("data", true, details)
        else
            loader:setModuleStatus("data", false, validationMsg)
            log("Data validation failed: " .. validationMsg, "error")
            loader:updateStatus("❌ Lỗi: Data không hợp lệ")
            return
        end
    else
        loader:setModuleStatus("data", false, "Load failed")
        log("Không thể tải Data Module! Dừng lại.", "error")
        loader:updateStatus("❌ Lỗi: Không tải được Data Module")
        return
    end
    
    loader:updateProgress(33)
    wait(Config.LoadDelay)
    
    -- STEP 2: Load Functions Module
    loader:updateStatus("Đang tải AutoFarmFunctions...")
    
    local functionsModule = loadModule(
        Config.FunctionsModuleURL,
        Config.FunctionsModuleFallback,
        "AutoFarmFunctions"
    )
    
    if functionsModule then
        getgenv().AutoFarmPro.Functions = functionsModule
        getgenv().AutoFarmPro.Loaded.Functions = true
        loader:setModuleStatus("func", true)
    else
        loader:setModuleStatus("func", false, "Load failed")
        log("Không thể tải Functions Module! Dừng lại.", "error")
        loader:updateStatus("❌ Lỗi: Không tải được Functions Module")
        return
    end
    
    loader:updateProgress(66)
    wait(Config.LoadDelay)
    
    -- STEP 3: Load GUI Module
    loader:updateStatus("Đang tải AutoFarmGUI...")
    
    local guiModule = loadModule(
        Config.GUIModuleURL,
        Config.GUIModuleFallback,
        "AutoFarmGUI"
    )
    
    if guiModule then
        getgenv().AutoFarmPro.Loaded.GUI = true
        loader:setModuleStatus("gui", true)
    else
        loader:setModuleStatus("gui", false, "Load failed")
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
    log("📌 Thông tin:", "info")
    log("   Version: " .. getgenv().AutoFarmPro.Version, "info")
    log("   Data Islands: Sea1=" .. #getgenv().AutoFarmPro.Data.Sea1 .. 
        " Sea2=" .. #getgenv().AutoFarmPro.Data.Sea2 .. 
        " Sea3=" .. #getgenv().AutoFarmPro.Data.Sea3, "info")
    log("📌 Hướng dẫn:", "info")
    log("   1. Vào Tab Quest để chọn đảo và quái", "info")
    log("   2. Bật Auto Farm trong Tab Farm", "info")
    log("   3. Enjoy! 🎮", "info")
end

--============================================
-- RUN
--============================================
main()
