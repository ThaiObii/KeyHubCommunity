-- Script Premium
repeat wait() until game:IsLoaded() and game.Players.LocalPlayer
getgenv().Key = getgenv().Key or ""

local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Player = Players.LocalPlayer
local API_URL = "https://192.168.1.20:5000"  -- Update to your deployed API URL

-- Function to verify key with retry logic
local function verifyKey(key, maxRetries, retryDelay)
    local retries = 0
    while retries < maxRetries do
        local success, response = pcall(function()
            return HttpService:GetAsync(API_URL .. "/verify?key=" .. HttpService:UrlEncode(key))
        end)
        
        if success then
            local decodeSuccess, result = pcall(function()
                return HttpService:JSONDecode(response)
            end)
            
            if decodeSuccess then
                if result.error then
                    return false, "API Error: " .. result.error
                end
                return true, result
            else
                return false, "Failed to parse API response"
            end
        else
            retries = retries + 1
            if retries < maxRetries then
                wait(retryDelay)
            else
                return false, "Connection error: Unable to reach API after " .. maxRetries .. " attempts"
            end
        end
    end
end

-- Verify key
local success, result = verifyKey(getgenv().Key, 3, 1)
if not success then
    Player:Kick("Lỗi: " .. result .. ". Liên hệ quản trị viên hoặc thử lại sau.")
    return
end

if not result.valid or not result.redeemed then
    local errorMsg
    if not result.exists then
        errorMsg = "Key không hợp lệ. Vui lòng sử dụng /genkey và /redeem trên Discord."
    elseif not result.redeemed then
        errorMsg = "Key chưa được kích hoạt. Vui lòng sử dụng /redeem trên Discord."
    else
        errorMsg = "Key không hợp lệ. Vui lòng kiểm tra lại."
    end
    Player:Kick("Lỗi: " .. errorMsg)
    return
end

-- Premium UI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Parent = Player.PlayerGui
ScreenGui.Name = "PremiumUI"
ScreenGui.ResetOnSpawn = false

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 300, 0, 400) -- Fixed size for mobile/PC adaptability
MainFrame.Position = UDim2.new(0.5, -150, 0.5, -200) -- Center initially
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui

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
Title.Text = "Premium Script"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextScaled = true
Title.Font = Enum.Font.GothamBlack
Title.TextStrokeTransparency = 0.7
Title.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
Title.Parent = MainFrame

-- Toggle Button
local ToggleButton = Instance.new("TextButton")
ToggleButton.Size = UDim2.new(0, 40, 0, 40)
ToggleButton.Position = UDim2.new(0.01, 0, 0.01, 0)
ToggleButton.BackgroundColor3 = Color3.fromRGB(255, 85, 85)
ToggleButton.Text = "☰"
ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleButton.TextScaled = true
ToggleButton.Font = Enum.Font.GothamBold
ToggleButton.Parent = MainFrame

local ToggleCorner = Instance.new("UICorner")
ToggleCorner.CornerRadius = UDim.new(0, 5)
ToggleCorner.Parent = ToggleButton

-- Button Container
local ButtonContainer = Instance.new("Frame")
ButtonContainer.Size = UDim2.new(0.9, 0, 0.75, 0)
ButtonContainer.Position = UDim2.new(0.05, 0, 0.15, 0)
ButtonContainer.BackgroundTransparency = 1
ButtonContainer.Parent = MainFrame

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Padding = UDim.new(0, 10)
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Parent = ButtonContainer

-- Toggle States
local toggles = {
    AutoFarm = false,
    AutoLevel = false,
    ESP = false,
    SpeedHack = false
}

