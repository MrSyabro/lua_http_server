local function index(request)
	request.filename = "/index.lua"
end

return {
	{regex = "aliases.lua", func = index},
	{regex = "pem", func = index},
	{regex = "index$", func = index},

	{regex = "files", func = function(request) request.filename = "/files.lua" end},
	{regex = "dump%-headers", func = function(request) request.filename = "/dump-headers.lua" end},
	{regex = "getfile", func = function(request) request.filename = "/getfile.lua" end},

	{regex = ".png", func = function(request, response) response.headers["Content-Type"] = "image/png" end},
	{regex = ".ico", func = function(request, response) response.headers["Content-Type"] = "image/vnd.microsoft.icon" end},
	{regex = ".json", func = function(request, response) response.headers["Content-Type"] = "application/json" end},
	{regex = ".svg", func = function(request, response) response.headers["Content-Type"] = "image/svg+xml" end},

	{regex = "/$", func = index},
}
