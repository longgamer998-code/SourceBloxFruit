-- ╔══════════════════════════════════════════════════════════╗
-- ║  GUI.LUA - PROFESSIONAL THREAD CONTROL                    ║
-- ║  ✅ Cách 1: Thread tracking full integration              ║
-- ╚══════════════════════════════════════════════════════════╝

local GUI = {}

function GUI.create(Config, Core)
    print("Loading GUI...")
    
    local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
    local Window = Library. CreateLib("🏴‍☠️ Blox Fruits Auto Farm V2.3 PRO", "DarkTheme")
    
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
    
    FarmSection: NewToggle("Debug Mode", "Enable detailed logs", function(state)
        Config.Settings.DebugMode = state
        print("Debug Mode: " .. (state and "ON" or "OFF"))
    end)
    
    -- ╔══════════════════════════════════════════════════════════╗
    -- ║  AUTO FARM BUTTON - PROFESSIONAL THREAD CONTROL           ║
    -- ╚══════════════════════════════════════════════════════════╝
    
    FarmSection:NewToggle("Auto Farm", "Start/Stop", function(state)
        print("\n[Button] Auto Farm toggled:  " .. (state and "ON" or "OFF"))
        
        if state then
            -- ═══ START AUTO FARM ═══
            
            -- Step 1: Check if already running
            if Core.isAutoFarmRunning() then
                local status = Core.getAutoFarmStatus()
                warn("⚠️ Auto Farm already running!")
                warn("⚠️ Thread status: " .. status)
                warn("⚠️ Please stop current farm first!")
                
                -- Force set config to false để sync với UI
                Config.Settings. Enabled = false
                return
            end
            
            -- Step 2: Set config enabled
            Config.Settings.Enabled = true
            
            -- Step 3: Start auto farm với validation
            Core.logSuccess("🚀 AUTO FARM ENABLED")
            print("[Button] Calling startAutoFarm()...")
            
            local startSuccess = Core.startAutoFarm(Config)
            
            if not startSuccess then
                warn("❌ Failed to start Auto Farm!")
                Config.Settings.Enabled = false
                return
            end
            
            -- Step 4: Start fast attack if enabled
            if Config.Settings. FastAttack then
                print("[Button] Starting Fast Attack...")
                Core.startFastAttack(Config)
            end
            
            -- Step 5: Verify running
            task.wait(0.5)
            if Core.isAutoFarmRunning() then
                Core.logSuccess("✅ Auto Farm is now running")
                Core.logSuccess("✅ Thread status: " .. Core.getAutoFarmStatus())
            else
                warn("⚠️ Auto Farm may not be running properly!")
            end
            
        else
            -- ═══ STOP AUTO FARM ═══
            
            warn("⛔ AUTO FARM DISABLED")
            
            -- Step 1: Set config disabled
            Config.Settings. Enabled = false
            
            -- Step 2: Check if running
            if not Core.isAutoFarmRunning() then
                print("[Button] No active farm to stop")
                return
            end
            
            -- Step 3: Stop auto farm
            print("[Button] Calling stopAutoFarm()...")
            Core.stopAutoFarm()
            
            -- Step 4:  Verify stopped
            task.wait(0.5)
            if Core.isAutoFarmRunning() then
                warn("⚠️ Thread may still be running!")
                warn("⚠️ Thread status: " .. Core.getAutoFarmStatus())
            else
                print("✅ Auto Farm fully stopped")
            end
        end
    end)
    
    -- ╔══════════════════════════════════════════════════════════╗
    -- ║  THREAD STATUS BUTTON (DEBUG)                             ║
    -- ╚══════════════════════════════════════════════════════════╝
    
    FarmSection:NewButton("🔍 Check Thread Status", "Debug info", function()
        print("\n===== THREAD STATUS =====")
        print("Config.Settings.Enabled: " ..  tostring(Config.Settings. Enabled))
        print("Is Running: " .. tostring(Core.isAutoFarmRunning()))
        print("Thread Status: " .. Core.getAutoFarmStatus())
        print("=========================\n")
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
            print("Level: " .. tostring(quest.LevelReq))
            print("Location: " .. location)
            Core.logSuccess("Best quest found!")
        else
            Core.logError("No quest found")
        end
    end)
    
    local CombatTab = Window:NewTab("Combat")
    local CombatSection = CombatTab:NewSection("⚔️ Combat")
    
    CombatSection:NewToggle("Fast Attack", "Fast attack", function(state)
        Config.Settings.FastAttack = state
        print("Fast Attack:  " .. (state and "ON" or "OFF"))
        
        if state and Config.Settings. Enabled then
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
        print("Safe Teleport: " ..  (state and "ON" or "OFF"))
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
            print(Core.getCombatDebug(Config))
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
    InfoSection:NewLabel("🏴‍☠️ Auto Farm V2.3 PRO")
    InfoSection:NewLabel("🧵 Thread Tracking System")
    InfoSection:NewLabel("👤 patrick31frag")
    InfoSection:NewLabel("=======================")
    InfoSection:NewLabel("")
    InfoSection:NewLabel("✨ Features:")
    InfoSection:NewLabel("✅ Professional thread control")
    InfoSection:NewLabel("✅ Coroutine status tracking")
    InfoSection:NewLabel("✅ Safe thread cancellation")
    InfoSection:NewLabel("✅ Duplicate prevention")
    InfoSection:NewLabel("✅ Auto cleanup")
    InfoSection:NewLabel("✅ Real-time validation")
    InfoSection:NewLabel("")
    InfoSection:NewLabel("Use 'Check Thread Status'")
    InfoSection:NewLabel("to debug farm state!")
    
    print("✅ GUI loaded successfully!")
end

return GUI
