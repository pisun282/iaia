-- Очистка старых потоков и элементов интерфейса для стабильности
local oldGui = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui"):FindFirstChild("XenoStableGui")
if oldGui then oldGui:Destroy() end
if _G.XenoToggleGuiConn then _G.XenoToggleGuiConn:Disconnect() _G.XenoToggleGuiConn = nil end
if _G.XenoFlyDisconnect then _G.XenoFlyDisconnect() end

_G.XenoScriptID = tick()
local currentScriptID = _G.XenoScriptID

-- Ссылки на сервисы движка
local P = game:GetService("Players")
local R = game:GetService("RunService")
local U = game:GetService("UserInputService")
local VU = game:GetService("VirtualUser") 
local lp = P.LocalPlayer

-- Настройки состояний и конфигурация
local fly, fSpd, wSpd, jPwr = false, 50, 16, 50
local isBind, speedToggle, jumpToggle, afkToggle = false, false, false, false
local afkSeconds, resetConfirm, confirmTime, espToggle = 0, false, 0, false
local flyKey = Enum.KeyCode.F
local guiVisible = true
local toggleGuiKey = Enum.KeyCode.Insert
local bv, bg

-- Переменные для системы кастомного FOV (диапазон: 70 - 120)
local fovValue = 70
local fovToggle = false 
local sliderDragging = false
-- Основной контейнер ScreenGui
local sg = Instance.new("ScreenGui", lp.PlayerGui)
sg.Name = "XenoStableGui"
sg.ResetOnSpawn = false
sg.DisplayOrder = 99999 -- Выводит меню на самый передний план поверх всего

-- Круглая кнопка-переключатель меню
local circleBtn = Instance.new("TextButton", sg)
circleBtn.Size = UDim2.new(0, 55, 0, 45) circleBtn.Position = UDim2.new(0, 10, 0, 10)
circleBtn.BackgroundColor3 = Color3.fromRGB(15, 15, 15) circleBtn.Font = Enum.Font.SourceSansBold
circleBtn.TextSize = 16 circleBtn.TextColor3 = Color3.fromRGB(255, 255, 255) circleBtn.Text = "YnSc"
circleBtn.Active = true circleBtn.Draggable = true

local corner = Instance.new("UICorner", circleBtn) corner.CornerRadius = UDim.new(0.4, 0)
local stroke = Instance.new("UIStroke", circleBtn) stroke.Thickness = 3 stroke.Color = Color3.fromRGB(75, 255, 75) stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

-- Главное окно меню
local mf = Instance.new("Frame", sg)
mf.Size = UDim2.new(0, 450, 0, 310) mf.AnchorPoint = Vector2.new(0.5, 0.5) mf.Position = UDim2.new(0.5, 0, 0.4, 0)
mf.BackgroundColor3 = Color3.fromRGB(30, 30, 30) mf.BorderColor3 = Color3.fromRGB(60, 60, 60) mf.Active = true mf.Draggable = true

-- Вспомогательные функции фабрики элементов
local function lbl(t, s, p, parent, f)
    local l = Instance.new("TextLabel", parent or mf) l.Size = s l.Position = p l.BackgroundTransparency = 1
    l.Font = f or Enum.Font.SourceSans l.TextSize = f and 16 or 14 l.TextColor3 = Color3.fromRGB(255, 255, 255) l.Text = t
    return l
end

local function box(t, p, parent)
    local b = Instance.new("TextBox", parent or mf) b.Size = UDim2.new(0, 60, 0, 30) b.Position = p
    b.BackgroundColor3 = Color3.fromRGB(45, 45, 45) b.BorderSizePixel = 0 b.Font = Enum.Font.SourceSansBold
    b.TextSize = 14 b.TextColor3 = Color3.fromRGB(255, 255, 255) b.Text = t
    return b
end

local function tgl(p, parent)
    local t = Instance.new("TextButton", parent or mf) t.Size = UDim2.new(0, 30, 0, 30) t.Position = p
    t.BackgroundColor3 = Color3.fromRGB(255, 75, 75) t.Font = Enum.Font.SourceSansBold t.TextSize = 16
    t.TextColor3 = Color3.fromRGB(255, 255, 255) t.Text = "X"
    return t
