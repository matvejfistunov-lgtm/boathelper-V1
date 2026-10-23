-- ===================== ВИЗУАЛЬНЫЙ ЛОГГЕР (GUI) =====================
local function createLogger()
    local sg = Instance.new("ScreenGui")
    sg.Name = "BetterFly_Logger"
    sg.ResetOnSpawn = false
    pcall(function() sg.Parent = game:GetService("CoreGui") end)
    if not sg.Parent then sg.Parent = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui") end

    local main = Instance.new("Frame")
    main.Size = UDim2.new(0, 500, 0, 250)
    main.Position = UDim2.new(0.5, -250, 0.5, -125)
    main.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    main.BorderSizePixel = 0
    main.Active = true
    main.Draggable = true
    main.Parent = sg

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 30)
    title.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    title.Text = "Loader Reports | by BetterFly"
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

-- Переопределяем print и warn для вывода в GUI
local oldPrint = print
local oldWarn = warn

local function addLog(text, color)
    oldPrint("[GUI] " .. text)
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
    addLog(str, Color3.fromRGB(100, 255, 100)) -- Зеленоватый для успеха
end

local function guiWarn(...)
    local args = {...}
    local str = ""
    for i, v in ipairs(args) do str = str .. tostring(v) .. (i < #args and " " or "") end
    addLog(str, Color3.fromRGB(255, 100, 100)) -- Красный для ошибок
end

-- ===================== КОНФИГУРАЦИЯ =====================
local SCRIPTS = {
    [537413528] = { -- Build A Boat
        Name = "BoatHelper",
        URL = "https://raw.githubusercontent.com/matvejfistunov-lgtm/boathelperv1/refs/heads/main/boathelper.luau",
        Replacements = {
            ['SubTitle = "Ironclad"'] = 'SubTitle = "by BetterFly"',
            ['Title = "BoatHelper"'] = 'Title = "BoatHelper | by BetterFly"'
        }
    },
    [6839171747] = { -- DOORS (твой ID)
        Name = "DoorsHelper",
        URL = "https://raw.githubusercontent.com/therealcookiemonsterof1966/AbysallContinued/main/Games/Doors/Main.luau",
        Replacements = {
            ["Abysall Hub"] = "Doors Helper",
            ["Abysall Continued"] = "Doors Helper",
            ["by therealcookiemonsterof1966"] = "by BetterFly",
            ["therealcookiemonsterof1966"] = "BetterFly"
        }
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
    guiPrint("[1/3] Скачиваем скрипт с GitHub...")
    
    local ok, body = pcall(function() return game:HttpGet(url) end)
    
    if ok and type(body) == "string" and #body > 100 then
        guiPrint("[OK] Успешно скачано! Размер: " .. #body .. " байт.")
        if writefile then pcall(writefile, cacheFile, body) end
        return body
    end
    
    guiWarn("[!] Ошибка сети! Пытаемся загрузить из кэша...")
    if isfile and isfile(cacheFile) then
        local cached = pcall(readfile, cacheFile)
        if cached then 
            guiPrint("[OK] Загружено из кэша.")
            return cached 
        end
    end
    guiWarn("[ERROR] Кэш пуст или не найден.")
    return nil
end

-- ===================== ОСНОВНАЯ ЛОГИКА =====================
local isSuccess = false
local placeId = game.PlaceId
local scriptInfo = SCRIPTS[placeId]

if not scriptInfo then 
    guiWarn("[ERROR] Для PlaceId (" .. tostring(placeId) .. ") скрипт не найден в лоадере.")
else
    local rawCode = fetchScript(scriptInfo.URL, scriptInfo.Name)
    
    if not rawCode then 
        guiWarn("[ERROR] Не удалось получить код скрипта.")
    else
        -- Безопасная замена
        guiPrint("[2/3] Заменяем названия на 'by BetterFly'...")
        for oldText, newText in pairs(scriptInfo.Replacements) do
            rawCode = string.gsub(rawCode, oldText, newText)
        end

        guiPrint("[3/3] Компиляция (loadstring)...")
        local success, err = pcall(function()
            local fn = loadstring(rawCode)
            if fn then
                guiPrint("[OK] Скрипт скомпилирован. Запускаем...")
                task.spawn(fn)
            else
                error("Loadstring вернул nil (синтаксическая ошибка в коде).")
            end
        end)

        if not success then
            guiWarn("[ERROR] ОШИБКА ЗАПУСКА: " .. tostring(err))
        else
            isSuccess = true
        end
    end
end

-- ===================== АВТО-ЗАКРЫТИЕ ПРИ УСПЕХЕ =====================
if isSuccess then
    guiPrint("[DONE] Скрипт успешно запущен! Логгер закроется через 2 сек...")
    
    -- Ждем 2 секунды и удаляем GUI
    task.delay(2, function()
        if logGui and logGui.Parent then
            logGui:Destroy()
        end
    end)
end
