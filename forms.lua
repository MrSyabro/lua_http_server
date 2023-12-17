local h = require "html"
local page = dofile "page.lua"

local div_args = {class = "mb-3"}
local input = h.form(
    {
        action="form_test.lua",
        method="GET"
    },
    h.div(div_args,
        h.label({ ["for"]="fitstname", class="form-label"}, "Ваше имя"),
        h.input {class = "form-control", type="text", name="firstname", id = "firstname"}
    ),
    h.div(div_args,
        h.label({ ["for"]="lastname", class="form-label"}, "Ваша фамилия"),
        h.input {class = "form-control", type="text", name="lastname", id = "lastname"}
    ),
    h.button({class = "btn btn-success", type="submit"}, "Send")
)

echo(page("Home", h.div({class = "container my-5"},
    h.div({class = "row"}, h.div({class = "col-lg-6 mx-auto"}, input))
)))