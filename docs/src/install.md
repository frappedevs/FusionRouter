# Installation

FusionRouter were built with [Wally](https://wally.run) in mind, a package manager for Roblox. For those who have their project managed by both Rojo and Wally, can choose to install FusionRouter by appending the package configuration to the `wally.toml` configuration file. Example below:

```toml
[package]
name = "user/project"
version = "0.1.0"
registry = "https://github.com/UpliftGames/wally-index"
realm = "shared"

[dependencies]
Fusion = "elttob/fusion@0.1.1-beta"
Router = "7kayoh/fusionrouter@1.0.0"
```

For those without Wally can choose to install FusionRouter from source, but this requires further steps so FusionRouter can run properly. Download the latest release's source code [here](https://github.com/frappedevs/fusionrouter/releases), and make sure your Fusion installation is placed inside `ReplicatedStorage.Packages`.

We highly do not recommend using the source code found in the master branch of the repository. The branch contains unreleased, untested and potentially unsafe code hence making it not production ready.