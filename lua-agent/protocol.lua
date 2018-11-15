function getMessageType(message)
    local startMsg = "START;"
    local changeMsg = "CHANGE;"
    local endMsg = "END\n"

    -- Dont even ask
    local endString = "end"

    if message == nil then return nil end

    -- START MESSAGE
    if message:sub(1, #startMsg) == startMsg then return "start" end

    -- CHANGE MESSAGE
    if message:sub(1, #changeMsg) == changeMsg then return "change" end

    -- -- END MESSAGE
    if message:sub(1, #endMsg) == endMsg then return endString end

    -- Message was not recognized
    print("Message was not recognised.")
    return nil
end

function getMessageBody(message, msgType)
    local stripType = message:sub()
end
