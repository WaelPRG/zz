local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local CLasses = ServerStorage.Classes

local Signal = require(ReplicatedStorage.Packages.Signal)
local knit = require(ReplicatedStorage.Packages.knit)
local profilestore = require(ReplicatedStorage.Packages.profilestore)

local DataTemplates = require(ReplicatedStorage.Shared.DataTemplates)
local PlayerProfileClass = require(CLasses.PlayerProfileClass)

local _Local = {}


local DataStoreService = knit.CreateService {
    Name = "DataStoreService",
    Client = {
        Coins = knit.CreateProperty(DataTemplates.PROFILE_TEMPLATE.Coins),
    },
}


-- Public methods for the service
function DataStoreService:KnitInit()
    print(`Knit initliazed Started`)

    -- properties
    self.PROFILE_TEMPLATE = DataTemplates.PROFILE_TEMPLATE
    self.profileStore = profilestore.New("PlayersData", self.PROFILE_TEMPLATE)
    self.profiles = {} 

    -- Events
    self.PlayerProfileLoaded = Signal.new()
    self.PlayerDataRemoving = Signal.new()
    self.PlayerCoinsChanged = Signal.new()
    self.PlayerBackPackInserted = Signal.new()
    self.EquippedMagnetChanged = Signal.new()
    self.IsHoldingChanged = Signal.new()


    -- Client events and properties

    -- Properties

    -- connections


    for _i, player : Player in Players:GetPlayers() do
        task.spawn(self._PlayerAdded, self, player)
    end

    Players.PlayerAdded:Connect(function(player)
        self:_PlayerAdded(player)
    end)
    
    Players.PlayerRemoving:Connect(function(player)
        self:_PlayerRemoving(player)
    end)

    game:BindToClose(function()
        for _i, player : Player in Players:GetPlayers() do
            task.spawn(self._PlayerRemoving, self, player)
        end
    end)

    self.PlayerProfileLoaded:Connect(function(player : Player)
        -- TODO: I'm thinking of making this to init properties then fire a playerinitialized event == probably i'll do it later when i need to add more properties 
        self:_SetForCoins(player)
    end)

    self.PlayerCoinsChanged:Connect(function(player : Player, _newValue : number)
        self:_SetForCoins(player)
    end)
    
end


function DataStoreService:KnitStart()
end

function DataStoreService:GetPlayerProfile(player : Player)
    
    if not self:IsPlayerProfileLoaded(player) then return end
    local profile = self.profiles[player]
    if profile then
        return profile
    else
        warn(`Profile not found for {player.DisplayName}`)
        return 
    end
end

function DataStoreService:GetPlayerData(player : Player, Type : "profile" | "session")

    local profile = self:GetPlayerProfile(player)
    if not profile then return end

    local data = profile:GetData(Type)
    if not data then return end
   
    print(data)
    return data

end

function DataStoreService:IsPlayerProfileLoaded(player : Player)
    return self.profiles[player] ~= nil
end

-- Updaters methods for player data, you can add more of these for different data types

function DataStoreService:UpdateCoins(player : Player, amount : number?)
    local profile = self:GetPlayerProfile(player)
    if profile then
        local success, newValue : number | any = profile:UpdateCoins(amount or 0)
        if success then
            self.PlayerCoinsChanged:Fire(player, newValue)
        end
    end
end    

function DataStoreService:EquipMagnet (Player : Player, magnetName : string)
    local profile = self:GetPlayerProfile(Player)
    if not profile then return end

    local r, new = profile:EquipMagnet (magnetName)

    if not r then
        warn(`something wrong happened`)
        return
    end
    
    self.EquippedMagnetChanged:Fire(Player, new)
    return true, new

end

function DataStoreService:InsertMaterial (Player : Player, Material)

    local profile = self:GetPlayerProfile(Player)
    if not profile then return end

    local r, new = profile:InsertMaterial (Material)
    if not r then
        warn(`faield to insert to backpack`)
        return
    end
    
    self.PlayerBackPackInserted:Fire(Player, new)
    return true, new
end

function DataStoreService:UpdateIsHolding (Player : Player, State : boolean)

    local profile = self:GetPlayerProfile(Player)
    if not profile then return end

    local r, new = profile:UpdateIsHolding(State)

    if not r then
        warn(`something wrong happened`)
        return
    end
    
    self.IsHoldingChanged:Fire(Player, new)
    return true, new

end

-- Getters methods for player data, you can add more of these for different data types

function DataStoreService:GetCoins(player : Player)
    local profile = self:GetPlayerProfile(player)
    if not profile then return end

    return profile:GetCoins()

end

function DataStoreService:GetEquippedMagnet(player : Player)
    local profile = self:GetPlayerProfile(player)
    if not profile then return end

    return profile:GetEquippedMagnet()

end

function DataStoreService:GetIsHolding (Player : Player)

    local profile = self:GetPlayerProfile(Player)
    if not profile then return end

    return profile:GetIsHolding()
end

-- Private methods for the service start with perfix _ (it's can be used outside the service but it's not recommended to use it)

function DataStoreService:_PlayerAdded(player : Player)
    -- هذي الوظيفة خاصة فقط ب profilestore عشان تفتح ال session الخاصة باللاعب ثم بعد ذلك تطلق حدث انه كل شي اكتمل
    local profile = self.profileStore:StartSessionAsync(`{player.UserId}`, {
        Cancel = function()
            return player.Parent ~= Players
         end,
    })
    if profile ~= nil then

        profile:AddUserId(player.UserId)
        profile:Reconcile()

        profile.OnSessionEnd:Connect(function()

            self.profiles[player] = nil
            self.PlayerDataRemoving:Fire(player)
            player:Kick(`Profile session end - Please rejoin`)

        end)
       
        if player.Parent == Players then

            -- successfully loaded the profile,

            local newPlayerProfile = PlayerProfileClass.new(player, profile)
            self.profiles[player] = newPlayerProfile
            print(`Profile loaded for {player.DisplayName}!`)
            self.PlayerProfileLoaded:Fire(player)

        else
            profile:EndSession()
        end
    else
        player:Kick(`Profile load fail - Please rejoin`)
    end
end

function DataStoreService:_PlayerRemoving(player : Player)

    if player.Parent ~= Players then return end -- to make sure that the player is still in the game and not already removed

    local profile = self:GetPlayerProfile(player)

    if not profile or not profile.profile then return end

    profile.profile:EndSession()
    print(`Profile saved for {player.DisplayName}!`)

end

function DataStoreService:_SetForCoins(player : Player)
    -- this is so can set in Start and when coins changed
     local Coins = self:GetCoins(player)
     if not Coins then return end
    self.Client.Coins:SetFor(player, Coins)    
end

return DataStoreService