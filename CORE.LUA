-- ╔══════════════════════════════════════════════════════════╗
-- ║  CORE. LUA - FIX 3 LỖI + RETURN CORE                       ║
-- ╚══════════════════════════════════════════════════════════╝

local Core = {}

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local VirtualUser = game:GetService("VirtualUser")
local VirtualInputManager = game:GetService("VirtualInputManager")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ScriptContext = game:GetService("ScriptContext")

local player = Players.LocalPlayer
local currentTween = nil
local fastAttackConnection = nil
local autoFarmThread = nil
local oldPrint = print
local oldWarn = warn

local attackStats = {
    totalAttempts = 0,
    remoteSuccess = 0,
    clickButton = 0
}

function Core.initConsole(Config)
    local function addLog(message, logType)
        logType = logType or "INFO"
        local timestamp = os.date("%H:%M:%S")
        
        table.insert(Config.ConsoleLog, {
            time = timestamp,
            type = logType,
            message = tostring(message),
            stack = debug.traceback("", 3):sub(1, 300)
        })
        
        if #Config.ConsoleLog > Config.MAX_LOGS then
            table.remove(Config.ConsoleLog, 1)
        end
        
        local prefix = ({ERROR = "❌", WARN = "⚠️", SUCCESS = "✅", INFO = "ℹ️", DEBUG = "🔍"})[logType] or "ℹ️"
        local output = string.format("[%s] %s %s", timestamp, prefix, message)
        
        if logType == "ERROR" then oldWarn(output) else oldPrint(output) end
    end
    
    print = function(... ) addLog(table.concat({...}, " "), "INFO") end
    warn = function(...) addLog(table.concat({...}, " "), "WARN") end
    
    Core.logError = function(msg) addLog(msg, "ERROR") end
    Core.logSuccess = function(msg) addLog(msg, "SUCCESS") end
    Core.logDebug = function(msg) addLog(msg, "DEBUG") end
    
    ScriptContext.Error: Connect(function(message, stackTrace)
        addLog("RUNTIME ERROR: " .. message, "ERROR")
        if stackTrace then addLog("Stack: " .. stackTrace: sub(1, 200), "ERROR") end
    end)
    
    Core.safePcall = function(func, ...)
        local args = {...}
        local ok, result = xpcall(function()
            return func(unpack(args))
        end, function(err)
            return tostring(err) .. "\n" .. debug.traceback("", 2)
        end)
        
        if not ok then
            addLog("XPCALL ERROR:\n" .. tostring(result), "ERROR")
        end
        return ok, result
    end
end

function Core.getConsoleText(Config)
    local output = "===== BLOX FRUITS AUTO FARM CONSOLE =====\n"
    output = output .. "Player: " .. player.Name .. "\n"
    output = output ..  "Level: " .. tostring(player.Data.Level. Value or "? ") .. "\n"
    output = output .. "Total Logs: " .. #Config.ConsoleLog .. "\n"
    output = output .. "Timestamp: " .. os.date("%Y-%m-%d %H:%M:%S") .. "\n"
    output = output .. string.rep("=", 45) .. "\n\n"
    
    for _, log in ipairs(Config.ConsoleLog) do
        local prefix = ({ERROR = "[❌]", WARN = "[⚠️]", SUCCESS = "[✅]", INFO = "[ℹ️]", DEBUG = "[🔍]"})[log.type] or "[ℹ️]"
        output = output .. string.format("[%s] %s %s\n", log.time, prefix, log.message)
    end
    
    return output
end

function Core. getErrorsOnly(Config)
    local output = "===== ERRORS & WARNINGS =====\n"
    local count = 0
    for _, log in ipairs(Config. ConsoleLog) do
        if log.type == "ERROR" or log.type == "WARN" then
            count = count + 1
            output = output .. string.format("[%s] [%s] %s\n", log.time, log.type, log.message)
        end
    end
    output = output .. "\nTotal:  " .. count .. "\n"
    return output
end

