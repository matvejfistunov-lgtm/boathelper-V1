-- ===================== ВИЗУАЛЬНЫЙ ЛОГГЕР =====================
local function createLogger()
    local sg = Instance.new("ScreenGui")
    sg.Name = "BetterFly_Logger"
    sg.ResetOnSpawn = false
    pcall(function() sg.Parent = game:GetService("CoreGui") end)
    if not sg.Parent then sg.Parent = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui") end

    local main = Instance.new("Frame")
    main.Size = UDim2.new(0, 500, 0, 200)
    main.Position = UDim2.new(0.5, -250, 0.5, -100)
    main.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    main.BorderSizePixel = 0
    main.Active = true
    main.Draggable = true
    main.Parent = sg

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 30)
    title.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    title.Text = "Loader | by BetterFly"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.Font = Enum.Font.GothamBold
    title.Parent = main

    local scroll = Instance.new("ScrollingFrame")
    scroll.Size = UDim2.new(1, -10, 1, -40)
    scroll.Position = UDim2.new(0, 5, 0, 35)
    scroll.BackgroundTransparency = 1
    scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    scroll.ScrollBarThickness = 4
    scroll.Parent = main

    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 2)
    layout.Parent = scroll

    return scroll, sg
end

local logScroll, logGui = createLogger()

local function addLog(text, color)
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -5, 0, 0)
    label.AutomaticSize = Enum.AutomaticSize.Y
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = color or Color3.fromRGB(200, 200, 200)
    label.TextWrapped = true
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Font = Enum.Font.Code
    label.TextSize = 14
    label.Parent = logScroll
end

local function guiPrint(text) addLog("[Лоадер] " .. text, Color3.fromRGB(100, 255, 100)) end
local function guiWarn(text) addLog("[Ошибка] " .. text, Color3.fromRGB(255, 100, 100)) end

-- ===================== ЗАПУСК =====================
local placeId = game.PlaceId
local isSuccess = false

if placeId == 537413528 then
    -- Build A Boat
    guiPrint("Загрузка BoatHelper...")
    local url = "https://raw.githubusercontent.com/matvejfistunov-lgtm/boathelperv1/refs/heads/main/boathelper.luau"
    
    local ok, code = pcall(function() return game:HttpGet(url) end)
    if ok and code then
        -- Меняем только БоатХелпер (Abysall не трогаем!)
        code = code:gsub('SubTitle = "Ironclad"', 'SubTitle = "by BetterFly"')
        code = code:gsub('Title = "BoatHelper"', 'Title = "BoatHelper | by BetterFly"')
        
        local execOk, err = pcall(function() loadstring(code)() end)
        if execOk then isSuccess = true else guiWarn("Ошибка: " .. tostring(err)) end
    else
        guiWarn("Не удалось скачать BoatHelper")
    end

elseif placeId == 6839171747 then
    -- DOORS: The Backdoor
    guiPrint("Загрузка Abysall...")
    local url = "https://raw.githubusercontent.com/therealcookiemonsterof1966/AbysallContinued/main/Games/Doors/Main.luau"
    
    local ok, code = pcall(function() return game:HttpGet(url) end)
    if ok and code then
        guiPrint("Код скачан. Запускаем...")
        -- Запускаем ровно то, что ты просил, без единой модификации
        local execOk, err = pcall(function()
            loadstring(code)()
        end)
        
        if execOk then 
            isSuccess = true 
        else 
            guiWarn("Ошибка при запуске: " .. tostring(err)) 
        end
    else
        guiWarn("Не удалось скачать Abysall")
    end

else
    guiWarn("Неизвестный PlaceId: " .. tostring(placeId))
end

-- ===================== АВТО-ЗАКРЫТИЕ =====================
if isSuccess then
    guiPrint("Успешно запущено! Закрываюсь...")
    task.delay(3, function()
        if logGui and logGui.Parent then
            logGui:Destroy()
        end
    end)
end
