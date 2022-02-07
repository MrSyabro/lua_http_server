package = "http_server"
version = "dev-2"
source = {
   url = "git+https://github.com/MrSyabro/lua_http_server"
}
description = {
   homepage = "https://github.com/MrSyabro/lua_http_server",
   license = "MIT"
}
dependencies = {
   "lua >= 5.2",
   "luasocket >= 2.0"
}
build = {
   type = "builtin",
   modules = {},
   install = {
      bin = {
         http_server = "http_server.lua"
      }
   }
}
