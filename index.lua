echo(([[<!DOCTYPE html>
<html lang='ru'>
    <head>
        <title>Index lua web</title>
        <meta content="text/html; charset=utf-8" />
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet" integrity="sha384-T3c6CoIi6uLrA9TneNEoa7RxnatzjcDSCmG1MXxSR1GAsXEV/Dwwykc2MPK8M2HN" crossorigin="anonymous">
    </head> 
    <body>
        <div class="container my-5">
            <h1 class="fw-light text-center">Скрипт %s </h1><br>
            <div class="row">
                <div class="col-lg-8 mx-auto">
                    <p class="lead">Эта страница динамическая и уже куда более интересна.</p>
                    <p class="lead">В последнем обновлении была добавлена микро библиотека для генерации HTML функциями Lua. Скрипты списка файлов и вывода захоловков запроса были переписаны на эту библиотеку.</p><br>
                    <p class="lead text-muted">$NAME = %s</p>
                    <p class="lead text-muted">Дата на сервере: %s</p>
                </div>
                <div class="col-lg-4 mx-auto">
                    <p>Взгляни на следующую страницу.</p>
                    <a href='/dump-headers' class="btn btn-primary">Dump headers script</a> - простейшая демонстрация рабоыт скриптов. Выдает распарсеные значения заголовков.</br>
                    <a href='/payload.lua' class="btn btn-warning">1GB Payload</a> - Осторожно! Скрипт отправляет гигабайт полезной нагрузки для демонстрации паралельной обработки запросов.</br>
                    <a href='/files' class="btn btn-secondary">Files</a> - Примитивный список файлов.
                </div>
            </div>
        </div>
    </body>
</html>
]]):format(server.request.filename, os.getenv("NAME"), os.date()))
