local base = [[<!DOCTYPE html>
<html lang='ru'><!-- Noncompliant -->
    <head>
        <title>Request headers</title>
        <meta content="text/html; charset=utf-8" />
    </head>
    <body>
        %s
    </body>
</html>]]

local function print_table(t)
    local out_table = {"<table border='1'>"}
    for k,i in pairs(t) do
        local str = string.format("<tr><td>%s</td><td>%s</td></tr>", k, i)
        table.insert(out_table, str)
    end

    table.insert(out_table, "</table>")

    return table.concat(out_table, "\n")
end

local head = "<h1> Headers </h1><br>"..
    "<p>Следующая таблица генерируется из запроса</p>"..
    "<p>Демонстрирует итеративную динамическую генерацию таблици</p>"
local s = print_table(request.headers)
local body_end = "<br><a href='/'>Home</a>"

io.html:write(base:format(head..s..body_end))