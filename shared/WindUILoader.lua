--[[
    WindUILoader - Shared WindUI initialization
    Handles loading WindUI from multiple sources with fallback.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local WINDUI_URL = "https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"

local WindUILoader = {}

function WindUILoader.load()
    local WindUI

    -- Try local require first
    local ok, result = pcall(function()
        return require("./src/Init")
    end)

    if ok and result then
        WindUI = result
    else
        -- Fallback: Studio or no writefile -> ReplicatedStorage
        if RunService:IsStudio() or not writefile then
            local windModule = ReplicatedStorage:FindFirstChild("WindUI")
            if windModule then
                WindUI = require(windModule:WaitForChild("Init"))
            end
        end

        -- Fallback: HTTP load
        if not WindUI then
            local httpOk, httpResult = pcall(function()
                return loadstring(game:HttpGet(WINDUI_URL))()
            end)
            if httpOk and httpResult then
                WindUI = httpResult
            end
        end
    end

    if not WindUI then
        warn("[WindUILoader] Failed to load WindUI from all sources")
    end

    return WindUI
end

return WindUILoader
