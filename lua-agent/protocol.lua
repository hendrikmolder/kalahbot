local protocol = {}

-- Returns message type (start, change, or end)
function protocol.getMessageType(message)
    local startMsg = "START;"
    local changeMsg = "CHANGE;"
    local endMsg = "END\n"

    -- Dont even ask
    local endString = "end"

    if message == nil then return nil end

    -- START MESSAGE
    if message:sub(1, #startMsg) == startMsg then return "start" end

    -- CHANGE MESSAGE
    if message:sub(1, #changeMsg) == changeMsg then return "state" end

    -- -- END MESSAGE
    if message:sub(1, #endMsg) == endMsg then return endString end

    -- Message was not recognized
    print("Message was not recognised.")
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
    if message:sub(#message, #message) ~= "\n" then return nil end

    -- Indexing starts at 1, hence we use 7 not 6
    local position = message:sub(7, #message - 1)
    if position == "South" then
        return true
    elseif position == "North" then
        return false
    else
        print("Illegal position paramter: " .. position)
        return nil
    end
end

return protocol