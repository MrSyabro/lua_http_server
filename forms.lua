local h = require "html"
local page = dofile "page.lua"

local div_args = { class = "mb-3" }
local function gen_elements()
    return h.div(div_args,
        h.label({ ["for"] = "fitstname", class = "form-label" }, "Ваше имя"),
        h.input { class = "form-control", type = "text", name = "firstname", id = "firstname" }
    ) ..
    h.div(div_args,
        h.label({ ["for"] = "lastname", class = "form-label" }, "Ваша фамилия"),
        h.input { class = "form-control", type = "text", name = "lastname", id = "lastname" }
    ) ..
    h.button({ class = "btn btn-success", type = "submit" }, "Send")
end

local getinput = h.form(
    {
        action = "form_test.lua",
        method = "GET"
    },
    gen_elements()
)

local postinput = h.form(
    {
        action = "form_test.lua",
        method = "POST",
        --enctype = "text/plain"
    },
    gen_elements()
)

echo(page("Forms example", h.div({ class = "container my-5" },
    h.p({ class = "lead" }, "На этой странице демонстрируется отправка формы на другую страницу сервера."),
    h.div({ class = "row" },
        h.div({ class = "col-lg-6 mx-auto" },
            h.p({ class = "lead" }, "Эта форма отправлает GET запрос"),
            getinput
        ),
        h.div({ class = "col-lg-6 mx-auto" },
            h.p({ class = "lead" }, "А эта форма отправляет POST запрос"),
            postinput
        )
    )
)))
