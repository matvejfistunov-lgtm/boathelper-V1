-- ===================== НАСТРОЙКИ =====================
local SCRIPTS = {
    [537413528] = { -- Build A Boat For Treasure
        Name = "BoatHelper",
        URL = "https://raw.githubusercontent.com/matvejfistunov-lgtm/boathelperv1/refs/heads/main/boathelper.luau",
        Replacements = {
            ['SubTitle = "Ironclad"'] = 'SubTitle = "by BetterFly"',
            ['Title = "BoatHelper"'] = 'Title = "BoatHelper | by BetterFly"'
        }
    },
    [6516141723] = { -- DOORS (Обычный)
        Name = "DoorsHelper",
        URL = "https://raw.githubusercontent.com/matvejfistunov-lgtm/DoorsHelper/refs/heads/main/DoorsHelper.luau"
    },
    [6839171747] = { -- DOORS: The Backdoor
        Name = "DoorsHelper",
        URL = "https://raw.githubusercontent.com/matvejfistunov-lgtm/DoorsHelper/refs/heads/main/DoorsHelper.luau"
    }
}

local CACHE_FOLDER = "BetterFlyHelper"

-- ===================== ВИЗУАЛЬНЫЙ ЛОГГЕР =====================
local function createLogger()
    local sg = Instance.new("ScreenGui")
    sg.Name = "BetterFly_Logger"
    sg.ResetOnSpawn = false
    pcall(function() sg.Parent = game:GetService("CoreGui") end)
    if not sg.Parent then sg.Parent = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui") end

    local main = Instance.new("Frame")
    main.Size = UDim2.new(0, 500, 0, 150)
    main.Position = UDim2.new(0.5, -250, 0.5, -75)
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

-- ===================== АБУЗ ФАЙЛОВ (КЭШИРОВАНИЕ) =====================
local function ensureFolder()
    if makefolder and not isfolder(CACHE_FOLDER) then
        pcall(makefolder, CACHE_FOLDER)
    end
end

local function fetchScript(url, name)
    ensureFolder()
    local cacheFile = CACHE_FOLDER .. "/" .. name .. ".lua"
    guiPrint("Скачиваем " .. name .. "...")
    
    local ok, body = pcall(function() return game:HttpGet(url) end)
    
    if ok and type(body) == "string" and #body > 100 then
        guiPrint("Успешно скачано! Размер: " .. #body .. " байт.")
        if writefile then pcall(writefile, cacheFile, body) end
        return body
    end
    
    guiWarn("Ошибка сети! Пытаемся взять из кэша...")
    if isfile and isfile(cacheFile) then
        local cached = pcall(readfile, cacheFile)
        if cached then 
            guiPrint("Загружено из кэша.")
            return cached 
        end
    end
    guiWarn("Кэш пуст или не найден.")
    return nil
end

-- ===================== ЗАПУСК =====================
local placeId = game.PlaceId
local scriptInfo = SCRIPTS[placeId]
local isSuccess = false

if not scriptInfo then 
    guiWarn("Для PlaceId (" .. tostring(placeId) .. ") нет скрипта в базе.")
else
    local rawCode = fetchScript(scriptInfo.URL, scriptInfo.Name)
    
    if rawCode then
        -- Применяем замены, если они есть (только для BoatHelper)
        if scriptInfo.Replacements then
            for oldText, newText in pairs(scriptInfo.Replacements) do
                rawCode = string.gsub(rawCode, oldText, newText)
            end
        end

        guiPrint("Компиляция (loadstring)...")
        
        local success, err = pcall(function()
            local fn = loadstring(rawCode)
            if fn then
                task.spawn(fn)
            else
                error("Loadstring вернул nil (синтаксическая ошибка в коде).")
            end
        end)

        if not success then
            guiWarn("КРАШ СКРИПТА: " .. tostring(err))
        else
            isSuccess = true
        end
    end
end

-- ===================== АВТО-ЗАКРЫТИЕ =====================
if isSuccess then
    guiPrint("Скрипт успешно запущен! Логгер закроется через 2 сек...")
    task.delay(2, function()
        if logGui and logGui.Parent then
            logGui:Destroy()
        end
    end)
end
