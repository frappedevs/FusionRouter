local Types = require(script.Types)

type FusionRouter = {
	Version: Types.Version,
	Router: Types.CreateRouter,
	Parse: Types.Parse,
}

return {
	Version = { Major = 1, Minor = 0, IsRelease = false },

	Router = require(script.Router),
	Parse = require(script.Parse),
} :: FusionRouter