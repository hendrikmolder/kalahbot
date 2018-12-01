Protocol = require 'protocol'
Board = require 'board'
Move = require 'move'
Kalah = require 'kalah'
Side = require 'Side'
Log = require 'utils.log'

-- Set logfile to output logs to the logs directory
-- Set file name to be mm/DD/YY-HH:MM::SS.log
Log.outfile = 'logs/'..(os.date("Log-%c"))..'.log'

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
        Log.debug("Message Received:", msg)
        local messageType = Protocol.getMessageType(msg)
        if messageType == "start" then
            local isFirst = Protocol.evaluateStartMsg(msg)
            Log.info("Message is first:", isFirst)
            if (isFirst) then
                local move = Move:new(Side.NORTH, 1) -- TODO FIND MOVE
                sendMsg(Protocol:createMoveMsg(move.hole))
            else
                state:setOurSide(Side.NORTH)
            end
        elseif messageType == "change" then
            local turn = Protocol.evaluateStateMsg(msg)
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

        elseif messageType == "end" then
            break

        end
    end
end


game = Main
-- game:GameLoop()
game:gameLoop()
