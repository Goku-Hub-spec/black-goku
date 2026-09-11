-- ==========================================
-- GOKU BLACK | Block Spin (Premium Custom Edition)
-- Created by Luis Dev
-- ==========================================
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer or Players.PlayerAdded:Wait()
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local Camera = Workspace.CurrentCamera
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local UserInputService = game:GetService("UserInputService")
local SoundService = game:GetService("SoundService")

local WindUI = loadstring(game:HttpGet("https://github.com"))()

local Window = WindUI:CreateWindow({
    Title = "GOKU BLACK | Block Spin",
    Icon = "rbxassetid://72957354226500",
    Size = UDim2.fromOffset(480, 360),
    Theme = "Indigo",
    Acrylic = true,
    Transparent = false,
})

local TabMain = Window:Tab({ Title = "MAIN", Icon = "house" })
local TabCombat = Window:Tab({ Title = "COMBAT", Icon = "crosshair" })
local TabPlayer = Window:Tab({ Title = "PLAYER", Icon = "user" })
local TabVisual = Window:Tab({ Title = "VISUAL", Icon = "eye" })

-- ==========================================
-- HUB INFO (MAIN TAB)
-- ==========================================
TabMain:Section({ Title = "Hub Information" })
TabMain:Paragraph({
    Title = "Created by Luis Dev",
    Desc = "GOKU BLACK - Block Spin Custom Edition",
})

TabMain:Section({ Title = "Hub Utilities" })
local enabledSkip = false
TabMain:Toggle({
    Title = "Crate Skip (Fast Open)",
    Default = false,
    Callback = function(state)
        enabledSkip = state
    end
})

task.spawn(function()
    while true do
        if enabledSkip then
            pcall(function()
                local modules = ReplicatedStorage:FindFirstChild("Modules")
                local crateMod = modules and modules:FindFirstChild("Game") and modules.Game:FindFirstChild("CrateSystem") and modules.Game.CrateSystem:FindFirstChild("Crate")
                if crateMod then
                    local CrateController = require(crateMod)
                    if CrateController and CrateController.class and CrateController.class.objects then
                        for _, crate in pairs(CrateController.class.objects) do
                            if crate.states and crate.states.open then crate.states.open.set(true) end
                            if CrateController.skipping and CrateController.skipping.set then CrateController.skipping.set(true) end
                        end
                    end
                end
            end)
            task.wait(0.1)
        else
            task.wait(1)
        end
    end
end)

-- ==========================================
-- ADVANCED COMBAT (SILENT AIM & NO RECOIL)
-- ==========================================
local fovLines = {}
local fovEnabled = false
local fovRadius = 120
local numLines = 16
local SilentAimEnabled = false
local CurrentLockedTarget = nil

pcall(function()
    if Drawing and Drawing.new then
        for i = 1, numLines do
            local line = Drawing.new("Line")
            line.Visible = false
            line.Thickness = 2
            table.insert(fovLines, line)
        end
    end
end)

local function getClosestPlayerInFOV()
    local bestTarget = nil
    local shortestDist = 999999
    local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    
    for _, pl in ipairs(Players:GetPlayers()) do
        if pl ~= LocalPlayer and pl.Character and pl.Character:FindFirstChild("Head") then
            local hum = pl.Character:FindFirstChild("Humanoid")
            if hum and hum.Health > 0 then
                local screenPos, onScreen = Camera:WorldToViewportPoint(pl.Character.Head.Position)
                if onScreen then
                    local screenDist = (Vector2.new(screenPos.X, screenPos.Y) - center).Magnitude
                    if screenDist <= fovRadius and screenDist < shortestDist then
                        shortestDist = screenDist
                        bestTarget = pl
                    end
                end
            end
        end
    end
    return bestTarget
end

-- HOOK DE REMOTOS ASIGNADO CORRECTAMENTE CON ÍNDICES FIJOS
local RemoteFolder = ReplicatedStorage:FindFirstChild("Remotes")
local SendRemote = RemoteFolder and RemoteFolder:FindFirstChild("Send")
if SendRemote and hookfunction then
    local originalFireServer
    originalFireServer = hookfunction(SendRemote.FireServer, function(self, ...)
        if self ~= SendRemote then return originalFireServer(self, ...) end
        local args = {...}
        if SilentAimEnabled and args[2] == "shoot_gun" and CurrentLockedTarget and CurrentLockedTarget.Character then
            local hitPart = CurrentLockedTarget.Character:FindFirstChild("Head") or CurrentLockedTarget.Character:FindFirstChild("HumanoidRootPart")
            local myHead = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Head")
            if hitPart and myHead then
                args[4] = CFrame.new(myHead.Position, hitPart.Position)
                args[5] = {
                    [1] = {
                        [1] = {
                            Instance = hitPart,
                            Normal = Vector3.new(0, 1, 0),
                            Position = hitPart.Position
                        }
                    }
                }
            end
        end
        return originalFireServer(self, unpack(args))
    end)
end

