local page = dofile "page.lua"

echo(page("Home", ([[
        <div class="container my-5">
            <h1 class="fw-light text-center">Скрипт %s </h1><br>
            <div class="row">
                <div class="col-lg-6 mx-auto">
                    <p class="lead">Эта страница динамическая и уже куда более интересна.</p>
                    <p class="lead">В последнем обновлении была добавлена микро библиотека для генерации HTML функциями Lua. Скрипты списка файлов и вывода захоловков запроса были переписаны на эту библиотеку.</p><br>
                    <p class="lead text-muted">$NAME = %s</p>
                    <p class="lead text-muted">Дата на сервере: %s</p>
                </div>
            </div>
        </div>
]]):format(server.request.filename, os.getenv("NAME"), os.date())))
