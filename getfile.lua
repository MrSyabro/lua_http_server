local base_head = [[<!DOCTYPE html>
<html lang='ru'>
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
	server:sendheaders()

	file:seek("set")
	for l in file:lines(1024*1024) do
		client:send(l)
		coroutine.yield()
	end
else
	echo(base_head)
	echo("<p>File ".. request.args.name .." not found</p>")
	echo("</body>\n</html>")
end
