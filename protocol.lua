function getMessageType(message)
    local startMsg = "START;"
    local changeMsg = "CHANGE;"
    local endMsg = "END\n"

    if message == nil then return end

    -- START MESSAGE
    if(message:sub(1, #startMsg) == startMsg) then return "start" end

    -- CHANGE MESSAGE
    if (message:sub(1, #changeMsg) == changeMsg) then return "change" end

    -- END MESSAGE
    if (message:sub(1, #endMsg) == endMsg) then return "end" end

    -- Message was not recognized
    print("Message was not recognised.")
    return nil
end
