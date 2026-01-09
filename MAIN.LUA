-- ╔══════════════════════════════════════════════════════════╗
-- ║  BLOX FRUITS AUTO FARM V2.5 - LOAD TỪ GITHUB              ║
-- ╚════════════════════════════════════════════════════════���═╝

print("🔄 Loading Blox Fruits Auto Farm V2.5...")

-- ═══════════════════════════════════════════════════════════
-- LOAD CONFIG
-- ═══════════════════════════════════════════════════════════

print("🔄 Loading CONFIG...")

local Config
local configSuccess, configError = pcall(function()
    Config = loadstring(game:HttpGet("https://raw.githubusercontent.com/longgamer998-code/SourceBloxFruit/main/CONFIG.LUA"))()
end)

if not configSuccess then
    warn("❌ Failed to load CONFIG from GitHub!")
    warn("Error: " .. tostring(configError))
    warn("⚠️ Script cannot run without CONFIG.LUA")
    warn("📝 Please make sure CONFIG.LUA is uploaded to:")
    warn("   https://raw.githubusercontent.com/longgamer998-code/SourceBloxFruit/main/CONFIG.LUA")
    return
end

print("✅ CONFIG loaded")

-- ═══════════════════════════════════════════════════════════
-- LOAD CORE
-- ═══════════════════════════════════════════════════════════

print("🔄 Loading CORE...")

local Core
local coreSuccess, coreError = pcall(function()
    Core = loadstring(game: HttpGet("https://raw.githubusercontent.com/longgamer998-code/SourceBloxFruit/main/CORE.LUA"))()
end)

if not coreSuccess then
    warn("❌ Failed to load CORE from GitHub!")
    warn("Error: " .. tostring(coreError))
    warn("⚠️ Script cannot run without CORE.LUA")
    return
end

print("✅ CORE loaded")

-- ═══════════════════════════════════════════════════════════
-- INIT CONSOLE
-- ═══════════════════════════════════════════════════════════

Core.initConsole(Config)
print("✅ Console ready")

-- ═══════════════════════════════════════════════════════════
-- PLAYER INFO
-- ═══════════════════════════════════════════════════════════

local player = game.Players.LocalPlayer

print("\n============================================================")
print("👤 Player:  " .. player.Name)

local levelSuccess, level = pcall(function()
    return player.Data.Level.Value
end)
print("⭐ Level:  " .. (levelSuccess and tostring(level) or "?"))

local beliSuccess, beli = pcall(function()
    return player.Data.Beli.Value
end)
print("💰 Beli: " .. (beliSuccess and tostring(beli) or "?"))

print("============================================================\n")

-- ═══════════════════════════════════════════════════════════
-- LOAD GUI
-- ═══════════════════════════════════════════════════════════

print("🎨 Loading GUI...")

local GUI
local guiSuccess, guiError = pcall(function()
    GUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/longgamer998-code/SourceBloxFruit/main/GUI.LUA"))()
end)

if not guiSuccess then
    warn("❌ Failed to load GUI from GitHub!")
    warn("Error: " .. tostring(guiError))
    warn("⚠️ Trying fallback GUI...")
    
    -- FALLBACK GUI
    GUI = {}
    function GUI.create(Config, Core)
        warn("⚠️ Using fallback GUI (simple version)")
        warn("📝 Manual commands:")
        warn("   BloxFruitsAutoFarm. Start()")
        warn("   BloxFruitsAutoFarm.Stop()")
        warn("   BloxFruitsAutoFarm. Status()")
    end
end

-- ═══════════════════════════════════════════════════════════
-- CREATE GUI
-- ═══════════════════════════════════════════════════════════

local createSuccess, createError = pcall(function()
    GUI.create(Config, Core)
end)

if not createSuccess then
    warn("❌ Failed to create GUI!")
    warn("Error: " .. tostring(createError))
    warn("⚠️ You can still use manual commands")
end

-- ═══════════════════════════════════════════════════��═══════
-- SUCCESS
-- ═══════════════════════════════════════════════════════════

print("\n============================================================")
print("✅ SCRIPT LOADED SUCCESSFULLY!")
print("============================================================")
print("📖 How to use:")
print("  1. Select weapon in GUI")
print("  2. Toggle 'Auto Farm' to start")
print("  3. Check Console tab for stats")
print("============================================================")
print("🌐 GitHub: longgamer998-code/SourceBloxFruit")
print("📅 " ..  os.date("%Y-%m-%d %H:%M:%S"))
print("✨ Ready!")
print("============================================================\n")

-- ═══════════════════════════════════════════════════════════
-- EXPOSE GLOBALS
-- ═══════════════════════════════════════════════════════════

getgenv().BloxFruitsAutoFarm = {
    Config = Config,
    Core = Core,
    Start = function()
        Config.Settings.Enabled = true
        return Core.startAutoFarm(Config)
    end,
    Stop = function()
        Config.Settings.Enabled = false
        Core.stopAutoFarm()
    end,
    Status = function()
        print("\n═══════════════════════════════════")
        print("📊 AUTO FARM STATUS")
        print("═══════════════════════════════════")
        print("Status: " .. (Core.isAutoFarmRunning() and "🟢 RUNNING" or "🔴 STOPPED"))
        print("Thread: " .. Core.getAutoFarmStatus())
        print("Enabled: " ..  tostring(Config.Settings. Enabled))
        print("Level: " .. tostring(Core. getPlayerLevel()))
        print("Mobs Killed: " ..  tostring(Config.Settings.MobsKilled))
        print("Quests Done: " .. tostring(Config.Settings.QuestsCompleted))
        print("Current Quest: " .. Config.Settings.CurrentQuest)
        print("═══════════════════════════════════\n")
    end,
    DebugQuests = function()
        print("\n═══════════════════════════════════")
        print("📋 AVAILABLE QUESTS")
        print("═══════════════════════════════════")
        for location, quests in pairs(Config.QuestData) do
            print("\n📍 " .. location ..  ":")
            for i, quest in ipairs(quests) do
                print("  " .. i .. ". " .. quest.Name ..  " (Lvl " .. quest.LevelReq .. ")")
            end
        end
        print("═══════════════════════════════════\n")
    end
}

print("📌 Manual commands:")
print("   BloxFruitsAutoFarm.Start()        -- Start farming")
print("   BloxFruitsAutoFarm.Stop()         -- Stop farming")
print("   BloxFruitsAutoFarm.Status()       -- Check status")
print("   BloxFruitsAutoFarm.DebugQuests()  -- Show all quests")
