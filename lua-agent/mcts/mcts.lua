--
--  REFERENCES
--  1. https://www.baeldung.com/java-monte-carlo-tree-search
--
require('pl.stringx').import()

local t = require 'pl.tablex'

local log = require '..utils.log'
local protocol = require '..protocol'
local State = require '..kalah'
local Side = require '..side'
local Tree = require 'mcts.tree'
local Node = require 'mcts.node'
local UCT = require 'mcts.uct'

MCTS = {}
MCTS.__index = MCTS

log.info('MCTS started. Import working.')

-- MCTS implementation based on https://jeffbradberry.com/posts/2015/09/intro-to-monte-carlo-tree-search/

-- TODO Remove other data structure based MCTS

function MCTS:init(state, calculationTime, maxMoves)
    local o = {}
    setmetatable(o, self)
    self.__index    = self
    -- The state to start MCTS from
    self.state = state
    -- Table to hold game states and statistics on them
    self.states = {}
    self.calculationTime = tonumber(calculationTime) or 30
    self.maxMoves = tonumber(maxMoves) or 50
    -- Track plays from current state
    self.plays = {}
    self.wins = {}
end

function MCTS:update(state)
    table.insert(self.states, state)
end

function MCTS:getMove()
    local calculationStartTime = os.time()
    local legalMoves = self.state:getAllLegalMoves()
    local sideToPlay = self.state:getSideToMove()

    if (#legalMoves == 0) then
        return
    elseif (#legalMoves == 0) then
        return legalMoves[1]
    end

    local games = 0

    while os.time() - calculationStartTime < self.calculationTime do
        self:runSimulation()
        games = games + 1
    end
    -- [(p, self.board.next_state(state, p)) for p in legal]
    -- create a list of state action pairs from all possible legal moves
    -- [[ TODO Lua Equivalent would be a table with the key being the move and the
    --  Value being the resultant state --]]

    --[[
    -- percent_wins, move = max(
            (self.wins.get((player, S), 0) /
             self.plays.get((player, S), 1),
             p)
            for p, S in moves_states
        )

        TODO calculate wins percentage and plays percentage by "getting" the value of "state" with "player" to
        play for all next move_states. This returns a tuple consisting of the play and the win percentage of
        that play. The Lua equivalent would be
        to compute the max using state references into the wins and plays table,
        this would get us the next state but we still need to know the move that gets us there and
        am not sure we have a way to do that yet
    --]]
    return state:getAllLegalMoves()
end

function MCTS:runSimulation()
    -- Copy the state to allow for simulations
    local stateCopy = t.deepcopy(self.state)
    local ourSide = stateCopy:getOurSide()
    local sideToPlay = stateCopy:getSideToMove()
    local oppositeSide = Side:getOpposite(ourSide)

    local expand = true

    local visited_states = {}

    local winner

    for moves=1,self.maxMoves do
        local legalMoves = stateCopy:getAllLegalMoves()
        -- Select a random legal move to make
        local randomIndex = math.random(1, #legalMoves)
        local randomMove = legalMoves[randomIndex]

        -- Create the state change message
        local randomChangeMSg = protocol.createChangeMsg(randomMove, stateCopy:getBoard())

        -- Play that random move AND update the board
        -- TODO update protocol to update all of state and not just board so we know whose turn is it
        local turn = protocol.evaluateStateMsg(randomChangeMSg, stateCopy:getBoard())
        if not turn.endMove then
            if turn.again then
                stateCopy:setSideToMove(ourSide)
            else
                stateCopy:setSideToMove(oppositeSide)
            end
        end

        self.states[stateCopy:toString()] = true

        -- Transposition table of sorts
        if expand and self.plays[statesCopy:toString()] == nil then
            expand = false
            self.plays[statesCopy:toString()] = 0
            self.wins[statesCopy:toString()] = 0
        end

        -- Add to set of visited states (It's a set, trust me)
        visited_states[stateCopy:toString()] = true

        winner = stateCopy:getWinner()

        -- If a winner is found, end simulation to start back prop (?)
        if winner ~= nil then
            break
        end
    end

    -- Update visit statistics
    for _,v in ipairs(visited_states) do
        if self.plays[v] == nil then
        else
            self.plays[v] = self.plays[v] + 1
            local keyParts = v:split(";", 4)
            local sideToMove = tonumber(keyParts[2])
            if winner == sideToMove then
                self.wins[v] = self.wins[v] + 1
            end
        end
    end






    -- if makeMove:getHole() == 1 then
    --     Main:sendMsg(protocol.createSwapMsg())
    -- else
    --     Main:sendMsg(protocol.createMoveMsg(makeMove.hole))
    -- end
    log.info('[MCTS] Played a random move: ', randomMove:getHole())
    return stateCopy
end

function MCTS.mcts()
    local WIN_SORE = 10
    local level
    local opp

    MCTS.findNextMove(board, side)

end

function MCTS.findNextMove(board, state)
    local rootNode = Node:new(nil, state)
    local tree = Tree:new(nil, rootNode)

    while (true) do
        local promisingNode = MCTS.selectPromisingNode(rootNode)

        if (promisingNode:getState():getBoard() == nil) then
            MCTS.expandNode(promisingNode)
        end

        local nodeToExplore = promisingNode

        if (#promisingNode:getChildren() > 0) then
            nodeToExplore = promisingNode:getRandomChild()
        end

        local playoutResult = MCTS.simulateRandomPlayout(nodeToExplore)
        MCTS.backPropagation(nodeToExplore, playoutResult)
    end

    local winnerNode = rootNode:getChildWithMaxScore()
    tree:setRoot(winnerNode)
    return winnerNode:getState():getBoard()
end

function MCTS.selectPromisingNode(rootNode)
    local node = rootNode
    while (#node:getChildren() ~= 0) do
        node = UCT.findBestNodeWithUCT(node)
    end
    return node
end

function MCTS.expandNode(node)

end

function MCTS:evaluateStateUsingHeuristic(state)
    -- Evaluation heuristic taken from:
    -- 1) https://blog.hackerrank.com/mancala/
    -- 2) (TODO create citation) http://jabaier.sitios.ing.uc.cl/iic2622/kalah.pdf
    local ourSide = state:getOurSide()
    local oppositeSide = Side:getOpposite(ourSide)

    local seedsInOurStore = state:getBoard():getSeedsInStore(ourSide)
    local seedsInOppStore = state:getBoard():getSeedsInStore(oppositeSide)

    local ourTotalSeeds = 0
    local oppTotalSeeds = 0

    for hole=1,7 do
        ourTotalSeeds = ourTotalSeeds + state:getBoard():getSeeds(ourSide, hole)
        oppTotalSeeds = oppTotalSeeds + state:getBoard():getSeeds(ourSide, hole)
    end

    return ((seedsInOurStore-seedsInOppStore) + (ourTotalSeeds - oppTotalSeeds))
end



return MCTS