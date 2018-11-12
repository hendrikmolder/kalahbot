
-- Parse message
-- Input:   Direct input from the server/game engine
-- Output:  Message object (?)

-- NB! Not finished and not working
function parseMessage(msg)
    local message = Message:new()
    local messageType = getMessageType(msg)

    message.type = messageType

    return message.type
end

function getMessageType(message)
    local startMsg = "START;"
    local changeMsg = "CHANGE;"
    local endMsg = "END\n"

    if message == nil then return end

    -- START MESSAGE
    if(message:sub(1, #startMsg) == startMsg) then return "START MESSAGE" end

    -- CHANGE MESSAGE
    if (message:sub(1, #changeMsg) == changeMsg) then return "CHANGE MESSAGE" end

    -- END MESSAGE
    if (message:sub(1, #endMsg) == endMsg) then return "END MESSAGE" end

    -- Message was not recognized
    print("Message was not recognised.")
    return nil
end

-- The below content is for testing purposes only. WILL BE REMOVED!
while true do
    local line = "START;" --io.read()

    -- If there's no new line, exit
    if line == nil then break end

    -- Else play the game
    io.write(string.format("%6d  ", 0), parseMessage(line), "\n")
end