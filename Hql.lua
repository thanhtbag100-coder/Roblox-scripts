
-- HQL HUB | MULTI FLY | AUTO HIGH TO LOW
-- Mobile + PC | Drag | Scroll | Minimize | Close
-- Speed 300-2000 | Auto delay 0.2s

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local savedPositions = {}
local slotCount = 4
local FLY_SPEED = 300
local MIN_SPEED = 300
local MAX_SPEED = 2000
local SPEED_STEP = 25
local AUTO_DELAY = 0.2
local minimized = false
local flying = false
local autoRunning = false
local flyConnection
local runId = 0

-- GUI
local gui = Instance.new("ScreenGui")
gui.Name = "HQL_MultiFly"
gui.ResetOnSpawn = false
gui.DisplayOrder = 999
gui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Name = "Main"
frame.Size = UDim2.fromOffset(250, 355)
frame.Position = UDim2.new(0, 20, 0.2, 0)
frame.BackgroundColor3 = Color3.fromRGB(24, 24, 24)
frame.BorderSizePixel = 0
frame.Active = true
frame.ClipsDescendants = true
frame.Parent = gui
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 10)

local title = Instance.new("TextButton")
title.Name = "Title"
title.Size = UDim2.new(1, 0, 0, 36)
title.BackgroundColor3 = Color3.fromRGB(170, 25, 25)
title.Text = "HQL HUB | MULTI FLY"
title.TextColor3 = Color3.new(1, 1, 1)
title.TextSize = 14
title.Font = Enum.Font.GothamBold
title.TextXAlignment = Enum.TextXAlignment.Left
title.AutoButtonColor = false
title.Parent = frame

local titlePadding = Instance.new("UIPadding")
titlePadding.PaddingLeft = UDim.new(0, 9)
titlePadding.Parent = title

local close = Instance.new("TextButton")
close.Name = "Close"
close.Size = UDim2.fromOffset(28, 28)
close.Position = UDim2.new(1, -32, 0, 4)
close.BackgroundColor3 = Color3.fromRGB(230, 45, 45)
close.Text = "X"
close.TextColor3 = Color3.new(1, 1, 1)
close.TextSize = 17
close.Font = Enum.Font.GothamBold
close.ZIndex = 3
close.Parent = frame
Instance.new("UICorner", close).CornerRadius = UDim.new(0, 6)

local minimize = Instance.new("TextButton")
minimize.Name = "Minimize"
minimize.Size = UDim2.fromOffset(28, 28)
minimize.Position = UDim2.new(1, -64, 0, 4)
minimize.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
minimize.Text = "-"
minimize.TextColor3 = Color3.new(1, 1, 1)
minimize.TextSize = 22
minimize.Font = Enum.Font.GothamBold
minimize.ZIndex = 3
minimize.Parent = frame
Instance.new("UICorner", minimize).CornerRadius = UDim.new(0, 6)

local content = Instance.new("Frame")
content.Position = UDim2.fromOffset(0, 36)
content.Size = UDim2.new(1, 0, 1, -36)
content.BackgroundTransparency = 1
content.Parent = frame

local function makeLabel(text, y, height)
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -12, 0, height or 20)
    label.Position = UDim2.fromOffset(6, y)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.fromRGB(220, 220, 220)
    label.TextSize = 11
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = content
    return label
end

local status = makeLabel("Ready | 4 save slots", 2, 20)
local speedLabel = makeLabel("", 23, 20)
speedLabel.TextColor3 = Color3.new(1, 1, 1)
speedLabel.Font = Enum.Font.GothamBold
speedLabel.TextSize = 12

local function makeButton(name, text, size, position, color, parent)
    local button = Instance.new("TextButton")
    button.Name = name
    button.Text = text
    button.Size = size
    button.Position = position
    button.BackgroundColor3 = color
    button.TextColor3 = Color3.new(1, 1, 1)
    button.TextSize = 12
    button.Font = Enum.Font.GothamBold
    button.Parent = parent
    Instance.new("UICorner", button).CornerRadius = UDim.new(0, 5)
    return button
end

local minus = makeButton(
    "SpeedMinus", "-", UDim2.fromOffset(36, 25),
    UDim2.fromOffset(6, 45),
    Color3.fromRGB(75, 75, 75), content
)

local plus = makeButton(
    "SpeedPlus", "+", UDim2.fromOffset(36, 25),
    UDim2.new(1, -42, 0, 45),
    Color3.fromRGB(45, 110, 70), content
)

