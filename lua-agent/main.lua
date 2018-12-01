protocol = require 'protocol'
Board = require 'board'
Move = require 'move'
Kalah = require 'kalah'
Side = require 'side'
log = require 'utils.log'

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
    if (msg == nil) then
        error("Unexpected end of input")
    end
    return msg
end

-- DONE Change function calls based on game messages perhaps
function Main:gameLoop()
    log.info('gameLoop() started.')
    local state = Kalah

    while true do
        local msg = Main:readMsg()
        log.info("Message Received:", msg)
        local messageType = protocol.getMessageType(msg)

        if messageType == "start" then
            local isFirst = protocol.evaluateStartMsg(msg)
            log.info("Message is first:", isFirst)
            if (isFirst) then
                local move = Move:new(Side.NORTH, 1) -- TODO FIND MOVE
                sendMsg(protocol.createMoveMsg(move.hole))
            else
                state:setOurSide(Side.NORTH)
            end
        elseif messageType == "change" then
            local turn = protocol.evaluateStateMsg(msg)
            state:performMove(Move:new(state.sideToMove, turn.move))
            if not turn.endMove then
                if turn.again then
                    local move = Move:new(Side.NORTH, 1)
                    if move.hole == 0 then
                        sendMsg(protocol.createSwapMsg())
                    else
                        sendMsg(protocol.createMoveMessage(move.hole))
                    end
                end
            end

        elseif messageType == "end" then
            break

        end
    end
    log.info('gameLoop() stopped.')
end


game = Main
-- game:GameLoop()
game:gameLoop()
