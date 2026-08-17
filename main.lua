-- Полная очистка старых потоков и элементов интерфейса для стабильности
local oldGui = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui"):FindFirstChild("XenoStableGui")
if oldGui then oldGui:Destroy() end
if _G.XenoToggleGuiConn then _G.XenoToggleGuiConn:Disconnect() _G.XenoToggleGuiConn = nil end
if _G.XenoFlyDisconnect then _G.XenoFlyDisconnect() end

_G.XenoScriptID = tick()
local currentScriptID = _G.XenoScriptID

local P = game:GetService("Players")
local R = game:GetService("RunService")
local U = game:GetService("UserInputService")
local VU = game:GetService("VirtualUser") 
local lp = P.LocalPlayer

-- Настройки состояний
local fly, fSpd, wSpd, jPwr = false, 50, 16, 50
local isBind, speedToggle, jumpToggle, afkToggle = false, false, false, false
local afkSeconds, resetConfirm, confirmTime, espToggle = 0, false, 0, false
local flyKey = Enum.KeyCode.F
local blockFly = false
local guiVisible = true
local toggleGuiKey = Enum.KeyCode.Insert

local bv, bg
local sg = Instance.new("ScreenGui", lp.PlayerGui)
sg.Name = "XenoStableGui"
sg.ResetOnSpawn = false

local circleBtn = Instance.new("TextButton", sg)
circleBtn.Size = UDim2.new(0, 55, 0, 45) circleBtn.Position = UDim2.new(0, 10, 0, 10)
circleBtn.BackgroundColor3 = Color3.fromRGB(15, 15, 15) circleBtn.Font = Enum.Font.SourceSansBold
circleBtn.TextSize = 16 circleBtn.TextColor3 = Color3.fromRGB(255, 255, 255) circleBtn.Text = "YnSc"
circleBtn.Active = true circleBtn.Draggable = true

local corner = Instance.new("UICorner", circleBtn) corner.CornerRadius = UDim.new(0.4, 0)
local stroke = Instance.new("UIStroke", circleBtn) stroke.Thickness = 3 stroke.Color = Color3.fromRGB(75, 255, 75) stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

-- Главное окно
local mf = Instance.new("Frame", sg)
mf.Size = UDim2.new(0, 450, 0, 310) mf.AnchorPoint = Vector2.new(0.5, 0.5) mf.Position = UDim2.new(0.5, 0, 0.4, 0)
mf.BackgroundColor3 = Color3.fromRGB(30, 30, 30) mf.BorderColor3 = Color3.fromRGB(60, 60, 60) mf.Active = true mf.Draggable = true

local function lbl(t, s, p, f)
    local l = Instance.new("TextLabel", mf) l.Size = s l.Position = p l.BackgroundTransparency = 1
    l.Font = f or Enum.Font.SourceSans l.TextSize = f and 16 or 14 l.TextColor3 = Color3.fromRGB(255, 255, 255) l.Text = t
    return l
end

local function toggleGui()
    guiVisible = not guiVisible 
    mf.Visible = guiVisible
    stroke.Color = guiVisible and Color3.fromRGB(75, 255, 75) or Color3.fromRGB(255, 75, 75)
end
local function box(t, p)
    local b = Instance.new("TextBox", mf) b.Size = UDim2.new(0, 60, 0, 30) b.Position = p
    b.BackgroundColor3 = Color3.fromRGB(45, 45, 45) b.BorderSizePixel = 0 b.Font = Enum.Font.SourceSansBold
    b.TextSize = 14 b.TextColor3 = Color3.fromRGB(255, 255, 255) b.Text = t
    return b
end

local function tgl(p)
    local t = Instance.new("TextButton", mf) t.Size = UDim2.new(0, 30, 0, 30) t.Position = p
    t.BackgroundColor3 = Color3.fromRGB(255, 75, 75) t.Font = Enum.Font.SourceSansBold t.TextSize = 16
    t.TextColor3 = Color3.fromRGB(255, 255, 255) t.Text = "X"
    return t
end

local mainTitle = lbl("YNIVERSAL SCRIPT MENU", UDim2.new(0, 250, 0, 30), UDim2.new(0, 15, 0, 0), Enum.Font.SourceSansBold)
mainTitle.TextXAlignment = Enum.TextXAlignment.Left
local timeLabelTop = lbl("00:00:00", UDim2.new(0, 100, 0, 30), UDim2.new(0, 335, 0, 0), Enum.Font.SourceSansBold)
timeLabelTop.TextXAlignment = Enum.TextXAlignment.Right

