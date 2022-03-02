local Fusion = require(script.Fusion)

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

function Router:Push(path, withData)
    for _, route in ipairs(self.Routes) do
        if path:lower() == route.Path:lower() then
            self.CurrentRoute.OnCleanup:get()(self.CurrentRoute)
            UpdateStatesRecursively(route, self.CurrentRoute)
            self.CurrentRoute.Data = withData or {}
        end
    end
end

function Router:GetView()
    return Fusion.New("Frame"){
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),

        [Fusion.Children] = Fusion.Computed(function()
           return self.CurrentRoute.Component:get()(self.CurrentRoute.Data)
        end),
    }
end

function Router:_initializeStates(route, tabl)
    for key, data in pairs(route) do
        if typeof(data) == "table" then
            tabl[key] = {}
            Router:_initializeStates(data, tabl[key])
        elseif key ~= "Data" then
            tabl[key] = Fusion.Value(data)
        end
    end
end

function Router.new(routes)
    local self = setmetatable({
        Routes = routes,
    }, Router)

    for _, route in ipairs(self.Routes) do
        if route.Path == ROUTER_BASE_PATH and not self.CurrentRoute then
            self.CurrentRoute = {}
            Router:_initializeStates(route, self.CurrentRoute)
            break
        end
    end

    return self
end

return Router