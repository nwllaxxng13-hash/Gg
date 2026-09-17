--[[
    Shared Utilities - Index Module
    Load all shared utilities from a single require.

    Usage:
        local Shared = loadstring(game:HttpGet("YOUR_RAW_URL/shared/init.lua"))()
        -- or --
        local Shared = require(path.to.shared)

    Available modules:
        Shared.PlayerUtils   - Character, humanoid, HRP, teleport helpers
        Shared.WindUILoader  - WindUI initialization with fallback
        Shared.AntiAFK       - Anti-AFK (VirtualUser-based)
        Shared.ESP           - ESP highlights and billboards
        Shared.Lighting      - Full brightness, no fog, night mode
        Shared.SilentAim     - FOV target finding, visibility, aim visuals
        Shared.Movement      - Speed hack, flight, infinite jump, noclip, draggable frames
]]

local Shared = {}

-- Lazy-load modules to avoid circular dependencies
local modules = {
    "PlayerUtils",
    "WindUILoader",
    "AntiAFK",
    "ESP",
    "Lighting",
    "SilentAim",
    "Movement",
}

for _, name in ipairs(modules) do
    local ok, mod = pcall(function()
        return require(script:WaitForChild(name))
    end)
    if ok then
        Shared[name] = mod
    else
        warn("[Shared] Failed to load module: " .. name .. " - " .. tostring(mod))
    end
end

return Shared
