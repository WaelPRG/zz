local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Material = require(ReplicatedStorage.Shared.Refrences.Material)
local MaterialClass = {}
MaterialClass.__index = MaterialClass

local SPAWN_HEIGHT = 50

function MaterialClass.new (Name: string, pos: Vector3, Strength : number, Value : number)
    local self = setmetatable({}, MaterialClass)

    local Clone = Material[Name].Path:Clone()
    
    self.techName = Name
    self.Name = Material[Name].Name
    self.MaterialModel = Clone
    self.Strength = Strength
    self.value = Value

    Clone.Parent = workspace
    Clone:PivotTo(CFrame.new(pos + Vector3.new(0, SPAWN_HEIGHT, 0)))

    return self
end
    
function MaterialClass:Destroy ()
    self.MaterialModel:Destroy()    
end

return MaterialClass