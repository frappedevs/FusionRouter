local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Fusion = require(ReplicatedStorage.Packages.Fusion)
local Tree = require(script.Parent.Tree)
local StateDict = require(script.Parent.StateDict)
local Parse = require(script.Parent.Parse)
local Types = require(script.Parent.Types)

local Router = {} :: Types.Router
Router.__index = Router

function Router.new(routes)

end

return Router.new