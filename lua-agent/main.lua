--
-- Created by IntelliJ IDEA.
-- User: aayushchadha
-- Date: 23/11/18
-- Time: 12:07
-- To change this template use File | Settings | File Templates.
--

Protocol = require 'protocol'
Board = require 'board'
Move = require 'move'
Kalah = require 'kalah'
Side = require 'Side'

Main = {}

-- Define game "object"
function Main:new (o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    return o
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

-- DONE Change function calls based on game messages perhaps
function Main:gameLoop()
    local state = Kalah
    while true do
        local msg = Main:readMsg()
        local messageType = Protocol:getMessageType(msg)
        if messageType == "START" then
            local isFirst = Protocol:evaluateStateMsg(msg)
            if (isFirst) then
                local move = Move:new(Side.NORTH, 1) -- TODO FIND MOVE
                sendMsg(Protocol:createMoveMsg(move.hole))
            else
                state:setOurSide(Side.NORTH)
            end
        elseif messageType == "CHANGE" then
            local turn = Protocol:evaluateStateMsg(msg)
            state:performMove(Move:new(state.sideToMove, turn.move))
            if not turn.endMove then
                if turn.again then
                    local move = Move:new(Side.NORTH, 1)
                    if move.hole == 0 then
                        sendMsg(Protocol:createSwapMsg())
                    else
                        sendMsg(Protocol:createMoveMessage(move.hole))
                    end
                end
            end

        elseif messageType == "END\n" then
            break

        end
    end
end


game = Main
-- game:GameLoop()
game:gameLoop()
