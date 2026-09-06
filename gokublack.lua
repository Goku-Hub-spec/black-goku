--// GOKU BLACK — DISEÑO LARGO PERSONALIZADO (COMPLETO)
--// Combinación de funciones de Aim/Movimiento con interfaz nativa semi-transparente

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

--==================================================
-- VARIABLES CONFIGURABLES
--==================================================
local AimbotEnabled = false
local AimSmoothness = 0.25
local AimMaxDistance = 500

local SpeedEnabled = false
local SpeedPercent = 16  

local JumpEnabled = false
local JumpPercent = 50   

local InfiniteJumpEnabled = false
local NoclipEnabled = false

--==================================================
-- 1. BASE DE LA PANTALLA
--==================================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "MenuLargoConLista"
ScreenGui.Parent = player:WaitForChild("PlayerGui")
ScreenGui.ResetOnSpawn = false

-- 2. VENTANA PRINCIPAL (Más larga a los costados: 450 de ancho, centrada y semi-transparente)
local MainFrame = Instance.new("Frame")
MainFrame.Name = "VentanaPrincipal"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25) 
MainFrame.BackgroundTransparency = 0.35                 -- Semi-transparente
MainFrame.BorderSizePixel = 0
MainFrame.Size = UDim2.new(0, 450, 0, 300)             -- Más ancho (450) y alto estándar (300)
MainFrame.Position = UDim2.new(0.5, -225, 0.5, -150)   -- Centrado exacto
MainFrame.Active = true
MainFrame.Draggable = true                             -- Se puede arrastrar por completo

local RedondeadoFrame = Instance.new("UICorner")
RedondeadoFrame.CornerRadius = UDim.new(0, 16)         
RedondeadoFrame.Parent = MainFrame

-- 3. LISTA DEL LADO IZQUIERDO (Contenedor para las pestañas)
local ListaIzquierda = Instance.new("Frame")
ListaIzquierda.Name = "ListaPestañas"
ListaIzquierda.Parent = MainFrame
ListaIzquierda.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
ListaIzquierda.BackgroundTransparency = 0.5            
ListaIzquierda.BorderSizePixel = 0
ListaIzquierda.Size = UDim2.new(0, 120, 1, 0)          
ListaIzquierda.Position = UDim2.new(0, 0, 0, 0)

local RedondeadoLista = Instance.new("UICorner")
RedondeadoLista.CornerRadius = UDim.new(0, 16)
RedondeadoLista.Parent = ListaIzquierda

local Titulo = Instance.new("TextLabel")
Titulo.Parent = ListaIzquierda
Titulo.BackgroundTransparency = 1
Titulo.Size = UDim2.new(1, 0, 0, 40)
Titulo.Position = UDim2.new(0, 0, 0, 15)
Titulo.Text = "GOKU BLACK"
Titulo.TextColor3 = Color3.fromRGB(220, 120, 210)  -- Color rosa/violeta característico
Titulo.TextSize = 15
Titulo.Font = Enum.Font.GothamBold

-- 4. BOTONES EN LA LISTA IZQUIERDA
local BotonLista1 = Instance.new("TextButton")
BotonLista1.Parent = ListaIzquierda
BotonLista1.BackgroundTransparency = 1
BotonLista1.Size = UDim2.new(1, 0, 0, 35)
BotonLista1.Position = UDim2.new(0, 0, 0, 60)          
BotonLista1.Text = "• Principal"
BotonLista1.TextColor3 = Color3.fromRGB(255, 255, 255)
BotonLista1.TextSize = 14
BotonLista1.Font = Enum.Font.GothamBold

local BotonLista2 = Instance.new("TextButton")
BotonLista2.Parent = ListaIzquierda
BotonLista2.BackgroundTransparency = 1
BotonLista2.Size = UDim2.new(1, 0, 0, 35)
BotonLista2.Position = UDim2.new(0, 0, 0, 95)          
BotonLista2.Text = "• Combat"
BotonLista2.TextColor3 = Color3.fromRGB(180, 180, 180) 
BotonLista2.TextSize = 14
BotonLista2.Font = Enum.Font.GothamBold

-- 5. CONTENEDORES DE PESTAÑAS (ZONA DERECHA)
local PaginaPrincipal = Instance.new("ScrollingFrame")
PaginaPrincipal.Name = "PaginaPrincipal"
PaginaPrincipal.Parent = MainFrame
PaginaPrincipal.BackgroundTransparency = 1
PaginaPrincipal.BorderSizePixel = 0
PaginaPrincipal.Size = UDim2.new(1, -140, 1, -60)
PaginaPrincipal.Position = UDim2.fromOffset(135, 50)
PaginaPrincipal.ScrollBarThickness = 3
PaginaPrincipal.Visible = true

