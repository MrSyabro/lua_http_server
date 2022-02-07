send_response(response)

coroutine.yield ([[<!DOCTYPE html>
<html lang='ru'><!-- Noncompliant -->
    <head>
        <title>Request headers</title>
        <meta content="text/html; charset=utf-8" />
    </head>
    <body>]])

local floor_base = [[
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

coroutine.yield ("<h1> Headers </h1><br>"..
    "<p>Следующая таблица генерируется из запроса</p>"..
    "<p>Демонстрирует итеративную динамическую генерацию таблиц</p>")

coroutine.yield(print_table(request.headers))

coroutine.yield("<br><a href='/'>Home</a>"..floor_base)
