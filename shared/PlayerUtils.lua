--[[
    PlayerUtils - Shared player utility functions
    Common helpers for character, humanoid, and teleportation.
]]

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local PlayerUtils = {}

function PlayerUtils.getCharacter(player)
    player = player or LocalPlayer
    return player.Character
end

function PlayerUtils.getHumanoid(player)
    local char = PlayerUtils.getCharacter(player)
    return char and char:FindFirstChildOfClass("Humanoid")
end

function PlayerUtils.getHRP(player)
    local char = PlayerUtils.getCharacter(player)
    return char and char:FindFirstChild("HumanoidRootPart")
end

function PlayerUtils.isAlive(player)
    local hum = PlayerUtils.getHumanoid(player)
    local hrp = PlayerUtils.getHRP(player)
    return hum and hrp and hum.Health > 0
end

function PlayerUtils.teleport(cframe, player)
    local hrp = PlayerUtils.getHRP(player)
    if hrp then
        hrp.CFrame = cframe
    end
end

function PlayerUtils.getPlayerByName(name)
    if type(name) ~= "string" then return nil end
    name = name:gsub("^%s+", ""):gsub("%s+$", "")
    if name == "" then return nil end
    for _, p in ipairs(Players:GetPlayers()) do
        if p.Name == name then return p end
    end
    return nil
end

function PlayerUtils.getPlayerNames()
    local names = {}
    for _, p in ipairs(Players:GetPlayers()) do
        table.insert(names, p.Name)
    end
    return names
end

function PlayerUtils.forceKill(player)
    local char = PlayerUtils.getCharacter(player)
    local hum = PlayerUtils.getHumanoid(player)
    if not char or not hum then return end
    pcall(function() hum:TakeDamage(hum.MaxHealth + 99999) end)
    pcall(function() hum.Health = 0 end)
    pcall(function() char:BreakJoints() end)
end

return PlayerUtils
