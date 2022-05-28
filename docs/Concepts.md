# Concepts

This page is pretty much an optional section. You do not really need to read this page in order to understand FusionRouter, but for those who have no knowledge about how web development works. This section is a plus to make things more easier to understand.

Anyway, If TL;DR, here's a list of concepts in FusionRouter with the shortest definition.

- [Concepts](#concepts)
  - [Route](#route)
    - [Constructor Method](#constructor-method)
    - [Function Method](#function-method)
  
  A dictionary storing the necessary information regarding a page.

  - [Path](#path)
    
    An unique identifier for the route
  - [Data](#data)
    
    A dictionary of data regarding the route
  - [Page](#page)
    
    A function that constructs the page

- [Push](#push)

  Jumps to a specific page
- [Back](#back)
  
  Go back to the previous page
- [Concepts](#concepts)
  - [Route](#route)
    - [Constructor Method](#constructor-method)
    - [Function Method](#function-method)
  
  A component that displays the Router-served page
- [Parameters](#parameters)
  
  A dictionary of parameters for the page
- [Dynamic Routing](#)
  
  Uses the path as a way to serve contextual pages

## Route
A route is basically a dictionary that stores value representing the page. It's also the way of how FusionRouter works.

When using FusionRouter, you have to define routes so it can actually do proper navigation. There are two methods depending on the situation you are in:

### Constructor Method
You can define routes when defining the router itself. Just call the constructor function with a list of routes.

This method allows using the index as a source for the route's path.

```lua
local router = FusionRouter {
    ["/"] = {
        Page = function(params) ... end,
    }.

    ["/plr/delete"] = {
        Page = function(params) ... end,
    },

    {
        Path = "/plr/undelete",
        Page = function(params) .. end,
    },
}
```

FusionRouter requires the `"/"` route in order to actually work.

For obvious reasons, stick to one method only when defining the routes using the constructor method.

### Function Method

Additionally, if you want to add a new route at later time, you can choose to use the `:addRoute()` function.

This method however, does not allow the usage of the index for defining page's route as this method only adds one route at one time.