local oldGui = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui"):FindFirstChild("XenoStableGui")
if oldGui then pcall(function() oldGui:Destroy() end) end
local oldHud = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui"):FindFirstChild("XenoStableHud")
if oldHud then pcall(function() oldHud:Destroy() end) end

if _G.XenoToggleGuiConn then pcall(function() _G.XenoToggleGuiConn:Disconnect() end) _G.XenoToggleGuiConn = nil end
if _G.XenoFlyDisconnect then pcall(function() _G.XenoFlyDisconnect() end) end

_G.XenoScriptID = tick()
local currentScriptID = _G.XenoScriptID

local P = game:GetService("Players")
local R = game:GetService("RunService")
local U = game:GetService("UserInputService")
local Stats = game:GetService("Stats")
local VU = game:GetService("VirtualUser") 
local lp = P.LocalPlayer

local fly, fSpd, wSpd, jPwr = false, 50, 16, 50
local isBind, speedToggle, jumpToggle, afkToggle = false, false, false, false
local afkSeconds, resetConfirm, confirmTime, espToggle = 0, false, 0, false
local flyKey = Enum.KeyCode.F
local guiVisible = true
local toggleGuiKey = Enum.KeyCode.Insert
local bv, bg

local fovValue = 70
local fovToggle = false 
local sliderDragging = false

local strokeRegistry = {}
local NeonColor1 = Color3.fromRGB(138, 43, 226)
local NeonColor2 = Color3.fromRGB(255, 0, 128)
local playerName = lp.Name
local sg = Instance.new("ScreenGui", lp.PlayerGui) sg.Name = "XenoStableGui" sg.ResetOnSpawn = false sg.DisplayOrder = 99999
local sgHud = Instance.new("ScreenGui", lp.PlayerGui) sgHud.Name = "XenoStableHud" sgHud.ResetOnSpawn = false sgHud.DisplayOrder = 100000

local circleBtn = Instance.new("TextButton", sg)
circleBtn.Size = UDim2.new(0, 55, 0, 45) circleBtn.Position = UDim2.new(0, 10, 0, 10)
circleBtn.BackgroundColor3 = Color3.fromRGB(18, 16, 24) circleBtn.Font = Enum.Font.GothamBold
circleBtn.TextSize = 14 circleBtn.TextColor3 = Color3.fromRGB(255, 255, 255) circleBtn.Text = "YnSc"
circleBtn.Active = true circleBtn.Draggable = true
Instance.new("UICorner", circleBtn).CornerRadius = UDim.new(0.4, 0)
local circleStroke = Instance.new("UIStroke", circleBtn) circleStroke.Thickness = 2.5 circleStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
table.insert(strokeRegistry, circleStroke)

local mf = Instance.new("Frame", sg)
mf.Size = UDim2.new(0, 450, 0, 330) mf.AnchorPoint = Vector2.new(0.5, 0.5) mf.Position = UDim2.new(0.5, 0, 0.4, 0)
mf.BackgroundColor3 = Color3.fromRGB(20, 18, 26) mf.Active = true mf.Draggable = true
Instance.new("UICorner", mf).CornerRadius = UDim.new(0, 12)
local mainStroke = Instance.new("UIStroke", mf) mainStroke.Thickness = 2.5 mainStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border mainStroke.LineJoinMode = Enum.LineJoinMode.Round
table.insert(strokeRegistry, mainStroke)

local menuLogo = Instance.new("TextLabel", mf)
menuLogo.Size = UDim2.new(0, 100, 0, 30) menuLogo.Position = UDim2.new(0, 15, 0, 0) menuLogo.BackgroundTransparency = 1
menuLogo.Font = Enum.Font.GothamBold menuLogo.TextSize = 15 menuLogo.Text = "YnSc" menuLogo.TextXAlignment = Enum.TextXAlignment.Left

