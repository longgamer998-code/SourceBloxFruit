-- ╔══════════════════════════════════════════════════════════╗
-- ║  MAIN. LUA - BLOX FRUITS AUTO FARM V2. 5 FINAL             ║
-- ╚══════════════════════════════════════════��═══════════════╝

print("🔄 Loading Blox Fruits Auto Farm...")

-- Load modules
local Config = loadstring(game:HttpGet("https://raw.githubusercontent.com/longgamer998-code/SourceBloxFruit/main/CONFIG.LUA"))()
local Core = loadstring(game:HttpGet("https://raw.githubusercontent.com/longgamer998-code/SourceBloxFruit/main/CORE.LUA"))()
local GUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/longgamer998-code/SourceBloxFruit/main/GUI.LUA"))()

-- Init
Core.initConsole(Config)
print("✅ Console ready")

-- Player info
print("\n============================================================")
print("👤 Player:  " .. game.Players.LocalPlayer.Name)
print("⭐ Level: " .. tostring(game.Players.LocalPlayer.Data.Level. Value))
print("💰 Beli: " .. tostring(game. Players.LocalPlayer.Data. Beli.Value))
print("============================================================\n")

-- Create GUI
print("🎨 Creating GUI...")
GUI.create(Config, Core)

print("\n🔫 Detecting weapons...")

print("\n============================================================")
print("✅ SCRIPT LOADED SUCCESSFULLY!")
print("============================================================")
print("📖 How to use:")
print("  1. Select weapon")
print("  2. Toggle 'Auto Farm' to start")
print("  3. Check Console tab for stats")
print("============================================================\n")

print("🌐 https://raw.githubusercontent.com/longgamer998-code/SourceBloxFruit/main/")
print("📅 " .. os.date("%Y-%m-%d %H:%M:%S"))
print("✨ Ready!")