local PaginaCombat = Instance.new("ScrollingFrame")
PaginaCombat.Name = "PaginaCombat"
PaginaCombat.Parent = MainFrame
PaginaCombat.BackgroundTransparency = 1
PaginaCombat.BorderSizePixel = 0
PaginaCombat.Size = UDim2.new(1, -140, 1, -60)
PaginaCombat.Position = UDim2.fromOffset(135, 50)
PaginaCombat.ScrollBarThickness = 3
PaginaCombat.Visible = false

-- Ajustar diseños de lista automáticos para las páginas
local layout1 = Instance.new("UIListLayout")
layout1.Padding = UDim.new(0, 6)
layout1.Parent = PaginaPrincipal

local layout2 = Instance.new("UIListLayout")
layout2.Padding = UDim.new(0, 6)
layout2.Parent = PaginaCombat

-- Sistema de navegación entre las dos pestañas de tu lista
BotonLista1.MouseButton1Click:Connect(function()
    PaginaPrincipal.Visible = true
    PaginaCombat.Visible = false
    BotonLista1.TextColor3 = Color3.fromRGB(255, 255, 255)
    BotonLista2.TextColor3 = Color3.fromRGB(180, 180, 180)
end)

BotonLista2.MouseButton1Click:Connect(function()
    PaginaPrincipal.Visible = false
    PaginaCombat.Visible = true
    BotonLista1.TextColor3 = Color3.fromRGB(180, 180, 180)
    BotonLista2.TextColor3 = Color3.fromRGB(255, 255, 255)
end)

-- 6. BOTÓN "X" PARA CERRAR EL MENÚ
local BotonCerrar = Instance.new("TextButton")
BotonCerrar.Parent = MainFrame
BotonCerrar.BackgroundColor3 = Color3.fromRGB(220, 60, 80) 
BotonCerrar.BorderSizePixel = 0
BotonCerrar.Size = UDim2.new(0, 28, 0, 28)
BotonCerrar.Position = UDim2.new(1, -40, 0, 15)          
BotonCerrar.Text = "X"
BotonCerrar.TextColor3 = Color3.fromRGB(255, 255, 255)
BotonCerrar.TextSize = 12
BotonCerrar.Font = Enum.Font.GothamBold

local RedondeadoX = Instance.new("UICorner")
RedondeadoX.CornerRadius = UDim.new(0, 8)
RedondeadoX.Parent = BotonCerrar

BotonCerrar.MouseButton1Click:Connect(function()
    MainFrame.Visible = false
end)

-- 7. BOTÓN FLOTANTE INDEPENDIENTE (Redondo y movible)
local BotonFlotante = Instance.new("TextButton")
BotonFlotante.Name = "BotonFlotanteAbrir"
BotonFlotante.Parent = ScreenGui
BotonFlotante.BackgroundColor3 = Color3.fromRGB(120, 45, 110) -- Violeta original de tu menú
BotonFlotante.BorderSizePixel = 0
BotonFlotante.Size = UDim2.new(0, 55, 0, 55)                
BotonFlotante.Position = UDim2.new(0.05, 0, 0.2, 0)          
BotonFlotante.Text = "OPEN"
BotonFlotante.TextColor3 = Color3.fromRGB(255, 255, 255)
BotonFlotante.TextSize = 12
BotonFlotante.Font = Enum.Font.GothamBold
BotonFlotante.Active = true
BotonFlotante.Draggable = true                               

local RedondeadoFlotante = Instance.new("UICorner")
RedondeadoFlotante.CornerRadius = UDim.new(1, 0)             
RedondeadoFlotante.Parent = BotonFlotante

BotonFlotante.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)

--==================================================
-- FUNCIONES DENTRO DE LOS CONTENEDORES (COMPONETIZACIÓN NATIVA)
--==================================================
local function createToggle(parent, text, default, callback)
    local button = Instance.new("TextButton")  
    button.Size = UDim2.new(1, -10, 0, 35)  
    button.BackgroundColor3 = Color3.fromRGB(40, 40, 48)  
    button.TextColor3 = Color3.new(1, 1, 1)  
    button.TextSize = 13  
    button.Font = Enum.Font.Gotham  
    button.BorderSizePixel = 0  
    button.Parent = parent  
    
    local tCorner = Instance.new("UICorner")
    tCorner.CornerRadius = UDim.new(0, 6)
    tCorner.Parent = button

    local enabled = default  
    local function refresh()  
        button.Text = text .. ": " .. (enabled and "ON" or "OFF")  
        button.BackgroundColor3 = enabled and Color3.fromRGB(100, 45, 95) or Color3.fromRGB(40, 40, 48)  
    end  

    button.MouseButton1Click:Connect(function()  
        enabled = not enabled  
        refresh()  
        callback(enabled)  
    end)  
    refresh()  
end

