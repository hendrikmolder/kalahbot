--[[
    References used for MCTS implementation:

    1. https://www.baeldung.com/java-monte-carlo-tree-search
    2. https://jeffbradberry.com/posts/2015/09/intro-to-monte-carlo-tree-search/

--]]

-- External imports:
require('pl.stringx').import()
local t = require 'pl.tablex'

-- Internal imports:
local log = require '..utils.log'
local protocol = require '..protocol'
local State = require '..kalah'
local Side = require '..side'
local Tree = require 'mcts.tree'
local Node = require 'mcts.node'
local UCT = require 'mcts.uct'

MCTS = {}
MCTS.__index = MCTS

-- TODO Remove other data structure based MCTS

-- Initialise the search algorithm
function MCTS:init(state, calculationTime, maxMoves)
    local o = {}
    setmetatable(o, self)
    self.__index    = self

    self.state = state      -- The state to start MCTS from
    self.states = {}        -- Table to hold game states and statistics on them
    self.plays = {}         -- Track plays from current state
    self.wins = {}
    self.calculationTime = tonumber(calculationTime) or 30
    self.maxMoves = tonumber(maxMoves) or 50
end

function MCTS:update(state)
    table.insert(self.states, state)
end

-- This returns the best move from a given state
function MCTS:getMove()
    local calculationStartTime = os.time()
    local legalMoves = self.state:getAllLegalMoves()
    local sideToPlay = self.state:getSideToMove()

    if (#legalMoves == 0) then
        return                      -- Return if no legal moves available
    elseif (#legalMoves == 1) then
        return legalMoves[1]        -- If only one move available, return that
    end                             -- Else continue with selecting the move

    local games = 0

    while os.time() - calculationStartTime < self.calculationTime do
        self:runSimulation()
        games = games + 1
    end

    --[[
        (p, self.board.next_state(state, p)) for p in legal
            create a list of state action pairs from all possible legal moves

        DONE Lua Equivalent would be a table with the key being the move and the
        Value being the resultant state
    --]]

    local possibleStates = {}  -- A table where k=[the move HOLE] and v=[the resulting state]
    local boardCopy = t.deepcopy(self.state:getBoard())
    local sideToMove = self.state:getSideToMove()
    local ourSide = self.state:getOurSide()
    for z=1,#legalMoves do

        local newState = Kalah:new(boardCopy, ourSide, sideToMove)

        -- Create the move message and play it
        local randomChangeMSg = protocol.createChangeMsg(legalMoves[z], newState:getBoard())
        local turn = protocol.evaluateStateMsg(randomChangeMSg, newState:getBoard())

        -- Update the side in the state
        if not turn.endMove then
            if turn.again then
                newState:setSideToMove(ourSide)
            else
                newState:setSideToMove(Side:getOpposite(ourSide))
            end
        end

        -- Add the updated state to the table
        possibleStates[legalMoves[z]:getHole()] = newState
    end

    --[[
         percent_wins, move = max(
            (self.wins.get((player, S), 0) /
             self.plays.get((player, S), 1),
             p)
            for p, S in moves_states
        )

        DONE calculate wins percentage and plays percentage by "getting" the value of "state" with "player" to
        play for all next move_states. This returns a tuple consisting of the play and the win percentage of
        that play. The Lua equivalent would be
        to compute the max using state references into the wins and plays table,
        this would get us the next state but we still need to know the move that gets us there and
        am not sure we have a way to do that yet
    --]]

    local maxWinPercentage = 0
    local bestHole

    for k,v in ipairs(possibleStates) do
        -- Retrieve the number of wins by using the state's string representation to index into
        -- the wins table
        local wins = self.wins[v:toString()] or 0
        -- Retrieve the number of plays by using the staten's string representation to index into
        -- the plays table
        local plays = self.plays[v:toString()] or 1

        local winRate = wins/plays

        if (maxWinPercentage < winRate) then
            maxWinPercentage = winRate
            bestHole = k
        end
    end

    log.info("MCTS Says: ", bestHole)

    return bestHole
end

-- This does a random playout from a given state to build the game tree
-- so that the getMove() function can use it to pick the best move using UCB
function MCTS:runSimulation()
    -- Copy the state to allow for simulations
    local stateCopy = t.deepcopy(self.state)
    local stateString = stateCopy:toString()
    log.info("SIMULATION STARTING AT", stateCopy:getBoard():toString())
    local ourSide = stateCopy:getOurSide()
    local sideToPlay = stateCopy:getSideToMove()
    local oppositeSide = Side:getOpposite(ourSide)

    local expand = true

    local visited_states = {}

    local winner

    local oldState

    for moves=1,self.maxMoves do
        local legalMoves = stateCopy:getAllLegalMoves()
        if #legalMoves == 0 then return end
        -- Select a random legal move to make
        local randomIndex = math.random(1, #legalMoves)
        local randomMove = legalMoves[randomIndex]

        if randomMove == nil then return end

        oldState = stateCopy:getBoard():toString()
        local randomChangeMSg = protocol.createChangeMsg(randomMove, stateCopy:getBoard())
        -- Play that random move AND update the board
        -- TODO update protocol to update all of state and not just board so we know whose turn is it
        local boardToMoveOn = t.deepcopy(stateCopy:getBoard())
--        log.debug("BEFORE UPDATE", boardToMoveOn:toString())
--        log.debug("SIDE TO MOVE:", stateCopy:getSideToMove())
        log.info("MAKING MOVE ON BOARD COPY")
        local sideToMove = stateCopy:makeMove(boardToMoveOn, randomMove)
        log.info("ORIGINAL BOARD AFTER MOVE MADE", stateCopy:getBoard():toString())
        stateCopy:setSideToMove(sideToMove)
--        log.debug("AFTER UPDATE", boardToMoveOn:toString())
--        local turn = protocol.evaluateStateMsg(randomChangeMSg, self.state:getBoard())
--        local currentState = self.state:getBoard():toString()
--
----        if (currentState == oldState) then
----            log.error("STATE NOT UPDATED")
----        end
--
--        if not turn.endMove then
--            if turn.again then
--                stateCopy:setSideToMove(ourSide)
--            else
--                stateCopy:setSideToMove(oppositeSide)
--            end
--        end

        self.states[stateCopy:toString()] = true

        -- Transposition table of sorts
        if expand and self.plays[stateCopy:toString()] == nil then
            expand = false
            self.plays[stateCopy:toString()] = 0
            self.wins[stateCopy:toString()] = 0
        end

        -- Add to set of visited states (It's a set, trust me)
        visited_states[stateCopy:toString()] = true

        -- Get a winner only if the holes have emptied
        if (stateCopy:holesEmpty(stateCopy:getBoard(), Side.NORTH)
                or stateCopy:holesEmpty(stateCopy:getBoard(), Side.SOUTH)) then
            winner = stateCopy:getWinner()
        end

        -- If a winner is found, end simulation to start back prop (?)
        if winner ~= nil then
            break
        end
    end

    log.info('visited states =', #visited_states)

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