local h = require "html"

---@param page_name string тайл страницы
---@return string
return function(page_name)
    return h.head(nil,
        h.meta { charset="utf-8" },
        h.meta { name="viewport", content="width=device-width, initial-scale=1" },
        h.link {
            href = "https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css",
            rel = "stylesheet",
            integrity = "sha384-T3c6CoIi6uLrA9TneNEoa7RxnatzjcDSCmG1MXxSR1GAsXEV/Dwwykc2MPK8M2HN",
            crossorigin = "anonymous"
        },
        h.script({src="https://unpkg.com/htmx.org@1.9.9"}, ""),
        h.script({
            src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js",
            integrity="sha384-C6RzsynM9kWDrMNeT87bh95OGNyZPhcTNXj1NW7RuBCsyN/o0jlpcV8Qyq46cDfL",
            crossorigin="anonymous"}, ""
        ),
        h.title(nil, page_name)
    )
end