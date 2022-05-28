# Creating Router
Now that we have FusionRouter up and running, let's learn how to create a router for our project.

**Required code**
```lua
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Packages = ReplicatedStorage.Packages

local Fusion = require(Packages.Fusion)
local FusionRouter = require(Packages.FusionRouter)
```

## Declaring Pages
In FusionRouter, a route is a dictionary of information regarding a specific page. Basic information like the path identifier and the page constructor function, is crucial to make a route, a route.

To make FusionRouter as easy as possible for Fusion users. FusionRouter uses a declarative and Fusion-like syntax for defining routes. Here's an example code showing the syntax:
```lua
local DemoRouter = FusionRouter {
    ["/"] = {
        Data = {},
        Page = function()
            return Fusion.New "TextLabel" {
                Size = UDim2.fromScale(1, 1),
                Text = "Hello, world!"
            }
        end,
    },

    ["/foo"] = {
        Data = {},
        Page = function()
            return Fusion.New "TextLabel" {
                Size = UDim2.fromScale(1, 1),
                Text = "Foo!"
            }
        end,
    },
}
```

The code above creates two routes:
- Route `/` shows a `TextLabel` displaying `Hello, world!`
- Route `/foo` shows a `TextLabel` displaying `Foo!`

Unlike most routing libraries. FusionRouter promotes the usage of dictionary member indices to define the path of a route. If you do not prefer doing so this way, you can always stick to the traditional method:

```lua
local DemoRouter = FusionRouter {
    {
        Path = "/",
        Data = {},
        Page = function()
            return Fusion.New "TextLabel" {
                Size = UDim2.fromScale(1, 1),
                Text = "Hello, world!"
            }
        end,
    },

    {
        Path = "/foo",
        Data = {},
        Page = function()
            return Fusion.New "TextLabel" {
                Size = UDim2.fromScale(1, 1),
                Text = "Foo!"
            }
        end,
    },
}
```

The code above is the same as the code before this one, except it does not use indices for defining the path.

## Add A Route Later
Some scenarios may require you to add the route at later moment. FusionRouter exposes a method for those situations.

Once you created the router, you will be given an object with a list of methods to use. The method we will be using for now is the `:addRoute()` method. The `:addRoute()` method is the only way to get a route added to FusionRouter, even the constructor method above uses `:addRoute()` too. However, unlike the previous method, this does not allow using indices for path declaration as the `:addRoute()` method accepts one route only.

Here's an example code for you to understand it better:
```lua
DemoRouter:addRoute({
    Path = "/bar",
    Data = {},
    Page = function()
        return Fusion.New "TextLabel" {
            Size = UDim2.fromScale(1, 1),
            Text = "Foo, Bar!"
        }
    end,
})
```

The code above adds a new route with the path `/bar`, and displays a `TextLabel` with the text `Foo, Bar!`

___

> **Note**
> If you hit 'Play' now, you will get nothing. Why? [Because you did not provide a way to render the results](./Rendering_Pages.md)

___

Congratulations - you've now learned how to create a router! Over the course of the next few tutorials, you'll see this syntax being used a lot, so you'll have some time to get used to it.

It's important to understand the syntax for defining a route, as it is a necessary part to get FusionRouter to work.

**Finished code**
```lua
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Packages = ReplicatedStorage.Packages

local Fusion = require(Packages.Fusion)
local FusionRouter = require(Packages.FusionRouter)

local DemoRouter = FusionRouter {
    ["/"] = {
        Data = {},
        Page = function()
            return Fusion.New "TextLabel" {
                Size = UDim2.fromScale(1, 1),
                Text = "Hello, world!"
            }
        end,
    },

    ["/foo"] = {
        Data = {},
        Page = function()
            return Fusion.New "TextLabel" {
                Size = UDim2.fromScale(1, 1),
                Text = "Foo!"
            }
        end,
    },
}

DemoRouter:addRoute({
    Path = "/bar",
    Data = {},
    Page = function()
        return Fusion.New "TextLabel" {
            Size = UDim2.fromScale(1, 1),
            Text = "Foo, Bar!"
        }
    end,
})
```

## Quick links:
- [All Tutorials](../README.md)
- [Home](../../README.md)