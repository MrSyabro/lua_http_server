local h = require "html"
local page = require "page"

local lead = {class = "lead"}

local args

if request.method == "POST" then
    local data, err = client:receive(request.headers["content-length"])
    if data then
        args = server.parsequery(data)
    end
elseif request.method == "GET" then
    args = server.parsequery(request.url.query)
end

local out = h.p(lead, "Вы не ввели имя или фамилию?")
if args.firstname and args.lastname then
    out = h.p(nil, "Вас зовут: ", h.b(nil, args.firstname), " ", h.b(nil, args.lastname))
end

echo(page("Form out",
    h.div({ class = "container" },
        h.h2(nil, "GET/POST example"),
        h.hr(),
        h.p(lead, "На этой странице обрабатываются даныне запроса. Ниже отображены введенные в форме данные:"),
        out
    )
))