end

-- Шапка (Название скрипта и Часы)
local mainTitle = lbl("YNIVERSAL SCRIPT MENU", UDim2.new(0, 250, 0, 30), UDim2.new(0, 15, 0, 0), mf, Enum.Font.SourceSansBold)
mainTitle.TextXAlignment = Enum.TextXAlignment.Left
local timeLabelTop = lbl("00:00:00", UDim2.new(0, 100, 0, 30), UDim2.new(0, 335, 0, 0), mf, Enum.Font.SourceSansBold)
timeLabelTop.TextXAlignment = Enum.TextXAlignment.Right

-- КНОПКИ ПЕРЕКЛЮЧЕНИЯ ВКЛАДОК (Под названием скрипта)
local mainTabBtn = Instance.new("TextButton", mf)
mainTabBtn.Size = UDim2.new(0, 100, 0, 25) mainTabBtn.Position = UDim2.new(0, 15, 0, 32)
mainTabBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60) mainTabBtn.Font = Enum.Font.SourceSansBold
mainTabBtn.TextSize = 13 mainTabBtn.TextColor3 = Color3.fromRGB(255, 255, 255) mainTabBtn.Text = "ГЛАВНОЕ"
Instance.new("UICorner", mainTabBtn).CornerRadius = UDim.new(0, 4)

local visualTabBtn = Instance.new("TextButton", mf)
visualTabBtn.Size = UDim2.new(0, 100, 0, 25) visualTabBtn.Position = UDim2.new(0, 120, 0, 32)
visualTabBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 45) visualTabBtn.Font = Enum.Font.SourceSansBold
visualTabBtn.TextSize = 13 visualTabBtn.TextColor3 = Color3.fromRGB(180, 180, 180) visualTabBtn.Text = "ВИЗУАЛЫ"
Instance.new("UICorner", visualTabBtn).CornerRadius = UDim.new(0, 4)

-- Фреймы-контейнеры для содержимого вкладок
local mainContent = Instance.new("Frame", mf)
mainContent.Size = UDim2.new(1, 0, 1, -65) mainContent.Position = UDim2.new(0, 0, 0, 65) mainContent.BackgroundTransparency = 1

local visualContent = Instance.new("Frame", mf)
visualContent.Size = UDim2.new(1, 0, 1, -65) visualContent.Position = UDim2.new(0, 0, 0, 65) visualContent.BackgroundTransparency = 1 visualContent.Visible = false

-- НАПОЛНЕНИЕ ВКЛАДКИ: ГЛАВНОЕ
lbl("УПРАВЛЕНИЕ ПОЛЕТОМ", UDim2.new(0, 190, 0, 20), UDim2.new(0, 15, 0, 0), mainContent, Enum.Font.SourceSansBold).TextColor3 = Color3.fromRGB(150, 150, 150)
lbl("НАСТРОЙКИ ХАРАКТЕРИСТИК", UDim2.new(0, 190, 0, 20), UDim2.new(0, 225, 0, 0), mainContent, Enum.Font.SourceSansBold).TextColor3 = Color3.fromRGB(150, 150, 150)

local btn = Instance.new("TextButton", mainContent) btn.Size = UDim2.new(0, 180, 0, 35) btn.Position = UDim2.new(0, 15, 0, 25)
btn.BackgroundColor3 = Color3.fromRGB(255, 75, 75) btn.Font = Enum.Font.SourceSansBold btn.TextSize = 15 btn.TextColor3 = Color3.fromRGB(255, 255, 255) btn.Text = "ВКЛЮЧИТЬ ПОЛЕТ"

local bBtn = Instance.new("TextButton", mainContent) bBtn.Size = UDim2.new(0, 180, 0, 25) bBtn.Position = UDim2.new(0, 15, 0, 70)
bBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 45) bBtn.Font = Enum.Font.SourceSansBold bBtn.TextSize = 13 bBtn.TextColor3 = Color3.fromRGB(220, 220, 220) bBtn.Text = "Бинд Fly: [ F ]"

