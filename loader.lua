-- ===================== ВИЗУАЛЬНЫЙ ЛОГГЕР + МОНИТОР =====================
local function createLogger()
    local sg = Instance.new("ScreenGui")
    sg.Name = "BetterFly_Logger"
    sg.ResetOnSpawn = false
    pcall(function() sg.Parent = game:GetService("CoreGui") end)
    if not sg.Parent then sg.Parent = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui") end

    local main = Instance.new("Frame")
    main.Size = UDim2.new(0, 600, 0, 350)
    main.Position = UDim2.new(0.5, -300, 0.5, -175)
    main.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    main.BorderSizePixel = 0
    main.Active = true
    main.Draggable = true
    main.Parent = sg

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 30)
    title.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    title.Text = "Loader Monitor | by BetterFly"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.Font = Enum.Font.GothamBold
    title.Parent = main

    local close = Instance.new("TextButton")
    close.Size = UDim2.new(0, 30, 0, 30)
    close.Position = UDim2.new(1, -30, 0, 0)
    close.BackgroundTransparency = 1
    close.Text = "X"
    close.TextColor3 = Color3.fromRGB(255, 100, 100)
    close.Font = Enum.Font.GothamBold
    close.Parent = main
    close.MouseButton1Click:Connect(function() sg:Destroy() end)

    local scroll = Instance.new("ScrollingFrame")
    scroll.Size = UDim2.new(1, -10, 1, -80) -- Оставили место для кнопки снизу
    scroll.Position = UDim2.new(0, 5, 0, 35)
    scroll.BackgroundTransparency = 1
    scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    scroll.ScrollBarThickness = 4
    scroll.Parent = main

    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 2)
    layout.Parent = scroll

    -- Поле для ввода ссылки и кнопка запуска
    local textBox = Instance.new("TextBox")
    textBox.Size = UDim2.new(1, -100, 0, 30)
    textBox.Position = UDim2.new(0, 5, 1, -35)
    textBox.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    textBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    textBox.PlaceholderText = "Вставь Raw-ссылку на любой скрипт для теста..."
    textBox.Text = ""
    textBox.Parent = main

    local runBtn = Instance.new("TextButton")
    runBtn.Size = UDim2.new(0, 85, 0, 30)
    runBtn.Position = UDim2.new(1, -90, 1, -35)
    runBtn.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
    runBtn.Text = "Запустить"
    runBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    runBtn.Font = Enum.Font.GothamBold
    runBtn.Parent = main

    return scroll, sg, textBox, runBtn
end

local logScroll, logGui, urlBox, runButton = createLogger()

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
    -- Прокрутка вниз
    task.defer(function() logScroll.CanvasPosition = Vector2.new(0, logScroll.AbsoluteCanvasSize.Y) end)
end

local function guiPrint(msg, color) addLog("[Loader] " .. tostring(msg), color or Color3.fromRGB(100, 255, 100)) end
local function guiWarn(msg, color) addLog("[Ошибка] " .. tostring(msg), color or Color3.fromRGB(255, 100, 100)) end

