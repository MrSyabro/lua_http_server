local fs = require "lfs"
local h = require "html"
local page = dofile "page.lua"
local url = require "socket.url"

local query = {}
if request.url.query then
	query = server.parsequery(request.url.query)
end
local file = query.file
if file then
	local f, err = io.open(server.ROOT_DIR .. "/" .. file, "rb")
	if f then
		local data_lenghth = f:seek("end"); f:seek("set")
		response.headers["Content-Type"] = "application/octet-stream"
		response.headers["Content-Disposition"] = "attachment; filename=" .. file
		response.headers["Content-Length"] = tostring(data_lenghth)
		server:sendheaders()

		for l in f:lines(server.datagramsize) do
			client:send(l)
			coroutine.yield()
		end
		f:close()
	else
		server:error(404)
	end

	return
end

local dir = query.dir or ""

local breadcrumpattr = { class = "breadcrumb-item" }

local dirnodes = url.parse_path(dir)

local dirnav = {}
if #dirnodes > 0 then
	table.insert(dirnav, h.li(breadcrumpattr, h.a({ href = "/files" }, "Home")))
	for i, node in ipairs(dirnodes) do
		if i == #dirnodes then
			table.insert(dirnav, h.li({ class = "breadcrumb-item active", ["aria-current"] = "page" }, node))
		else
			table.insert(dirnav,
				h.li(breadcrumpattr,
					h.a({ href = "/files?dir=" .. url.escape("/" .. table.concat(dirnodes, "/", 1, i) .. "/") }, node)))
		end
	end
end

local out = {}

local fileimgattr = { src = "assets/file.png", alt = "twbs", height = "32", class = "flex-shrink-0" }
local dirimgattr = { src = "assets/folder.png", class = "flex-shrink-0", height = "32", alt = "Directory" }

for d in fs.dir(server.ROOT_DIR .. "/" .. dir) do
	if d ~= "." and d ~= ".." then
		local attr, err = fs.attributes(server.ROOT_DIR .. "/" .. dir .. d)
		if attr then
			if attr.mode == "directory" then
				local card = h.a({
						class = "list-group-item list-group-item-action gap-3 py-3",
						["aria-current"] = "true",
						href = "files?dir=" .. url.escape(dir .. d .. "/")
					},
					h.div({ class = "d-flex gap-2 w-100 justify-content-between" },
						h.img(dirimgattr),
						h.h6({ class = "mb-0" }, d),
						h.small(nil, os.date("%m.%d %H:%M", attr.modification))
					)
				)
				table.insert(out, card)
			elseif attr.mode == "file" then
				local card = h.div({
						class = "list-group-item gap-3 py-3",
						["aria-current"] = "true"
					},
					h.div({ class = "d-flex gap-2 w-100 justify-content-between" },
						h.img(fileimgattr),
						h.h6({ class = "mb-0" }, d),
						h.small(nil, os.date("%m.%d %H:%M", attr.modification))
					),
					h.p({ class = "opacity-50 text-nowrap" }, ("Size: %.2fkb"):format(attr.size / 1024)),
					h.div({ class = "btn-group", role = "group", ["aria-label"] = "Basic example" },
						h.a({ target = "_blank", class = "btn", href = "?file=" .. url.escape(dir .. d) }, "Download"),
						h.a({ target = "_blank", class = "btn", href = dir .. d }, "Open")
						--h.a({ class = "btn", href = "" }, "Delete")
					)
				)
				table.insert(out, card)
			end
		else
			error(err)
		end
	end
end

echo(page("Files", h.div({ class = "container my-5" },
	(#dirnav > 0) and h.div({ class = "row" },
		h.nav({ style = "--bs-breadcrumb-divider: '/';", ["aria-label"] = "breadcrumb" },
			h.ol({ class = "col-lg-8 col-md-6 mx-auto breadcrumb" },
				dirnav
			)
		)
	) or "",
	h.div({ class = "row" },
		h.div({ class = "col-lg-8 col-md-6 mx-auto list-group" },
			out
		)
	)
)))
