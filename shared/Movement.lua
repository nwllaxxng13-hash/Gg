--[[
    Movement - Shared movement utility functions
    Speed hack, flight, infinite jump, noclip, and draggable UI frames.
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

local Movement = {}
Movement._connections = {}

-- Speed Hack (BodyVelocity-based)
function Movement.startSpeedHack(speed)
    speed = speed or 100
    Movement.stopSpeedHack()

    local camera = workspace.CurrentCamera
    Movement._connections.speedHack = RunService.RenderStepped:Connect(function()
        local character = LocalPlayer.Character
        if not character then return end
        local hrp = character:FindFirstChild("HumanoidRootPart")
        if not hrp then return end

        local bv = hrp:FindFirstChild("SharedSpeedVelocity")
        if not bv then
            bv = Instance.new("BodyVelocity")
            bv.Name = "SharedSpeedVelocity"
            bv.MaxForce = Vector3.new(1e5, 0, 1e5)
            bv.Velocity = Vector3.zero
            bv.Parent = hrp
        end

        local moveDir = Vector3.zero
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then
            moveDir = moveDir + camera.CFrame.LookVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then
            moveDir = moveDir - camera.CFrame.LookVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then
            moveDir = moveDir - camera.CFrame.RightVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then
            moveDir = moveDir + camera.CFrame.RightVector
        end

        if moveDir.Magnitude > 0 then
            moveDir = moveDir.Unit * speed
        end
        bv.Velocity = Vector3.new(moveDir.X, 0, moveDir.Z)
    end)
end

function Movement.stopSpeedHack()
    if Movement._connections.speedHack then
        Movement._connections.speedHack:Disconnect()
        Movement._connections.speedHack = nil
    end
    local character = LocalPlayer.Character
    if character then
        local hrp = character:FindFirstChild("HumanoidRootPart")
        if hrp then
            local bv = hrp:FindFirstChild("SharedSpeedVelocity")
            if bv then bv:Destroy() end
        end
    end
end

-- Flight
function Movement.startFlight(speed)
    speed = speed or 150
    Movement.stopFlight()

    local camera = workspace.CurrentCamera
    Movement._connections.flight = RunService.RenderStepped:Connect(function()
        local character = LocalPlayer.Character
        if not character then return end
        local hrp = character:FindFirstChild("HumanoidRootPart")
        if not hrp then return end

        local moveDir = Vector3.zero
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then
            moveDir = moveDir + camera.CFrame.LookVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then
            moveDir = moveDir - camera.CFrame.LookVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then
            moveDir = moveDir - camera.CFrame.RightVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then
            moveDir = moveDir + camera.CFrame.RightVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
            moveDir = moveDir + camera.CFrame.UpVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
            moveDir = moveDir - camera.CFrame.UpVector
        end

        if moveDir.Magnitude > 0 then
            moveDir = moveDir.Unit * speed
        end
        hrp.Velocity = moveDir
    end)
end

function Movement.stopFlight()
    if Movement._connections.flight then
        Movement._connections.flight:Disconnect()
        Movement._connections.flight = nil
    end
    local character = LocalPlayer.Character
    if character then
        local hrp = character:FindFirstChild("HumanoidRootPart")
        if hrp then hrp.Velocity = Vector3.zero end
    end
end

-- Infinite Jump
function Movement.startInfiniteJump()
    Movement.stopInfiniteJump()
    Movement._connections.infiniteJump = UserInputService.JumpRequest:Connect(function()
        local character = LocalPlayer.Character
        if character then
            local hum = character:FindFirstChildOfClass("Humanoid")
            if hum then
                hum:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end
    end)
end

function Movement.stopInfiniteJump()
    if Movement._connections.infiniteJump then
        Movement._connections.infiniteJump:Disconnect()
        Movement._connections.infiniteJump = nil
    end
end

-- NoClip
function Movement.startNoClip()
    Movement.stopNoClip()
    Movement._connections.noClip = RunService.Stepped:Connect(function()
        local character = LocalPlayer.Character
        if not character then return end
        for _, part in pairs(character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end)
end

function Movement.stopNoClip()
    if Movement._connections.noClip then
        Movement._connections.noClip:Disconnect()
        Movement._connections.noClip = nil
    end
end

-- Draggable Frame utility
function Movement.makeDraggable(frame)
    local dragging = false
    local dragInput, mousePos, framePos

    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            mousePos = input.Position
            framePos = frame.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    frame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - mousePos
            frame.Position = UDim2.new(
                framePos.X.Scale, framePos.X.Offset + delta.X,
                framePos.Y.Scale, framePos.Y.Offset + delta.Y
            )
        end
    end)
end

-- CFrame-based speed boost (alternative to BodyVelocity)
function Movement.startCFrameSpeed(speed)
    speed = speed or 16
    Movement.stopCFrameSpeed()

    Movement._connections.cframeSpeed = RunService.RenderStepped:Connect(function()
        local character = LocalPlayer.Character
        if not character then return end
        local hum = character:FindFirstChildOfClass("Humanoid")
        local hrp = character:FindFirstChild("HumanoidRootPart")
        if not hum or not hrp then return end

        local moveDir = hum.MoveDirection
        if moveDir.Magnitude > 0 then
            hrp.CFrame = hrp.CFrame + moveDir * math.max(speed, 1) * 0.080
        end
    end)
end

function Movement.stopCFrameSpeed()
    if Movement._connections.cframeSpeed then
        Movement._connections.cframeSpeed:Disconnect()
        Movement._connections.cframeSpeed = nil
    end
end

return Movement
