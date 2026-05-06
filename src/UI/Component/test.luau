local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local React = require(ReplicatedStorage.Packages.React)
local _ReactRoblox = require(ReplicatedStorage.Packages.ReactRoblox)
local charm = require(ReplicatedStorage.Packages.charm)
local useCoinshook = require(ReplicatedStorage.UI.Hooks.useCoinshook)
local TextLabel = require(ReplicatedStorage.UI.Primitive.TextLabel)

local e = React.createElement


return function ()

    local coins = if RunService:IsRunning() then useCoinshook() else nil

    return e (
        TextLabel,
        {
            Size = UDim2.fromScale(.22, .2),
            Position = UDim2.fromScale(.12, .5),
            Text = if coins then coins else "NULL",
            BGTransparency = 0.5,
        },
        {
            Corner = e(
                "UICorner"
            ),
            Stroke = e(
                "UIStroke"
            )
        }
    )
end    