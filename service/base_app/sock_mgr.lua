local skynet = require "skynet"
local socket = require "socket"
local utils = require "utils"
local packer = require "packer"
local msg_define = require "msg_define"
local cjson = require "cjson"

local M = {
    dispatch_tbl = {},
    authed_fd = {}
}

function M:start(conf)
    self.gate = skynet.newservice("gate")

    skynet.call(self.gate, "lua", "open", conf)

    skynet.error("login service listen on port "..conf.port)
end

-------------------处理socket消息开始--------------------
function M:open(fd, addr)
    skynet.error("New client from : " .. addr)
    skynet.call(self.gate, "lua", "accept", fd)
end

function M:close(fd)
    self:close_conn(fd)
    skynet.error("socket close "..fd)
end

function M:error(fd, msg)
    self:close_conn(fd)
    skynet.error("socket error "..fd.." msg "..msg)
end

function M:warning(fd, size)
    self:close_conn(fd)
    skynet.error(string.format("%dK bytes havn't send out in fd=%d", size, fd))
end

function M:data(fd, msg)
    skynet.error(string.format("recv socket data fd = %d, len = %d ", fd, #msg))
    local proto_id, params = string.unpack(">Hs2", msg)

    local proto_name = msg_define.id_2_name(proto_id)

    skynet.error(string.format("socket msg id:%d name:%s %s", proto_id, proto_name, params))
    params = cjson.decode(params)

    self:dispatch(fd, proto_id, proto_name, params)
end

function M:close_conn(fd)
    self.authed_fd[fd] = nil
end

-------------------处理socket消息结束--------------------

-------------------网络消息回调函数开始------------------
function M:register_callback(name, func, obj)
    self.dispatch_tbl[name] = {func = func, obj = obj}
end

function M:dispatch(fd, proto_id, proto_name, params)
    local t = self.dispatch_tbl[proto_name]
    if not t then
        skynet.error("协议编号"..proto_id)
        skynet.error("can't find socket callback "..proto_name)
        return
    end

    local ret
    if t.obj then
        ret = t.func(t.obj, fd, params)
    else
        ret = t.func(fd, params)
    end

    if ret then
        skynet.error("ret msg:"..cjson.encode(ret))
        socket.write(fd, packer.pack(proto_id, ret))
    end
end

function M:send(fd, proto_name, msg)
    local proto_id = msg_define.name_2_id(proto_name)
    local str = cjson.encode(msg)
    skynet.error("send msg:"..str)
    socket.write(fd, packer.pack(proto_id, msg))
end

-------------------网络消息回调函数结束------------------

return M
