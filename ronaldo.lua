-- Tải thư viện Kavo UI
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()

-- Tạo giao diện UI với theme màu đỏ
local Window = Library.CreateLib("BloodTheme")

-- Tạo tab chính
local Tab = Window:NewTab("Main")

-- Tạo section chính
local Section = Tab:NewSection("Chức năng chính")

-- Nhảy Cao
Section:NewSlider("Nhảy Cao", "Điều chỉnh độ cao nhảy của bạn", 250, 50, function(v)
    game.Players.LocalPlayer.Character.Humanoid.JumpPower = v
end)

-- Chạy Nhanh
Section:NewSlider("Chạy Nhanh", "Điều chỉnh tốc độ chạy của bạn", 200, 16, function(v)
    game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = v
end)

-- Bật ESP (Xuyên tường để thấy người chơi khác)
Section:NewButton("Bật ESP", "Hiển thị người chơi khác qua tường", function()
    local function createESP(player)
        local highlight = Instance.new("Highlight")
        highlight.Parent = player.Character
        highlight.FillColor = Color3.new(1, 0, 0) -- Màu đỏ
        highlight.OutlineColor = Color3.new(1, 1, 1) -- Màu trắng
        highlight.FillTransparency = 0.5 -- Độ trong suốt
    end

    for _, player in pairs(game.Players:GetPlayers()) do
        if player ~= game.Players.LocalPlayer then
            createESP(player)
        end
    end

    game.Players.PlayerAdded:Connect(function(player)
        createESP(player)
    end)
end)

-- Bật No Clip (Xuyên tường)
local noClipEnabled = false
Section:NewToggle("No Clip (Xuyên Tường)", "Bật/Tắt khả năng xuyên qua tường", function(state)
    noClipEnabled = state
end)

-- Hàm No Clip
game:GetService("RunService").Stepped:Connect(function()
    if noClipEnabled then
        local character = game.Players.LocalPlayer.Character
        for _, v in pairs(character:GetDescendants()) do
            if v:IsA("BasePart") and v.CanCollide then
                v.CanCollide = false -- Cho phép xuyên qua tường
            end
        end
    end
end)

-- Thêm tính năng bất tử
Section:NewToggle("Bất Tử", "Bật/Tắt khả năng bất tử", function(state)
    local player = game.Players.LocalPlayer
    local character = player.Character or player.CharacterAdded:Wait()
    local humanoid = character:WaitForChild("Humanoid")
    
    if state then
        -- Đảm bảo nhân vật luôn đầy máu
        humanoid:GetPropertyChangedSignal("Health"):Connect(function()
            if humanoid.Health < humanoid.MaxHealth then
                humanoid.Health = humanoid.MaxHealth -- Luôn hồi máu về mức tối đa
            end
        end)
    else
        humanoid.Health = humanoid.MaxHealth -- Về mặc định khi tắt bất tử
    end
end)

-- Anti-Detection cơ bản (Giảm thiểu nguy cơ bị phát hiện)
local function antiDetection()
    -- Tắt các log liên quan đến hành vi gian lận
    local mt = getrawmetatable(game)
    setreadonly(mt, false)
    local oldNamecall = mt.__namecall
    mt.__namecall = newcclosure(function(self, ...)
        local method = getnamecallmethod()
        local args = {...}
        if tostring(self) == "LogService" or tostring(self) == "MessageLogService" then
            return nil -- Không cho phép ghi log lại
        end
        return oldNamecall(self, unpack(args))
    end)
end

-- Kích hoạt Anti-Detection và thêm vào UI
Section:NewButton("Anti Ban", "Kích hoạt chức năng chống bị phát hiện", function()
    antiDetection()
end)

-- Dropdown Troll Người Chơi
local TrollDropdown = Section:NewDropdown("Troll Người Chơi", "Chọn người chơi để troll", {}, function(selected)
    local player = game.Players:FindFirstChild(selected)
    if player and player.Character and player.Character:FindFirstChild("Humanoid") then
        player.Character.Humanoid.Health = 0 -- Giảm máu về 0, khiến họ "chết"
    end
end)

-- Cập nhật danh sách người chơi vào dropdown Troll
game.Players.PlayerAdded:Connect(function(player)
    TrollDropdown:Add(player.Name)
end)

game.Players.PlayerRemoving:Connect(function(player)
    TrollDropdown:Remove(player.Name)
end)

-- No Clip vẫn giữ nguyên trong phần chạy dịch vụ
