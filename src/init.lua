local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Fusion = require(ReplicatedStorage.Packages.Fusion)
local Tree = require(script.Tree)
local StateDict = require(script.StateDict)
local Types = require(script.Types)
local ErrorView = require(script.ErrorView)

local Router = {} :: Types.Router
Router.__index = Router

local ERROR_MESSAGES = {
	BAD_PATH = function(path: string)
		return {
			Title = "Runtime error",
			Message = (
				'Router:push("%s", { ... }) - Router expects a path that matches ([^/.]+)(.*), got malformed path'
			):format(path),
		}
	end,

	CANT_GO_BACK = function(steps: number)
		return {
			Title = "Runtime error",
			Message = (
				"Router:back(%s) - Router expects steps to be less than or equal to the number of steps in history, got %s"
			):format(steps or 1, steps or 1),
		}
	end,

	ROUTE_NOT_FOUND = function(path: string)
		return {
			Title = "Runtime error",
			Message = ('Router:push("%s", { ... }) - Router expects path "%s" to be a Route, got nil'):format(
				path,
				path
			),
		}
	end,

	PAGE_BUILD_ERROR = function(path: string, functionType: "A" | "B", reason: string)
		local functionType = if functionType == "A" then "page builder" else "lifecycle"
		return {
			Title = "Fatal error",
			Message = ('When attempting to build page "%s", %s function threw an error:\n\n%s'):format(
				path,
				functionType,
				reason
			),
			CanReturn = false,
		}
	end,

	BAD_ROUTE = function(path: string, memberName: string, typeName: string)
		return {
			Title = "Fatal error",
			Message = (
				'Router.new({ ... }) - Router expects route "%s" to have a table member named "%s", got %s'
			):format(path, memberName, typeName),
			CanReturn = false,
		}
	end,
}

local function parse(path: string): (string?, string?)
	if path:sub(-1, -1) ~= "/" then
		path ..= "/"
	end
	if path == "/" then
		return path, nil
	end
	local _, _, current, rest = path:find("([^/.]+)(.*)")
	return current, if rest ~= "/" then rest else nil
end

function Router:_postError(context: { Title: string, Message: string, CanReturn: boolean? })
	self._error.IsActive:set(true)
	self._error.Title:set(context.Title)
	self._error.Message:set(context.Message)
	self._error.CanReturn:set(context.CanReturn or true)
	warn(("\n[FusionRouter]: %s:\n\n%s"):format(context.Title, context.Message))
end

function Router:addRoute(route: Types.Route<string>)
	if not self:checkRoute(route.Path) then
		self:_postError(ERROR_MESSAGES.BAD_PATH(route.Path))
		return
	end
	local function resolve(path: string, node: Tree.Tree<Types.Route<string> | { ParameterName: string? }>)
		local current, rest = parse(path)
		local isWildcard = current:byte(1) == (":"):byte(1)
		local nodeName = if isWildcard then "%WILDCARD%" else current
		local currentNode = node[Fusion.Children][nodeName]
		if currentNode and #currentNode.Value == 0 and not rest then -- if theres no more to resolve but there is a current route with no data
			currentNode.Value = route -- set the current route to the new route
		elseif not currentNode then -- if theres no current route and theres more
			node:newChild({ -- create new route with empty data or route if no more
				[nodeName] = if not isWildcard
					then route
					else {
						ParameterName = if isWildcard then current:sub(2, -1) else nil,
					},
			})
			currentNode = node[Fusion.Children][nodeName]
		end
		if rest then
			resolve(rest, currentNode)
		end
	end

	resolve(route.Path, self.Routes)
end

