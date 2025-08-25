-- Premium Script with Modern UI
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- API key verification
local function verifyKey(key)
    local success, response = pcall(function()
        return HttpService:GetAsync("https://your-api-endpoint.com/verify?key=" .. key)
    end)
    if success then
        local data = HttpService:JSONDecode(response)
        if not data.exists then
            return false, "Invalid key: Key does not exist."
        elseif not data.redeemed then
            return false, "Unredeemed key: Please redeem the key using /redeem."
        end
        return data.valid, "Key verified successfully."
    end
    return false, "Failed to connect to API."
end

-- Kick if key is invalid or unredeemed
if not getgenv().Key then
    LocalPlayer:Kick("No API key provided. Please set a valid key.")
    return
end
local isValid, message = verifyKey(getgenv().Key)
if not isValid then
    LocalPlayer:Kick(message)
    return
end

-- Load Vestra UI Library (modern, sleek UI)
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/0zBug/Vestra/main/Vestra.lua"))()
local Window = Library:CreateWindow("Premium Script Hub", {
    Theme = "Dark",
    AccentColor = Color3.fromRGB(0, 120, 255),
    Transparency = 0.2,
    CornerRadius = 8
})

-- Main Tab with modern design
local MainTab = Window:CreateTab("Main", "rbxasset://textures/ui/GuiImagePlaceholder.png")
MainTab:CreateSection("Welcome, " .. LocalPlayer.Name .. "!")
MainTab:CreateLabel("Your Key: " .. getgenv().Key, {
    TextColor = Color3.fromRGB(150, 200, 255),
    Font = Enum.Font.GothamBold
})

MainTab:CreateButton("Execute Premium Feature", function()
    print("Premium feature executed!")
    Library:Notify("Feature Activated!", 3, "Success")
    -- Add your premium script functionality here
end, {
    Color = Color3.fromRGB(0, 170, 255),
    HoverColor = Color3.fromRGB(0, 200, 255),
    TextColor = Color3.fromRGB(255, 255, 255)
})

MainTab:CreateToggle("Auto-Execute Feature", false, function(state)
    print("Auto-Execute set to: " .. tostring(state))
    -- Add auto-execute logic here
end, {
    EnabledColor = Color3.fromRGB(0, 255, 100),
    DisabledColor = Color3.fromRGB(100, 100, 100)
})

MainTab:CreateSlider("Feature Intensity", 0, 100, 50, function(value)
    print("Feature intensity set to: " .. value)
    -- Add intensity-based logic here
end, {
    Color = Color3.fromRGB(0, 120, 255),
    MarkerColor = Color3.fromRGB(255, 255, 255)
})

-- Settings Tab with additional features
local SettingsTab = Window:CreateTab("Settings", "rbxasset://textures/ui/Settings.png")
SettingsTab:CreateSection("Account Management")
SettingsTab:CreateButton("Logout", function()
    LocalPlayer:Kick("Logged out. Please restart the script with a new key.")
end, {
    Color = Color3.fromRGB(255, 50, 50),
    HoverColor = Color3.fromRGB(255, 100, 100),
    TextColor = Color3.fromRGB(255, 255, 255)
})

SettingsTab:CreateDropdown("Theme", {"Dark", "Light", "Neon"}, "Dark", function(theme)
    Library:SetTheme(theme)
    Library:Notify("Theme changed to " .. theme, 3, "Info")
end, {
    Color = Color3.fromRGB(50, 50, 50),
    TextColor = Color3.fromRGB(200, 200, 200)
})

-- UI Initialization
Library:Notify("Premium Script Hub Loaded", 5, "Success")
Window:SelectTab(MainTab)