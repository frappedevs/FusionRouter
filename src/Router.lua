local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Fusion = require(ReplicatedStorage.Packages.Fusion)
local Tree = require(script.Parent.Tree)
local StateDict = require(script.Parent.StateDict)
local Parse = require(script.Parent.Parse)
local Types = require(script.Parent.Types)

local Router = {} :: Types.Router
Router.__index = Router

function Router:addRoute(route: Types.Route<string>)
	assert(self:checkRoute(route.Path), "Router expects a path that matches ([^/.]+)(.*), got malformed path")
	local function resolve(path: string, node: Types.TreeChild<Types.Route<string> | { ParameterName: string? }>)
		local current, rest = Parse(path)
		local isWildcard = current:match("^:")
		if isWildcard then
			current = "%WILDCARD%"
		end
		local currentNode = node[Fusion.Children][current]

		if currentNode and rest and rest ~= "/" then -- if current route exists and theres more
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

function Router:setRoute(route: Types.Route<string>, parameters: { [any]: any })
	local duplicatedRoute = table.clone(route)
	duplicatedRoute.Parameters = parameters
	self.History[#self.History + 1] = duplicatedRoute
	for _, name in ipairs({ "Path", "Page", "Data" }) do
		self.CurrentPage[name]:set(duplicatedRoute[name])
		if self.CurrentPage[name].clearAll then
			self.CurrentPage[name]:clearAll()
		end
	end
	self.CurrentPage.Parameters = duplicatedRoute.Parameters or {}
	self.CurrentPage.Parameters.Router = self
	table.insert(self.History, duplicatedRoute)
end

function Router:canGoBack(steps: number?): boolean
	return #self.History > (steps or 1)
end

function Router:back(steps: number?)
	assert(
		self:canGoBack(steps),
		"Router expects steps to be less than or equal to the number of steps in history, got " .. steps
	)
	local route = self.History[#self.History - (steps or 1)]
	self:setRoute(route, route.Parameters)
end

function Router:push(path: string, parameters: { [any]: any }?)
	assert(self:checkRoute(path), "Router expects a path that matches ([^/.]+)(.*), got malformed path")
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

function Router:checkRoute(path: string): boolean
	local current, rest = Parse(path)
	if current and rest then
		return self:checkRoute(rest)
	elseif not current then
		return false
	end
	
	return true
end

function Router:getRouterView()
	local pageState = Fusion.State(self.CurrentPage.Page:get()(self.CurrentPage.Parameters))
	local disconnectPageStateCompat = Fusion.Compat(self.CurrentPage.Page):onChange(function()
		pageState:set(self.CurrentPage.Page:get()(self.CurrentPage.Parameters))
	end)

	return Fusion.New "Frame" {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 1, 0),
		ClipsDescendants = true,

		[Fusion.Children] = pageState,
		[Fusion.OnEvent "Destroying"] = function()
			disconnectPageStateCompat()
		end,
	}
end

return function(routes: Types.Routes)
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
	self.CurrentPage = {
		Path = Fusion.State(""),
		Page = Fusion.State(function(props)
			return Fusion.New("Frame")({})
		end),
		Data = StateDict {},
	}
	for _, route in pairs(routeIndices) do
		self:addRoute(route)
	end
	self:push("/")

	return self
end