local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local localPlayer = Players.LocalPlayer
local PlayerGui = localPlayer:WaitForChild("PlayerGui")

local Types = require(ReplicatedStorage.Shared.Types)

local React = require(ReplicatedStorage.Packages.React)
local ReactRoblox = require(ReplicatedStorage.Packages.ReactRoblox)
local knit : Types.knitClient = require(ReplicatedStorage.Packages.knit)
local App = require(ReplicatedStorage.UI.App)



local UIController = knit.CreateController {
    Name = "UIController",

}

function UIController:KnitInit ()

end

function UIController:KnitStart ()
-- load render
    local container = Instance.new("ScreenGui")
    container.Parent = PlayerGui
    container.ResetOnSpawn = false
    local root = ReactRoblox.createRoot(PlayerGui)
    root:render(React.createElement(App))
end

return UIController