--
-- Created by IntelliJ IDEA.
-- User: Hendrik
-- Date: 26/10/2018
-- Time: 20:36
-- To change this template use File | Settings | File Templates.
--

Message = {
    type = nil;
    body = nil
}

-- Define Message object
function Message:new (message)
    message = message or {}
    setmetatable(message, self)
    self.__index = self
    return message
end

function Message:getMessageType()
    return self.type
end

function Message:getBody()
    return self.body
end