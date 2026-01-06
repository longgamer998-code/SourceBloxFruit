--[[
    ╔══════════════════════════════════════════════════════════════╗
    ║              AUTO FARM FUNCTIONS MODULE                      ║
    ║         Chứa logic: Farm, Quest, Attack, Teleport            ║
    ╚══════════════════════════════════════════════════════════════╝
    
    Module này cần được load SAU BloxFruitsData.lua
    Sử dụng: getgenv().AutoFarmPro.Functions
]]

--============================================
-- SERVICES
--============================================
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer

--============================================
-- MODULE
--============================================
local AutoFarmFunctions = {}

--============================================
-- REFERENCES
--============================================
local function getSettings()
    return getgenv().AutoFarmPro and getgenv().AutoFarmPro.Settings or {}
end

local function getData()
    return getgenv().AutoFarmPro and getgenv().AutoFarmPro.Data or {}
end

local function getConnections()
    return getgenv().AutoFarmPro and getgenv().AutoFarmPro.Connections or {}
end

--============================================
-- CHARACTER FUNCTIONS
--============================================
function AutoFarmFunctions.GetCharacter()
    return player.Character or player.CharacterAdded:Wait()
end

function AutoFarmFunctions.GetHumanoidRootPart()
    local char = AutoFarmFunctions.GetCharacter()
    return char and char:FindFirstChild("HumanoidRootPart")
end

function AutoFarmFunctions.GetHumanoid()
    local char = AutoFarmFunctions.GetCharacter()
    return char and char:FindFirstChild("Humanoid")
end

--============================================
-- TELEPORT FUNCTIONS
--============================================
function AutoFarmFunctions.TeleportTo(position, offset)
    local hrp = AutoFarmFunctions.GetHumanoidRootPart()
    if hrp then
        offset = offset or Vector3.new(0, 15, 0)
        hrp.CFrame = CFrame.new(position + offset)
    end
end

function AutoFarmFunctions.TeleportToMob(mob)
    local Settings = getSettings()
    local mobHRP = mob:FindFirstChild("HumanoidRootPart") or mob:FindFirstChild("Head")
    
    if mobHRP then
        local hrp = AutoFarmFunctions.GetHumanoidRootPart()
        if hrp then
            local targetPos = mobHRP.Position + Vector3.new(0, Settings.FarmDistance or 15, 0)
            hrp.CFrame = CFrame.new(targetPos) * CFrame.Angles(math.rad(-90), 0, 0)
        end
    end
end

function AutoFarmFunctions.TeleportToNPC(npcName)
    local npc = AutoFarmFunctions.FindQuestNPC(npcName)
    if npc then
        local npcPart = npc:FindFirstChild("HumanoidRootPart") or npc:FindFirstChild("Head") or npc.PrimaryPart
        if npcPart then
            AutoFarmFunctions.TeleportTo(npcPart.Position, Vector3.new(0, 3, 5))
            return true
        end
    end
    return false
end

--============================================
-- MOB FUNCTIONS
--============================================
function AutoFarmFunctions.FindMob(mobName)
    local enemies = Workspace:FindFirstChild("Enemies") or Workspace
    
    for _, mob in pairs(enemies:GetDescendants()) do
        if mob:IsA("Model") and mob.Name == mobName then
            local humanoid = mob:FindFirstChild("Humanoid")
            local hrp = mob:FindFirstChild("HumanoidRootPart") or mob:FindFirstChild("Head")
            
            if humanoid and hrp and humanoid.Health > 0 then
                return mob
            end
        end
    end
    return nil
end

function AutoFarmFunctions.FindAllMobs(mobName)
    local mobs = {}
    local enemies = Workspace:FindFirstChild("Enemies") or Workspace
    
    for _, mob in pairs(enemies:GetDescendants()) do
        if mob:IsA("Model") and mob.Name == mobName then
            local humanoid = mob:FindFirstChild("Humanoid")
            local hrp = mob:FindFirstChild("HumanoidRootPart") or mob:FindFirstChild("Head")
            
            if humanoid and hrp and humanoid.Health > 0 then
                table.insert(mobs, mob)
            end
        end
    end
    return mobs
end

function AutoFarmFunctions.GetNearestMob(mobName)
    local mobs = AutoFarmFunctions.FindAllMobs(mobName)
    local hrp = AutoFarmFunctions.GetHumanoidRootPart()
    
    if not hrp or #mobs == 0 then return nil end
    
    local nearestMob = nil
    local nearestDist = math.huge
    
    for _, mob in pairs(mobs) do
        local mobHRP = mob:FindFirstChild("HumanoidRootPart") or mob:FindFirstChild("Head")
        if mobHRP then
            local dist = (hrp.Position - mobHRP.Position).Magnitude
            if dist < nearestDist then
                nearestDist = dist
                nearestMob = mob
            end
        end
    end
    
    return nearestMob, nearestDist
