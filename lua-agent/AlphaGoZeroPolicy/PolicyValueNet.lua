--
-- Created by IntelliJ IDEA.
-- User: aayushchadha
-- Date: 07/12/18
-- Time: 11:11
-- To change this template use File | Settings | File Templates.
--

torch = require 'torch'
nn = require 'nn'
optim = require 'optim'


local AGZ = {}
AGZ.__index = AGZ

function AGZ:new(boardHeight, boardWidth)
    local self = setmetatable({}, AGZ)
    self.height = boardHeight
    self.width = boardWidth
    self.model = nn.Sequential()
    self.stateValueLayers = nn.Sequential()
    self.actionPolicyLayers = nn.Sequential()
    self.splitPoint = nn.Concat()
    -- Our model has 6 input planes
    -- The first 4 planes are board states, at 4 time points
    -- Plane 5 indicates which side is to move
    -- Plane 6 indicates who has more seeds in their store
    self.conv1 = nn.SpatialConvolution(6, 32, 3, 3, 1, 1)
    self.conv2 = nn.SpatialConvolution(32,64,3,3,1,1)
    self.conv3 = nn.SpatialConvolution(64,128,3,3,1,1)

    -- Action Policy Layers
    self.actPConv = nn.SpatialConvolution(128, 6, 1, 1)
    self.act_fc1 = nn.Linear(6*boardWidth*boardHeight, boardWidth*boardHeight)

    -- State Value Layers
    self.val_conv1 = nn.SpatialConvolution(128, 3, 1,1)
    self.val_fc1 = nn.Linear(3*boardHeight*boardWidth, 64)
    self.val_fc2 = nn.Linear(64, 1)

    return self
end

function AGZ:buildModel(state)
    -- We wire the model up now
    self.model:add(self.conv1)
    self.model:add(nn.ReLU())
    self.model:add(self.conv2)
    self.model:add(nn.ReLU())
    -- DONE, so far, it was feed forward, now we need to store the result of
    -- the next operation and pass it to the action policy layers and the state value layers
    self.model:add(self.conv3)
    self.model:add(nn.ReLU())

    -- Build the action policy layer branch
    self.actionPolicyLayers:add(self.actPConv)
    self.actionPolicyLayers:add(nn.ReLU())
    self.actionPolicyLayers:add(nn.View(-1, 6*self.width*self.height))
    self.actionPolicyLayers:add(self.act_fc1)
    self.actionPolicyLayers:add(nn.LogSoftMax())

    -- Build the state value layers
    self.stateValueLayers:add(self.val_conv1)
    self.stateValueLayers:add(nn.ReLU())
    self.stateValueLayers:add(nn.View(-1, 3*self.width*self.height))
    self.stateValueLayers:add(self.val_fc1)
    self.stateValueLayers:add(nn.ReLU())
    self.stateValueLayers:add(self.val_fc2)
    self.stateValueLayers:add(nn.Tanh())


    self.model:add(self.splitPoint())
    -- Concat and add two separate branches whose output is later combined
    self.splitPoint:add(self.actionPolicyLayers)
    self.splitPoint:add(self.stateValueLayers)

    print (self.model)

    -- With the model built, finally pipe through the input tensor
    local output = self.model:forward(state)

    return output
end

local kalahPolicyNet = AGZ:new(2,7)

kalahPolicyNet:buildModel(torch.Tensor(6,2,7))