lbl("УПРАВЛЕНИЕ ПОЛЕТОМ", UDim2.new(0, 190, 0, 20), UDim2.new(0, 15, 0, 35), Enum.Font.SourceSansBold).TextColor3 = Color3.fromRGB(150, 150, 150)
lbl("НАСТРОЙКИ ХАРАКТЕРИСТИК", UDim2.new(0, 190, 0, 20), UDim2.new(0, 225, 0, 35), Enum.Font.SourceSansBold).TextColor3 = Color3.fromRGB(150, 150, 150)

local btn = Instance.new("TextButton", mf) btn.Size = UDim2.new(0, 180, 0, 35) btn.Position = UDim2.new(0, 15, 0, 60)
btn.BackgroundColor3 = Color3.fromRGB(255, 75, 75) btn.Font = Enum.Font.SourceSansBold btn.TextSize = 15 btn.TextColor3 = Color3.fromRGB(255, 255, 255) btn.Text = "ВКЛЮЧИТЬ ПОЛЕТ"

local bBtn = Instance.new("TextButton", mf) bBtn.Size = UDim2.new(0, 180, 0, 25) bBtn.Position = UDim2.new(0, 15, 0, 105)
bBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 45) bBtn.Font = Enum.Font.SourceSansBold bBtn.TextSize = 13 bBtn.TextColor3 = Color3.fromRGB(220, 220, 220) bBtn.Text = "Бинд Fly: [ F ]"

lbl("Скорость полета:", UDim2.new(0, 90, 0, 30), UDim2.new(0, 15, 0, 140))
local fInp = box(tostring(fSpd), UDim2.new(0, 115, 0, 140))
lbl("Скорость бега:", UDim2.new(0, 90, 0, 30), UDim2.new(0, 225, 0, 60))
lbl("Сила прыжка:", UDim2.new(0, 90, 0, 30), UDim2.new(0, 225, 0, 105))

local sInp = box(tostring(wSpd), UDim2.new(0, 315, 0, 60)) local jInp = box(tostring(jPwr), UDim2.new(0, 315, 0, 105))
local sTgl = tgl(UDim2.new(0, 385, 0, 60)) local jTgl = tgl(UDim2.new(0, 385, 0, 105))

local afkBtn = Instance.new("TextButton", mf) afkBtn.Size = UDim2.new(0, 420, 0, 35) afkBtn.Position = UDim2.new(0, 15, 0, 185)
afkBtn.BackgroundColor3 = Color3.fromRGB(255, 75, 75) afkBtn.Font = Enum.Font.SourceSansBold afkBtn.TextSize = 14 afkBtn.TextColor3 = Color3.fromRGB(255, 255, 255) afkBtn.Text = "ВКЛЮЧИТЬ АНТИ-АФК"

local timeLabel = Instance.new("TextLabel", mf) timeLabel.Size = UDim2.new(0, 200, 0, 30) timeLabel.Position = UDim2.new(0, 15, 0, 225)
timeLabel.BackgroundTransparency = 1 timeLabel.Font = Enum.Font.SourceSansBold timeLabel.TextSize = 15 timeLabel.TextColor3 = Color3.fromRGB(255, 255, 255) timeLabel.Text = "Время АФК: 00:00:00" timeLabel.TextXAlignment = Enum.TextXAlignment.Left

local rBtn = Instance.new("TextButton", mf) rBtn.Size = UDim2.new(0, 150, 0, 30) rBtn.Position = UDim2.new(0, 285, 0, 225)
rBtn.BackgroundColor3 = Color3.fromRGB(55, 55, 55) rBtn.Font = Enum.Font.SourceSansBold rBtn.TextSize = 13 rBtn.TextColor3 = Color3.fromRGB(255, 255, 255) rBtn.Text = "СБРОС" rBtn.BorderSizePixel = 0

