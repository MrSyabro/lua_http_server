local socket = require("socket")
local ltn12 = require("ltn12")

--{{Options
---The port number for the HTTP server. Default is 80
PORT=8080
---The parameter backlog specifies the number of client connections
-- that can be queued waiting for service. If the queue is full and
-- another client attempts connection, the connection is refused.
BACKLOG=5
-- Этот параметр определяет, где сервер буде искать файлы.
ROOT_DIR="./"
--}}Options

local function parse_start_line(start_line)
	local _request = {}
	local request = {}
	
	for word in string.gmatch(start_line, "%g+") do
		table.insert(_request, word)
	end
	
	request.method = _request[1]
	request.uri = _request[2]
	request.filename = _request[2]
	request.protocol = _request[3]
	
	local i = string.find (request.uri, "?")
	if i then
		local args_str = string.sub (request.uri, i + 1)
		request.args = {}
		
		for key, value in string.gmatch(args_str, "(%w+)=(%w+)") do
			request.args[key] = value
		end
		
		request.filename = string.sub (request.uri, 1, i -1)
	end
	
	return request
end

local function read_request (client)
 	local start_line, err = client:receive("*l")
	local request = parse_start_line(start_line)
	local raw_headers = {}
	request.headers = {}

	local reading = true
	while reading do
		local header_line, err = client:receive("*l")
		reading = (header_line ~= "")
		if reading then
			table.insert(raw_headers, header_line)
			local key, value = string.match (header_line, "(%g+): (%g+)")
			if key then
				request.headers[key:lower()] = value
			end
		end
	end

	request.header = table.concat(raw_headers)

	if request.filename == "/" then
		request.filename = "/index.lua"
	end

	return request
end

local function send_headers (client, headers)
	for i, k in pairs(headers) do
		local header = ("%s: %s\n"):format(i, k)
		client:send(header)
	end
end

local function send_response (client, response)
	client:send(("HTTP/1.1 %d %s\n"):format(
		response.code or 200,
		response.mess or "OK"
	))
	
	send_headers(client, response.headers)
	
	client:send("\n")
end

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
		local f
		local response = {
			headers = {
				["content-type"] = "text/html; charset=utf-8" -- По дефолту отправляем html, utf-8
			}
		}
		local request = read_request(client)
		local is_script = string.find(request.filename, ".lua") and true
		
		io.write(("[INFO] %s request to %s%s\n"):format(request.method, request.filename, is_script and ". Execute." or ""))
		
		
		if request.method == "GET" then
			if is_script then 	-- если обратились к lua фалу
				local tmp_f = io.tmpfile() 	-- времнный файл для вывода
				local stat, ret

				local env = _G
				env.io.html = tmp_f
				env.request = request
				env.response = response

				f, err = loadfile(ROOT_DIR..request.filename, "t", env) 	-- загрузка скрипта
				if f then
					stat, ret = pcall(f, request) 	-- выполняем скрипт
				else
					io.stderr:write("[ERROR] "..err)
					response.code = 500
					response.mess = "Open file error"
				end

				if stat then
					tmp_f:seek ("set")
					f = tmp_f
				else
					io.stderr:write("[ERROR] "..ret)
					f = nil
					response.code = 500
					response.mess = "Script error"
				end
			else 	-- иначе
				f = io.open(ROOT_DIR..request.filename) 	-- открываем файл для чтения
			end
		end

		-- if there was no error, send it back to the client
		if f then
			local data_lenghth = f:seek("end") f:seek("set") 	-- Узнаем обьем выходных данных
			response.headers["Content-Length"] = tostring(data_lenghth) -- ..указываем в заголовке

			send_response(client, response)

			local source = ltn12.source.file(f)
			local sink = socket.sink("close-when-done", client)
			ltn12.pump.all(source, sink)
		else
			client:send(("HTTP/1.1 %d %s\n\n"):format(
				response.code or 404,
				response.mess or "Not Found"
			))
			client:send("<!DOCTYPE html><html lang='en'><!-- Noncompliant --><body><h1>"..(response.mess or "Not Found").."</h1><br><p>File "..request.filename.." not found.</p></body></html>")
		end
	else
		print("Error happened while getting the connection.nError: "..err)
	end

	-- done with client, close the object
	client:close()
end
