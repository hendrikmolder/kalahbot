local log = require '..utils.log'
local State

MCTS = {}

log.info('MCTS started. Import working.')

function MCTS.getMove(state)
    return state:getAllLegalMoves()
end



return MCTS