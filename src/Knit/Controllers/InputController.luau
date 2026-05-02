local ContextActionService = game:GetService("ContextActionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local _localPlayer = Players.LocalPlayer

local Signal = require(ReplicatedStorage.Packages.Signal)
local knit = require(ReplicatedStorage.Packages.knit)
local PlayerMouseShared = require(ReplicatedStorage.Shared.PlayerMouseShared)

local HOLD_TIME_THRESHOLD = PlayerMouseShared.HOLD_TIME_THRESHOLD -- seconds
local HOLD_DEBOUNCE_TIME = PlayerMouseShared.HOLD_DEBOUNCE_TIME

local InputService

local InputController = knit.CreateController {
    Name = "InputController",
    Signals = {},
}

function InputController:KnitInit()
    self.State = "Up"
    self.IsHolding = false
    self.IsDebounce = false
    self.Signals.Charge = Signal.new()
    ContextActionService:BindAction("MouseAction", self.MouseAction, true, Enum.UserInputType.MouseButton1)
end

function InputController:KnitStart()
    InputService = knit.GetService("InputService")
end

function InputController.MouseAction (_actionName : string, inputState : Enum.UserInputState, _inputObject : InputObject)
    -- call server
    if not InputService then return end
    if inputState == Enum.UserInputState.Begin then
        InputService.RemoteEvent:Fire("MouseAction", "Down")
        InputController:_Down()
    elseif inputState == Enum.UserInputState.End then
        InputService.RemoteEvent:Fire("MouseAction", "Up")
        InputController:_Up()
    else
        warn(`Unexpected State {inputState}`)
    end
end

function InputController:_Down ()
    -- self.Signals.Charge:Fire()
    self.LastPressTime = tick()
    local LastPressTime = self.LastPressTime

    -- check if debounced            
    -- start calc and make sure it doesn't go UP til threshold then it's holding
    
    if self.IsDebounce == true then
        local conn
        conn = self.Signals.deBounceChanged:Once(function(State)
            if not self.IsDebounce or not State then
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

function InputController:_Up ()
    task.cancel(self.delay or nil)
    if self.IsHolding == true then
        self:_ChangeHolding(false)
        self:_Debounce()
        print(`end Holding`)        
        -- wait debounce time then undebounce
    end
end

function InputController:_Calc (LPT : number) --LPT aka LastPressTime 
    self.Signals.Charge:Fire(HOLD_TIME_THRESHOLD)
    self.delay = task.delay(HOLD_TIME_THRESHOLD, function ()
        print(`finished`)
        if LPT == self.LastPressTime then
            if self.State == "Down" then
                -- it's hold
                self:_ChangeHolding(true)
                print(`Start Holding`)
            end
        end
    end)
end

function InputController:_Debounce ()
    self.IsDebounce = true
    self.Signals.deBounceChanged:Fire(true)
    task.delay(HOLD_DEBOUNCE_TIME, function ()
        self.IsDebounce = false
        self.Signals.deBounceChanged:Fire(false)
    end)
end

return InputController