function Router:setRoute(route: Types.Route<string>, parameters: { [any]: any })
	self._error.IsActive:set(false)
	local duplicatedRoute = table.clone(route)
	duplicatedRoute.Parameters = parameters
	self.History[#self.History + 1] = duplicatedRoute
	for _, name in ipairs({ "Path", "Page", "Data" }) do
		self.CurrentPage[name]:set(duplicatedRoute[name])
	end
	self.CurrentPage.Parameters = duplicatedRoute.Parameters or {}
	self.CurrentPage.Parameters.Router = self
	if not self.CurrentPage.Path:get() == route.Path then
		table.insert(self.History, duplicatedRoute)
	end
end

function Router:canGoBack(steps: number?): boolean
	return #self.History > (steps or 1)
end

function Router:back(steps: number?)
	if not self:canGoBack(steps) then
		self:_postError(ERROR_MESSAGES.CANT_GO_BACK(steps or 1))
		return
	end
	local route = self.History[#self.History - (steps or 1)]
	self:setRoute(route, route.Parameters or {})
end

function Router:push(path: string, parameters: { [any]: any }?)
	if not self:checkRoute(path) then
		self:_postError(ERROR_MESSAGES.BAD_PATH(path))
		return
	end
	parameters = parameters or {}
	local function resolve(path: string, node: Tree.Tree<Types.Route<string> | { ParameterName: string? }>)
		local current, rest = parse(path)
		local currentNode = node[Fusion.Children][current] or node[Fusion.Children]["%WILDCARD%"]
		local isWildcard = node[Fusion.Children]["%WILDCARD%"] == currentNode
		if currentNode then
			if isWildcard then
				parameters[currentNode.Value.ParameterName] = current
			end
			if rest then
				resolve(rest, currentNode)
			elseif not rest and next(currentNode.Value) ~= nil then
				self:setRoute(if not isWildcard then currentNode.Value else node.Value, parameters)
			end
		else
			self:_postError(ERROR_MESSAGES.ROUTE_NOT_FOUND(path))
		end
	end

	resolve(path, self.Routes)
end

function Router:checkRoute(path: string): boolean
	local current, rest = parse(path)
	if current and rest then
		return self:checkRoute(rest)
	elseif not current then
		return false
	end
	return true
end

function Router:getRouterView(lifecycleFunction: (string) -> ()?)
	local pageState = Fusion.State()
	local wrappedLifecycleFunction = function(lifecycle: string): boolean
		if lifecycleFunction then
			local success, result = pcall(lifecycleFunction, lifecycle)
			if not success then
				self:_postError(ERROR_MESSAGES.PAGE_BUILD_ERROR(self.CurrentPage.Page:get(), "B", result))
			end
			return success
		end
	end
	local function render()
		if not wrappedLifecycleFunction("pageSwitch") then
			return
		end
		local success, result = pcall(function()
			pageState:set(self.CurrentPage.Page:get()(self.CurrentPage.Parameters))
			return
		end)
		if not success then
			self:_postError(ERROR_MESSAGES.PAGE_BUILD_ERROR(self.CurrentPage.Page:get(), "A", result))
		end
		if not wrappedLifecycleFunction("pageSwitched") then
			return
		end
	end
	local disconnectPageStateCompat = Fusion.Observer(self.CurrentPage.Page):onChange(function()
		render()
	end)
	render()

	return Fusion.New "Frame" {
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 1),
		ClipsDescendants = true,

		[Fusion.Children] = {
			Fusion.New "Frame" {
				BackgroundTransparency = 1,
				Size = UDim2.fromScale(1, 1),
				ZIndex = 2,

				[Fusion.Children] = ErrorView {
					IsActive = self._error.IsActive,
					Title = self._error.Title,
					Message = self._error.Message,
					CanReturn = self._error.CanReturn,
					Router = self,
				},
			},

			Fusion.New "Frame" {
				BackgroundTransparency = 1,
				Size = UDim2.fromScale(1, 1),

				[Fusion.Children] = pageState,
			},
		},
		[Fusion.OnEvent "Destroying"] = function()
			disconnectPageStateCompat()
		end,
	}
end

return function(routes: Types.Routes): Types.Router
	local routeIndices = {}
	local self = setmetatable({
		_error = {
			IsActive = Fusion.State(false),
			Title = Fusion.State(""),
			Message = Fusion.State(""),
			CanReturn = Fusion.State(false),
		},
		History = {},
		CurrentPage = {
			Path = Fusion.State(""),
			Page = Fusion.State(function(props)
				return Fusion.New("Frame")({})
			end),
			Data = StateDict({}),
		},
	}, Router)

	local function resolve(routes, prevPath: string?)
		for path, route in pairs(routes) do
			if type(path) == "string" then
				route.Path = path
			end
			if prevPath then
				route.Path = prevPath .. route.Path
			end
			for name, expectedType in pairs({ Path = "string", Page = "function", Data = "table" }) do
				if type(route[name]) ~= expectedType then
					self:_postError(ERROR_MESSAGES.BAD_ROUTE(route.Path, name, typeof(route[name])))
				end
			end
			routeIndices[route.Path] = route
			if route.Children then
				resolve(route.Children, route.Path)
			end
		end
	end

	resolve(routes)
	self.Routes = Tree(routeIndices["/"])
	for _, route in pairs(routeIndices) do
		self:addRoute(route)
	end
	self:push("/")

	return self
end
