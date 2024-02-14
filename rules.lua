local function index(s)
	s.request.url.path = "/index.lua"
end

return {
	{regex = "rules.lua", func = index},
	{regex = "pem", func = index},
	{regex = "index$", func = index},

	{regex = "files", func = function(s) s.url.path = "/files.lua" end},
	{regex = "dump%-headers", func = function(s) s.request.url.path = "/dump-headers.lua" end},
	{regex = "getfile", func = function(s) s.request.url.path = "/getfile.lua" end},

	{regex = ".png", func = function(s) s.response.headers["Content-Type"] = "image/png" end},
	{regex = ".ico", func = function(s) s.response.headers["Content-Type"] = "image/icon" end},
	{regex = ".json", func = function(s) s.response.headers["Content-Type"] = "application/json" end},
	{regex = ".svg", func = function(s) s.response.headers["Content-Type"] = "image/svg+xml" end},
	{regex = ".css", func = function(s) s.response.headers["Content-Type"] = "image/css" end},

	{regex = "/$", func = index},
}
