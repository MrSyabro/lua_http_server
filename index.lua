server.send_response(response)

coroutine.yield([[<!DOCTYPE html>
<html lang='ru'>
    <head>
        <title>Index lua web</title>
        <meta content="text/html; charset=utf-8" />
    </head> 
    <body>]])

coroutine.yield(
"<h1> "..request.filename.." </h1><br>"..
"<p>Эта страница динамическая и уже куда более интересна.<p><br>"..
"<p>$NAME = "..os.getenv("NAME").."</p>"..
"<p>Дата на сервере: "..os.date().."</p><br>"..
"<p>Взгляни на следующую страницу.</p>"..
"<a href='/dump-headers'>Dump headers script</a> - простейшая демонстрация рабоыт скрипто. Выдает распарсеные значения заголовков.</br>"..
"<a href='/payload.lua'>1GB Payload</a> - Осторожно! Скрипт отправляет гигабайт полезной нагрузки для демонстрации паралельной обработки запросов.</br>"..
"<a href='/files'>Files</a> - Примитивный список файлов.</br>")

coroutine.yield([[    </body>
</html>]])
