-- ==========================================
-- GOKU BLACK | Block Spin (WindUI Indigo + English + Rainbow FOV)
-- Created by eld0305
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

local THIN_FONT = Enum.Font.SourceSansLight
local BOLD_FONT = Enum.Font.SourceSansBold

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
-- CREATOR INFO (MAIN TAB HEADER)
-- ==========================================
TabMain:Section({ Title = "Hub Information" })
TabMain:Paragraph({
    Title = "Created by eld0305",
    Desc = "GOKU BLACK - Block Spin Edition",
})

-- ==========================================
-- 16-LINE RAINBOW FOV CIRCLE & SILENT AIM UTILS
-- ==========================================
local fovLines = {}
local fovEnabled = false
local fovRadius = 120
local numLines = 16

local SilentAimEnabled = false
local TargetHitPart = "Head"
local CurrentLockedTarget = nil

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "DMX_Visuals"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = CoreGui

local TargetTracerLine = Drawing.new("Line")
TargetTracerLine.Thickness = 1.2
TargetTracerLine.Color = Color3.fromRGB(255, 20, 50)
TargetTracerLine.Transparency = 0.8
TargetTracerLine.Visible = false

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

local RaycastParamsCache = RaycastParams.new()
RaycastParamsCache.FilterType = Enum.RaycastFilterType.Exclude
RaycastParamsCache.IgnoreWater = true

local function isInCarOrVehicle(char, targetPart)
    if not char then return false end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum and hum.SeatPart then return true end
    local parent = char.Parent
    while parent and parent ~= workspace do
        local pName = parent.Name:lower()
        if pName:find("vehicle") or pName:find("car") or pName:find("auto") or pName:find("moto") then
            return true
        end
        parent = parent.Parent
    end
    return false
end

local function isTargetVisibleOrInCar(targetPart)
    local char = LocalPlayer.Character
    local targetChar = targetPart and targetPart.Parent
    local head = char and char:FindFirstChild("Head")
    if not head or not targetPart or not targetChar then return false end

    if isInCarOrVehicle(targetChar, targetPart) then
        return true
    end

    local origin = head.Position
    local targetPos = targetPart.Position
    local direction = targetPos - origin

    RaycastParamsCache.FilterDescendantsInstances = {char, targetChar}
    local result = workspace:Raycast(origin, direction, RaycastParamsCache)

    if not result then
        return true
    else
        local hitPart = result.Instance
        if hitPart then
            local mat = hitPart.Material
            local name = hitPart.Name:lower()
            if mat == Enum.Material.Glass or name:find("glass") or name:find("window") or name:find("cristal") or name:find("vidrio") then
                RaycastParamsCache.FilterDescendantsInstances = {char, targetChar, hitPart}
                local secondResult = workspace:Raycast(result.Position + (direction.Unit * 0.5), targetPos - (result.Position + (direction.Unit * 0.5)), RaycastParamsCache)
                if not secondResult then return true end
            end
        end
        return false
    end
end

local VelocityCache = {}
RunService.Heartbeat:Connect(function()
    for _, pl in ipairs(Players:GetPlayers()) do
        if pl ~= LocalPlayer and pl.Character then
            local root = pl.Character:FindFirstChild("HumanoidRootPart")
            local hum = pl.Character:FindFirstChild("Humanoid")
            if root and hum and hum.Health > 0 then
                VelocityCache[pl] = VelocityCache[pl] or {}
                table.insert(VelocityCache[pl], {time = os.clock(), pos = root.Position})
                if #VelocityCache[pl] > 8 then table.remove(VelocityCache[pl], 1) end
            else
                VelocityCache[pl] = nil
            end
        end
    end
end)

local function getCalculatedVelocity(pl, rootPart)
    if rootPart and rootPart.AssemblyLinearVelocity.Magnitude > 22 then
        return rootPart.AssemblyLinearVelocity
    end
    local data = VelocityCache[pl]
    if not data or #data < 2 then return Vector3.zero end
    local vel = Vector3.zero
    local count = 0
    for i = 2, #data do
        local dt = data[i].time - data[i - 1].time
        if dt > 0 then
            vel = vel + (data[i].pos - data[i - 1].pos) / dt
            count = count + 1
        end
    end
    return count > 0 and (vel / count) or Vector3.zero
