#!/usr/bin/env lua
local socket = require("socket")
local url = require "socket.url"

--{{Options
---The port number for the HTTP server. Default is 80
PORT = 8080
-- Этот параметр определяет, где сервер будет искать файлы.
ROOT_DIR = arg[1] or "."
--}}Options

local codes = {
	[200] = "OK",
	[404] = "Page not found",
	[500] = "Internal server error",
}

local ssl
local ssl_param
local cert_file = io.open(ROOT_DIR .. "/cert.pem")
if cert_file then
	local succ, ssll = pcall(require, "ssl")
	if succ then
		print("[INFO] OpneSSL loaded")
		ssl_param = {
			mode = "server",
			protocol = "sslv23",
			key = ROOT_DIR .. "/key.pem",
			certificate = ROOT_DIR .. "/cert.pem",
			verify = { "peer" },
			options = { "all" },
		}
		ssl = ssll
	elseif ssll then
		print("[WARN] OpennSSL loading error:", ssl)
	end
	cert_file:close()
else
	print("[INFO] SSL disable")
end

local recvt = {}
local sendt = {}

function table.search(list, data)
	for i, d in ipairs(list) do
		if d == data then return i end
	end
end

function table.removedata(list, data)
	local pos = table.search(list)
	if pos then
		table.remove(list, pos)
	end
end

---@type Server[]
local threads = {}
local last_thread = 0

local rules = {}

local rules_file, err = loadfile(ROOT_DIR .. "/rules.lua", "t", {})
if rules_file then
	rules = rules_file()
	print("[INFO] Rules loaded")
elseif err then
	print("[ERROR]", err)
else
	print("[WARN] Rules not found.")
end

local start_line_fmt = "(%w+)%s+(%g+)%s+(%w+)/([%d%.]+)"
local function parse_start_line(start_line)
	local request = {startline = start_line}
	request.method, request.rawurl, request.protoname, request.protover = start_line:match(start_line_fmt)
	return request
end

local header_match = "(%g+): ([%g ]+)"
local function read_request(client)
	repeat
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
					local key, value = string.match(header_line, header_match)
					if key then
						request.headers[key:lower()] = value
					end
				end
			end
			request.header = table.concat(raw_headers, "\n")
			request.url = url.parse(request.rawurl, {})
			return request
		elseif err == "timeout" then
			coroutine.yield()
		elseif err == "closed" then
			return
		else
			io.stderr:write("[ERROR] Client " .. err .. "\n")
			return
		end
	until start_line
end

local startline_fmt = "HTTP/1.1 %d %s\n"
local function resp_startline(code, mess)
	return startline_fmt:format(code, mess)
end

local header_fmt = "%s: %s"
local function concat_headers(headers)
	local out = {}
	for i, k in pairs(headers) do
		local header = (header_fmt):format(i, k)
		table.insert(out, header)
	end
	return table.concat(out, "\n")
end

---@class Server
---@field receiving boolean стоит ли клиент в очереди на чтение данных
---@field sending boolean стоит ли клиент в очереди на отправку данных
---@field closed boolean?
---@field startline_sended boolean?
---@field header_sended boolean?
---@field body_sended boolean?
---@field client table Socket.TCP клиент
---@field request table
---@field response table
---@field thread thread
---@field datagramsize number
local server_obj = {}
server_obj.receiving = true
server_obj.sending = false
server_obj.datagramsize = socket._DATAGRAMSIZE

---Добавить клиента в очеред на получение данных
---@param state boolean
function server_obj:setreceiving(state)
	if self.receiving == state then return end
	if self.receiving then
		table.removedata(recvt, self.client)
	else
		table.insert(recvt, self.client)
	end
	self.receiving = state or false
end

---Добавить клиент в очередь на отправку данных
---@param state boolean
function server_obj:setsending(state)
	if self.sending == state then return end
	if self.sending then
		table.removedata(sendt, self.client)
	else
		table.insert(sendt, self.client)
	end
	self.sending = state or false
end

---Отсылает стартовую строку
function server_obj:sendstartline()
	if self.startline_sended then return end
	self.client:send(resp_startline(self.response.code, self.response.mess))
	self.startline_sended = true
end

---Отсылает, если надо, заголовки
function server_obj:sendheaders()
	local response = self.response
	if self.header_sended == true then return end
	local out = concat_headers(response.headers) .. "\n\n"
	self:sendstartline()
	self.client:send(out)
	self.header_sended = true
end

---Отсылает, если надо, тело, сохраненное в response.body, а перед этим headers
function server_obj:sendbody()
	local response = self.response
	if self.body_sended then return end

	local body, client = response.body, self.client
	if #body > 0 then
		local bodytext = table.concat(body)
		response.headers["Content-Length"] = #bodytext
		self:sendheaders()
		client:send(bodytext)
	else
		self:sendheaders()
	end

	self.body_sended = true
end

---Отсылает, если надо, заголовки и тело страницы, и закрывает соединение
function server_obj:closecon()
	if self.closed then return end
	self:sendbody()
	self.client:close()
	self.closed = true
end

---Отправляет ошибку и закрывает соединение
---@param code number
---@param text string
function server_obj:error(code, text)
	local response = self.response
	local err_mess = codes[code]
	response.code = code
	response.mess = err_mess
	if text then
		text = text:gsub("\n", "<br>")
	else
		text = ""
	end
	table.insert(response.body,
		("<!DOCTYPE html><html lang='en'><body><h1>%s</h1><br><p>%s</p></body></html>"):format(err_mess, text))