lbl("Скорость полета:", UDim2.new(0, 90, 0, 30), UDim2.new(0, 15, 0, 105), mainContent)
local fInp = box(tostring(fSpd), UDim2.new(0, 115, 0, 105), mainContent)
lbl("Скорость бега:", UDim2.new(0, 90, 0, 30), UDim2.new(0, 225, 0, 25), mainContent)
lbl("Сила прыжка:", UDim2.new(0, 90, 0, 30), UDim2.new(0, 225, 0, 70), mainContent)

local sInp = box(tostring(wSpd), UDim2.new(0, 315, 0, 25), mainContent) local jInp = box(tostring(jPwr), UDim2.new(0, 315, 0, 70), mainContent)
local sTgl = tgl(UDim2.new(0, 385, 0, 25), mainContent) local jTgl = tgl(UDim2.new(0, 385, 0, 70), mainContent)

local afkBtn = Instance.new("TextButton", mainContent) afkBtn.Size = UDim2.new(0, 420, 0, 35) afkBtn.Position = UDim2.new(0, 15, 0, 150)
afkBtn.BackgroundColor3 = Color3.fromRGB(255, 75, 75) afkBtn.Font = Enum.Font.SourceSansBold afkBtn.TextSize = 14 afkBtn.TextColor3 = Color3.fromRGB(255, 255, 255) afkBtn.Text = "ВКЛЮЧИТЬ АНТИ-АФК"

local timeLabel = Instance.new("TextLabel", mainContent) timeLabel.Size = UDim2.new(0, 200, 0, 30) timeLabel.Position = UDim2.new(0, 15, 0, 190)
timeLabel.BackgroundTransparency = 1 timeLabel.Font = Enum.Font.SourceSansBold timeLabel.TextSize = 15 timeLabel.TextColor3 = Color3.fromRGB(255, 255, 255) timeLabel.Text = "Время АФК: 00:00:00" timeLabel.TextXAlignment = Enum.TextXAlignment.Left

local rBtn = Instance.new("TextButton", mainContent) rBtn.Size = UDim2.new(0, 150, 0, 30) rBtn.Position = UDim2.new(0, 285, 0, 190)
rBtn.BackgroundColor3 = Color3.fromRGB(55, 55, 55) rBtn.Font = Enum.Font.SourceSansBold rBtn.TextSize = 13 rBtn.TextColor3 = Color3.fromRGB(255, 255, 255) rBtn.Text = "СБРОС" rBtn.BorderSizePixel = 0

-- НАПОЛНЕНИЕ ВКЛАДКИ: ВИЗУАЛЫ
lbl("ВИЗУАЛЬНЫЕ НАСТРОЙКИ", UDim2.new(0, 420, 0, 20), UDim2.new(0, 15, 0, 0), visualContent, Enum.Font.SourceSansBold).TextColor3 = Color3.fromRGB(150, 150, 150)

local espBtn = Instance.new("TextButton", visualContent) espBtn.Size = UDim2.new(0, 420, 0, 35) espBtn.Position = UDim2.new(0, 15, 0, 25)
espBtn.BackgroundColor3 = Color3.fromRGB(255, 75, 75) espBtn.Font = Enum.Font.SourceSansBold espBtn.TextSize = 13 espBtn.TextColor3 = Color3.fromRGB(255, 255, 255) espBtn.Text = "ESP УЛЬТРА: ВЫКЛ" espBtn.BorderSizePixel = 0

-- Включалка (Toggle) кастомного FOV
local fovTglBtn = Instance.new("TextButton", visualContent) fovTglBtn.Size = UDim2.new(0, 420, 0, 35) fovTglBtn.Position = UDim2.new(0, 15, 0, 75)
fovTglBtn.BackgroundColor3 = Color3.fromRGB(255, 75, 75) fovTglBtn.Font = Enum.Font.SourceSansBold fovTglBtn.TextSize = 13 fovTglBtn.TextColor3 = Color3.fromRGB(255, 255, 255) fovTglBtn.Text = "КАСТОМНЫЙ FOV: ВЫКЛ" fovTglBtn.BorderSizePixel = 0

