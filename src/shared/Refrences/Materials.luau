

local Materials : {[string]: Metal} = {
    ["Rusty_Iron"] = {
		Name = "Rusty Iron",
		ValueRange = NumberRange.new(1,7),
		StrengthRange = NumberRange.new(1,10),
		materials = {
			"Rusty_Nail",
			"Old_Wrench",
			"Rusty Gear",
			"Old Screw",
			"Broken Chain Link",
			"Rusty Safety Pin",
		},
	},
}

export type Metal = {
    Name: string?,
    ValueRange: NumberRange,
    StrengthRange: NumberRange,
    materials: {string?} | any,
}

return Materials