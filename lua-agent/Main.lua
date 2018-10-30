--
-- Created by IntelliJ IDEA.
-- User: aayushchadha
-- Date: 26/10/18
-- Time: 11:01
-- To change this template use File | Settings | File Templates.
--
local protocol = require 'protocol'


Main = {}

-- Define game "object"
function Main:new (game)
    game = game or {}
    setmetatable(game, self)
    self.__index = self
    return game
end

function Main:sendMsg(msg)
    io.write(msg, '\n')
end

-- DONE this should have some sort of check
function Main:readMsg()
    local msg = io.read()
    print (msg)
    if (msg == nil) then
       error("Unexpected end of input")
    end
    return msg
end

-- TODO Change function calls based on game messages perhaps
function Main:gameLoop()
    while true do
        protocol.parseMessage(Main:readMsg())
    end
end

game = Main

game:gameLoop()

