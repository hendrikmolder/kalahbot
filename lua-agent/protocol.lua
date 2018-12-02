require('pl.stringx').import()
MoveTurn = require 'moveTurn'
Board = require 'board'
log = require 'utils.log'

local protocol = {}

-- Returns message type (start, change, or end)
function protocol.getMessageType(message)
    local startMsg = "START;"
    local changeMsg = "CHANGE;"
    local endMsg = "END\n"

    -- Dont even ask
    local endString = "end"

    if message == nil then return nil end
    if message:sub(1, #startMsg) == startMsg then return "start" end
    if message:sub(1, #changeMsg) == changeMsg then return "state" end
    if message:sub(1, #endMsg) == endMsg then return endString end

    -- Message was not recognized
    log.error('Message type was not recognized:', message)
    return nil
end

-- Returns move message
function protocol.createMoveMsg(hole)
    return "MOVE;" .. hole .. "\n"
end

-- Returns swap message
function protocol.createSwapMsg()
    return "SWAP\n"
end

-- Evaluates start message and decides who's turn it is
-- Should be called when getMessageType returns START
function protocol.evaluateStartMsg(message)
    -- Check if the message has a valid ending character
    if message:sub(#message, #message) ~= "\n" then
        log.error('Expected last character to be \"/n\", received:', message:sub(#message, #message))
        return nil
    end

    -- Indexing starts at 1, hence we use 7 not 6
    local position = message:sub(7, #message - 1)
    if position == "South" then
        return true
    elseif position == "North" then
        return false
    else
        log.error('Illegal position parameter:', position)
        return nil
    end
end

function protocol.evaluateStateMsg(message, board)
    -- Check if message has a valid ending character
    if message:sub(#message, #message) ~= "\n" then return nil end

    local moveTurn = MoveTurn:new(nil)
    local msgParts = message:split(";", 4)

    -- If message does not have 4 parts, it is missing arguments
    if #msgParts ~= 4 then return nil end

    -- msgParts[1] is "CHANGE"
    -- msgParts[2] is the move (SWAP)
    -- msgParts[3] is the board
    -- msgParts[4] says who's turn it is
    if msgParts[2] == "SWAP" then
        moveTurn.move = -1
    else
        moveTurn.move = msgParts[2]
    end

    -- msgparts[3] -- the board
    local boardParts = msgParts[3]:split(",")

    if 2 * board:getNoOfHoles() + 1 ~= #boardParts then
        print("Board holes error: expected " .. 2 *board:getNoOfHoles() + 1 .. " but received " .. #boardParts)
        return nil
    end

    for hole=1,board:getNoOfHoles() do
        -- North holes
        board:setSeeds("NORTH", hole+1, boardParts[hole])
        -- South holes
        board:setSeeds("SOUTH", hole+1, boardParts[hole + board:getNoOfHoles() + 1])
    end

    -- North store
    board:setSeedsInStore("NORTH", boardParts[board:getNoOfHoles()])
    -- South store
    board:setSeedsInStore("SOUTH", boardParts[2 * board:getNoOfHoles() + 1])

    -- msgParts[4] -- who's turn
    moveTurn.endMove = false
    if msgParts[4] == "YOU\n" then
        moveTurn.again = true
    elseif msgParts[4] == "OPP\n" then
        moveTurn.again = false
    elseif msgParts[4] == "END\n" then
        moveTurn.endMove = true
        moveTurn.again = false
    else
        print("Illegal value for turn parameter " .. msgParts[4])
        return nil
    end

    return moveTurn
end

return protocol