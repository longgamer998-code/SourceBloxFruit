-- ╔══════════════════════════════════════════════════════════╗
-- ║  CORE.LUA - Core Logic Functions Only                    ║
-- ╚══════════════════════════════════════════════════════════╝

local Core = {}

-- ========== SERVICES ==========
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local VirtualUser = game:GetService("VirtualUser")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ScriptContext = game:GetService("ScriptContext")

local player = Players.LocalPlayer

-- Variables
local currentTween = nil
local fastAttackConnection = nil
local oldPrint = print
local oldWarn = warn

-- ========== CONSOLE SYSTEM ==========
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
    
    -- Hook print/warn
    print = function(... ) addLog(table.concat({...}, " "), "INFO") end
    warn = function(...) addLog(table.concat({...}, " "), "WARN") end
    
    -- Custom loggers
    Core.logError = function(msg) addLog(msg, "ERROR") end
    Core.logSuccess = function(msg) addLog(msg, "SUCCESS") end
    Core.logDebug = function(msg, Config) if Config.Settings. DebugMode then addLog(msg, "DEBUG") end end
    
    -- Error hook
    ScriptContext.Error:Connect(function(message, stackTrace)
        addLog("RUNTIME ERROR: " .. message, "ERROR")
        if stackTrace then addLog("Stack: " .. stackTrace: sub(1, 200), "ERROR") end
    end)
    
    -- Safe pcall
    Core.safePcall = function(func, ...)
        local args = {...}
        local success, result = pcall(func, unpack(args))
        if not success then addLog("PCALL ERROR: " .. tostring(result), "ERROR") end
        return success, result
    end
end

function Core.getConsoleText(Config)
    local output = "===== BLOX FRUITS AUTO FARM CONSOLE =====\n"
    output = output .. "Player: " ..  player.Name .. "\n"
    output = output .. "Level: " .. tostring(player.Data.Level. Value or "? ") .. "\n"
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
    output = output .. "Attack Attempts: " .. tostring(Config.CombatDebug. AttackAttempts) .. "\n"
    output = output ..  "Successful Hits: " ..  tostring(Config.CombatDebug.SuccessfulHits) .. "\n"
    output = output .. "Click Attempts: " .. tostring(Config.CombatDebug. ClickAttempts) .. "\n"
    output = output ..  "Health Changes: " .. tostring(Config.CombatDebug. HealthChanges) .. "\n"
    output = output .. "Weapon Equip Fails: " .. tostring(Config.CombatDebug.WeaponEquipFails) .. "\n"
    output = output .. "Position Errors: " .. tostring(Config.CombatDebug. PositionErrors) .. "\n"
    
    local hitRate = Config.CombatDebug.AttackAttempts > 0 and 
        (Config.CombatDebug. SuccessfulHits / Config.CombatDebug.AttackAttempts * 100) or 0
    output = output .. "Hit Rate: " .. string.format("%.1f", hitRate) .. "%\n"
    output = output .. "==============================\n"
    return output
end

function Core.clearConsole(Config)
    Config.ConsoleLog = {}
    print("Console cleared")
end

-- ========== UTILITY FUNCTIONS ==========
function Core. getCharacter()
    return player.Character or player.CharacterAdded:Wait()
end

function Core.getHRP()
    local char = Core.getCharacter()
    return char and char: FindFirstChild("HumanoidRootPart")
end

function Core.getPlayerLevel()
    local success, level = pcall(function() return player.Data.Level.Value end)
    return success and level or 1
end

-- ========== WEAPON SYSTEM ==========
function Core.getPlayerWeapons()
    local weapons = {"Combat"}
    
    Core.safePcall(function()
        local backpack = player.Backpack
        local character = Core.getCharacter()
        
        for _, item in pairs(backpack:GetChildren()) do
            if item:IsA("Tool") then
                table.insert(weapons, item.Name)
            end
        end
        
        for _, item in pairs(character:GetChildren()) do
            if item: IsA("Tool") then
                local alreadyAdded = false
                for _, w in ipairs(weapons) do
                    if w == item.Name then
                        alreadyAdded = true
                        break
                    end
                end
                if not alreadyAdded then
                    table.insert(weapons, item.Name)
                end
            end
        end
    end)
    
    return weapons
end

