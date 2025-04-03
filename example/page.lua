local h = require "html"
local head = require "head"
local navbar = require "navbar"

local menu = {
    {
        href = "/",
        text = "Home",
    },
    {
        href = "forms.lua",
        text = "Forms"
    },
    {
        href = "dump-headers",
        text = "Dump headers"
    },
    {
        href = "files",
        text = "Files"
    }
}

---@param title string
---@param ... string body
---@return string
return function(title, ...)
    return h.doctype() ..
    h.html({lang = "ru"},
        head(title),
        h.body(nil,
            navbar(menu),
            ...
        )
    )
end