-- Элементы Ползунка FOV
local fovLabel = lbl("Поле зрения (FOV): 70", UDim2.new(0, 200, 0, 20), UDim2.new(0, 15, 0, 125), visualContent, Enum.Font.SourceSansBold)
fovLabel.TextXAlignment = Enum.TextXAlignment.Left

local sliderBack = Instance.new("Frame", visualContent)
sliderBack.Size = UDim2.new(0, 420, 0, 8) sliderBack.Position = UDim2.new(0, 15, 0, 155)
sliderBack.BackgroundColor3 = Color3.fromRGB(45, 45, 45) sliderBack.BorderSizePixel = 0
Instance.new("UICorner", sliderBack).CornerRadius = UDim.new(0.5, 0)

local sliderFill = Instance.new("Frame", sliderBack)
sliderFill.Size = UDim2.new(0, 0, 1, 0) sliderFill.BackgroundColor3 = Color3.fromRGB(75, 255, 75) sliderFill.BorderSizePixel = 0
Instance.new("UICorner", sliderFill).CornerRadius = UDim.new(0.5, 0)

local sliderMainBtn = Instance.new("TextButton", sliderBack)
sliderMainBtn.Size = UDim2.new(0, 16, 0, 16) sliderMainBtn.AnchorPoint = Vector2.new(0.5, 0.5) sliderMainBtn.Position = UDim2.new(0, 0, 0.5, 0)
sliderMainBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255) sliderMainBtn.Text = "" sliderMainBtn.BorderSizePixel = 0
Instance.new("UICorner", sliderMainBtn).CornerRadius = UDim.new(0.5, 0)

-- Логика переключения окон вкладок
local function switchTab(tab)
    mainContent.Visible = (tab == "Main")
    visualContent.Visible = (tab == "Visuals")
    mainTabBtn.BackgroundColor3 = (tab == "Main") and Color3.fromRGB(60, 60, 60) or Color3.fromRGB(45, 45, 45)
    mainTabBtn.TextColor3 = (tab == "Main") and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(180, 180, 180)
    visualTabBtn.BackgroundColor3 = (tab == "Visuals") and Color3.fromRGB(60, 60, 60) or Color3.fromRGB(45, 45, 45)
    visualTabBtn.TextColor3 = (tab == "Visuals") and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(180, 180, 180)
end
mainTabBtn.MouseButton1Click:Connect(function() switchTab("Main") end)
visualTabBtn.MouseButton1Click:Connect(function() switchTab("Visuals") end)

local function toggleGui()
    guiVisible = not guiVisible 
    mf.Visible = guiVisible
    stroke.Color = guiVisible and Color3.fromRGB(75, 255, 75) or Color3.fromRGB(255, 75, 75)
end
-- Логика полной очистки объектов ESP
local function clearESP()
    for _, p in ipairs(P:GetPlayers()) do
        if p.Character then
            local skin = p.Character:FindFirstChild("XenoSkinESP")
            local txt = p.Character:FindFirstChild("XenoTextESP")
            if skin then skin:Destroy() end
            if txt then txt:Destroy() end
        end
    end
end

