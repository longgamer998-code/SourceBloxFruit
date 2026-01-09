-- =================================================================
-- MAIN.LUA - Universal Loader (hỗ trợ mọi executor)
-- =================================================================

print("=" .. string.rep("=", 58) .. "=")
print("  BLOX FRUITS AUTO FARM V2.5 - UNIVERSAL LOADER")
print("=" .. string.rep("=", 58) .. "=")
print("")

-- =================================================================
-- UNIVERSAL HTTP GET (hỗ trợ tất cả executor)
-- =================================================================

local function httpGet(url)
    print("[HTTP] Attempting to fetch:  " .. url)
    
    -- Method 1: syn.request (Synapse X)
    if syn and syn. request then
        print("[HTTP] Using syn.request...")
        local ok, res = pcall(function()
            return syn.request({
                Url = url,
                Method = "GET"
            })
        end)
        
        if ok and res and res.Body then
            print("[HTTP] [OK] syn.request success (" .. #res.Body .. " bytes)")
            return res.Body
        end
        print("[HTTP] syn.request failed")
    end
    
    -- Method 2: http_request (KRNL, Electron)
    if http_request then
        print("[HTTP] Using http_request...")
        local ok, res = pcall(function()
            return http_request({
                Url = url,
                Method = "GET"
            })
        end)
        
        if ok and res and res. Body then
            print("[HTTP] [OK] http_request success (" .. #res.Body .. " bytes)")
            return res.Body
        end
        print("[HTTP] http_request failed")
    end
    
    -- Method 3: request (Script-Ware, Fluxus)
    if request then
        print("[HTTP] Using request...")
        local ok, res = pcall(function()
            return request({
                Url = url,
                Method = "GET"
            })
        end)
        
        if ok and res and res.Body then
            print("[HTTP] [OK] request success (" .. #res.Body .. " bytes)")
            return res.Body
        end
        print("[HTTP] request failed")
    end
    
    -- Method 4: game:HttpGet (Roblox default, nếu được bật)
    if game and game.HttpGet then
        print("[HTTP] Using game:HttpGet...")
        local ok, res = pcall(function()
            return game:HttpGet(url)
        end)
        
        if ok and res and type(res) == "string" and #res > 0 then
            print("[HTTP] [OK] game:HttpGet success (" .. #res .. " bytes)")
            return res
        end
        print("[HTTP] game:HttpGet failed")
    end
    
    -- Method 5: HttpService (fallback)
    local HttpService = game:GetService("HttpService")
    if HttpService and HttpService.GetAsync then
        print("[HTTP] Using HttpService:GetAsync...")
        local ok, res = pcall(function()
            return HttpService:GetAsync(url)
        end)
        
        if ok and res and type(res) == "string" and #res > 0 then
            print("[HTTP] [OK] HttpService success (" .. #res .. " bytes)")
            return res
        end
        print("[HTTP] HttpService failed")
    end
    
    warn("[HTTP] [ERROR] ALL HTTP METHODS FAILED!")
    warn("[HTTP] Your executor may not support HTTP requests")
    warn("[HTTP] Try:")
    warn("  1. Enable HTTP in executor settings")
    warn("  2. Use a different executor")
    warn("  3. Check internet connection")
    
    return nil
end

-- =================================================================
-- SAFE MODULE LOADER
-- =================================================================

local function loadModule(moduleName, url)
    print("\n" .. string.rep("-", 60))
    print("[" .. moduleName .. "] Loading...")
    print("[" .. moduleName .. "] URL: " .. url)
    print(string.rep("-", 60))
    
    -- Step 1: HTTP GET
    local source = httpGet(url)
    
    if not source then
        error("[" .. moduleName .. "] HttpGet returned nil")
    end
    
    if type(source) ~= "string" then
        error("[" .. moduleName .. "] HttpGet returned " .. type(source) .. " instead of string")
    end
    
    if #source < 10 then
        error("[" .. moduleName ..  "] HttpGet returned too short (" .. #source .. " bytes)")
    end
    
    print("[" .. moduleName .. "] Downloaded: " .. #source .. " bytes")
    
    -- Step 2: loadstring
    local loadFunc, loadErr = loadstring(source)
    
    if not loadFunc then
        error("[" .. moduleName ..  "] loadstring failed: " ..  tostring(loadErr))
    end
    
    print("[" .. moduleName .. "] Compiled successfully")
    
    -- Step 3: Execute
    local ok, result = pcall(loadFunc)
    
    if not ok then
        error("[" .. moduleName .. "] Execution failed: " .. tostring(result))
    end
    
    if not result then
        error("[" ..  moduleName .. "] Module returned nil (missing 'return " .. moduleName .. "'? )")
    end
    
    if type(result) ~= "table" then
        error("[" ..  moduleName .. "] Module returned " .. type(result) .. " instead of table")
    end
    
    print("[" .. moduleName .. "] [OK] Loaded successfully")
    return result
end

-- =================================================================
-- CONFIGURATION
-- =================================================================

local BASE_URL = "https://raw.githubusercontent.com/longgamer998-code/SourceBloxFruit/main/"
local CACHE_BUSTER = "?v=" .. tostring(tick())

local CONFIG_URL = BASE_URL .. "CONFIG. LUA" .. CACHE_BUSTER
local CORE_URL = BASE_URL .. "CORE.LUA" .. CACHE_BUSTER
local GUI_URL = BASE_URL .. "GUI.LUA" .. CACHE_BUSTER

-- =================================================================
-- DETECT EXECUTOR
-- =================================================================

print("\n" .. string.rep("=", 60))
print("EXECUTOR DETECTION")
print(string.rep("=", 60))

local executorName = "Unknown"
local httpMethod = "None"

if syn and syn.request then
    executorName = "Synapse X"
    httpMethod = "syn.request"
elseif KRNL_LOADED then
    executorName = "KRNL"
    httpMethod = "http_request"
elseif ELECTRON then
    executorName = "Electron"
    httpMethod = "http_request"
elseif Fluxus then
    executorName = "Fluxus"
    httpMethod = "request"
elseif http_request then
    executorName = "Generic (http_request)"
    httpMethod = "http_request"
elseif request then
    executorName = "Generic (request)"
    httpMethod = "request"
elseif game. HttpGet then
    executorName = "Roblox Default"
    httpMethod = "game:HttpGet"
end

print("Executor: " .. executorName)
print("HTTP Method: " .. httpMethod)
print(string.rep("=", 60))

-- =================================================================
-- LOAD MODULES
-- =================================================================

local Config, Core, GUI
local loadSuccess = true
local loadErrors = {}

-- Load CONFIG
print("\n[1/3] LOADING CONFIG...")

local ok, err = pcall(function()
    Config = loadModule("CONFIG", CONFIG_URL)
end)

if not ok then
    loadSuccess = false
    table.insert(loadErrors, "CONFIG:  " .. tostring(err))
    warn("[ERROR] Failed to load CONFIG!")
    warn("Error: " .. tostring(err))
end

-- Load CORE (only if CONFIG loaded)
if loadSuccess and Config then
    print("\n[2/3] LOADING CORE...")
    
    ok, err = pcall(function()
        Core = loadModule("CORE", CORE_URL)
    end)
    
    if not ok then
        loadSuccess = false
        table.insert(loadErrors, "CORE: " ..  tostring(err))
        warn("[ERROR] Failed to load CORE!")
        warn("Error: " .. tostring(err))
    end
end

-- Initialize console
if loadSuccess and Config and Core then
    print("\n" .. string.rep("-", 60))
    print("INITIALIZING CONSOLE...")
    print(string.rep("-", 60))
    
    ok, err = pcall(function()
        Core.initConsole(Config)
    end)
    
    if ok then
        print("[OK] Console initialized")
    else
        warn("[WARN] Console init failed: " .. tostring(err))
    end
end

-- Player info
if loadSuccess and Config and Core then
    local player = game.Players.LocalPlayer
    
    print("\n" ..  string.rep("=", 60))
    print("PLAYER INFO")
    print(string.rep("=", 60))
    print("Player:  " .. player.Name)
    
    local levelOk, level = pcall(function()
        return player.Data.Level. Value
    end)
    print("Level: " .. (levelOk and tostring(level) or "?"))
    
    local beliOk, beli = pcall(function()
        return player.Data.Beli.Value
    end)
    print("Beli: " .. (beliOk and tostring(beli) or "?"))
    print(string.rep("=", 60))
end

-- Load GUI
if loadSuccess and Config and Core then
    print("\n[3/3] LOADING GUI...")
    
    ok, err = pcall(function()
        GUI = loadModule("GUI", GUI_URL)
    end)
    
    if not ok then
        warn("[WARN] Failed to load GUI (non-critical)")
        warn("Error: " .. tostring(err))
        
        -- Fallback GUI
        GUI = {}
        function GUI.create(Config, Core)
            warn("[WARN] Using fallback GUI - no UI available")
            warn("Use manual commands:")
            warn("  BloxFruitsAutoFarm. Start()")
            warn("  BloxFruitsAutoFarm.Stop()")
            warn("  BloxFruitsAutoFarm. Status()")
        end
        
        print("[WARN] Created fallback GUI")
    end
end

-- Verify GUI structure
if GUI and type(GUI) == "table" then
    if not GUI.create or type(GUI.create) ~= "function" then
        warn("[WARN] GUI. create is missing or not a function!")
        
        GUI.create = function(Config, Core)
            warn("[WARN] Dummy GUI. create called")
        end
    end
end

-- Create GUI
if loadSuccess and Config and Core and GUI then
    print("\n" .. string.rep("-", 60))
    print("CREATING GUI...")
    print(string.rep("-", 60))
    
    ok, err = pcall(function()
        GUI.create(Config, Core)
    end)
    
    if ok then
        print("[OK] GUI created successfully")
    else
        warn("[ERROR] Failed to create GUI!")
        warn("Error: " ..  tostring(err))
    end
end

-- =================================================================
-- FINAL STATUS
-- =================================================================

print("\n" .. string.rep("=", 60))

if loadSuccess and Config and Core then
    print("[OK] SCRIPT LOADED SUCCESSFULLY!")
    print(string.rep("=", 60))
    print("")
    print("HOW TO USE:")
    print("  1. Open GUI (if loaded)")
    print("  2. Select weapon")
    print("  3. Toggle 'Auto Farm' to start")
    print("  4. Check Console tab for stats")
    print("")
else
    print("[ERROR] SCRIPT FAILED TO LOAD!")
    print(string.rep("=", 60))
    print("")
    print("ERRORS:")
    for i, errMsg in ipairs(loadErrors) do
        print("  " ..  i .. ".  " .. errMsg)
    end
    print("")
    print("TROUBLESHOOTING:")
    print("  1. Check executor supports HTTP requests")
    print("  2. Enable HTTP in executor settings")
    print("  3. Check internet connection")
    print("  4. Try a different executor")
    print("  5. Verify GitHub files exist:")
    print("     " .. BASE_URL)
    print("")
    return
end

print("Executor: " .. executorName)
print("GitHub: longgamer998-code/SourceBloxFruit")
print("Date: " .. os.date("%Y-%m-%d %H:%M:%S"))
print("Ready to farm!")
print(string.rep("=", 60))

-- =================================================================
-- EXPOSE GLOBALS
-- =================================================================

if loadSuccess and Config and Core then
    getgenv().BloxFruitsAutoFarm = {
        Config = Config,
        Core = Core,
        GUI = GUI,
        
        Start = function()
            if not Config or not Core then
                warn("[ERROR] Modules not loaded!")
                return false
            end
            
            Config.Settings. Enabled = true
            local success = Core.startAutoFarm(Config)
            
            if success then
                print("[OK] Auto Farm started!")
            else
                warn("[ERROR] Failed to start Auto Farm")
            end
            
            return success
        end,
        
        Stop = function()
            if not Config or not Core then
                warn("[ERROR] Modules not loaded!")
                return
            end
            
            Config. Settings.Enabled = false
            Core.stopAutoFarm()
            print("[OK] Auto Farm stopped")
        end,
        
        Status = function()
            if not Config or not Core then
                warn("[ERROR] Modules not loaded!")
                return
            end
            
            print("\n" .. string.rep("=", 40))
            print("AUTO FARM STATUS")
            print(string.rep("=", 40))
            print("Running: " .. tostring(Core. isAutoFarmRunning()))
            print("Thread: " .. Core.getAutoFarmStatus())
            print("Enabled: " .. tostring(Config.Settings.Enabled))
            
            local levelOk, level = pcall(function()
                return Core.getPlayerLevel()
            end)
            print("Level: " .. (levelOk and tostring(level) or "?"))
            
            print("Weapon: " .. (Config.Settings. SelectedWeapon or "? "))
            print("Quest: " .. (Config.Settings. CurrentQuest or "?"))
            print("Kills: " .. tostring(Config.Settings.MobsKilled or 0))
            print("Quests: " .. tostring(Config.Settings.QuestsCompleted or 0))
            print(string.rep("=", 40) .. "\n")
        end,
        
        DebugQuests = function()
            if not Config then
                warn("[ERROR] Config not loaded!")
                return
            end
            
            print("\n" .. string.rep("=", 40))
            print("AVAILABLE QUESTS")
            print(string.rep("=", 40))
            
            local count = 0
            for location, quests in pairs(Config.QuestData or {}) do
                print("\n[" .. location .. "]")
                for i, quest in ipairs(quests) do
                    print("  " .. i .. ". " ..  quest.Name ..  " (Lvl " .. quest.LevelReq .. ")")
                    count = count + 1
                end
            end
            
            print("\nTotal:  " .. count .. " quests")
            print(string.rep("=", 40) .. "\n")
        end,
        
        TestModules = function()
            print("\n[TEST] Module Status:")
            print("  Config: " .. (Config and "OK" or "MISSING"))
            print("  Core:  " .. (Core and "OK" or "MISSING"))
            print("  GUI: " .. (GUI and "OK" or "MISSING"))
            
            if Config then
                print("  Config.Settings: " .. (Config.Settings and "OK" or "MISSING"))
                print("  Config.QuestData: " .. (Config.QuestData and "OK" or "MISSING"))
            end
            
            if Core then
                print("  Core.startAutoFarm: " .. (Core.startAutoFarm and "OK" or "MISSING"))
                print("  Core.getPlayerLevel: " .. (Core. getPlayerLevel and "OK" or "MISSING"))
            end
            
            if GUI and type(GUI) == "table" then
                print("  GUI.create: " ..  (GUI.create and "OK" or "MISSING"))
            end
            
            print("")
        end,
        
        TestHTTP = function()
            print("\n[TEST] Testing HTTP methods...")
            
            local testUrl = "https://raw.githubusercontent.com/longgamer998-code/SourceBloxFruit/main/CONFIG.LUA"
            local result = httpGet(testUrl)
            
            if result then
                print("[OK] HTTP working!  Downloaded " .. #result .. " bytes")
            else
                warn("[ERROR] HTTP not working!")
                warn("Your executor may not support HTTP requests")
            end
        end
    }
    
    print("\nMANUAL COMMANDS:")
    print("  BloxFruitsAutoFarm. Start()       -- Start farming")
    print("  BloxFruitsAutoFarm.Stop()        -- Stop farming")
    print("  BloxFruitsAutoFarm.Status()      -- Show status")
    print("  BloxFruitsAutoFarm. DebugQuests() -- Show quests")
    print("  BloxFruitsAutoFarm. TestModules() -- Test modules")
    print("  BloxFruitsAutoFarm.TestHTTP()    -- Test HTTP")
    print("")
end