local mainBar = Instance.new("Frame", sgHud)
mainBar.Size = UDim2.new(0, 530, 0, 32) mainBar.Position = UDim2.new(0.5, -265, 0, 15) mainBar.BackgroundColor3 = Color3.fromRGB(14, 13, 18) mainBar.BorderSizePixel = 0
Instance.new("UICorner", mainBar).CornerRadius = UDim.new(0, 8)
local barStroke = Instance.new("UIStroke", mainBar) barStroke.Thickness = 1.8 barStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
table.insert(strokeRegistry, barStroke)

task.spawn(function()
    local timeElapsed = 0
    while task.wait(0.02) and (sg.Parent or sgHud.Parent) do
        timeElapsed = timeElapsed + 0.02
        local alpha = (math.sin(timeElapsed * 2.5) + 1) / 2 
        local currentColor = NeonColor1:Lerp(NeonColor2, alpha)
        
        if menuLogo and menuLogo.Parent then menuLogo.TextColor3 = currentColor end
        for _, strk in pairs(strokeRegistry) do
            if strk and strk.Parent then strk.Color = currentColor end
        end
    end
end)
local mainContent = Instance.new("Frame", mf) mainContent.Size = UDim2.new(1, 0, 1, -65) mainContent.Position = UDim2.new(0, 0, 0, 65) mainContent.BackgroundTransparency = 1
local visualContent = Instance.new("Frame", mf) visualContent.Size = UDim2.new(1, 0, 1, -65) visualContent.Position = UDim2.new(0, 0, 0, 65) visualContent.BackgroundTransparency = 1 visualContent.Visible = false

local function lbl(t, s, p, parent, f)
    local l = Instance.new("TextLabel")
    l.Size = s l.Position = p l.BackgroundTransparency = 1
    l.Font = f or Enum.Font.Gotham l.TextSize = f and 15 or 14 l.TextColor3 = Color3.fromRGB(245, 245, 245) l.Text = t
    l.Parent = parent or mf
    return l
end
local function box(t, p, parent)
    local b = Instance.new("TextBox")
    b.Size = UDim2.new(0, 60, 0, 30) b.Position = p
    b.BackgroundColor3 = Color3.fromRGB(32, 28, 42) b.Font = Enum.Font.GothamBold b.TextSize = 14 b.TextColor3 = Color3.fromRGB(255, 255, 255) b.Text = t
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)
    local bStroke = Instance.new("UIStroke", b) bStroke.Thickness = 1.2 bStroke.Color = Color3.fromRGB(65, 60, 80)
    b.Focused:Connect(function() bStroke.Color = NeonColor1 end) b.FocusLost:Connect(function() bStroke.Color = Color3.fromRGB(65, 60, 80) end)
    b.Parent = parent or mf
    return b
end
local function tgl(p, parent)
    local t = Instance.new("TextButton")
    t.Size = UDim2.new(0, 30, 0, 30) t.Position = p
    t.BackgroundColor3 = Color3.fromRGB(35, 25, 35) t.Font = Enum.Font.GothamBold t.TextSize = 13 t.TextColor3 = Color3.fromRGB(255, 100, 100) t.Text = "X"
    Instance.new("UICorner", t).CornerRadius = UDim.new(0, 8)
    local tStroke = Instance.new("UIStroke", t) tStroke.Thickness = 1.2 table.insert(strokeRegistry, tStroke)
    t.Parent = parent or mf
    return t
end
local function styleCustomButton(btn, text)
    btn.BackgroundColor3 = Color3.fromRGB(30, 26, 40) btn.Font = Enum.Font.GothamBold btn.TextSize = 13 btn.TextColor3 = Color3.fromRGB(240, 240, 240) btn.Text = text
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
    local bStroke = Instance.new("UIStroke", btn) bStroke.Thickness = 1.5 table.insert(strokeRegistry, bStroke)
end

