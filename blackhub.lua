--// ÁRABE HUB
--// WindUI

local WindUI = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"
))()

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer

--// WINDOW
local Window = WindUI:CreateWindow({
    Title = "Árabe Hub",
    Icon = "star",
    Theme = "Dark",

    Topbar = {
        Height = 44,
        ButtonsType = "Mac",
    },

    OpenButton = {
        Enabled = false,
    },
})

--// BOTÓN FLOTANTE
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ArabeHubFloatingButton"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = CoreGui

local FloatButton = Instance.new("ImageButton")
FloatButton.Name = "OpenCloseButton"
FloatButton.Size = UDim2.fromOffset(50, 50)
FloatButton.Position = UDim2.new(0, 20, 0.5, -25)
FloatButton.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
FloatButton.BackgroundTransparency = 0.05
FloatButton.Image = "rbxassetid://132693337850412"
FloatButton.ImageTransparency = 0
FloatButton.ScaleType = Enum.ScaleType.Crop
FloatButton.AutoButtonColor = false
FloatButton.ZIndex = 100
FloatButton.Parent = ScreenGui

local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(0, 13)
Corner.Parent = FloatButton

local Stroke = Instance.new("UIStroke")
Stroke.Color = Color3.fromRGB(180, 25, 40)
Stroke.Thickness = 2
Stroke.Transparency = 0.15
Stroke.Parent = FloatButton

--// ABRIR / CERRAR
FloatButton.MouseButton1Click:Connect(function()
    Window:Toggle()
end)

--// ARRASTRAR BOTÓN
local dragging = false
local dragStart
local startPos

FloatButton.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then

        dragging = true
        dragStart = input.Position
        startPos = FloatButton.Position

        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if not dragging then
        return
    end

    if input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch then

        local delta = input.Position - dragStart

        FloatButton.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end
end)

--// GENERAL
local GeneralTab = Window:Tab({
    Title = "General",
    Icon = "home",
})

GeneralTab:Section({
    Title = "Árabe Hub",
})

--// COMBAT
local CombatTab = Window:Tab({
    Title = "Combat",
    Icon = "swords",
})

CombatTab:Section({
    Title = "Combat",
})

--// FOV CIRCLE
local FOVEnabled = false
local FOVPercent = 50

local FOVGui = Instance.new("ScreenGui")
FOVGui.Name = "ArabeHubFOV"
FOVGui.ResetOnSpawn = false
FOVGui.IgnoreGuiInset = true
FOVGui.Enabled = false
FOVGui.Parent = CoreGui

local FOVCircle = Instance.new("Frame")
FOVCircle.Name = "FOVCircle"
FOVCircle.AnchorPoint = Vector2.new(0.5, 0.5)
FOVCircle.Position = UDim2.fromScale(0.5, 0.5)
FOVCircle.Size = UDim2.fromOffset(275, 275)
FOVCircle.BackgroundTransparency = 1
FOVCircle.Parent = FOVGui

local FOVCorner = Instance.new("UICorner")
FOVCorner.CornerRadius = UDim.new(1, 0)
FOVCorner.Parent = FOVCircle

local FOVStroke = Instance.new("UIStroke")
FOVStroke.Thickness = 2
FOVStroke.Transparency = 0.15
FOVStroke.Color = Color3.fromRGB(255, 255, 255)
FOVStroke.Parent = FOVCircle

local function UpdateFOV()
    local size = 50 + (FOVPercent * 4.5)
    FOVCircle.Size = UDim2.fromOffset(size, size)
end

UpdateFOV()

CombatTab:Toggle({
    Title = "FOV Circle",
    Desc = "Muestra un círculo de FOV en el centro.",
    Value = false,

    Callback = function(Value)
        FOVEnabled = Value
        FOVGui.Enabled = Value

        WindUI:Notify({
            Title = "FOV Circle",
            Content = Value and "Activado." or "Desactivado.",
            Duration = 3,
        })
    end,
})

CombatTab:Slider({
    Title = "FOV",
    Desc = "Tamaño del círculo.",
    Step = 1,

    Value = {
        Min = 1,
        Max = 100,
        Default = 50,
    },

    Callback = function(Value)
        FOVPercent = Value
        UpdateFOV()
    end,
})

--// PLAYER
local PlayerTab = Window:Tab({
    Title = "Player",
    Icon = "user",
})

PlayerTab:Section({
    Title = "Player",
})

--// DISTANCIA
local DistanceEnabled = false
local DistanceLabels = {}
local DistanceConnection

local function RemoveDistance(player)
    if DistanceLabels[player] then
        DistanceLabels[player]:Destroy()
        DistanceLabels[player] = nil
    end
end

