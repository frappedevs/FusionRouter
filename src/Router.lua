local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Fusion = require(ReplicatedStorage.Packages.Fusion)
local Tree = require(script.Parent.Tree)
local StateDict = require(script.Parent.StateDict)
local Parse = require(script.Parent.Parse)
local Types = require(script.Parent.Types)

local Router = {} :: Types.Router
Router.__index = Router

function Router.new(routes: Types.Routes)
    local routeIndices = {}
    for path, route in pairs(routes) do
        if type(path) == "string" then
            route.Path = path
        end
        assert(type(route.Path) == "string", "Router expects route path to be a string, got " .. type(route.Path))
        route.Path = route.Path:lower()
        routeIndices[route.Path] = route
    end
    assert(routeIndices["/"], "Router expects base route \"/\" to be supplied, got nil")

    local self = setmetatable({}, Router)
    self.Routes = Tree(routeIndices["/"])
    routeIndices["/"] = nil
    self.CurrentPage = {}
    for _, route in pairs(routeIndices) do
        self:addRoute(route)
    end

    return self
end

end

return Router.new