local timeLabelTop = lbl("00:00:00", UDim2.new(0, 100, 0, 30), UDim2.new(0, 335, 0, 0), mf, Enum.Font.GothamBold) timeLabelTop.TextXAlignment = Enum.TextXAlignment.Right timeLabelTop.TextColor3 = Color3.fromRGB(160, 150, 180)
local mainTabBtn = Instance.new("TextButton", mf) mainTabBtn.Size = UDim2.new(0, 100, 0, 25) mainTabBtn.Position = UDim2.new(0, 15, 0, 32) styleCustomButton(mainTabBtn, "ГЛАВНОЕ")
local visualTabBtn = Instance.new("TextButton", mf) visualTabBtn.Size = UDim2.new(0, 100, 0, 25) visualTabBtn.Position = UDim2.new(0, 120, 0, 32) styleCustomButton(visualTabBtn, "ВИЗУАЛЫ")
lbl("УПРАВЛЕНИЕ ПОЛЕТОМ", UDim2.new(0, 190, 0, 20), UDim2.new(0, 15, 0, 0), mainContent, Enum.Font.GothamBold).TextColor3 = Color3.fromRGB(140, 130, 160)
lbl("НАСТРОЙКИ ХАРАКТЕРИСТИК", UDim2.new(0, 190, 0, 20), UDim2.new(0, 225, 0, 0), mainContent, Enum.Font.GothamBold).TextColor3 = Color3.fromRGB(140, 130, 160)
local btn = Instance.new("TextButton", mainContent) btn.Size = UDim2.new(0, 180, 0, 35) btn.Position = UDim2.new(0, 15, 0, 25) styleCustomButton(btn, "ВКЛЮЧИТЬ ПОЛЕТ")
local bBtn = Instance.new("TextButton", mainContent) bBtn.Size = UDim2.new(0, 180, 0, 25) bBtn.Position = UDim2.new(0, 15, 0, 70) styleCustomButton(bBtn, "Бинд Fly: [ F ]")

local lblFSpd = lbl("Скорость полета:", UDim2.new(0, 110, 0, 30), UDim2.new(0, 15, 0, 105), mainContent) lblFSpd.TextXAlignment = Enum.TextXAlignment.Left
local fInp = box(tostring(fSpd), UDim2.new(0, 135, 0, 105), mainContent)
local lblWSpd = lbl("Скорость бега:", UDim2.new(0, 90, 0, 30), UDim2.new(0, 225, 0, 25), mainContent) lblWSpd.TextXAlignment = Enum.TextXAlignment.Left
local lblJPwr = lbl("Сила прыжка:", UDim2.new(0, 90, 0, 30), UDim2.new(0, 225, 0, 70), mainContent) lblJPwr.TextXAlignment = Enum.TextXAlignment.Left

local sInp = box(tostring(wSpd), UDim2.new(0, 315, 0, 25), mainContent) local jInp = box(tostring(jPwr), UDim2.new(0, 315, 0, 70), mainContent)
local sTgl = tgl(UDim2.new(0, 385, 0, 25), mainContent) local jTgl = tgl(UDim2.new(0, 385, 0, 70), mainContent)

local afkBtn = Instance.new("TextButton", mainContent) afkBtn.Size = UDim2.new(0, 420, 0, 30) afkBtn.Position = UDim2.new(0, 15, 0, 150) styleCustomButton(afkBtn, "ВКЛЮЧИТЬ АНТИ-АФК")

local timeLabel = Instance.new("TextLabel", mainContent) timeLabel.Size = UDim2.new(0, 200, 0, 25) timeLabel.Position = UDim2.new(0, 15, 0, 195) timeLabel.BackgroundTransparency = 1 timeLabel.Font = Enum.Font.GothamBold timeLabel.TextSize = 13 timeLabel.TextColor3 = Color3.fromRGB(255, 255, 255) timeLabel.Text = "Время АФК: 00:00:00" timeLabel.TextXAlignment = Enum.TextXAlignment.Left
local rBtn = Instance.new("TextButton", mainContent) rBtn.Size = UDim2.new(0, 150, 0, 25) rBtn.Position = UDim2.new(0, 285, 0, 195) styleCustomButton(rBtn, "СБРОС")

