local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Types = require(ReplicatedStorage.Shared.Types)
local knit : Types.knitServer = require(ReplicatedStorage.Packages.knit)

local newService = knit.CreateService {
    Name = "newService",
    Client = {
    },
}

function newService:KnitInit()
end

function newService:KnitStart()
end

knit.OnStart():andThen(function()
end)

return newService