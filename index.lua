local base = [[<!DOCTYPE html>
<html lang='ru'>
    <head>
        <title>Index lua web</title>
        <meta content="text/html; charset=utf-8" />
    </head> 
    <body>
        %s
    </body>
</html>]]

local body = 
"<h1> "..request.filename.." </h1><br>"..
"<p>Эта страница динамическая и уже куда более интересна.<p><br>"..
"<p>Взгляни на следующую страницу.</p><br>"..
"<a href='/dump-headers.lua'>Dump headers script</a>"

io.html:write(base:format(body).."\n")