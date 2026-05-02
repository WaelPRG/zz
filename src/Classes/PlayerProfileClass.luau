local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Signal = require(ReplicatedStorage.Packages.Signal)
local TableUtil = require(ReplicatedStorage.Packages.TableUtil)

local DataTemplates = require(ReplicatedStorage.Shared.DataTemplates)


local PlayerProfileClass = {}
PlayerProfileClass.__index = PlayerProfileClass

function PlayerProfileClass.new(_player : Player, profile)

    local self = setmetatable({}, PlayerProfileClass)

    self.sessionData = TableUtil.Copy(DataTemplates.SESSION_DATA_TEMPLATE, true) -- should be deep clone but since it only contains primitive values it's fine to do a shallow clone
    self.profile = profile
    self.Signals = {
        DataChanged = Signal.new(),
    }
   
    return self
end

function PlayerProfileClass:Init()
end

function PlayerProfileClass:GetData(Type : "profile" | "session", _DeepCopy : boolean?)
    -- WARNING: this will return reference!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    if Type == "profile" then
        if not self.profile or not self.profile.Data then return end
        return self.profile.Data
    elseif Type == "session" then
        if not self.sessionData then return end
        return self.sessionData
    end
    return nil
end

---------------------------------------- Updater methods-----------------------------

-- profiles data

function PlayerProfileClass:UpdateCoins(amount : number?)
    local profileData = self:GetData("profile")
    if not profileData then return end
    profileData.Coins += amount or 0
    return true, profileData.Coins
end

function PlayerProfileClass:InsertMaterial (Material)

    local profileData = self:GetData("profile")
    if not profileData then return end
    
    table.insert(profileData.BackPack, Material)
    
    return true, profileData.BackPack
end

function PlayerProfileClass:EquipMagnet (magnetName : string)
    local profileData = self:GetData("profile")
    if not profileData then return end

    profileData.EquippedMagnet = magnetName
    return true, profileData.EquippedMagnet

end

-- session data

function PlayerProfileClass:UpdateIsHolding (State : boolean)

    local SessionData = self:GetData(`session`)
    if not SessionData then return end

    SessionData.IsHolding = State
    return true, SessionData.IsHolding

end

---------------------------------------- Getters methods------------------------------

-- profiles data

function PlayerProfileClass:GetCoins()
    
    local profileData = TableUtil.Copy(self:GetData("profile"), true)

    if not profileData or not profileData.Coins then return end

    return profileData.Coins -- should not return reference, later I'll change it to return copy of the data
    -- TODO: change it to return copy of the data to avoid memory leak and also to make sure that the data is not being changed outside of the class methods

end

function PlayerProfileClass:GetEquippedMagnet()
    
    local profileData = TableUtil.Copy(self:GetData("profile"), true)

    if not profileData or not profileData.EquippedMagnet then return end

    return profileData.EquippedMagnet -- should not return reference, later I'll change it to return copy of the data
    -- TODO: change it to return copy of the data to avoid memory leak and also to make sure that the data is not being changed outside of the class methods

end

-- session data

function PlayerProfileClass:GetIsHolding ()

    local SessionData = self:GetData(`session`)
    if not SessionData then return end

    return SessionData.IsHolding

end

return PlayerProfileClass