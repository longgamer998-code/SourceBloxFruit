-- ╔══════════════════════════════════════════════════════════╗
-- ║  MAIN.LUA - Blox Fruits Auto Farm V2.3                   ║
-- ║  Load modules from GitHub                                ║
-- ║  Repo: longgamer998-code/SourceBloxFruit                 ║
-- ╚══════════════════════════════════════════════════════════╝

print("🏴‍☠️ Initializing Blox Fruits Auto Farm V2.3...")
print("📦 Loading modules from GitHub...")

-- ========== GITHUB RAW LINKS ==========
local REPO_BASE = "https://raw.githubusercontent.com/longgamer998-code/SourceBloxFruit/main/"

local CONFIG_URL = REPO_BASE .. "Config.lua"
local CORE_URL = REPO_BASE .. "Core.lua"
local GUI_URL = REPO_BASE .. "GUI.lua"

-- ========== LOAD MODULES ==========
local loadSuccess = true
local Config, Core, GUI

print("📥 Loading Config.lua...")
local success, result = pcall(function()
    Config = loadstring(game:HttpGet(CONFIG_URL))()
end)

if not success then
    warn("❌ Failed to load Config.lua:  " .. tostring(result))
    loadSuccess = false
else
    print("✅ Config.lua loaded successfully")
end

print("📥 Loading Core. lua...")
success, result = pcall(function()
    Core = loadstring(game:HttpGet(CORE_URL))()
end)

if not success then
    warn("❌ Failed to load Core.lua: " .. tostring(result))
    loadSuccess = false
else
    print("✅ Core. lua loaded successfully")
end

print("📥 Loading GUI.lua...")
success, result = pcall(function()
    GUI = loadstring(game:HttpGet(GUI_URL))()
end)

if not success then
    warn("❌ Failed to load GUI. lua: " .. tostring(result))
    loadSuccess = false
else
    print("✅ GUI.lua loaded successfully")
end

-- ========== CHECK IF ALL MODULES LOADED ==========
if not loadSuccess then
    warn("❌ Failed to load one or more modules.  Aborting...")
    return
end

if not Config or not Core or not GUI then
    warn("❌ One or more modules returned nil. Aborting...")
    return
end

-- ========== INITIALIZE ==========
print("\n" .. string.rep("=", 60))
print("🏴‍☠️ BLOX FRUITS AUTO FARM V2.3")
print(string.rep("=", 60))

-- Initialize console system
print("🔧 Initializing console system...")
Core.initConsole(Config)

-- Display player info
local player = game:GetService("Players").LocalPlayer
print("👤 Player:  " .. player.Name)
print("⭐ Level: " .. tostring(Core.getPlayerLevel()))
print(string.rep("=", 60))

-- Create GUI
print("🎨 Creating GUI...")
GUI.create(Config, Core)

-- Display weapon list
print("\n🔫 Detecting weapons...")
task.spawn(function()
    task.wait(2)
    local weapons = Core. getPlayerWeapons()
    print("Weapons detected:")
    for i, weapon in ipairs(weapons) do
        print("  " .. tostring(i) .. ". " .. weapon)
    end
end)

-- Final message
print("\n" .. string.rep("=", 60))
Core.logSuccess("✅ Combat Debug System enabled!")
print("📖 Enable 'Debug Mode' in Main tab for detailed logs")
print("🖥️ Check Console tab for combat statistics")
print(string.rep("=", 60))

print("\n✅ Script loaded successfully!")
print("🎮 Open GUI and toggle 'Auto Farm' to start")
print("\n📍 Loaded from: " .. REPO_BASE)
