--[[
    MAIN - Auto Farm Hub with FSM
    
    Architecture:
    - Data.lua: Island/Mob data
    - FSM.lua: State machine logic
    - GUI.lua: User interface
]]

print("🍎 Auto Farm Hub - Loading...")

--=== CONFIG ===--
local BASE_URL = "https://raw.githubusercontent.com/longgamer998-code/SourceBloxFruit/main/"

--=== SHARED SETTINGS ===--
local Settings = {
    AutoFarm = false,
    AutoEquip = false,
    CurrentLevel = 0,
    CurrentSea = 1,
    CurrentIsland = "--",
    CurrentMob = "--"
}

--=== LOAD MODULES ===--
local function LoadModule(name)
    local url = BASE_URL .. name .. ".lua"
    local success, result = pcall(function()
        return loadstring(game:HttpGet(url))()
    end)
    
    if success then
        print("✅ Loaded:", name)
        return result
    else
        warn("❌ Failed to load:", name, result)
        return nil
    end
end

-- Load modules
local Data = LoadModule("Data")
local FSM = LoadModule("FSM")
local GUI = LoadModule("GUI")

if not Data or not FSM or not GUI then
    warn("❌ Auto Farm Hub - Failed to load modules!")
    return
end

--=== INITIALIZE ===--
FSM.Init(Settings, Data)
GUI.Init(Settings, FSM)

--=== START ===--
FSM.Start()
GUI.Create()

print("✅ Auto Farm Hub - Ready!")
print("📊 FSM State Machine Active")
