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
    [6839171747] = { -- DOORS: The Backdoor (твой ID)
        Name = "AbysallDoors",
        URL = "https://raw.githubusercontent.com/therealcookiemonsterof1966/AbysallContinued/main/Games/Doors/Main.luau"
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
    print("[Loader] Скачиваем " .. name .. "...")
    
    local ok, body = pcall(function() return game:HttpGet(url) end)
    
    if ok and type(body) == "string" and #body > 100 then
        print("[Loader] Успешно скачано!")
        if writefile then pcall(writefile, cacheFile, body) end
        return body
    end
    
    print("[Loader] Ошибка сети! Берем из кэша...")
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
    warn("[Loader] Для PlaceId (" .. tostring(placeId) .. ") нет скрипта.")
    return 
end

local rawCode = fetchScript(scriptInfo.URL, scriptInfo.Name)
if not rawCode then return end

-- Применяем замены (только для BoatHelper, чтобы поставить подпись)
if scriptInfo.Replacements then
    for oldText, newText in pairs(scriptInfo.Replacements) do
        rawCode = string.gsub(rawCode, oldText, newText)
    end
end

print("[Loader] Запускаем " .. scriptInfo.Name .. "...")
local success, err = pcall(function()
    local fn = loadstring(rawCode)
    if fn then
        task.spawn(fn)
    end
end)

if not success then
    warn("[Loader] Ошибка: " .. tostring(err))
end
