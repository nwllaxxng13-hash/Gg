--[[
    SilentAim - Shared silent aim utilities
    FOV-based target finding, visibility checks, and aim visuals.
]]

local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local SilentAim = {}

function SilentAim.isVisible(targetPart, filterInstances)
    local origin = Camera.CFrame.Position
    local direction = (targetPart.Position - origin)
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = filterInstances or {LocalPlayer.Character, Camera}
    local result = workspace:Raycast(origin, direction, params)
    return result == nil or result.Instance:IsDescendantOf(targetPart.Parent)
end

function SilentAim.getScreenCenter()
    return Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
end

function SilentAim.getTarget(options)
    options = options or {}
    local fovRadius = options.fovRadius or 150
    local lockPart = options.lockPart or "Head"
    local teamCheck = options.teamCheck ~= false
    local wallCheck = options.wallCheck or false
    local priority = options.priority or "FOV" -- "FOV" or "Distance"
    local closeRangeFix = options.closeRangeFix or false
    local closeRange = options.closeRange or 10

    local center = SilentAim.getScreenCenter()
    local bestScore = math.huge
    local bestTarget = nil

    for _, player in ipairs(Players:GetPlayers()) do
        if player == LocalPlayer or not player.Character then continue end
        if teamCheck and player.Team == LocalPlayer.Team then continue end

        local character = player.Character
        local hum = character:FindFirstChildOfClass("Humanoid")
        local targetPart = character:FindFirstChild(lockPart) or character:FindFirstChild("Head")
        local root = character:FindFirstChild("HumanoidRootPart")

        if not hum or hum.Health <= 0 or not targetPart or not root then continue end

        local screenPos, onScreen = Camera:WorldToScreenPoint(targetPart.Position)
        if not onScreen then continue end

        local fovDist = (Vector2.new(screenPos.X, screenPos.Y) - center).Magnitude
        if fovDist > fovRadius then continue end

        local score
        if priority == "Distance" then
            local myHRP = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            score = myHRP and (root.Position - myHRP.Position).Magnitude or fovDist
        else
            score = fovDist
        end

        -- Close range fix: skip wall check for nearby targets
        local myHRP = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        local dist3D = myHRP and (root.Position - myHRP.Position).Magnitude or math.huge
        local isClose = closeRangeFix and dist3D < closeRange

        if isClose then
            if score < bestScore then
                bestTarget = targetPart
                bestScore = score
            end
        elseif not wallCheck or SilentAim.isVisible(targetPart) then
            if score < bestScore then
                bestTarget = targetPart
                bestScore = score
            end
        end
    end

    return bestTarget
end

-- Visual feedback: highlight locked target
SilentAim._highlight = nil
SilentAim._tag = nil

function SilentAim.addVisuals(targetPart)
    if not targetPart or not targetPart.Parent then return end
    local char = targetPart.Parent

    if not SilentAim._highlight then
        SilentAim._highlight = Instance.new("Highlight")
        SilentAim._highlight.FillColor = Color3.fromRGB(255, 0, 0)
        SilentAim._highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
        SilentAim._highlight.FillTransparency = 0.5
        SilentAim._highlight.Parent = CoreGui
    end
    if SilentAim._highlight.Adornee ~= char then
        SilentAim._highlight.Adornee = char
    end

    if not SilentAim._tag then
        local bb = Instance.new("BillboardGui")
        bb.Size = UDim2.new(0, 200, 0, 50)
        bb.StudsOffset = Vector3.new(0, 2.5, 0)
        bb.AlwaysOnTop = true

        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, 0, 1, 0)
        label.BackgroundTransparency = 1
        label.Text = ">>> LOCKED <<<"
        label.TextColor3 = Color3.fromRGB(255, 0, 0)
        label.Font = Enum.Font.GothamBlack
        label.TextSize = 14
        label.TextStrokeTransparency = 0
        label.Parent = bb

        SilentAim._tag = bb
        SilentAim._tag.Parent = CoreGui
    end
    if SilentAim._tag.Adornee ~= targetPart then
        SilentAim._tag.Adornee = targetPart
    end
end

function SilentAim.clearVisuals()
    if SilentAim._highlight then
        SilentAim._highlight:Destroy()
        SilentAim._highlight = nil
    end
    if SilentAim._tag then
        SilentAim._tag:Destroy()
        SilentAim._tag = nil
    end
end

return SilentAim
