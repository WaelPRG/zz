local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local localPlayer = Players.LocalPlayer
local PlayerScripts = localPlayer.PlayerScripts
local Types = require(ReplicatedStorage.Shared.Types)
local knit : Types.knitClient = require(ReplicatedStorage.Packages.knit)

knit.AddControllers(PlayerScripts.Controllers)

knit.Start()
    :andThen(function()
     print(`[Client {localPlayer.Name}]: Knit started successfully`) 
        end)
    :catch(function(err)
        warn("Error starting Knit:", err)
    end)