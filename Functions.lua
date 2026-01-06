--[[
    FUNCTIONS MODULE - Logic Auto Farm
]]

local Functions = {}

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer

-- References
local Settings, Data, Connections

function Functions.Init(settings, data)
    Settings = settings
    Data = data
    Connections = {}
end

--=== CHARACTER ===--
function Functions.GetCharacter()
    return player.Character or player.CharacterAdded:Wait()
end

function Functions.GetHRP()
    local char = Functions.GetCharacter()
    return char and char:FindFirstChild("HumanoidRootPart")
end

function Functions.GetHumanoid()
    local char = Functions.GetCharacter()
    return char and char:FindFirstChild("Humanoid")
end

--=== PLAYER INFO ===--
function Functions.GetLevel()
    local data = player:FindFirstChild("Data")
    if data then
        local level = data:FindFirstChild("Level")
        if level then return level.Value end
    end
    return 1
end

function Functions.GetSea()
    local placeId = game.PlaceId
    local seas = {
        [2753915549] = 1,
        [4442272183] = 2,
        [7449423635] = 3,
    }
    return seas[placeId] or 1
end

--=== TELEPORT ===--
function Functions.Teleport(pos, offset)
    local hrp = Functions.GetHRP()
    if hrp then
        offset = offset or Vector3.new(0, 10, 0)
        hrp.CFrame = CFrame.new(pos + offset)
    end
end

function Functions.TeleportToMob(mob)
    local mobHRP = mob:FindFirstChild("HumanoidRootPart") or mob:FindFirstChild("Head")
    if mobHRP then
        local hrp = Functions.GetHRP()
        if hrp then
            hrp.CFrame = CFrame.new(mobHRP.Position + Vector3.new(0, 15, 0)) * CFrame.Angles(math.rad(-90), 0, 0)
        end
    end
end

--=== MOB ===--
function Functions.FindMob(mobName)
    local enemies = Workspace:FindFirstChild("Enemies")
    if not enemies then return nil end
    
    for _, mob in pairs(enemies:GetDescendants()) do
        if mob:IsA("Model") and mob.Name == mobName then
            local hum = mob:FindFirstChild("Humanoid")
            local hrp = mob:FindFirstChild("HumanoidRootPart")
            if hum and hrp and hum.Health > 0 then
                return mob
            end
        end
    end
    return nil
end

function Functions.BringMob(mob)
    local hrp = Functions.GetHRP()
    local mobHRP = mob:FindFirstChild("HumanoidRootPart")
    if hrp and mobHRP then
        mobHRP.CFrame = hrp.CFrame * CFrame.new(0, -15, 0)
    end
end

--=== ATTACK ===--
function Functions.Attack()
    pcall(function()
        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
        task.wait(0.1)
        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0)
    end)
end

--=== QUEST ===--
function Functions.AcceptQuest(npcName, questName)
    pcall(function()
        for _, remote in pairs(ReplicatedStorage:GetDescendants()) do
            if remote:IsA("RemoteFunction") and remote.Name == "Quest" then
                remote:InvokeServer("Start", questName)
                break
            end
        end
    end)
end

function Functions.HasQuest()
    local data = player:FindFirstChild("Data")
    if data then
        local quest = data:FindFirstChild("Quest")
        if quest then
            return quest.Value ~= nil and quest.Value ~= ""
        end
    end
    return false
end

--=== EQUIP ===--
function Functions.EquipWeapon(weaponName)
    local backpack = player:FindFirstChild("Backpack")
    local char = Functions.GetCharacter()
    local hum = Functions.GetHumanoid()
    
    if not backpack or not hum then return end
    
    -- Nếu không chọn weapon cụ thể, lấy cái đầu tiên
    local weapon
    if weaponName then
        weapon = backpack:FindFirstChild(weaponName)
    else
        for _, tool in pairs(backpack:GetChildren()) do
            if tool:IsA("Tool") then
                weapon = tool
                break
            end
        end
    end
    
    if weapon then
        hum:EquipTool(weapon)
    end
end

--=== AUTO FARM LOOP ===--
function Functions.StartFarm()
    Functions.StopFarm()
    
    local sea = Functions.GetSea()
    Settings.CurrentSea = sea
    
    Connections.FarmLoop = RunService.Heartbeat:Connect(function()
        if not Settings.AutoFarm then return end
        
        -- Cập nhật level và đảo
        local level = Functions.GetLevel()
        local islandData = Data.GetIslandByLevel(level, sea)
        
        if not islandData then return end
        
        Settings.CurrentIsland = islandData.Island
        Settings.CurrentMob = islandData.Mob
        Settings.CurrentLevel = level
        
        -- Tìm mob
        local mob = Functions.FindMob(islandData.Mob)
        
        if mob then
            -- Teleport đến mob
            Functions.TeleportToMob(mob)
            
            -- Bring mob
            if Settings.BringMob then
                Functions.BringMob(mob)
            end
            
            -- Attack
            if Settings.KillAura then
                Functions.Attack()
            end
            
            -- Auto Equip
            if Settings.AutoEquip then
                Functions.EquipWeapon(Settings.SelectedWeapon)
            end
        else
            -- Không có mob -> nhận quest
            if Settings.AutoQuest then
                Functions.Teleport(islandData.NPCPos, Vector3.new(0, 3, 0))
                task.wait(0.3)
                Functions.AcceptQuest(islandData.QuestNPC, islandData.Mob)
            end
        end
    end)
end

function Functions.StopFarm()
    if Connections.FarmLoop then
        Connections.FarmLoop:Disconnect()
        Connections.FarmLoop = nil
    end
end

return Functions
