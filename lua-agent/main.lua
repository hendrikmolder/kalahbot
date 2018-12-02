package.path = "./?.lua;;" .. package.path -- Fix path if needed and *prefer* local modules instead of luarocks
protocol = require 'protocol'
Board = require 'board'
Move = require 'move'
Kalah = require 'kalah'
Side = require 'side'
log = require 'utils.log'

Main = {}

function Main:new (o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    return o
end

function Main:sendMsg(msg)
    io.write(msg)
    log.info('Message sent:', msg)
end

function Main:readMsg()
    local msg = string.format( "%s\n", io.read())
    if (msg == nil) then
        log.error("Unexpected end of input at:", msg)
    end
    return msg
end

function Main:gameLoop()
    log.info('Game loop started.')
    local state = Kalah
    local board = Board:new(7,7)

    while true do
        local msg = Main:readMsg()
        log.info("Message Received:", msg)
        local messageType = protocol.getMessageType(msg)

        if messageType == "start" then
            local isFirst = protocol.evaluateStartMsg(msg)
            if (isFirst) then
                local move = Move:new(nil, Side.NORTH, 2) -- TODO FIND MOVE
                Main:sendMsg(protocol.createMoveMsg(move.hole))
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
            log.info('Received END command. Stopping.')
            break
        end
    end
    log.info('gameLoop() stopped.')
end

log.info('Bot started.')
game = Main
game:gameLoop()
