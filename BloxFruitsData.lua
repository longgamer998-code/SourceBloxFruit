--[[
    ╔══════════════════════════════════════════════════════════════╗
    ║                  BLOX FRUITS DATA MODULE                     ║
    ║           Chứa dữ liệu Sea 1, Sea 2, Sea 3                   ║
    ╚══════════════════════════════════════════════════════════════╝
    
    Module này được load ĐẦU TIÊN bởi Main.lua
    Chứa thông tin về:
    - Các đảo (Island)
    - Quái vật (Mobs) với Level, HP, Damage, Position
    - NPC Quest
]]

local BloxFruitsData = {}

--============================================
-- SEA 1 DATA (Level 1 - 700)
--============================================
BloxFruitsData.Sea1 = {
    -- Starter Island
    {
        Island = "Starter Island",
        LevelRange = {1, 15},
        Mobs = {
            {Name = "Bandit", Level = 5, Health = 100, Damage = 10, Position = Vector3.new(-1124, 15, 3855)},
        },
        QuestNPC = {Name = "Bandit Quest Giver", Position = Vector3.new(-1139, 15, 3824)},
    },
    -- Jungle
    {
        Island = "Jungle",
        LevelRange = {15, 30},
        Mobs = {
            {Name = "Monkey", Level = 14, Health = 250, Damage = 22, Position = Vector3.new(-1613, 42, 152)},
            {Name = "Gorilla", Level = 20, Health = 420, Damage = 35, Position = Vector3.new(-1223, 50, 135)},
        },
        QuestNPC = {Name = "Jungle Quest Giver", Position = Vector3.new(-1603, 36, 154)},
    },
    -- Pirate Village
    {
        Island = "Pirate Village",
        LevelRange = {30, 60},
        Mobs = {
            {Name = "Pirate", Level = 35, Health = 650, Damage = 45, Position = Vector3.new(-1140, 5, 3830)},
            {Name = "Brute", Level = 45, Health = 900, Damage = 60, Position = Vector3.new(-1183, 5, 3795)},
        },
        QuestNPC = {Name = "Pirate Quest Giver", Position = Vector3.new(-1133, 5, 3856)},
    },
    -- Desert
    {
        Island = "Desert",
        LevelRange = {60, 90},
        Mobs = {
            {Name = "Desert Bandit", Level = 60, Health = 1100, Damage = 75, Position = Vector3.new(895, 6, 4390)},
            {Name = "Desert Officer", Level = 70, Health = 1400, Damage = 95, Position = Vector3.new(1090, 6, 4460)},
        },
        QuestNPC = {Name = "Desert Quest Giver", Position = Vector3.new(900, 6, 4375)},
    },
    -- Frozen Village
    {
        Island = "Frozen Village",
        LevelRange = {90, 120},
        Mobs = {
            {Name = "Snow Bandit", Level = 90, Health = 1700, Damage = 110, Position = Vector3.new(1386, 87, -1296)},
            {Name = "Snowman", Level = 100, Health = 2000, Damage = 130, Position = Vector3.new(1326, 87, -1346)},
        },
        QuestNPC = {Name = "Frozen Quest Giver", Position = Vector3.new(1386, 87, -1350)},
    },
    -- Marine Fortress
    {
        Island = "Marine Fortress",
        LevelRange = {120, 150},
        Mobs = {
            {Name = "Marine Soldier", Level = 120, Health = 2500, Damage = 160, Position = Vector3.new(-4914, 54, 4288)},
            {Name = "Marine Captain", Level = 130, Health = 3000, Damage = 190, Position = Vector3.new(-4850, 54, 4350)},
        },
        QuestNPC = {Name = "Marine Quest Giver", Position = Vector3.new(-4918, 54, 4324)},
    },
    -- Skylands
    {
        Island = "Skylands",
        LevelRange = {150, 200},
        Mobs = {
            {Name = "Sky Bandit", Level = 150, Health = 3500, Damage = 220, Position = Vector3.new(-4973, 717, -2622)},
            {Name = "Dark Master", Level = 175, Health = 4500, Damage = 280, Position = Vector3.new(-4900, 717, -2700)},
        },
        QuestNPC = {Name = "Sky Quest Giver", Position = Vector3.new(-4966, 717, -2567)},
    },
    -- Prison
    {
        Island = "Prison",
        LevelRange = {190, 275},
        Mobs = {
            {Name = "Prisoner", Level = 190, Health = 5000, Damage = 310, Position = Vector3.new(4875, 6, 740)},
            {Name = "Dangerous Prisoner", Level = 210, Health = 5800, Damage = 360, Position = Vector3.new(4920, 6, 680)},
            {Name = "Warden", Level = 220, Health = 6500, Damage = 400, Position = Vector3.new(4780, 6, 600)},
        },
        QuestNPC = {Name = "Prison Quest Giver", Position = Vector3.new(4851, 6, 660)},
    },
    -- Colosseum
    {
        Island = "Colosseum",
        LevelRange = {225, 300},
        Mobs = {
            {Name = "Toga Warrior", Level = 225, Health = 7000, Damage = 430, Position = Vector3.new(-1576, 7, -2983)},
            {Name = "Gladiator", Level = 275, Health = 8500, Damage = 520, Position = Vector3.new(-1450, 7, -2900)},
        },
        QuestNPC = {Name = "Colosseum Quest Giver", Position = Vector3.new(-1580, 7, -2915)},
    },
    -- Magma Village
    {
        Island = "Magma Village",
        LevelRange = {300, 375},
        Mobs = {
            {Name = "Military Soldier", Level = 300, Health = 9500, Damage = 580, Position = Vector3.new(-5316, 12, 8517)},
            {Name = "Military Spy", Level = 330, Health = 11000, Damage = 670, Position = Vector3.new(-5400, 12, 8600)},
            {Name = "Magma Ninja", Level = 350, Health = 12500, Damage = 760, Position = Vector3.new(-5250, 12, 8700)},
        },
        QuestNPC = {Name = "Magma Quest Giver", Position = Vector3.new(-5320, 12, 8450)},
    },
    -- Underwater City
    {
        Island = "Underwater City",
        LevelRange = {375, 450},
        Mobs = {
            {Name = "Fishman Warrior", Level = 375, Health = 13500, Damage = 820, Position = Vector3.new(61162, 11, 1568)},
            {Name = "Fishman Captain", Level = 400, Health = 15000, Damage = 910, Position = Vector3.new(61200, 11, 1500)},
            {Name = "Fishman Lord", Level = 425, Health = 17000, Damage = 1030, Position = Vector3.new(61100, 11, 1650)},
        },
        QuestNPC = {Name = "Fishman Quest Giver", Position = Vector3.new(61163, 11, 1550)},
    },
    -- Fountain City
    {
        Island = "Fountain City",
        LevelRange = {625, 700},
        Mobs = {
            {Name = "Galley Pirate", Level = 625, Health = 25000, Damage = 1500, Position = Vector3.new(-5765, 313, 3456)},
            {Name = "Galley Captain", Level = 650, Health = 28000, Damage = 1680, Position = Vector3.new(-5700, 313, 3500)},
        },
        QuestNPC = {Name = "Fountain Quest Giver", Position = Vector3.new(-5770, 313, 3400)},
    },
}

