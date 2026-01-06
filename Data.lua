--[[
    DATA MODULE - Mob + Vị trí Teleport chính xác
]]

local Data = {}

-- CFrame.new(X, Y, Z) = vị trí mob spawn
Data.Sea1 = {
    {Island = "Starter Island", Level = {1, 10}, Mob = "Bandit", Pos = CFrame.new(-1102, 16, 3852)},
    {Island = "Jungle", Level = {10, 20}, Mob = "Monkey", Pos = CFrame.new(-1613, 42, 152)},
    {Island = "Jungle", Level = {20, 30}, Mob = "Gorilla", Pos = CFrame.new(-1223, 50, 135)},
    {Island = "Pirate Village", Level = {30, 45}, Mob = "Pirate", Pos = CFrame.new(-1176, 4, 3787)},
    {Island = "Pirate Village", Level = {45, 60}, Mob = "Brute", Pos = CFrame.new(-1게41, 4, 3800)},
    {Island = "Desert", Level = {60, 75}, Mob = "Desert Bandit", Pos = CFrame.new(1095, 6, 4180)},
    {Island = "Desert", Level = {75, 90}, Mob = "Desert Officer", Pos = CFrame.new(1578, 12, 4339)},
    {Island = "Frozen Village", Level = {90, 105}, Mob = "Snow Bandit", Pos = CFrame.new(1386, 87, -1343)},
    {Island = "Frozen Village", Level = {105, 120}, Mob = "Snowman", Pos = CFrame.new(1329, 87, -1265)},
    {Island = "Marine Fortress", Level = {120, 135}, Mob = "Chief Petty Officer", Pos = CFrame.new(-5019, 28, 4324)},
    {Island = "Marine Fortress", Level = {135, 150}, Mob = "Vice Admiral", Pos = CFrame.new(-5100, 28, 4193)},
    {Island = "Skylands", Level = {150, 175}, Mob = "Sky Bandit", Pos = CFrame.new(-4869, 717, -2623)},
    {Island = "Skylands", Level = {175, 200}, Mob = "Dark Master", Pos = CFrame.new(-5765, 381, -2778)},
    {Island = "Prison", Level = {200, 235}, Mob = "Prisoner", Pos = CFrame.new(5765, 5, 747)},
    {Island = "Prison", Level = {235, 275}, Mob = "Dangerous Prisoner", Pos = CFrame.new(6088, 5, 1155)},
    {Island = "Colosseum", Level = {275, 300}, Mob = "Toga Warrior", Pos = CFrame.new(-1428, 7, -3014)},
    {Island = "Colosseum", Level = {300, 350}, Mob = "Gladiator", Pos = CFrame.new(-1606, 7, -2956)},
    {Island = "Magma Village", Level = {350, 375}, Mob = "Military Soldier", Pos = CFrame.new(-5250, 12, 8515)},
    {Island = "Magma Village", Level = {375, 400}, Mob = "Military Spy", Pos = CFrame.new(-5467, 12, 8381)},
    {Island = "Underwater City", Level = {400, 450}, Mob = "Fishman Warrior", Pos = CFrame.new(61163, 11, 1819)},
    {Island = "Underwater City", Level = {450, 500}, Mob = "Fishman Commando", Pos = CFrame.new(61597, 11, 1792)},
    {Island = "Upper Skylands", Level = {500, 550}, Mob = "God's Guard", Pos = CFrame.new(-4726, 843, -1926)},
    {Island = "Upper Skylands", Level = {550, 575}, Mob = "Shanda", Pos = CFrame.new(-7894, 5547, -380)},
    {Island = "Fountain City", Level = {575, 625}, Mob = "Galley Pirate", Pos = CFrame.new(5127, 38, 4046)},
    {Island = "Fountain City", Level = {625, 700}, Mob = "Galley Captain", Pos = CFrame.new(5259, 38, 4050)},
}

Data.Sea2 = {
    {Island = "Kingdom of Rose", Level = {700, 775}, Mob = "Swan Pirate", Pos = CFrame.new(2179, 73, -6741)},
    {Island = "Kingdom of Rose", Level = {775, 850}, Mob = "Factory Staff", Pos = CFrame.new(3331, 23, -6410)},
    {Island = "Green Zone", Level = {850, 925}, Mob = "Zombie", Pos = CFrame.new(-5765, 210, -782)},
    {Island = "Green Zone", Level = {925, 1000}, Mob = "Vampire", Pos = CFrame.new(-5765, 210, -782)},
    {Island = "Graveyard", Level = {1000, 1050}, Mob = "Snow Trooper", Pos = CFrame.new(613, 400, -5765)},
    {Island = "Snow Mountain", Level = {1050, 1100}, Mob = "Winter Warrior", Pos = CFrame.new(1203, 438, -5765)},
    {Island = "Hot and Cold", Level = {1100, 1175}, Mob = "Lab Subordinate", Pos = CFrame.new(-6006, 15, -4765)},
    {Island = "Hot and Cold", Level = {1175, 1250}, Mob = "Horned Warrior", Pos = CFrame.new(-6006, 15, -4765)},
    {Island = "Cursed Ship", Level = {1250, 1325}, Mob = "Ship Deckhand", Pos = CFrame.new(923, 125, 32988)},
    {Island = "Cursed Ship", Level = {1325, 1375}, Mob = "Ship Engineer", Pos = CFrame.new(923, 125, 32988)},
    {Island = "Ice Castle", Level = {1375, 1425}, Mob = "Arctic Warrior", Pos = CFrame.new(5668, 27, -6484)},
    {Island = "Ice Castle", Level = {1425, 1500}, Mob = "Snow Lurker", Pos = CFrame.new(5668, 27, -6484)},
}

Data.Sea3 = {
    {Island = "Port Town", Level = {1500, 1575}, Mob = "Pirate Millionaire", Pos = CFrame.new(-285, 44, 5318)},
    {Island = "Hydra Island", Level = {1575, 1675}, Mob = "Dragon Crew Warrior", Pos = CFrame.new(5228, 452, 344)},
    {Island = "Great Tree", Level = {1675, 1750}, Mob = "Forest Pirate", Pos = CFrame.new(2275, 30, -6507)},
    {Island = "Floating Turtle", Level = {1750, 1900}, Mob = "Fishman Raider", Pos = CFrame.new(-13274, 457, -7735)},
    {Island = "Haunted Castle", Level = {1900, 2000}, Mob = "Demonic Soul", Pos = CFrame.new(-9515, 171, 5765)},
    {Island = "Sea of Treats", Level = {2000, 2100}, Mob = "Cake Guard", Pos = CFrame.new(-68, 41, 11514)},
    {Island = "Sea of Treats", Level = {2100, 2200}, Mob = "Cookie Crafter", Pos = CFrame.new(-548, 41, 11714)},
    {Island = "Tiki Outpost", Level = {2200, 2300}, Mob = "Tiki Warrior", Pos = CFrame.new(-1057, 65, -10580)},
    {Island = "Kitsune Shrine", Level = {2300, 2450}, Mob = "Kitsune Guardian", Pos = CFrame.new(-5765, 215, -535)},
}

function Data.GetIslandByLevel(level, sea)
    local seaData = Data["Sea" .. sea]
    if not seaData then return nil end
    
    for _, island in ipairs(seaData) do
        if level >= island.Level[1] and level <= island.Level[2] then
            return island
        end
    end
    
    return seaData[#seaData]
end

return Data
