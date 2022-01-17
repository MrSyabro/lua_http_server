local base = [[<html>
<body>
%s
</body>
</html>]]

local body = [[<h> Header </h></br>
<p> Test1 <p>]]

io.html:write(base:format(body).."\n")
