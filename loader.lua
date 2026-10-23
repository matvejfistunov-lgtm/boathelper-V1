-- ===================== КОНФИГУРАЦИЯ =====================
local SCRIPTS = {
    [537413528] = { -- Build A Boat For Treasure
        Name = "BoatHelper",
        URL = "https://raw.githubusercontent.com/matvejfistunov-lgtm/boathelperv1/refs/heads/main/boathelper.luau",
        Replacements = {} -- Для BoatHelper замены не нужны
    },
    [6516141723] = { -- DOORS
        Name = "DoorsHelper",
        URL = "https://raw.githubusercontent.com/therealcookiemonsterof1966/AbysallContinued/main/Games/Doors/Main.luau",
        -- Заменяем старое название на новое прямо в коде перед запуском
        Replacements = {
            ["Abysall Hub"] = "Doors Helper",
            ["Abysall Continued"] = "Doors Helper",
            ["Abyss"] = "Doors Helper",
            ["Made by"] = "by BetterFly",
            ["by therealcookiemonsterof1966"] = "by BetterFly",
            ["therealcookiemonsterof1966"] = "BetterFly"
        }
    },
}

local CACHE_FOLDER = "BetterFlyHelper"

-- ===================== АБУЗ ФАЙЛОВ (КЭШИРОВАНИЕ) =====================
local function ensureFolder()
    if makefolder and not isfolder(CACHE_FOLDER) then
        pcall(makefolder, CACHE_FOLDER)
    end
end

local function fetchScript(url, name)
    ensureFolder()
    local cacheFile = CACHE_FOLDER .. "/" .. name .. ".lua"
    
    -- Пытаемся скачать
    local ok, body = pcall(function()
        return game:HttpGet(url)
    end)
    
    if ok and type(body) == "string" and #body > 100 then
        -- Если скачали, сохраняем в кэш (абуз файловой системы)
        if writefile then
            pcall(writefile, cacheFile, body)
        end
        return body
    end
    
    -- Если сеть отвалилась, берем из кэша
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
    warn("[Loader] Этот плейс (" .. tostring(placeId) .. ") не поддерживается.")
    return
end

print("[Loader] Загрузка: " .. scriptInfo.Name .. " by BetterFly...")

local rawCode = fetchScript(scriptInfo.URL, scriptInfo.Name)
if not rawCode then
    warn("[Loader] Не удалось загрузить код (нет сети и кэша).")
    return
end

-- Применяем замены (переименовываем скрипт на лету)
for oldText, newText in pairs(scriptInfo.Replacements) do
    rawCode = string.gsub(rawCode, oldText, newText)
end

-- Запускаем
local success, err = pcall(function()
    local fn = loadstring(rawCode)
    if fn then
        task.spawn(fn)
    else
        error("Ошибка компиляции кода.")
    end
end)

if not success then
    warn("[" .. scriptInfo.Name .. "] Ошибка запуска: " .. tostring(err))
end
