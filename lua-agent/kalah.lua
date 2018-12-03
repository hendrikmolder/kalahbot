Board = require 'board'
Side = require 'side'

-- TODO: @aayush look through the ingored linting errors (CTRL-F "luachedk:")

-- This class also maintains game state
local Kalah = {}
Kalah.__index = Kalah

-- New State contains a reference to the board, the side that belongs to us
-- and the side that has to move

-- State Implementation based on - https://github.com/aleju/mario-ai/blob/master/state.lua
-- luacheck: ignore self
function Kalah:new(board, ourSide, sideToMove)
    local self = setmetatable({}, Kalah)
    self.board = board or Board:new(7,7)
    self.ourSide = ourSide or Side.SOUTH
    self.sideToMove = sideToMove or Side.SOUTH
    return self
end

-- Return the board in its current state
function Kalah:getBoard()
    return self.board
end

-- Set side
function Kalah:setOurSide(side)
    self.ourSide = side
end


function Kalah:setSideToMove(side)
    self.sideToMove = side
end

function Kalah:getOurSide()
    return self.ourSide
end

function Kalah:getSideToMove()
    return self.sideToMove
end

function Kalah:setBoard(board)
    self.board = board
end

-- Checks whether a given move is legal on a given board.
-- NB! No moves are actually made.

-- Removed board reference since we'll be checking all moves against
-- the Kalah instance we create
function Kalah:isLegalMove(move)
    return (move:getHole() <= self.board:getNoOfHoles())
        and (self.board:getSeeds(move.getSide(), move.getHole()) ~= 0)
end

function Kalah:performMove(move)
    log.debug("Move is: ", move)
    return self.makeMove(self.board, move)
end

-- Checks whether all holes are empty
function Kalah:holesEmpty(board, side)
    -- luacheck: ignore
    for hole=1,board:getNoOfHoles() do
        if (board:getSeeds(side, hole) ~= 0) then return false end
        return true
    end
end

-- Checks whether the game is over (based on the board)
function Kalah:gameOver(board)
    return holesEmpty(board, "NORTH") or holesEmpty(board, "SOUTH")
end

function Kalah:makeMove(board, move)
    local seedsToSow = board:getSeeds(move:getSide(), move:getHole())
    board:setSeeds(move:getSide(), move:getHole(), 0)

    local holes = board:getNoOfHoles()
    local receivingPits = 2*holes + 1
    local rounds = seedsToSow / receivingPits
    local extra = seedsToSow % receivingPits

    if (rounds ~= 0) then
        for hole=1,board:getNoOfHoles() do
            board:addSeeds("NORTH", hole, rounds)
            board:addSeeds("SOUTH", hole, rounds)
        end

        board:addSeedsToStore(move:getSide(), rounds);
    end

    local sowSide = move:getSide()
    local sowHole = move:getHole()
    for i=extra,1,-1 do
        sowHole = sowHole + 1
        -- luacheck: ignore extra
        extra=i
        if sowHole == 1 then
            -- TODO implment side.lua
            sowSide = sowSide:opposite()
        end

        if sowHole > holes then
            if (sowSide == move:getSide()) then
                sowHole = 0
                board:addSeedsToStore(sowSide, 1);
            else
                sowSide = sowSide:opposite()
                sowHole = 1
            end
        end

        board:addSeeds(sowSide, sowHole, 1)
    end

    -- Capture

    if ((sowSide == move.getSide())
            and (sowHole > 0)
            and (board:getSeeds(sowSide, sowHole) == 1)
            and (board:getSeedsOp(sowSide, sowHole) > 0)) then

        board:addSeedsToStore(move:getSide(), 1+board:getSeedsOp(move:getSide(), sowHole))
        board:setSeeds(move:getSide(), sowHole, 0)
        board:setSeedsOp(move:getSide(), sowHole, 0)
    end

    local finishedSide

    if (holesEmpty(board, move:getSide())) then
        finishedSide = move:getSide()
    elseif (holesEmpty(board, move:getSide():opposite())) then
        finishedSide = move:getSide().opposite()
    end

    if (finishedSide) then
        local seeds = 0
        local collectingSide = finishedSide:opposite()
        for hole=1, board:getNoOfHoles() do
            seeds = seeds + board:getSeeds(collectingSide, hole)
            board:setSeeds(collectingSide, hole, 0)
        end

        board:addSeedsToStore(collectingSide, seeds)
    end

    -- TODO board:notifyObservers()

    if (sowHole == 0) then
        return move:getSide()
    else
        return move:getSide():opposite()
    end
end

return Kalah