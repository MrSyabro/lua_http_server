FROM imolein/luarocks:5.4

COPY http_server.lua .
COPY http_server-dev-2.rockspec .

RUN luarocks install luasec
RUN luarocks install dkjson
RUN luarocks install luafilesystem
RUN luarocks make http_server-dev-2.rockspec

CMD ["http_server", "/var/http"]