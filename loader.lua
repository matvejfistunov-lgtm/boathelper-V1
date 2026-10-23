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
    [6839171747] = { -- Тот самый DOORS, который ты нашел (6839171747)
        Name = "DoorsHelper",
        URL = "https://raw.githubusercontent.com/therealcookiemonsterof1966/AbysallContinued/main/Games/Doors/Main.luau",
        Replacements = {
            ["Abysall Hub"] = "Doors Helper",
            ["Abysall Continued"] = "Doors Helper",
            ["Abyss"] = "Doors Helper",
            ["Made by"] = "Created by",
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
    
    local ok, body = pcall(function() return game:HttpGet(url) end)
    
    if ok and type(body) == "string" and #body > 100 then
        if writefile then pcall(writefile, cacheFile, body) end
        return body
    end
    
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
    warn("[Loader] Для этого PlaceId (" .. tostring(placeId) .. ") скрипт не найден.")
    return 
end

local rawCode = fetchScript(scriptInfo.URL, scriptInfo.Name)
if not rawCode then return end

-- Заменяем названия на "by BetterFly"
for oldText, newText in pairs(scriptInfo.Replacements) do
    rawCode = string.gsub(rawCode, oldText, newText)
end

-- Запускаем
local success, err = pcall(function()
    local fn = loadstring(rawCode)
    if fn then
        task.spawn(fn)
    end
end)

if not success then
    warn("[" .. scriptInfo.Name .. "] Ошибка запуска: " .. tostring(err))
end