function Core.getCombatDebug(Config)
    local output = "===== COMBAT DEBUG STATS =====\n"
    output = output .. "Attack Attempts: " .. tostring(Config.CombatDebug.AttackAttempts) .. "\n"
    output = output .. "Successful Hits: " .. tostring(Config. CombatDebug.SuccessfulHits) .. "\n"
    output = output .. "Health Changes: " .. tostring(Config. CombatDebug.HealthChanges) .. "\n"
    output = output .. "Weapon Equip Fails: " .. tostring(Config. CombatDebug.WeaponEquipFails) .. "\n"
    output = output ..  "Position Errors: " .. tostring(Config.CombatDebug. PositionErrors) .. "\n"
    
    local hitRate = Config.CombatDebug.AttackAttempts > 0 and 
        (Config.CombatDebug.SuccessfulHits / Config.CombatDebug. AttackAttempts * 100) or 0
    output = output .. "Hit Rate: " .. tostring(math.floor(hitRate)) .. "%\n"
    output = output .. "\n=== ATTACK METHOD STATS ===\n"
    output = output .. "Total Attempts: " .. attackStats.totalAttempts .. "\n"
    output = output ..  "Remote Success: " .. attackStats.remoteSuccess .. "\n"
    output = output .. "ClickButton1: " .. attackStats.clickButton .. "\n"
    output = output .. "==============================\n"
    return output
end

function Core.clearConsole(Config)
    Config.ConsoleLog = {}
    print("Console cleared")
end

function Core.getCharacter()
    return player.Character or player.CharacterAdded:Wait()
end

function Core.getHRP()
    local char = Core.getCharacter()
    return char and char:FindFirstChild("HumanoidRootPart")
end

function Core.getPlayerLevel()
    local success, level = Core.safePcall(function() 
        return player.Data.Level.Value 
    end)
    return success and level or 1
end

function Core.getPlayerWeapons()
    local weapons = {"Melee"}
    local seen = {["Melee"] = true}
    
    Core.safePcall(function()
        local backpack = player. Backpack
        local character = Core.getCharacter()
        
        for _, item in pairs(backpack:GetChildren()) do
            if item:IsA("Tool") and item.Name ~= "Tool" and not seen[item.Name] then
                table.insert(weapons, item. Name)
                seen[item. Name] = true
            end
        end
        
        for _, item in pairs(character:GetChildren()) do
            if item: IsA("Tool") and item.Name ~= "Tool" and not seen[item.Name] then
                table.insert(weapons, item.Name)
                seen[item.Name] = true
            end
        end
    end)
    
    return weapons
end

function Core.pressKey(key)
    Core.safePcall(function()
        VirtualInputManager:SendKeyEvent(true, key, false, game)
        task.wait(0.05)
        VirtualInputManager:SendKeyEvent(false, key, false, game)
    end)
end

function Core.equipWeapon(weaponName, Config)
    if weaponName == "Melee" or weaponName == "Combat" then
        Core.logDebug("[Equip] Pressing key 1 for Melee")
        Core.pressKey(Enum.KeyCode.One)
        task.wait(0.3)
        Core.logSuccess("[Equip] ✅ Equipped Melee (Hotkey 1)")
        return true
    end
    
    Core.logDebug("[Equip] Pressing key 2 for " .. weaponName)
    Core.pressKey(Enum.KeyCode.Two)
    task.wait(0.3)
    
    local character = Core.getCharacter()
    local equippedTool = character:FindFirstChildOfClass("Tool")
    
    if equippedTool then
        Core.logSuccess("[Equip] ✅ Equipped:  " .. equippedTool.Name ..  " (Hotkey 2)")
        return true
    else
        Core.logError("[Equip] ⚠️ No weapon equipped after keypress")
        return false
    end
end

function Core.stopTween()
    if currentTween then
        Core.safePcall(function() currentTween:Cancel() end)
        currentTween = nil
    end
end

function Core.tweenTo(targetPos, Config)
    local success = Core.safePcall(function()
        local hrp = Core.getHRP()
        if not hrp then
            Core.logError("[Tween] HRP not found for tween")
            return
        end
        
        Core.stopTween()
        
        local distance = (hrp.Position - targetPos).Magnitude
        local duration = math.max(distance / Config.Settings.TweenSpeed, 0.5)
        
        currentTween = TweenService: Create(
            hrp,
            TweenInfo.new(duration, Enum.EasingStyle.Linear),
            {CFrame = CFrame.new(targetPos)}
        )
        
        currentTween:Play()
        currentTween.Completed:Wait()
    end)
    
    return success
