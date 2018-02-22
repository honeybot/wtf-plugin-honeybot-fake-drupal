local require = require
local tools = require("wtf.core.tools")
local Plugin = require("wtf.core.classes.plugin")
local lfs = require("lfs")
local cjson = require("cjson")

local _M = Plugin:extend()
_M.name = "honeybot.fake.drupal"

function send_response(state,headers,content)
    ngx.status = state
    if headers then
        for key,val in pairs(headers) do
            ngx.header[key] = val
        end
    end
    ngx.print(content)
    ngx.exit(ngx.HTTP_OK)
end

function _M:access(...)
    local select = select
    local instance = select(1, ...)
    local version = self:get_optional_parameter('version')
    local path = self:get_optional_parameter('path')
    local filename = path .. version .. "/" ..ngx.var.uri
    local headers = {}
    local files = cjson.decode(io.open(path.."files.json","rb"):read "*a")
    local dirs = cjson.decode(io.open(path.."dirs.json","rb"):read "*a")

    if files[ngx.var.uri] then
        for md5,versions in pairs(files[ngx.var.uri]) do
            if versions[version] then
                local page = io.open(path .. "content/" .. tostring(md5), "rb"):read "*a"
                send_response(200, {["Content-Type"]="text/html"}, page)
            end
        end
        send_response(404, {["Content-Type"]="text/html"}, "")
    end

    if dirs[string.gsub(ngx.var.uri,"/?$","")] then
        if dirs[string.gsub(ngx.var.uri,"/?$","")][version] then
            send_response(403, {["Content-Type"]="text/html"}, "")
        end
    end


    local module_name, module_path = string.match(ngx.var.uri, "/modules/([^/]*)/?(.*)$")
    local theme_name, theme_path = string.match(ngx.var.uri, "/themes/([^/]*)/?(.*)$")
    if module_name ~= nil or theme_name ~= nil then
        local temp = string.gsub(ngx.var.uri, "/modules/.*$", "")
        local temp = string.gsub(temp, "/themes/.*$", "")
        if dirs[temp] then
            send_response(200, {["Content-Type"]="text/html;charset=UTF-8"}, "")
        else
            send_response(404, {["Content-Type"]="text/html;charset=UTF-8"}, "")
        end
    end

	return self
end

function _M:header_filter(...)
    ngx.header.content_length = nil 
end

function _M:body_filter(...)
    local select = select
    local instance = select(1, ...)
    local version = self:get_optional_parameter('version')
    local path = self:get_optional_parameter('path')

    ngx.arg[1] = ngx.re.gsub(ngx.arg[1],'<meta name="[gG]enerator" content="Drupal[^>]*>', "")
    ngx.arg[1] = ngx.re.gsub(ngx.arg[1],'<head>', '<head>\n<meta name="Generator" content="Drupal '.. string.sub(version,1,1) .. ' (https://www.drupal.org) />\n<!--\n/core/misc/drupal.js\n/core/misc/ajax.js\n/core/misc/tableheader.js\n/core/misc/tabledrag.js\n-->\n')
    return self
end

return _M

