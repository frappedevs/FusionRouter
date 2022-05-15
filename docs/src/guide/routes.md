# Routes

Routes are what you use to define pages in the router class. Without defining the routes, the router simply will not function as router heavily relies on routes to produce any outcome.

In FusionRouter, we have a specific format for routes:
```lua
{
	Path: string?,
	Page: (({ Router: Router, [any]: any }) -> (Instance)),
	Data: { [string]: any },
	Parameters: { [any]: any }?,
}
```

## Path

If you are defining routes during router creation, you can use the table index as the path for the route. Otherwise, specify the route path in the `path` member.

```lua
Router {
    ["/foo/"] = {
        Page = require(Pages.Foo),
        Data = {},
    },
}
```
The above will create a route with path `"/foo"/`. Same for the code below:

```lua
Router {
    {
        Path = "/foo/",
        Page = require(Pages.Foo),
        Data = {},
    },
}
```

Note that FusionRouter is case-insensitive, `"/foo/"` == `"/FOO/"`

## Page

The `page` field accepts a function that returns a `Instance` class. When the router is calling the `page` function, it will pass a table with a reference to itself under `Router`. This is useful when you want to navigate to another page.

Any parameters for the route will be also passed to that table. Explanation on what parameter is can be found in the next section.
```lua
return function(props)
    return New "TextButton" {
        Text = props.Text, -- Text is a parameter here

        [OnEvent "Activated"] = function()
            props.Router:push("/") -- props.Router is a reference to the router class which pushed to this page.
        end,
    }
end
```

## Parameters

Sometimes, a page may return a different result depending on situations. Parameters are handy when it comes to situations like this. In FusionRouter, parameters are not anywhere magical, it is just a table holding values. They are stored in the table found in the page function, one's value can be retrieved with its name.

There are two ways to pass parameters to a route. Either by the `Router:push()` method, or by using dynamic route.

### Passing parameters via `Router:push()`
You can pass parameters with the `Router:push()` and it is really easy. Pass a table after the path parameter:
```lua
Router:push("/foo/", {
    Text = "Bar!",
})
```

### Passing parameters with dynamic routing
Dynamic routing in FusionRouter is just like `("/foo/%s/"):format("Bar!")` except that the final result of `"%s"` is put into a table with an unique identifier and that identifier is set by you when defining the route. We call this implementation a slug.

A slug is defined with a colon (`:`), and then with identifier name after it. For example, `/foo/:text/`. The page function will be able to get the parameter value via `props.text`:
```lua
return function(props)
    return New "TextButton" {
        Text = props.text -- ":text in /foo/:text/"
    }
end
```

Now, to push to `"/foo/"`, you just have to pass the value of `":text"` after `"/foo"/`: `"/foo/bar/"`.

## Data

When defining routes, you might would like to insert some arbitrary information to a route like route title, route favicon, etc. This can be done by using the `Data` field in a route. When that page is being served as the current page in the router, whatever is inside the `Data` field will be automatically converted to `Fusion.State` and can be achieved via `Router.CurrentPage.Data`.

Internally, how this work is that we are using a library called `StateDict`, which is basically a dictionary of states. As how the `StateDict` library work, you have to call the `:get()` method on it to return a locked dictonary of the states.

We recommend storing data in the `Data` field only when those data exist across all routes.
```lua
{
    Path = "/foo/:text/",
    Page = require(Pages.Foo),
    Data = {
        Title = "Foo!"
    }
}
```

```lua
Router:push("/foo/bar/")
print(Router.CurrentPage.Data:get().Title:get()) --> "Foo!"
```