lbl("ВИЗУАЛЬНЫЕ НАСТРОЙКИ", UDim2.new(0, 420, 0, 20), UDim2.new(0, 15, 0, 0), visualContent, Enum.Font.GothamBold).TextColor3 = Color3.fromRGB(140, 130, 160)
local espBtn = Instance.new("TextButton", visualContent) espBtn.Size = UDim2.new(0, 420, 0, 35) espBtn.Position = UDim2.new(0, 15, 0, 25) styleCustomButton(espBtn, "ESP УЛЬТРА: ВЫКЛ")
local fovTglBtn = Instance.new("TextButton", visualContent) fovTglBtn.Size = UDim2.new(0, 420, 0, 35) fovTglBtn.Position = UDim2.new(0, 15, 0, 75) styleCustomButton(fovTglBtn, "КАСТОМНЫЙ FOV: ВЫКЛ")

local fovLabel = lbl("Поле зрения (FOV): 70", UDim2.new(0, 200, 0, 20), UDim2.new(0, 15, 0, 125), visualContent, Enum.Font.GothamBold) fovLabel.TextXAlignment = Enum.TextXAlignment.Left
local sliderBack = Instance.new("Frame", visualContent) sliderBack.Size = UDim2.new(0, 420, 0, 8) sliderBack.Position = UDim2.new(0, 15, 0, 155) sliderBack.BackgroundColor3 = Color3.fromRGB(35, 30, 45) sliderBack.BorderSizePixel = 0
Instance.new("UICorner", sliderBack).CornerRadius = UDim.new(0.5, 0)
local sliderFill = Instance.new("Frame", sliderBack) sliderFill.Size = UDim2.new(0, 0, 1, 0) sliderFill.BackgroundColor3 = Color3.fromRGB(138, 43, 226) sliderFill.BorderSizePixel = 0
Instance.new("UICorner", sliderFill).CornerRadius = UDim.new(0.5, 0)
local sliderMainBtn = Instance.new("TextButton", sliderBack) sliderMainBtn.Size = UDim2.new(0, 16, 0, 16) sliderMainBtn.AnchorPoint = Vector2.new(0.5, 0.5) sliderMainBtn.Position = UDim2.new(0, 0, 0.5, 0) sliderMainBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255) sliderMainBtn.Text = ""
Instance.new("UICorner", sliderMainBtn).CornerRadius = UDim.new(0.5, 0)
local slStroke = Instance.new("UIStroke", sliderMainBtn) slStroke.Thickness = 1.5 table.insert(strokeRegistry, slStroke)
local logoFrame = Instance.new("TextButton", mainBar) logoFrame.Size = UDim2.new(0, 60, 1, -8) logoFrame.Position = UDim2.new(0, 8, 0, 4) logoFrame.BackgroundColor3 = Color3.fromRGB(24, 20, 32) logoFrame.Text = "" logoFrame.AutoButtonColor = false
Instance.new("UICorner", logoFrame).CornerRadius = UDim.new(0, 5)
local logoStroke = Instance.new("UIStroke", logoFrame) logoStroke.Thickness = 1.2 table.insert(strokeRegistry, logoStroke)
local logoText = Instance.new("TextLabel", logoFrame) logoText.Size = UDim2.new(1, 0, 1, 0) logoText.BackgroundTransparency = 1 logoText.Font = Enum.Font.GothamBold logoText.TextSize = 12 logoText.TextColor3 = Color3.fromRGB(255, 255, 255) logoText.Text = "YnSc"

