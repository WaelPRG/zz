local _Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")


local Signal = require(ReplicatedStorage.Packages.Signal)
local Types = require(ReplicatedStorage.Shared.Types)
local knit : Types.knitClient = require(ReplicatedStorage.Packages.knit)

local PlayerProfileController = knit.CreateController {
    Name = "PlayerProfileController"
}


function PlayerProfileController:KnitInit ()
    self.CoinsChanged = Signal.new()
    self.Data = {}
    self.Properties = {}
end

function PlayerProfileController:KnitStart ()
    
    local DataStoreService = knit.GetService("DataStoreService")
    self.DataStoreService = DataStoreService

    self.Properties["Coins"] = DataStoreService.Coins

    self.Properties.Coins:Observe(function(newValue)
        print(`Coins changed to {newValue}`)
        self.CoinsChanged:Fire(newValue)
    end)

end



knit.OnStart():andThen(function()

end)

return PlayerProfileController