-- ============================================
-- Chilli Hub 2.0 - Steal An Egg (Delta Fixed)
-- ============================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
local Humanoid = Character:WaitForChild("Humanoid")

local Config = {
    ESP = true,
    AutoSteal = false,
    SpeedBoost = false,
    SpeedValue = 28,
    InfJump = false,
    AntiRagdoll = true,
    StealDelay = 0.45,
}

local function forceParent()
    local tries = {}
    pcall(function() if gethui then table.insert(tries, gethui()) end end)
    pcall(function() table.insert(tries, CoreGui) end)
    pcall(function()
        table.insert(tries, LocalPlayer:FindFirstChild("PlayerGui") or LocalPlayer:WaitForChild("PlayerGui", 2))
    end)
    for _, p in pairs(tries) do
        if p then return p end
    end
    return LocalPlayer:WaitForChild("PlayerGui")
end

local parent = forceParent()

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ChilliHub2"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.DisplayOrder = 999
ScreenGui.Parent = parent

pcall(function()
    if syn and syn.protect_gui then syn.protect_gui(ScreenGui) end
    if protect_gui then protect_gui(ScreenGui) end
end)

local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 260, 0, 380)
Main.Position = UDim2.new(0.5, -130, 0.5, -190)
Main.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
Main.BorderSizePixel = 0
Main.Active = true
Main.Draggable = true
Main.Parent = ScreenGui

Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 10)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 36)
Title.BackgroundColor3 = Color3.fromRGB(28, 28, 34)
Title.Text = "  Chilli Hub 2.0"
Title.TextColor3 = Color3.fromRGB(255, 90, 90)
Title.TextSize = 16
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Main
Instance.new("UICorner", Title).CornerRadius = UDim.new(0, 10)

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 36, 0, 36)
CloseBtn.Position = UDim2.new(1, -36, 0, 0)
CloseBtn.BackgroundTransparency = 1
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
CloseBtn.TextSize = 18
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.Parent = Main
CloseBtn.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

local Scrolling = Instance.new("ScrollingFrame")
Scrolling.Size = UDim2.new(1, -12, 1, -48)
Scrolling.Position = UDim2.new(0, 6, 0, 42)
Scrolling.BackgroundTransparency = 1
Scrolling.ScrollBarThickness = 3
Scrolling.CanvasSize = UDim2.new(0, 0, 0, 420)
Scrolling.Parent = Main

local List = Instance.new("UIListLayout")
List.Padding = UDim.new(0, 6)
List.Parent = Scrolling

local function makeToggle(name, default, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 34)
    frame.BackgroundColor3 = Color3.fromRGB(28, 28, 34)
    frame.Parent = Scrolling
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 6)

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -55, 1, 0)
    label.Position = UDim2.new(0, 10, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = name
    label.TextColor3 = Color3.fromRGB(230, 230, 230)
    label.TextSize = 13
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 42, 0, 22)
    btn.Position = UDim2.new(1, -50, 0.5, -11)
    btn.BackgroundColor3 = default and Color3.fromRGB(80, 200, 120) or Color3.fromRGB(60, 60, 70)
    btn.Text = default and "ON" or "OFF"
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.TextSize = 11
    btn.Font = Enum.Font.GothamBold
    btn.Parent = frame
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 5)

    local state = default
    btn.MouseButton1Click:Connect(function()
        state = not state
        btn.Text = state and "ON" or "OFF"
        btn.BackgroundColor3 = state and Color3.fromRGB(80, 200, 120) or Color3.fromRGB(60, 60, 70)
        callback(state)
    end)
end

local function makeButton(name, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 34)
    btn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    btn.Text = name
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.TextSize = 13
    btn.Font = Enum.Font.Gotham
    btn.Parent = Scrolling
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    btn.MouseButton1Click:Connect(callback)
end

local espFolder = Instance.new("Folder")
espFolder.Name = "ChilliESP"
espFolder.Parent = workspace

local function clearESP()
    for _, v in pairs(espFolder:GetChildren()) do
        v:Destroy()
    end
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj.Name == "ChilliHighlight" then
            obj:Destroy()
        end
    end
end

local function getEggs()
    local eggs = {}
    for _, obj in pairs(workspace:GetDescendants()) do
        local name = string.lower(obj.Name)
        if (obj:IsA("Model") or obj:IsA("BasePart")) and string.find(name, "egg") and not string.find(name, "pet") then
            table.insert(eggs, obj)
        end
    end
    return eggs
end

