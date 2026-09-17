--[[
    Lighting - Shared lighting/visual utility functions
    Handles full brightness, no fog, night mode, and visual resets.
]]

local LightingService = game:GetService("Lighting")

local Lighting = {}
Lighting._defaults = nil

function Lighting.saveDefaults()
    if Lighting._defaults then return end
    Lighting._defaults = {
        Brightness = LightingService.Brightness,
        Ambient = LightingService.Ambient,
        OutdoorAmbient = LightingService.OutdoorAmbient,
        GlobalShadows = LightingService.GlobalShadows,
        FogEnd = LightingService.FogEnd,
        FogStart = LightingService.FogStart,
        ClockTime = LightingService.ClockTime,
    }
end

function Lighting.restoreDefaults()
    if not Lighting._defaults then return end
    local d = Lighting._defaults
    LightingService.Brightness = d.Brightness
    LightingService.Ambient = d.Ambient
    LightingService.OutdoorAmbient = d.OutdoorAmbient
    LightingService.GlobalShadows = d.GlobalShadows
    LightingService.FogEnd = d.FogEnd
    LightingService.FogStart = d.FogStart
    LightingService.ClockTime = d.ClockTime
end

function Lighting.applyFullBright()
    Lighting.saveDefaults()
    LightingService.Brightness = 2
    LightingService.OutdoorAmbient = Color3.fromRGB(128, 128, 128)
    LightingService.Ambient = Color3.fromRGB(128, 128, 128)
    LightingService.GlobalShadows = false
    LightingService.ClockTime = 14
end

function Lighting.removeFullBright()
    Lighting.restoreDefaults()
end

function Lighting.applySuperBright()
    Lighting.saveDefaults()
    LightingService.Brightness = 15
    LightingService.OutdoorAmbient = Color3.fromRGB(255, 255, 255)
    LightingService.Ambient = Color3.fromRGB(255, 255, 255)
    LightingService.GlobalShadows = false
end

function Lighting.applyNoFog()
    Lighting.saveDefaults()
    LightingService.FogEnd = 1000000
    LightingService.FogStart = 999999
end

function Lighting.removeNoFog()
    if Lighting._defaults then
        LightingService.FogEnd = Lighting._defaults.FogEnd
        LightingService.FogStart = Lighting._defaults.FogStart
    end
end

function Lighting.applyNightMode()
    Lighting.saveDefaults()
    LightingService.Ambient = Color3.fromRGB(20, 20, 20)
    LightingService.Brightness = 0.5
    LightingService.ClockTime = 0
end

function Lighting.removeNightMode()
    Lighting.restoreDefaults()
end

function Lighting.setFogEnd(value)
    LightingService.FogEnd = value
end

function Lighting.getService()
    return LightingService
end

return Lighting