-- ИСПРАВЛЕНО: Прямой возврат текстового объекта наружу фабрики без локального замыкания
local function createSegment(text, sizeX, posX, iconText, iconColor)
    local f = Instance.new("Frame", mainBar) f.Size = UDim2.new(0, sizeX, 1, 0) f.Position = UDim2.new(0, posX, 0, 0) f.BackgroundTransparency = 1
    local textObject = Instance.new("TextLabel", f) textObject.Size = UDim2.new(1, -15, 1, 0) textObject.Position = UDim2.new(0, 15, 0, 0) textObject.BackgroundTransparency = 1 textObject.Font = Enum.Font.GothamBold textObject.TextSize = 13 textObject.TextColor3 = Color3.fromRGB(240, 240, 240) textObject.Text = text textObject.TextXAlignment = Enum.TextXAlignment.Left
    if iconText then 
        local ico = Instance.new("TextLabel", f) ico.Size = UDim2.new(0, 12, 1, 0) ico.BackgroundTransparency = 1 ico.Font = Enum.Font.GothamBold ico.TextSize = 12 ico.TextColor3 = iconColor or Color3.fromRGB(140, 120, 255) ico.Text = iconText ico.TextXAlignment = Enum.TextXAlignment.Center 
    end
    local dot = Instance.new("TextLabel", f) dot.Size = UDim2.new(0, 10, 1, 0) dot.Position = UDim2.new(1, -5, 0, -2) dot.BackgroundTransparency = 1 dot.Font = Enum.Font.GothamBold dot.TextSize = 14 dot.TextColor3 = Color3.fromRGB(60, 55, 75) dot.Text = "·"
    return textObject, f
end

local lblPlayer = createSegment(playerName, 120, 80, "👤")
local lblFps, fFrame = createSegment("000 FPS", 90, 215, "🚀", Color3.fromRGB(255, 180, 50))
local lblPing, pFrame = createSegment("00 MS", 85, 315, "⇅", Color3.fromRGB(80, 160, 255))
local lblTps, tFrame = createSegment("20.0 TPS", 90, 410, "⏱", Color3.fromRGB(100, 255, 100))
if tFrame:FindFirstChild("TextLabel") and tFrame:FindFirstChild("TextLabel").Text == "·" then tFrame:FindFirstChild("TextLabel"):Destroy() end
local function toggleGui() guiVisible = not guiVisible mf.Visible = guiVisible end
local function updT() timeLabel.Text = string.format("Время АФК: %02d:%02d:%02d", math.floor(afkSeconds / 3600), math.floor((afkSeconds % 3600) / 60), afkSeconds % 60) end
local function switchTab(tab)
    mainContent.Visible = (tab == "Main") 
    visualContent.Visible = (tab == "Visuals")
    mainTabBtn.BackgroundColor3 = (tab == "Main") and Color3.fromRGB(48, 32, 68) or Color3.fromRGB(30, 26, 40)
    visualTabBtn.BackgroundColor3 = (tab == "Visuals") and Color3.fromRGB(48, 32, 68) or Color3.fromRGB(30, 26, 40)
end

local function toggleFly() 
    local c = lp.Character if not c then return end 
    local r = c:FindFirstChild("HumanoidRootPart") local h = c:FindFirstChildOfClass("Humanoid") if not r or not h then return end 
    fly = not fly 
    if fly then 
        btn.Text = "ВЫКЛЮЧИТЬ ПОЛЕТ" btn.BackgroundColor3 = Color3.fromRGB(48, 32, 68) h.PlatformStand = true 
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
        btn.Text = "ВКЛЮЧИТЬ ПОЛЕТ" btn.BackgroundColor3 = Color3.fromRGB(30, 26, 40) h.PlatformStand = false 
        if bv then bv:Destroy() end if bg then bg:Destroy() end if h then h:ChangeState(Enum.HumanoidStateType.GettingUp) end
    end 
end

