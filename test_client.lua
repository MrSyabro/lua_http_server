local socket = require "socket"

IP = "localhost"
PORT = 8080

local function receive (connection)
	connection:settimeout(0)
	-- не блокирует данные
	local s, status, partial = connection:receive(2^10)
	if status == "timeout" then
		coroutine.yield(connection)
	end
	return s or partial, status
end

local function download (host, file)
	local c = assert(socket.connect(host, PORT))
	local count = 0 -- counts number of bytes read
	c:send("GET " .. file .. " HTTP/1.0\r\n\r\n")
	while true do
		local s, status = receive(c)
		count = count + #s
		if status == "closed" then break end
	end
	c:close()
	print(file, count)
end

threads = {}

-- список всех живых нитей
function get (host, file)
	-- создает сопрограмму
	local co = coroutine.create(function ()
		download(host, file)
	end)
	-- вставляет ее в список
	table.insert(threads, co)
end

function dispatch ()
	local i = 1
	local timedout = {}
	while true do
		if threads[i] == nil then
			-- больше нет нитей?
			if threads[1] == nil then break end
			i = 1
			-- перезапускает цикл
			timedout = {}
		end
		local status, res = coroutine.resume(threads[i])
		if not res then
			-- нить выполнила свою задачу?
			table.remove(threads, i)
		else
			-- превышено время ожидания
			i = i + 1
			timedout[#timedout + 1] = res
			if #timedout == #threads then
				-- все нити заблокированы?
				socket.select(timedout)
			end
		end
	end
end

for i=1, 100 do
get(IP, "/index.lua")
get(IP, "/dump-headers.lua")
get(IP, "/test.html")
end

local clock = os.clock()

dispatch()

print(os.clock() - clock)