-- ===================== ЯДРО ЗАПУСКА =====================
local function runScript(code, name)
    guiPrint("Компиляция " .. name .. "...")
    
    -- Перехватываем принты самого скрипта
    local originalPrint = print
    local originalWarn = warn
    local originalError = error
    
    getgenv().print = function(...)
        local str = ""
        for i, v in ipairs({...}) do str = str .. tostring(v) .. (i < select("#", ...) and " " or "") end
        addLog("[Скрипт] " .. str, Color3.fromRGB(255, 255, 200))
        originalPrint(...)
    end
    
    getgenv().warn = function(...)
        local str = ""
        for i, v in ipairs({...}) do str = str .. tostring(v) .. (i < select("#", ...) and " " or "") end
        addLog("[Внимание] " .. str, Color3.fromRGB(255, 150, 50))
        originalWarn(...)
    end

    -- Запуск с глубокой трассировкой
    local startTime = tick()
    local success, err = xpcall(function()
        local fn = loadstring(code)
        if fn then
            task.spawn(fn)
        else
            error("Loadstring вернул nil (синтаксическая ошибка).")
        end
    end, debug.traceback)

    getgenv().print = originalPrint
    getgenv().warn = originalWarn
    getgenv().error = originalError

    local endTime = tick()
    guiPrint(string.format("Выполнение заняло: %.2f сек.", endTime - startTime))

    if not success then
        guiWarn("КРАШ СКРИПТА:\n" .. tostring(err))
    else
        guiPrint("Код выполнен без критических ошибок.")
        
        -- Мониторинг GUI (появилось ли окно)
        task.wait(1.5) -- Ждем, пока скрипт отрисует интерфейс
        local count = 0
        for _, v in ipairs(game:GetService("CoreGui"):GetChildren()) do
            if v:IsA("ScreenGui") then count = count + 1 end
        end
        for _, v in ipairs(game.Players.LocalPlayer.PlayerGui:GetChildren()) do
            if v:IsA("ScreenGui") then count = count + 1 end
        end
        
        if count > 0 then
            guiPrint("Мониторинг: Обнаружено " .. count .. " активных GUI окон.")
        else
            guiWarn("Мониторинг: Скрипт не создал ни одного GUI окна. Возможно, он не поддерживает эту игру.")
        end
    end
end

-- ===================== КОНФИГУРАЦИЯ =====================
local SCRIPTS = {
    [537413528] = { -- BABFT
        Name = "BoatHelper",
        URL = "https://raw.githubusercontent.com/matvejfistunov-lgtm/boathelperv1/refs/heads/main/boathelper.luau",
        Replacements = {
            ['SubTitle = "Ironclad"'] = 'SubTitle = "by BetterFly"',
            ['Title = "BoatHelper"'] = 'Title = "BoatHelper | by BetterFly"'
        }
    },
    [6839171747] = { -- DOORS Backdoor
        Name = "AbysallDoors",
        URL = "https://raw.githubusercontent.com/therealcookiemonsterof1966/AbysallContinued/main/Games/Doors/Main.luau"
    },
}

local function fetchScript(url, name)
    guiPrint("Скачиваем " .. name .. "...")
    local ok, body = pcall(function() return game:HttpGet(url) end)
    
    if ok and type(body) == "string" and #body > 100 then
        guiPrint("Успешно скачано (" .. #body .. " байт).")
        return body
    end
    guiWarn("Не удалось скачать код. Проверь ссылку/интернет.")
    return nil
end

-- ===================== КНОПКА РУЧНОГО ЗАПУСКА =====================
runButton.MouseButton1Click:Connect(function()
    local url = urlBox.Text
    if url == "" or not url:match("http") then
        guiWarn("Введи корректную ссылку в поле внизу!")
        return
    end
    runButton.Text = "Жди..."
    runButton.BackgroundColor3 = Color3.fromRGB(150, 150, 50)
    
    local code = fetchScript(url, "CustomScript")
    if code then
        runScript(code, "CustomScript")
    end
    
    runButton.Text = "Запустить"
    runButton.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
end)

-- ===================== АВТО-ЗАПУСК ПО ID =====================
local placeId = game.PlaceId
local scriptInfo = SCRIPTS[placeId]

if not scriptInfo then 
    guiWarn("Для ID (" .. tostring(placeId) .. ") нет авто-скрипта. Можешь запустить вручную внизу.")
else
    local rawCode = fetchScript(scriptInfo.URL, scriptInfo.Name)
    if rawCode then
        if scriptInfo.Replacements then
            for oldText, newText in pairs(scriptInfo.Replacements) do
                rawCode = string.gsub(rawCode, oldText, newText)
            end
        end
        runScript(rawCode, scriptInfo.Name)
    end
end