end

function Core.smartTeleport(targetPos, forceTween, Config)
    local success = Core.safePcall(function()
        local hrp = Core.getHRP()
        if not hrp then
            Core.logError("[TP] HRP not found")
            return false
        end
        
        local distance = (hrp.Position - targetPos).Magnitude
        local distStr = tostring(math.floor(distance))
        
        if forceTween or (Config.Settings.SafeTeleport and distance > 100) then
            Core.logDebug("[TP] Tween " .. distStr .. " studs")
            Core.tweenTo(targetPos, Config)
        else
            Core.logDebug("[TP] Instant TP " .. distStr ..  " studs")
            hrp.CFrame = CFrame. new(targetPos)
            task.wait(0.3)
        end
        
        return true
    end)
    
    return success
end

function Core.enableHaki(Config)
    if not Config.Settings.AutoHaki then return end
    Core.safePcall(function()
        ReplicatedStorage. Remotes.CommF_:InvokeServer("Buso")
        Core.logDebug("[Haki] Enabled")
    end)
end

function Core.performAttack(Config)
    Core.safePcall(function()
        attackStats.totalAttempts = attackStats.totalAttempts + 1
        
        Core.safePcall(function()
            ReplicatedStorage.Remotes. CommF_:InvokeServer("Combat")
            attackStats.remoteSuccess = attackStats.remoteSuccess + 1
        end)
        
        Core.safePcall(function()
            game:GetService("VirtualUser"):ClickButton1(Vector2.new(0,0))
            attackStats.clickButton = attackStats.clickButton + 1
        end)
        
        Config.CombatDebug. ClickAttempts = Config.CombatDebug.ClickAttempts + 1
    end)
end

do
    local lastFastAttack = 0
    local FAST_ATTACK_INTERVAL = 0.2
    
    function Core.startFastAttack(Config)
        if fastAttackConnection then return end
        
        fastAttackConnection = RunService.Heartbeat:Connect(function()
            if not (Config.Settings.FastAttack and Config.Settings. Enabled) then
                return
            end
            
            local now = tick()
            if now - lastFastAttack < FAST_ATTACK_INTERVAL then
                return
            end
            lastFastAttack = now
            
            Core.safePcall(function()
                local character = Core.getCharacter()
                local humanoid = character and character:FindFirstChild("Humanoid")
                
                if not (humanoid and humanoid.Health > 0) then
                    return
                end
                
                Core.safePcall(function()
                    ReplicatedStorage.Remotes. CommF_:InvokeServer("Combat")
                end)
                
                Core.safePcall(function()
                    game: GetService("VirtualUser"):ClickButton1(Vector2.new(0,0))
                end)
            end)
        end)
        
        print("✅ Fast Attack started")
    end
end

function Core.stopFastAttack()
    if fastAttackConnection then
        fastAttackConnection: Disconnect()
        fastAttackConnection = nil
        print("⛔ Fast Attack stopped")
    end
end

function Core.isAutoFarmRunning()
    if not autoFarmThread then return false end
    
    local ok, status = Core.safePcall(function()
        return coroutine.status(autoFarmThread)
    end)
    
    if not ok or status == "dead" then
        autoFarmThread = nil
        return false
    end
    
    return true
end

function Core. getAutoFarmStatus()
    if not autoFarmThread then return "stopped" end
    
    local ok, status = Core.safePcall(function()
        return coroutine.status(autoFarmThread)
    end)
    
    if not ok then
        autoFarmThread = nil
        return "error"
    end
    
    return status
end

function Core.stopAutoFarm()
    if not autoFarmThread then
        print("[Thread] No thread to stop")
        return
    end
    
    print("[Thread] Stopping auto farm thread...")
    
    Core.safePcall(function()
        task.cancel(autoFarmThread)
    end)
    
    autoFarmThread = nil
    Core.stopTween()
    Core.stopFastAttack()
    
    print("⛔ Auto Farm stopped completely")
end

