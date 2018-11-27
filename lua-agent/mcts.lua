-- Monte Carlo Tree Search implementation
-- TODO: Improve MCTS

mcts = {}

-- see https://medium.com/@quasimik/monte-carlo-tree-search-applied-to-letterpress-34f41c86e238

local random = math.random(0, math.pi, 1000)
local randoms = {}

for i=1,1000 do
    randoms[i] = math.random(0, math.pi, 1000)
end


-- Limits



return mcts