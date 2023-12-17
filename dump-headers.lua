echo([[<!DOCTYPE html>
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
    echo("<table border='1'>")
    for k,i in pairs(t) do
        echo(string.format("<tr><td>%s</td><td>%s</td></tr>", k, i))
    end

    echo("</table>")
end

echo("<h1> Headers </h1><br>"..
    "<p>Следующая таблица генерируется из запроса</p>"..
    "<p>Демонстрирует итеративную динамическую генерацию таблиц</p>")

send_table(request.headers)

echo("<br><a href='/'>Home</a>"..floor_base)
