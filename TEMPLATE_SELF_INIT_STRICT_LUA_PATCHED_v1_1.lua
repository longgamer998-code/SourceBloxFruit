--[[====================================================
  TEMPLATE_SELF_INIT_STRICT_LUA  (HARDENED)
  Strict Local Script – Lua Only
  - Self init (single-run)
  - Enforce .lua execution only
  - Hard block: .txt, .md
  - Hard block: README / GUIDE / INSTRUCTION / NOTE / CHANGELOG
  - No external dependency
======================================================]]

-- ===============================
-- HARD GUARD: FILE EXTENSION & NAME
-- ===============================
local function __assert_lua_only()
    local info = debug.getinfo(1, "S")
    local src  = info and info.source or ""
    local filename = src:match("^@(.+)$") or ""

    if filename == "" then
        error("[STRICT INIT] Cannot determine script source.", 0)
    end

    filename = filename:lower()

    -- only .lua allowed
    if not filename:match("%.lua$") then
        error("[STRICT INIT] Forbidden file type. ONLY .lua is allowed.", 0)
    end

    -- hard block text / markdown
    if filename:match("%.txt$") or filename:match("%.md$") then
        error("[STRICT INIT] .txt / .md files are BLOCKED.", 0)
    end

    -- hard block documentation / instruction names
    if filename:match("readme")
        or filename:match("guide")
        or filename:match("instruction")
        or filename:match("note")
        or filename:match("change")
        or filename:match("huongdan")
        or filename:match("sua")
        or filename:match("thaydoi")
    then
        error("[STRICT INIT] Documentation / instruction files are BLOCKED.", 0)
    end
end

__assert_lua_only()

-- ===============================
-- STRICT LOCAL ENVIRONMENT
-- ===============================
local _ENV = (function()
    local env = {}

    env.assert   = assert
    env.error    = error
    env.ipairs   = ipairs
    env.pairs    = pairs
    env.next     = next
    env.print    = print
    env.select   = select
    env.tonumber = tonumber
    env.tostring = tostring
    env.type     = type

    env.math   = math
    env.string = string
    env.table  = table
    env.os     = os
    env.debug  = debug

    return env
end)()

-- ===============================
-- SELF INIT STATE
-- ===============================
local INIT = {
    ok        = false,
    started  = false,
    version  = "1.1.0",
    bootTime = os.time()
}

local function __self_init()
    if INIT.started then
        error("[STRICT INIT] Double initialization detected.", 0)
    end

    INIT.started = true

    assert(type(INIT.version) == "string", "Invalid version")
    assert(type(INIT.bootTime) == "number", "Invalid boot time")

    INIT.ok = true
end

__self_init()

-- ===============================
-- PUBLIC ENTRY (LOCAL ONLY)
-- ===============================
local function main(...)
    assert(INIT.ok == true, "[STRICT INIT] Init failed")

    -- ===== USER CODE START =====
    print("[STRICT LUA] Script running safely.")
    -- ===== USER CODE END =====
end

-- ===============================
-- EXECUTE
-- ===============================
return main(...)