function Core.startAutoFarm(Config)
    if Core.isAutoFarmRunning() then
        warn("[Thread] ⚠️ Auto Farm already running!")
        warn("[Thread] Status: " .. Core.getAutoFarmStatus())
        return false
    end
    
    if autoFarmThread then
        print("[Thread] Cleaning up old thread...")
        Core.stopAutoFarm()
        task.wait(0.5)
    end
    
    print("[Thread] Starting new auto farm thread...")
    autoFarmThread = task.spawn(function()
        Core.autoFarmLoop(Config)
    end)
    
    task.wait(0.2)
    if Core.isAutoFarmRunning() then
        print("[Thread] ✅ Thread started successfully")
        print("[Thread] Status: " .. Core.getAutoFarmStatus())
        return true
    else
        warn("[Thread] ❌ Failed to start thread")
        autoFarmThread = nil
        return false
    end
end

function Core.findBestQuest(Config)
    local level = Core.getPlayerLevel()
    local bestQuest, bestLocation, bestIndex = nil, nil, 1
    
    for locationName, quests in pairs(Config.QuestData) do
        for idx, quest in ipairs(quests) do
            if quest.LevelReq <= level then
                if not bestQuest or quest.LevelReq > bestQuest. LevelReq then
                    bestQuest = quest
                    bestLocation = locationName
                    bestIndex = idx
                end
            end
        end
    end
    
    return bestLocation, bestQuest, bestIndex
end

function Core.hasActiveQuest()
    local ok, result = Core.safePcall(function()
        local questUI = player. PlayerGui:FindFirstChild("Main")
        if questUI then
            local quest = questUI:FindFirstChild("Quest")
            return quest and quest. Visible
        end
        return false
    end)
    
    return ok and result
end

function Core.acceptQuest(locationName, questIndex, Config)
    local ok, result = Core.safePcall(function()
        local questPos = Config.QuestLocations[locationName]
        if not questPos then
            Core.logError("[Quest] Location not found: " ..  locationName)
            return false
        end
        
        print("[Quest] Traveling to quest giver...")
        if not Core.smartTeleport(questPos, true, Config) then
            Core. logError("[Quest] Failed to teleport to quest giver")
            return false
        end
        
        task.wait(0.5)
        
        local invokeOk, invokeResult = Core.safePcall(function()
            return ReplicatedStorage.Remotes. CommF_:InvokeServer("StartQuest", locationName, questIndex)
        end)
        
        if not invokeOk then
            Core. logError("[Quest] StartQuest invoke failed:  " .. tostring(invokeResult))
            return false
        end
        
        task.wait(0.3)
        
        if Core.hasActiveQuest() then
            Core.logSuccess("[Quest] ✅ Quest accepted!")
            return true
        else
            Core.logError("[Quest] Quest not active after accept")
            return false
        end
    end)
    
    return ok and result
end

function Core.findNearestMob(mobName, Config)
    local ok, mob = Core.safePcall(function()
        local hrp = Core.getHRP()
        if not hrp then return nil end
        
        local nearestMob, nearestDistance = nil, math.huge
        
        for _, enemy in pairs(workspace. Enemies:GetChildren()) do
            if enemy. Name == mobName then
                local enemyHRP = enemy:FindFirstChild("HumanoidRootPart")
                local enemyHumanoid = enemy:FindFirstChild("Humanoid")
                
                if enemyHRP and enemyHumanoid and enemyHumanoid.Health > 0 then
                    local distance = (enemyHRP.Position - hrp.Position).Magnitude
                    if distance < nearestDistance then
                        nearestMob = enemy
                        nearestDistance = distance
                    end
                end
            end
        end
        
        if nearestMob then
            Core.logDebug("[Mob] Found " .. mobName .. " at " .. tostring(math.floor(nearestDistance)) .. " studs")
        end
        
        return nearestMob
    end)
    
    return ok and mob or nil
end

