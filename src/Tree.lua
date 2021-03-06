--- 7kayoh
--- Tree.lua
--- 6 May 2022

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Packages = ReplicatedStorage.Packages

local Fusion = require(Packages.Fusion)

export type Tree<T> = {
	new: (value: any, children: { [string]: any }?, parent: Tree<any>?) -> (),
	get: (Tree<T>) -> (any),
	set: (Tree<T>, any) -> (),
	newChild: (Tree<T>, { [string]: any }) -> (),
	getRoot: (Tree<T>) -> (Tree<any>?),
	destroy: (Tree<T>) -> (),

	Value: T,
	[Fusion.Symbol]: { [string]: Tree<any> },
	Parent: Tree<any>?,
}

local Tree = {}
Tree.__index = Tree

function Tree.new(value: any, children: { [string]: any }?, parent: any?): Tree<any>
	local self = setmetatable({
		Value = value,
		[Fusion.Children] = {},
		Parent = parent,
	}, Tree)
	if children then
		self:newChild(children)
	end

	return self
end

function Tree:get()
	return self.Value
end

function Tree:set(newValue: any)
	self.Value = newValue
end

function Tree:newChild(children: { [string]: any })
	for name, value in pairs(children) do
		assert(not self[Fusion.Children][name], ('Children with "%s" already exists'):format(name))
		self[Fusion.Children][name] = Tree.new(value, nil, self)
	end
end

function Tree:getRoot()
	local node = self
	while node.Parent do
		node = node.Parent
	end

	return node
end

function Tree:destroy()
	if self.Parent then
		for name, children in pairs(self.Parent[Fusion.Children]) do
			if children == self then
				self.Parent[Fusion.Children][name] = nil
			end
		end
		self.Parent = nil
	end
end

return Tree.new
