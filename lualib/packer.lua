local utils = require "utils"
local cjson = require "cjson"
local skynet = require "skynet"

local M = {}

-- 组包
function M.pack(id, msg)
    local msg_str = cjson.encode(msg)
    skynet.error(msg_str);
    local len = 2 + 2 + #msg_str
    local data = string.pack(">HHs2", len, id, msg_str)
    return data
end

-- 拆包
function M.unpack(data)
    local id, params = string.unpack(">Hs2", data)

    params = cjson.decode(params)

    return id, params
end

return M
