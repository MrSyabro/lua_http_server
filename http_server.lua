local socket = require("socket")
local mime = require("mime")
local ltn12 = require("ltn12")

local function parse_request(request_str)
	local _request = {}
	local request = {}
	
	for word in string.gmatch(request_str, "%g+") do
		table.insert(_request, word)
	end
	
	request.type = _request[1]
	request.filename = _request[2]
	request.protocol = _request[3]
	
	local i = string.find (_request[2], "?")
	if i then
		local args_str = string.sub (_request[2], i + 1)
		request.args = {}
		
		for key, value in string.gmatch(args_str, "(%w+)=(%w+)") do
			request.args[key] = value
		end
		
		request.filename = string.sub (_request[2], 1, i -1)
	end
	
	return request
end

--{{Options
---The port number for the HTTP server. Default is 80
PORT=8080
---The parameter backlog specifies the number of client connections
-- that can be queued waiting for service. If the queue is full and
-- another client attempts connection, the connection is refused.
BACKLOG=5
ROOT_DIR="./"
--}}Options

-- create a TCP socket and bind it to the local host, at any port
server=assert(socket.tcp())
server:setoption("reuseaddr", true)
assert(server:bind("*", PORT))
server:listen(BACKLOG)

-- Print IP and port
local ip, port = server:getsockname()
print("Listening on IP="..ip..", PORT="..port.."...")

-- loop forever waiting for clients
while 1 do
	-- wait for a connection from any client
	local client, err = server:accept()

	if client then
		local f, err_code
		local line, err = client:receive("*l")
		local request = parse_request (line)
		
		print("TYPE: "..request.type)
		print("FILE: "..request.filename)
		
		local is_script = string.find(request.filename, ".lua") and true
		
		if request.type == "GET" then
			if is_script then
				local tmp_f = io.tmpfile()
				local stat, ret
				local env = _G
				env.io.html = tmp_f
				env.request = request
				f, err = loadfile(ROOT_DIR..request.filename, "t", env)
				if f then
					stat, ret = pcall(f, request)
				end
				if stat then
					tmp_f:seek ("set")
					f = tmp_f
				else
					io.stderr:write("[ERROR] "..ret)
					f = nil
				end
			else
				f = io.open(ROOT_DIR..request.filename)
			end
		end

		-- if there was no error, send it back to the client
		if f then
			client:send("HTTP/1.0 200 OK")
			
			client:send("\n\n")
			
			local source = ltn12.source.file(f)
			local sink = socket.sink("close-when-done", client)
			ltn12.pump.all(source, sink)
		else
			
			client:send("HTTP/1.0 404 Not Found\n\n")
			client:send("File not found.")
		end
	else
		print("Error happened while getting the connection.nError: "..err)
	end

	-- done with client, close the object
	client:close()
	print("Terminated")
end
