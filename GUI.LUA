-- ╔══════════════════════════════════════════════════════════╗
-- ║  GUI.LUA - Auto disable Fast Attack khi bật Auto Farm    ║
-- ╚══════════════════════════════════════════════════════════╝

local GUI = {}

function GUI.create(Config, Core)
    print("Loading GUI...")
    
    local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
    local Window = Library. CreateLib("🏴‍☠️ Blox Fruits Auto Farm V2.4 FINAL", "DarkTheme")
    
    local MainTab = Window:NewTab("Main")
    local FarmSection = MainTab:NewSection("⚔️ Auto Farm")
    
    local weaponList = Core.getPlayerWeapons()
    local weaponDropdown
    
    weaponDropdown = FarmSection:NewDropdown("Select Weapon", "Choose weapon", weaponList, function(selected)
        Config.Settings.SelectedWeapon = selected
        Core.logSuccess("Weapon selected: " .. selected)
        
        if Config.Settings.AutoEquipWeapon then
            Core.equipWeapon(selected, Config)
        end
    end)
    
    FarmSection:NewButton("🔄 Refresh Weapons", "Reload weapon list", function()
        weaponList = Core.getPlayerWeapons()
        
        pcall(function()
            weaponDropdown: Refresh(weaponList)
        end)
        
        print("✅ Weapons refreshed!")
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
    
    -- ✅ FIX: Auto tắt Fast Attack khi bật Auto Farm
    FarmSection: NewToggle("Auto Farm", "Start/Stop", function(state)
        print("\n[Button] Auto Farm toggled: " .. (state and "ON" or "OFF"))
        
        if state then
            if Core.isAutoFarmRunning() then
                local status = Core.getAutoFarmStatus()
                warn("⚠️ Auto Farm already running!")
                warn("⚠️ Thread status: " .. status)
                warn("⚠️ Please stop current farm first!")
                
                Config.Settings.Enabled = false
                return
            end
            
            -- ✅ Tự động tắt Fast Attack để tránh conflict
            if Config.Settings.FastAttack then
                Config.Settings.FastAttack = false
                Core.stopFastAttack()
                warn("⚠️ Auto-disabled Fast Attack (conflict with Auto Farm)")
            end
            
            Config.Settings.Enabled = true
            
            Core.logSuccess("🚀 AUTO FARM ENABLED")
            print("[Button] Calling startAutoFarm()...")
            
            local startSuccess = Core.startAutoFarm(Config)
            
            if not startSuccess then
                warn("❌ Failed to start Auto Farm!")
                Config.Settings.Enabled = false
                return
            end
            
            task.wait(0.5)
            if Core.isAutoFarmRunning() then
                Core.logSuccess("✅ Auto Farm is now running")
                Core.logSuccess("✅ Thread status: " .. Core.getAutoFarmStatus())
            else
                warn("⚠️ Auto Farm may not be running properly!")
            end
            
        else
            warn("⛔ AUTO FARM DISABLED")
            
            Config.Settings.Enabled = false
            
            if not Core.isAutoFarmRunning() then
                print("[Button] No active farm to stop")
                return
            end
            
            print("[Button] Calling stopAutoFarm()...")
            Core.stopAutoFarm()
            
            task.wait(0.5)
            if Core.isAutoFarmRunning() then
                warn("⚠️ Thread may still be running!")
                warn("⚠️ Thread status: " .. Core.getAutoFarmStatus())
            else
                print("✅ Auto Farm fully stopped")
            end
        end
    end)
    
    FarmSection:NewButton("🔍 Check Thread Status", "Debug info", function()
        print("\n===== THREAD STATUS =====")
        print("Config.Settings.Enabled: " ..  tostring(Config.Settings. Enabled))
        print("Is Running: " .. tostring(Core.isAutoFarmRunning()))
        print("Thread Status: " .. Core.getAutoFarmStatus())
        print("=========================\n")
    end)
    
    FarmSection:NewToggle("Auto Quest", "Auto accept", function(state)
        Config.Settings.AutoQuest = state
        print("Auto Quest: " ..  (state and "ON" or "OFF"))
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
    
    -- ✅ WARNING: Fast Attack sẽ conflict với Auto Farm
    CombatSection:NewLabel("⚠️ WARNING: Don't use with Auto Farm!")
    CombatSection:NewLabel("Fast Attack will auto-disable when")
    CombatSection:NewLabel("you enable Auto Farm")
    CombatSection:NewLabel("")
    
    CombatSection:NewToggle("Fast Attack", "Fast attack (standalone)", function(state)
        Config.Settings.FastAttack = state
        print("Fast Attack: " .. (state and "ON" or "OFF"))
        
        if state then
            if Config.Settings. Enabled then
                warn("⚠️ Cannot enable Fast Attack while Auto Farm is running!")
                Config.Settings.FastAttack = false
                return
            end
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
        TPSection:NewButton(island.name, "TP", function()
            print("Teleporting to " .. island.name)
            if Core.smartTeleport(island.pos, true, Config) then
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
        print("Player:  " .. game.Players.LocalPlayer.Name)
        print("Level: " ..  tostring(Core.getPlayerLevel()))
        print("Weapon: " .. Config.Settings. SelectedWeapon)
        print("Quest: " .. Config.Settings.CurrentQuest)
        print("Mobs Killed: " .. tostring(Config.Settings.MobsKilled))
        print("Quests Done: " .. tostring(Config. Settings.QuestsCompleted))
        print("Auto Farm Running: " .. tostring(Core.isAutoFarmRunning()))
        print("Thread Status: " .. Core.getAutoFarmStatus())
        print("===========================\n")
    end)
    
    StatsSection:NewButton("🔄 Reset Counters", "Reset", function()
        Config.Settings.MobsKilled = 0
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
        debug = debug .. "Auto Farm Running: " .. tostring(Core. isAutoFarmRunning()) .. "\n"
        debug = debug .. "Thread Status: " .. Core.getAutoFarmStatus() .. "\n"
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
    InfoSection:NewLabel("🏴‍☠️ Auto Farm V2.4 FINAL")
    InfoSection:NewLabel("✅ Fixed HP tracking")
    InfoSection:NewLabel("✅ Multi-method attack")
    InfoSection:NewLabel("✅ Auto-disable conflict")
    InfoSection:NewLabel("👤 patrick31frag")
    InfoSection:NewLabel("=======================")
    InfoSection:NewLabel("")
    InfoSection:NewLabel("✨ How to use:")
    InfoSection:NewLabel("1. Enable 'Auto Farm' ONLY")
    InfoSection:NewLabel("2. Don't enable 'Fast Attack'")
    InfoSection:NewLabel("3. Check Console for stats")
    InfoSection:NewLabel("")
    InfoSection:NewLabel("Fast Attack = Standalone mode")
    InfoSection:NewLabel("(for manual farming only)")
    
    print("✅ GUI loaded successfully!")
end

return GUI
