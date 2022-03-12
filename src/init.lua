local Fusion = require(script.Fusion)

local Router = { ROUTER_BASE_PATH = "/" }
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
			self[key] = (self[key] and self[key].set) and self[key]:set(data) or Fusion.Value(data)
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

function Router:_update(withData: { [any]: any }?)
	self.Current.Data = withData or {}
	self.Current.Data.Router = self

	for index, routerView in ipairs(self._routerViews) do
		routerView.Children:get():Destroy()
		if routerView.Component then
			routerView.Lifecycle("PageSwitch")
			routerView.Children:set(self.Current.View:get()(self.Current.Data))
		else
			table.remove(self._routerViews, index)
		end
	end
end

function Router:Push(path: string, withData: { [any]: any }?)
	for _, route in ipairs(self.Routes) do
		if path:lower() == route.Path:lower() then
			_populateStates(self.Current, route)
			self:_update(withData)
			break
		end
	end
end

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
		Lifecycle = lifecycle or function () end,
	})

	return routerView
end

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
