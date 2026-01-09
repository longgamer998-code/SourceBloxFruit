-- ╔══════════════════════════════════════════════════════════╗
-- ║  MAIN.LUA - Blox Fruits Auto Farm V2.3                   ║
-- ║  Repo: longgamer998-code/SourceBloxFruit                 ║
-- ╚══════════════════════════════════════════════════════════╝

print("╔══════════════════════════════════════════════════════════╗")
print("║  🏴‍☠️ BLOX FRUITS AUTO FARM V2.3                          ║")
print("║  Loading modules...                                         ║")
print("╚══════════════════════════════════════════════════════════╝")

local REPO_BASE = "https://raw.githubusercontent.com/longgamer998-code/SourceBloxFruit/main/"

local function safeLoad(filename)
    print("\n📥 Loading " .. filename ..  "...")
    
    local url = REPO_BASE .. filename
    local content
    
    local success, result = pcall(function()
        content = game:HttpGet(url)
    end)
    
    if not success then
        warn("❌ HTTP Request failed")
        warn("Error: " .. tostring(result))
        warn("URL: " .. url)
        return nil
    end
    
    if not content or #content == 0 then
        warn("❌ File is empty or not found")
        warn("URL: " .. url)
        warn("Make sure:")
        warn("  1. File exists on GitHub")
        warn("  2. File name matches exactly (case-sensitive)")
        warn("  3. Branch is 'main' not 'master'")
        return nil
    end
    
    print("✅ Downloaded " .. #content .. " bytes")
    
    local loadSuccess, module = pcall(function()
        return loadstring(content)()
    end)
    
    if not loadSuccess then
        warn("❌ Failed to execute")
        warn("Error: " ..  tostring(module))
        return nil
    end
    
    if not module then
        warn("❌ Module returned nil")
        warn("Make sure file ends with 'return Config/Core/GUI'")
        return nil
    end
    
    print("✅ " .. filename .. " loaded!")
    return module
end

print("\n" .. string.rep("=", 60))
print("📦 Repository: " .. REPO_BASE)
print(string.rep("=", 60))

local Config = safeLoad("CONFIG.LUA")
if not Config then
    warn("\n❌ CONFIG.LUA failed to load - aborting")
    return
end

local Core = safeLoad("CORE.LUA")
if not Core then
    warn("\n❌ CORE.LUA failed to load - aborting")
    return
end

local GUI = safeLoad("GUI.LUA")
if not GUI then
    warn("\n❌ GUI.LUA failed to load - aborting")
    return
end

print("\n" .. string.rep("=", 60))
print("✅ All modules loaded successfully!")
print(string.rep("=", 60))

print("\n🔧 Initializing console...")
local success, result = pcall(function()
    Core.initConsole(Config)
end)

if not success then
    warn("❌ Console init failed:  " .. tostring(result))
    return
end

print("✅ Console ready")

local player = game: GetService("Players").LocalPlayer

print("\n" .. string.rep("=", 60))
print("👤 Player: " .. player.Name)
print("⭐ Level: " .. tostring(Core.getPlayerLevel()))

local belliSuccess, belli = pcall(function() return player.Data.Beli. Value end)
if belliSuccess then
    print("💰 Beli: " .. tostring(belli))
end

print(string.rep("=", 60))

print("\n🎨 Creating GUI...")
success, result = pcall(function()
    GUI.create(Config, Core)
end)

if not success then
    warn("❌ GUI creation failed: " .. tostring(result))
    return
end

print("\n🔫 Detecting weapons...")
task.spawn(function()
    task.wait(2)
    local weapons = Core.getPlayerWeapons()
    if weapons and #weapons > 0 then
        print("Weapons found:")
        for i, weapon in ipairs(weapons) do
            print("  " .. tostring(i) .. ". " .. weapon)
        end
    end
end)

print("\n" .. string.rep("=", 60))
print("✅ SCRIPT LOADED SUCCESSFULLY!")
print(string.rep("=", 60))
print("📖 How to use:")
print("  1. Enable 'Debug Mode' for detailed logs")
print("  2. Toggle 'Auto Farm' to start")
print("  3. Check Console tab for stats")
print(string.rep("=", 60))
print("\n🌐 " ..  REPO_BASE)
print("📅 " .. os.date("%Y-%m-%d %H:%M:%S"))
print("✨ Ready!")
