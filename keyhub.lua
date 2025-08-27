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

-- Function to verify key with retry logic and SSL handling
local function verifyKey(key, maxRetries, retryDelay)
    local retries = 0
    while retries < maxRetries do
        local success, response
        -- Try GetAsync first, fallback to RequestInternal with IgnoreSslValidation
        success, response = pcall(function()
            return HttpService:GetAsync(API_URL .. "/verify?key=" .. HttpService:UrlEncode(key))
        end)
        if not success then
            print("GetAsync failed, trying RequestInternal: " .. tostring(response))
            success, response = pcall(function()
                return HttpService:RequestInternal({
                    Url = API_URL .. "/verify?key=" .. HttpService:UrlEncode(key),
                    Method = "GET",
                    IgnoreSslValidation = true -- Bypass SSL for local testing
                }).Body
            end)
        end
        
        if success then
            local decodeSuccess, result = pcall(function()
                return HttpService:JSONDecode(response)
            end)
            
            if decodeSuccess then
                if result.error then
                    print("API Error: " .. result.error)
                    return false, "API Error: " .. result.error
                end
                print("Key verification result: ", result)
                return true, result
            else
                print("Failed to parse API response: ", response)
                return false, "Failed to parse API response"
            end
        else
            retries = retries + 1
            print("Connection attempt " .. retries .. " failed: " .. tostring(response))
            if retries < maxRetries then
                wait(retryDelay)
            else
                print("All " .. maxRetries .. " attempts failed. Check API server at " .. API_URL)
                return false, "Connection error: Unable to reach API after " .. maxRetries .. " attempts"
            end
        end
    end
end

-- Verify key
local success, result = verifyKey(getgenv().Key, 3, 1)
if not success then
    Player:Kick("Lỗi: " .. result .. ". \n- Đảm bảo API đang chạy tại " .. API_URL .. ". \n- Nếu dùng chứng chỉ tự ký, triển khai API với chứng chỉ đáng tin cậy. \n- Dùng 127.0.0.1 nếu chạy trên cùng máy. \nLiên hệ quản trị viên hoặc thử lại sau.")
    return
end

if not result.valid or not result.redeemed then
    local errorMsg
    if not result.exists then
        errorMsg = "Khóa không hợp lệ. Vui lòng sử dụng /genkey và /redeem trên Discord."
    elseif not result.redeemed then
        errorMsg = "Khóa chưa được kích hoạt. Vui lòng sử dụng /redeem trên Discord."
    else
        errorMsg = "Khóa không hợp lệ. Vui lòng kiểm tra lại."
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
MainFrame.Size = UDim2.new(0, 300, 0, 400)
MainFrame.Position = UDim2.new(0.5, -150, 0.5, -200)
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
Title.Text = "Script Premium"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextScaled = true
Title.Font = Enum.Font.GothamBlack
Title.TextStrokeTransparency = 0.7
Title.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
Title.Parent = MainFrame

-- Toggle Button
local ToggleButton = Instance.new("TextButton")
ToggleButton.Size = UDim2.new(0.1, 0, 0.05, 0)
ToggleButton.Position = UDim2.new(0.9, -30, 0.05, 0)
ToggleButton.BackgroundColor3 = Color3.fromRGB(255, 85, 85)
ToggleButton.Text = "☰"
ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleButton.TextScaled = true
ToggleButton.Font = Enum.Font.GothamBold
ToggleButton.Parent = MainFrame

local ToggleCorner = Instance.new("UICorner")
ToggleCorner.CornerRadius = UDim.new(0, 5)
ToggleCorner.Parent = ToggleButton

local isMenuVisible = true
ToggleButton.MouseButton1Click:Connect(function()
    isMenuVisible = not isMenuVisible
    local targetPos = isMenuVisible and UDim2.new(0.5, -150, 0.5, -200) or UDim2.new(0.5, -150, 1.5, 0)
    TweenService:Create(MainFrame, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = targetPos}):Play()
end)

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