end

function AutoFarmFunctions.BringMob(mob)
    local Settings = getSettings()
    local hrp = AutoFarmFunctions.GetHumanoidRootPart()
    local mobHRP = mob:FindFirstChild("HumanoidRootPart")
    
    if hrp and mobHRP then
        mobHRP.CFrame = hrp.CFrame * CFrame.new(0, -(Settings.FarmDistance or 15), 0)
    end
end

--============================================
-- QUEST FUNCTIONS
--============================================
function AutoFarmFunctions.FindQuestNPC(npcName)
    for _, npc in pairs(Workspace:GetDescendants()) do
        if npc:IsA("Model") and (npc.Name == npcName or npc.Name:find(npcName)) then
            return npc
        end
    end
    return nil
end

function AutoFarmFunctions.AcceptQuest()
    local Settings = getSettings()
    
    if not Settings.SelectedIsland or not Settings.SelectedIsland.QuestNPC then 
        return false 
    end
    
    local questNPCData = Settings.SelectedIsland.QuestNPC
    local questNPC = AutoFarmFunctions.FindQuestNPC(questNPCData.Name)
    
    if questNPC then
        -- Teleport đến NPC
        local npcPart = questNPC:FindFirstChild("HumanoidRootPart") or questNPC:FindFirstChild("Head")
        if npcPart then
            AutoFarmFunctions.TeleportTo(npcPart.Position, Vector3.new(0, 3, 5))
            wait(0.5)
            
            -- Thử tương tác với NPC thông qua các remote phổ biến
            local questArgs = {
                [1] = "StartQuest",
                [2] = Settings.SelectedIsland.Island,
                [3] = Settings.SelectedMob and Settings.SelectedMob.Name or ""
            }
            
            -- Tìm và gọi remote quest
            for _, remote in pairs(ReplicatedStorage:GetDescendants()) do
                if remote:IsA("RemoteFunction") or remote:IsA("RemoteEvent") then
                    if remote.Name:lower():find("quest") then
                        pcall(function()
                            if remote:IsA("RemoteEvent") then
                                remote:FireServer(unpack(questArgs))
                            else
                                remote:InvokeServer(unpack(questArgs))
                            end
                        end)
                    end
                end
            end
            
            return true
        end
    end
    
    return false
end

function AutoFarmFunctions.HasQuest()
    -- Kiểm tra xem đã có quest chưa (tùy game)
    local playerData = player:FindFirstChild("Data") or player:FindFirstChild("PlayerData")
    if playerData then
        local quest = playerData:FindFirstChild("Quest") or playerData:FindFirstChild("CurrentQuest")
        if quest then
            return quest.Value ~= "" and quest.Value ~= nil
        end
    end
    return false
end

--============================================
-- ATTACK FUNCTIONS
--============================================
function AutoFarmFunctions.Attack()
    pcall(function()
        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
        task.wait(0.1)
        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0)
    end)
end

function AutoFarmFunctions.ClickAttack()
    local mouse = player:GetMouse()
    if mouse then
        pcall(function()
            -- Simulate left click
            VirtualInputManager:SendMouseButtonEvent(mouse.X, mouse.Y, 0, true, game, 0)
            task.wait(0.05)
            VirtualInputManager:SendMouseButtonEvent(mouse.X, mouse.Y, 0, false, game, 0)
        end)
    end
end

function AutoFarmFunctions.UseSkill(key)
    pcall(function()
        VirtualInputManager:SendKeyEvent(true, key, false, game)
        task.wait(0.1)
        VirtualInputManager:SendKeyEvent(false, key, false, game)
    end)
end

--============================================
-- AUTO FARM MAIN LOOP
--============================================

