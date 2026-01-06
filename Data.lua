--[[
    DATA MODULE - Tên mob chính xác từ Blox Fruits Wiki
]]

local Data = {}

Data.Sea1 = {
    {Island = "Starter Island", Level = {1, 10}, Mob = "Bandit"},
    {Island = "Jungle", Level = {10, 20}, Mob = "Monkey"},
    {Island = "Jungle", Level = {20, 30}, Mob = "Gorilla"},
    {Island = "Pirate Village", Level = {30, 45}, Mob = "Pirate"},
    {Island = "Pirate Village", Level = {45, 60}, Mob = "Brute"},
    {Island = "Desert", Level = {60, 75}, Mob = "Desert Bandit"},
    {Island = "Desert", Level = {75, 90}, Mob = "Desert Officer"},
    {Island = "Frozen Village", Level = {90, 105}, Mob = "Snow Bandit"},
    {Island = "Frozen Village", Level = {105, 120}, Mob = "Snowman"},
    {Island = "Marine Fortress", Level = {120, 135}, Mob = "Chief Petty Officer"},
    {Island = "Marine Fortress", Level = {135, 150}, Mob = "Vice Admiral"},
    {Island = "Skylands", Level = {150, 175}, Mob = "Sky Bandit"},
    {Island = "Skylands", Level = {175, 200}, Mob = "Dark Master"},
    {Island = "Prison", Level = {200, 235}, Mob = "Prisoner"},
    {Island = "Prison", Level = {235, 275}, Mob = "Dangerous Prisoner"},
    {Island = "Colosseum", Level = {275, 300}, Mob = "Toga Warrior"},
    {Island = "Colosseum", Level = {300, 350}, Mob = "Gladiator"},
    {Island = "Magma Village", Level = {350, 375}, Mob = "Military Soldier"},
    {Island = "Magma Village", Level = {375, 400}, Mob = "Military Spy"},
    {Island = "Underwater City", Level = {400, 450}, Mob = "Fishman Warrior"},
    {Island = "Underwater City", Level = {450, 500}, Mob = "Fishman Commando"},
    {Island = "Skylands Upper", Level = {500, 550}, Mob = "God's Guard"},
    {Island = "Skylands Upper", Level = {550, 575}, Mob = "Shanda"},
    {Island = "Fountain City", Level = {575, 625}, Mob = "Galley Pirate"},
    {Island = "Fountain City", Level = {625, 700}, Mob = "Galley Captain"},
}

Data.Sea2 = {
    {Island = "Kingdom of Rose", Level = {700, 775}, Mob = "Swan Pirate"},
    {Island = "Kingdom of Rose", Level = {775, 850}, Mob = "Factory Staff"},
    {Island = "Green Zone", Level = {850, 925}, Mob = "Zombie"},
    {Island = "Green Zone", Level = {925, 1000}, Mob = "Vampire"},
    {Island = "Graveyard", Level = {1000, 1050}, Mob = "Snow Trooper"},
    {Island = "Snow Mountain", Level = {1050, 1100}, Mob = "Winter Warrior"},
    {Island = "Hot and Cold", Level = {1100, 1175}, Mob = "Lab Subordinate"},
    {Island = "Hot and Cold", Level = {1175, 1250}, Mob = "Horned Warrior"},
    {Island = "Cursed Ship", Level = {1250, 1325}, Mob = "Ship Deckhand"},
    {Island = "Cursed Ship", Level = {1325, 1375}, Mob = "Ship Engineer"},
    {Island = "Ice Castle", Level = {1375, 1425}, Mob = "Arctic Warrior"},
    {Island = "Ice Castle", Level = {1425, 1500}, Mob = "Snow Lurker"},
}

Data.Sea3 = {
    {Island = "Port Town", Level = {1500, 1575}, Mob = "Pirate Millionaire"},
    {Island = "Hydra Island", Level = {1575, 1675}, Mob = "Dragon Crew Warrior"},
    {Island = "Great Tree", Level = {1675, 1750}, Mob = "Forest Pirate"},
    {Island = "Floating Turtle", Level = {1750, 1900}, Mob = "Fishman Raider"},
    {Island = "Haunted Castle", Level = {1900, 2000}, Mob = "Demonic Soul"},
    {Island = "Sea of Treats", Level = {2000, 2100}, Mob = "Cake Guard"},
    {Island = "Sea of Treats", Level = {2100, 2200}, Mob = "Cookie Crafter"},
    {Island = "Tiki Outpost", Level = {2200, 2300}, Mob = "Tiki Warrior"},
    {Island = "Kitsune Shrine", Level = {2300, 2400}, Mob = "Kitsune Guardian"},
}

function Data.GetIslandByLevel(level, sea)
    local seaData = Data["Sea" .. sea]
    if not seaData then return nil end
    
    for _, island in ipairs(seaData) do
        if level >= island.Level[1] and level <= island.Level[2] then
            return island
        end
    end
    
    -- Nếu level cao hơn max, trả về entry cuối
    return seaData[#seaData]
end

return Data
