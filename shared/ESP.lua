--[[
    ESP - Shared ESP (Extra Sensory Perception) utilities
    Creates/removes Highlights and BillboardGui nametags for players.
]]

local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer

local ESP = {}
ESP._states = {} -- [player] = { highlight, billboard, labels... }

function ESP.createHighlight(character, options)
    if not character or not character:IsDescendantOf(game) then return nil end
    options = options or {}

    local hl = Instance.new("Highlight")
    hl.Name = options.name or "ESP_Highlight"
    hl.Adornee = character
    hl.FillColor = options.fillColor or Color3.fromRGB(255, 0, 0)
    hl.FillTransparency = options.fillTransparency or 0.5
    hl.OutlineColor = options.outlineColor or Color3.fromRGB(255, 255, 255)
    hl.OutlineTransparency = options.outlineTransparency or 0
    hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    hl.Parent = options.parent or CoreGui
    return hl
end

function ESP.createBillboard(adornee, options)
    if not adornee then return nil end
    options = options or {}

    local bb = Instance.new("BillboardGui")
    bb.Name = options.name or "ESP_Billboard"
    bb.Adornee = adornee
    bb.Size = options.size or UDim2.new(0, 150, 0, 60)
    bb.StudsOffset = options.offset or Vector3.new(0, 3, 0)
    bb.AlwaysOnTop = true
    bb.Parent = options.parent or CoreGui
    return bb
end

function ESP.addLabel(billboard, options)
    if not billboard then return nil end
    options = options or {}

    local label = Instance.new("TextLabel")
    label.Size = options.size or UDim2.new(1, 0, 0, 20)
    label.Position = options.position or UDim2.new(0, 0, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = options.text or ""
    label.Font = options.font or Enum.Font.GothamBold
    label.TextColor3 = options.color or Color3.fromRGB(255, 255, 255)
    label.TextStrokeTransparency = options.strokeTransparency or 0
    label.TextStrokeColor3 = options.strokeColor or Color3.fromRGB(20, 20, 20)
    label.TextSize = options.textSize or 14
    label.TextScaled = options.scaled or false
    label.Parent = billboard
    return label
end

function ESP.applyToPlayer(player, options)
    if player == LocalPlayer then return end
    options = options or {}

    local character = player.Character
    if not character then return end

    local head = character:FindFirstChild("Head")
    local hrp = character:FindFirstChild("HumanoidRootPart")
    local hum = character:FindFirstChildOfClass("Humanoid")
    if not head or not hrp or not hum then return end
    if hum.Health <= 0 then return end

    -- Team check
    if options.teamCheck and player.Team == LocalPlayer.Team then return end

    local state = ESP._states[player]
    if not state then
        state = {}
        ESP._states[player] = state
    end

    -- Highlight
    if not state.highlight then
        state.highlight = ESP.createHighlight(character, {
            fillColor = options.highlightColor or (player.Team and player.Team.TeamColor.Color) or Color3.new(1, 0, 0),
            fillTransparency = options.fillTransparency or 0.5,
            outlineColor = options.outlineColor,
            outlineTransparency = options.outlineTransparency,
        })
    end

    -- Billboard with name/HP/team
    if options.showName and not state.billboard then
        state.billboard = ESP.createBillboard(head, {
            offset = Vector3.new(0, 3, 0),
        })
        state.nameLabel = ESP.addLabel(state.billboard, {
            text = player.Name,
            position = UDim2.new(0, 0, 0, 0),
        })
        if options.showHP then
            state.hpLabel = ESP.addLabel(state.billboard, {
                text = "HP: " .. math.floor(hum.Health),
                position = UDim2.new(0, 0, 0, 20),
                color = Color3.fromRGB(255, 100, 100),
            })
        end
        if options.showTeam then
            state.teamLabel = ESP.addLabel(state.billboard, {
                text = "Team: " .. (player.Team and player.Team.Name or "None"),
                position = UDim2.new(0, 0, 0, 40),
                color = Color3.fromRGB(150, 200, 255),
            })
        end
    end
end

function ESP.updatePlayer(player)
    local state = ESP._states[player]
    if not state then return end

    local character = player.Character
    if not character then
        ESP.removeFromPlayer(player)
        return
    end

    local hum = character:FindFirstChildOfClass("Humanoid")
    if not hum or hum.Health <= 0 then
        ESP.removeFromPlayer(player)
        return
    end

    if state.nameLabel then state.nameLabel.Text = player.Name end
    if state.hpLabel then state.hpLabel.Text = "HP: " .. math.floor(hum.Health) end
    if state.teamLabel then state.teamLabel.Text = "Team: " .. (player.Team and player.Team.Name or "None") end
end

function ESP.removeFromPlayer(player)
    local state = ESP._states[player]
    if not state then return end

    if state.highlight then
        state.highlight:Destroy()
    end
    if state.billboard then
        state.billboard:Destroy()
    end
    ESP._states[player] = nil
end

function ESP.removeAll()
    for player, _ in pairs(ESP._states) do
        ESP.removeFromPlayer(player)
    end
end

function ESP.getState(player)
    return ESP._states[player]
end

return ESP