-- Tự động trang bị vũ khí tốt nhất hoặc vũ khí đã chọn
function AutoFarmFunctions.EquipBestWeapon()
    local Settings = getSettings()
    if not Settings.AutoEquip then return end
    
    pcall(function()
        local backpack = player:FindFirstChild("Backpack")
        local char = AutoFarmFunctions.GetCharacter()
        if not backpack or not char then return end
        
        local humanoid = AutoFarmFunctions.GetHumanoid()
        if not humanoid then return end
        
        -- Kiểm tra đã trang bị đúng vũ khí chưa
        local currentWeapon = char:FindFirstChildOfClass("Tool")
        
        -- Nếu đã chọn vũ khí cụ thể
        if Settings.SelectedWeapon then
            -- Đã đang cầm đúng vũ khí
            if currentWeapon and currentWeapon.Name == Settings.SelectedWeapon then
                return
            end
            
            -- Tìm và trang bị vũ khí đã chọn
            local targetWeapon = backpack:FindFirstChild(Settings.SelectedWeapon)
            if targetWeapon then
                humanoid:EquipTool(targetWeapon)
                return
            end
        end
        
        -- Nếu đã có vũ khí và không chọn cụ thể -> giữ nguyên
        if currentWeapon and not Settings.SelectedWeapon then
            return
        end
        
        -- Tự động chọn vũ khí tốt nhất
        local bestWeapon = nil
        local weaponPriority = {"Sword", "Blox Fruit", "Gun", "Fighting Style"}
        
        -- Tìm trong Backpack theo priority
        for _, priority in ipairs(weaponPriority) do
            for _, tool in pairs(backpack:GetChildren()) do
                if tool:IsA("Tool") then
                    if tool.Name:find(priority) or tool:GetAttribute("Type") == priority then
                        bestWeapon = tool
                        break
                    end
                end
            end
            if bestWeapon then break end
        end
        
        -- Nếu không tìm được theo priority, lấy tool đầu tiên
        if not bestWeapon then
            for _, tool in pairs(backpack:GetChildren()) do
                if tool:IsA("Tool") then
                    bestWeapon = tool
                    break
                end
            end
        end
        
        -- Trang bị
        if bestWeapon then
            humanoid:EquipTool(bestWeapon)
        end
    end)
end

-- Detect Sea hiện tại dựa vào vị trí hoặc PlaceId
function AutoFarmFunctions.GetCurrentSea()
    local placeId = game.PlaceId
    
    -- Blox Fruits Place IDs
    local seaPlaceIds = {
        [2753915549] = 1,  -- Sea 1 (Old World)
        [4442272183] = 2,  -- Sea 2 (New World)  
        [7449423635] = 3,  -- Sea 3 (Third Sea)
    }
    
    return seaPlaceIds[placeId] or 1
end

