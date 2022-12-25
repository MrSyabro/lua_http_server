local function index(request)
	request.filename = "/index.lua"
end

return {
	{regex = "aliases.lua", func = index},
	{regex = "index$", func = index},

	{regex = "files", func = function(request) request.filename = "/files.lua" end},
	{regex = "dump%-headers", func = function(request) request.filename = "/dump-headers.lua" end},
	{regex = "getfile", func = function(request) request.filename = "/getfile.lua" end},

	{regex = "/$", func = index},
}
