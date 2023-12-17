local h = require "html"
local head = require "head"

local out = h.p(nil, "Ты шо дурак?")
if request.args.firstname and request.args.lastname then
    out = h.p(nil, "Вас зовут: ", h.b(nil, request.args.firstname), " ", h.b(nil, request.args.lastname))
end

echo(h.doctype())
echo(h.html(nil,
    head("GET example"),
    h.body(nil,
        h.h2(nil, "Test page 2"),
        out
    )
))