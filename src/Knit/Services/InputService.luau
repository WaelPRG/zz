local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local PlayerMouseClass = require(ServerStorage.Classes.PlayerMouseClass)
local _Signal = require(ReplicatedStorage.Packages.Signal)
local Types = require(ReplicatedStorage.Shared.Types)
local knit : Types.knitServer = require(ReplicatedStorage.Packages.knit)


-- local HOLD_TIME_THRESHOLD = 0.35 -- seconds
-- local HOLD_DEBOUNCE_TIME = 1.75

local DataStoreService

local InputService = knit.CreateService {
    Name = "InputService",
    Client = {
        RemoteEvent = knit.CreateSignal(),
    },
    Players = {}
}

function InputService:KnitInit ()


    InputService.Client.RemoteEvent:Connect(function(Player : Player, Name : string, ...)
        -- print(`{Player.Name}`, ...)
        if Name == "MouseAction" then
            self:MouseAction(Player, ...)
        else
            warn(`Unexpected action {Name}`)
        end
    end)
end

function InputService:KnitStart ()

    repeat 
        task.wait()
    until DataStoreService    

    DataStoreService.PlayerProfileLoaded:Connect(function(Player : Player)
        self:CreateInput(Player)
    end)

    DataStoreService.PlayerDataRemoving:Connect(function(Player : Player)
       self:RemoveInput(Player)       
    end)

end

function InputService:CreateInput (Player : Player)
    local newMouse = PlayerMouseClass.new(Player)
    self.Players[Player] = newMouse
    self:InitInput (Player)
end

function InputService:RemoveInput (Player : Player)
    if not  self.Players[Player] then return end

    self.Players[Player]:Destroy()
    self.Players[Player] = nil
end

function InputService:InitInput (Player : Player)

    self.Players[Player].Signals.HoldingChanged:Connect(function(State: boolean)
        DataStoreService:UpdateIsHolding(Player, State)
        print(Player, State)
    end)

end

function InputService:MouseAction (Player : Player, State : string)
    -- print(Player, State)
    if not self.Players[Player] then return end
    if State == "Down" then
        self.Players[Player]:ChangeState("Down")
    elseif State == "Up" then
        self.Players[Player]:ChangeState("Up")
    else
        warn(`Unexpected State {State}`)
    end
end

knit.OnStart():andThen(function()
    DataStoreService = knit.GetService("DataStoreService")
end)

return InputService

