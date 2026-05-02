local ReplicatedStorage = game:GetService("ReplicatedStorage")
local MagnetsFolder = ReplicatedStorage.Assets.Magnets


local Magnets : {[string] : Magnet} = {
    ["Magnet1"] = {
		Name = "Magnet1",
		Strength = 5,
		Range = 10,
		-- MaxMetal = 1,
		-- City = 1,
		-- Order = 1,
		Image = "",
		Price = 0,
		Path = MagnetsFolder.Magnet1 :: Model,
	},
}
export type Magnet = typeof(Magnets.Magnet1)

return Magnets