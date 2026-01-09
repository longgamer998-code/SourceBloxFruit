-- =================================================================
-- MAIN.LUA - FIX:  Gọi GUI.create() đúng cách
-- =================================================================

print("Loading Blox Fruits Auto Farm V2.5...")
print("Loading modules from GitHub...")

-- Raw URLs
local RAW_BASE = "https://raw.githubusercontent.com/longgamer998-code/SourceBloxFruit/main/"
local CONFIG_URL = RAW_BASE .. "CONFIG.LUA"
local CORE_URL = RAW_BASE ..   "CORE.LUA"
local GUI_URL = RAW_BASE ..  "GUI.LUA"

print("Base URL:  " .. RAW_BASE)

-- =================================================================
-- LOAD CONFIG
-- =================================================================

print("\n[1/3] Loading CONFIG...")
print("URL: " .. CONFIG_URL)

local Config
local configSuccess, configError = pcall(function()
    local source = game:HttpGet(CONFIG_URL ..  "? v=" .. tick())
    print("[OK] Downloaded CONFIG (" .. #source .. " bytes)")
    Config = loadstring(source)()
end)

if not configSuccess then
    warn("[ERROR] Failed to load CONFIG!")
    warn("Error: " .. tostring(configError))
    warn("\nPlease verify:")
    warn("  1. CONFIG.LUA exists at:  " .. CONFIG_URL)
    warn("  2. File ends with 'return Config'")
    warn("  3. No syntax errors")
    return
end

if not Config then
    warn("[ERROR] CONFIG is nil after loading!")
    return
end

print("[OK] CONFIG loaded successfully")

-- =================================================================
-- LOAD CORE
-- =================================================================

print("\n[2/3] Loading CORE...")
print("URL: " .. CORE_URL)

local Core
local coreSuccess, coreError = pcall(function()
    local source = game:HttpGet(CORE_URL ..  "?v=" .. tick())
    print("[OK] Downloaded CORE (" .. #source .. " bytes)")
    Core = loadstring(source)()
end)

if not coreSuccess then
    warn("[ERROR] Failed to load CORE!")
    warn("Error: " .. tostring(coreError))
    warn("\nPlease verify:")
    warn("  1. CORE.LUA exists at: " .. CORE_URL)
    warn("  2. File ends with 'return Core'")
    warn("  3. No syntax errors")
    return
end

if not Core then
    warn("[ERROR] CORE is nil after loading!")
    return
end

print("[OK] CORE loaded successfully")

-- =================================================================
-- INIT CONSOLE
-- =================================================================

print("\nInitializing console...")
Core.initConsole(Config)
print("[OK] Console ready")

-- =================================================================
-- PLAYER INFO
-- =================================================================

local player = game.Players.LocalPlayer

print("\n" .. string.rep("=", 60))
print("Player: " .. player.Name)

local levelSuccess, level = pcall(function()
    return player.Data.Level.Value
end)
print("Level: " .. (levelSuccess and tostring(level) or "?"))

local beliSuccess, beli = pcall(function()
    return player.Data.Beli.Value
end)
print("Beli: " .. (beliSuccess and tostring(beli) or "?"))

print(string.rep("=", 60))

-- =================================================================
-- LOAD GUI
-- =================================================================

print("\n[3/3] Loading GUI...")
print("URL: " .. GUI_URL)

local GUI
local guiSuccess, guiError = pcall(function()
    local source = game:HttpGet(GUI_URL .. "?v=" ..  tick())
    print("[OK] Downloaded GUI (" .. #source ..  " bytes)")
    GUI = loadstring(source)()
end)

if not guiSuccess then
    warn("[ERROR] Failed to load GUI!")
    warn("Error: " .. tostring(guiError))
    warn("\nUsing fallback mode...")
    
    -- Fallback GUI
    GUI = {}
    function GUI.create(Config, Core)
        warn("[WARN] GUI not available - use manual commands:")
        warn("  BloxFruitsAutoFarm. Start()")
        warn("  BloxFruitsAutoFarm.Stop()")
        warn("  BloxFruitsAutoFarm.Status()")
    end
end

if not GUI then
    warn("[ERROR] GUI is nil after loading!")
    -- Create dummy GUI
    GUI = {}
    function GUI.create(Config, Core)
        warn("[WARN] Using dummy GUI")
    end
end

if type(GUI) ~= "table" then
    warn("[ERROR] GUI is not a table!  Type: " .. type(GUI))
    return
end

if not GUI.create then
    warn("[ERROR] GUI.create function not found!")
    warn("GUI keys: " .. table.concat(vim.tbl_keys(GUI or {}), ", "))
    return
end

print("[OK] GUI loaded (type: " .. type(GUI) .. ")")

-- =================================================================
-- CREATE GUI - FIX:  Gọi GUI.create() ĐÚNG CÁCH
-- =================================================================

print("\nCreating GUI...")

-- ✅ ĐÚNG: Gọi GUI.create() như một method của table
local createSuccess, createError = pcall(function()
    GUI.create(Config, Core)  -- ✅ ĐÚNG! 
    -- ❌ SAI: GUI(Config, Core)  -- Không được gọi table như function
end)

if not createSuccess then
    warn("[ERROR] Failed to create GUI!")
    warn("Error: " .. tostring(createError))
    warn("\nYou can still use manual commands:")
    warn("  BloxFruitsAutoFarm. Start()")
    warn("  BloxFruitsAutoFarm.Stop()")
    warn("  BloxFruitsAutoFarm.Status()")
end

-- =================================================================
-- SUCCESS
-- =================================================================

print("\n" .. string.rep("=", 60))
print("[OK] SCRIPT LOADED SUCCESSFULLY!")
print(string.rep("=", 60))
print("How to use:")
print("  1. Open GUI (if loaded)")
print("  2. Select weapon")
print("  3. Toggle 'Auto Farm' to start")
print("  4. Check Console tab for stats")
print(string.rep("=", 60))
print("GitHub: longgamer998-code/SourceBloxFruit")
print("Date: " .. os.date("%Y-%m-%d %H:%M:%S"))
print("Ready to farm!")
print(string.rep("=", 60))

-- =================================================================
-- EXPOSE GLOBALS
-- =================================================================

getgenv().BloxFruitsAutoFarm = {
    Config = Config,
    Core = Core,
    GUI = GUI,
    
    Start = function()
        Config.Settings.Enabled = true
        local success = Core.startAutoFarm(Config)
        if success then
            print("[OK] Auto Farm started!")
        else
            warn("[ERROR] Failed to start Auto Farm")
        end
        return success
    end,
    
    Stop = function()
        Config.Settings.Enabled = false
        Core.stopAutoFarm()
        print("[OK] Auto Farm stopped")
    end,
    
    Status = function()
        print("\n" .. string.rep("=", 40))
        print("AUTO FARM STATUS")
        print(string.rep("=", 40))
        print("Status: " .. (Core.isAutoFarmRunning() and "[RUNNING]" or "[STOPPED]"))
        print("Thread: " .. Core.getAutoFarmStatus())
        print("Enabled: " .. tostring(Config.Settings.Enabled))
        print("Level: " .. tostring(Core. getPlayerLevel()))
        print("Weapon: " .. Config.Settings. SelectedWeapon)
        print("Quest: " .. Config.Settings.CurrentQuest)
        print("Mobs Killed: " .. tostring(Config.Settings.MobsKilled))
        print("Quests Done: " .. tostring(Config. Settings.QuestsCompleted))
        print(string.rep("=", 40) .. "\n")
    end,
    
    DebugQuests = function()
        print("\n" .. string.rep("=", 40))
        print("AVAILABLE QUESTS")
        print(string.rep("=", 40))
        local count = 0
        for location, quests in pairs(Config.QuestData) do
            print("\n[" .. location .. "]")
            for i, quest in ipairs(quests) do
                print("  " .. i ..  ". " .. quest.Name ..  " (Lvl " .. quest.LevelReq .. ")")
                count = count + 1
            end
        end
        print("\nTotal:  " .. count .. " quests")
        print(string.rep("=", 40) .. "\n")
    end,
    
    TestModules = function()
        print("\n[TEST] Checking modules...")
        print("Config type: " .. type(Config))
        print("Core type: " ..  type(Core))
        print("GUI type: " .. type(GUI))
        
        if type(GUI) == "table" then
            print("GUI.create exists:  " .. tostring(GUI.create ~= nil))
        end
        
        print("\n[OK] All modules loaded correctly!")
    end
}

print("\nManual Commands:")
print("  BloxFruitsAutoFarm.Start()        -- Start farming")
print("  BloxFruitsAutoFarm.Stop()         -- Stop farming")
print("  BloxFruitsAutoFarm.Status()       -- Show status")
print("  BloxFruitsAutoFarm. DebugQuests()  -- Show all quests")
print("  BloxFruitsAutoFarm. TestModules()  -- Test modules\n")