end

local function getPing()
    local pGui = LocalPlayer:FindFirstChild("PlayerGui")
    if pGui and pGui:FindFirstChild("NetworkStats") and pGui.NetworkStats:FindFirstChild("PingLabel") then
        local ms = tonumber(pGui.NetworkStats.PingLabel.Text:match("%d+"))
        if ms then return math.clamp(ms / 1000, 0.04, 1.2) end
    end
    return 0.08
end

local function predictTargetPos(targetPart)
    if not targetPart then return Vector3.zero end
    local char = targetPart.Parent
    local pl = char and Players:GetPlayerFromCharacter(char)
    if not pl then return targetPart.Position end
    local vel = getCalculatedVelocity(pl, char:FindFirstChild("HumanoidRootPart"))
    local ping = getPing()
    return targetPart.Position + (vel * (ping + 0.15) * 1.5)
end

local function getClosestPlayerInFOV()
    local bestTarget = nil
    local shortestDist = 999999
    local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    
    for _, pl in ipairs(Players:GetPlayers()) do
        if pl ~= LocalPlayer and pl.Character then
            local char = pl.Character
            local head = char:FindFirstChild("Head") or char:FindFirstChild("HumanoidRootPart")
            local hum = char:FindFirstChild("Humanoid")
            if head and hum and hum.Health > 0 then
                if isTargetVisibleOrInCar(head) then
                    local screenPos, onScreen = Camera:WorldToViewportPoint(head.Position)
                    if onScreen and screenPos.Z > 0 then
                        local screenDist = (Vector2.new(screenPos.X, screenPos.Y) - center).Magnitude
                        if screenDist <= fovRadius and screenDist < shortestDist then
                            shortestDist = screenDist
                            bestTarget = pl
                        end
                    end
                end
            end
        end
    end
    return bestTarget
end