local speedBar = Instance.new("Frame")
speedBar.Size = UDim2.new(1, -96, 0, 8)
speedBar.Position = UDim2.new(0, 48, 0, 53)
speedBar.BackgroundColor3 = Color3.fromRGB(65, 65, 65)
speedBar.BorderSizePixel = 0
speedBar.Parent = content
Instance.new("UICorner", speedBar).CornerRadius = UDim.new(1, 0)

local speedFill = Instance.new("Frame")
speedFill.Size = UDim2.new(0, 0, 1, 0)
speedFill.BackgroundColor3 = Color3.fromRGB(50, 190, 100)
speedFill.BorderSizePixel = 0
speedFill.Parent = speedBar
Instance.new("UICorner", speedFill).CornerRadius = UDim.new(1, 0)

local function updateSpeed()
    FLY_SPEED = math.clamp(FLY_SPEED, MIN_SPEED, MAX_SPEED)
    speedLabel.Text = "FLY SPEED: " .. FLY_SPEED
    speedFill.Size = UDim2.new(
        (FLY_SPEED - MIN_SPEED) / (MAX_SPEED - MIN_SPEED),
        0, 1, 0
    )
end

minus.Activated:Connect(function()
    FLY_SPEED = math.max(MIN_SPEED, FLY_SPEED - SPEED_STEP)
    updateSpeed()
end)

plus.Activated:Connect(function()
    FLY_SPEED = math.min(MAX_SPEED, FLY_SPEED + SPEED_STEP)
    updateSpeed()
end)

updateSpeed()

local function getRoot()
    local character = player.Character
    return character and character:FindFirstChild("HumanoidRootPart")
end

-- Cancel all current movement and queued auto-flight steps.
local function stopFly(message)
    runId += 1
    flying = false
    autoRunning = false

    if flyConnection then
        flyConnection:Disconnect()
        flyConnection = nil
    end

    if message then
        status.Text = message
    end
end

-- Flight uses the current runId; only the auto runner schedules next steps.
local function flyTo(targetCFrame, slot, myRunId, onReached)
    local root = getRoot()

    if not root then
        status.Text = "Character not ready!"
        return false
    end

    if flyConnection then
        flyConnection:Disconnect()
        flyConnection = nil
    end

    flying = true
    status.Text = "Flying to point " .. slot

    flyConnection = RunService.Heartbeat:Connect(function(dt)
        if myRunId ~= runId or not flying then
            return
        end

        if not root.Parent then
            stopFly("Character not ready!")
            return
        end

        local offset = targetCFrame.Position - root.Position
        local distance = offset.Magnitude

        if distance <= 2 then
            root.CFrame = targetCFrame
            flying = false

            if flyConnection then
                flyConnection:Disconnect()
                flyConnection = nil
            end

            status.Text = "Reached point " .. slot

            if onReached then
                task.defer(function()
                    if myRunId == runId then
                        onReached()
                    end
                end)
            end
            return
        end

        local step = math.min(FLY_SPEED * dt, distance)
        local nextPosition = root.Position + offset.Unit * step
        local rotation = targetCFrame - targetCFrame.Position
        root.CFrame = CFrame.new(nextPosition) * rotation
    end)

    return true
end

-- Scrollable slots
local slotScroll = Instance.new("ScrollingFrame")
slotScroll.Name = "SlotScroll"
slotScroll.Position = UDim2.fromOffset(6, 76)
slotScroll.Size = UDim2.new(1, -12, 0, 130)
slotScroll.BackgroundTransparency = 1
slotScroll.BorderSizePixel = 0
slotScroll.ScrollBarThickness = 5
slotScroll.ScrollBarImageColor3 = Color3.fromRGB(180, 45, 45)
slotScroll.ScrollingDirection = Enum.ScrollingDirection.Y
slotScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
slotScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
slotScroll.Active = true
slotScroll.Parent = content

local slotLayout = Instance.new("UIListLayout")
slotLayout.Padding = UDim.new(0, 5)
slotLayout.SortOrder = Enum.SortOrder.LayoutOrder
slotLayout.Parent = slotScroll

local slotPadding = Instance.new("UIPadding")
slotPadding.PaddingBottom = UDim.new(0, 4)
slotPadding.Parent = slotScroll

local addSlot = makeButton(
    "AddSlot", "+ ADD SLOT",
    UDim2.new(1, -12, 0, 27),
    UDim2.fromOffset(6, 212),
    Color3.fromRGB(170, 25, 25), content
)