-- Динамическое обновление ESP (Highlight + BillboardGui) без мигания
local function updateESP()
    if _G.XenoScriptID ~= currentScriptID then return end
    if not espToggle then clearESP() return end
    local myRoot = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
    
    for _, p in ipairs(P:GetPlayers()) do
        if p ~= lp and p.Character then
            local targetHum = p.Character:FindFirstChildOfClass("Humanoid")
            local targetRoot = p.Character:FindFirstChild("HumanoidRootPart")
            
            if targetHum and targetHum.Health > 0 and targetRoot then
                local hl = p.Character:FindFirstChild("XenoSkinESP")
                if not hl then
                    hl = Instance.new("Highlight") hl.Name = "XenoSkinESP"
                    hl.FillColor = Color3.fromRGB(255, 0, 0) hl.FillTransparency = 0.5 hl.OutlineColor = Color3.fromRGB(255, 255, 255)
                    hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop hl.Parent = p.Character
                end
                
                local bb = p.Character:FindFirstChild("XenoTextESP")
                local tl
                if not bb then
                    bb = Instance.new("BillboardGui") bb.Name = "XenoTextESP" bb.AlwaysOnTop = true
                    bb.Size = UDim2.new(5, 0, 2, 0) bb.ExtentsOffset = Vector3.new(0, 3, 0) bb.Adornee = targetRoot
                    tl = Instance.new("TextLabel", bb) tl.Size = UDim2.new(1, 0, 1, 0) tl.BackgroundTransparency = 1
                    tl.Font = Enum.Font.SourceSansBold tl.TextSize = 13 tl.TextColor3 = Color3.fromRGB(255, 255, 255)
                    tl.TextStrokeTransparency = 0 tl.TextStrokeColor3 = Color3.fromRGB(0, 0, 0) bb.Parent = p.Character
                else
                    tl = bb:FindFirstChildOfClass("TextLabel")
                end
                
                local distance = myRoot and math.floor((myRoot.Position - targetRoot.Position).Magnitude) or 0
                if tl then tl.Text = string.format("%s\n[%d HP] [%dm]", p.Name, math.floor(targetHum.Health), distance) end
            else
                local skin = p.Character:FindFirstChild("XenoSkinESP")
                local txt = p.Character:FindFirstChild("XenoTextESP")
                if skin then skin:Destroy() end
                if txt then txt:Destroy() end
            end
        end
    end
end

-- Логика трехмерного полета (Fly) через BodyVelocity и BodyGyro
local function toggleFly() 
    local c = lp.Character if not c then return end 
    local r = c:FindFirstChild("HumanoidRootPart") local h = c:FindFirstChildOfClass("Humanoid") if not r or not h then return end 
    fly = not fly 
    if fly then 
        btn.Text = "ВЫКЛЮЧИТЬ ПОЛЕТ" btn.BackgroundColor3 = Color3.fromRGB(75, 255, 75) h.PlatformStand = true 
        bg = Instance.new("BodyGyro", r) bg.P = 9e4 bg.maxTorque = Vector3.new(9e9, 9e9, 9e9) 
        bv = Instance.new("BodyVelocity", r) bv.velocity = Vector3.new(0,0,0) bv.maxForce = Vector3.new(9e9, 9e9, 9e9) 
        task.spawn(function() 
            while fly and task.wait() and _G.XenoScriptID == currentScriptID do 
                local cam = workspace.CurrentCamera 
                if bg and bv and r then 
                    bg.cframe = cam.CFrame local dir = Vector3.new(0,0,0) 
                    if U:IsKeyDown(Enum.KeyCode.W) then dir = dir + cam.CFrame.LookVector end 
                    if U:IsKeyDown(Enum.KeyCode.S) then dir = dir - cam.CFrame.LookVector end 
                    if U:IsKeyDown(Enum.KeyCode.A) then dir = dir - cam.CFrame.RightVector end 
                    if U:IsKeyDown(Enum.KeyCode.D) then dir = dir + cam.CFrame.RightVector end 
                    bv.velocity = dir.Magnitude > 0 and dir.Unit * fSpd or Vector3.new(0,0,0) 
                end 
            end 
        end) 
    else 
        btn.Text = "ВКЛЮЧИТЬ ПОЛЕТ" btn.BackgroundColor3 = Color3.fromRGB(255, 75, 75) h.PlatformStand = false 
        if bv then bv:Destroy() end if bg then bg:Destroy() end 
        if h then h:ChangeState(Enum.HumanoidStateType.GettingUp) end
    end 
end
local function updT() timeLabel.Text = string.format("Время АФК: %02d:%02d:%02d", math.floor(afkSeconds / 3600), math.floor((afkSeconds % 3600) / 60), afkSeconds % 60) end

