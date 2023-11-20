local h = require "html"
server.send_response(response)

local out = h.p(nil, "Ты шо дурак?")
if request.args.firstname and request.args.lastname then
    out = h.p(nil, "Вас зовут: ", h.b(nil, request.args.firstname), " ", h.b(nil, request.args.lastname))
end

coroutine.yield(h.doctype())
coroutine.yield(h.html(nil,
    h.head(nil,
        h.meta { content="text/html; charset=utf-8" },
        h.title(nil, "Aboba 2.0")
    ),
    h.body(nil,
        h.h2(nil, "Test page 2"),
        out
    )
))