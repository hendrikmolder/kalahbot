Board = require 'board'
Side = require 'side'
Move = require 'move'
local pl = require 'pl.pretty'
local log = require 'utils.log'

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

-- Given a board state, returns true if there is a winner else false
function Kalah:getWinner()
    local finishedSide

    if self:holesEmpty(self.board, Side.NORTH) then finishedSide = Side.NORTH else finishedSide = Side.SOUTH end

    local otherSide = Side:getOpposite(finishedSide)
    local otherSideSeeds = self.board:getSeedsInStore(otherSide)

    for hole=1,7 do
        otherSideSeeds = otherSideSeeds + self.board:getSeeds(otherSide, hole)
    end

    local finishedSideSeeds = self.board:getSeedsInStore(finishedSide)

    if finishedSideSeeds > otherSideSeeds then
        return finishedSide
    elseif otherSideSeeds > finishedSideSeeds then
        return otherSide
    end

    return nil

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
    local side          = self.sideToMove

    -- log.debug("Board to search for legal moves", useBoard:toString())
    for i=1,noOfHoles do
        if (useBoard:getSeeds(side, i) ~= 0) then
            local move = Move:new(nil, side, i)
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
    log.info("Board before move made", board:toString())
    log.info("MOVE", move:toString())
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
            board:addSeeds(Side.NORTH, hole, rounds)
            board:addSeeds(Side.SOUTH, hole, rounds)
        end

        board:addSeedsToStore(move:getSide(), rounds);
    end

    local sowSide = move:getSide()
    local sowHole = move:getHole() -- 8 is a store
    -- log.info("Board before seed update\n", board:toShortString())
    for i=extra,1,-1 do
        sowHole = sowHole + 1
        -- luacheck: ignore extra
        extra=i
        if sowHole == 9 then
            sowSide = Side:getOpposite(sowSide)
        end
        -- We now add seeds to the store
        if sowHole > holes then
            if (sowSide == move:getSide()) then
                -- Lua counts from 1
                sowHole = 8
                board:addSeedsToStore(sowSide, 1);

                -- TODO continue loop somhow witout adding seeds below
            else
                -- sowSide = Side:getOpposite(sowSide)
                sowHole = 1
            end
        end

        if (sowHole == 8 and sowSide == move:getSide()) then
        else
            board:addSeeds(sowSide, sowHole, 1)
        end
    end

    -- Capture

    if ((sowSide == move:getSide())
            and (sowHole > 0)
            and (board:getSeeds(sowSide, sowHole) == 1)
            and (board:getSeedsOp(sowSide, sowHole) > 0)) then

        board:addSeedsToStore(move:getSide(), 1+board:getSeedsOp(move:getSide(), sowHole))
        board:setSeeds(move:getSide(), sowHole, 0)
        board:setSeedsOp(move:getSide(), sowHole, 0)
    end

    local finishedSide

    -- DONE This should check for end of the game, but for some reason finishedSide gets set to 2
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
            board:setSeeds(collectingSide, hole, 0)
        end

        board:addSeedsToStore(collectingSide, seeds)
    end

    -- TODO board:notifyObservers()

    log.info("Board after move made", board:toString())

    if (sowHole == 8) then
        return move:getSide()
    else
        -- log.info('Returning side:', move:getSide())
        return Side:getOpposite(move:getSide())
    end
end

-- Use this to create a state hash
function Kalah:toString()
    return "Side To Move;"..self.sideToMove..";Our Side:"..self.ourSide..";Board:"..self.board:toString()
end

return Kalah