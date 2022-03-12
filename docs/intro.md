# Introduction

![](/banner.png)

FusionRouter is a UI Routing library designed to be used with Fusion, the declarative UI library made by Elttob. It is implemented with references of VueRouter, how routes are defined are very similar to how you do it in VueJS.

In a nutshell, FusionRouter is basically `[Children] = PageState` and `PageState:set(newPage)`, but with more powerful utilities to make UI routing less painful and reduce more boilerplate codes. The `Meta` field allows you to use data that is not exclusive to one page, such as page name, page description, et cetera.

If you are from VueJS, you can easily recreate the similar working experience in Fusion with the use of FusionRouter. Everything is designed to be simple and one-liner, so you can create UI in an even faster pace.