function Core.farmMob(mobName, count, Config)
    local ok = Core.safePcall(function()
        print("🎯 Farming " .. mobName .. " x" .. tostring(count))
        
        if Config.Settings.AutoEquipWeapon then
            print("[Farm] Auto equipping weapon:  " .. Config.Settings. SelectedWeapon)
            Core.equipWeapon(Config.Settings.SelectedWeapon, Config)
            task.wait(0.3)
        end
        
        local killed = 0
        local attempts = 0
        local maxAttempts = 100
        
        while killed < count and Config.Settings.Enabled and attempts < maxAttempts do
            attempts = attempts + 1
            
            local mob = Core.findNearestMob(mobName, Config)
            
            if mob then
                local mobHRP = mob:FindFirstChild("HumanoidRootPart")
                local mobHumanoid = mob:FindFirstChild("Humanoid")
                local mobHead = mob:FindFirstChild("Head")
                
                if not mobHRP or not mobHumanoid then
                    Core.logError("[Mob] ❌ Missing HRP or Humanoid for " .. mobName)
                    task.wait(1)
                    continue
                end
                
                if mobHumanoid.Health <= 0 then
                    Core.logDebug("[Mob] Mob already dead, skipping...")
                    task.wait(0.5)
                    continue
                end
                
                print("[Mob] Target HP: " .. math.floor(mobHumanoid.Health))
                
                local targetPos = mobHead and mobHead.Position or mobHRP.Position
                local hrp = Core.getHRP()
                
                if not hrp then
                    Core.logError("[TP] ❌ Player HRP not found!")
                    task.wait(1)
                    continue
                end
                
                -- ✅ FIX LỖI 1: mobToPlayer vector
                local mobToPlayer = (hrp.Position - targetPos).Unit
                local behindMob = targetPos + mobToPlayer * 6
                
                -- ✅ FIX LỖI 2: Side offset dùng HRP. RightVector
                local sideOffset = hrp.CFrame.RightVector * 2
                
                -- Cao +2. 5 studs
                local farmPos = behindMob + sideOffset + Vector3.new(0, 2.5, 0)
                
                Core.logDebug("[TP] Target:  " .. tostring(targetPos))
                Core.logDebug("[TP] Farm pos: " .. tostring(farmPos))
                
                local tpOK = Core.smartTeleport(farmPos, false, Config)
                if not tpOK then
                    Core.logError("[TP] ❌ Teleport failed!")
                    task.wait(1)
                    continue
                end
                
                task.wait(0.5)
                
                hrp = Core.getHRP()
                if hrp then
                    local actualDistance = (hrp.Position - targetPos).Magnitude
                    print("[TP] ✅ Teleported!  Distance: " .. math.floor(actualDistance) .. " studs")
                    
                    if actualDistance > 15 then
                        Core.logError("[TP] ⚠️ Too far:  " .. math.floor(actualDistance) .. " studs")
                    end
                else
                    Core.logError("[TP] ❌ HRP lost after teleport!")
                    continue
                end
                
                Core.enableHaki(Config)
                task.wait(0.2)
                
                print("[Combat] 🗡️ Starting attack loop...")
                
                local attackCount = 0
                local lastAttackTime = tick()
                local ATTACK_COOLDOWN = 0.06
                
                while mob and mob.Parent and Config.Settings.Enabled do
                    if not mobHumanoid or not mobHumanoid.Parent or mobHumanoid.Health <= 0 then
                        break
                    end
                    
                    attackCount = attackCount + 1
                    Config.CombatDebug.AttackAttempts = Config.CombatDebug.AttackAttempts + 1
                    
                    Core.safePcall(function()
                        local hrp = Core.getHRP()
                        local hpBefore = mobHumanoid.Health
                        
                        if hrp and mobHRP and mobHRP.Parent then
                            -- ✅ FIX LỖI 3: Chỉ xoay mặt khi Dot < 0.98
                            local dir = (mobHRP.Position - hrp. Position).Unit
                            local look = hrp.CFrame. LookVector
                            
                            if look: Dot(dir) < 0.98 then
                                hrp.CFrame = CFrame. new(hrp.Position, mobHRP.Position)
                                Core.logDebug("[Combat] Rotated to face mob")
                            end
                            
                            Core.logDebug("[Combat] Attack #" .. tostring(attackCount))
                            
                            local now = tick()
                            if now - lastAttackTime >= ATTACK_COOLDOWN then
                                Core.performAttack(Config)
                                lastAttackTime = now
                                
                                task.wait(0.03)
                                
                                if mobHumanoid and mobHumanoid.Parent then
                                    local hpAfter = mobHumanoid. Health
                                    
                                    if hpAfter < hpBefore then
                                        local damage = hpBefore - hpAfter
                                        Config.CombatDebug. HealthChanges = Config.CombatDebug.HealthChanges + 1
                                        Config.CombatDebug. SuccessfulHits = Config.CombatDebug.SuccessfulHits + 1
                                        
                                        print("[Combat] 💥 HIT!  Damage: " .. math.floor(damage) .. " | HP: " .. math.floor(hpAfter))
                                    else
                                        if attackCount % 30 == 0 then
                                            Core.logError("[Combat] ⚠️ No damage after 30 attacks!  HP: " .. math.floor(hpAfter))
                                        end
                                    end
                                end
                            end
                        else
                            Core.logError("[Combat] ❌ HRP or MobHRP lost!")
                            break
                        end
                    end)
                    
                    task.wait(0.03)
                    
                    if attackCount > 300 then
                        Core.logError("[Combat] ⏱️ Timeout (300 attacks)")
                        break
                    end
                end
                
                if not mob. Parent or not mobHumanoid or not mobHumanoid.Parent or mobHumanoid.Health <= 0 then
                    killed = killed + 1
                    Config.Settings.MobsKilled = Config.Settings.MobsKilled + 1
                    Core.logSuccess("[Farm] ✅ Killed " .. mobName ..  " (" .. tostring(killed) .. "/" .. tostring(count) .. ")")
                end
                
                task.wait(0.5)
            else
                if attempts % 10 == 0 then
                    Core.logDebug("[Farm] ⏳ Waiting for " .. mobName ..  " (" .. tostring(attempts) .. "/" .. tostring(maxAttempts) .. ")")
                end
                task.wait(2)
            end
        end
        
        if killed >= count then
            Core.logSuccess("[Farm] ✅ Completed:  " .. tostring(killed) .. "/" .. tostring(count) .. " " .. mobName)
            return true
        else
            Core.logError("[Farm] ❌ Only killed " .. tostring(killed) .. "/" .. tostring(count) .. " " .. mobName)
            return false
        end
    end)
    
    return ok
