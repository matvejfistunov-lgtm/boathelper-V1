-- ===================== КОНФИГУРАЦИЯ =====================
local SCRIPTS = {
    [537413528] = { -- Build A Boat For Treasure
        Name = "BoatHelper",
        URL = "https://raw.githubusercontent.com/matvejfistunov-lgtm/boathelperv1/refs/heads/main/boathelper.luau",
        Replacements = {
            ['SubTitle = "Ironclad"'] = 'SubTitle = "by BetterFly"',
            ['Title = "BoatHelper"'] = 'Title = "BoatHelper | by BetterFly"'
        }
    },
    [6839171747] = { -- DOORS: The Backdoor (твой ID)
        Name = "DoorsHelper",
        URL = "https://raw.githubusercontent.com/therealcookiemonsterof1966/AbysallContinued/main/Games/Doors/Main.luau",
        Replacements = {
            -- Оставляем только безопасные замены (без переменных)
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
    print("[Loader] Скачиваем скрипт с GitHub...")
    
    local ok, body = pcall(function() return game:HttpGet(url) end)
    
    if ok and type(body) == "string" and #body > 100 then
        print("[Loader] Успешно скачано! Размер: " .. #body .. " байт.")
        if writefile then pcall(writefile, cacheFile, body) end
        return body
    end
    
    print("[Loader] Ошибка сети! Пытаемся загрузить из кэша...")
    if isfile and isfile(cacheFile) then
        local cached = pcall(readfile, cacheFile)
        if cached then 
            print("[Loader] Загружено из кэша.")
            return cached 
        end
    end
    return nil
end

-- ===================== ОСНОВНАЯ ЛОГИКА =====================
local placeId = game.PlaceId
local scriptInfo = SCRIPTS[placeId]

if not scriptInfo then 
    warn("[Loader] Для этого PlaceId (" .. tostring(placeId) .. ") скрипт не найден.")
    return 
end

local rawCode = fetchScript(scriptInfo.URL, scriptInfo.Name)
if not rawCode then 
    warn("[Loader] Не удалось получить код скрипта.")
    return 
end

-- Безопасная замена
for oldText, newText in pairs(scriptInfo.Replacements) do
    rawCode = string.gsub(rawCode, oldText, newText)
end

print("[Loader] Компиляция скрипта...")
local success, err = pcall(function()
    local fn = loadstring(rawCode)
    if fn then
        print("[Loader] Запуск...")
        task.spawn(fn)
    else
        error("Loadstring вернул nil (синтаксическая ошибка в коде).")
    end
end)

if not success then
    warn("[" .. scriptInfo.Name .. "] ОШИБКА: " .. tostring(err))
end