-- Tìm đảo tốt nhất cho level hiện tại
function AutoFarmFunctions.GetBestIslandForLevel(playerLevel, seaNum)
    local Data = getData()
    local seaData = Data["Sea" .. seaNum]
    if not seaData then return nil, nil end
    
    local bestIsland = nil
    local bestMob = nil
    
    for _, island in ipairs(seaData) do
        local minLv, maxLv = island.LevelRange[1], island.LevelRange[2]
        
        -- Tìm đảo mà player level nằm trong range hoặc gần nhất
        if playerLevel >= minLv and playerLevel <= maxLv + 10 then
            bestIsland = island
            
            -- Tìm mob có level cao nhất mà player có thể đánh
            for _, mob in ipairs(island.Mobs or {}) do
                if playerLevel >= mob.Level - 5 then
                    if not bestMob or mob.Level > bestMob.Level then
                        bestMob = mob
                    end
                end
            end
            
            if bestMob then break end
        end
    end
    
    -- Nếu level quá cao cho sea này, lấy đảo cuối
    if not bestIsland and seaData[#seaData] then
        bestIsland = seaData[#seaData]
        if bestIsland.Mobs and #bestIsland.Mobs > 0 then
            bestMob = bestIsland.Mobs[#bestIsland.Mobs]
        end
    end
    
    return bestIsland, bestMob
end

-- Kiểm tra có cần chuyển đảo/mob không
function AutoFarmFunctions.ShouldSwitchIsland()
    local Settings = getSettings()
    local playerLevel = AutoFarmFunctions.GetPlayerLevel()
    
    if not Settings.SelectedIsland then return true end
    
    local maxLv = Settings.SelectedIsland.LevelRange[2]
    
    -- Nếu level player cao hơn max level đảo 10 level -> chuyển
    if playerLevel > maxLv + 10 then
        return true
    end
    
    return false
end

-- Auto update đảo và mob theo level
function AutoFarmFunctions.AutoUpdateIslandAndMob()
    local Settings = getSettings()
    local playerLevel = AutoFarmFunctions.GetPlayerLevel()
    local currentSea = Settings.CurrentSea or AutoFarmFunctions.GetCurrentSea()
    
    local newIsland, newMob = AutoFarmFunctions.GetBestIslandForLevel(playerLevel, currentSea)
    
    if newIsland and newMob then
        local changed = false
        
        if not Settings.SelectedIsland or Settings.SelectedIsland.Island ~= newIsland.Island then
            Settings.SelectedIsland = newIsland
            changed = true
        end
        
        if not Settings.SelectedMob or Settings.SelectedMob.Name ~= newMob.Name then
            Settings.SelectedMob = newMob
            changed = true
        end
        
        if changed then
            print("[AutoFarm] Level " .. playerLevel .. " → " .. newIsland.Island .. " - " .. newMob.Name)
        end
        
        return changed
    end
    
    return false
end

function AutoFarmFunctions.StartAutoFarm()
    local Settings = getSettings()
    local Connections = getConnections()
    
    -- Dừng farm cũ nếu có
    AutoFarmFunctions.StopAutoFarm()
    
    -- Khởi tạo sea hiện tại
    if not Settings.CurrentSea then
        Settings.CurrentSea = AutoFarmFunctions.GetCurrentSea()
    end
    
    -- Auto chọn đảo/mob ban đầu nếu chưa có
    if not Settings.SelectedIsland or not Settings.SelectedMob then
        AutoFarmFunctions.AutoUpdateIslandAndMob()
    end
    
    -- Biến đếm để kiểm tra chuyển đảo định kỳ
    local checkCounter = 0
    
    Connections.FarmLoop = RunService.Heartbeat:Connect(function()
        if not Settings.AutoFarm then return end
        
        -- Auto Equip vũ khí
        AutoFarmFunctions.EquipBestWeapon()
        
        -- Kiểm tra chuyển đảo mỗi 300 frames (~5 giây)
        checkCounter = checkCounter + 1
        if checkCounter >= 300 then
            checkCounter = 0
            AutoFarmFunctions.AutoUpdateIslandAndMob()
        end
        
        if not Settings.SelectedMob then return end
        
        local mobName = Settings.SelectedMob.Name
        local mob = AutoFarmFunctions.FindMob(mobName)
        
        if mob then
            -- Teleport lên đầu mob
            AutoFarmFunctions.TeleportToMob(mob)
            
            -- Bring mob nếu bật
            if Settings.BringMob then
                AutoFarmFunctions.BringMob(mob)
            end
            
            -- Tấn công nếu Kill Aura bật
            if Settings.KillAura then
                AutoFarmFunctions.Attack()
            end
        else
            -- Không tìm thấy mob, thử nhận quest mới
            if Settings.AutoQuest then
                AutoFarmFunctions.AcceptQuest()
                wait(1)
            end
        end
    end)
    
    print("[AutoFarm] Farm loop started! Sea " .. (Settings.CurrentSea or "?"))
end

function AutoFarmFunctions.StopAutoFarm()
    local Connections = getConnections()
    
    if Connections.FarmLoop then
        Connections.FarmLoop:Disconnect()
        Connections.FarmLoop = nil
        print("[AutoFarm] Farm loop stopped!")
    end
end

--============================================
-- UTILITY FUNCTIONS
--============================================
function AutoFarmFunctions.GetPlayerLevel()
    local playerData = player:FindFirstChild("Data") or player:FindFirstChild("PlayerData")
    if playerData then
        local level = playerData:FindFirstChild("Level")
        if level then
            return level.Value
        end
    end
    return 0
end

function AutoFarmFunctions.GetBestMobForLevel()
    local Settings = getSettings()
    local Data = getData()
    local playerLevel = AutoFarmFunctions.GetPlayerLevel()
    
    local seaData = Data["Sea" .. Settings.CurrentSea]
    if not seaData then return nil end
    
    local bestIsland = nil
    local bestMob = nil
    
    for _, island in ipairs(seaData) do
        if playerLevel >= island.LevelRange[1] and playerLevel <= island.LevelRange[2] then
            bestIsland = island
            -- Chọn mob có level cao nhất trong tầm
            for _, mob in ipairs(island.Mobs) do
                if playerLevel >= mob.Level then
                    bestMob = mob
                end
            end
            break
        end
    end
    
    return bestIsland, bestMob
end

function AutoFarmFunctions.AutoSelectMob()
    local Settings = getSettings()
    local island, mob = AutoFarmFunctions.GetBestMobForLevel()
    
    if island and mob then
        Settings.SelectedIsland = island
        Settings.SelectedMob = mob
        print("[AutoFarm] Auto selected: " .. island.Island .. " - " .. mob.Name)
        return true
    end
    
    return false
end

--============================================
-- CLEANUP
--============================================
function AutoFarmFunctions.Cleanup()
    AutoFarmFunctions.StopAutoFarm()
    
    local Connections = getConnections()
    for name, connection in pairs(Connections) do
        if connection and typeof(connection) == "RBXScriptConnection" then
            connection:Disconnect()
        end
    end
    
    print("[AutoFarm] Cleanup completed!")
end

--============================================
-- RETURN MODULE
--============================================
return AutoFarmFunctions
