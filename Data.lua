--[[
    DATA MODULE - Chứa thông tin đảo/mob theo Sea và Level
]]

local Data = {}

Data.Sea1 = {
    {Island = "Starter Island", Level = {1, 15}, Mob = "Bandit", QuestNPC = "Bandit Quest Giver", MobPos = Vector3.new(-1124, 15, 3855), NPCPos = Vector3.new(-1139, 15, 3824)},
    {Island = "Jungle", Level = {15, 30}, Mob = "Monkey", QuestNPC = "Jungle Quest Giver", MobPos = Vector3.new(-1613, 42, 152), NPCPos = Vector3.new(-1603, 36, 154)},
    {Island = "Pirate Village", Level = {30, 60}, Mob = "Pirate", QuestNPC = "Pirate Quest Giver", MobPos = Vector3.new(-1140, 5, 3830), NPCPos = Vector3.new(-1133, 5, 3856)},
    {Island = "Desert", Level = {60, 90}, Mob = "Desert Bandit", QuestNPC = "Desert Quest Giver", MobPos = Vector3.new(1095, 6, 4180), NPCPos = Vector3.new(1090, 6, 4210)},
    {Island = "Frozen Village", Level = {90, 120}, Mob = "Snow Bandit", QuestNPC = "Frozen Quest Giver", MobPos = Vector3.new(1386, 87, -1298), NPCPos = Vector3.new(1360, 87, -1310)},
    {Island = "Marine Fortress", Level = {120, 150}, Mob = "Marine", QuestNPC = "Marine Quest Giver", MobPos = Vector3.new(-4914, 50, 4281), NPCPos = Vector3.new(-4890, 50, 4300)},
    {Island = "Skylands", Level = {150, 190}, Mob = "Sky Bandit", QuestNPC = "Sky Quest Giver", MobPos = Vector3.new(-4869, 717, -2623), NPCPos = Vector3.new(-4850, 717, -2610)},
    {Island = "Prison", Level = {190, 275}, Mob = "Prisoner", QuestNPC = "Prison Quest Giver", MobPos = Vector3.new(5765, 5, 747), NPCPos = Vector3.new(5740, 5, 760)},
    {Island = "Colosseum", Level = {275, 350}, Mob = "Gladiator", QuestNPC = "Colosseum Quest Giver", MobPos = Vector3.new(-1428, 7, -3014), NPCPos = Vector3.new(-1450, 7, -3000)},
    {Island = "Magma Village", Level = {350, 450}, Mob = "Military Soldier", QuestNPC = "Magma Quest Giver", MobPos = Vector3.new(-5250, 12, 8515), NPCPos = Vector3.new(-5230, 12, 8530)},
    {Island = "Underwater City", Level = {450, 575}, Mob = "Fishman", QuestNPC = "Underwater Quest Giver", MobPos = Vector3.new(61163, 11, 1819), NPCPos = Vector3.new(61140, 11, 1830)},
    {Island = "Fountain City", Level = {575, 700}, Mob = "Galley Pirate", QuestNPC = "Fountain Quest Giver", MobPos = Vector3.new(5127, 38, 4046), NPCPos = Vector3.new(5110, 38, 4060)},
}

