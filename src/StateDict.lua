--- 7kayoh
--- StateDict.lua
--- 6 May 2022

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Packages = ReplicatedStorage.Packages

local Fusion = require(Packages.Fusion)

type DictOfStates<T> = {
    [any]: Fusion.State<T> | DictOfStates<T>
}

export type StateDict<T> = {
    set: ({ [any]: T }, boolean?) -> (),
    get: () -> (DictOfStates<T>),
    clearAll: (boolean?) -> (),

    _values: DictOfStates<T>,
}

local StateDict = {}
StateDict.__index = StateDict

function StateDict:set(newValue: { [any]: any }, force: boolean?)
    local function resolve(oldValue, newValue)
        for name, value in pairs(newValue) do
            if typeof(value) == "table" then
                oldValue[name] = oldValue[name] or {}
                resolve(oldValue[name], value)
            else
                if oldValue[name] and oldValue[name].set then
                    oldValue[name]:set(value, force)
                else
                    oldValue[name] = Fusion.State(value)
                end
            end
        end
    end
    resolve(self._values, newValue)
end

function StateDict:get()
    return table.freeze(table.clone(self._values))
end

function StateDict:clearAll(force: boolean?)
    local function resolve(value)
        for _, value in pairs(value) do
            if typeof(value) == "table" then
                resolve(value)
            else
                value:set(nil, force)
            end
        end
    end
    
    resolve(self._values)
end

return function(value: { [any]: any }): StateDict<any>
    local self = setmetatable({ _values = {} }, StateDict)
    self:set(value)
    return self
end