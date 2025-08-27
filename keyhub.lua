-- Script Premium
getgenv().Key = getgenv().Key or ""
repeat wait() until game:IsLoaded() and game.Players.LocalPlayer

local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Player = Players.LocalPlayer
local API_URL = "https://192.168.1.20:5000"  -- Update to your deployed API URL

-- Improved key verification with retry logic
local function verifyKey()
    local MAX_RETRIES = 3
    local RETRY_DELAY = 2
    local success, response

    for attempt = 1, MAX_RETRIES do
        success, response = pcall(function()
            return HttpService:GetAsync(API_URL .. "/verify?key=" .. HttpService:UrlEncode(getgenv().Key))
        end)
        if success then
            local decoded, result = pcall(function()
                return HttpService:JSONDecode(response)
            end)
            if decoded and result and type(result) == "table" and result.exists ~= nil and result.redeemed ~= nil and result.valid ~= nil then
                return true, result
            else
                warn("Invalid API response format on attempt " .. attempt)
            end
        else
            warn("API connection attempt " .. attempt .. " failed: " .. tostring(response))
        end
        wait(RETRY_DELAY * attempt) -- Exponential backoff
    end
    return false, {error = "Unable to reach API after " .. MAX_RETRIES .. " attempts"}
end

local success, result = verifyKey()
if not success or not result.valid or not result.redeemed then
    local errorMsg = result.error or "Khóa không hợp lệ hoặc chưa được kích hoạt. Vui lòng sử dụng lệnh /redeem trên Discord."
    Player:Kick("Lỗi: " .. errorMsg)
    return
end

-- Premium UI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Parent = Player.PlayerGui
ScreenGui.Name = "PremiumUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0.4, 0, 0.5, 0)
MainFrame.Position = UDim2.new(0.3, 0, 0.25, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui
MainFrame.ClipsDescendants = true

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 15)
UICorner.Parent = MainFrame

local UIGradient = Instance.new("UIGradient")
UIGradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 170, 255)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 255, 170))
}
UIGradient.Rotation = 45
UIGradient.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0.1, 0)
Title.BackgroundTransparency = 1
Title.Text = "Script Premium"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextScaled = true
Title.Font = Enum.Font.GothamBlack
Title.TextStrokeTransparency = 0.8
Title.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
Title.Parent = MainFrame

-- Feature buttons container
local ButtonContainer = Instance.new("Frame")
ButtonContainer.Size = UDim2.new(0.9, 0, 0.75, 0)
ButtonContainer.Position = UDim2.new(0.05, 0, 0.15, 0)
ButtonContainer.BackgroundTransparency = 1
ButtonContainer.Parent = MainFrame

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Padding = UDim.new(0, 10)
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Parent = ButtonContainer

-- Feature states
local features = {
    AutoFarm = false,
    SpeedHack = false,
    Aimbot = false
}

local function createToggleButton(text, callback)
    local ButtonFrame = Instance.new("Frame")
    ButtonFrame.Size = UDim2.new(1, 0, 0, 40)
    ButtonFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    ButtonFrame.BorderSizePixel = 0
    ButtonFrame.Parent = ButtonContainer

    local ButtonCorner = Instance.new("UICorner")
    ButtonCorner.CornerRadius = UDim.new(0, 8)
    ButtonCorner.Parent = ButtonFrame

    local ButtonText = Instance.new("TextLabel")
    ButtonText.Size = UDim2.new(0.7, 0, 1, 0)
    ButtonText.BackgroundTransparency = 1
    ButtonText.Text = text
    ButtonText.TextColor3 = Color3.fromRGB(255, 255, 255)
    ButtonText.TextScaled = true
    ButtonText.Font = Enum.Font.Gotham
    ButtonText.TextXAlignment = Enum.TextXAlignment.Left
    ButtonText.Position = UDim2.new(0.05, 0, 0, 0)
    ButtonText.Parent = ButtonFrame

    local Toggle = Instance.new("TextButton")
    Toggle.Size = UDim2.new(0.15, 0, 0.6, 0)
    Toggle.Position = UDim2.new(0.8, 0, 0.2, 0)
    Toggle.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
    Toggle.Text = "OFF"
    Toggle.TextColor3 = Color3.fromRGB(255, 255, 255)
    Toggle.TextScaled = true
    Toggle.Font = Enum.Font.GothamBold
    Toggle.Parent = ButtonFrame

    local ToggleCorner = Instance.new("UICorner")
    ToggleCorner.CornerRadius = UDim.new(0, 5)
    ToggleCorner.Parent = Toggle

    local function updateToggle()
        Toggle.Text = features[text] and "ON" or "OFF"
        Toggle.BackgroundColor3 = features[text] and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(100, 100, 100)
    end

    Toggle.MouseButton1Click:Connect(function()
        features[text] = not features[text]
        updateToggle()
        callback(features[text])
    end)

    updateToggle()
    return ButtonFrame
