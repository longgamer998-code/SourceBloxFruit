-- ╔══════════════════════════════════════════════════════════╗
-- ║  CONFIG.LUA - Data Configuration Only                    ║
-- ╚══════════════════════════════════════════════════════════╝

local Config = {}

-- ========== QUEST DATA ==========
Config.QuestData = {
    ["BanditQuest1"] = {{LevelReq = 0, Name = "Bandits", Task = {Bandit = 5}, Reward = {Beli = 350, Exp = 300}}},
    ["JungleQuest"] = {
        {LevelReq = 10, Name = "Monkeys", Task = {Monkey = 6}, Reward = {Beli = 800, Exp = 2300}},
        {LevelReq = 15, Name = "Gorillas", Task = {Gorilla = 8}, Reward = {Beli = 1200, Exp = 4500}},
        {LevelReq = 20, Name = "Gorilla King", Task = {["The Gorilla King"] = 1}, Reward = {Beli = 2000, Exp = 9500}}
    },
    ["BuggyQuest1"] = {
        {LevelReq = 30, Name = "Pirates", Task = {Pirate = 8}, Reward = {Beli = 3000, Exp = 13000}},
        {LevelReq = 40, Name = "Brute", Task = {Brute = 8}, Reward = {Beli = 3500, Exp = 22000}},
        {LevelReq = 55, Name = "Chef", Task = {Chef = 1}, Reward = {Beli = 8000, Exp = 45000}}
    },
    ["DesertQuest"] = {
        {LevelReq = 60, Name = "Desert Bandit", Task = {["Desert Bandit"] = 8}, Reward = {Beli = 4000, Exp = 45000}},
        {LevelReq = 75, Name = "Desert Officer", Task = {["Desert Officer"] = 6}, Reward = {Beli = 4500, Exp = 65000}}
    },
    ["SnowQuest"] = {
        {LevelReq = 90, Name = "Snow Bandit", Task = {["Snow Bandit"] = 7}, Reward = {Beli = 5000, Exp = 90000}},
        {LevelReq = 100, Name = "Snowman", Task = {Snowman = 8}, Reward = {Beli = 5500, Exp = 150000}},
        {LevelReq = 105, Name = "Yeti", Task = {Yeti = 1}, Reward = {Beli = 10000, Exp = 220000}}
    },
    ["MarineQuest"] = {{LevelReq = 0, Name = "Trainees", Task = {Trainee = 5}, Reward = {Beli = 350, Exp = 300}}},
    ["MarineQuest2"] = {
        {LevelReq = 120, Name = "Chief Petty Officer", Task = {["Chief Petty Officer"] = 8}, Reward = {Beli = 6000, Exp = 225000}},
        {LevelReq = 130, Name = "Vice Admiral", Task = {["Vice Admiral"] = 1}, Reward = {Beli = 15000, Exp = 415000}}
    },
    ["SkyQuest"] = {
        {LevelReq = 150, Name = "Sky Bandit", Task = {["Sky Bandit"] = 7}, Reward = {Beli = 7000, Exp = 315000}},
        {LevelReq = 175, Name = "Dark Master", Task = {["Dark Master"] = 8}, Reward = {Beli = 7500, Exp = 450000}}
    },
    ["PrisonerQuest"] = {
        {LevelReq = 190, Name = "Prisoner", Task = {Prisoner = 8}, Reward = {Beli = 7000, Exp = 550000}},
        {LevelReq = 210, Name = "Dangerous Prisoner", Task = {["Dangerous Prisoner"] = 8}, Reward = {Beli = 7500, Exp = 780000}}
    },
    ["ColosseumQuest"] = {
        {LevelReq = 250, Name = "Toga Warrior", Task = {["Toga Warrior"] = 7}, Reward = {Beli = 7000, Exp = 1100000}},
        {LevelReq = 275, Name = "Gladiator", Task = {Gladiator = 8}, Reward = {Beli = 7500, Exp = 1300000}}
    },
    ["MagmaQuest"] = {
        {LevelReq = 300, Name = "Mil.  Soldier", Task = {["Military Soldier"] = 7}, Reward = {Beli = 8250, Exp = 1700000}},
        {LevelReq = 325, Name = "Mil.  Spy", Task = {["Military Spy"] = 8}, Reward = {Beli = 8500, Exp = 2000000}},
        {LevelReq = 350, Name = "Magma Admiral", Task = {["Magma Admiral"] = 1}, Reward = {Beli = 15000, Exp = 3000000}}
    },
    ["FishmanQuest"] = {
        {LevelReq = 375, Name = "Fishman Warrior", Task = {["Fishman Warrior"] = 8}, Reward = {Beli = 8750, Exp = 3050000}},
        {LevelReq = 400, Name = "Fishman Commando", Task = {["Fishman Commando"] = 7}, Reward = {Beli = 9000, Exp = 3350000}},
        {LevelReq = 425, Name = "Fishman Lord", Task = {["Fishman Lord"] = 1}, Reward = {Beli = 15000, Exp = 4250000}}
    },
}

-- ========== QUEST LOCATIONS ==========
Config.QuestLocations = {
    ["BanditQuest1"] = Vector3.new(1059, 17, 1544),
    ["JungleQuest"] = Vector3.new(-1604, 37, 152),
    ["BuggyQuest1"] = Vector3.new(-1139, 5, 3831),
    ["DesertQuest"] = Vector3.new(897, 7, 4388),
    ["SnowQuest"] = Vector3.new(1386, 87, -1298),
    ["MarineQuest"] = Vector3.new(-2709, 28, 2124),
    ["MarineQuest2"] = Vector3.new(-5039, 28, 4325),
    ["SkyQuest"] = Vector3.new(-4842, 718, -2623),
    ["PrisonerQuest"] = Vector3.new(5308, 2, 474),
    ["ColosseumQuest"] = Vector3.new(-1427, 8, -2773),
    ["MagmaQuest"] = Vector3.new(-5317, 12, 8515),
    ["FishmanQuest"] = Vector3.new(61123, 19, 1569),
}

-- ========== ISLAND LOCATIONS ==========
Config.IslandLocations = {
    {name = "🏝️ Starter", pos = Vector3.new(1059, 17, 1544)},
    {name = "🌴 Jungle", pos = Vector3.new(-1604, 37, 152)},
    {name = "🏴‍☠️ Pirate Village", pos = Vector3.new(-1139, 5, 3831)},
    {name = "🏜️ Desert", pos = Vector3.new(897, 7, 4388)},
    {name = "❄️ Frozen", pos = Vector3.new(1386, 87, -1298)},
    {name = "⚓ Marine", pos = Vector3.new(-2709, 28, 2124)},
}

-- ========== SETTINGS ==========
Config.Settings = {
    Enabled = false,
    AutoQuest = true,
    FastAttack = false,
    AutoHaki = false,
    SafeTeleport = true,
    TweenSpeed = 200,
    FarmDistance = 15,
    CurrentQuest = "None",
    MobsKilled = 0,
    QuestsCompleted = 0,
    SelectedWeapon = "Combat",
    AutoEquipWeapon = true,
    DebugMode = false,
}

-- ========== COMBAT DEBUG STATS ==========
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

-- ========== CONSOLE LOG ==========
Config.ConsoleLog = {}
Config.MAX_LOGS = 300

return Config