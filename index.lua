local base = [[<html>
<body>
%s
</body>
</html>]]

local body = 
"<h1> "..request.filename.." </h1>"..
"<br><p> This is index lua script. <p><br>"..
"<a href='/dump-headers.lua'>Dump headers script</a>"

io.html:write(base:format(body).."\n")