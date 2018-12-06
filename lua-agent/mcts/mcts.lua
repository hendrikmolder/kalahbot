--
--  REFERENCES
--  1. https://www.baeldung.com/java-monte-carlo-tree-search
--

local t = require 'pl.tablex'

local log = require '..utils.log'
local protocol = require '..protocol'
local State = require '..state'
local Tree = require 'tree'
local Node = require 'node'
local UCT = require 'uct'

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



return MCTS