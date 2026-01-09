-- ╔══════════════════════════════════════════════════════════╗
-- ║  MAIN.LUA - Main Entry Point                             ║
-- ║  Made for:   patrick31frag                                  ║
-- ╚══════════════════════════════════════════════════════════╝

print("Initializing Blox Fruits Auto Farm V2.3...")

-- ========== LOAD MODULES ==========
-- Option 1: If using separate files (loadstring from pastebin/github)
--[[
local Config = loadstring(game:HttpGet("YOUR_CONFIG_URL"))()
local Core = loadstring(game:HttpGet("YOUR_CORE_URL"))()
local GUI = loadstring(game:HttpGet("YOUR_GUI_URL"))()
]]

-- Option 2: If all in one file (paste all modules above this)
-- Uncomment if you're using this method: 
--[[
-- Paste Config. lua code here
-- Paste Core.lua code here  
-- Paste GUI.lua code here
]]

-- ========== FOR TESTING:  Use getgenv() ==========
-- Store in global environment
if not getgenv().BFConfig then
    -- Load Config (paste Config.lua content or load via loadstring)
    getgenv().BFConfig = {} -- Replace with actual Config module
    getgenv().BFCore = {}   -- Replace with actual Core module
    getgenv().BFGUI = {}    -- Replace with actual GUI module
end

local Config = getgenv().BFConfig
local Core = getgenv().BFCore
local GUI = getgenv().BFGUI

-- ========== INITIALIZE ==========
print("\n" .. string.rep("=", 60))
print("🏴‍☠️ BLOX FRUITS AUTO FARM V2.3")
print(string.rep("=", 60))

-- Initialize console system
Core.initConsole(Config)

-- Display player info
local player = game: GetService("Players").LocalPlayer
print("Player: " .. player.Name)
print("Level: " .. tostring(Core.getPlayerLevel()))
print(string.rep("=", 60))

-- Create GUI
GUI.create(Config, Core)

-- Display weapon list
print("\nDetecting weapons...")
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
Core.logSuccess("Combat Debug System enabled!")
print("Enable 'Debug Mode' in Main for detailed logs")
print("Check Console tab for combat statistics")
print(string.rep("=", 60) .. "\n")

print("✅ Script loaded successfully!")
print("📖 Open GUI and toggle 'Auto Farm' to start")