-- Подписка на интеракции элементов GUI
circleBtn.MouseButton1Click:Connect(toggleGui)
btn.MouseButton1Click:Connect(toggleFly)
fInp.FocusLost:Connect(function() fSpd = tonumber(fInp.Text) or fSpd fInp.Text = tostring(fSpd) end) 
sInp.FocusLost:Connect(function() wSpd = tonumber(sInp.Text) or wSpd sInp.Text = tostring(wSpd) end) 
jInp.FocusLost:Connect(function() jPwr = tonumber(jInp.Text) or jPwr jInp.Text = tostring(jPwr) end)
bBtn.MouseButton1Click:Connect(function() isBind = true bBtn.Text = "Нажмите клавишу..." bBtn.BackgroundColor3 = Color3.fromRGB(70, 70, 70) end)

espBtn.MouseButton1Click:Connect(function() espToggle = not espToggle espBtn.Text = espToggle and "ESP УЛЬТРА: ВКЛ" or "ESP УЛЬТРА: ВЫКЛ" espBtn.BackgroundColor3 = espToggle and Color3.fromRGB(75, 255, 75) or Color3.fromRGB(255, 75, 75) updateESP() end)
sTgl.MouseButton1Click:Connect(function() speedToggle = not speedToggle sTgl.Text = speedToggle and "✔" or "X" sTgl.BackgroundColor3 = speedToggle and Color3.fromRGB(75, 255, 75) or Color3.fromRGB(255, 75, 75) end)
jTgl.MouseButton1Click:Connect(function() jumpToggle = not jumpToggle jTgl.Text = jumpToggle and "✔" or "X" jTgl.BackgroundColor3 = jumpToggle and Color3.fromRGB(75, 255, 75) or Color3.fromRGB(255, 75, 75) end)
afkBtn.MouseButton1Click:Connect(function() afkToggle = not afkToggle afkBtn.BackgroundColor3 = afkToggle and Color3.fromRGB(75, 255, 75) or Color3.fromRGB(255, 75, 75) afkBtn.Text = afkToggle and "АНТИ-АФК: РАБОТАЕТ" or "ВКЛЮЧИТЬ АНТИ-АФК" updT() end)

-- Взаимодействие с включалкой FOV
fovTglBtn.MouseButton1Click:Connect(function()
    fovToggle = not fovToggle
    fovTglBtn.Text = fovToggle and "КАСТОМНЫЙ FOV: ВКЛ" or "КАСТОМНЫЙ FOV: ВЫКЛ"
    fovTglBtn.BackgroundColor3 = fovToggle and Color3.fromRGB(75, 255, 75) or Color3.fromRGB(255, 75, 75)
    
    local cam = workspace.CurrentCamera
    if cam and not fovToggle then cam.FieldOfView = 70 end 
end)

-- ЛОГИКА УПРАВЛЕНИЯ И ПЕРЕТАСКИВАНИЯ ПОЛЗУНКА FOV (Разблокировано перетаскивание при ВЫКЛ)
local function updateSlider(input)
    local sliderWidth = sliderBack.AbsoluteSize.X
    local mouseX = input.Position.X - sliderBack.AbsolutePosition.X
    local percentage = math.clamp(mouseX / sliderWidth, 0, 1)
    
    sliderMainBtn.Position = UDim2.new(percentage, 0, 0.5, 0)
    sliderFill.Size = UDim2.new(percentage, 0, 1, 0)
    
    fovValue = math.floor(70 + (percentage * 50))
    fovLabel.Text = "Поле зрения (FOV): " .. tostring(fovValue)
end

sliderMainBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        sliderDragging = true
    end
end)

U.InputChanged:Connect(function(input)
    if sliderDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        updateSlider(input)
    end
end)

U.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        sliderDragging = false
    end
end)

-- Поддержание установленного FOV в цикле рендера
R.RenderStepped:Connect(function()
    if _G.XenoScriptID ~= currentScriptID then return end
    local cam = workspace.CurrentCamera
    if cam then
        if fovToggle then
            if cam.FieldOfView ~= fovValue then cam.FieldOfView = fovValue end
        else
            if cam.FieldOfView == fovValue then cam.FieldOfView = 70 end
        end
    end
end)

