local url = "https://raw.githubusercontent.com/matvejfistunov-lgtm/boathelperv1/refs/heads/main/boathelper.luau"

local success, err = pcall(function()
    loadstring(game:HttpGet(url))()
end)

if not success then
    warn("Не удалось загрузить скрипт. Проверьте ссылку или интернет. Ошибка: " .. tostring(err))
end
