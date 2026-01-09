local GUI = {}

function GUI.create(Config, Core)
    print("Loading GUI...")
    
    local success, Library = pcall(function()
        return loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
    end)
    
    if not success then
        warn("❌ Failed to load GUI library!")
        warn("Error: " .. tostring(Library))
        return
    end
    
    local Window = Library. CreateLib("🏴‍☠️ Blox Fruits Auto Farm V2.5", "DarkTheme")
    
    local MainTab = Window:NewTab("Main")
    local FarmSection = MainTab:NewSection("⚔️ Auto Farm")
    
    local weaponList = Core.getPlayerWeapons()
    local weaponDropdown
    
    weaponDropdown = FarmSection:NewDropdown("Select Weapon", "Choose weapon", weaponList, function(selected)
        Config.Settings.SelectedWeapon = selected
        print("✅ Weapon selected: " ..  selected)
        
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
    end)
    
    FarmSection:NewToggle("Auto Equip Weapon", "Auto equip", function(state)
        Config.Settings.AutoEquipWeapon = state
        print("Auto Equip: " .. (state and "ON" or "OFF"))
    end)
    
    FarmSection:NewToggle("Auto Farm", "Start/Stop", function(state)
        print("\n[Button] Auto Farm toggled: " .. (state and "ON" or "OFF"))
        
        if state then
            if Core.isAutoFarmRunning() then
                warn("⚠️ Auto Farm already running!")
                Config.Settings.Enabled = false
                return
            end
            
            if Config.Settings.FastAttack then
                Config.Settings.FastAttack = false
                Core.stopFastAttack()
                warn("⚠️ Auto-disabled Fast Attack")
            end
            
            Config.Settings.Enabled = true
            
            print("🚀 AUTO FARM ENABLED")
            
            local startSuccess = Core.startAutoFarm(Config)
            
            if not startSuccess then
                warn("❌ Failed to start Auto Farm!")
                Config.Settings.Enabled = false
                return
            end
            
            task.wait(0.5)
            if Core.isAutoFarmRunning() then
                print("✅ Auto Farm is now running")
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
            
            Core.stopAutoFarm()
            
            task.wait(0.5)
            if not Core.isAutoFarmRunning() then
                print("✅ Auto Farm fully stopped")
            end
        end
    end)
    
    FarmSection:NewToggle("Auto Quest", "Auto accept quest", function(state)
        Config.Settings.AutoQuest = state
        print("Auto Quest:  " .. (state and "ON" or "OFF"))
    end)
    
    FarmSection: NewSlider("Farm Distance", "Distance from mob", 30, 5, function(value)
        Config.Settings.FarmDistance = value
        print("Farm Distance: " .. tostring(value))
    end)
    
    local CombatTab = Window:NewTab("Combat")
    local CombatSection = CombatTab:NewSection("⚔️ Combat")
    
    CombatSection:NewLabel("⚠️ WARNING: Don't use with Auto Farm!")
    CombatSection:NewLabel("")
    
    CombatSection:NewToggle("Fast Attack", "Standalone mode", function(state)
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
    
    CombatSection:NewToggle("Auto Haki", "Auto enable Haki", function(state)
        Config.Settings.AutoHaki = state
        print("Auto Haki: " .. (state and "ON" or "OFF"))
    end)
    
    CombatSection:NewToggle("Safe Teleport", "Use tween for long distance", function(state)
        Config.Settings.SafeTeleport = state
        print("Safe Teleport: " .. (state and "ON" or "OFF"))
    end)
    
    CombatSection:NewSlider("Tween Speed", "Speed of tween", 300, 100, function(value)
        Config.Settings.TweenSpeed = value
        print("Tween Speed: " .. tostring(value))
    end)
    
    local StatsTab = Window:NewTab("Stats")
    local StatsSection = StatsTab:NewSection("📊 Stats")
    
    StatsSection:NewButton("📈 Show Stats", "Display current stats", function()
        print("\n===========================")
        print("PLAYER STATS")
        print("===========================")
        print("Player: " .. game.Players.LocalPlayer.Name)
        print("Level: " .. tostring(Core.getPlayerLevel()))
        print("Weapon: " .. Config.Settings. SelectedWeapon)
        print("Quest: " .. Config.Settings.CurrentQuest)
        print("Mobs Killed: " .. tostring(Config.Settings.MobsKilled))
        print("Quests Done: " .. tostring(Config. Settings.QuestsCompleted))
        print("Auto Farm Running: " .. tostring(Core.isAutoFarmRunning()))
        print("===========================\n")
    end)
    
    StatsSection:NewButton("🔄 Reset Counters", "Reset kill counters", function()
        Config.Settings.MobsKilled = 0
        Config.Settings.QuestsCompleted = 0
        print("✅ Counters reset")
    end)
    
    local ConsoleTab = Window:NewTab("Console")
    local ConsoleSection = ConsoleTab:NewSection("🖥️ Console")
    
    ConsoleSection:NewButton("📋 Copy All Logs", "Copy to clipboard", function()
        if setclipboard then
            setclipboard(Core.getConsoleText(Config))
            print("✅ Copied!")
        else
            print("❌ Clipboard unavailable")
        end
    end)
    
    ConsoleSection:NewButton("❌ Copy Errors Only", "Copy errors", function()
        if setclipboard then
            setclipboard(Core.getErrorsOnly(Config))
            print("✅ Errors copied!")
        else
            print(Core.getErrorsOnly(Config))
        end
    end)
    
    ConsoleSection: NewButton("🎯 Show Combat Debug", "Show combat stats", function()
        print("\n" .. Core.getCombatDebug(Config))
    end)
    
    ConsoleSection:NewButton("🗑️ Clear Console", "Clear all logs", function()
        Core.clearConsole(Config)
    end)
    
    local InfoTab = Window:NewTab("Info")
    local InfoSection = InfoTab:NewSection("ℹ️ Info")
    
    InfoSection:NewLabel("=======================")
    InfoSection:NewLabel("🏴‍☠️ Auto Farm V2.5 FINAL")
    InfoSection:NewLabel("✅ Fixed 3 lỗi theo checklist")
    InfoSection:NewLabel("✅ Vị trí:  Sau + Lệch + Cao")
    InfoSection:NewLabel("✅ Không spam CFrame")
    InfoSection:NewLabel("👤 patrick31frag")
    InfoSection:NewLabel("=======================")
    
    print("✅ GUI loaded successfully!")
end

return GUI
