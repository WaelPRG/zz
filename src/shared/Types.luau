local ReplicatedStorage = game:GetService("ReplicatedStorage")

local knit = ReplicatedStorage.Packages._Index["sleitnick_knit@1.7.0"]["knit"]


export type knitClient = typeof(require(knit.KnitClient))
export type knitServer = typeof(require(knit.KnitServer))


return {}
