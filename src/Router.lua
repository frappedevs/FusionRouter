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
	assert(routeIndices["/"], 'Router expects base route "/" to be supplied, got nil')

	local self = setmetatable({}, Router)
	self.Routes = Tree(routeIndices["/"])
    self.History = {}
	routeIndices["/"] = nil
	self.CurrentPage = {}
	for _, route in pairs(routeIndices) do
		self:addRoute(route)
	end

	return self
end

function Router:addRoute(route: Types.Route<string>)
	local function resolve(path: string, node: Types.TreeChild<Types.Route<string> | { ParameterName: string? }>)
		local current, rest = Parse(path)
		local isWildcard = current:match("^:")
		if isWildcard then
			current = "%WILDCARD%"
		end
		local currentNode = node[Fusion.Children][current]

		if currentNode and rest then -- if current route exists and theres more
			resolve(rest, currentNode) -- resolve
		elseif currentNode and #currentNode.Value == 0 and not rest then -- if theres no more to resolve but there is a current route with no data
			currentNode.Value = route -- set the current route to the new route
		elseif not currentNode then -- if theres no current route and theres more
			currentNode:newChild({ -- create new route with empty data or route if no more
				[current] = if not rest
					then route
					else {
						ParameterName = if isWildcard then current:sub(2) else nil,
					},
			})
		end
	end

	resolve(route.Path, self.Routes)
end

function Router:setRoute(route: Types.Route<string>, parameters: { [any]: any }) end

function Router:push(path: string, parameters: { [any]: any }?)
	local function resolve(path: string, node: Types.TreeChild<Types.Route<string> | { ParameterName: string? }>)
		local current, rest = Parse(path)
		local currentNode = node[Fusion.Children][current] or node[Fusion.Children]["%WILDCARD%"]
		local isWildcard = currentNode == node[Fusion.Children][current]

		if currentNode then
			if isWildcard then
				parameters[currentNode.Value.ParameterName] = current
			end
			if rest then
				resolve(rest, currentNode) -- resolve
			elseif not rest and #currentNode.Value ~= 0 then
				self:setRoute(currentNode.Value, parameters)
			end
		end
	end

	resolve(path, self.Routes)
end

return Router.new
