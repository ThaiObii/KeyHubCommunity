-- Premium Script with UI
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
        return data.valid
    end
    return false
end

-- Kick if key is invalid
if not getgenv().Key or not verifyKey(getgenv().Key) then
    LocalPlayer:Kick("Invalid or unredeemed API key. Please redeem a valid key.")
    return
end

-- UI Library (Synapse X UI Lib or similar)
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/Robojini/Dropbox/master/UILIB.lua"))()
local Window = Library:CreateWindow("Premium Script")

-- Main UI
local Tab = Window:Tab("Main")
Tab:Label("Welcome to Premium Script!")
Tab:Button("Execute Premium Feature", function()
    print("Premium feature executed!")
    -- Add your premium script functionality here
end)

Tab:Separator()
Tab:Label("User: " .. LocalPlayer.Name)
Tab:Label("Key: " .. getgenv().Key)

-- Settings Tab
local SettingsTab = Window:Tab("Settings")
SettingsTab:Button("Logout", function()
    LocalPlayer:Kick("Logged out. Please restart the script with a new key.")
end)

-- UI Styling
Library:Notify("Premium Script Loaded", 5)