end

function Core.autoFarmLoop(Config)
    Core.logSuccess("🚀 AUTO FARM STARTED!")
    Core.logSuccess("⚔️ Weapon: " .. Config.Settings. SelectedWeapon)
    Core.logSuccess("✅ Fixed 3 lỗi theo checklist")
    print("[Thread] Loop started")
    
    while Config.Settings.Enabled do
        task.wait(1)
        
        local location, quest, questIndex = Core.findBestQuest(Config)
        
        if not quest then
            warn("No quest for level " .. tostring(Core.getPlayerLevel()))
            task.wait(5)
            continue
        end
        
        Config.Settings.CurrentQuest = quest. Name
        
        print(string.rep("=", 50))
        print("📜 Quest: " .. quest.Name ..  " (Lvl " .. tostring(quest.LevelReq) .. ")")
        print("📍 Location: " .. location)
        print(string.rep("=", 50))
        
        if Config.Settings.AutoQuest and not Core.hasActiveQuest() then
            if not Core.acceptQuest(location, questIndex, Config) then
                warn("Failed to accept quest, retrying...")
                task.wait(5)
                continue
            end
        end
        
        local questSuccess = true
        for mobName, mobCount in pairs(quest.Task) do
            if not Config.Settings.Enabled then break end
            
            if not Core.farmMob(mobName, mobCount, Config) then
                questSuccess = false
                break
            end
        end
        
        if questSuccess then
            Config.Settings.QuestsCompleted = Config.Settings. QuestsCompleted + 1
            Core.logSuccess("🎉 Quest done! Total: " .. tostring(Config. Settings.QuestsCompleted))
        else
            warn("Quest failed")
        end
        
        task.wait(2)
    end
    
    warn("⛔ AUTO FARM LOOP ENDED")
    Config.Settings.CurrentQuest = "None"
    print("[Thread] Loop finished")
    
    autoFarmThread = nil
    Core.stopTween()
    Core.stopFastAttack()
end

-- ✅ BẮT BUỘC:  RETURN CORE Ở CUỐI FILE
return Core