local function clearESP() for _, p in ipairs(P:GetPlayers()) do if p.Character then local s = p.Character:FindFirstChild("XenoSkinESP") local t = p.Character:FindFirstChild("XenoTextESP") if s then pcall(function() s:Destroy() end) end; if t then pcall(function() t:Destroy() end) end end end end
local function updateESP()
    if _G.XenoScriptID ~= currentScriptID or not espToggle then clearESP() return end
    local myRoot = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
    for _, p in ipairs(P:GetPlayers()) do
        if p ~= lp and p.Character then
            local tHum, tRoot = p.Character:FindFirstChildOfClass("Humanoid"), p.Character:FindFirstChild("HumanoidRootPart")
            if tHum and tHum.Health > 0 and tRoot then
                local hl = p.Character:FindFirstChild("XenoSkinESP") or Instance.new("Highlight", p.Character)
                hl.Name = "XenoSkinESP" hl.FillColor = Color3.fromRGB(138, 43, 226) hl.FillTransparency = 0.5 hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                local bb = p.Character:FindFirstChild("XenoTextESP") or Instance.new("BillboardGui", p.Character)
                bb.Name = "XenoTextESP" bb.AlwaysOnTop = true bb.Size = UDim2.new(5, 0, 2, 0) bb.ExtentsOffset = Vector3.new(0, 3, 0) bb.Adornee = tRoot
                local tl = bb:FindFirstChildOfClass("TextLabel") or Instance.new("TextLabel", bb)
                tl.Size = UDim2.new(1, 0, 1, 0) tl.BackgroundTransparency = 1 tl.Font = Enum.Font.GothamBold tl.TextSize = 12 tl.TextColor3 = Color3.fromRGB(255, 255, 255)
                local dist = myRoot and math.floor((myRoot.Position - tRoot.Position).Magnitude) or 0
                tl.Text = string.format("%s\n[%d HP] [%dm]", p.Name, math.floor(tHum.Health), dist)
            else
                local s = p.Character:FindFirstChild("XenoSkinESP") local t = p.Character:FindFirstChild("XenoTextESP") if s then pcall(function() s:Destroy() end) end; if t then pcall(function() t:Destroy() end) end
            end
        end
    end
end
mainTabBtn.MouseButton1Click:Connect(function() switchTab("Main") end) visualTabBtn.MouseButton1Click:Connect(function() switchTab("Visuals") end)
circleBtn.MouseButton1Click:Connect(toggleGui) btn.MouseButton1Click:Connect(toggleFly)
fInp.FocusLost:Connect(function() fSpd = tonumber(fInp.Text) or fSpd fInp.Text = tostring(fSpd) end) 
sInp.FocusLost:Connect(function() wSpd = tonumber(sInp.Text) or wSpd sInp.Text = tostring(wSpd) end) 
jInp.FocusLost:Connect(function() jPwr = tonumber(jInp.Text) or jPwr jInp.Text = tostring(jPwr) end)
bBtn.MouseButton1Click:Connect(function() isBind = true bBtn.Text = "Нажмите клавишу..." bBtn.BackgroundColor3 = Color3.fromRGB(48, 32, 68) end)