Data.Sea2 = {
    {Island = "Kingdom of Rose", Level = {700, 850}, Mob = "Swan Pirate", QuestNPC = "Rose Quest Giver", MobPos = Vector3.new(2179, 73, -6741), NPCPos = Vector3.new(2160, 73, -6720)},
    {Island = "Green Zone", Level = {850, 950}, Mob = "Plant", QuestNPC = "Green Quest Giver", MobPos = Vector3.new(-2450, 73, -3292), NPCPos = Vector3.new(-2430, 73, -3280)},
    {Island = "Graveyard", Level = {950, 1050}, Mob = "Zombie", QuestNPC = "Graveyard Quest Giver", MobPos = Vector3.new(-5765, 210, -782), NPCPos = Vector3.new(-5740, 210, -770)},
    {Island = "Snow Mountain", Level = {1050, 1150}, Mob = "Snowman", QuestNPC = "Snow Quest Giver", MobPos = Vector3.new(613, 400, -5765), NPCPos = Vector3.new(630, 400, -5750)},
    {Island = "Hot and Cold", Level = {1150, 1250}, Mob = "Hot/Cold Warrior", QuestNPC = "Hot Cold Quest Giver", MobPos = Vector3.new(-6006, 15, -4765), NPCPos = Vector3.new(-5990, 15, -4750)},
    {Island = "Cursed Ship", Level = {1250, 1350}, Mob = "Cursed Pirate", QuestNPC = "Cursed Quest Giver", MobPos = Vector3.new(923, 125, 32988), NPCPos = Vector3.new(940, 125, 33000)},
    {Island = "Ice Castle", Level = {1350, 1450}, Mob = "Ice Viking", QuestNPC = "Ice Quest Giver", MobPos = Vector3.new(5668, 27, -6484), NPCPos = Vector3.new(5650, 27, -6470)},
    {Island = "Forgotten Island", Level = {1450, 1525}, Mob = "Jungle Pirate", QuestNPC = "Forgotten Quest Giver", MobPos = Vector3.new(-3053, 237, -10547), NPCPos = Vector3.new(-3030, 237, -10530)},
}

Data.Sea3 = {
    {Island = "Port Town", Level = {1500, 1575}, Mob = "Pirate Millionaire", QuestNPC = "Port Quest Giver", MobPos = Vector3.new(-285, 44, 5318), NPCPos = Vector3.new(-270, 44, 5330)},
    {Island = "Hydra Island", Level = {1575, 1675}, Mob = "Hydra Warrior", QuestNPC = "Hydra Quest Giver", MobPos = Vector3.new(5228, 452, 344), NPCPos = Vector3.new(5225, 452, 340)},
    {Island = "Great Tree", Level = {1700, 1775}, Mob = "Tree Fighter", QuestNPC = "Tree Quest Giver", MobPos = Vector3.new(2275, 30, -6507), NPCPos = Vector3.new(2270, 30, -6505)},
    {Island = "Floating Turtle", Level = {1775, 1900}, Mob = "Marine Commodore", QuestNPC = "Turtle Quest Giver", MobPos = Vector3.new(-13274, 457, -7735), NPCPos = Vector3.new(-13270, 457, -7730)},
    {Island = "Haunted Castle", Level = {1975, 2075}, Mob = "Demonic Soul", QuestNPC = "Haunted Quest Giver", MobPos = Vector3.new(-9515, 171, 5765), NPCPos = Vector3.new(-9510, 171, 5760)},
    {Island = "Sea of Treats", Level = {2075, 2275}, Mob = "Cake Guard", QuestNPC = "Treats Quest Giver", MobPos = Vector3.new(-68, 41, 11514), NPCPos = Vector3.new(-65, 41, 11510)},
    {Island = "Tiki Outpost", Level = {2225, 2300}, Mob = "Tiki Warrior", QuestNPC = "Tiki Quest Giver", MobPos = Vector3.new(-1057, 65, -10580), NPCPos = Vector3.new(-1055, 65, -10575)},
    {Island = "Kitsune Shrine", Level = {2300, 2400}, Mob = "Kitsune Guardian", QuestNPC = "Kitsune Quest Giver", MobPos = Vector3.new(-5765, 215, -535), NPCPos = Vector3.new(-5760, 215, -530)},
}

-- Lấy data đảo phù hợp với level
function Data.GetIslandByLevel(level, sea)
    local seaData = Data["Sea" .. sea]
    if not seaData then return nil end
    
    for _, island in ipairs(seaData) do
        if level >= island.Level[1] and level <= island.Level[2] then
            return island
        end
    end
    
    -- Nếu level cao hơn max, trả về đảo cuối
    return seaData[#seaData]
end

-- Lấy đảo tiếp theo
function Data.GetNextIsland(currentIsland, sea)
    local seaData = Data["Sea" .. sea]
    if not seaData then return nil end
    
    for i, island in ipairs(seaData) do
        if island.Island == currentIsland then
            return seaData[i + 1]
        end
    end
    return nil
end

return Data
