local h = require "html"
local head = dofile "head.lua"

---@param name string текст для тайтла страницы
---@param body string текст для тела страницы
---@return string
return function(name, body)
    return h.doctype() ..
    h.html({lang = "ru"},
        head(name),
        h.body(nil,
            dofile "navbar.lua",
            body
        )
    )
end