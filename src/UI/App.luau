local ReplicatedStorage = game:GetService("ReplicatedStorage")
local React = require(ReplicatedStorage.Packages.React)
local _testing = require(ReplicatedStorage.UI.Component.test)
local HoldingUI = require(ReplicatedStorage.UI.features.HoldingUI)

local e = React.createElement
return function ()
    return e(
        "ScreenGui",
        {
            ResetOnSpawn = false
        },
        {
            HoldingUI = e(HoldingUI)
        }
    )
end