local function CreateDistance(player)
    if player == LocalPlayer then
        return
    end

    local character = player.Character
    if not character then
        return
    end

    local root = character:FindFirstChild("HumanoidRootPart")
    if not root then
        return
    end

    RemoveDistance(player)

    local billboard = Instance.new("BillboardGui")
    billboard.Name = "DistanceDisplay"
    billboard.Adornee = root
    billboard.Size = UDim2.fromOffset(120, 30)
    billboard.StudsOffset = Vector3.new(0, 3.5, 0)
    billboard.AlwaysOnTop = true
    billboard.Parent = root

    local label = Instance.new("TextLabel")
    label.BackgroundTransparency = 1
    label.Size = UDim2.fromScale(1, 1)
    label.TextScaled = true
    label.Font = Enum.Font.GothamBold
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.Text = "0 m"
    label.Parent = billboard

    DistanceLabels[player] = billboard
end

local function UpdateDistances()
    if not DistanceEnabled then
        return
    end

    local myCharacter = LocalPlayer.Character
    local myRoot = myCharacter
        and myCharacter:FindFirstChild("HumanoidRootPart")

    if not myRoot then
        return
    end

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then

            local character = player.Character
            local root = character
                and character:FindFirstChild("HumanoidRootPart")

            if root then

                if not DistanceLabels[player] then
                    CreateDistance(player)
                end

                local billboard = DistanceLabels[player]

                if billboard then

                    local label =
                        billboard:FindFirstChildOfClass("TextLabel")

                    if label then

                        local distance =
                            (myRoot.Position - root.Position).Magnitude

                        label.Text = string.format(
                            "%d m",
                            math.floor(distance + 0.5)
                        )
                    end
                end

            else
                RemoveDistance(player)
            end
        end
    end
end

local function SetDistance(enabled)

    DistanceEnabled = enabled

    if enabled then

        for _, player in ipairs(Players:GetPlayers()) do
            CreateDistance(player)
        end

        if not DistanceConnection then
            DistanceConnection =
                RunService.RenderStepped:Connect(UpdateDistances)
        end

        WindUI:Notify({
            Title = "Distancia",
            Content = "Distancia activada.",
            Duration = 3,
        })

    else

        for player in pairs(DistanceLabels) do
            RemoveDistance(player)
        end

        if DistanceConnection then
            DistanceConnection:Disconnect()
            DistanceConnection = nil
        end

        WindUI:Notify({
            Title = "Distancia",
            Content = "Distancia desactivada.",
            Duration = 3,
        })
    end
end

Players.PlayerRemoving:Connect(function(player)
    RemoveDistance(player)
end)

Players.PlayerAdded:Connect(function(player)

    player.CharacterAdded:Connect(function()

        if DistanceEnabled then
            task.wait(0.5)
            CreateDistance(player)
        end

    end)

end)

PlayerTab:Section({
    Title = "Visual",
})

PlayerTab:Toggle({
    Title = "Distancia",
    Desc = "Muestra la distancia de cada jugador en metros.",
    Value = false,

    Callback = function(Value)
        SetDistance(Value)
    end,
})

--// SETTINGS
local SettingsTab = Window:Tab({
    Title = "Settings",
    Icon = "settings",
})

SettingsTab:Section({
    Title = "Performance",
})

--// FPS BOOSTER
local FPSBoostEnabled = false

local SavedLighting = {
    GlobalShadows = Lighting.GlobalShadows,
    FogEnd = Lighting.FogEnd,
    Brightness = Lighting.Brightness,
}

local SavedEffects = {}

local function SetFPSBoost(enabled)

    FPSBoostEnabled = enabled

    if enabled then

        Lighting.GlobalShadows = false
        Lighting.FogEnd = 100000
        Lighting.Brightness = 1

        for _, obj in ipairs(Workspace:GetDescendants()) do

            if obj:IsA("ParticleEmitter")
                or obj:IsA("Trail")
                or obj:IsA("Beam")
                or obj:IsA("Smoke")
                or obj:IsA("Fire") then

                if SavedEffects[obj] == nil then
                    SavedEffects[obj] = obj.Enabled
                end

                obj.Enabled = false
            end
        end

        WindUI:Notify({
            Title = "FPS Booster",
            Content = "Optimización visual activada.",
            Duration = 3,
        })

    else

        Lighting.GlobalShadows = SavedLighting.GlobalShadows
        Lighting.FogEnd = SavedLighting.FogEnd
        Lighting.Brightness = SavedLighting.Brightness

        for obj, state in pairs(SavedEffects) do

            if obj and obj.Parent then
                obj.Enabled = state
            end
        end

        SavedEffects = {}

        WindUI:Notify({
            Title = "FPS Booster",
            Content = "Optimización visual desactivada.",
            Duration = 3,
        })
    end
end

SettingsTab:Toggle({
    Title = "FPS Booster",
    Desc = "Reduce efectos visuales para mejorar el rendimiento.",
    Value = false,

    Callback = function(Value)
        SetFPSBoost(Value)
    end,
})
