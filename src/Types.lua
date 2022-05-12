local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Fusion = require(ReplicatedStorage.Packages.Fusion)

local Tree = require(script.Parent.Tree)
local StateDict = require(script.Parent.StateDict)

export type Route<T> = {
    Path: T,
    Page: (({ Router: Router, Parameters: { [any]: any } }) -> (Instance)),
    Data: { [string]: any },
    Parameters: { [any]: any }?,
}

export type Routes = {
    [string|number]: Route<string?>,
}


export type Router = {
    CurrentPage: {
        Path: Fusion.State<string>,
        Page: Fusion.State<({ Router: Router, Parameters: { [any]: any } }) -> (Instance)>,
        Data: StateDict.StateDict<any>,
        Parameters: { [any]: any },
    },
    History: { Route<string> },
    Routes: {
        [string]: Tree.Tree<Route<string>>,
    },

    addRoute: (Route<string>) -> (),
    getRoute: (string) -> (Route<string>?),
    push: (string, { [any]: any }) -> (),
    back: (number?) -> (),
    canGoBack: (number?) -> (boolean),
}

return {}