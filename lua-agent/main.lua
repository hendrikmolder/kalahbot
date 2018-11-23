--
-- Created by IntelliJ IDEA.
-- User: aayushchadha
-- Date: 23/11/18
-- Time: 12:07
-- To change this template use File | Settings | File Templates.
--

Protocol = require 'protocol'
Board = require 'board'

testBoard = Board:new(7,7)

function sendMsg (messageString)
    io.write(messageString)
end

function rcvMsg ()
    local messageString = io.read()
    return messageString
end

