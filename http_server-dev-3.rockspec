package = "http_server"
version = "dev-3"
source = {
   url = "git+https://github.com/MrSyabro/lua_http_server",
   tag = "dev-3",
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
