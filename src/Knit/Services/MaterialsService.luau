local _Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local _CLasses = ServerStorage.Classes
local Cities : Folder = workspace.Cities

local Signal = require(ReplicatedStorage.Packages.Signal)
local MaterialClass = require(ServerStorage.Classes.MaterialClass)
local Types = require(ReplicatedStorage.Shared.Types)

local knit: Types.knitServer = require(ReplicatedStorage.Packages.knit)
local _Material = require(ReplicatedStorage.Shared.Refrences.Material)
local Materials = require(ReplicatedStorage.Shared.Refrences.Materials)
local Metals = require(ReplicatedStorage.Shared.Refrences.Metals)

local MARGIN = 5


local MaterialsService = knit.CreateService {
    Name = "MaterialsService",

}


function MaterialsService:KnitInit ()
    self.Materials = {}
    self.MaterialAdded = Signal.new()
    self.MaterialRemoving = Signal.new()
    
end

function MaterialsService:KnitStart ()

    for _, Part : BasePart | any in Cities:GetChildren() do
        task.spawn(function()
            while true do
                task.wait(math.random(1, 9)) 
                
                local Metalchoosed : Materials.Metal, Materialchoosed = self:_ChooseMaterial()
                
                local Strength, Value = self:_chooseDetails (Metalchoosed)

                local x , z = self:_Pos(Part)
                
                local newVec = Vector3.new(x, Part.Position.Y, z)
                local newMaterial = MaterialClass.new(Materialchoosed, newVec, Strength, Value)
                
                table.insert(self.Materials, newMaterial)

                task.delay(math.random(10, 60), function()
                    if not table.find(self.Materials, newMaterial) then return end
                    self:DestroyMaterial(newMaterial.MaterialModel)
                end)
                   
            end
        end)
    end
end

function MaterialsService:GetMaterialByModel (model : Model)
    for _, material in self.Materials do
        if material.MaterialModel == model then
            return material
        end
    end
    return
end


function MaterialsService:DestroyMaterial (Material : Model)
    assert(Material, `Material object is not found`)
    local material = self:GetMaterialByModel(Material)
    material:Destroy()
    table.remove(self.Materials, table.find(self.Materials, material))
end


-- Private Functions

function MaterialsService:_ChooseMaterial ()
    local random = math.random(1,1)
    local choosed = Metals[random]
    
    local secrandom = math.random(1, 2)
    local secChoosed = Materials[choosed].materials[secrandom]
    
    return Materials[choosed], secChoosed
end

function MaterialsService:_Pos(Part : Part)

    local minRange = Part.Position - (Part.Size/2) + (Vector3.one * MARGIN) 
    local maxRange = Part.Position + (Part.Size/2) - (Vector3.one * MARGIN)

    local random = Random.new()
    local x, z = random:NextNumber(minRange.X, maxRange.X), random:NextNumber(minRange.Z, maxRange.Z)

    return x, z
end

function MaterialsService:_chooseDetails (metal : Materials.Metal) : (number, number)

    local Strength = Random.new():NextInteger(metal.StrengthRange.Min, metal.StrengthRange.Max)
    local Value = Random.new():NextInteger(metal.ValueRange.Min, metal.ValueRange.Max)

    return Strength, Value
end


return MaterialsService