local code = 301
local mess = Codes[code]

return {
    {regex = ".", func = function (s) ---@cast s Server
        s.response.code = code
        s.response.mess = mess
        s.response.headers.Location = ("https://%s:%s"):format(Config.host, Config.port)
        s:closecon() --отправляем ответ браузеру
    end}
}