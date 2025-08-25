-- Script Cao Cấp với Giao Diện Hiện Đại
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")

-- Kiểm tra khóa API với thử lại
local function verifyKey(key)
    local maxRetries = 3
    local retryDelay = 2
    for attempt = 1, maxRetries do
        local success, response = pcall(function()
            return HttpService:GetAsync("http://192.168.1.10:5000/verify?key=" .. key, true, {["Timeout"] = 10})
        end)
        if success then
            local success_decode, data = pcall(function()
                return HttpService:JSONDecode(response)
            end)
            if success_decode then
                if not data.exists then
                    return false, "Khóa không hợp lệ: Khóa không tồn tại."
                elseif not data.redeemed then
                    return false, "Khóa chưa được kích hoạt: Vui lòng kích hoạt khóa bằng lệnh /redeem."
                end
                return data.valid, "Khóa đã được xác minh thành công."
            else
                return false, "Lỗi khi phân tích phản hồi từ API."
            end
        end
        wait(retryDelay)
    end
    return false, "Không thể kết nối với API. Vui lòng kiểm tra URL API hoặc kết nối mạng."
end

-- Đá người chơi nếu khóa không hợp lệ hoặc chưa được kích hoạt
if not getgenv().Key then
    LocalPlayer:Kick("Không cung cấp khóa API. Vui lòng sử dụng khóa hợp lệ.")
    return
end
local isValid, message = verifyKey(getgenv().Key)
if not isValid then
    LocalPlayer:Kick(message)
    return
end

-- Tải Thư Viện Giao Diện Vestra (hiện đại, mượt mà)
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/0zBug/Vestra/main/Vestra.lua"))()
local Window = Library:CreateWindow("Trung Tâm Script Cao Cấp", {
    Theme = "Dark",
    AccentColor = Color3.fromRGB(0, 120, 255),
    Transparency = 0.15,
    CornerRadius = 10,
    Animation = {Type = "FadeIn", Duration = 0.5}
})

-- Tab Chính với thiết kế hiện đại
local MainTab = Window:CreateTab("Chính", "rbxasset://textures/ui/GuiImagePlaceholder.png", {
    Animation = {Type = "SlideIn", Direction = "Left", Duration = 0.3}
})
MainTab:CreateSection("Chào Mừng, " .. LocalPlayer.Name .. "!", {
    Gradient = {Color3.fromRGB(0, 120, 255), Color3.fromRGB(0, 255, 200)},
    Font = Enum.Font.GothamBold
})
MainTab:CreateLabel("Khóa của bạn: " .. getgenv().Key, {
    TextColor = Color3.fromRGB(150, 200, 255),
    Font = Enum.Font.GothamBold,
    Animation = {Type = "FadeIn", Duration = 0.4}
})

MainTab:CreateButton("Kích Hoạt Tính Năng Cao Cấp", function()
    print("Tính năng cao cấp đã được kích hoạt!")
    Library:Notify("Tính Năng Đã Kích Hoạt!", 3, "Thành Công", {
        Animation = {Type = "PopIn", Duration = 0.3}
    })
    -- Thêm chức năng script cao cấp tại đây
end, {
    Color = Color3.fromRGB(0, 170, 255),
    HoverColor = Color3.fromRGB(0, 200, 255),
    TextColor = Color3.fromRGB(255, 255, 255),
    BorderColor = Color3.fromRGB(50, 50, 50),
    Animation = {Type = "Scale", Duration = 0.2}
})

MainTab:CreateToggle("Tự Động Kích Hoạt Tính Năng", false, function(state)
    print("Tự động kích hoạt được đặt thành: " .. tostring(state))
    -- Thêm logic tự động kích hoạt tại đây
end, {
    EnabledColor = Color3.fromRGB(0, 255, 100),
    DisabledColor = Color3.fromRGB(100, 100, 100),
    Animation = {Type = "FadeIn", Duration = 0.3}
})

MainTab:CreateSlider("Cường Độ Tính Năng", 0, 100, 50, function(value)
    print("Cường độ tính năng được đặt thành: " .. value)
    -- Thêm logic dựa trên cường độ tại đây
end, {
    Color = Color3.fromRGB(0, 120, 255),
    MarkerColor = Color3.fromRGB(255, 255, 255),
    Gradient = {Color3.fromRGB(0, 120, 255), Color3.fromRGB(0, 255, 200)},
    Animation = {Type = "Slide", Duration = 0.3}
})

-- Thanh trạng thái
MainTab:CreateLabel("Trạng Thái: Đã Kết Nối", {
    TextColor = Color3.fromRGB(0, 255, 100),
    Font = Enum.Font.Gotham,
    Animation = {Type = "FadeIn", Duration = 0.5}
})

-- Tab Cài Đặt với các tính năng bổ sung
local SettingsTab = Window:CreateTab("Cài Đặt", "rbxasset://textures/ui/Settings.png", {
    Animation = {Type = "SlideIn", Direction = "Right", Duration = 0.3}
})
SettingsTab:CreateSection("Quản Lý Tài Khoản", {
    Gradient = {Color3.fromRGB(255, 50, 50), Color3.fromRGB(255, 100, 100)}
})
SettingsTab:CreateButton("Đăng Xuất", function()
    LocalPlayer:Kick("Đã đăng xuất. Vui lòng khởi động lại script với khóa mới.")
end, {
    Color = Color3.fromRGB(255, 50, 50),
    HoverColor = Color3.fromRGB(255, 100, 100),
    TextColor = Color3.fromRGB(255, 255, 255),
    BorderColor = Color3.fromRGB(50, 50, 50),
    Animation = {Type = "Scale", Duration = 0.2}
})

SettingsTab:CreateDropdown("Giao Diện", {"Tối", "Sáng", "Neon"}, "Tối", function(theme)
    Library:SetTheme(theme == "Tối" and "Dark" or theme == "Sáng" and "Light" or "Neon")
    Library:Notify("Giao diện đã đổi thành " .. theme, 3, "Thông Tin", {
        Animation = {Type = "PopIn", Duration = 0.3}
    })
end, {
    Color = Color3.fromRGB(50, 50, 50),
    TextColor = Color3.fromRGB(200, 200, 200),
    Animation = {Type = "FadeIn", Duration = 0.3}
})

-- Thông tin người dùng
SettingsTab:CreateSection("Thông Tin Người Dùng")
SettingsTab:CreateLabel("Tên: " .. LocalPlayer.Name, {
    TextColor = Color3.fromRGB(200, 200, 200),
    Font = Enum.Font.Gotham
})
SettingsTab:CreateLabel("ID: " .. LocalPlayer.UserId, {
    TextColor = Color3.fromRGB(200, 200, 200),
    Font = Enum.Font.Gotham
})

-- Khởi tạo Giao Diện
Library:Notify("Trung Tâm Script Cao Cấp Đã Tải", 5, "Thành Công", {
    Animation = {Type = "FadeIn", Duration = 0.5}
})
Window:SelectTab(MainTab)