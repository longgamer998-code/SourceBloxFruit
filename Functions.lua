--[[
    FUNCTIONS MODULE - Auto Farm theo Level + Teleport đảo đúng
]]

local Functions = {}

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local Workspace = game:GetService("Workspace")

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
function Functions.TeleportTo(cframe)
    local hrp = Functions.GetHRP()
    if hrp then
        hrp.CFrame = cframe + Vector3.new(0, 10, 0)
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
function Functions.FindMob(targetName)
    local enemies = Workspace:FindFirstChild("Enemies")
    if not enemies then return nil end
    
    local hrp = Functions.GetHRP()
    if not hrp then return nil end
    
    local nearestMob = nil
    local nearestDist = math.huge
    
    for _, mob in pairs(enemies:GetChildren()) do
        if mob:IsA("Model") and mob.Name == targetName then
            local hum = mob:FindFirstChild("Humanoid")
            local mobHRP = mob:FindFirstChild("HumanoidRootPart")
            
            if hum and mobHRP and hum.Health > 0 then
                local dist = (hrp.Position - mobHRP.Position).Magnitude
                if dist < nearestDist then
                    nearestDist = dist
                    nearestMob = mob
                end
            end
        end
    end
    
    return nearestMob
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

--=== EQUIP ===--
function Functions.EquipWeapon()
    local backpack = player:FindFirstChild("Backpack")
    local char = Functions.GetCharacter()
    local hum = Functions.GetHumanoid()
    if not backpack or not hum then return end
    
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
        
        -- Update level
        local level = Functions.GetLevel()
        Settings.CurrentLevel = level
        
        -- Lấy data đảo theo level
        local islandData = Data.GetIslandByLevel(level, Settings.CurrentSea)
        if not islandData then return end
        
        Settings.CurrentIsland = islandData.Island
        Settings.CurrentMob = islandData.Mob
        
        -- Auto Equip
        if Settings.AutoEquip then
            Functions.EquipWeapon()
        end
        
        -- Tìm mob đúng tên
        local mob = Functions.FindMob(islandData.Mob)
        
        if mob then
            -- Có mob → Farm
            Settings.CurrentMob = islandData.Mob .. " ✓"
            Functions.TeleportToMob(mob)
            Functions.BringMob(mob)
            Functions.Attack()
        else
            -- Không có mob → Teleport đến vị trí đảo đúng
            Settings.CurrentMob = islandData.Mob .. " (teleporting...)"
            Functions.TeleportTo(islandData.Pos)
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
