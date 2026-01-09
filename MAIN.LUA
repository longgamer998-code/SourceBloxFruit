-- ╔══════════════════════════════════════════════════════════╗
-- ║  MAIN.LUA - Blox Fruits Auto Farm V2.3                   ║
-- ║  Load modules from GitHub                                ║
-- ║  Repo: longgamer998-code/SourceBloxFruit                 ║
-- ║  Made for: patrick31frag                                 ║
-- ╚══════════════════════════════════════════════════════════╝

print("╔══════════════════════════════════════════════════════════╗")
print("║  🏴‍☠️ BLOX FRUITS AUTO FARM V2.3                          ║")
print("║  Initializing...                                          ║")
print("╚══════════════════════════════════════════════════════════╝")

-- ========== GITHUB RAW LINKS ==========
local REPO_BASE = "https://raw.githubusercontent.com/longgamer998-code/SourceBloxFruit/main/"

local CONFIG_URL = REPO_BASE .. "CONFIG.LUA"
local CORE_URL = REPO_BASE ..  "CORE.LUA"
local GUI_URL = REPO_BASE .. "GUI.LUA"

print("\n📦 Loading modules from GitHub...")
print("📍 Repository: longgamer998-code/SourceBloxFruit")
print("")

-- ========== LOAD CONFIG ==========
print("📥 [1/3] Loading CONFIG.LUA...")
local Config
local success, result = pcall(function()
    Config = loadstring(game:HttpGet(CONFIG_URL))()
end)

if not success then
    warn("❌ Failed to load CONFIG.LUA")
    warn("Error: " .. tostring(result))
    warn("URL: " .. CONFIG_URL)
    return
end

if not Config then
    warn("❌ CONFIG.LUA returned nil")
    return
end

print("✅ CONFIG.LUA loaded successfully")

-- ========== LOAD CORE ==========
print("📥 [2/3] Loading CORE.LUA...")
local Core
success, result = pcall(function()
    Core = loadstring(game:HttpGet(CORE_URL))()
end)

if not success then
    warn("❌ Failed to load CORE.LUA")
    warn("Error: " .. tostring(result))
    warn("URL: " ..  CORE_URL)
    return
end

if not Core then
    warn("❌ CORE. LUA returned nil")
    return
end

print("✅ CORE.LUA loaded successfully")

-- ========== LOAD GUI ==========
print("📥 [3/3] Loading GUI. LUA...")
local GUI
success, result = pcall(function()
    GUI = loadstring(game:HttpGet(GUI_URL))()
end)

if not success then
    warn("❌ Failed to load GUI.LUA")
    warn("Error: " ..  tostring(result))
    warn("URL: " .. GUI_URL)
    return
end

if not GUI then
    warn("❌ GUI.LUA returned nil")
    return
end

print("✅ GUI.LUA loaded successfully")

-- ========== VERIFY ALL MODULES ==========
print("\n🔍 Verifying modules...")

if not Config or not Core or not GUI then
    warn("❌ One or more modules failed to load")
    warn("Config: " .. tostring(Config ~= nil))
    warn("Core: " .. tostring(Core ~= nil))
    warn("GUI: " .. tostring(GUI ~= nil))
    return
end

print("✅ All modules verified")

-- ========== INITIALIZE ==========
print("\n" .. string.rep("=", 60))
print("🏴‍☠️ BLOX FRUITS AUTO FARM V2.3")
print(string.rep("=", 60))

-- Initialize console system
print("🔧 Initializing console system...")
success, result = pcall(function()
    Core.initConsole(Config)
end)

if not success then
    warn("❌ Failed to initialize console")
    warn("Error: " .. tostring(result))
    return
end

print("✅ Console system initialized")

-- Display player info
local player = game: GetService("Players").LocalPlayer
print("\n👤 Player: " .. player. Name)
print("⭐ Level: " .. tostring(Core.getPlayerLevel()))
print("💰 Beli: " .. tostring(player.Data.Beli. Value))

print(string.rep("=", 60))

-- Create GUI
print("\n🎨 Creating GUI...")
success, result = pcall(function()
    GUI.create(Config, Core)
end)

if not success then
    warn("❌ Failed to create GUI")
    warn("Error: " .. tostring(result))
    return
end

-- Display weapon list
print("\n🔫 Detecting weapons...")
task.spawn(function()
    task.wait(2)
    local weapons = Core.getPlayerWeapons()
    print("Weapons detected:")
    for i, weapon in ipairs(weapons) do
        print("  " .. tostring(i) .. ". " .. weapon)
    end
end)

-- Final message
print("\n" .. string.rep("=", 60))
print("✅ Script loaded successfully!")
print(string.rep("=", 60))
print("📖 Enable 'Debug Mode' in Main tab for detailed logs")
print("🎮 Toggle 'Auto Farm' to start farming")
print("🖥️ Check Console tab for statistics")
print(string.rep("=", 60))

print("\n🌐 Loaded from:  " .. REPO_BASE)
print("📅 " .. os.date("%Y-%m-%d %H:%M:%S"))
