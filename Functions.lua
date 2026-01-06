--[[
    FUNCTIONS MODULE - Logic Auto Farm (All-in-one)
    Bật Auto Farm = Auto Quest + Kill Aura + Bring Mob
]]

local Functions = {}

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
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
    local seas = {[2753915549] = 1, [4442272183] = 2, [7449423635] = 3}
    return seas[game.PlaceId] or 1
end

--=== TELEPORT ===--
function Functions.Teleport(pos, offset)
    local hrp = Functions.GetHRP()
    if hrp then
        hrp.CFrame = CFrame.new(pos + (offset or Vector3.new(0, 10, 0)))
    end
end

function Functions.TeleportToMob(mob)
    local mobHRP = mob:FindFirstChild("HumanoidRootPart") or mob:FindFirstChild("Head")
    local hrp = Functions.GetHRP()
    if mobHRP and hrp then
        hrp.CFrame = CFrame.new(mobHRP.Position + Vector3.new(0, 15, 0)) * CFrame.Angles(math.rad(-90), 0, 0)
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
function Functions.AcceptQuest(questName)
    pcall(function()
        for _, remote in pairs(ReplicatedStorage:GetDescendants()) do
            if remote:IsA("RemoteFunction") and remote.Name == "Quest" then
                remote:InvokeServer("Start", questName)
                break
            end
        end
    end)
end

--=== EQUIP ===--
function Functions.EquipWeapon()
    local backpack = player:FindFirstChild("Backpack")
    local hum = Functions.GetHumanoid()
    if not backpack or not hum then return end
    
    for _, tool in pairs(backpack:GetChildren()) do
        if tool:IsA("Tool") then
            hum:EquipTool(tool)
            break
        end
    end
end

--=== AUTO FARM (All-in-one) ===--
function Functions.StartFarm()
    Functions.StopFarm()
    
    Settings.CurrentSea = Functions.GetSea()
    
    Connections.FarmLoop = RunService.Heartbeat:Connect(function()
        if not Settings.AutoFarm then return end
        
        -- Cập nhật level và đảo
        local level = Functions.GetLevel()
        local islandData = Data.GetIslandByLevel(level, Settings.CurrentSea)
        if not islandData then return end
        
        Settings.CurrentLevel = level
        Settings.CurrentIsland = islandData.Island
        Settings.CurrentMob = islandData.Mob
        
        -- Auto Equip
        if Settings.AutoEquip then
            Functions.EquipWeapon()
        end
        
        -- Tìm mob
        local mob = Functions.FindMob(islandData.Mob)
        
        if mob then
            -- Teleport + Bring + Attack
            Functions.TeleportToMob(mob)
            Functions.BringMob(mob)
            Functions.Attack()
        else
            -- Không có mob -> nhận quest
            Functions.Teleport(islandData.NPCPos, Vector3.new(0, 3, 0))
            task.wait(0.3)
            Functions.AcceptQuest(islandData.Mob)
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
