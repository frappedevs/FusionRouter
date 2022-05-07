![Router](https://user-images.githubusercontent.com/40730127/160251857-1329b88d-236b-4166-954b-2345a8700d97.png)

# FusionRouter

[![Join the chat at https://gitter.im/frappedevs/fusionrouter](https://badges.gitter.im/frappedevs/fusionrouter.svg)](https://gitter.im/frappedevs/fusionrouter?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)

FusionRouter is a UI Routing library designed to be used with Fusion, the declarative UI library made by Elttob. It is implemented with references of VueRouter, how routes are defined are very similar to how you do it in VueJS.

In a nutshell, FusionRouter is basically `[Children] = PageState` and `PageState:set(newPage)`, but with more powerful utilities to make UI routing less painful and reduce more boilerplate codes. The `Meta` field allows you to use data that is not exclusive to one page, such as page name, page description, et cetera.

If you are from VueJS, you can easily recreate the similar working experience in Fusion with the use of FusionRouter. Everything is designed to be simple and one-liner, so you can create UI in an even faster pace.

## Installation

Added installation by Wally, you can now either choose to install by Wally or by filesystem.

To install by using Wally, simply add `7kayoh/fusionrouter` into your `toml` file. To install manually, download the latest release's source code.

### Why not `frappedevs/fusionrouter`?
We would love to publish to the scope `frappedevs`, but we do not have permission to do that in the Wally index nor had a response from the team regarding this problem. 😞

## Community
[Discord](https://discord.gg/JSHRQkrafN)

## License
FusionRouter is licensed under the MIT license.