function Core.equipWeapon(weaponName, Config)
    if weaponName == "Combat" then
        Core.safePcall(function()
            local character = Core.getCharacter()
            for _, item in pairs(character:GetChildren()) do
                if item: IsA("Tool") then
                    item.Parent = player.Backpack
                end
            end
        end)
        Core.logDebug("Using Combat (melee)", Config)
        return true
    end
    
    local success = Core.safePcall(function()
        local character = Core.getCharacter()
        local humanoid = character:FindFirstChild("Humanoid")
        
        if not humanoid then
            Core.logError("Humanoid not found")
            Config.CombatDebug.WeaponEquipFails = Config.CombatDebug.WeaponEquipFails + 1
            return false
        end
        
        local equippedTool = character:FindFirstChildOfClass("Tool")
        if equippedTool and equippedTool.Name == weaponName then
            Core.logDebug("Weapon already equipped:  " .. weaponName, Config)
            return true
        end
        
        local weapon = player.Backpack:FindFirstChild(weaponName)
        
        if weapon then
            humanoid: EquipTool(weapon)
            task.wait(0.3)
            Core.logSuccess("Equipped weapon: " .. weaponName)
            return true
        else
            Core.logError("Weapon not found: " .. weaponName)
            Config.CombatDebug.WeaponEquipFails = Config.CombatDebug.WeaponEquipFails + 1
            return false
        end
    end)
    
    return success
end

-- ========== TELEPORT SYSTEM ==========
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
            Core. logError("HRP not found for tween")
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
        local hrp = Core. getHRP()
        if not hrp then
            Core.logError("HRP not found")
            return false
        end
        
        local distance = (hrp.Position - targetPos).Magnitude
        local distStr = tostring(math.floor(distance))
        
        if forceTween or (Config.Settings.SafeTeleport and distance > 100) then
            Core.logDebug("Tween " .. distStr .. " studs", Config)
            Core.tweenTo(targetPos, Config)
        else
            Core.logDebug("Instant TP " .. distStr ..  " studs", Config)
            hrp.CFrame = CFrame.new(targetPos)
            task.wait(0.3)
        end
        
        return true
    end)
    
    return success
end

-- ========== COMBAT SYSTEM ==========
function Core.enableHaki(Config)
    if not Config.Settings.AutoHaki then return end
    Core.safePcall(function()
        ReplicatedStorage. Remotes.CommF_:InvokeServer("Buso")
        Core.logDebug("Haki enabled", Config)
    end)
end

function Core.startFastAttack(Config)
    if fastAttackConnection then return end
    
    fastAttackConnection = RunService.RenderStepped:Connect(function()
        if Config.Settings.FastAttack and Config.Settings. Enabled then
            Core.safePcall(function()
                local character = Core.getCharacter()
                local tool = character:FindFirstChildOfClass("Tool")
                
                if tool then
                    ReplicatedStorage.Remotes. CommF_:InvokeServer("weaponDebounce")
                    VirtualUser: CaptureController()
                    VirtualUser:ClickButton1(Vector2.new(1, 1))
                    Config.CombatDebug. ClickAttempts = Config.CombatDebug.ClickAttempts + 1
                end
            end)
        end
    end)
    
    print("Fast Attack started")
end

function Core.stopFastAttack()
    if fastAttackConnection then
        fastAttackConnection: Disconnect()
        fastAttackConnection = nil
        print("Fast Attack stopped")
    end
end

-- ========== QUEST SYSTEM ==========
function Core. findBestQuest(Config)
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
    local success, result = Core.safePcall(function()
        local questUI = player.PlayerGui:FindFirstChild("Main")
        if questUI then
            local quest = questUI:FindFirstChild("Quest")
            return quest and quest. Visible
        end
        return false
    end)
    
    return success and result
end