local function createESP(egg)
    if egg:FindFirstChild("ChilliHighlight") then return end
    local part = egg:IsA("BasePart") and egg or egg:FindFirstChildWhichIsA("BasePart")
    if not part then return end

    local hl = Instance.new("Highlight")
    hl.Name = "ChilliHighlight"
    hl.Adornee = egg
    hl.FillColor = Color3.fromRGB(255, 80, 80)
    hl.OutlineColor = Color3.fromRGB(255, 255, 255)
    hl.FillTransparency = 0.55
    hl.Parent = egg

    local bill = Instance.new("BillboardGui")
    bill.Size = UDim2.new(0, 100, 0, 24)
    bill.StudsOffset = Vector3.new(0, 2.8, 0)
    bill.AlwaysOnTop = true
    bill.Adornee = part
    bill.Parent = espFolder

    local txt = Instance.new("TextLabel")
    txt.Size = UDim2.new(1, 0, 1, 0)
    txt.BackgroundTransparency = 1
    txt.Text = egg.Name
    txt.TextColor3 = Color3.fromRGB(255, 220, 100)
    txt.TextStrokeTransparency = 0.4
    txt.TextSize = 11
    txt.Font = Enum.Font.GothamBold
    txt.Parent = bill
end

local function flyTo(pos)
    if not HumanoidRootPart then return end
    local start = HumanoidRootPart.Position
    local dist = (pos - start).Magnitude
    local time = math.clamp(dist / 85, 0.1, 0.5)
    local t = 0
    local conn
    conn = RunService.Heartbeat:Connect(function(dt)
        t = t + dt
        local alpha = math.min(t / time, 1)
        if HumanoidRootPart then
            HumanoidRootPart.CFrame = CFrame.new(start:Lerp(pos, alpha))
        end
        if alpha >= 1 then
            conn:Disconnect()
        end
    end)
    task.wait(time + 0.05)
end

local function trySteal(egg)
    local part = egg:IsA("BasePart") and egg or egg:FindFirstChildWhichIsA("BasePart")
    if not part then return end
    flyTo(part.Position + Vector3.new(0, 3.5, 0))
    pcall(function()
        local cd = egg:FindFirstChildWhichIsA("ClickDetector", true)
        if cd then fireclickdetector(cd) end
    end)
end

RunService.Heartbeat:Connect(function()
    if Config.SpeedBoost and Humanoid then
        Humanoid.WalkSpeed = Config.SpeedValue
    end
    if Config.AntiRagdoll and Humanoid then
        local state = Humanoid:GetState()
        if state == Enum.HumanoidStateType.Ragdoll or state == Enum.HumanoidStateType.Physics then
            Humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
        end
    end
end)

UserInputService.JumpRequest:Connect(function()
    if Config.InfJump and Humanoid then
        Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)

task.spawn(function()
    while task.wait(1.1) do
        if Config.ESP then
            clearESP()
            for _, egg in pairs(getEggs()) do
                createESP(egg)
            end
        else
            clearESP()
        end
    end
end)

task.spawn(function()
    while task.wait(0.4) do
        if Config.AutoSteal then
            for _, egg in pairs(getEggs()) do
                if not Config.AutoSteal then break end
                trySteal(egg)
                task.wait(Config.StealDelay)
            end
        end
    end
end)

LocalPlayer.CharacterAdded:Connect(function(char)
    Character = char
    HumanoidRootPart = char:WaitForChild("HumanoidRootPart")
    Humanoid = char:WaitForChild("Humanoid")
end)

makeToggle("ESP Ovos", true, function(v) Config.ESP = v end)
makeToggle("Auto Steal", false, function(v) Config.AutoSteal = v end)
makeToggle("Speed Boost", false, function(v) Config.SpeedBoost = v end)
makeToggle("Infinite Jump", false, function(v) Config.InfJump = v end)
makeToggle("Anti Ragdoll", true, function(v) Config.AntiRagdoll = v end)

makeButton("Server Hop", function()
    pcall(function()
        local data = HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?sortOrder=Asc&limit=50"))
        for _, s in pairs(data.data) do
            if s.playing < s.maxPlayers and s.id \~= game.JobId then
                TeleportService:TeleportToPlaceInstance(game.PlaceId, s.id)
                break
            end
        end
    end)
end)

makeButton("Rejoin", function()
    TeleportService:Teleport(game.PlaceId, LocalPlayer)
end)

print("[Chilli Hub 2.0] Carregado com sucesso")
