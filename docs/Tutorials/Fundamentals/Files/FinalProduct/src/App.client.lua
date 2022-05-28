local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Packages = ReplicatedStorage.Packages

local Fusion = require(Packages.Fusion)
local FusionRouter = require(Packages.FusionRouter)

local DemoRouter = FusionRouter {
	["/"] = {
        Data = {},
		Page = function(params)
			return Fusion.New "TextButton" {
                Size = UDim2.fromScale(1, 1),
				Text = "Hello, world!",

                [Fusion.OnEvent "Activated"] = function()
                    params.Router:push("/foo")
                end,
			}
		end,
	},

	["/foo"] = {
        Data = {},
		Page = function(params)
			return Fusion.New "TextButton" {
                Size = UDim2.fromScale(1, 1),
				Text = "Foo!",
                
                [Fusion.OnEvent "Activated"] = function()
                    params.Router:push("/bar")
                end,
			}
		end,
	},
}

DemoRouter:addRoute({
	Path = "/bar",
    Data = {},
	Page = function()
		return Fusion.New "TextButton" {
            Size = UDim2.fromScale(1, 1),
			Text = "Foo, Bar!",

            [Fusion.OnEvent "Activated"] = function()
                DemoRouter:push("/")
            end,
		}
	end,
})

local DemoUI = Fusion.New "ScreenGui" {
	ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
	Parent = Players.LocalPlayer.PlayerGui,

	[Fusion.Children] = {
		Fusion.New "Frame" {
			Size = UDim2.fromScale(1, 1),

			[Fusion.Children] = { DemoRouter:getRouterView() }
		}
	}
}