end

server_obj.__index = server_obj
server_obj.ROOT_DIR = ROOT_DIR


local args_fmt = "([^&=?]+)=([^&=?]+)"
---Парсит аргументы формата www-form-urlencoded
---@param query string
---@return table
function server_obj.parsequery(query)
	local args = {}
	for key, value in string.gmatch(query,
		args_fmt) do
		args[key] = url.unescape(value)
	end
	return args
end

local env_mt = { __index = _G }
---@param threaddata Server
---@return function?
local function thread_func(threaddata)
	local client = threaddata.client
	repeat
		threaddata:setreceiving(true)
		threaddata:setsending(false)
		local request = read_request(client)
		
		if request then
			local response = {
				headers = {
					["Content-Type"] = "text/html; charset=utf-8", -- По дефолту отправляем html, utf-8
					["Date"] = os.date("!%c GMT"),
				},
				body = {},
				code = 200,
				mess = "OK",
			}
			for _, rule in ipairs(rules) do
				if request.rawurl:match(rule.regex) then
					rule.func(request, response)
				end
			end
			threaddata.request = request
			threaddata.response = response
			threaddata.startline_sended = false
			threaddata.header_sended = false
			threaddata.body_sended = false
			
			local filename = threaddata.request.url.path
			local is_script = string.find(filename, ".lua") and true

			if request.headers.connection == "keep-alive" then
				client:setoption("keepalive", true)
			end
			threaddata:setreceiving(false)
			threaddata:setsending(true)
			coroutine.yield()
			if is_script then -- если обратились к lua фалу
				local threadenv = setmetatable({
					server = threaddata,
					request = request,
					response = response,
					client = threaddata.client,
					echo = function(...)
						local args = table.pack(...)
						for i = 1, args.n do
							table.insert(threaddata.response.body, tostring(args[i]))
						end
					end
				}, env_mt)

				local script_func, err = loadfile(
					ROOT_DIR .. filename, "bt", threadenv) -- загрузка скрипта

				if script_func then
					local ret, err = xpcall(script_func, debug.traceback)
					if not ret then
						io.stderr:write("[ERROR] " .. err .. "\n")
						threaddata:error(500, err)
					end
				else
					io.stderr:write("[ERROR] " .. err .. "\n")
					threaddata:error(500, err)
				end
				threaddata:sendbody()
			else
				local f = io.open(ROOT_DIR .. request.url.path, "rb")

				if f then
					local data_lenghth = f:seek("end"); f:seek("set")
					response.headers["Content-Length"] =
						tostring(data_lenghth)
					threaddata:sendheaders()
					for d in f:lines(socket._DATAGRAMSIZE) do
						client:send(d)
						coroutine.yield()
					end

					f:close()
				else
					print("[ERROR] Page not found", request.url.path)
					threaddata:error(500, "File "
						.. request.url.path .. " not found.")
					threaddata:sendbody()
				end
			end
			if request.headers.connection ~= "keep-alive" then
				return
			end
		else
			return
		end
	until not request and threaddata.closed
end

local function process_subpool(subpool, pool)
	for _, client in ipairs(subpool) do
		local t = threads[client]

		if t then
			local cr = t.thread
			local status, error = coroutine.resume(cr)
			local crstatus = coroutine.status(cr)
			if status and crstatus == "dead" then
				t:closecon()
				table.removedata(pool, client)
				threads[client] = nil
			elseif status == false then
				io.stderr:write("[ERROR] " .. error .. " in " .. last_thread .. "\n")
				t:error(500, err)
				t:closecon()
				table.removedata(pool, client)
				threads[client] = nil
			end
		end
	end
end

-- create a TCP socket and bind it to the local host, at any port
local server = assert(socket.tcp())
server:setoption("reuseaddr", true)
server:settimeout(300)
assert(server:bind("0.0.0.0", PORT))
server:listen(socket._SETSIZE)
print("[INFO] Max connections count", socket._SETSIZE)

-- Print IP and port
print(("[INFO] Listening on IP=%s, PORT=%d."):format(server:getsockname()))

while true do
	local client, err = server:accept()

	if client then
		if ssl and ssl_param then
			local ssl_client, err = ssl.wrap(client, ssl_param)
			if ssl_client then
				local suc, err = ssl_client:dohandshake()
				if suc then
					client = ssl_client
				else
					print("[ERROR] HANDSHAKE", err)
				end
			else
				print("[ERROR] SSL_WRAP", err)
			end
		end
		client:settimeout(0)
		local newth = coroutine.create(thread_func)
		local threaddata = setmetatable({
			client = client,
			thread = newth,
		}, server_obj)
		
		threads[client] = threaddata
		table.insert(recvt, client)
		server:settimeout(0)
		coroutine.resume(newth, threaddata)
	elseif err == "timeout" then
		if #recvt > 0 or #sendt > 0 then
			local readyread, readysend, err = socket.select(recvt, sendt, 0.01)
			if err ~= "timeout" then
				process_subpool(readyread, recvt)
				process_subpool(readysend, sendt)
			end
		else
			server:settimeout(300)
		end
	else
		print("Error happened while getting the connection.nError: " .. err)
	end
end
