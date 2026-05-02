local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local Services = ServerStorage.Services

local Types = require(ReplicatedStorage.Shared.Types)
local knit : Types.knitServer = require(ReplicatedStorage.Packages.knit)

knit.AddServices(Services)
knit.OnStart():andThen(function()
end)
knit.Start()
:andThen(function()
    print("[Server]: Knit started successfully")
    end)
    :catch(function(err)
        warn("Error starting Knit:", err)
    end)