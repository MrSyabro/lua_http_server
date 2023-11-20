local h = require "html"
server.send_response(response)

local list = {
    {
        name = "test1",
        data = 10
    },
    {
        name = "test2",
        data = 20,
    },
    {
        name = "test3",
        data = 30,
    },
}

local tile_args = {
    class = "column",
    style = "background-color:#bbb;"
}

local function gen_tile(name, data)
    return h.div(tile_args,
        h.h2(nil, name),
        h.p(nil, data)
    )
end

local divs = {}

for _, tile in ipairs(list) do
    table.insert(divs, gen_tile(tile.name, tile.data))
end

local list_cont = h.div({class = "row"}, divs)

local input = h.div(nil, h.form({
        action="form_test.lua",
        method="GET"
    },
    h.p(nil, "Введите имя: ", h.input {type="text", name="firstname"}),
    h.p(nil, "Введите фамилию: ", h.input {type="text", name="lastname"}),
    h.input {type="submit", value="Отправить"}
))

coroutine.yield(h.doctype())
coroutine.yield(h.html(nil,
    h.head(nil,
        h.meta { content="text/html; charset=utf-8" },
        h.link { rel="stylesheet", href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/4.7.0/css/font-awesome.min.css" },
        h.title(nil, "Aboba")
    ),
    h.body(nil,
        list_cont,
        input
    )
))