Board = require 'board'
Side = require 'side'
Move = require 'move'
local pl = require 'pl.pretty'

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
    self.board = board or Board:new(nil, 7,7)
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
    return self:makeMove(self:getBoard(), move)
end

function Kalah:getAllLegalMoves(board)
    local legalMoves    = {}
    local useBoard      = board or self.board
    local noOfHoles     = useBoard:getNoOfHoles()
    local side       = useBoard.sideToMove

    for i=1,noOfHoles do
        if (useBoard:getSeeds(side, i) ~= 0) then
            move = Move:new(nil, side, i)
            table.insert(legalMoves, move)
        end
    end

    return legalMoves
end

-- Checks whether all holes are empty
function Kalah:holesEmpty(board, side)
    -- luacheck: ignore
    for hole=1,board:getNoOfHoles() do
        -- Check if any hole has a seed remaining
        if (board:getSeeds(side, hole) ~= 0) then return false end
    end

    return true
end

-- Checks whether the game is over (based on the board)
function Kalah:gameOver(board)
    return holesEmpty(board, "NORTH") or holesEmpty(board, "SOUTH")
end

function Kalah:makeMove(board, move)
    local seedsToSow = board:getSeeds(move:getSide(), move:getHole())
    -- Empty the selected cell
    board:setSeeds(move:getSide(), move:getHole(), 0)

    -- Fetch board holes
    local holes = board:getNoOfHoles()
    local receivingPits = 2*holes + 1
    -- Lua's lack of types gives back decimals if not using floor
    local rounds = math.floor(seedsToSow / receivingPits)
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
        log.info("Board before seed update\n", board:toString())
        sowHole = sowHole + 1
        -- luacheck: ignore extra
        extra=i
        if sowHole == 8 then
            -- DONE implment side.lua
            sowSide = Side:getOpposite(sowSide)
        end
        -- We now add seeds to the store
        if sowHole > holes then
            if (sowSide == move:getSide()) then
                -- Lua counts from 1
                sowHole = 8
                board:addSeedsToStore(sowSide, 1);
            else
                sowSide = Side:getOpposite(sowSide)
                sowHole = 1
            end
        end

        board:addSeeds(sowSide, sowHole, 1)
    end

    -- Capture

    if ((sowSide == move:getSide())
            and (sowHole > 0)
            and (board:getSeeds(sowSide, sowHole) == 1)
            and (board:getSeedsOp(sowSide, sowHole) > 0)) then

        board:addSeedsToStore(move:getSide(), 1+board:getSeedsOp(move:getSide(), sowHole))
        board:setSeeds(move:getSide(), sowHole, 0)
        board:setSeedsOp(move:getSide(), sowHole, 0)
        log.info("board is now\n", board:toString())
    end

    local finishedSide

    -- This should check for end of the game, but for some reason finishedSide gets set to 2
    if (self:holesEmpty(board, move:getSide())) then
        finishedSide = move:getSide()
    elseif (self:holesEmpty(board, Side:getOpposite(move:getSide()))) then
        finishedSide = Side:getOpposite(move:getSide())
    end

    if (finishedSide) then
        local seeds = 0
        local collectingSide = Side:getOpposite(finishedSide)
        for hole=1, board:getNoOfHoles() do
            seeds = seeds + board:getSeeds(collectingSide, hole)
            board:setSeeds(collectingSide, hole, 8)
        end

        board:addSeedsToStore(collectingSide, seeds)
    end

    -- TODO board:notifyObservers()

    if (sowHole == 0) then
        return move:getSide()
    else
        log.info('Returning side:', move:getSide())
        return Side:getOpposite(move:getSide())
    end
end

return Kalah