-- Function to create toggle button
local function createToggleButton(text, defaultState, callback)
    local ButtonFrame = Instance.new("Frame")
    ButtonFrame.Size = UDim2.new(1, 0, 0, 50)
    ButtonFrame.BackgroundTransparency = 1
    ButtonFrame.Parent = ButtonContainer

    local Button = Instance.new("TextButton")
    Button.Size = UDim2.new(1, 0, 1, 0)
    Button.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    Button.Text = text .. (defaultState and " [ON]" or " [OFF]")
    Button.TextColor3 = Color3.fromRGB(255, 255, 255)
    Button.TextScaled = true
    Button.Font = Enum.Font.GothamBold
    Button.Parent = ButtonFrame

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

    local isOn = defaultState
    Button.MouseButton1Click:Connect(function()
        isOn = not isOn
        Button.Text = text .. (isOn and " [ON]" or " [OFF]")
        if isOn then
            ButtonGradient.Color = ColorSequence.new{
                ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 255, 0)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 170, 255))
            }
        else
            ButtonGradient.Color = ColorSequence.new{
                ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 170, 255)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 255, 170))
            }
        end
        callback(isOn)
    end)
end

-- Implement features
local function autoFarm(isActive)
    if isActive then
        spawn(function()
            while isActive and wait(0.1) do
                for _, v in pairs(game.Workspace:GetDescendants()) do
                    if v.Name == "FarmSpot" then -- Replace with actual farm spot name
                        Player.Character.HumanoidRootPart.CFrame = v.CFrame
                        wait(0.5)
                    end
                end
            end
        end)
    end
end

local function autoLevel(isActive)
    if isActive then
        spawn(function()
            while isActive and wait(1) do
                local levelPart = game.Workspace:FindFirstChild("LevelUpPart") -- Replace with actual part name
                if levelPart then
                    Player.Character.HumanoidRootPart.CFrame = levelPart.CFrame
                    wait(0.5)
                    game:GetService("ReplicatedStorage").LevelUp:FireServer() -- Replace with actual level-up event
                end
            end
        end)
    end
end

local function esp(isActive)
    if isActive then
        spawn(function()
            while isActive and wait(0.5) do
                for _, player in pairs(Players:GetPlayers()) do
                    if player ~= Player then
                        local billboard = player.Character and player.Character:FindFirstChild("Head") and player.Character.Head:FindFirstChild("ESPBillboard")
                        if not billboard then
                            billboard = Instance.new("BillboardGui")
                            billboard.Name = "ESPBillboard"
                            billboard.Parent = player.Character and player.Character:FindFirstChild("Head") or nil
                            billboard.Size = UDim2.new(0, 100, 0, 50)
                            billboard.AlwaysOnTop = true
                            local text = Instance.new("TextLabel")
                            text.Parent = billboard
                            text.Size = UDim2.new(1, 0, 1, 0)
                            text.Text = player.Name
                            text.TextColor3 = Color3.fromRGB(0, 255, 0)
                            text.BackgroundTransparency = 1
                        end
                    end
                end
            end
        else
            for _, player in pairs(Players:GetPlayers()) do
                if player ~= Player then
                    local billboard = player.Character and player.Character:FindFirstChild("Head") and player.Character.Head:FindFirstChild("ESPBillboard")
                    if billboard then billboard:Destroy() end
                end
            end
        end
    end
end

local function aimbot(isActive)
    if isActive then
        spawn(function()
            while isActive and wait(0.1) do
                local target = nil
                local maxDist = math.huge
                for _, player in pairs(Players:GetPlayers()) do
                    if player ~= Player and player.Character and player.Character:FindFirstChild("Head") then
                        local dist = (Player.Character.Head.Position - player.Character.Head.Position).Magnitude
                        if dist < maxDist then
                            maxDist = dist
                            target = player.Character.Head
                        end
                    end
                end
                if target then
                    Player.Character.HumanoidRootPart.CFrame = CFrame.new(Player.Character.HumanoidRootPart.Position, target.Position)
                end
            end
        end)
    end
end

local function speedHack(isActive)
    if isActive then
        Player.Character.Humanoid.WalkSpeed = 50 -- Adjust speed as needed
    else
        Player.Character.Humanoid.WalkSpeed = 16 -- Reset to default
    end
end

-- Create toggle buttons
createToggleButton("Auto Farm", false, autoFarm)
createToggleButton("Auto Level", false, autoLevel)
createToggleButton("ESP", false, esp)
createToggleButton("Aimbot", false, aimbot)
createToggleButton("Speed Hack", false, speedHack)

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
MainFrame.Position = UDim2.new(0.5, -150, 1.5, 0)
TweenService:Create(MainFrame, TweenInfo.new(0.7, Enum.EasingStyle.Bounce, Enum.EasingDirection.Out), {Position = UDim2.new(0.5, -150, 0.5, -200)}):Play()

print("Script Premium đã tải thành công!")