<div align="center">

![FusionRouter Light](./gh_assets/FusionRouter_Light.png#gh-light-mode-only)
![FusionRouter Dark](./gh_assets/FusionRouter_Dark.png#gh-dark-mode-only)
</div>

# FusionRouter
UI Routing in Fusion, done with `Fusion.Value`

:warning: Work In Progress! Features are incomplete and bugs may occur.

If you came from web development (React, Vue, Svelte, et cetera). You definitely know **Routers**. That's basically what FusionRouter does! Except paths are just an identier rather than an actual URI, and there is no need for a server to serve the Views.

Of course, you can implement a similar workaround by using `Fusion.New "Frame` and `Fusion.Value` only, but without lifecycles method, it's really hard to clean the current view completely for GC purposes.

## Usage
All you need to do is...

<div align="center">
<big>Router.new(Routes) & Router:Push()</big>
</div>
<br>

The argument `Routes` is a table of routes with the minimum syntax below:

```lua
{
    Path = "/..",
    Component = ComponentFunction: ({[any]: any}) -> (Instance),
    OnCleanup = CleanupFunction: (Router.CurrentRoute) -> (),
}
```

You can further expand it for your other UI needs, like this...
```lua
	{
		Path = "/",
		Meta = {
			Title = "Verification Center",
			Subtitle = "Home",
			Icon = Icons.home,
		},
		Component = require(AppViews.Home),
		OnCleanup = function(route)
            route.Component:get():Destroy()
		end,
	},
```

In `OnCleanup`, the parameter `route` returns the data for the current route, **the OnCleanup function must always be async**.

## License
FusionRouter is licensed under the MIT license.