end

-- Create feature toggles
createToggleButton("Auto Farm Level", function(state)
    print("Auto Farm Level: " .. (state and "ON" or "OFF"))
    if state then
        -- Add your auto farm logic here (e.g., teleport to farm spots, automate tasks)
        spawn(function()
            while features.AutoFarm and Player.Character do
                -- Example: Teleport to a farm location (replace with game-specific logic)
                local farmPos = CFrame.new(0, 10, 0) -- Replace with actual farm position
                if Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
                    Player.Character.HumanoidRootPart.CFrame = farmPos
                end
                wait(1)
            end
        end)
    end
end)

createToggleButton("Speed Hack", function(state)
    print("Speed Hack: " .. (state and "ON" or "OFF"))
    if state then
        -- Add speed hack logic (e.g., modify Humanoid WalkSpeed)
        if Player.Character and Player.Character:FindFirstChild("Humanoid") then
            Player.Character.Humanoid.WalkSpeed = 50 -- Adjust speed as needed
        end
    else
        if Player.Character and Player.Character:FindFirstChild("Humanoid") then
            Player.Character.Humanoid.WalkSpeed = 16 -- Default Roblox walk speed
        end
    end
end)

createToggleButton("Aimbot", function(state)
    print("Aimbot: " .. (state and "ON" or "OFF"))
    if state then
        -- Add aimbot logic (e.g., aim at nearest player)
        spawn(function()
            while features.Aimbot and Player.Character do
                -- Example: Aim at nearest player (replace with game-specific logic)
                local closestPlayer = nil
                local minDistance = math.huge
                for _, p in pairs(Players:GetPlayers()) do
                    if p ~= Player and p.Character and p.Character:FindFirstChild("Head") then
                        local distance = (p.Character.Head.Position - Player.Character.Head.Position).Magnitude
                        if distance < minDistance then
                            minDistance = distance
                            closestPlayer = p
                        end
                    end
                end
                if closestPlayer and Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
                    -- Example: Rotate to face target (simplified)
                    local targetPos = closestPlayer.Character.Head.Position
                    local lookAt = CFrame.new(Player.Character.HumanoidRootPart.Position, targetPos)
                    Player.Character.HumanoidRootPart.CFrame = lookAt
                end
                wait(0.1)
            end
        end)
    end
end)

-- Close button
local CloseButton = Instance.new("TextButton")
CloseButton.Size = UDim2.new(0.1, 0, 0.05, 0)
CloseButton.Position = UDim2.new(0.85, 0, 0.05, 0)
CloseButton.BackgroundColor3 = Color3.fromRGB(255, 85, 85)
CloseButton.Text = "X"
CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseButton.TextScaled = true
CloseButton.Font = Enum.Font.GothamBold
CloseButton.Parent = MainFrame

local UICornerClose = Instance.new("UICorner")
UICornerClose.CornerRadius = UDim.new(0, 5)
UICornerClose.Parent = CloseButton

CloseButton.MouseButton1Click:Connect(function()
    local tween = TweenService:Create(MainFrame, TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {Position = UDim2.new(0.3, 0, -0.5, 0)})
    tween:Play()
    tween.Completed:Wait()
    ScreenGui:Destroy()
end)

-- Toggle UI with keybind (E key)
local uiVisible = true
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == Enum.KeyCode.E then
        uiVisible = not uiVisible
        local targetPos = uiVisible and UDim2.new(0.3, 0, 0.25, 0) or UDim2.new(0.3, 0, -0.5, 0)
        TweenService:Create(MainFrame, TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {Position = targetPos}):Play()
    end
end)

-- Draggable UI
local dragging, dragInput, dragStart, startPos
local function update(input)
    local delta = input.Position - dragStart
    local newPos = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    -- Clamp position to screen bounds
    newPos = UDim2.new(
        math.clamp(newPos.X.Scale, 0, 1 - MainFrame.Size.X.Scale),
        newPos.X.Offset,
        math.clamp(newPos.Y.Scale, 0, 1 - MainFrame.Size.Y.Scale),
        newPos.Y.Offset
    )
    MainFrame.Position = newPos
end

MainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

MainFrame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        update(input)
    end
end)

-- Welcome animation
MainFrame.Position = UDim2.new(0.3, 0, -0.5, 0)
TweenService:Create(MainFrame, TweenInfo.new(0.7, Enum.EasingStyle.Bounce, Enum.EasingDirection.Out), {Position = UDim2.new(0.3, 0, 0.25, 0)}):Play()

print("Script Premium đã tải thành công!")