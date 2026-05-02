local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Materials = ReplicatedStorage.Assets.Materials

export type Material = {
    [string] : {
        Name: string?,
        Path: Model,
    }
}

local Material : Material = {
    ["Rusty_Nail"] = {
        Name = "Rusty Nail",
        Path = Materials.Rusty_Nail,
    },
    ["Old_Wrench"] = {
        Name = "Old Wrench",
        Path = Materials.Old_Wrench,
    },
}


return Material