-- Hook para Silent Aim con wallbang inteligente y alcance lejano
local RemoteFolder = ReplicatedStorage:FindFirstChild("Remotes")
local SendRemote = RemoteFolder and RemoteFolder:FindFirstChild("Send")
if SendRemote and hookfunction then
    local originalFireServer
    originalFireServer = hookfunction(SendRemote.FireServer, function(self, ...)
        if self ~= SendRemote then return originalFireServer(self, ...) end
        local args = {...}
        
        if SilentAimEnabled and args[2] == "shoot_gun" and CurrentLockedTarget then
            local targetChar = CurrentLockedTarget.Character
            local hitPart = targetChar and (targetChar:FindFirstChild("Head") or targetChar:FindFirstChild("HumanoidRootPart"))
            local myHead = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Head")
            
            if hitPart and myHead and isTargetVisibleOrInCar(hitPart) then
                local predPos = predictTargetPos(hitPart)
                local startOrigin = myHead.Position
                
                args[4] = CFrame.new(startOrigin, predPos)
                args[5] = {
                    [1] = {
                        [1] = {
                            Instance = hitPart,
                            Normal = Vector3.new(0, 1, 0),
                            Position = predPos
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
        pcall(function()
            local timeVal = tick() * 0.6
            for i, line in ipairs(fovLines) do
                local angle1 = math.rad((i - 1) * (360 / numLines))
                local angle2 = math.rad(i * (360 / numLines))
                
                local p1 = center + Vector2.new(math.cos(angle1), math.sin(angle1)) * fovRadius
                local p2 = center + Vector2.new(math.cos(angle2), math.sin(angle2)) * fovRadius
Usa el código con precaución.line.From = p1line.To = p2local hue = (timeVal + (i / numLines)) % 1line.Color = Color3.fromHSV(hue, 1, 1)line.Visible = trueendend)elsefor _, line in ipairs(fovLines) doline.Visible = falseendendCurrentLockedTarget = SilentAimEnabled and getClosestPlayerInFOV() or nilif CurrentLockedTarget and CurrentLockedTarget.Character and CurrentLockedTarget.Character:FindFirstChild("HumanoidRootPart") thenlocal tPos, tOn = Camera:WorldToViewportPoint(CurrentLockedTarget.Character.HumanoidRootPart.Position)if tOn and tPos.Z > 0 thenTargetTracerLine.From = centerTargetTracerLine.To = Vector2.new(tPos.X, tPos.Y)TargetTracerLine.Visible = trueelseTargetTracerLine.Visible = falseendelseTargetTracerLine.Visible = falseendend)TabCombat:Section({ Title = "Silent Aim & FOV" })TabCombat:Toggle({Title = "Enable Silent Aim",Default = false,Callback = function(state)SilentAimEnabled = stateWindUI:Notify({ Title = "GOKU BLACK", Content = state and "Silent Aim ENABLED" or "Silent Aim DISABLED", Duration = 1.5 })end})TabCombat:Toggle({Title = "Enable Rainbow FOV",Default = false,Callback = function(state)fovEnabled = stateend})TabCombat:Slider({Title = "FOV Radius",Step = 5,Value = { Min = 30, Max = 300, Default = 120 },Callback = function(value)fovRadius = valueend})-- ==========================================-- GUN OPTIONS (NO RECOIL)-- ==========================================TabCombat:Section({ Title = "Gun Options" })local noRecoilEnabled = falseTabCombat:Toggle({Title = "No Recoil / Spread",Default = false,Callback = function(state)noRecoilEnabled = stateWindUI:Notify({ Title = "GOKU BLACK", Content = state and "No Recoil ENABLED" or "No Recoil DISABLED", Duration = 1.5 })end})task.spawn(function()while true doif noRecoilEnabled thenpcall(function()local char = LocalPlayer.Characterlocal backpack = LocalPlayer:FindFirstChild("Backpack")if char thenfor _, tool in ipairs(char:GetChildren()) doif tool:IsA("Tool") thenfor _, v in ipairs(tool:GetDescendants()) doif (v:IsA("NumberValue") or v:IsA("IntValue")) and (v.Name:lower():find("recoil") or v.Name:lower():find("spread") or v.Name:lower():find("shake")) thenv.Value = 0endendendendendif backpack thenfor _, tool in ipairs(backpack:GetChildren()) doif tool:IsA("Tool") thenfor _, v in ipairs(tool:GetDescendants()) doif (v:IsA("NumberValue") or v:IsA("IntValue")) and (v.Name:lower():find("recoil") or v.Name:lower():find("spread") or v.Name:lower():find("shake")) thenv.Value = 0endendendendendend)endtask.wait(0.5)endend)-- ==========================================-- MAIN SECTION: OPTIMIZATION & CRATE SKIP-- ==========================================TabMain:Section({ Title = "Optimization & Utilities" })TabMain:Toggle({Title = "Auto Player Optimization",Default = false,Callback = function(state)pcall(function()local lighting = game:GetService("Lighting")if state thenlighting.GlobalShadows = falselighting.FogEnd = 9e9for _, v in ipairs(Workspace:GetDescendants()) doif v:IsA("BasePart") thenv.Material = Enum.Material.SmoothPlasticv.Reflectance = 0endendelselighting.GlobalShadows = trueendend)end})local enabledSkip = falseTabMain:Toggle({Title = "Crate Skip",Default = false,Callback = function(state)enabledSkip = stateend})task.spawn(function()while true doif enabledSkip thenpcall(function()local modules = ReplicatedStorage:FindFirstChild("Modules")local crateMod = modules and modules:FindFirstChild("Game") and modules.Game:FindFirstChild("CrateSystem") and modules.Game.CrateSystem:FindFirstChild("Crate")if crateMod thenlocal CrateController = require(crateMod)if CrateController and CrateController.class and CrateController.class.objects thenfor _, crate in pairs(CrateController.class.objects) doif crate.states and crate.states.open then crate.states.open.set(true) endif CrateController.skipping and CrateController.skipping.set then CrateController.skipping.set(true) endendendendend)task.wait(0.1)elsetask.wait(1)endendend)-- ==========================================-- UNDER-GROUND SNAP SYSTEM-- ==========================================TabMain:Section({ Title = "Under-Ground Snap System" })local SnapActive = falselocal SnapConnection = nillocal SnapDepth = 15local lockedY = nilTabMain:Toggle({Title = "Enable Under-Ground Snap",Default = false,Callback = function(state)SnapActive = stateif state thenlockedY = nilif SnapConnection then SnapConnection:Disconnect() endSnapConnection = RunService.RenderStepped:Connect(function()if not SnapActive then return endlocal char = LocalPlayer.Characterlocal hrp = char and char:FindFirstChild("HumanoidRootPart")if hrp thenif not lockedY then lockedY = hrp.Position.Y - SnapDepth endfor _, part in ipairs(char:GetDescendants()) doif part:IsA("BasePart") then part.CanCollide = false endendlocal vel = hrp.AssemblyLinearVelocityhrp.AssemblyLinearVelocity = Vector3.new(vel.X, 0, vel.Z)local cf = hrp.CFramehrp.CFrame = CFrame.new(cf.X, lockedY, cf.Z) * (cf - cf.Position)endend)WindUI:Notify({ Title = "GOKU BLACK", Content = "Snap ENABLED", Duration = 1.5 })elseif SnapConnection then SnapConnection:Disconnect() SnapConnection = nil endpcall(function()local char = LocalPlayer.Characterif char thenfor _, part in ipairs(char:GetDescendants()) doif part:IsA("BasePart") then part.CanCollide = true endendendend)lockedY = nilWindUI:Notify({ Title = "GOKU BLACK", Content = "Snap DISABLED", Duration = 1.5 })endend})TabMain:Slider({Title = "Under-Ground Distance (Studs)",Step = 1,Value = { Min = 5, Max = 100, Default = 15 },Callback = function(value)SnapDepth = valuelockedY = nilend})-- ==========================================-- PLAYER SECTION (AUTO PICK, STAMINA, SPEED)-- ==========================================TabPlayer:Section({ Title = "Player Functions" })local AutoPickupEnabled = falsetask.spawn(function()while true doif AutoPickupEnabled thenpcall(function()local character = LocalPlayer.Characterlocal root = character and (character:FindFirstChild("HumanoidRootPart") or character:FindFirstChild("Torso"))if root thenlocal droppedFolder = Workspace:FindFirstChild("DroppedItems")if droppedFolder thenfor _, item in ipairs(droppedFolder:GetChildren()) dolocal targetPart = item:IsA("Model") and (item.PrimaryPart or item:FindFirstChildWhichIsA("BasePart")) or itemif targetPart thenlocal prompt = item:FindFirstChildOfClass("ProximityPrompt") or targetPart:FindFirstChildOfClass("ProximityPrompt")if prompt then fireproximityprompt(prompt) endlocal touchPart = item:FindFirstChild("PickUpZone") or targetPartif touchPart thenfiretouchinterest(root, touchPart, 0)firetouchinterest(root, touchPart, 1)endendendendendend)task.wait(0.2)elsetask.wait(1)endendend)TabPlayer:Toggle({Title = "Auto Pickup Items",Default = false,Callback = function(state)AutoPickupEnabled = stateWindUI:Notify({ Title = "GOKU BLACK", Content = state and "Auto Pick ENABLED" or "Auto Pick DISABLED", Duration = 1.5 })end})-- Infinite Staminalocal InfStaminaEnabled = falselocal OriginalSprintUpdate = nilTabPlayer:Toggle({Title = "Infinite Stamina",Default = false,Callback = function(enable)InfStaminaEnabled = enablepcall(function()local success, sprintModule = pcall(function()return require(ReplicatedStorage.Modules.Game.Sprint)end)if success and sprintModule thenlocal consumeFunc = sprintModule.consume_staminalocal upvalues = getupvalues(consumeFunc)local sprintBarfor _, uv in ipairs(upvalues) doif type(uv) == "table" and rawget(uv, "sprint_bar") thensprintBar = uv.sprint_barbreakendendif sprintBar thenif enable thenlocal originalUpdate = sprintBar.updatesprintBar.update = function(...)return originalUpdate(function() return 1 end)endOriginalSprintUpdate = originalUpdateelseif OriginalSprintUpdate and sprintBar thensprintBar.update = OriginalSprintUpdateOriginalSprintUpdate = nilendendendendend)WindUI:Notify({ Title = "GOKU BLACK", Content = enable and "Inf Stamina ENABLED" or "Inf Stamina DISABLED", Duration = 1.5 })end})-- Speed Hack (Máx 20)local SpeedHackEnabled = falselocal SpeedValue = 4TabPlayer:Toggle({Title = "Speed Hack",Default = false,Callback = function(state)SpeedHackEnabled = stateend})TabPlayer:Slider({Title = "Speed Level (Max 20)",Step = 1,Value = { Min = 1, Max = 20, Default = 4 },Callback = function(value)SpeedValue = valueend})RunService.RenderStepped:Connect(function(dt)if SpeedHackEnabled and LocalPlayer.Character thenlocal hum = LocalPlayer.Character:FindFirstChild("Humanoid")local root = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")if hum and root and hum.MoveDirection.Magnitude > 0 thenlocal factor = (SpeedValue / 20) * 1.8local moveVec = hum.MoveDirection.Unit * (factor * 14 * dt)root.CFrame = root.CFrame + Vector3.new(moveVec.X, 0, moveVec.Z)endendend)-- ==========================================-- VISUAL SECTION (NAMES & INVENTORY ESP)-- ==========================================TabVisual:Section({ Title = "Player Info" })local inventoryESPEnabled = falselocal namesESPEnabled = falselocal WeaponRegistry = {}local PlayerBillboards = {}local RarityColors = {Common = Color3.fromRGB(180, 180, 180),Uncommon = Color3.fromRGB(0, 255, 0),Rare = Color3.fromRGB(0, 112, 221),Epic = Color3.fromRGB(163, 53, 238),Legendary = Color3.fromRGB(255, 128, 0)}local function registerItems(folder)if not folder then return endfor , tool in ipairs(folder:GetChildren()) doif tool:IsA("Tool") thenlocal handle      = tool:FindFirstChild("Handle")local displayName = tool:GetAttribute("DisplayName") or tool.Namelocal itemId      = tool:GetAttribute("ItemId") or tool:GetAttribute("Id") or tool.Namelocal rarity      = tool:GetAttribute("RarityName") or "Common"local imageId     = tool:GetAttribute("ImageId") or "rbxassetid://7072725737"local keyif handle thenlocal mesh = handle:FindFirstChildOfClass("SpecialMesh")if mesh and mesh.MeshId ~= "" thenkey = mesh.MeshId .. (mesh.TextureId or "") .. "RARITY" .. rarityelseif handle:IsA("MeshPart") and handle.MeshId ~= "" thenkey = handle.MeshId .. (handle.TextureID or "") .. "RARITY" .. rarityendendif not key and itemId and itemId ~= "" and itemId ~= tool.Name thenkey = "ITEMID" .. itemId .. "RARITY" .. rarityendif not key thenkey = "NAME_" .. displayName .. "_" .. tool.Name .. "RARITY" .. rarityendWeaponRegistry[key] = { Name = displayName, Rarity = rarity, ImageId = imageId, ToolName = tool.Name }endendendlocal function getItemKey(tool)local handle      = tool:FindFirstChild("Handle")local displayName = tool:GetAttribute("DisplayName") or tool.Namelocal itemId      = tool:GetAttribute("ItemId") or tool:GetAttribute("Id") or tool.Namelocal rarity      = tool:GetAttribute("RarityName") or "Common"if handle thenlocal mesh = handle:FindFirstChildOfClass("SpecialMesh")if mesh and mesh.MeshId ~= "" then return mesh.MeshId .. (mesh.TextureId or "") .. "RARITY" .. rarity endif handle:IsA("MeshPart") and handle.MeshId ~= "" then return handle.MeshId .. (handle.TextureID or "") .. "RARITY" .. rarity endendif itemId and itemId ~= "" and itemId ~= tool.Name then return "ITEMID_" .. itemId .. "RARITY" .. rarity endreturn "NAME_" .. displayName .. "_" .. tool.Name .. "RARITY" .. rarityendlocal function getWeaponInfo(tool)if not tool or not tool:IsA("Tool") then return nil endreturn WeaponRegistry[getItemKey(tool)]endlocal function createBillboardForPlayer(player)if not inventoryESPEnabled and not namesESPEnabled then return endif player == LocalPlayer then return endlocal char = player.Characterif not char then return endlocal head = char:FindFirstChild("Head") or char:FindFirstChild("HumanoidRootPart")if not head then return endif PlayerBillboards[player] thenPlayerBillboards[player]:Destroy()PlayerBillboards[player] = nilendlocal gui = Instance.new("BillboardGui")gui.Name        = "DMX_ESP"gui.Adornee     = headgui.Size        = UDim2.new(0, 140, 0, 45)gui.StudsOffset = Vector3.new(0, 2.5, 0)gui.AlwaysOnTop = truegui.Parent      = charlocal layout = Instance.new("UIListLayout", gui)layout.FillDirection       = Enum.FillDirection.Verticallayout.SortOrder           = Enum.SortOrder.LayoutOrderlayout.Padding             = UDim.new(0, 4)layout.HorizontalAlignment = Enum.HorizontalAlignment.Centerif namesESPEnabled thenlocal nameLbl = Instance.new("TextLabel", gui)nameLbl.Size = UDim2.new(1, 0, 0, 16)nameLbl.BackgroundTransparency = 1nameLbl.Text = player.NamenameLbl.TextColor3 = Color3.fromRGB(255, 255, 255)nameLbl.TextStrokeTransparency = 0.5nameLbl.Font = Enum.Font.GothamBoldnameLbl.TextSize = 12nameLbl.LayoutOrder = 1endif inventoryESPEnabled thenlocal toolsContainer = Instance.new("Frame", gui)toolsContainer.Size = UDim2.new(1, 0, 0, 20)toolsContainer.BackgroundTransparency = 1toolsContainer.LayoutOrder = 2local hLayout = Instance.new("UIListLayout", toolsContainer)hLayout.FillDirection       = Enum.FillDirection.HorizontalhLayout.SortOrder           = Enum.SortOrder.LayoutOrderhLayout.Padding             = UDim.new(0, 5)hLayout.HorizontalAlignment = Enum.HorizontalAlignment.Centerlocal tools = {}for _, bag in ipairs({ "Backpack", "StarterGear", "StarterPack" }) dolocal b = player:FindFirstChild(bag)if b thenfor _, t in ipairs(b:GetChildren()) doif t:IsA("Tool") and t.Name ~= "Fists" then table.insert(tools, t) endendendendfor _, t in ipairs(char:GetChildren()) doif t:IsA("Tool") and t.Name ~= "Fists" then table.insert(tools, t) endendfor _, tool in ipairs(tools) dolocal info = getWeaponInfo(tool)if info thenlocal img = Instance.new("ImageLabel", toolsContainer)img.Size                   = UDim2.new(0, 20, 0, 20)img.BackgroundTransparency = 0.1img.Image                  = info.ImageIdimg.BackgroundColor3       = Color3.fromRGB(240, 248, 255)Instance.new("UICorner", img).CornerRadius = UDim.new(0, 10)local stroke = Instance.new("UIStroke", img)stroke.Color    = RarityColors[info.Rarity] or Color3.new(1, 1, 1)stroke.Thickness = 2endendendPlayerBillboards[player] = guiendPlayers.PlayerAdded:Connect(function(player)player.CharacterAdded:Connect(function()if inventoryESPEnabled or namesESPEnabled thentask.wait(0.2)createBillboardForPlayer(player)endend)end)Players.PlayerRemoving:Connect(function(player)if PlayerBillboards[player] thenPlayerBillboards[player]:Destroy()PlayerBillboards[player] = nilendend)task.spawn(function()local Items = ReplicatedStorage:WaitForChild("Items", 15)if Items thenfor _, folderName in ipairs({ "gun", "melee", "throwable", "consumable", "farming", "misc", "rod", "fish" }) dolocal folder = Items:FindFirstChild(folderName)if folder thenregisterItems(folder)endendendend)local function refreshAll()for _, p in ipairs(Players:GetPlayers()) doif inventoryESPEnabled or namesESPEnabled thencreateBillboardForPlayer(p)elseif PlayerBillboards[p] thenPlayerBillboards[p]:Destroy()PlayerBillboards[p] = nilendendendendTabVisual:Toggle({Title = "Player Names",Default = false,Callback = function(state)namesESPEnabled = staterefreshAll()end})TabVisual:Toggle({Title = "Inventory ESP",Default = false,Callback = function(state)inventoryESPEnabled = staterefreshAll()end})-- Startup Notification with Creator CreditWindUI:Notify({Title = "GOKU BLACK | Created by eld0305",Content = "Menu loaded successfully with Silent Aim & Stamina!",Duration = 4})
