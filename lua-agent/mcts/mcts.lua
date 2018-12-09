--
--  REFERENCES
--  1. https://www.baeldung.com/java-monte-carlo-tree-search
--

local t = require 'pl.tablex'

local log = require '..utils.log'
local protocol = require '..protocol'
local State = require '..kalah'
local Side = require '..side'
local Tree = require 'mcts.tree'
local Node = require 'mcts.node'
local UCT = require 'mcts.uct'

MCTS = {}

log.info('MCTS started. Import working.')

function MCTS.getMove(state)
    return state:getAllLegalMoves()
end

function MCTS.playRandomMove(state)
    local stateCopy = t.deepcopy(state)
    local legalMoves = stateCopy:getAllLegalMoves()
    local randomIndex = math.random(1, #legalMoves)
    local randomMove = legalMoves[randomIndex]
    local randomChangeMSg = protocol.createChangeMsg(randomMove, stateCopy:getBoard())

    -- Play that random move AND update the state
    local turn = protocol.evaluateStateMsg(randomChangeMSg, stateCopy:getBoard())

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
    local ourSide = state:getOurSide
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


-- Move ordering heuristic to guide exploration
function MCTS:orderMovesUsingHeuristic(allLegalMoves) end



return MCTS