local espBtn = Instance.new("TextButton", mf) espBtn.Size = UDim2.new(0, 420, 0, 30) espBtn.Position = UDim2.new(0, 15, 0, 265)
espBtn.BackgroundColor3 = Color3.fromRGB(255, 75, 75) espBtn.Font = Enum.Font.SourceSansBold espBtn.TextSize = 13 espBtn.TextColor3 = Color3.fromRGB(255, 255, 255) espBtn.Text = "ESP УЛЬТРА: ВЫКЛ" espBtn.BorderSizePixel = 0
local function clearESP()
    for _, p in ipairs(P:GetPlayers()) do
        if p.Character and p.Character:FindFirstChild("XenoSkinESP") then p.Character.XenoSkinESP:Destroy() end
        if p.Character and p.Character:FindFirstChild("XenoTextESP") then p.Character.XenoTextESP:Destroy() end
    end
end

local function updateESP()
    clearESP() if not espToggle then return end
    local myRoot = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
    for _, p in ipairs(P:GetPlayers()) do
        if p ~= lp and p.Character and p.Character:FindFirstChildOfClass("Humanoid") and p.Character:FindFirstChildOfClass("Humanoid").Health > 0 and p.Character:FindFirstChild("HumanoidRootPart") then
            local targetHum = p.Character:FindFirstChildOfClass("Humanoid")
            local targetRoot = p.Character.HumanoidRootPart
            local hl = Instance.new("Highlight") hl.Name = "XenoSkinESP" hl.Parent = p.Character
            hl.FillColor = Color3.fromRGB(255, 0, 0) hl.FillTransparency = 0.5 hl.OutlineColor = Color3.fromRGB(255, 255, 255)
            hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
            local distance = myRoot and math.floor((myRoot.Position - targetRoot.Position).Magnitude) or 0
            local bb = Instance.new("BillboardGui", p.Character) bb.Name = "XenoTextESP" bb.AlwaysOnTop = true bb.Size = UDim2.new(5, 0, 2, 0) bb.ExtentsOffset = Vector3.new(0, 3, 0) bb.Adornee = targetRoot
            local tl = Instance.new("TextLabel", bb) tl.Size = UDim2.new(1, 0, 1, 0) tl.BackgroundTransparency = 1 tl.Font = Enum.Font.SourceSansBold tl.TextSize = 13 tl.TextColor3 = Color3.fromRGB(255, 255, 255) tl.TextStrokeTransparency = 0 tl.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
            tl.Text = string.format("%s\n[%d HP] [%dm]", p.Name, math.floor(targetHum.Health), distance)
        end
    end
end

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
circleBtn.MouseButton1Click:Connect(toggleGui)
espBtn.MouseButton1Click:Connect(function() espToggle = not espToggle espBtn.Text = espToggle and "ESP УЛЬТРА: ВКЛ" or "ESP УЛЬТРА: ВЫКЛ" espBtn.BackgroundColor3 = espToggle and Color3.fromRGB(75, 255, 75) or Color3.fromRGB(255, 75, 75) updateESP() end)
btn.MouseButton1Click:Connect(toggleFly)
fInp.FocusLost:Connect(function() fSpd = tonumber(fInp.Text) or fSpd fInp.Text = tostring(fSpd) end) 
sInp.FocusLost:Connect(function() wSpd = tonumber(sInp.Text) or wSpd sInp.Text = tostring(wSpd) end) 
jInp.FocusLost:Connect(function() jPwr = tonumber(jInp.Text) or jPwr jInp.Text = tostring(jPwr) end)

sTgl.MouseButton1Click:Connect(function() speedToggle = not speedToggle sTgl.Text = speedToggle and "✔" or "X" sTgl.BackgroundColor3 = speedToggle and Color3.fromRGB(75, 255, 75) or Color3.fromRGB(255, 75, 75) end)
jTgl.MouseButton1Click:Connect(function() jumpToggle = not jumpToggle jTgl.Text = jumpToggle and "✔" or "X" jTgl.BackgroundColor3 = jumpToggle and Color3.fromRGB(75, 255, 75) or Color3.fromRGB(255, 75, 75) end)
afkBtn.MouseButton1Click:Connect(function() afkToggle = not afkToggle afkBtn.BackgroundColor3 = afkToggle and Color3.fromRGB(75, 255, 75) or Color3.fromRGB(255, 75, 75) afkBtn.Text = afkToggle and "АНТИ-АФК: РАБОТАЕТ" or "ВКЛЮЧИТЬ АНТИ-АФК" updT() end)

