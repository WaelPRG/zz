local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local React = require(ReplicatedStorage.Packages.React)
local Types = require(ReplicatedStorage.Shared.Types)
local knit : Types.knitClient = require(ReplicatedStorage.Packages.knit)

local useState = React.useState
local useBinding = React.useBinding

local InputController

knit.OnStart():andThen(function()
    InputController = knit.GetController("InputController")
end)

local function hook ()
    -- local State, Updater = useState("Idle")
    local progress, setprogress = useBinding(0)

    if InputController then
        React.useEffect(function()
            local conn = InputController.Signals.Charge:Connect(function(duration)
                local startTime = tick()
                local conn2
                conn2 = RunService.RenderStepped:Connect(function()

                    local elapsed = tick() - startTime
                    local alpha = math.clamp(elapsed / duration, 0, 1)
                    setprogress(alpha)

                    if alpha >= 1 then
                        conn2:Disconnect()
                    end

                end)
            end)
            return function ()
                conn:Disconnect()
            end
        end, {})
    end
end


return hook