#!/bin/lua
local socket = require("socket")

--{{Options
---The port number for the HTTP server. Default is 80
PORT=8080
---The parameter backlog specifies the number of client connections
-- that can be queued waiting for service. If the queue is full and
-- another client attempts connection, the connection is refused.
BACKLOG=10
-- Этот параметр определяет, где сервер будет искать файлы.
ROOT_DIR="."
--}}Options

local root_dir = arg[1] or ROOT_DIR

-- Загружаем короткие имена, если есть.
local aliases = {}

local aliases_file, err = loadfile(root_dir.."/aliases.lua", "t", {})
if aliases_file then
	aliases = aliases_file()
	print("[INFO] Aliases loaded")
elseif err then
	print("[ERROR]", err)
else
	print("[INFO] Aliases not found.")
end

local function unescape (s)
  s = string.gsub(s, "+", " ")
  s = string.gsub(s, "%%(%x%x)", function (h)
        return string.char(tonumber(h, 16))
      end)
  return s
end

-- Делим ссылку на имя файла и аргументы
local function parse_uri (uri)
	local i = string.find (uri, "?")
	if i then
		local args_str = string.sub (uri, i + 1)
		local args = {}
		
		for key, value in string.gmatch(args_str,
			"([^&=?]+)=([^&=?]+)") do
			args[key] = unescape(value)
		end
		
		return string.sub (uri, 1, i -1), args
	else
		return uri, {}
	end
end

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
	
	return request
end

local function find_alias(filename)
	for _, alias in ipairs(aliases) do
		if filename:match(alias.regex) then
			print("[INFO] Find alias for", alias.regex)
			return alias.func
		end
	end
end

local function read_request (client)
 	local start_line, err = client:receive("*l")
	if start_line then
		local request = parse_start_line(start_line)
		local raw_headers = {}
		request.headers = {}

		local reading = true
		while reading do
			local header_line, err = client:receive("*l")
			reading = (header_line ~= "" and header_line ~= nil)
			if reading then
				table.insert(raw_headers, header_line)
				local key, value = string.match (header_line,
					"(%g+): ([%g ]+)")
				if key then
					request.headers[key:lower()] = value
				end
			end
		end

		request.header = table.concat(raw_headers)

		request.filename, request.args = parse_uri(request.uri)

		local alias_func = find_alias(request.filename)
		if alias_func then alias_func(request) end

		return request
	else
		return nil, err
	end
end

local function send_headers (headers)
	for i, k in pairs(headers) do
		local header = ("%s: %s\n"):format(i, k)
		coroutine.yield(header)
	end
end

local function send_response (response)
	coroutine.yield(("HTTP/1.1 %d %s\n"):format(
		response.code or 200,
		response.mess or "OK"
	))
	
	send_headers(response.headers)
	
	coroutine.yield("\n")
end

local function thread_func(request, number)
	io.write(("[THREAD %d] %s request to %s\n"):format(number,
		request.method, request.filename))
	local is_script = string.find(request.filename, ".lua") and true
	
	local response = {
		headers = {
			["Content-Type"] = "text/html; charset=utf-8", 	-- По дефолту отправляем html, utf-8
			["Date"] = os.date("!%c GMT")
		}
	}
	
	if is_script then 	-- если обратились к lua фалу
		local stat, ret

		local env = setmetatable({}, {__index=_G})
		env.server = {
			send_response = send_response,
			send_headers = send_headers,
			root_dir = root_dir,
		}
		env.request = request
		env.response = response

		local script_func, err = loadfile(
			root_dir..request.filename, "t", env) 			-- загрузка скрипта
		if script_func then
			script_func()			 			-- выполняем скрипт
		else
			io.stderr:write("[ERROR] "..err)
			response.code = 500
			response.mess = "Open file error"
		end
	else 	-- иначе
		local f = io.open(root_dir..request.filename) 			-- открываем файл для чтения

		if f then
			local data_lenghth = f:seek ("end")		 	-- Узнаем обьем выходных данных
			response.headers ["Content-Length"] =
				tostring (data_lenghth) 			-- ..указываем в заголовке

			send_response(response)
			f:seek ("set")

			for d in f:lines(1024) do
				coroutine.yield(d)
			end

			f:close()
		else
			coroutine.yield(("HTTP/1.1 %d %s\n\n"):format(
				response.code or 404,
				response.mess or "Not Found"
			))
			coroutine.yield(
"<!DOCTYPE html><html lang='en'><!-- Noncompliant --><body><h1>"
..(response.mess or "Not Found").."</h1><br><p>File "
..request.filename.." not found.</p></body></html>"
			)
		end
	end
end

local threads = {
	current = 1
}

-- create a TCP socket and bind it to the local host, at any port
server=assert(socket.tcp())
server:setoption("reuseaddr", true)
server:settimeout(0)
assert(server:bind("*", PORT))
server:listen(BACKLOG)

-- Print IP and port
local ip, port = server:getsockname()
print("Listening on IP="..ip..", PORT="..port.."...")

-- loop forever waiting for clients
while true do
	-- wait for a connection from any client
	local client, err = server:accept()

	if client then
		local request, err = read_request(client)
		if request then
			if request.method == "GET" then

				local thread = {
					client = client,
					request = request,
					thread = coroutine.create(thread_func)
				}

				table.insert(threads, thread)
			end
		else
			io.stderr:write("[ERROR] "..err.."\n")
		end
	elseif err == "timeout" then
		if threads.current and threads[threads.current] then
			local t = threads[threads.current]
			if coroutine.status(t.thread) == "suspended" then
				local status, data = coroutine.resume(t.thread, t.request, threads.current)
				if status and data then t.client:send(data)
				elseif data then
					io.stderr:write("[ERROR] "..data.."\n")

					--t.client:send (("HTTP/1.1 %d %s\n\r\n\r"):format (500, "Internal server error"))
				end
			else
				t.client:close()
				table.remove(threads, threads.current)
			end
			threads.current = threads.current - 1
			if threads.current < 1 then
				threads.current = #threads
			end
		else threads.current = #threads end
	else
		print("Error happened while getting the connection.nError: "..err)
	end
end
