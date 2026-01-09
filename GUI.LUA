-- ╔══════════════════════════════════════════════════════════╗
-- ║  GUI.LUA - GUI Interface Only                            ║
-- ╚══════════════════════════════════════════════════════════╝

local GUI = {}

function GUI.create(Config, Core)
    print("Loading GUI...")
    
    local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
    local Window = Library. CreateLib("🏴‍☠️ Blox Fruits Auto Farm V2.3", "DarkTheme")
    
    local MainTab = Window:NewTab("Main")
    local FarmSection = MainTab:NewSection("⚔️ Auto Farm")
    
    local weaponList = Core.getPlayerWeapons()
    FarmSection:NewDropdown("Select Weapon", "Choose weapon", weaponList, function(selected)
        Config.Settings.SelectedWeapon = selected
        Core.logSuccess("Weapon selected: " .. selected)
        
        if Config.Settings.AutoEquipWeapon then
            Core.equipWeapon(selected, Config)
        end
    end)
    
    FarmSection:NewButton("🔄 Refresh Weapons", "Reload weapon list", function()
        weaponList = Core.getPlayerWeapons()
        print("Weapons found:")
        for i, weapon in ipairs(weaponList) do
            print("  " .. tostring(i) .. ". " .. weapon)
        end
        Core.logSuccess("Found " .. tostring(#weaponList) .. " weapons")
    end)
    
    FarmSection:NewToggle("Auto Equip Weapon", "Auto equip weapon", function(state)
        Config.Settings.AutoEquipWeapon = state
        print("Auto Equip:  " .. (state and "ON" or "OFF"))
    end)
    
    FarmSection: NewToggle("Debug Mode", "Enable detailed logs", function(state)
        Config.Settings.DebugMode = state
        print("Debug Mode:  " .. (state and "ON" or "OFF"))
    end)
    
    FarmSection: NewToggle("Auto Farm", "Start/Stop", function(state)
        Config.Settings.Enabled = state
        
        if state then
            Core.logSuccess("AUTO FARM ENABLED")
            task.spawn(function() Core.autoFarmLoop(Config) end)
            if Config.Settings.FastAttack then
                Core.startFastAttack(Config)
            end
        else
            warn("AUTO FARM DISABLED")
            Core.stopTween()
            Core.stopFastAttack()
        end
    end)
    
    FarmSection:NewToggle("Auto Quest", "Auto accept", function(state)
        Config.Settings.AutoQuest = state
        print("Auto Quest: " .. (state and "ON" or "OFF"))
    end)
    
    FarmSection:NewSlider("Farm Distance", "Height above mob", 30, 5, function(value)
        Config.Settings.FarmDistance = value
        print("Farm Distance: " .. tostring(value))
    end)
    
    FarmSection:NewButton("🔍 Show Best Quest", "Check best", function()
        local location, quest = Core.findBestQuest(Config)
        if quest then
            print("=======================")
            print("BEST QUEST")
            print("=======================")
            print("Quest: " .. quest.Name)
            print("Level: " .. tostring(quest. LevelReq))
            print("Location: " .. location)
            Core.logSuccess("Best quest found!")
        else
            Core.logError("No quest found")
        end
    end)
    
    local CombatTab = Window:NewTab("Combat")
    local CombatSection = CombatTab:NewSection("⚔️ Combat")
    
    CombatSection:NewToggle("Fast Attack", "Fast attack", function(state)
        Config.Settings. FastAttack = state
        print("Fast Attack: " .. (state and "ON" or "OFF"))
        
        if state and Config.Settings.Enabled then
            Core.startFastAttack(Config)
        else
            Core.stopFastAttack()
        end
    end)
    
    CombatSection:NewToggle("Auto Haki", "Auto Haki", function(state)
        Config.Settings.AutoHaki = state
        print("Auto Haki: " .. (state and "ON" or "OFF"))
    end)
    
    CombatSection:NewToggle("Safe Teleport", "Use tween", function(state)
        Config.Settings.SafeTeleport = state
        print("Safe Teleport: " .. (state and "ON" or "OFF"))
    end)
    
    CombatSection:NewSlider("Tween Speed", "Speed", 300, 100, function(value)
        Config.Settings.TweenSpeed = value
        print("Tween Speed: " .. tostring(value))
    end)
    
    local TeleportTab = Window:NewTab("Teleport")
    local TPSection = TeleportTab:NewSection("🗺️ Teleport")
    
    for _, island in ipairs(Config.IslandLocations) do
        TPSection: NewButton(island.name, "TP", function()
            print("Teleporting to " .. island.name)
            if Core.smartTeleport(island. pos, true, Config) then
                Core.logSuccess("Arrived at " .. island.name)
            else
                Core.logError("Teleport failed")
            end
        end)
    end
    
    local StatsTab = Window:NewTab("Stats")
    local StatsSection = StatsTab:NewSection("📊 Stats")
    
    StatsSection:NewButton("📈 Show Stats", "Display", function()
        print("\n===========================")
        print("PLAYER STATS")
        print("===========================")
        print("Player:  " .. game. Players.LocalPlayer.Name)
        print("Level: " .. tostring(Core.getPlayerLevel()))
        print("Weapon: " .. Config.Settings. SelectedWeapon)
        print("Quest: " .. Config.Settings.CurrentQuest)
        print("Mobs Killed: " .. tostring(Config.Settings.MobsKilled))
        print("Quests Done: " .. tostring(Config. Settings.QuestsCompleted))
        print("===========================\n")
    end)
    
    StatsSection:NewButton("🔄 Reset Counters", "Reset", function()
        Config.Settings. MobsKilled = 0
        Config.Settings.QuestsCompleted = 0
        Core.logSuccess("Counters reset")
    end)
    
    local ConsoleTab = Window:NewTab("Console")
    local ConsoleSection = ConsoleTab:NewSection("🖥️ Console")
    
    ConsoleSection:NewButton("📋 Copy All Logs", "Clipboard", function()
        if setclipboard then
            setclipboard(Core.getConsoleText(Config))
            Core.logSuccess("Copied!")
        else
            Core.logError("Clipboard unavailable")
        end
    end)
    
    ConsoleSection:NewButton("❌ Copy Errors Only", "Errors", function()
        if setclipboard then
            setclipboard(Core.getErrorsOnly(Config))
            Core.logSuccess("Errors copied!")
        else
            print(Core.getErrorsOnly(Config))
        end
    end)
    
    ConsoleSection: NewButton("🎯 Copy Combat Debug", "Combat stats", function()
        if setclipboard then
            setclipboard(Core.getCombatDebug(Config))
            Core.logSuccess("Combat debug copied!")
        else
            print(Core. getCombatDebug(Config))
        end
    end)
    
    ConsoleSection:NewButton("🔍 Show Combat Debug", "Show stats", function()
        print("\n" .. Core.getCombatDebug(Config))
    end)
    
    ConsoleSection:NewButton("🗑️ Clear Console", "Clear", function()
        Core.clearConsole(Config)
    end)
    
    ConsoleSection:NewButton("🔄 Reset Combat Stats", "Reset", function()
        Config.CombatDebug = {
            AttackAttempts = 0,
            SuccessfulHits = 0,
            WeaponEquipFails = 0,
            ClickAttempts = 0,
            LastMobHealth = 0,
            HealthChanges = 0,
            PositionErrors = 0,
            LastAttackTime = 0,
        }
        Core.logSuccess("Combat stats reset!")
    end)
    
    ConsoleSection:NewButton("💾 Export Debug", "Full export", function()
        local debug = "=== DEBUG EXPORT ===\n"
        debug = debug .. "Player: " .. game.Players.LocalPlayer.Name .. "\n"
        debug = debug .. "Level: " .. tostring(Core.getPlayerLevel()) .. "\n"
        debug = debug .. "Weapon: " .. Config.Settings. SelectedWeapon .. "\n"
        debug = debug .. "\n" .. Core.getCombatDebug(Config)
        debug = debug .. "\n" .. Core.getConsoleText(Config)
        
        if setclipboard then
            setclipboard(debug)
            Core.logSuccess("Full export copied!")
        else
            print(debug)
        end
    end)
    
    local InfoTab = Window:NewTab("Info")
    local InfoSection = InfoTab:NewSection("ℹ️ Info")
    
    InfoSection:NewLabel("=======================")
    InfoSection:NewLabel("🏴‍☠️ Auto Farm V2.3")
    InfoSection:NewLabel("🐛 Combat Debug System")
    InfoSection:NewLabel("👤 patrick31frag")
    InfoSection:NewLabel("=======================")
    InfoSection:NewLabel("")
    InfoSection:NewLabel("✨ Features:")
    InfoSection:NewLabel("🔍 Position tracking")
    InfoSection:NewLabel("💥 Attack hit detection")
    InfoSection:NewLabel("⚔️ Weapon equip tracking")
    InfoSection:NewLabel("🎯 Click attempt counter")
    InfoSection:NewLabel("📊 Combat statistics")
    InfoSection:NewLabel("")
    InfoSection:NewLabel("Enable 'Debug Mode' in Main")
    InfoSection:NewLabel("Check Console for details")
    
    print("GUI loaded successfully!")
end

return GUI
