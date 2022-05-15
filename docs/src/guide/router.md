# Router

The router is the core element in FusionRouter. Developers use this class in order to integrate FusionRouter into their project.

To define a router, you just have to require the library and call it:
```lua
local FusionRouter = require(...)
local router = FusionRouter {
    ["/"] = {
        Page = require(...),
        Data = {},
    }
}
```

The code above creates a new Router and add the route `"/"` to it. The created router exposes public methods and members useful for what you are working on, such as [navigation](./nav.md), [adding new routes](./routes.md). For a more detailed definition of every methods and members inside the router class, [check this page](../api/README.md).