local function createSlider(parent, text, minVal, maxVal, default, callback)
    local container = Instance.new("Frame")  
    container.Size = UDim2.new(1, -10, 0, 45)  
    container.BackgroundTransparency = 1  
    container.Parent = parent  

    local label = Instance.new("TextLabel")  
    label.Size = UDim2.new(1, 0, 0, 18)  
    label.BackgroundTransparency = 1
    label.Text = text .. ": " .. math.floor(default)
    label.TextColor3 = Color3.new(1, 1, 1)
    label.TextSize = 12
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = container

    local slider = Instance.new("TextButton")
    slider.Size = UDim2.new(1, 0, 0, 6)
    slider.Position = UDim2.fromOffset(0, 24)
    slider.Text = ""
    slider.BackgroundColor3 = Color3.fromRGB(65, 65, 75)
    slider.BorderSizePixel = 0
    slider.Parent = container

    local sc = Instance.new("UICorner")
    sc.CornerRadius = UDim.new(1, 0)
    sc.Parent = slider

    local fill = Instance.new("Frame")
    local startPercent = (default - minVal) / (maxVal - minVal)
    fill.Size = UDim2.new(startPercent, 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(170, 70, 150)
    fill.BorderSizePixel = 0
    fill.Parent = slider

    local fc = Instance.new("UICorner")
    fc.CornerRadius = UDim.new(1, 0)
    fc.Parent = fill

    local function updateValue(input)
        local percentage = math.clamp((input.Position.X - slider.AbsolutePosition.X) / slider.AbsoluteSize.X, 0, 1)
        local finalValue = minVal + (percentage * (maxVal - minVal))
        fill.Size = UDim2.new(percentage, 0, 1, 0)
        label.Text = text .. ": " .. math.floor(finalValue)
        callback(finalValue)
    end

    local holding = false
    slider.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            holding = true
            updateValue(input)
        end
    end)
    UIS.InputChanged:Connect(function(input)
Usa el código con precaución.if holding and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) thenupdateValue(input)endend)UIS.InputEnded:Connect(function(input)if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch thenholding = falseendend)end--==================================================-- INYECCIÓN DE CONTENIDOS EN LAS PESTAÑAS NATIVAS--==================================================-- PESTAÑA PRINCIPAL (Físicas de Movimiento)createToggle(PaginaPrincipal, "Activar Súper Velocidad", false, function(state) SpeedEnabled = state end)createSlider(PaginaPrincipal, "Velocidad Máxima", 16, 300, 16, function(value) SpeedPercent = value end)createToggle(PaginaPrincipal, "Activar Súper Salto", false, function(state) JumpEnabled = state end)createSlider(PaginaPrincipal, "Fuerza de Salto", 50, 400, 50, function(value) JumpPercent = value end)createToggle(PaginaPrincipal, "Salto Infinito", false, function(state) InfiniteJumpEnabled = state end)createToggle(PaginaPrincipal, "Noclip (Atravesar Paredes)", false, function(state) NoclipEnabled = state end)-- PESTAÑA COMBAT (Aimbot)createToggle(PaginaCombat, "Activar Aimbot", false, function(state) AimbotEnabled = state end)createSlider(PaginaCombat, "Suavizado de Cámara", 1, 10, 3, function(value) AimSmoothness = value / 10 end)createSlider(PaginaCombat, "Distancia Máxima Aim", 100, 1000, 500, function(value) AimMaxDistance = value end)--==================================================-- LOGICA EN BUCLE DETRÁS DE ESCENA--==================================================local function getClosestPlayer()local closestPart = nillocal shortestDistance = AimMaxDistancefor _, v in pairs(Players:GetPlayers()) doif v ~= player and v.Character and v.Character:FindFirstChild("HumanoidRootPart") and v.Character:FindFirstChild("Head") and v.Character:FindFirstChild("Humanoid") and v.Character.Humanoid.Health > 0 thenlocal pos, onScreen = camera:WorldToViewportPoint(v.Character.Head.Position)if onScreen thenlocal distance = (Vector2.new(pos.X, pos.Y) - UIS:GetMouseLocation()).Magnitudeif distance < shortestDistance thenclosestPart = v.Character.HeadshortestDistance = distanceendendendendreturn closestPartendRunService.RenderStepped:Connect(function()local char = player.Characterif char and char:FindFirstChild("Humanoid") thenif SpeedEnabled then char.Humanoid.WalkSpeed = SpeedPercent else char.Humanoid.WalkSpeed = 16 endif JumpEnabled then char.Humanoid.JumpPower = JumpPercent char.Humanoid.UseJumpPower = true endif NoclipEnabled thenfor _, child in pairs(char:GetDescendants()) doif child:IsA("BasePart") and child.CanCollide == true then child.CanCollide = false endendendendif AimbotEnabled thenlocal target = getClosestPlayer()if target thencamera.CFrame = camera.CFrame:Lerp(CFrame.new(camera.CFrame.Position, target.Position), AimSmoothness)endendend)UIS.JumpRequest:Connect(function()if InfiniteJumpEnabled and player.Character and player.Character:FindFirstChildOfClass("Humanoid") thenplayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState("Jumping")endend)
