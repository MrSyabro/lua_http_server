server.send_response(response)

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

local function send_table(t)
    coroutine.yield("<table border='1'>")
    for k,i in pairs(t) do
        coroutine.yield(string.format("<tr><td>%s</td><td>%s</td></tr>", k, i))
    end

    coroutine.yield ("</table>")
end

coroutine.yield ("<h1> Headers </h1><br>"..
    "<p>Следующая таблица генерируется из запроса</p>"..
    "<p>Демонстрирует итеративную динамическую генерацию таблиц</p>")

send_table(request.headers)

coroutine.yield("<br><a href='/'>Home</a>"..floor_base)