-- Function to create toggle button
local function createToggleButton(text, stateKey)
    local Button = Instance.new("TextButton")
    Button.Size = UDim2.new(1, 0, 0, 50)
    Button.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    Button.Text = text .. (toggles[stateKey] and " [ON]" or " [OFF]")
    Button.TextColor3 = Color3.fromRGB(255, 255, 255)
    Button.TextScaled = true
    Button.Font = Enum.Font.GothamBold
    Button.Parent = ButtonContainer
    
    local ButtonCorner = Instance.new("UICorner")
    ButtonCorner.CornerRadius = UDim.new(0, 10)
    ButtonCorner.Parent = Button
    
    local ButtonGradient = Instance.new("UIGradient")
    ButtonGradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 170, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 255, 170))
    }
    ButtonGradient.Rotation = 45
    ButtonGradient.Parent = Button
    
    Button.MouseButton1Click:Connect(function()
        toggles[stateKey] = not toggles[stateKey]
        Button.Text = text .. (toggles[stateKey] and " [ON]" or " [OFF]")
        if toggles[stateKey] then
            -- Activate feature
            if stateKey == "AutoFarm" then
                spawn(function()
                    while toggles.AutoFarm and wait(1) do
                        -- Auto Farm logic (example: move to nearest part)
                        local part = workspace:FindFirstChild("FarmPart")
                        if part and part:IsA("BasePart") then
                            Player.Character.Humanoid:MoveTo(part.Position)
                        end
                    end
                end)
            elseif stateKey == "AutoLevel" then
                spawn(function()
                    while toggles.AutoLevel and wait(1) do
                        -- Auto Level logic (example: increase level stat)
                        local stats = Player:FindFirstChild("leaderstats")
                        if stats and stats:FindFirstChild("Level") then
                            stats.Level.Value = stats.Level.Value + 1
                        end
                    end
                end)
            elseif stateKey == "ESP" then
                -- ESP logic (example: highlight parts)
                for _, part in pairs(workspace:GetDescendants()) do
                    if part:IsA("BasePart") then
                        local billboard = Instance.new("BillboardGui", part)
                        billboard.Size = UDim2.new(0, 100, 0, 50)
                        billboard.AlwaysOnTop = true
                        local text = Instance.new("TextLabel", billboard)
                        text.Size = UDim2.new(1, 0, 1, 0)
                        text.Text = part.Name
                        text.TextColor3 = Color3.fromRGB(0, 255, 0)
                    end
                end
            elseif stateKey == "SpeedHack" then
                spawn(function()
                    while toggles.SpeedHack and wait(0.1) do
                        Player.Character.Humanoid.WalkSpeed = 100
                    end
                end)
            end
        else
            -- Deactivate feature
            if stateKey == "SpeedHack" then
                Player.Character.Humanoid.WalkSpeed = 16 -- Reset speed
            end
        end
    end)
end

-- Create toggle buttons
createToggleButton("Auto Farm", "AutoFarm")
createToggleButton("Auto Level", "AutoLevel")
createToggleButton("ESP", "ESP")
createToggleButton("Speed Hack", "SpeedHack")

-- Toggle UI visibility
local uiVisible = false
ToggleButton.MouseButton1Click:Connect(function()
    uiVisible = not uiVisible
    local targetPos = uiVisible and UDim2.new(0.5, -150, 0.5, -200) or UDim2.new(0.5, -150, -0.5, 0)
    TweenService:Create(MainFrame, TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {Position = targetPos}):Play()
end)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == Enum.KeyCode.E then
        uiVisible = not uiVisible
        local targetPos = uiVisible and UDim2.new(0.5, -150, 0.5, -200) or UDim2.new(0.5, -150, -0.5, 0)
        TweenService:Create(MainFrame, TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {Position = targetPos}):Play()
    end
end)

-- Draggable UI
local dragging, dragInput, dragStart, startPos
local function update(input)
    local delta = input.Position - dragStart
    MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
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
    if (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        update(input)
    end
end)

-- Welcome animation
MainFrame.Position = UDim2.new(0.5, -150, -0.5, 0)
TweenService:Create(MainFrame, TweenInfo.new(0.7, Enum.EasingStyle.Bounce, Enum.EasingDirection.Out), {Position = UDim2.new(0.5, -150, 0.5, -200)}):Play()

print("Script Premium đã tải thành công!")