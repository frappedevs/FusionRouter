--[=[
	@class Router
	UI routing class for Fusion
--]=]

local Fusion = require(script.Fusion)

local Router = { ROUTER_BASE_PATH = "/", URL_SEPARATOR = "/" }
Router.__index = Router

type Routes = {
	Path: string,
	View: ({ [any]: any }) -> any,
	Meta: { [any]: any },
	[any]: any,
}

function _populateStates(self, tabl)
	for key, data in pairs(tabl) do
		if typeof(data) == "table" then
			self[key] = self[key] or {}
			_populateStates(self[key], data)
		elseif key ~= "Data" then
			if self[key] and self[key].set then
				self[key]:set(data)
			else
				self[key] = Fusion.Value(data)
			end
		end
	end
end

function _checkRoute(routes: Routes)
	local seen = {}

	for _, data in ipairs(routes) do
		assert(data.Path and data.View, ("%s is required"):format(not data.Path and "Path" or "View"))
		if seen[data.Path] then
			error("This path already exists: " .. data.Path)
		end
		seen[data.Path] = true
	end
end

function _checkURL(originalPath: string, path: string): (boolean, { string? })
	local originalSplit = originalPath:lower():split(Router.URL_SEPARATOR)
	local split = path:lower():split(Router.URL_SEPARATOR)
	local slugs = {}
	table.remove(originalSplit, 1)
	table.remove(split, 1)

	if #originalSplit < #split then
		return false, {}
	end

	for index, token in ipairs(originalSplit) do
		local isSlug = token:match("^:") and token:match(":$")
		if isSlug then
			slugs[token:sub(2, -2)] = split[index] or ""
		elseif not isSlug and split[index] ~= token then
			return false, {}
		end
	end

	return true, slugs
end

--[=[
	Updates the Router class to all RouterViews
	@within Router
	@param withData { [any]: any }? -- Any extra data to send to the route's view
--]=]
function Router:_update(withData: { [any]: any }?)
	self.Current.Data = withData or {}
	self.Current.Data.Router = self

	for index, routerView in ipairs(self._routerViews) do
		if routerView.Component then
			routerView.Lifecycle("PageSwitch")
			routerView.Children:get():Destroy()
			routerView.Children:set(self.Current.View:get()(self.Current.Data))
			routerView.Lifecycle("PageSwitchEnded")
		else
			table.remove(self._routerViews, index)
		end
	end
end

--[=[
	Pushes the new route to the stack. All RouterViews will be automatically updated
	@within Router
	@param path string -- The route's path
	@param withData { [any]: any }? -- Any extra data to send to the route's view
--]=]
function Router:Push(path: string, withData: { [any]: any }?)
	for _, route in ipairs(self.Routes) do
		local isSame, slugs = _checkURL(route.Path, path)
		if isSame then
			_populateStates(self.Current, route)
			withData.Slugs = slugs
			self:_update(withData)
			break
		end
	end
end

--[=[
	Generates and returns a new RouterView component binded to the current Router class
	@within Router
	@param lifecycle (event: string) -> ()? -- A function to call when a lifecycle reaches
	@return [Frame] -- Returns the RouterView component
--]=]
function Router:GetView(lifecycle: (string) -> ()?)
	local children = Fusion.Value(self.Current.View:get()(self.Current.Data))
	local routerView = Fusion.New("Frame")({
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 1, 0),
		[Fusion.Children] = children,
	})

	table.insert(self._routerViews, {
		Component = routerView,
		Children = children,
		Lifecycle = lifecycle or function() end,
	})

	return routerView
end

--[=[
	Creates a new Router class.

	Each route must have at least 3 fields, `Path`, `View`, and `Meta`.
	The `path` field represents the identifier for the route, duplicated path should never exist as it will break the
	functionality of the Router. The `View` field is a function that will be called when [Router:Push()] is called with
	the corresponding path, it should return a [Instance]. The `Meta` field is a table that can be used to store any
	global data that can be used outside of RouterView. It should not be used to store any data that is specific to the
	route, for that, send data in the `withData` parameter in the [Router:Push()] function.

	You can add other kind of data, the Data field is reserved for route-specific data and is not stateful by default.
	@param routes { Path: string, View: ({ [any]: any }) -> any, Meta: { [any]: any }, [any]: any } -- The routes to add
	@return Router -- Returns the new Router class
]=]
function Router.new(routes: Routes)
	local self = setmetatable({
		Current = {},
		Routes = routes,
		_routerViews = {},
	}, Router)

	_checkRoute(routes)

	for _, route in pairs(self.Routes) do
		if route.Path == self.ROUTER_BASE_PATH then
			_populateStates(self.Current, route)
			self:_update()
			break
		end
	end

	return self
end

return Router