--============================================
-- SEA 2 DATA (Level 700 - 1500)
--============================================
BloxFruitsData.Sea2 = {
    -- Kingdom of Rose
    {
        Island = "Kingdom of Rose",
        LevelRange = {700, 850},
        Mobs = {
            {Name = "Swan Pirate", Level = 700, Health = 32000, Damage = 1900, Position = Vector3.new(-367, 73, 896)},
            {Name = "Factory Staff", Level = 750, Health = 36000, Damage = 2150, Position = Vector3.new(-450, 73, 950)},
            {Name = "Diamond", Level = 800, Health = 42000, Damage = 2500, Position = Vector3.new(-300, 73, 800)},
        },
        QuestNPC = {Name = "Rose Quest Giver", Position = Vector3.new(-360, 73, 900)},
    },
    -- Green Zone
    {
        Island = "Green Zone",
        LevelRange = {875, 950},
        Mobs = {
            {Name = "Marine Lieutenant", Level = 875, Health = 48000, Damage = 2850, Position = Vector3.new(-2438, 73, -3294)},
            {Name = "Marine Captain", Level = 925, Health = 55000, Damage = 3270, Position = Vector3.new(-2500, 73, -3200)},
        },
        QuestNPC = {Name = "Green Zone Quest Giver", Position = Vector3.new(-2430, 73, -3300)},
    },
    -- Graveyard
    {
        Island = "Graveyard",
        LevelRange = {950, 1000},
        Mobs = {
            {Name = "Zombie", Level = 950, Health = 58000, Damage = 3450, Position = Vector3.new(-5765, 95, -795)},
            {Name = "Vampire", Level = 975, Health = 62000, Damage = 3680, Position = Vector3.new(-5850, 95, -850)},
        },
        QuestNPC = {Name = "Graveyard Quest Giver", Position = Vector3.new(-5760, 95, -800)},
    },
    -- Snow Mountain
    {
        Island = "Snow Mountain",
        LevelRange = {1000, 1050},
        Mobs = {
            {Name = "Snow Trooper", Level = 1000, Health = 65000, Damage = 3860, Position = Vector3.new(609, 400, -5378)},
            {Name = "Winter Warrior", Level = 1025, Health = 68000, Damage = 4030, Position = Vector3.new(550, 400, -5450)},
        },
        QuestNPC = {Name = "Snow Mountain Quest Giver", Position = Vector3.new(615, 400, -5370)},
    },
    -- Hot and Cold
    {
        Island = "Hot and Cold",
        LevelRange = {1050, 1150},
        Mobs = {
            {Name = "Magma Ninja", Level = 1050, Health = 72000, Damage = 4280, Position = Vector3.new(-5475, 18, -5284)},
            {Name = "Ice Elemental", Level = 1100, Health = 78000, Damage = 4630, Position = Vector3.new(-5550, 18, -5350)},
        },
        QuestNPC = {Name = "Hot Cold Quest Giver", Position = Vector3.new(-5470, 18, -5280)},
    },
    -- Cursed Ship
    {
        Island = "Cursed Ship",
        LevelRange = {1000, 1075},
        Mobs = {
            {Name = "Cursed Captain", Level = 1000, Health = 65000, Damage = 3860, Position = Vector3.new(916, 123, 32884)},
            {Name = "Possessed Mummy", Level = 1050, Health = 72000, Damage = 4280, Position = Vector3.new(900, 123, 32950)},
        },
        QuestNPC = {Name = "Cursed Ship Quest Giver", Position = Vector3.new(920, 123, 32880)},
    },
    -- Ice Castle
    {
        Island = "Ice Castle",
        LevelRange = {1150, 1250},
        Mobs = {
            {Name = "Ice Admiral", Level = 1150, Health = 85000, Damage = 5050, Position = Vector3.new(5669, 27, -6483)},
            {Name = "Awakened Ice Admiral", Level = 1175, Health = 90000, Damage = 5350, Position = Vector3.new(5600, 27, -6550)},
        },
        QuestNPC = {Name = "Ice Castle Quest Giver", Position = Vector3.new(5670, 27, -6480)},
    },
    -- Forgotten Island
    {
        Island = "Forgotten Island",
        LevelRange = {1225, 1325},
        Mobs = {
            {Name = "Forest Pirate", Level = 1225, Health = 95000, Damage = 5650, Position = Vector3.new(-3054, 237, -10842)},
            {Name = "Saber Expert", Level = 1275, Health = 102000, Damage = 6060, Position = Vector3.new(-3100, 237, -10900)},
        },
        QuestNPC = {Name = "Forgotten Quest Giver", Position = Vector3.new(-3050, 237, -10840)},
    },
    -- Dark Arena
    {
        Island = "Dark Arena",
        LevelRange = {1000, 1000},
        Mobs = {
            {Name = "Dark Master", Level = 1000, Health = 65000, Damage = 3860, Position = Vector3.new(-456, 3, 4335)},
        },
        QuestNPC = nil, -- Boss only
    },
    -- Usoap's Island
    {
        Island = "Usoap's Island",
        LevelRange = {1325, 1425},
        Mobs = {
            {Name = "Urban Pirate", Level = 1325, Health = 110000, Damage = 6530, Position = Vector3.new(-1861, 11, -1618)},
            {Name = "Urban Captain", Level = 1375, Health = 118000, Damage = 7010, Position = Vector3.new(-1900, 11, -1700)},
        },
        QuestNPC = {Name = "Usoap Quest Giver", Position = Vector3.new(-1855, 11, -1615)},
    },
    -- Mansion
    {
        Island = "Mansion",
        LevelRange = {1425, 1500},
        Mobs = {
            {Name = "Reborn Skeleton", Level = 1425, Health = 125000, Damage = 7430, Position = Vector3.new(-4846, 84, -4487)},
            {Name = "Undead Pirate", Level = 1475, Health = 135000, Damage = 8020, Position = Vector3.new(-4900, 84, -4550)},
        },
        QuestNPC = {Name = "Mansion Quest Giver", Position = Vector3.new(-4840, 84, -4485)},
    },
}

