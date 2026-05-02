local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Types = require(ReplicatedStorage.Shared.Types)
local knit : Types.knitServer = require(ReplicatedStorage.Packages.knit)

local secondService = knit.CreateService {
    Name = "secondService",
}

function secondService:KnitInit()
end

function secondService:KnitStart()
end


knit.OnStart():andThen(function()
end)

return secondService