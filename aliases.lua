local function index(request)
	request.filename = "/index.lua"
end

return {
	["/aliases.lua"] = index,
	["/index"] = index,
	["/"] = index,

	["/files"] = function(request) request.filename = "/files.lua" end,
	["/dump-headers"] = function(request) request.filename = "/dump-headers.lua" end,
	["/getfile"] = function(request) request.filename = "/getfile.lua" end,
}
