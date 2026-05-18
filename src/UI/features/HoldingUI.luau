local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage.Packages.React)
local useHoldinghook = require(ReplicatedStorage.UI.Hooks.useHoldinghook)

local e = React.createElement
-- local useEffect = React.useEffect


local DEBOUNCED_COLOR : Color3 = Color3.fromRGB(148, 0, 0)
local HOLDING_COLOR : Color3 = Color3.fromRGB(0, 148, 0)
local CHARGING_COLOR : Color3 = Color3.fromRGB(225, 220, 220)
local CORNER_RADIUS : UDim = UDim.new(0, 4)


local function ProgressBar(props)

    local color = if props.Action == `Debounced` then DEBOUNCED_COLOR 
                elseif props.Action == `Holding` then HOLDING_COLOR
                else CHARGING_COLOR


    return e("Frame", {

            AnchorPoint = Vector2.new(0, 0.5),
            Position = UDim2.fromScale(0, 0.5),
            BackgroundColor3 = color,
            BackgroundTransparency = 0.19,
            BorderSizePixel = 0,

            Size = props.Progress:map(function (p)
                p = math.clamp(p, 0, 1)
                return UDim2.fromScale(p, 1)
            end),
        },
        {
            Corner = e("UICorner", {
                CornerRadius = CORNER_RADIUS,
            }),
        })
end

return function ()
    local Values = useHoldinghook()

    local Visible = Values.Visible

    if not Visible then return nil end

    return e("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Size = UDim2.fromScale(0.05, 0.05),
        Position = UDim2.fromScale(0.5, 0.75),
        BackgroundColor3 = Color3.new(0.094118, 0.094118, 0.094118),
        BackgroundTransparency = 0.4,
        ClipsDescendants = true,
        BorderSizePixel = 0,
    },
    {
        AspectRatio = e("UIAspectRatioConstraint", {
            AspectRatio = 4, 
            AspectType = Enum.AspectType.ScaleWithParentSize
        }),
        Corner = e("UICorner", {
            CornerRadius = CORNER_RADIUS,
        }),
        ProgressBar = e(ProgressBar, {
            Progress = Values.Progress,
            Action = Values.Action
        }),
    }
)
end