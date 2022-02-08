local base_head = [[<!DOCTYPE html>
<html lang='ru'><!-- Noncompliant -->
    <head>
        <title>File not found</title>
        <meta content="text/html; charset=utf-8" />
    </head>
    <body>]]

local file = io.open(server.root_dir..request.args.name, "rb")
if file then
	local data_lenghth = file:seek ("end")
	response.headers["Content-Type"] = "application/octet-stream"
	response.headers["Content-Disposition"] = "attachment; filename="..request.args.name
	response.headers["Content-Length"] = tostring (data_lenghth)
	server.send_response(response)

	file:seek("set")
	for l in file:lines(1024*1024) do
		coroutine.yield(l)
	end
else
	server.send_response(response)
	coroutine.yield(base_head)
	coroutine.yield("<p>File ".. request.args.name .." not found</p>")
	coroutine.yield("</body>\n</html>")
end
