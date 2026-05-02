local ReplicatedStorage = game:GetService("ReplicatedStorage")
local React = require(ReplicatedStorage.Packages.React)
local ReactRoblox = require(ReplicatedStorage.Packages.ReactRoblox)
local test = require(ReplicatedStorage.UI.Component.test)

local controls = {}

local story = {
    react = React,
    reactRoblox = ReactRoblox,
    controls = controls,
    story = function (props)
        print(props)
        local root = ReactRoblox.createRoot(props.target)
        return root:render(React.createElement(test))
    end
}


return story