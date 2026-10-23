-- ===================== ВИЗУАЛЬНЫЙ ЛОГГЕР (GUI) =====================
local function createLogger()
    local sg = Instance.new("ScreenGui")
    sg.Name = "BetterFly_Logger"
    sg.ResetOnSpawn = false
    pcall(function() sg.Parent = game:GetService("CoreGui") end)
    if not sg.Parent then sg.Parent = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui") end

    local main = Instance.new("Frame")
    main.Size = UDim2.new(0, 600, 0, 300)
    main.Position = UDim2.new(0.5, -300, 0.5, -150)
    main.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    main.BorderSizePixel = 0
    main.Active = true
    main.Draggable = true
    main.Parent = sg

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 30)
    title.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    title.Text = "Loader Debug | by BetterFly"
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
    scroll.Size = UDim2.new(1, -10, 1, -40)
    scroll.Position = UDim2.new(0, 5, 0, 35)
    scroll.BackgroundTransparency = 1
    scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
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

local function guiPrint(...)
    local args = {...}
    local str = ""
    for i, v in ipairs(args) do str = str .. tostring(v) .. (i < #args and " " or "") end
    addLog("[Лоадер] " .. str, Color3.fromRGB(100, 255, 100))
end

local function guiWarn(...)
    local args = {...}
    local str = ""
    for i, v in ipairs(args) do str = str .. tostring(v) .. (i < #args and " " or "") end
    addLog("[Ошибка] " .. str, Color3.fromRGB(255, 100, 100))
end

-- ===================== КОНФИГУРАЦИЯ =====================
local SCRIPTS = {
    [537413528] = { 
        Name = "BoatHelper",
        URL = "https://raw.githubusercontent.com/matvejfistunov-lgtm/boathelperv1/refs/heads/main/boathelper.luau",
        Replacements = {
            ['SubTitle = "Ironclad"'] = 'SubTitle = "by BetterFly"',
            ['Title = "BoatHelper"'] = 'Title = "BoatHelper | by BetterFly"'
        }
    },
    [6839171747] = { 
        Name = "DoorsHelper",
        URL = "https://raw.githubusercontent.com/therealcookiemonsterof1966/AbysallContinued/main/Games/Doors/Main.luau",
        -- ВРЕМЕННО ОТКЛЮЧИЛИ ЗАМЕНЫ, чтобы проверить, не они ли ломают скрипт
        Replacements = {} 
    },
}

local CACHE_FOLDER = "BetterFlyHelper"

-- ===================== АБУЗ ФАЙЛОВ =====================
local function ensureFolder()
    if makefolder and not isfolder(CACHE_FOLDER) then
        pcall(makefolder, CACHE_FOLDER)
    end
end

local function fetchScript(url, name)
    ensureFolder()
    local cacheFile = CACHE_FOLDER .. "/" .. name .. ".lua"
    guiPrint("Скачиваем скрипт...")
    
    local ok, body = pcall(function() return game:HttpGet(url) end)
    
    if ok and type(body) == "string" and #body > 100 then
        guiPrint("Скачано: " .. #body .. " байт.")
        if writefile then pcall(writefile, cacheFile, body) end
        return body
    end
    
    guiWarn("Ошибка сети. Берем из кэша...")
    if isfile and isfile(cacheFile) then
        local cached = pcall(readfile, cacheFile)
        if cached then return cached end
    end
    return nil
end

-- ===================== ОСНОВНАЯ ЛОГИКА =====================
local placeId = game.PlaceId
local scriptInfo = SCRIPTS[placeId]

if not scriptInfo then 
    guiWarn("Для PlaceId (" .. tostring(placeId) .. ") нет скрипта.")
else
    local rawCode = fetchScript(scriptInfo.URL, scriptInfo.Name)
    
    if rawCode then
        -- Применяем замены, если они есть
        for oldText, newText in pairs(scriptInfo.Replacements) do
            rawCode = string.gsub(rawCode, oldText, newText)
        end

        guiPrint("Запускаем код скрипта...")
        
        -- ПЕРЕХВАТЫВАЕМ СООБЩЕНИЯ САМОГО СКРИПТА
        local originalPrint = print
        local originalWarn = warn
        local scriptLogs = {}
        
        getgenv().print = function(...)
            local args = {...}
            local str = ""
            for i, v in ipairs(args) do str = str .. tostring(v) .. (i < #args and " " or "") end
            table.insert(scriptLogs, str)
            addLog("[Скрипт] " .. str, Color3.fromRGB(255, 255, 200)) -- Желтоватый
        end
        
        getgenv().warn = function(...)
            local args = {...}
            local str = ""
            for i, v in ipairs(args) do str = str .. tostring(v) .. (i < #args and " " or "") end
            table.insert(scriptLogs, str)
            addLog("[Внимание] " .. str, Color3.fromRGB(255, 150, 50)) -- Оранжевый
        end

        -- Запуск в pcall
        local success, err = pcall(function()
            local fn = loadstring(rawCode)
            if fn then
                task.spawn(fn)
            else
                error("Ошибка компиляции (loadstring вернул nil)")
            end
        end)

        -- Возвращаем print и warn обратно
        getgenv().print = originalPrint
        getgenv().warn = originalWarn

        if not success then
            guiWarn("КРАШ СКРИПТА: " .. tostring(err))
        else
            guiPrint("Код запущен. Ждем 5 секунд...")
            -- Даем скрипту 5 секунд, чтобы он либо открыл GUI, либо выдал ошибку
            task.delay(5, function()
                if logGui and logGui.Parent then
                    logGui:Destroy()
                end
            end)
        end
    end
end