--============================================
-- SEA 3 DATA (Level 1500 - 2550)
--============================================
BloxFruitsData.Sea3 = {
    -- Port Town
    {
        Island = "Port Town",
        LevelRange = {1500, 1575},
        Mobs = {
            {Name = "Pirate Millionaire", Level = 1500, Health = 145000, Damage = 8610, Position = Vector3.new(-290, 44, 5321)},
            {Name = "Pistol Billionaire", Level = 1550, Health = 155000, Damage = 9210, Position = Vector3.new(-350, 44, 5400)},
        },
        QuestNPC = {Name = "Port Town Quest Giver", Position = Vector3.new(-285, 44, 5318)},
    },
    -- Hydra Island
    {
        Island = "Hydra Island",
        LevelRange = {1575, 1675},
        Mobs = {
            {Name = "Hydra Warrior", Level = 1575, Health = 165000, Damage = 9800, Position = Vector3.new(5228, 452, 344)},
            {Name = "Hydra Captain", Level = 1625, Health = 175000, Damage = 10400, Position = Vector3.new(5300, 452, 400)},
            {Name = "Hydra Island Boss", Level = 1650, Health = 185000, Damage = 10990, Position = Vector3.new(5150, 452, 280)},
        },
        QuestNPC = {Name = "Hydra Quest Giver", Position = Vector3.new(5225, 452, 340)},
    },
    -- Great Tree
    {
        Island = "Great Tree",
        LevelRange = {1700, 1775},
        Mobs = {
            {Name = "Tree Fighter", Level = 1700, Health = 195000, Damage = 11590, Position = Vector3.new(2275, 30, -6507)},
            {Name = "Nature Guardian", Level = 1750, Health = 210000, Damage = 12480, Position = Vector3.new(2350, 30, -6600)},
        },
        QuestNPC = {Name = "Great Tree Quest Giver", Position = Vector3.new(2270, 30, -6505)},
    },
    -- Floating Turtle
    {
        Island = "Floating Turtle",
        LevelRange = {1775, 1900},
        Mobs = {
            {Name = "Marine Commodore", Level = 1775, Health = 220000, Damage = 13070, Position = Vector3.new(-13274, 457, -7735)},
            {Name = "Marine Rear Admiral", Level = 1825, Health = 235000, Damage = 13960, Position = Vector3.new(-13350, 457, -7800)},
            {Name = "Fishman Raider", Level = 1875, Health = 250000, Damage = 14850, Position = Vector3.new(-13200, 457, -7670)},
        },
        QuestNPC = {Name = "Floating Turtle Quest Giver", Position = Vector3.new(-13270, 457, -7730)},
    },
    -- Castle on the Sea
    {
        Island = "Castle on the Sea",
        LevelRange = {1000, 1000},
        Mobs = {
            -- Boss Area
        },
        QuestNPC = nil,
    },
    -- Haunted Castle
    {
        Island = "Haunted Castle",
        LevelRange = {1975, 2075},
        Mobs = {
            {Name = "Demonic Soul", Level = 1975, Health = 280000, Damage = 16640, Position = Vector3.new(-9515, 171, 5765)},
            {Name = "Possessed Guardian", Level = 2025, Health = 300000, Damage = 17830, Position = Vector3.new(-9600, 171, 5850)},
            {Name = "Soul Reaper", Level = 2050, Health = 315000, Damage = 18720, Position = Vector3.new(-9430, 171, 5680)},
        },
        QuestNPC = {Name = "Haunted Castle Quest Giver", Position = Vector3.new(-9510, 171, 5760)},
    },
    -- Sea of Treats
    {
        Island = "Sea of Treats",
        LevelRange = {2075, 2275},
        Mobs = {
            {Name = "Cake Guard", Level = 2075, Health = 330000, Damage = 19610, Position = Vector3.new(-68, 41, 11514)},
            {Name = "Cookie Crafter", Level = 2125, Health = 350000, Damage = 20800, Position = Vector3.new(-150, 41, 11600)},
            {Name = "Biscuit Soldier", Level = 2175, Health = 370000, Damage = 21990, Position = Vector3.new(30, 41, 11430)},
            {Name = "Chocolate Bar Battler", Level = 2225, Health = 390000, Damage = 23180, Position = Vector3.new(-100, 41, 11700)},
        },
        QuestNPC = {Name = "Sea of Treats Quest Giver", Position = Vector3.new(-65, 41, 11510)},
    },
    -- Tiki Outpost
    {
        Island = "Tiki Outpost",
        LevelRange = {2225, 2300},
        Mobs = {
            {Name = "Tiki Warrior", Level = 2225, Health = 390000, Damage = 23180, Position = Vector3.new(-1057, 65, -10580)},
            {Name = "Tribal Chief", Level = 2275, Health = 410000, Damage = 24370, Position = Vector3.new(-1130, 65, -10660)},
        },
        QuestNPC = {Name = "Tiki Outpost Quest Giver", Position = Vector3.new(-1055, 65, -10575)},
    },
    -- Kitsune Shrine
    {
        Island = "Kitsune Shrine",
        LevelRange = {2300, 2400},
        Mobs = {
            {Name = "Kitsune Guardian", Level = 2300, Health = 420000, Damage = 24960, Position = Vector3.new(-5765, 215, -535)},
            {Name = "Fox Spirit", Level = 2350, Health = 440000, Damage = 26150, Position = Vector3.new(-5840, 215, -600)},
        },
        QuestNPC = {Name = "Kitsune Shrine Quest Giver", Position = Vector3.new(-5760, 215, -530)},
    },
    -- Atlantis
    {
        Island = "Atlantis",
        LevelRange = {2450, 2550},
        Mobs = {
            {Name = "Atlantean Warrior", Level = 2450, Health = 480000, Damage = 28530, Position = Vector3.new(6665, -1917, -515)},
            {Name = "Atlantean Guard", Level = 2500, Health = 500000, Damage = 29720, Position = Vector3.new(6740, -1917, -590)},
            {Name = "Atlantean Champion", Level = 2550, Health = 530000, Damage = 31500, Position = Vector3.new(6590, -1917, -440)},
        },
        QuestNPC = {Name = "Atlantis Quest Giver", Position = Vector3.new(6660, -1917, -510)},
    },
}

return BloxFruitsData
