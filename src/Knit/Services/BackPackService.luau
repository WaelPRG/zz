local _Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local _CLasses = ServerStorage.Classes

local Types = require(ReplicatedStorage.Shared.Types)

local _Signal = require(ReplicatedStorage.Packages.Signal)
local knit: Types.knitServer = require(ReplicatedStorage.Packages.knit)

local DataStoreService
local MaterialsService 



local BackPackService = knit.CreateService({
	Name = "BackPackService",
})

function BackPackService:KnitInit ()
end

function BackPackService:KnitStart ()
    repeat
        task.wait()
    until DataStoreService

end

function BackPackService:InsertMaterial (Player : Player, Material: Model)
    if not MaterialsService then 
		warn(`[{script.Name}]: Materials Service is not loaded yet!!!!!`)
		 return
	end
    local Detailed_mat = MaterialsService:GetMaterialByModel(Material)
    local insertedMaterial = {
        Strength = Detailed_mat.Strength,
        value = Detailed_mat.value,
        techName = Detailed_mat.techName
    }
    local r, _new = DataStoreService:InsertMaterial(Player, insertedMaterial)
    
    if not r then
        print(`Failed to insert material to BackPack`)
        return    
    end
    MaterialsService:DestroyMaterial(Material)
end

knit.OnStart():andThen(function()
    DataStoreService = knit.GetService("DataStoreService")
    MaterialsService = knit.GetService("MaterialsService")
end)

return BackPackService