--[[
    FSM MODULE - Finite State Machine for Auto Farm
    
    States:
    - IDLE: Waiting for user to enable
    - UPDATE_TARGET: Read level, get island data, check if island changed
    - TELEPORT_ISLAND: Teleport to new island (only when island changes)
    - FIND_MOB: Search for mob in Enemies folder
    - COMBAT: Attack mob with internal cooldown
]]

local FSM = {}

local Players = game:GetService("Players")
local VirtualInputManager = game:GetService("VirtualInputManager")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer

--=== CONSTANTS ===--
local STATES = {
    IDLE = "IDLE",
    UPDATE_TARGET = "UPDATE_TARGET",
    TELEPORT_ISLAND = "TELEPORT_ISLAND",
    FIND_MOB = "FIND_MOB",
    COMBAT = "COMBAT"
}

local COOLDOWNS = {
    FIND_MOB_RETRY = 0.5,
    TELEPORT_WAIT = 1.0,
    ATTACK = 0.15,
    TICK = 0.1
}

--=== STATE VARIABLES ===--
local currentState = STATES.IDLE
local Settings = nil
local Data = nil

-- Tracking
local currentIsland = nil
local currentMob = nil
local targetData = nil
local activeMob = nil

-- Timers
local lastFindMobTime = 0
local lastAttackTime = 0

--=== DEBUG LOG ===--
local function Log(message)
    print("[FSM]", os.date("%H:%M:%S"), "-", message)
end

local function TransitionTo(newState, reason)
    if currentState ~= newState then
        Log("Transition: " .. currentState .. " -> " .. newState .. " (" .. reason .. ")")
        currentState = newState
    end
end

--=== HELPER FUNCTIONS ===--
local function GetCharacter()
    return player.Character
end

local function GetHRP()
    local char = GetCharacter()
    return char and char:FindFirstChild("HumanoidRootPart")
end

local function GetHumanoid()
    local char = GetCharacter()
    return char and char:FindFirstChild("Humanoid")
end

local function GetLevel()
    local data = player:FindFirstChild("Data")
    if data then
        local level = data:FindFirstChild("Level")
        if level then return level.Value end
    end
    return 1
end

local function GetSea()
    local seas = {[2753915549] = 1, [4442272183] = 2, [7449423635] = 3}
    return seas[game.PlaceId] or 1
end

--=== STATE HANDLERS ===--

-- S0: IDLE
local function HandleIdle()
    if Settings.AutoFarm then
        TransitionTo(STATES.UPDATE_TARGET, "User enabled Auto Farm")
    end
end

-- S1: UPDATE_TARGET
local function HandleUpdateTarget()
    if not Settings.AutoFarm then
        TransitionTo(STATES.IDLE, "User disabled Auto Farm")
        return
    end
    
    local level = GetLevel()
    local sea = GetSea()
    
    Settings.CurrentLevel = level
    Settings.CurrentSea = sea
    
    targetData = Data.GetIslandByLevel(level, sea)
    
    if not targetData then
        Log("No target data for level " .. level)
        TransitionTo(STATES.IDLE, "No island data")
        return
    end
    
    Settings.CurrentIsland = targetData.Island
    Settings.CurrentMob = targetData.Mob
    
    -- Check if island changed
    local newIslandKey = targetData.Island .. "_" .. targetData.Mob
    
    if currentIsland ~= newIslandKey then
        Log("Island change detected: " .. (currentIsland or "none") .. " -> " .. newIslandKey)
        currentIsland = newIslandKey
        TransitionTo(STATES.TELEPORT_ISLAND, "New island/mob target")
    else
        TransitionTo(STATES.FIND_MOB, "Same island, find mob")
    end
end

-- S2: TELEPORT_ISLAND
local function HandleTeleportIsland()
    if not Settings.AutoFarm then
        TransitionTo(STATES.IDLE, "User disabled Auto Farm")
        return
    end
    
    local hrp = GetHRP()
    if not hrp or not targetData then
        TransitionTo(STATES.UPDATE_TARGET, "No HRP or target data")
        return
    end
    
    -- Teleport to island position
    Log("Teleporting to " .. targetData.Island .. " for " .. targetData.Mob)
    hrp.CFrame = targetData.Pos + Vector3.new(0, 10, 0)
    
    -- Wait for game to load
    task.wait(COOLDOWNS.TELEPORT_WAIT)
    
    TransitionTo(STATES.FIND_MOB, "Teleport complete")
end

