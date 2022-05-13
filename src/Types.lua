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

    addRoute: (Router, Route<string>) -> (),
    getRoute: (Router, string) -> (Route<string>?),
    push: (Router, string, { [any]: any }) -> (),
    back: (Router, number?) -> (),
    canGoBack: (Router, number?) -> (boolean),
}

return {}