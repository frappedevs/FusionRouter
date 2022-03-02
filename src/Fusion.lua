local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Fusion = ReplicatedStorage:FindFirstChild("Fusion")
local Wally = ReplicatedStorage:FindFirstChild("Packages")
local WallyFusion = Wally and Wally:FindFirstChild("Fusion") or nil

if Fusion and Fusion:IsA("ModuleScript") then
	return require(Fusion)
elseif WallyFusion and WallyFusion:IsA("ModuleScript") then
	return require(WallyFusion)
else
	error(
		"Can not find Fusion in ReplicatedStorage and ReplicatedStorage.Packages, have you actually installed Fusion?\n\nIf you have, adjust FusionRouter/Fusion.lua to point to your Fusion installation."
	)
end