local autoFlyButton = makeButton(
    "AutoFly", "AUTO FLY HIGH -> LOW",
    UDim2.new(1, -12, 0, 27),
    UDim2.fromOffset(6, 243),
    Color3.fromRGB(55, 75, 145), content
)

local stopButton = makeButton(
    "StopFly", "STOP FLY",
    UDim2.new(1, -12, 0, 27),
    UDim2.fromOffset(6, 274),
    Color3.fromRGB(160, 55, 45), content
)

local function createSlot(i)
    local row = Instance.new("Frame")
    row.Name = "SlotRow" .. i
    row.Size = UDim2.new(1, -4, 0, 29)
    row.BackgroundTransparency = 1
    row.LayoutOrder = i
    row.Parent = slotScroll

    local save = makeButton(
        "Save" .. i, "SAVE " .. i,
        UDim2.new(0.48, -3, 1, 0),
        UDim2.new(0, 0, 0, 0),
        Color3.fromRGB(45, 100, 65), row
    )

    local fly = makeButton(
        "Fly" .. i, "FLY " .. i,
        UDim2.new(0.48, -3, 1, 0),
        UDim2.new(0.52, 3, 0, 0),
        Color3.fromRGB(55, 75, 145), row
    )

    save.Activated:Connect(function()
        local root = getRoot()

        if root then
            savedPositions[i] = root.CFrame
            save.Text = "SAVED " .. i
            status.Text = "Saved point " .. i
        else
            status.Text = "Character not ready!"
        end
    end)

    fly.Activated:Connect(function()
        if not savedPositions[i] then
            status.Text = "Save point " .. i .. " first!"
            return
        end

        stopFly()
        local myRunId = runId
        flyTo(savedPositions[i], i, myRunId)
    end)
end

for i = 1, slotCount do
    createSlot(i)
end

local function updateLayout()
    local listHeight = math.max(65, frame.AbsoluteSize.Y - 36 - 76 - 101)
    slotScroll.Size = UDim2.new(1, -12, 0, listHeight)
    addSlot.Position = UDim2.new(0, 6, 0, 76 + listHeight + 5)
    autoFlyButton.Position = UDim2.new(0, 6, 0, 76 + listHeight + 36)
    stopButton.Position = UDim2.new(0, 6, 0, 76 + listHeight + 67)
end

addSlot.Activated:Connect(function()
    slotCount += 1
    createSlot(slotCount)
    status.Text = "Added slot " .. slotCount
    updateLayout()
end)

-- Auto flight: highest saved slot to lowest, 0.2s between destinations.
local function runAutoFly()
    stopFly()

    local myRunId = runId
    local highest = 0

    for i = 1, slotCount do
        if savedPositions[i] then
            highest = i
        end
    end

    if highest == 0 then
        status.Text = "Save at least one point!"
        return
    end

    autoRunning = true
    local nextSlot = highest

    local function flyNext()
        if myRunId ~= runId or not autoRunning then
            return
        end

        while nextSlot >= 1 and not savedPositions[nextSlot] do
            nextSlot -= 1
        end

        if nextSlot < 1 then
            autoRunning = false
            flying = false
            status.Text = "AUTO FLY completed!"
            return
        end

        local slot = nextSlot
        nextSlot -= 1

        status.Text = "Auto: point " .. slot

        local started = flyTo(savedPositions[slot], slot, myRunId, function()
            task.delay(AUTO_DELAY, function()
                if myRunId == runId and autoRunning then
                    flyNext()
                end
            end)
        end)

        if not started then
            autoRunning = false
        end
    end

    flyNext()
end

autoFlyButton.Activated:Connect(runAutoFly)

stopButton.Activated:Connect(function()
    stopFly("Flight stopped")
end)

minimize.Activated:Connect(function()
    minimized = not minimized
    content.Visible = not minimized

    frame.Size = minimized
        and UDim2.fromOffset(250, 36)
        or UDim2.fromOffset(250, 355)

    minimize.Text = minimized and "+" or "-"

    if not minimized then
        task.defer(updateLayout)
    end
end)

close.Activated:Connect(function()
    stopFly()
    gui:Destroy()
end)

-- Drag title bar
local dragging = false
local dragStart
local startPos
local dragInput

title.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then

        dragging = true
        dragStart = input.Position
        startPos = frame.Position

        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

title.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UIS.InputChanged:Connect(function(input)
    if dragging and (
        input == dragInput
        or input.UserInputType == Enum.UserInputType.Touch
    ) then
        local delta = input.Position - dragStart

        frame.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end
end)

player.CharacterAdded:Connect(function()
    stopFly("Respawned | Slots retained")
end)

updateLayout()
