local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Signal = require(ReplicatedStorage.Packages.Signal)
local PlayerMouseShared = require(ReplicatedStorage.Shared.PlayerMouseShared)

local HOLD_TIME_THRESHOLD = PlayerMouseShared.HOLD_TIME_THRESHOLD -- seconds
local HOLD_DEBOUNCE_TIME = PlayerMouseShared.HOLD_DEBOUNCE_TIME

local PlayerMouseClass = {}
PlayerMouseClass.__index = PlayerMouseClass

function PlayerMouseClass.new (Player : Player)
    local self = setmetatable({
        LastPressTime = 0,
        Signals = {
            deBounceChanged = Signal.new(),
            HoldingChanged = Signal.new(),
        },
    }, PlayerMouseClass)

    self.owner = Player
    self.State = "Up"
    self.IsHolding = false
    self.IsDebounce = false

    return self    
end

function PlayerMouseClass:ChangeState (newState : "Down" | "Up")
    self.State = newState
    print(`-------------------------------------------------`)
    if newState == "Down" then
        self:_Down()
    elseif newState == "Up" then
        self:_Up()
    else
        warn(`Unexpected State {newState}`)
    end
end

function PlayerMouseClass:_Down ()

    self.LastPressTime = tick()
    local LastPressTime = self.LastPressTime

    -- check if debounced            
    -- start calc and make sure it doesn't go UP til threshold then it's holding
    
    if self.IsDebounce == true then
        local conn
        conn = self.Signals.deBounceChanged:Once(function(_State)
            if not self.IsDebounce then
                if self.State == "Down" then
                    self:_Calc(LastPressTime)
                else
                    print(`bro he gave up and up it`)
                end
            end
            conn:Disconnect()
        end)
        return
    end
    self:_Calc(LastPressTime)
end

function PlayerMouseClass:_Up ()
    print(self.delay)
    task.cancel(self.delay)
    if self.IsHolding == true then
        self:_ChangeHolding(false)
        self.IsDebounce = true
        print(`end Holding`)
        
        -- wait debounce time then undebounce
        
        task.delay(HOLD_DEBOUNCE_TIME, function ()
            self.IsDebounce = false
            self.Signals.deBounceChanged:Fire(false)
        end)
    end
end

function PlayerMouseClass:_Calc (LPT : number) --LPT aka LastPressTime 
    self.delay = task.delay(HOLD_TIME_THRESHOLD, function ()
        if LPT == self.LastPressTime then
            if self.State == "Down" then
                -- it's hold
                self:_ChangeHolding(true)
                print(`Start Holding`)
            end
        end
    end)
end

function PlayerMouseClass:_ChangeHolding (value : boolean)
    self.IsHolding = value
    self.Signals.HoldingChanged:Fire(value)
end

function PlayerMouseClass:Destroy()
    for _, v in self.Signals do
        v:Destroy()    
    end
end

return PlayerMouseClass