RunService.RenderStepped:Connect(function()
    local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    if fovEnabled and #fovLines > 0 then
        local timeVal = tick() * 0.6
        for i, line in ipairs(fovLines) do
            local angle1 = math.rad((i - 1) * (360 / numLines))
            local angle2 = math.rad(i * (360 / numLines))
            line.From = center + Vector2.new(math.cos(angle1), math.sin(angle1)) * fovRadius
            line.To = center + Vector2.new(math.cos(angle2), math.sin(angle2)) * fovRadius
            line.Color = Color3.fromHSV((timeVal + (i / numLines)) % 1, 1, 1)
            line.Visible = true
        end
    else
        for _, line in ipairs(fovLines) do line.Visible = false end
    end
    CurrentLockedTarget = SilentAimEnabled and getClosestPlayerInFOV() or nil
end)

TabCombat:Section({ Title = "Targeting" })
TabCombat:Toggle({
    Title = "Enable Silent Aim",
    Default = false,
    Callback = function(state) SilentAimEnabled = state end
})
TabCombat:Toggle({
    Title = "Show Rainbow FOV Circle",
    Default = false,
    Callback = function(state) fovEnabled = state end
})
TabCombat:Slider({
    Title = "Field of View Size",
    Step = 5,
    Value = { Min = 30, Max = 300, Default = 120 },
    Callback = function(value) fovRadius = value end
})

-- ==========================================
-- PLAYER MECHANICS (STAMINA & SPEED)
-- ==========================================
TabPlayer:Section({ Title = "Stamina & Movement" })

local InfStaminaEnabled = false
local OriginalSprintUpdate = nil
TabPlayer:Toggle({
    Title = "Infinite Stamina",
    Default = false,
    Callback = function(enable)
        InfStaminaEnabled = enable
        pcall(function()
            local success, sprintModule = pcall(function() return require(ReplicatedStorage.Modules.Game.Sprint) end)
            if success and sprintModule then
                local upvals = getupvalues(sprintModule.consume_stamina)
                local sprintBar
                for _, uv in ipairs(upvals) do
                    if type(uv) == "table" and rawget(uv, "sprint_bar") then
                        sprintBar = uv.sprint_bar
                        break
                    end
                end
                if sprintBar then
                    if enable then
                        OriginalSprintUpdate = sprintBar.update
                        sprintBar.update = function(...) return OriginalSprintUpdate(function() return 1 end) end
                    else
                        if OriginalSprintUpdate then sprintBar.update = OriginalSprintUpdate end
                    end
                end
            end
        end)
    end
})

local SpeedHackEnabled = false
local SpeedValue = 4
TabPlayer:Toggle({
    Title = "Enable Speed Modification",
    Default = false,
    Callback = function(state) SpeedHackEnabled = state end
})
TabPlayer:Slider({
    Title = "Velocity Mult (Max 20)",
    Step = 1,
    Value = { Min = 1, Max = 20, Default = 4 },
    Callback = function(value) SpeedValue = value end
})

RunService.RenderStepped:Connect(function(dt)
    if SpeedHackEnabled and LocalPlayer.Character then
        local hum = LocalPlayer.Character:FindFirstChild("Humanoid")
        local root = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if hum and root and hum.MoveDirection.Magnitude > 0 then
            root.CFrame = root.CFrame + (hum.MoveDirection.Unit * ((SpeedValue / 20) * 1.8 * 14 * dt))
        end
    end
end)

-- ==========================================
-- VISUALS & FRIEND TRACKING
-- ==========================================
TabVisual:Section({ Title = "Tracking & ESP" })

local trackedFriends = {}
local namesESPEnabled = false

local function updateFriendList()
    table.clear(trackedFriends)
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and LocalPlayer:IsFriendsWith(player.UserId) then
            table.insert(trackedFriends, player.Name)
        end
    end
end

TabVisual:Toggle({
    Title = "Active Player Names ESP",
    Default = false,
    Callback = function(state)
        namesESPEnabled = state
        for _, p in ipairs(Players:GetPlayers()) do
Usa el código con precaución.if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("Head") thenlocal currentEsp = p.Character.Head:FindFirstChild("FriendBillboard")if currentEsp then currentEsp:Destroy() endif state thenlocal isFriend = LocalPlayer:IsFriendsWith(p.UserId)local billboard = Instance.new("BillboardGui", p.Character.Head)billboard.Name = "FriendBillboard"billboard.Size = UDim2.new(0, 150, 0, 30)billboard.AlwaysOnTop = truebillboard.StudsOffset = Vector3.new(0, 2, 0)local label = Instance.new("TextLabel", billboard)label.Size = UDim2.new(1, 0, 1, 0)label.BackgroundTransparency = 1label.Text = p.Name .. (isFriend and " [FRIEND]" or "")label.TextColor3 = isFriend and Color3.fromRGB(0, 255, 120) or Color3.fromRGB(255, 255, 255)label.Font = Enum.Font.GothamBoldlabel.TextSize = 12endendendend})TabVisual:Section({ Title = "Your Network Friends" })Players.PlayerAdded:Connect(updateFriendList)Players.PlayerRemoving:Connect(updateFriendList)updateFriendList()task.spawn(function()task.wait(1)print("--- [GOKU BLACK] Amigos Conectados ---")if #trackedFriends == 0 then print("Ninguno") elsefor _, name in ipairs(trackedFriends) do print("- " .. name) endendend)WindUI:Notify({Title = "GOKU BLACK | Luis Dev Edition",Content = "Menú seguro y modificado cargado de forma independiente.",Duration = 4})
