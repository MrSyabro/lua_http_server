local h = require "html"
local head = dofile "head.lua"

return function(name, body)
    return h.doctype() ..
    h.html({lang = "ru"},
        head(name),
        h.body(nil,
            h.script({
                src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js",
                integrity="sha384-C6RzsynM9kWDrMNeT87bh95OGNyZPhcTNXj1NW7RuBCsyN/o0jlpcV8Qyq46cDfL",
                crossorigin="anonymous"}, ""
            ),
            dofile "navbar.lua",
            body
        )
    )
end