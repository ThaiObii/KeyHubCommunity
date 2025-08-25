-- Script Cao Cấp với Giao Diện Hiện Đại
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer

-- Kiểm tra khóa API
local function verifyKey(key)
    local success, response = pcall(function()
        -- Thay thế bằng điểm cuối API thực tế của bạn
        return HttpService:GetAsync("http://127.0.0.1:5000/verify?key=" .. key)
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
    return false, "Không thể kết nối với API. Vui lòng kiểm tra máy chủ API hoặc kết nối mạng."
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
    Animation = true, -- Bật hiệu ứng động
    AnimationSpeed = 0.5
})

-- Hiệu ứng động cho các phần tử UI
local function animateElement(element)
    local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
    local tween = TweenService:Create(element, tweenInfo, {Transparency = 0})
    tween:Play()
end

-- Tab Chính với thiết kế hiện đại
local MainTab = Window:CreateTab("Chính", "rbxasset://textures/ui/GuiImagePlaceholder.png")
MainTab:CreateSection("Chào Mừng, " .. LocalPlayer.Name .. "!", {
    Font = Enum.Font.GothamBold,
    TextColor = Color3.fromRGB(255, 255, 255),
    BackgroundColor = Color3.fromRGB(30, 30, 30)
})
MainTab:CreateLabel("Khóa của bạn: " .. getgenv().Key, {
    TextColor = Color3.fromRGB(150, 200, 255),
    Font = Enum.Font.GothamBold,
    Transparency = 0.5
})

MainTab:CreateButton("Kích Hoạt Tính Năng Cao Cấp", function()
    print("Tính năng cao cấp đã được kích hoạt!")
    Library:Notify("Tính Năng Đã Kích Hoạt!", 3, "Thành Công", {
        Color = Color3.fromRGB(0, 255, 100)
    })
    -- Thêm chức năng script cao cấp tại đây
end, {
    Color = Color3.fromRGB(0, 170, 255),
    HoverColor = Color3.fromRGB(0, 200, 255),
    TextColor = Color3.fromRGB(255, 255, 255),
    BorderColor = Color3.fromRGB(0, 100, 200),
    Animation = "Fade"
})

MainTab:CreateToggle("Tự Động Kích Hoạt", false, function(state)
    print("Tự động kích hoạt được đặt thành: " .. tostring(state))
    Library:Notify("Tự Động Kích Hoạt: " .. (state and "Bật" or "Tắt"), 2, "Thông Tin")
    -- Thêm logic tự động kích hoạt tại đây
end, {
    EnabledColor = Color3.fromRGB(0, 255, 100),
    DisabledColor = Color3.fromRGB(100, 100, 100),
    Animation = "Slide"
})

MainTab:CreateSlider("Cường Độ Tính Năng", 0, 100, 50, function(value)
    print("Cường độ tính năng được đặt thành: " .. value)
    Library:Notify("Cường độ: " .. value, 2, "Thông Tin")
    -- Thêm logic dựa trên cường độ tại đây
end, {
    Color = Color3.fromRGB(0, 120, 255),
    MarkerColor = Color3.fromRGB(255, 255, 255),
    Animation = "Smooth"
})

MainTab:CreateTextbox("Nhập Mã Tùy Chỉnh", "Nhập mã...", function(value)
    print("Mã tùy chỉnh: " .. value)
    Library:Notify("Đã nhập mã: " .. value, 3, "Thành Công")
end, {
    Color = Color3.fromRGB(50, 50, 50),
    TextColor = Color3.fromRGB(200, 200, 200),
    PlaceholderColor = Color3.fromRGB(150, 150, 150)
})

-- Tab Cài Đặt với các tính năng bổ sung
local SettingsTab = Window:CreateTab("Cài Đặt", "rbxasset://textures/ui/Settings.png")
SettingsTab:CreateSection("Quản Lý Tài Khoản", {
    Font = Enum.Font.GothamBold,
    TextColor = Color3.fromRGB(255, 255, 255)
})
SettingsTab:CreateButton("Đăng Xuất", function()
    LocalPlayer:Kick("Đã đăng xuất. Vui lòng khởi động lại script với khóa mới.")
end, {
    Color = Color3.fromRGB(255, 50, 50),
    HoverColor = Color3.fromRGB(255, 100, 100),
    TextColor = Color3.fromRGB(255, 255, 255),
    Animation = "Fade"
})

SettingsTab:CreateDropdown("Giao Diện", {"Tối", "Sáng", "Neon"}, "Tối", function(theme)
    local themeMap = {["Tối"] = "Dark", ["Sáng"] = "Light", ["Neon"] = "Neon"}
    Library:SetTheme(themeMap[theme])
    Library:Notify("Giao diện đã đổi thành " .. theme, 3, "Thông Tin")
end, {
    Color = Color3.fromRGB(50, 50, 50),
    TextColor = Color3.fromRGB(200, 200, 200),
    Animation = "Drop"
})

SettingsTab:CreateButton("Kiểm Tra Kết Nối API", function()
    local isValid, message = verifyKey(getgenv().Key)
    Library:Notify(isValid and "Kết nối API thành công!" or "Kết nối API thất bại: " .. message, 4, isValid and "Thành Công" or "Lỗi")
end, {
    Color = Color3.fromRGB(0, 150, 150),
    HoverColor = Color3.fromRGB(0, 180, 180),
    TextColor = Color3.fromRGB(255, 255, 255)
})

-- Khởi tạo Giao Diện với hiệu ứng động
Library:Notify("Trung Tâm Script Cao Cấp Đã Tải", 5, "Thành Công", {
    Animation = "FadeIn",
    Color = Color3.fromRGB(0, 255, 100)
})
Window:SelectTab(MainTab)
for _, element in pairs(Window:GetElements()) do
    element.Transparency = 1
    animateElement(element)
end