rBtn.MouseButton1Click:Connect(function() 
    if not afkToggle then afkSeconds = 0 updT() else 
        if not resetConfirm then resetConfirm = true confirmTime = tick() rBtn.Size = UDim2.new(0, 250, 0, 30) rBtn.Position = UDim2.new(0, 185, 0, 190) rBtn.BackgroundColor3 = Color3.fromRGB(200, 150, 50) rBtn.TextSize = 11 rBtn.Text = "Вы точно хотите сбросить время?" 
        else resetConfirm = false afkSeconds = 0 updT() rBtn.Size = UDim2.new(0, 150, 0, 30) rBtn.Position = UDim2.new(0, 285, 0, 190) rBtn.BackgroundColor3 = Color3.fromRGB(55, 55, 55) rBtn.TextSize = 13 rBtn.Text = "СБРОС" end 
    end 
end)

-- Двухрежимный перехватчик аппаратного ввода
_G.XenoToggleGuiConn = U.InputBegan:Connect(function(input, gameProcessed)
    if isBind and input.UserInputType == Enum.UserInputType.Keyboard then
        flyKey = input.KeyCode isBind = false
        bBtn.Text = "Бинд Fly: [ " .. flyKey.Name .. " ]" bBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
        return 
    end
    if not gameProcessed then
        if input.KeyCode == toggleGuiKey then toggleGui() end
        if input.KeyCode == flyKey and not isBind and not U:GetFocusedTextBox() then toggleFly() end
    end
end)

-- Симуляция физических параметров прыжка и скорости бега
local ev = R.RenderStepped:Connect(function() 
    if _G.XenoScriptID ~= currentScriptID then return end
    local c = lp.Character local h = c and c:FindFirstChildOfClass("Humanoid") local r = c and c:FindFirstChild("HumanoidRootPart") 
    if U:IsKeyDown(Enum.KeyCode.Space) and jumpToggle and not fly and h and r then 
        if h:GetState() ~= Enum.HumanoidStateType.Jumping and h:GetState() ~= Enum.HumanoidStateType.Freefall then r.AssemblyLinearVelocity = Vector3.new(r.AssemblyLinearVelocity.X, jPwr, r.AssemblyLinearVelocity.Z) end 
    end 
end)

local ev2 = R.PostSimulation:Connect(function() 
    if _G.XenoScriptID ~= currentScriptID then return end
    local c = lp.Character local h = c and c:FindFirstChildOfClass("Humanoid") local r = c and c:FindFirstChild("HumanoidRootPart") 
    if h and r and not fly and speedToggle and h.MoveDirection.Magnitude > 0 then r.CFrame = r.CFrame + (h.MoveDirection * (wSpd / 150)) end 
end)

-- Потоковые циклы проверки и синхронизации
task.spawn(function() while task.wait(0.5) do if _G.XenoScriptID ~= currentScriptID then break end if espToggle then updateESP() end end end)
P.PlayerAdded:Connect(function(p) p.CharacterAdded:Connect(function() if espToggle then task.wait(0.5) updateESP() end end) end)
P.PlayerRemoving:Connect(function() if espToggle then task.wait(0.1) updateESP() end end)

task.spawn(function() while task.wait(0.5) do if _G.XenoScriptID ~= currentScriptID then break end if resetConfirm and (tick() - confirmTime > 3) then resetConfirm = false rBtn.Size = UDim2.new(0, 150, 0, 30) rBtn.Position = UDim2.new(0, 285, 0, 190) rBtn.BackgroundColor3 = Color3.fromRGB(55, 55, 55) rBtn.TextSize = 13 rBtn.Text = "СБРОС" end end end)
task.spawn(function() while task.wait(1) do if _G.XenoScriptID ~= currentScriptID then break end if afkToggle then afkSeconds = afkSeconds + 1 updT() end timeLabelTop.Text = os.date("%X") end end)

-- Защита от AFK-кика и функция очистки памяти при перезапуске
local idledConn = lp.Idled:Connect(function() if afkToggle then VU:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame) task.wait(0.5) VU:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame) end end)

_G.XenoFlyDisconnect = function() 
    pcall(function() ev:Disconnect() end) 
    pcall(function() ev2:Disconnect() end) 
    pcall(function() idledConn:Disconnect() end)
    
    local cam = workspace.CurrentCamera
    if cam then cam.FieldOfView = 70 end
    clearESP() 
end
