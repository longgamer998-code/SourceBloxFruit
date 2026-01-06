--[[
    FUNCTIONS MODULE - Logic Auto Farm (Fixed)
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

--=== MOB (Fixed - tìm linh hoạt) ===--
function Functions.FindMob(mobName)
    -- Tìm trong nhiều folder có thể chứa mob
    local searchFolders = {
        Workspace:FindFirstChild("Enemies"),
        Workspace:FindFirstChild("enemies"),
        Workspace:FindFirstChild("NPCs"),
        Workspace:FindFirstChild("Mobs"),
        Workspace
    }
    
    for _, folder in pairs(searchFolders) do
        if folder then
            for _, mob in pairs(folder:GetDescendants()) do
                if mob:IsA("Model") then
                    local hum = mob:FindFirstChild("Humanoid")
                    local hrp = mob:FindFirstChild("HumanoidRootPart")
                    
                    -- Kiểm tra tên mob (có thể chứa tên hoặc bằng tên)
                    if hum and hrp and hum.Health > 0 then
                        if mob.Name == mobName or string.find(mob.Name, mobName) then
                            return mob
                        end
                    end
                end
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
function Functions.AcceptQuest(npcPos, mobName)
    -- Teleport đến NPC
    Functions.Teleport(npcPos, Vector3.new(0, 3, 0))
    task.wait(0.5)
    
    -- Thử nhiều cách gọi quest
    pcall(function()
        -- Cách 1: RemoteFunction Quest
        local questRemote = ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes:FindFirstChild("CommF_")
        if questRemote then
            questRemote:InvokeServer("StartQuest", mobName, 1)
        end
    end)
    
    pcall(function()
        -- Cách 2: Click NPC trực tiếp
        local args = {mobName, 1}
        ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("CommF_"):InvokeServer("StartQuest", unpack(args))
    end)
end

function Functions.HasQuest()
    local plrGui = player:FindFirstChild("PlayerGui")
    if plrGui then
        local main = plrGui:FindFirstChild("Main")
        if main then
            local quest = main:FindFirstChild("Quest")
            if quest and quest:FindFirstChild("Container") then
                return quest.Container.Visible
            end
        end
    end
    return false
end

--=== EQUIP ===--
function Functions.EquipWeapon()
    local backpack = player:FindFirstChild("Backpack")
    local char = Functions.GetCharacter()
    local hum = Functions.GetHumanoid()
    if not backpack or not hum then return end
    
    -- Kiểm tra đã trang bị chưa
    if char:FindFirstChildOfClass("Tool") then return end
    
    for _, tool in pairs(backpack:GetChildren()) do
        if tool:IsA("Tool") then
            hum:EquipTool(tool)
            break
        end
    end
end

--=== AUTO FARM ===--
function Functions.StartFarm()
    Functions.StopFarm()
    
    Settings.CurrentSea = Functions.GetSea()
    
    Connections.FarmLoop = RunService.Heartbeat:Connect(function()
        if not Settings.AutoFarm then return end
        
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
            -- Có mob -> farm
            Functions.TeleportToMob(mob)
            Functions.BringMob(mob)
            Functions.Attack()
        else
            -- Không có mob
            if not Functions.HasQuest() then
                -- Chưa có quest -> nhận quest
                Functions.AcceptQuest(islandData.NPCPos, islandData.Mob)
            else
                -- Đã có quest nhưng không có mob -> teleport đến vị trí mob spawn
                Functions.Teleport(islandData.MobPos, Vector3.new(0, 15, 0))
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
