--
-- Created by IntelliJ IDEA.
-- User: aayushchadha
-- Date: 28/11/18
-- Time: 00:51
-- To change this template use File | Settings | File Templates.
--

-- Lua doesn't support enums out of the box, a decent halfway house is using the mapping below
-- Taken from - https://rosettacode.org/wiki/Enumerations#Lua
Side = {NORTH = 1, SOUTH = 2}

Side.__index = Side

function Side:getOpposite(side)
    if side == self.NORTH then
        return self.SOUTH
    end

    return self.NORTH
end


return Side



