local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Fusion = require(ReplicatedStorage.Packages.Fusion)

export type Route<T> = {
    Path: T,
    Page: (({ Router: Router, Parameters: { [any]: any } }) -> (Instance)),
    Data: { [string]: any },
    [any]: any
}

export type Routes = {
    [string|number]: Route<string?>,
}

export type TreeChild<T> = {
    Value: T,
    Children: {
        [string]: TreeChild<T>
    },
    Parent: TreeChild<T>?,
}

export type Router = {
    CurrentPage: {
        Path: Fusion.Value<string>,
        Page: Fusion.Value<({ Router: Router, Parameters: { [any]: any } }) -> (Instance)>,
        Data: {
            [any]: Fusion.Value<any>,
        },
        [any]: any,
    },
    Routes: {
        [string]: TreeChild<Route<string>>,
    },

    new: CreateRouter,
    addRoute: (Route<string>) -> (),
    getRoute: (string) -> (Route<string>?),
    push: (string, { [any]: any }) -> (),
    back: (number?) -> (),
    canGoBack: (number?) -> (boolean),
}

export type CreateRouter = (Routes) -> (Router)
export type Parse = (string) -> (string?, string?)
export type Version = { Major: number, Minor: number, IsRelease: boolean }

return {}