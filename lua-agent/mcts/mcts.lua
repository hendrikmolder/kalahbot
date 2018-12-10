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
function MCTS:init(calculationTime, maxMoves)
    local self = setmetatable({}, MCTS)
    self.states = {}        -- Table to hold game states and statistics on them
    self.plays = {}         -- Track plays from current state
    self.wins = {}
    self.calculationTime = tonumber(calculationTime) or 30
    self.maxMoves = tonumber(maxMoves) or 50
    math.randomseed(os.time())
    math.random()
    math.random()
    math.random()

    return self
end

function MCTS:update(state)
    table.insert(self.states, state)
end

-- This returns the best move from a given state
function MCTS:getMove(state)
    local calculationStartTime = os.time()
    local legalMoves = state:getAllLegalMoves()
    local sideToPlay = state:getSideToMove()

    if (#legalMoves == 0) then
        return                      -- Return if no legal moves available
    elseif (#legalMoves == 1) then
        return legalMoves[1]        -- If only one move available, return that
    end                             -- Else continue with selecting the move

    local games = 0

    while os.time() - calculationStartTime < self.calculationTime do
        self:runSimulation(state)
        games = games + 1
    end

    -- create a list of move-state pairs from all possible legal moves
    -- A table where k=[the move HOLE] and v=[the resulting state]
    local possibleStates = {}
    local boardCopy = t.deepcopy(state:getBoard())
    local sideToMove = state:getSideToMove()
    local ourSide = state:getOurSide()
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

    for k,v in pairs(possibleStates) do
        -- Retrieve the number of wins by using the state's string representation to index into
        -- the wins table
        local wins = self.wins[v:toString()] or 0
        log.info("STATE WINS", wins)
        -- Retrieve the number of plays by using the staten's string representation to index into
        -- the plays table
        local plays = self.plays[v:toString()] or 1
        log.info("STATE PLAYS", plays)

        local winRate = wins/plays

        if (maxWinPercentage < winRate) then
            maxWinPercentage = winRate
            bestHole = k
            log.info("BEST HOLE SET TO", k)
        end

    end

    if bestHole == nil then
        local bestMove = math.random(1, #legalMoves)
        bestHole = legalMoves[bestMove]:getHole()
    end

    log.info("MCTS Says: ", bestHole)

    return bestHole
end

-- This does a random playout from a given state to build the game tree
-- so that the getMove() function can use it to pick the best move using UCB
function MCTS:runSimulation(state)
    -- Copy the state to allow for simulations
    local stateCopy = t.deepcopy(state)
    -- log.info("SIMULATION STARTING AT", stateCopy:getBoard():toString())

    local expand = true

    local visited_states = {}

    local winner

    for moves=1,self.maxMoves do
        local legalMoves = stateCopy:getAllLegalMoves()
        if #legalMoves == 0 then break end
        -- Select a random legal move to make
        local randomIndex = math.random(1, #legalMoves)
        local randomMove = legalMoves[randomIndex]
        if randomMove == nil then return end
        -- Play that random move AND update the board
        local boardToMoveOn = t.deepcopy(stateCopy:getBoard())
        local sideToMove = stateCopy:makeMove(boardToMoveOn, randomMove)
        stateCopy:setSideToMove(sideToMove)

        self.states[stateCopy:toString()] = true

        -- DONE SOMETHING IS OFF HERE, IT'S NOT POPULATED AS INTENDED
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
            log.info("Deciding who won")
            winner = stateCopy:getWinner()
        end

        -- If a winner is found, end simulation to start back prop (?)
        if winner ~= nil then
            break
        end

    end

    -- Update visit statistics
    for k,_ in pairs(visited_states) do
        if self.plays[k] == nil then
        else
            self.plays[k] = self.plays[k] + 1
            local keyParts = k:split(";", 4)
            local sideToMove = tonumber(keyParts[2])
            if winner == sideToMove then
                self.wins[k] = self.wins[k] + 1
            end
        end
    end
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