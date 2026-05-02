local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local _localPlayer = Players.LocalPlayer

-- react is for UI

local knit = require(ReplicatedStorage.Packages.knit)

local newController = knit.CreateController {
    Name = "newController",
}

function newController:KnitInit()
end
--Coins
function newController:KnitStart()

    local _DataStoreService = knit.GetService("DataStoreService")
    
end

function newController:new()
    --TODO: 
end

return newController