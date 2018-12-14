package.path = "./?.lua;;" .. package.path -- Fix path if needed and *prefer* local modules instead of luarocks
--local pl = require 'pl.pretty'

protocol = require 'protocol'
Board = require 'board'
Move = require 'move'
Kalah = require 'kalah'
Side = require 'side'
log = require 'utils.log'
MCTS = require 'mcts.mcts'
--local t = require 'pl.tablex'

Main = {}

function Main:new (o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    return o
end

function Main:sendMsg(msg)
    io.write(msg)
    -- The critical piece of the puzzle -
    -- https://stackoverflow.com/questions/30669863/lua-flushing-input-buffer-during-interactive-terminal-session
    io.flush()
    log.info('Message sent:', msg)
end

function Main:readMsg()
    local msg = string.format( "%s\n", io.read())
    log.info('Message received:', msg)
    if (msg == nil) then
        log.error("Unexpected end of input at:", msg)
    end
    return msg
end

function Main:gameLoop()
    log.info('Game loop started.')

    -- Run random seed for random numbers
    math.randomseed(os.time())
    math.random()
    math.random()
    math.random()
    --  END of random popping

    local state = Kalah:new()
    local mctsEngine = MCTS:init(0.5, 15)

    while true do
        local msg = Main:readMsg()
        local messageType = protocol.getMessageType(msg)
        if messageType == "start" then
            local isFirst = protocol.evaluateStartMsg(msg)
            if (isFirst) then
                local move = mctsEngine:getMove(state)
                Main:sendMsg(protocol.createMoveMsg(move))
            else
               state:setOurSide(Side.NORTH)

                -- Pie Rule - Random swap
               local pieRuleRandom = math.random(1, 100)
               if pieRuleRandom % 2 == 0 then -- Send a SWAP message
                   state:setOurSide(Side.SOUTH)
                   Main:sendMsg(protocol.createSwapMsg())
               end
            end

        elseif messageType == "state" then
            local turn = protocol.evaluateStateMsg(msg, state:getBoard())
            -- We don't really have to worry about moving for the opponent again, because everytime we get a state
            -- message, the evaluateStateMsg() function handles it for us, leaving us to only focus on our moves below
            -- this
            if not turn.endMove then
                if turn.again then
                    state:setSideToMove(state:getOurSide())
                    -- On Pie rule
                    if (turn.move == -1) then
                        state:setOurSide(Side:getOpposite(state:getOurSide()))
                        log.info("OUR SIDE IS NOW", state:getOurSide())
                        log.info("Side to move", state:getSideToMove())
                    end

                    local mctsMove = mctsEngine:getMove(state)
                    local msgToSend = protocol.createMoveMsg(mctsMove)
                    Main:sendMsg(msgToSend)
                else
                    state:setSideToMove(Side:getOpposite(state:getOurSide()))
                end
            end
        elseif messageType == "end" then
            log.info('Received END command. Stopping.')
            break
        end
    end
    log.info('Game loop stopped.')
end

log.info('Bot started.')
game = Main
game:gameLoop()
