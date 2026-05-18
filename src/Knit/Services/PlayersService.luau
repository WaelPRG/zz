local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local _CLasses = ServerStorage.Classes

local Types = require(ReplicatedStorage.Shared.Types)

local _Signal = require(ReplicatedStorage.Packages.Signal)
local knit: Types.knitServer = require(ReplicatedStorage.Packages.knit)

local DataStoreService
local MagnetService



local PlayersService = knit.CreateService ({
	Name = "PlayersService",
    Players = {},
})

function PlayersService:KnitInit ()
    Players.PlayerAdded:Connect(function(Player: Player)
        table.insert(self.Players, Player)
    end)
    Players.PlayerRemoving:Connect(function(Player: Player)
        table.remove(self.Players, table.find(self.Players, Player))
    end)
end

function PlayersService:KnitStart ()
    repeat
        task.wait()
    until DataStoreService

    DataStoreService.PlayerProfileLoaded:Connect(function(Player : Player)
        if not table.find(self.Players, Player) then 
           warn(`Player is not in Game anymore`)
            return
        end

        local equippedMagnet = DataStoreService:GetEquippedMagnet(Player) :: string

        DataStoreService.EquippedMagnetChanged:Connect(function(_Player : Player, newMagnet : string)
            equippedMagnet = newMagnet                
        end)

        local char = Player.Character or Player.CharacterAdded:Wait()
        
        if char then
            self:addCollisionGroup(char)
            MagnetService:EquipMagnet(Player, equippedMagnet)
        end

        Player.CharacterAdded:Connect(function(Char: Model)
            self:addCollisionGroup(Char)
            MagnetService:EquipMagnet(Player, equippedMagnet)
        end)

        Player.CharacterRemoving:Connect(function(_char: Model)
            MagnetService:DestroyMagnet(Player)
        end)
        
    end)

    DataStoreService.PlayerDataRemoving:Connect(function(Player : Player)
        MagnetService:DestroyMagnet(Player)
    end)

end

function PlayersService:addCollisionGroup (char : Model)
    for _, part in char:QueryDescendants("BasePart") do
        part.CollisionGroup = "Players"
    end
end


knit.OnStart():andThen(function()
    DataStoreService = knit.GetService("DataStoreService")
    MagnetService = knit.GetService("MagnetService")
end)

return PlayersService