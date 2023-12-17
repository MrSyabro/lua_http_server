local h = require "html"
local page = dofile "page.lua"

--local list = { class = "list-group list-group-horizontal" }
local el = { class = "list-group-item" }
local h5 = { class = "mb-1"}

local els = {}
for k, i in pairs(request.headers) do
    table.insert(els, h.div(el, h.h5(h5, k), h.small(nil, i)))
end

echo(page("Dump headers"),
    h.div({ class = "container my-5" },
        h.div({ class = "row" },
            h.div({ class = "col-lg-8 mx-auto list-group" }, els)
        )
    )
)
