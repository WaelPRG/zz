local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Types = require(ReplicatedStorage.Shared.Types)

local React = require(ReplicatedStorage.Packages.React)
local knit : Types.knitClient = require(ReplicatedStorage.Packages.knit)
local ripple = require(ReplicatedStorage.Packages.ripple)
local PlayerMouseShared = require(ReplicatedStorage.Shared.PlayerMouseShared)

local useState = React.useState
local useBinding = React.useBinding
local useEffect = React.useEffect

local HOLD_TIME_THRESHOLD = PlayerMouseShared.HOLD_TIME_THRESHOLD
local HOLD_DEBOUNCE_TIME = PlayerMouseShared.HOLD_DEBOUNCE_TIME


local Progress = ripple.createTween(0, {
    easing = "linear",
})

local function hook ()
    
    local isReady, updateIsReady = useState(false)
    local visible, updateVisible = useState(false)
    local action, updateAction = useState("Idle") -- Idle, Charging, Debounced, Holding

    local progress, setprogress = useBinding(0)

    useEffect(function()
        knit.OnStart():andThen(function()
            updateIsReady(true)
        end)
        return
    end, {})

    useEffect(function()

        if not isReady then return end
        
        local InputController = knit.GetController("InputController")

        local conn = InputController.Signals.Charge:Connect(function(_duration)
            Progress:setGoal(1, {duration = HOLD_TIME_THRESHOLD})
            Progress:setPosition(0)
            Progress:start()
            updateAction("Charging")
        end)

        local holdingChanged_conn = InputController.Signals.holdingChanged:Connect(function(value : boolean)
            if value == true then
                updateAction("Holding")
            end
        end)

        local DebounceChanged_conn = InputController.Signals.DebounceChanged:Connect(function(isDebounced : boolean)
            if isDebounced == true then
                -- make progress back
                Progress:setGoal(0, {duration = HOLD_DEBOUNCE_TIME})
                Progress:start()
                updateAction("Debounced")
            end
        end)

        local MouseUpped_conn = InputController.Signals.MouseUpped:Connect(function()
            if InputController:isDebounce() == false then
                Progress:setGoal(0)
                Progress:start()
            end
        end)
        
        local onChange_conn = Progress:onChange(function(value: number, _deltaTime: number)
            setprogress(value)
            if value > 0 then
                if visible then return end
                updateVisible(true)
            else
                if visible == false then return end
                updateVisible(false)
                updateAction("Idle")
            end
        end)

        return function ()
            conn:Disconnect()
            DebounceChanged_conn:Disconnect()
            MouseUpped_conn:Disconnect()
            holdingChanged_conn:Disconnect()
            onChange_conn()
        end
    end, {isReady, visible, action})

    return {
        Progress = progress,
        Visible = visible,
        Action = action,
    }
end


return hook