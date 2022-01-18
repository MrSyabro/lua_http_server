local base = [[<html>
<head>
  <meta charset="utf-8">
  <title>Headers dump</title>
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

local body = "<h1> Headers </h1><br>"
local s = print_table(request.headers)

io.html:write(base:format(body)..s.."\n")