--[[
    ╔═══════════════════════════════════════════════════╗
    ║           AUTO FARM HUB - CLEAN VERSION           ║
    ║                    Main Loader                    ║
    ╚═══════════════════════════════════════════════════╝
]]

-- Config URLs (thay link của bạn ở đây)
local Config = {
    DataURL = "https://raw.githubusercontent.com/longgamer998-code/SourceBloxFruit/main/Data.lua",
    FunctionsURL = "https://raw.githubusercontent.com/longgamer998-code/SourceBloxFruit/main/Functions.lua",
    GUIURL = "https://raw.githubusercontent.com/longgamer998-code/SourceBloxFruit/main/GUI.lua",
}

-- Settings (shared giữa các module)
local Settings = {
    AutoFarm = false,
    AutoQuest = false,
    KillAura = false,
    BringMob = false,
    AutoEquip = false,
    SelectedWeapon = nil,
    CurrentLevel = 0,
    CurrentSea = 1,
    CurrentIsland = nil,
    CurrentMob = nil,
}

-- Load module từ URL
local function loadModule(url)
    local success, result = pcall(function()
        return loadstring(game:HttpGet(url))()
    end)
    
    if success then
        return result
    else
        warn("Failed to load:", url, result)
        return nil
    end
end

-- Main
print("🍎 Auto Farm Hub - Loading...")

local Data = loadModule(Config.DataURL)
local Functions = loadModule(Config.FunctionsURL)
local GUI = loadModule(Config.GUIURL)

if Data and Functions and GUI then
    -- Init modules
    Functions.Init(Settings, Data)
    GUI.Init(Settings, Functions)
    
    -- Create GUI
    GUI.Create()
    
    print("✅ Auto Farm Hub - Loaded!")
else
    warn("❌ Auto Farm Hub - Failed to load modules!")
end
