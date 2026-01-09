-- =================================================================
-- MAIN.LUA - SAFE LOADER (check từng bước, không crash)
-- =================================================================

print("=" .. string.rep("=", 58) .. "=")
print("  BLOX FRUITS AUTO FARM V2.5 - SAFE LOADER")
print("=" .. string.rep("=", 58) .. "=")
print("")

-- =================================================================
-- SAFE MODULE LOADER (check từng bước)
-- =================================================================

local function loadModule(moduleName, url)
    print("[" .. moduleName .. "] Loading...")
    print("[" .. moduleName .. "] URL: " .. url)
    
    -- Step 1: HttpGet
    local source
    local ok, err = pcall(function()
        source = game:HttpGet(url)
    end)
    
    if not ok then
        error("[" .. moduleName .. "] HttpGet failed: " .. tostring(err))
    end
    
    if not source then
        error("[" .. moduleName .. "] HttpGet returned nil")
    end
    
    if type(source) ~= "string" then
        error("[" ..  moduleName .. "] HttpGet returned " .. type(source) .. " instead of string")
    end
    
    if #source < 10 then
        error("[" .. moduleName .. "] HttpGet returned empty or too short (" .. #source .. " bytes)")
    end
    
    print("[" .. moduleName .. "] Downloaded:  " .. #source .. " bytes")
    
    -- Step 2: loadstring
    local loadFunc
    ok, err = pcall(function()
        loadFunc = loadstring(source)
    end)
    
    if not ok then
        error("[" .. moduleName .. "] loadstring failed: " .. tostring(err))
    end
    
    if not loadFunc then
        error("[" .. moduleName .. "] loadstring returned nil")
    end
    
    if type(loadFunc) ~= "function" then
        error("[" .. moduleName .. "] loadstring returned " .. type(loadFunc) .. " instead of function")
    end
    
    print("[" .. moduleName .. "] Compiled successfully")
    
    -- Step 3: Execute
    local result
    ok, err = pcall(function()
        result = loadFunc()
    end)
    
    if not ok then
        error("[" ..  moduleName .. "] Execution failed: " .. tostring(err))
    end
    
    if not result then
        error("[" ..  moduleName .. "] Module returned nil (missing 'return " .. moduleName .. "'? )")
    end
    
    if type(result) ~= "table" then
        error("[" ..  moduleName .. "] Module returned " .. type(result) .. " instead of table")
    end
    
    print("[" .. moduleName .. "] [OK] Loaded successfully (type: table)")
    return result
end

-- =================================================================
-- CONFIGURATION
-- =================================================================

local BASE_URL = "https://raw.githubusercontent.com/longgamer998-code/SourceBloxFruit/main/"
local CACHE_BUSTER = "?v=" .. tick()

local CONFIG_URL = BASE_URL .. "CONFIG. LUA" .. CACHE_BUSTER
local CORE_URL = BASE_URL .. "CORE.LUA" .. CACHE_BUSTER
local GUI_URL = BASE_URL .. "GUI.LUA" .. CACHE_BUSTER

-- =================================================================
-- LOAD MODULES
-- =================================================================

local Config, Core, GUI
local loadSuccess = true
local loadErrors = {}

-- Load CONFIG
print("\n" .. string.rep("-", 60))
print("[1/3] LOADING CONFIG...")
print(string.rep("-", 60))

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
if loadSuccess then
    print("\n" .. string.rep("-", 60))
    print("[2/3] LOADING CORE...")
    print(string.rep("-", 60))
    
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

-- Initialize console (only if both loaded)
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
if loadSuccess then
    local player = game. Players.LocalPlayer
    
    print("\n" .. string.rep("=", 60))
    print("PLAYER INFO")
    print(string.rep("=", 60))
    print("Player: " .. player.Name)
    
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

-- Load GUI (only if CONFIG + CORE loaded)
if loadSuccess then
    print("\n" .. string.rep("-", 60))
    print("[3/3] LOADING GUI...")
    print(string.rep("-", 60))
    
    ok, err = pcall(function()
        GUI = loadModule("GUI", GUI_URL)
    end)
    
    if not ok then
        warn("[WARN] Failed to load GUI (non-critical)")
        warn("Error: " .. tostring(err))
        
        -- Create fallback GUI
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

-- Verify GUI has create method
if GUI and type(GUI) == "table" then
    if not GUI.create or type(GUI.create) ~= "function" then
        warn("[WARN] GUI.create is not a function!")
        
        -- Create dummy create function
        GUI.create = function(Config, Core)
            warn("[WARN] Dummy GUI.create called")
        end
    end
end

-- Create GUI (only if all modules loaded)
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
    print("  1. Check internet connection")
    print("  2. Verify GitHub files exist:")
    print("     " .. BASE_URL)
    print("  3. Check executor supports HttpGet and loadstring")
    print("  4. Try again in a few minutes (rate limit)")
    print("")
    return
end

print("GitHub: longgamer998-code/SourceBloxFruit")
print("Date: " .. os.date("%Y-%m-%d %H:%M:%S"))
print("Ready to farm!")
print(string.rep("=", 60))

-- =================================================================
-- EXPOSE GLOBALS (only if loaded successfully)
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
            
            print("Weapon: " .. (Config.Settings.SelectedWeapon or "?"))
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
            for location, quests in pairs(Config. QuestData or {}) do
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
                print("  Core.getPlayerLevel: " .. (Core.getPlayerLevel and "OK" or "MISSING"))
            end
            
            if GUI and type(GUI) == "table" then
                print("  GUI.create: " .. (GUI.create and "OK" or "MISSING"))
            end
            
            print("")
        end
    }
    
    print("\nMANUAL COMMANDS:")
    print("  BloxFruitsAutoFarm. Start()       -- Start farming")
    print("  BloxFruitsAutoFarm.Stop()        -- Stop farming")
    print("  BloxFruitsAutoFarm.Status()      -- Show status")
    print("  BloxFruitsAutoFarm. DebugQuests() -- Show quests")
    print("  BloxFruitsAutoFarm. TestModules() -- Test modules")
    print("")
end
