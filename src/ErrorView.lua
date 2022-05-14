local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Packages = ReplicatedStorage.Packages
local Fusion = require(Packages.Fusion)

local New = Fusion.New
local Children = Fusion.Children
local Computed = Fusion.Computed
local OnEvent = Fusion.OnEvent

return function(props)
    return New "Frame" {
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundColor3 = Color3.fromHex("#282828"),
        BorderSizePixel = 0,
        Size = UDim2.fromScale(1, 0),
        Visible = props.IsActive,
    
        [Children] = {
            New "TextLabel" {
                Font = Enum.Font.SourceSansSemibold,
                Text = props.Message,
                TextColor3 = Color3.fromHex("#FFFFFF"),
                TextSize = 18,
                TextWrapped = true,
                AutomaticSize = Enum.AutomaticSize.Y,
                TextXAlignment = Enum.TextXAlignment.Left,
                BackgroundTransparency = 1,
                LayoutOrder = 2,
                Size = UDim2.fromScale(1, 0),
            },
    
            New "TextLabel" {
                Font = Enum.Font.SourceSansBold,
                Text = Computed(function()
                    return props.Title:get()
                end),
                TextColor3 = Color3.fromHex("#FFD500"),
                TextSize = 20,
                TextWrapped = true,
                AutomaticSize = Enum.AutomaticSize.Y,
                TextXAlignment = Enum.TextXAlignment.Left,
                BackgroundTransparency = 1,
                LayoutOrder = 1,
                Size = UDim2.fromScale(1, 0),
            },
    
            New "UIPadding" {
                PaddingBottom = UDim.new(0, 24),
                PaddingLeft = UDim.new(0, 24),
                PaddingRight = UDim.new(0, 24),
                PaddingTop = UDim.new(0, 24),
            },
    
            New "Frame" {
                AutomaticSize = Enum.AutomaticSize.Y,
                LayoutOrder = 4,
                BackgroundTransparency = 1,
                Size = UDim2.fromScale(1, 0),
    
                [Children] = {
                    New "UIPadding" {
                        PaddingTop = UDim.new(0, 24),
                    },
    
                    New "TextButton" {
                        Font = Enum.Font.SourceSansBold,
                        RichText = true,
                        Text = "<u>Reload Application</u>",
                        TextColor3 = Color3.fromHex("#FFFFFF"),
                        TextSize = 16,
                        TextWrapped = true,
                        AutomaticSize = Enum.AutomaticSize.XY,
                        BackgroundColor3 = Color3.fromHex("#FFFFFF"),
                        BackgroundTransparency = 0.8,
                        BorderSizePixel = 0,
                        LayoutOrder = 4,
                        Visible = props.CanReturn,

                        [OnEvent "Activated"] = function()
                            if props.CanReturn:get() then
                                props.IsActive:set(false)
                                props.Router:push("/")
                            end
                        end,
                    },
                }
            },
    
            New "UIListLayout" {
                Padding = UDim.new(0, 2),
                SortOrder = Enum.SortOrder.LayoutOrder,
                VerticalAlignment = Enum.VerticalAlignment.Center,
            },
        }
    }
end