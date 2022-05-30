local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Fusion = require(ReplicatedStorage.Packages.Fusion)
local Tree = require(script.Tree)
local StateDict = require(script.StateDict)
local Types = require(script.Types)
local ErrorView = require(script.ErrorView)

local Router = {} :: Types.Router
Router.__index = Router

local WILDCARD_PATH = "%WC%"
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
		local stringSteps = tostring(steps or 1)
		return {
			Title = "Runtime error",
			Message = (
				"Router:back(%s) - Router expects steps to be less than or equal to the number of steps in history, got %s"
			):format(stringSteps, stringSteps),
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

	PAGE_BUILD_ERROR = function(path: string, functionType: "A" | "B" | "page builder" | "lifecycle", reason: string)
		functionType = if functionType == "A" or functionType == "page builder" then "page builder" else "lifecycle"
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

function Router:addRoutes(routes: Types.Routes, _prevPath: string?)
	type routeTreeNode = Tree.Tree<Types.Route<string> | { ParameterName: string? }>
	local function resolve(path: string, node: routeTreeNode)
		local current, rest = parse(path)
		local nodeName = if current:byte(1) == (":"):byte(1) then WILDCARD_PATH else current
		local currentNode = node[Fusion.Children][nodeName]

		if currentNode then
			if #currentNode.Value == 0 and not rest then
				currentNode.Value = route
			end
		else
			node:newChild({
				[nodeName] = if nodeName ~= WILDCARD_PATH
					then route
					else {
						ParameterName = if nodeName == WILDCARD_PATH then current:sub(2, -1) else nil, 
					},
			})
		end
		if rest then
			resolve(rest, currentNode)
		end
	end

	for path, route in routes do
		route.Data = route.Data or {}
		route.Path = if type(path) == "string" then path else route.Path
		if prevPath then
			route.Path = _prevPath .. route.Path
		end
		route.Path ..= if route.Path:sub(-1, -1) ~= "/" then "/" else ""
		if not self:checkRoute(route.Path) then
			self:_postError(ERROR_MESSAGES.BAD_PATH(route.Path))
			return
		end
		for name, expectedType in { Path = "string", Page = "function" } do
			if type(route[name]) ~= expectedType then
				self:_postError(ERROR_MESSAGES.BAD_ROUTE(route.Path or tostring(route), name, typeof(route[name])))
				return
			end
		end

		resolve(route.Path, self.Routes)
		if route[Fusion.Children] then
			self:addRoutes(route[Fusion.Children], route.Path)
		end
	end
end

function Router:setRoute(route: Types.Route<string>, parameters: { [any]: any}, shouldInsert: boolean?)
	self._error.IsActive:set(false)
	local duplicatedRoute = table.clone(route)
	duplicatedRoute.Parameters = parameters
	self.History[#self.History + 1] = duplicatedRoute
	for _, name in ipairs({ "Path", "Page", "Data" }) do
		self.CurrentPage[name]:set(duplicatedRoute[name])
	end
	self.CurrentPage.Parameters = duplicatedRoute.Parameters or {}
	self.CurrentPage.Parameters.Router = self
	if not self.CurrentPage.Path:get() == route.Path or not shouldInsert then
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
	self:setRoute(route, route.Parameters or {}, false)
end

function Router:push(path: string, parameters: { [any]: any }?)
	if not self:checkRoute(path) then
		self:_postError(ERROR_MESSAGES.BAD_PATH(path))
		return
	end
	parameters = parameters or {}
	local function resolve(path: string, node: Tree.Tree<Types.Route<string> | { ParameterName: string? }>)
		local current, rest = parse(path)
		local children = node[Fusion.Children]
		local currentNode = children[current] or children[WILDCARD_PATH]
		local isWildcard = currentNode == children[WILDCARD_PATH]
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
		return true
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
	for path, route in routes do
		if path == "/" or route.Path == "/" then
			self.Routes = Tree(route)
			break
		end
	end
	self:addRoutes(routes)
	self:push("/")

	return self
end