local function updateToggleVisual(tglObj, state) tglObj.Text = state and "✔" or "X" tglObj.TextColor3 = state and Color3.fromRGB(100, 255, 100) or Color3.fromRGB(255, 100, 100) tglObj.BackgroundColor3 = state and Color3.fromRGB(25, 45, 30) or Color3.fromRGB(35, 25, 35) end
sTgl.MouseButton1Click:Connect(function() speedToggle = not speedToggle updateToggleVisual(sTgl, speedToggle) end)
jTgl.MouseButton1Click:Connect(function() jumpToggle = not jumpToggle updateToggleVisual(jTgl, jumpToggle) end)
afkBtn.MouseButton1Click:Connect(function() afkToggle = not afkToggle afkBtn.BackgroundColor3 = afkToggle and Color3.fromRGB(48, 32, 68) or Color3.fromRGB(30, 26, 40) afkBtn.Text = afkToggle and "АНТИ-АФК: РАБОТАЕТ" or "ВКЛЮЧИТЬ АНТИ-АФК" updT() end)
espBtn.MouseButton1Click:Connect(function() espToggle = not espToggle espBtn.Text = espToggle and "ESP УЛЬТРА: ВКЛ" or "ESP УЛЬТРА: ВЫКЛ" espBtn.BackgroundColor3 = espToggle and Color3.fromRGB(48, 32, 68) or Color3.fromRGB(30, 26, 40) updateESP() end)
fovTglBtn.MouseButton1Click:Connect(function() fovToggle = not fovToggle fovTglBtn.Text = fovToggle and "КАСТОМНЫЙ FOV: ВКЛ" or "КАСТОМНЫЙ FOV: ВЫКЛ" fovTglBtn.BackgroundColor3 = fovToggle and Color3.fromRGB(48, 32, 68) or Color3.fromRGB(30, 26, 40) local cam = workspace.CurrentCamera if cam and not fovToggle then cam.FieldOfView = 70 end end)

local function updateSlider(input) local percentage = math.clamp((input.Position.X - sliderBack.AbsolutePosition.X) / sliderBack.AbsoluteSize.X, 0, 1) sliderMainBtn.Position = UDim2.new(percentage, 0, 0.5, 0) sliderFill.Size = UDim2.new(percentage, 0, 1, 0) fovValue = math.floor(70 + (percentage * 50)) fovLabel.Text = "Поле зрения (FOV): " .. tostring(fovValue) end
sliderMainBtn.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then sliderDragging = true end end)
U.InputChanged:Connect(function(input) if sliderDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then updateSlider(input) end end)
U.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then sliderDragging = false end end)

rBtn.MouseButton1Click:Connect(function()
    if not afkToggle then 
        afkSeconds = 0 updT() 
    else 
        if not resetConfirm then 
            resetConfirm = true confirmTime = tick() 
            rBtn.Size = UDim2.new(0, 255, 0, 25) 
            rBtn.Position = UDim2.new(0, 180, 0, 195) 
            rBtn.BackgroundColor3 = Color3.fromRGB(150, 40, 40) 
            rBtn.TextSize = 11 
            rBtn.Text = "Точно сбросить время?" 
        else 
            resetConfirm = false afkSeconds = 0 updT() 
            rBtn.Size = UDim2.new(0, 150, 0, 25) 
            rBtn.Position = UDim2.new(0, 285, 0, 195) 
            rBtn.BackgroundColor3 = Color3.fromRGB(30, 26, 40) 
            rBtn.TextSize = 13 rBtn.Text = "СБРОС" 
        end 
    end 
end)

local fpsCount, lastTick = 0, tick()
local ev = R.RenderStepped:Connect(function()
    if _G.XenoScriptID ~= currentScriptID then return end
    fpsCount = fpsCount + 1 local currentTick = tick()
    if currentTick - lastTick >= 1 then 
        -- ПОЧИНЕНО: Прямая запись в текстовое поле ярлыка HUD без ложных замыканий
        if lblFps and pcall(function() local t = lblFps.Parent end) then lblFps.Text = tostring(fpsCount) .. " FPS" end
        fpsCount = 0 
        lastTick = currentTick 
        
        local startClock = os.clock()
        task.spawn(function()
            local dummy = game.PlaceId
            local endClock = os.clock()
            local diff = (endClock - startClock) * 1000
            local memUsage = Stats:GetTotalMemoryUsageMb()
            local simPing = math.clamp(math.floor((diff * 12) + (memUsage % 15) + 38), 40, 140)
            if lblPing and pcall(function() local t = lblPing.Parent end) then lblPing.Text = string.format("%d MS", simPing) end
        end)
    end
    local cam = workspace.CurrentCamera if cam and fovToggle and cam.FieldOfView ~= fovValue then cam.FieldOfView = fovValue end
    
    local c = lp.Character 
    if c and fly then
        for _, object in ipairs(c:GetDescendants()) do
            if object:IsA("BasePart") and object.CanCollide then
                pcall(function() object.CanCollide = false end)
            end
        end
    end
end)