function Core.acceptQuest(locationName, questIndex, Config)
    local success, result = Core.safePcall(function()
        local questPos = Config.QuestLocations[locationName]
        if not questPos then
            Core. logError("Quest location not found:  " .. locationName)
            return false
        end
        
        print("Traveling to quest giver...")
        if not Core.smartTeleport(questPos, true, Config) then
            Core. logError("Failed to teleport to quest giver")
            return false
        end
        
        task.wait(0.5)
        
        local invokeSuccess, invokeResult = pcall(function()
            return ReplicatedStorage.Remotes. CommF_:InvokeServer("StartQuest", locationName, questIndex)
        end)
        
        if not invokeSuccess then
            Core.logError("StartQuest invoke failed: " .. tostring(invokeResult))
            return false
        end
        
        task.wait(0.3)
        
        if Core.hasActiveQuest() then
            Core.logSuccess("Quest accepted!")
            return true
        else
            Core.logError("Quest not active after accept")
            return false
        end
    end)
    
    return success and result
end

-- ========== MOB FARM SYSTEM ==========
function Core. findNearestMob(mobName, Config)
    local success, mob = Core.safePcall(function()
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
            Core.logDebug("Found " .. mobName .. " at distance: " .. tostring(math.floor(nearestDistance)), Config)
        end
        
        return nearestMob
    end)
    
    return success and mob or nil
end

function Core.farmMob(mobName, count, Config)
    local success = Core.safePcall(function()
        print("Farming " .. mobName ..  " x" .. tostring(count))
        
        -- Equip weapon before farming
        if Config.Settings. AutoEquipWeapon then
            if not Core.equipWeapon(Config.Settings. SelectedWeapon, Config) then
                Core.logError("Failed to equip weapon before farming")
            end
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
                
                if mobHRP and mobHumanoid and mobHumanoid.Health > 0 then
                    Config.CombatDebug.LastMobHealth = mobHumanoid.Health
                    
                    -- Calculate position above mob's head
                    local targetPos = mobHead and mobHead.Position or mobHRP.Position
                    local farmPos = targetPos + Vector3.new(0, Config.Settings.FarmDistance, 0)
                    
                    Core.logDebug("Target Position: " .. tostring(targetPos), Config)
                    Core.logDebug("Farm Position (above head): " .. tostring(farmPos), Config)
                    
                    if not Core.smartTeleport(farmPos, false, Config) then
                        Core.logError("Failed to teleport to mob")
                        Config.CombatDebug. PositionErrors = Config.CombatDebug.PositionErrors + 1
                        task.wait(1)
                        continue
                    end
                    
                    -- Verify position
                    local hrp = Core.getHRP()
                    if hrp then
                        local actualDistance = (hrp.Position - targetPos).Magnitude
                        Core.logDebug("Distance from mob:  " .. tostring(math.floor(actualDistance)), Config)
                        
                        if actualDistance > 50 then
                            Core.logError("Too far from mob!  Distance: " .. tostring(math. floor(actualDistance)))
                            Config.CombatDebug.PositionErrors = Config.CombatDebug. PositionErrors + 1
                        end
                    end
                    
                    Core.enableHaki(Config)
                    
                    -- Attack loop with detailed debug
                    local attackLoopCount = 0
                    while mob and mobHumanoid.Health > 0 and Config.Settings.Enabled do
                        attackLoopCount = attackLoopCount + 1
                        Config.CombatDebug.AttackAttempts = Config.CombatDebug.AttackAttempts + 1
                        
                        Core.safePcall(function()
                            local hrp = Core.getHRP()
                            local character = Core.getCharacter()
                            
                            if hrp and mobHRP then
                                -- Face mob
                                local lookAt = CFrame.new(hrp.Position, mobHRP.Position)
                                hrp.CFrame = lookAt
                                
                                Core.logDebug("Facing mob - Loop:  " .. tostring(attackLoopCount), Config)
                                
                                -- Check weapon
                                local tool = character:FindFirstChildOfClass("Tool")
                                if tool then
                                    Core.logDebug("Weapon equipped:  " .. tool.Name, Config)
                                    
                                    -- Activate tool
                                    local activateSuccess = pcall(function()
                                        tool: Activate()
                                    end)
                                    
                                    if not activateSuccess then
                                        Core.logError("Tool activate failed")
                                    else
                                        Core.logDebug("Tool activated", Config)
                                    end
                                else
                                    if Config.Settings. SelectedWeapon ~= "Combat" then
                                        Core.logError("No weapon equipped!")
                                        Config.CombatDebug. WeaponEquipFails = Config.CombatDebug. WeaponEquipFails + 1
                                    else
                                        Core.logDebug("Using Combat (no tool needed)", Config)
                                    end
                                end
                                
                                -- Click attack
                                local clickSuccess = pcall(function()
                                    VirtualUser:CaptureController()
                                    VirtualUser:ClickButton1(Vector2.new(1, 1))
                                end)
                                
                                if clickSuccess then
                                    Config.CombatDebug. ClickAttempts = Config.CombatDebug.ClickAttempts + 1
                                    Core.logDebug("Click attack sent", Config)
                                else
                                    Core.logError("Click attack failed")
                                end
                                
                                -- Check health change
                                task.wait(0.1)
                                local currentHealth = mobHumanoid. Health
                                if currentHealth < Config.CombatDebug.LastMobHealth then
                                    local damage = Config.CombatDebug.LastMobHealth - currentHealth
                                    Config.CombatDebug. HealthChanges = Config.CombatDebug.HealthChanges + 1
                                    Config.CombatDebug. SuccessfulHits = Config.CombatDebug.SuccessfulHits + 1
                                    Core.logDebug("HIT! Damage: " .. string.format("%.1f", damage) .. " | HP: " .. string.format("%.0f", currentHealth), Config)
                                else
                                    if attackLoopCount % 10 == 0 then
                                        Core.logError("No damage after 10 attacks!  HP: " .. string.format("%. 0f", currentHealth))
                                    end
                                end
                                
                                Config.CombatDebug.LastMobHealth = currentHealth
                            else
                                Core.logError("HRP or MobHRP not found in attack loop")
                                Config.CombatDebug. PositionErrors = Config.CombatDebug.PositionErrors + 1
                            end
                        end)
                        
                        task.wait(0.1)
                        
                        -- Safety check
                        if attackLoopCount > 200 then
                            Core.logError("Attack loop exceeded 200 iterations, breaking...")
                            break
                        end
                    end
                    
                    if mobHumanoid.Health <= 0 then
                        killed = killed + 1
                        Config.Settings.MobsKilled = Config.Settings.MobsKilled + 1
                        Core.logSuccess("Killed " .. mobName .. " (" .. tostring(killed) .. "/" .. tostring(count) .. ")")
                    end
                    
                    task.wait(0.5)
                else
                    task.wait(1)
                end
            else
                if attempts % 10 == 0 then
                    Core.logDebug("Waiting for " .. mobName .. " (attempt " .. tostring(attempts) .. "/" .. tostring(maxAttempts) .. ")", Config)
                end
                task.wait(2)
            end
        end
        
        if killed >= count then
            Core.logSuccess("Completed:  " .. tostring(killed) .. "/" .. tostring(count) .. " " .. mobName)
            return true
        else
            Core.logError("Only killed " .. tostring(killed) .. "/" .. tostring(count) .. " " .. mobName)
            return false
        end
    end)
    
    return success
