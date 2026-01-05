--[[====================================================
  TEMPLATE_SELF_INIT_STRICT_LUA
  Strict Local Script – Lua Only
  - Self init
  - Enforce .lua execution only
  - Reject .txt / .md / others
  - No external dependency
======================================================]]

-- ===============================
-- HARD GUARD: FILE EXTENSION
-- ===============================
local function __assert_lua_only()
    -- debug.getinfo(1, "S") is standard Lua
    local info = debug.getinfo(1, "S")
    local src  = info and info.source or ""

    -- source format: "@path/to/file.lua"
    local filename = src:match("^@(.+)$") or ""

    if filename == "" then
        error("[STRICT INIT] Cannot determine script source (not file-based).", 0)
    end

    -- lower-case for safety
    filename = filename:lower()

    -- reject non-lua
    if not filename:match("%.lua$") then
        error("[STRICT INIT] Forbidden file type. ONLY .lua is allowed.", 0)
    end

    -- explicit block
    if filename:match("%.txt$") or filename:match("%.md$") then
        error("[STRICT INIT] .txt / .md files are BLOCKED.", 0)
    end
end

__assert_lua_only()

-- ===============================
-- STRICT LOCAL ENVIRONMENT
-- ===============================
local _ENV = (function()
    local env = {}

    -- allow basic safe globals explicitly
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
    version  = "1.0.0",
    bootTime = os.time()
}

local function __self_init()
    if INIT.started then
        error("[STRICT INIT] Double initialization detected.", 0)
    end

    INIT.started = true

    -- sanity checks
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
    -- viết logic của bạn từ đây
    print("[STRICT LUA] Script running safely.")
    -- ===== USER CODE END =====
end

-- ===============================
-- EXECUTE
-- ===============================
return main(...)
