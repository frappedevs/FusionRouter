local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Fusion = require(ReplicatedStorage.Packages.Fusion)
local Types = require(script.Parent.Types)

local Router = {} :: Types.Router
Router.__index = Router

function Router.new(routes)

end

return Router.new