end

-- ========== AUTO FARM LOOP ==========
function Core.autoFarmLoop(Config)
    Core.logSuccess("AUTO FARM STARTED!")
    Core.logSuccess("Using weapon: " .. Config.Settings. SelectedWeapon)
    Core.logSuccess("Debug Mode: " .. (Config.Settings. DebugMode and "ON" or "OFF"))
    
    while Config.Settings.Enabled do
        task.wait(1)
        
        local location, quest, questIndex = Core.findBestQuest(Config)
        
        if not quest then
            warn("No suitable quest for level " .. tostring(Core.getPlayerLevel()))
            task.wait(5)
            continue
        end
        
        Config.Settings.CurrentQuest = quest. Name
        
        print(string.rep("=", 50))
        print("Quest: " .. quest.Name ..  " (Level " .. tostring(quest. LevelReq) .. ")")
        print("Location: " .. location)
        print(string.rep("=", 50))
        
        if Config.Settings.AutoQuest and not Core.hasActiveQuest() then
            if not Core.acceptQuest(location, questIndex, Config) then
                warn("Failed to accept quest, retrying in 5s...")
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
            Core.logSuccess("Quest completed!  Total: " .. tostring(Config. Settings.QuestsCompleted))
        else
            warn("Quest failed or interrupted")
        end
        
        task.wait(2)
    end
    
    warn("AUTO FARM STOPPED")
    Config.Settings.CurrentQuest = "None"
    Core.stopTween()
    Core.stopFastAttack()
end

return Core