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

-- Adjust size based on device
local isMobile = UserInputService.TouchEnabled and not UserInputService.MouseEnabled
local frameSize = isMobile and UDim2.new(0.8, 0, 0.9, 0) or UDim2.new(0.5, 0, 0.6, 0)
local framePosition = isMobile and UDim2.new(0.1, 0, 0.05, 0) or UDim2.new(0.25, 0, 0.2, 0)

local MainFrame = Instance.new("Frame")
MainFrame.Size = frameSize
MainFrame.Position = UDim2.new(0.25, 0, -0.6, 0) -- Start off-screen for animation
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui
MainFrame.Visible = false -- Hidden by default, toggled by button

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

-- Toggle Button
local ToggleButton = Instance.new("TextButton")
ToggleButton.Size = UDim2.new(0.1, 0, 0.05, 0)
ToggleButton.Position = UDim2.new(0.9, -50, 0.9, -30)
ToggleButton.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
ToggleButton.Text = "☰"
ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleButton.TextScaled = true
ToggleButton.Font = Enum.Font.GothamBold
ToggleButton.Parent = ScreenGui

local ToggleCorner = Instance.new("UICorner")
ToggleCorner.CornerRadius = UDim.new(0, 10)
ToggleCorner.Parent = ToggleButton

local ToggleGradient = Instance.new("UIGradient")
ToggleGradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 170, 255)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 255, 170))
}
ToggleGradient.Rotation = 45
ToggleGradient.Parent = ToggleButton

local isMenuVisible = false
ToggleButton.MouseButton1Click:Connect(function()
    isMenuVisible = not isMenuVisible
    MainFrame.Visible = isMenuVisible
    if isMenuVisible then
        TweenService:Create(MainFrame, TweenInfo.new(0.7, Enum.EasingStyle.Bounce, Enum.EasingDirection.Out), {Position = framePosition}):Play()
    else
        TweenService:Create(MainFrame, TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {Position = UDim2.new(0.25, 0, -0.6, 0)}):Play()
    end
end)

-- Button Container
local ButtonContainer = Instance.new("Frame")
ButtonContainer.Size = UDim2.new(0.9, 0, 0.7, 0)
ButtonContainer.Position = UDim2.new(0.05, 0, 0.15, 0)
ButtonContainer.BackgroundTransparency = 1
ButtonContainer.Parent = MainFrame

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Padding = UDim.new(0, isMobile and 5 or 10)
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Parent = ButtonContainer

local function createButton(text, callback, isToggle)
    local Button = Instance.new("TextButton")
    Button.Size = UDim2.new(1, 0, 0, isMobile and 40 or 50)
    Button.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    Button.Text = text
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
    
    if isToggle then
        local isActive = false
        Button.MouseButton1Click:Connect(function()
            isActive = not isActive
            Button.BackgroundColor3 = isActive and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(30, 30, 30)
            callback(isActive)
        end)
    else
        Button.MouseButton1Click:Connect(callback)
    end
end

-- Feature Implementations
local autoFarmActive = false
createButton("Auto Farm", function(active)
    autoFarmActive = active
    spawn(function()
        while autoFarmActive and wait(1) do
            local humanoidRootPart = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
            if humanoidRootPart then
                humanoidRootPart.CFrame = CFrame.new(0, 50, 0) -- Placeholder: Move to a farm area
                print("Auto Farm đang hoạt động...")
            end
        end
    end)
end, true)

createButton("Level Hack", function()
    local character = Player.Character
    if character and character:FindFirstChild("Humanoid") then
        character.Humanoid.WalkSpeed = 100 -- Placeholder: Increase level/speed
        print("Level Hack đã kích hoạt!")
    end
end)

createButton("Speed Hack", function()
    local character = Player.Character
    if character and character:FindFirstChild("Humanoid") then
        character.Humanoid.WalkSpeed = 50 -- Adjustable speed
        print("Speed Hack đã kích hoạt!")
    end
end)

-- Close Button
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
    TweenService:Create(MainFrame, TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {Position = UDim2.new(0.25, 0, -0.6, 0)}):Play()
    wait(0.5)
    MainFrame.Visible = false
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
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        update(input)
    end
end)

-- Welcome animation (triggered on toggle)
print("Script Premium đã tải thành công!")