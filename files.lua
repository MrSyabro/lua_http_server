echo([[<!DOCTYPE html>
<html lang='ru'>
    <head>
        <title>File list</title>
        <meta content="text/html; charset=utf-8" />
    </head> 
    <body>
    	<h1>Files</h1>]])
    
local fs = require "lfs"

if fs then
	echo("<table border='1'>")
	local dir = (request.args.dir or "/")
	for d in fs.dir(server.ROOT_DIR..dir) do
		if d ~=  "." and d ~= ".." then
			local attr, err = fs.attributes(server.ROOT_DIR..dir..d)
			if attr then
				if attr.mode == "directory" then
					echo(
						("<tr><td>%s</td><td><a href='/files.lua?dir=%s/'>Open</a></td><td></td></tr>"):format(d, dir..d))
				elseif attr.mode == "file" then
					echo(
						("\
<tr>\
<td>%s</td>\
<td><a href='/getfile?name=%s'>Get</a> <a href='%s'>Open</a></td>\
<td> Last modified: %s</td>\
</tr>"
):format(d, dir..d, dir..d, os.date("%c", attr.modification)))
				end
			else
				error(err)
			end
		end
	end
	echo ("</table>")
else
	--print("[ERROR] Not installed
	echo("<h3>Error</h3></br>\n<p>"..err.."</p>")
end

echo([[
    </body>
</html>]])
