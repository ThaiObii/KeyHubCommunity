-- Script Cao Cấp với Giao Diện Hiện Đại
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Kiểm tra khóa API
local function verifyKey(key)
    local success, response = pcall(function()
        -- Thay thế URL này bằng điểm cuối API thực tế của bạn
        return HttpService:GetAsync("https://your-api-endpoint.com/verify?key=" .. key)
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
    return false, "Không thể kết nối với API. Vui lòng kiểm tra kết nối hoặc thử lại sau."
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
    Transparency = 0.2,
    CornerRadius = 8
})

-- Tab Chính với thiết kế hiện đại
local MainTab = Window:CreateTab("Chính", "rbxasset://textures/ui/GuiImagePlaceholder.png")
MainTab:CreateSection("Chào mừng, " .. LocalPlayer.Name .. "!")
MainTab:CreateLabel("Khóa của bạn: " .. getgenv().Key, {
    TextColor = Color3.fromRGB(150, 200, 255),
    Font = Enum.Font.GothamBold
})

MainTab:CreateButton("Kích Hoạt Tính Năng Cao Cấp", function()
    print("Tính năng cao cấp đã được kích hoạt!")
    Library:Notify("Tính Năng Đã Kích Hoạt!", 3, "Thành Công")
    -- Thêm chức năng script cao cấp tại đây
end, {
    Color = Color3.fromRGB(0, 170, 255),
    HoverColor = Color3.fromRGB(0, 200, 255),
    TextColor = Color3.fromRGB(255, 255, 255)
})

MainTab:CreateToggle("Tự Động Kích Hoạt Tính Năng", false, function(state)
    print("Tự động kích hoạt được đặt thành: " .. tostring(state))
    -- Thêm logic tự động kích hoạt tại đây
end, {
    EnabledColor = Color3.fromRGB(0, 255, 100),
    DisabledColor = Color3.fromRGB(100, 100, 100)
})

MainTab:CreateSlider("Cường Độ Tính Năng", 0, 100, 50, function(value)
    print("Cường độ tính năng được đặt thành: " .. value)
    -- Thêm logic dựa trên cường độ tại đây
end, {
    Color = Color3.fromRGB(0, 120, 255),
    MarkerColor = Color3.fromRGB(255, 255, 255)
})

-- Tab Cài Đặt với các tính năng bổ sung
local SettingsTab = Window:CreateTab("Cài Đặt", "rbxasset://textures/ui/Settings.png")
SettingsTab:CreateSection("Quản Lý Tài Khoản")
SettingsTab:CreateButton("Đăng Xuất", function()
    LocalPlayer:Kick("Đã đăng xuất. Vui lòng khởi động lại script với khóa mới.")
end, {
    Color = Color3.fromRGB(255, 50, 50),
    HoverColor = Color3.fromRGB(255, 100, 100),
    TextColor = Color3.fromRGB(255, 255, 255)
})

SettingsTab:CreateDropdown("Giao Diện", {"Tối", "Sáng", "Neon"}, "Tối", function(theme)
    Library:SetTheme(theme == "Tối" and "Dark" or theme == "Sáng" and "Light" or "Neon")
    Library:Notify("Giao diện đã đổi thành " .. theme, 3, "Thông Tin")
end, {
    Color = Color3.fromRGB(50, 50, 50),
    TextColor = Color3.fromRGB(200, 200, 200)
})

-- Khởi tạo Giao Diện
Library:Notify("Trung Tâm Script Cao Cấp Đã Tải", 5, "Thành Công")
Window:SelectTab(MainTab)