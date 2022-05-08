--- 7kayoh
--- StateDict.lua
--- 6 May 2022

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Packages = ReplicatedStorage.Packages

local Fusion = require(Packages.Fusion)

local StateDict = {}
StateDict.__index = StateDict

function StateDict.new(value: { [any]: any })
    local self = setmetatable({}, StateDict)
    self:set(value)
    return self
end

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
                    oldValue[name] = Fusion.Value(value)
                end
            end
        end
    end
    resolve(self, newValue)
end

return StateDict.new