local base = [[<!DOCTYPE html>
<html lang='ru'><!-- Noncompliant -->
    <head>
        <title>File not found</title>
        <meta content="text/html; charset=utf-8" />
    </head>
    <body>
        %s
    </body>
</html>]]

local file = io.open(request.args.name, "rb")
if file then
	response.headers["Content-Type"] = "application/octet-stream"
	response.headers["Content-Disposition"] = "attachment; filename="..request.args.name
	io.html:write(file:read("*a"))
else
	io.html:write(base:format("<p>File ".. request.args.name .." not found</p>"))
end
