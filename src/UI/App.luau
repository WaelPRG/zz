local ReplicatedStorage = game:GetService("ReplicatedStorage")
local React = require(ReplicatedStorage.Packages.React)
local testing = require(ReplicatedStorage.UI.Component.test)

local e = React.createElement
return function ()
    return e(
        "ScreenGui",
        {
            ResetOnSpawn = false
        },
        {
            tests = e(
                testing
            )
        }
    )
end