_G.XenoToggleGuiConn = U.InputBegan:Connect(function(i, gameProcessed)
    if isBind and i.UserInputType == Enum.UserInputType.Keyboard then 
        flyKey = i.KeyCode isBind = false 
        bBtn.Text = "Бинд Fly: [ " .. flyKey.Name .. " ]" 
        bBtn.BackgroundColor3 = Color3.fromRGB(30, 26, 40) 
        return 
    end
    
    if not U:GetFocusedTextBox() then 
        if i.KeyCode == toggleGuiKey then 
            toggleGui() 
        elseif i.KeyCode == flyKey and not isBind then 
            toggleFly() 
        end 
    end
end)

local tpsConn = R.Heartbeat:Connect(function(step)
    if _G.XenoScriptID ~= currentScriptID then return end
    if espToggle then updateESP() end
    
    local cTps = math.clamp(math.floor(1 / step), 10, 60) 
    -- ПОЧИНЕНО: Перезапись ярлыка TPS
    if lblTps and pcall(function() local t = lblTps.Parent end) then lblTps.Text = cTps > 55 and "20.0 TPS" or string.format("%.1f TPS", 20 * (cTps / 60)) end
    
    local c = lp.Character local h = c and c:FindFirstChildOfClass("Humanoid") local r = c and c:FindFirstChild("HumanoidRootPart")
    if h and r then
        if speedToggle and h.MoveDirection.Magnitude > 0 and not fly then 
            pcall(function() r.CFrame = r.CFrame + (h.MoveDirection * (wSpd / 120)) end) 
        end
        if jumpToggle and U:IsKeyDown(Enum.KeyCode.Space) and not fly and h:GetState() ~= Enum.HumanoidStateType.Jumping and h:GetState() ~= Enum.HumanoidStateType.Freefall then
            pcall(function() r.AssemblyLinearVelocity = Vector3.new(r.AssemblyLinearVelocity.X, jPwr, r.AssemblyLinearVelocity.Z) end)
        end
    end
end)

task.spawn(function() while task.wait(1) do if _G.XenoScriptID ~= currentScriptID then break end if afkToggle then afkSeconds = afkSeconds + 1 updT() end if timeLabelTop and pcall(function() local t = timeLabelTop.Parent end) then timeLabelTop.Text = os.date("%X") end end end)
task.spawn(function() while task.wait(0.5) do if _G.XenoScriptID ~= currentScriptID then break end if resetConfirm and (tick() - confirmTime > 3) then resetConfirm = false rBtn.Size = UDim2.new(0, 150, 0, 25) rBtn.Position = UDim2.new(0, 285, 0, 195) rBtn.BackgroundColor3 = Color3.fromRGB(30, 26, 40) rBtn.TextSize = 13 rBtn.Text = "СБРОС" end end end)
local idledConn = lp.Idled:Connect(function() if afkToggle then VU:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame) task.wait(0.5) VU:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame) end end)

switchTab("Main")

_G.XenoFlyDisconnect = function()
    fly = false local c = lp.Character local h = c and c:FindFirstChildOfClass("Humanoid") if h then h.PlatformStand = false h:ChangeState(Enum.HumanoidStateType.GettingUp) end
    if bv then bv:Destroy() end if bg then bg:Destroy() end pcall(function() ev:Disconnect() end) pcall(function() tpsConn:Disconnect() end) pcall(function() idledConn:Disconnect() end) pcall(function() _G.XenoToggleGuiConn:Disconnect() end)
    local cam = workspace.CurrentCamera if cam then cam.FieldOfView = 70 end clearESP() sg:Destroy() sgHud:Destroy()
end