-- S3: FIND_MOB
local function HandleFindMob()
    if not Settings.AutoFarm then
        TransitionTo(STATES.IDLE, "User disabled Auto Farm")
        return
    end
    
    -- Cooldown check
    local now = tick()
    if now - lastFindMobTime < COOLDOWNS.FIND_MOB_RETRY then
        return -- Wait, don't spam
    end
    lastFindMobTime = now
    
    -- Search for mob
    local enemies = Workspace:FindFirstChild("Enemies")
    if not enemies then
        Settings.CurrentMob = targetData.Mob .. " (no enemies folder)"
        return -- Stay in FIND_MOB, retry
    end
    
    local hrp = GetHRP()
    if not hrp then return end
    
    local nearestMob = nil
    local nearestDist = math.huge
    
    for _, mob in pairs(enemies:GetChildren()) do
        if mob:IsA("Model") and mob.Name == targetData.Mob then
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
    
    if nearestMob then
        activeMob = nearestMob
        Log("Found mob: " .. nearestMob.Name)
        TransitionTo(STATES.COMBAT, "Mob found")
    else
        Settings.CurrentMob = targetData.Mob .. " (waiting...)"
        -- Stay in FIND_MOB, will retry after cooldown
    end
end

-- S4: COMBAT
local function HandleCombat()
    if not Settings.AutoFarm then
        activeMob = nil
        TransitionTo(STATES.IDLE, "User disabled Auto Farm")
        return
    end
    
    -- Check if mob still valid
    if not activeMob or not activeMob.Parent then
        activeMob = nil
        TransitionTo(STATES.UPDATE_TARGET, "Mob disappeared")
        return
    end
    
    local mobHum = activeMob:FindFirstChild("Humanoid")
    local mobHRP = activeMob:FindFirstChild("HumanoidRootPart")
    
    if not mobHum or not mobHRP or mobHum.Health <= 0 then
        activeMob = nil
        Log("Mob dead")
        TransitionTo(STATES.UPDATE_TARGET, "Mob dead")
        return
    end
    
    -- Attack cooldown
    local now = tick()
    if now - lastAttackTime < COOLDOWNS.ATTACK then
        return -- Wait for cooldown
    end
    lastAttackTime = now
    
    local hrp = GetHRP()
    local hum = GetHumanoid()
    if not hrp or not hum then return end
    
    -- Auto Equip
    if Settings.AutoEquip then
        local char = GetCharacter()
        if char and not char:FindFirstChildOfClass("Tool") then
            local backpack = player:FindFirstChild("Backpack")
            if backpack then
                local tool = backpack:FindFirstChildOfClass("Tool")
                if tool then
                    hum:EquipTool(tool)
                end
            end
        end
    end
    
    -- Teleport to mob
    hrp.CFrame = CFrame.new(mobHRP.Position + Vector3.new(0, 15, 0)) * CFrame.Angles(math.rad(-90), 0, 0)
    
    -- Bring mob
    mobHRP.CFrame = hrp.CFrame * CFrame.new(0, -15, 0)
    
    -- Attack
    pcall(function()
        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
        task.wait(0.05)
        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0)
    end)
    
    Settings.CurrentMob = targetData.Mob .. " ✓"
end

--=== MAIN FSM TICK ===--
local function Tick()
    if currentState == STATES.IDLE then
        HandleIdle()
    elseif currentState == STATES.UPDATE_TARGET then
        HandleUpdateTarget()
    elseif currentState == STATES.TELEPORT_ISLAND then
        HandleTeleportIsland()
    elseif currentState == STATES.FIND_MOB then
        HandleFindMob()
    elseif currentState == STATES.COMBAT then
        HandleCombat()
    end
end

--=== PUBLIC API ===--
local loopConnection = nil

function FSM.Init(settings, data)
    Settings = settings
    Data = data
    currentState = STATES.IDLE
    currentIsland = nil
    activeMob = nil
    Log("FSM Initialized")
end

function FSM.Start()
    if loopConnection then return end
    
    Log("FSM Started")
    
    loopConnection = task.spawn(function()
        while loopConnection do
            Tick()
            task.wait(COOLDOWNS.TICK)
        end
    end)
end

function FSM.Stop()
    if loopConnection then
        task.cancel(loopConnection)
        loopConnection = nil
    end
    currentState = STATES.IDLE
    activeMob = nil
    Log("FSM Stopped")
end

function FSM.GetState()
    return currentState
end

return FSM
