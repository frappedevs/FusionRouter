# Get Started
Welcome to FusionRouter! FusionRouter is an expressive routing library that delivers fine-grained navigation control and declarative syntax just like your Fusion UI.

## What You Need To Know
These tutorials assume:
- You are comfortable with Roblox and the Luau scripting language.
- You are familiar with Fusion.
  - You do not need to be super familiar with it, but base understanding of how things work in Fusion will allow you to understand whatever is explained in this section.

## How These Tutorials Work
You can find a list of all published tutorials in [the index file of this folder](../README.md). Tutorials here are grouped together by category just like with the Fusion documentation:
- **Fundamentals** introduces the core ideas of FusionRouter - defining routes, navigation through pages, using page parameters.
- **Further Basics** builds on those core ideas by adding advanced concepts for building more complex application. They are usually optimization tips for ensuring scalability of your application when using FusionRouter.

For beginners, start with the fundamentals section first as FusionRouter contains some abstract concepts that is only commonly found in web development.

## Tipss
- Pseudo-code is usually given per every section of each tutorial as a bonus in case if the text explanation is poorly understood.
- Sometimes, the final product may be displayed visually, it could be: images, videos, or place files depending on the situation.
- Some tutorials here may not be fully cosrrect. Always use your own judgement if there are something you are not so sure about. FusionRouter is a community-backed project, some of the documentation here may be biased.
- If you have any questions and this documentation does not satisfy your concern, try visiting our community server. [Link here](https://discord.gg/JSHRQkrafN).

## Installing FusionRouter
Fusion is distributed as a single `ModuleScript`. Before starting, you'll need to add this module script to your game. Here's how:

### FusionRouter for Wally-managed Projects
If you use Wally to manage project dependencies, you can install FusionRouter by appending the line below in your `wally.toml` configuration file, under the `[dependencies]` section:
```toml
FusionRouter = "7kayoh/fusionrouter@1.0.0"
```

### Others: FusionRouter for Roblox Studio etc
Unfortunately, FusionRouter is only published to the Wally registry. For those having their project not managed by both Rojo and Wally. This requires some tinkering.

## Setting Up A Test Script
Now that you've finished installing FusionRouter, you can set up a `LocalScript` for testing. Here's how:
```lua
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Packages = ReplicatedStorage.Packages
local FusionRouter = require(Packages.FusionRouter)
```

* Depending on the name you chose for your FusionRouter installation, you might need to adjust the package location in the above code.

## Quick links:
- [All Tutorials](../README.md)
- [Home](../../README.md)