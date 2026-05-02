local ReplicatedStorage = game:GetService("ReplicatedStorage")
local React = require(ReplicatedStorage.Packages.React)
local knit = require(ReplicatedStorage.Packages.knit)


local function a ()

    local state, setState = React.useState(0)

    React.useEffect(function ()

        local connection

        local PlayerProfileController = knit.GetController("PlayerProfileController")
        
        connection = PlayerProfileController.CoinsChanged:Connect(function(newValue)
            setState(newValue)
        end)
        
        return function ()
            connection:Disconnect ()
        end    
    
    end, {})

    return state

end


return a