local fs = require "lfs"
local h = require "html"
local page = dofile "page.lua"

local dir = request.args.dir or "/"

local breadcrumpattr = { class = "breadcrumb-item" }

local dirnodes = {}
for node in string.gmatch(dir, "[^/]+") do
	table.insert(dirnodes, node)
end

local dirnav = {}
if #dirnodes > 0 then
	table.insert(dirnav, h.li(breadcrumpattr, h.a({ href = "/files" }, "Home")))
	for i, node in ipairs(dirnodes) do
		if i == #dirnodes then
			table.insert(dirnav, h.li({ class = "breadcrumb-item active", ["aria-current"] = "page" }, node))
		else
			table.insert(dirnav,
				h.li(breadcrumpattr, h.a({ href = "/files?dir=/" .. table.concat(dirnodes, "/", 1, i) .. "/" }, node)))
		end
	end
end

local out = {}

local fileimgattr = { src = "assets/file.png", alt = "twbs", height = "32", class = "flex-shrink-0" }
local dirimgattr = { src = "assets/folder.png", class = "flex-shrink-0", height = "32", alt = "Directory" }

for d in fs.dir(server.ROOT_DIR .. dir) do
	if d ~= "." and d ~= ".." then
		local attr, err = fs.attributes(server.ROOT_DIR .. dir .. d)
		if attr then
			if attr.mode == "directory" then
				local card = h.a({
						class = "list-group-item list-group-item-action d-flex gap-3 py-3",
						["aria-current"] = "true",
						href = "files?dir=" .. dir .. d .. "/"
					},
					h.img(dirimgattr),
					h.div({ class = "d-flex gap-2 w-100 justify-content-between" },
						h.h6({ class = "mb-0" }, d)
					),
					h.small({ class = "opacity-50 text-nowrap" }, os.date(nil, attr.modification))
				)
				table.insert(out, card)
			elseif attr.mode == "file" then
				local card = h.a({
						class = "list-group-item list-group-item-action d-flex gap-3 py-3",
						["aria-current"] = "true",
						href = dir .. d
					},
					h.img(fileimgattr),
					h.div({ class = "d-flex gap-2 w-100 justify-content-between" },
						h.h6({ class = "mb-0" }, d),
						h.p({ class = "mb-0 opacity-75" }, ("Size: %.2fkb"):format(attr.size / 1024))
					),
					h.small({ class = "opacity-50 text-nowrap" }, os.date(nil, attr.modification))
				)
				table.insert(out, card)
			end
		else
			error(err)
		end
	end
end

echo(page("Files", h.div({ class = "container my-5" },
	h.nav({ style = "--bs-breadcrumb-divider: '/';", ["aria-label"] = "breadcrumb" },
		h.ol({ class = "breadcrumb" },
			dirnav
		)
	),
	h.div({ class = "d-flex flex-column flex-md-row p-4 gap-4 py-md-5 align-items-center justify-content-center" },
		h.div({ class = "list-group" },
			out
		)
	)
)))
