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

function protocol.getMessageBody(message, msgType)
    local stripType = message:sub()
end

-- Returns move message
function protocol.createMoveMsg(hole)
    return "MOVE;" .. hole .. "\n"
end

return protocol