rBtn.MouseButton1Click:Connect(function() 
    if not afkToggle then afkSeconds = 0 updT() else 
        if not resetConfirm then resetConfirm = true confirmTime = tick() rBtn.Size = UDim2.new(0, 250, 0, 30) rBtn.Position = UDim2.new(0, 185, 0, 225) rBtn.BackgroundColor3 = Color3.fromRGB(200, 150, 50) rBtn.TextSize = 11 rBtn.Text = "Вы точно хотите сбросить время?" 
        else resetConfirm = false afkSeconds = 0 updT() rBtn.Size = UDim2.new(0, 150, 0, 30) rBtn.Position = UDim2.new(0, 285, 0, 225) rBtn.BackgroundColor3 = Color3.fromRGB(55, 55, 55) rBtn.TextSize = 13 rBtn.Text = "СБРОС" end 
    end 
end)

bBtn.MouseButton1Click:Connect(function() isBind = true bBtn.Text = "Нажмите клавишу..." bBtn.BackgroundColor3 = Color3.fromRGB(70, 70, 70) end)

-- ЗАЩИЩЕННЫЙ ДВУХРЕЖИМНЫЙ СЛУШАТЕЛЬ КЛАВИШ
_G.XenoToggleGuiConn = U.InputBegan:Connect(function(input, gameProcessed)
    -- Режим 1: Если мы сейчас переназначаем клавишу
    if isBind and input.UserInputType == Enum.UserInputType.Keyboard then
        flyKey = input.KeyCode
        isBind = false
        bBtn.Text = "Бинд Fly: [ " .. flyKey.Name .. " ]"
        bBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
        return -- КРИТИЧЕСКИЙ ВЫХОД: Предотвращает ложную авто-активацию полёта!
    end
    
    -- Режим 2: Обычное игровое прослушивание кнопок скрипта
    if not gameProcessed then
        if input.KeyCode == toggleGuiKey then toggleGui() end
        if input.KeyCode == flyKey and not isBind and not U:GetFocusedTextBox() then toggleFly() end
    end
end)

local ev = R.RenderStepped:Connect(function() 
    local c = lp.Character local h = c and c:FindFirstChildOfClass("Humanoid") local r = c and c:FindFirstChild("HumanoidRootPart") 
    if U:IsKeyDown(Enum.KeyCode.Space) and jumpToggle and not fly and h and r then 
        if h:GetState() ~= Enum.HumanoidStateType.Jumping and h:GetState() ~= Enum.HumanoidStateType.Freefall then r.AssemblyLinearVelocity = Vector3.new(r.AssemblyLinearVelocity.X, jPwr, r.AssemblyLinearVelocity.Z) end 
    end 
end)

local ev2 = R.PostSimulation:Connect(function() local c = lp.Character local h = c and c:FindFirstChildOfClass("Humanoid") local r = c and c:FindFirstChild("HumanoidRootPart") if h and r and not fly and speedToggle and h.MoveDirection.Magnitude > 0 then r.CFrame = r.CFrame + (h.MoveDirection * (wSpd / 150)) end end)

task.spawn(function() while true do task.wait(0.5) if _G.XenoScriptID ~= currentScriptID then break end if espToggle then updateESP() end end end)
P.PlayerAdded:Connect(function(p) p.CharacterAdded:Connect(function() if espToggle then task.wait(0.5) updateESP() end end) end)
P.PlayerRemoving:Connect(function() if espToggle then updateESP() end end)

task.spawn(function() while true do task.wait(0.5) if _G.XenoScriptID ~= currentScriptID then break end if resetConfirm and (tick() - confirmTime > 3) then resetConfirm = false rBtn.Size = UDim2.new(0, 150, 0, 30) rBtn.Position = UDim2.new(0, 285, 0, 225) rBtn.BackgroundColor3 = Color3.fromRGB(55, 55, 55) rBtn.TextSize = 13 rBtn.Text = "СБРОС" end end end)

task.spawn(function() 
    while true do task.wait(1) 
        if _G.XenoScriptID ~= currentScriptID then break end 
        if afkToggle then afkSeconds = afkSeconds + 1 updT() end 
        timeLabelTop.Text = os.date("%X") 
    end 
end)

lp.Idled:Connect(function() if afkToggle then VU:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame) task.wait(0.5) VU:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame) end end)
_G.XenoFlyDisconnect = function() pcall(function() ev:Disconnect() end) pcall(function() ev2:Disconnect() end) clearESP() end
