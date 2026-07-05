--[[
    AntiAFK - Shared anti-AFK utility
    Prevents idle kick using VirtualUser service.
]]

local Players = game:GetService("Players")
local VirtualUser = game:GetService("VirtualUser")
local LocalPlayer = Players.LocalPlayer

local AntiAFK = {}
AntiAFK._running = false
AntiAFK._connection = nil

function AntiAFK.start(interval)
    interval = interval or 60
    if AntiAFK._running then return end
    AntiAFK._running = true

    task.spawn(function()
        while AntiAFK._running do
            pcall(function()
                VirtualUser:CaptureController()
                VirtualUser:ClickButton2(Vector2.new(0, 0))
            end)
            task.wait(interval)
        end
    end)
end

function AntiAFK.stop()
    AntiAFK._running = false
end

function AntiAFK.isRunning()
    return AntiAFK._running
end

-- Alternative: connect to Idled event (fires once after ~20min)
function AntiAFK.connectIdled()
    if AntiAFK._connection then return end
    AntiAFK._connection = LocalPlayer.Idled:Connect(function()
        pcall(function()
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.new())
        end)
    end)
end

function AntiAFK.disconnectIdled()
    if AntiAFK._connection then
        AntiAFK._connection:Disconnect()
        AntiAFK._connection = nil
    end
end

return AntiAFK
