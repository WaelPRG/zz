local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local _CLasses = ServerStorage.Classes

local MagnetClass = require(ServerStorage.Classes.MagnetClass)
local Types = require(ReplicatedStorage.Shared.Types)

local _Signal = require(ReplicatedStorage.Packages.Signal)
local knit: Types.knitServer = require(ReplicatedStorage.Packages.knit)
local Magnets = require(ReplicatedStorage.Shared.Refrences.Magnets)

local callbacks = {}

local MaterialsService
local BackPackService

local MagnetService = knit.CreateService({
	Name = "MagnetService",
	connections = {},
	Magnets = {},
})

function MagnetService:KnitInit()
	table.insert(
		self.connections,
		Players.PlayerAdded:Connect(function(_Player: Player)
			-- self:CreateMagnet(Player)
		end)
	)
end

function MagnetService:KnitStart() 
	while task.wait(2) do
		for _, Magnet in self.Magnets do
			task.spawn(function()
				Magnet:Attract()
			end)
		end
	end
end

function MagnetService:EquipMagnet (Player : Player, magnetName : string)
	-- check if player aleardy equipped, if yes then remove it. create new
	print(magnetName)
	
	if self.Magnets[Player] then
		self:DestroyMagnet(Player)
	end
	
	local Magnet = Magnets[magnetName]
	assert(Magnet, `Magnet with name: {magnetName} is not avialable`)

	local newMagnet = MagnetClass.new(Player, Magnet, callbacks)
	self.Magnets[Player] = newMagnet
end

function MagnetService:CreateMagnet(Player: Player)

	local Magnet = Magnets.Magnet1
	local new = MagnetClass.new(Player, Magnet, callbacks)
	self.Magnets[Player] = new
end

function MagnetService:DestroyMagnet (Player : Player)
	local Magnet = self.Magnets[Player]

	if not Magnet then return end

	Magnet:Destroy()
	self.Magnets[Player] = nil

end

-- callbacks for objects
function callbacks.GetMaterialCallBack (Material : Model?)
	
	if not MaterialsService then 
		warn(`[{script.Name}]: Materials Service is not loaded yet!!!!!`)
		 return
	end
	return MaterialsService:GetMaterialByModel(Material)	
end

function callbacks.InsertMaterial (Player : Player, Material : Model)
	
	if not BackPackService then 
		warn(`[{script.Name}]: BackPackService is not loaded yet!!!!!`)
		return
	end
	BackPackService:InsertMaterial (Player, Material)
end


knit.OnStart():andThen(function()
	MaterialsService = knit.GetService("MaterialsService")
	BackPackService = knit.GetService("BackPackService")
end)

return MagnetService
