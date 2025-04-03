---@alias html_args table<string, any>
---@alias html_node table<string, html_node>|fun(args: html_args, ...:string)

---@type html_node
local M = {
    __name = "HTML"
}

local function parse_args(args)
    if not args then return "" end
    local out = {""}
    for key, val in pairs(args) do
        table.insert(out, ("%s=%q"):format(key,val))
    end
    local out_str = table.concat(out, " ") .. " "
    return out_str
end

---@return string
function M.doctype()
    return "<!DOCTYPE html>"
end

M.__index = function(self, key)
    return function(args, cont, ...)
        if type(cont) ~= "table" then cont = table.pack(cont, ...) end
        if not cont or (#cont < 1) then 
            local out = "<%s%%s />"
            local out_f = out:format(key, key)
            return (out_f):format(parse_args(args))
        else
            local out = "<%s%%s>%%s</%s>"
            local out_f = out:format(key, key)
            return (out_f):format(parse_args(args), table.concat(cont))
        end
    end
end

return setmetatable(M, M)