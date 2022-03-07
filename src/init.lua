local ReplicatedFirst = game:GetService("ReplicatedFirst")

local Alias = require(ReplicatedFirst.Core.Alias)
local Fusion = require(Alias.Fusion)

local ROUTER_BASE_PATH = "/"

local Router = {}
Router.__index = Router

function UpdateStatesRecursively(route, tabl)
	for key, data in pairs(route) do
		if typeof(data) == "table" then
			UpdateStatesRecursively(data, tabl[key])
        elseif key ~= "Data" then
			tabl[key]:set(data)
		end
	end
end

function InitializeStates(route, tabl)
    for key, data in pairs(route) do
        if typeof(data) == "table" then
            tabl[key] = {}
            InitializeStates(data, tabl[key])
        elseif key ~= "Data" then
            tabl[key] = Fusion.Value(data)
        end
    end
end

function Router:_update()
    for _, routerView in ipairs(self._routerViews) do
        routerView.Children:get():Destroy()
        if routerView.Component then
            routerView.Children:set(self.Current.View:get()(self.Current.Data))
        end
    end
end

function Router:Push(path, withData)
    for _, route in ipairs(self.Routes) do
        if path:lower() == route.Path:lower() then
            UpdateStatesRecursively(route, self.Current)
            withData = withData or {}
            withData.Router = self
            self.Current.Data = withData
            self:_update()
            break
        end
    end
end

function Router:GetView()
    local children = Fusion.Value(self.Current.View:get()(self.Current.Data))
    local routerView = Fusion.New("Frame"){
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        [Fusion.Children] = children
    }

    table.insert(self._routerViews, {
        Component = routerView,
        Children = children,
    })

    return RouterView
end

function Router.new(routes)
    local self = setmetatable({
        Routes = routes,
        Current = {
            Data = {
                Router = self,
            },
        },
        _routerViews = {},
    }, Router)

    for _, route in ipairs(self.Routes) do
        if route.Path == ROUTER_BASE_PATH then
            self:_initializeStates(route, self.Current)
            break
        end
    end

    return self
end

return Router