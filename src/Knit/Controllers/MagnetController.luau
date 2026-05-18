--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local _Signal = require(ReplicatedStorage.Packages.Signal)
local knit = require(ReplicatedStorage.Packages.knit)
local Magnets = require(ReplicatedStorage.Shared.Refrences.Magnets)


local SPEED = 25

local MagnetService

local MagnetController = knit.CreateController({
	Name = "MagnetController",
})

function MagnetController:KnitInit ()
    self.attracter_conn = nil :: RBXScriptConnection?
end

function MagnetController:KnitStart ()
    MagnetService = knit.GetService("MagnetService")
    self:init()
end

function MagnetController:init ()
    MagnetService.attractMaterial:Connect(function(magnet, material)
        if self.attracter_conn then
            self.attracter_conn:Disconnect()
            self.attracter_conn = nil
        end
        self:attractMaterial(magnet, material)
    end)
end

function MagnetController:attractMaterial(magnet : Model, material)
    local magnetInfo = Magnets[magnet.Name]
    local magnetStrength = magnetInfo.Strength

    local materialModel = material.MaterialModel :: Model
    local materialStrength = material.Strength

    if not magnetStrength or not materialModel or not materialStrength then return end

    self.attracter_conn = RunService.PreRender:Connect(function(dt: number)
        if not magnet or not magnet.Parent or not materialModel or not materialModel.Parent or not materialModel.PrimaryPart then
            if self.attracter_conn then
                self.attracter_conn:Disconnect()
                self.attracter_conn = nil
            end
            return
        end
        
        local distance = (magnet:GetPivot().Position - materialModel:GetPivot().Position).Magnitude
        local force = (magnetStrength / math.max(3, (distance ^ 2))) / materialStrength
        local alpha = force * dt * SPEED * ((1/materialStrength) / 2) --0.75  0.25 0.33
        
        alpha = math.clamp(alpha, 0, 1)
        
        if alpha > 0 then
            local currentPivot = materialModel:GetPivot()
            local targetPivot = magnet:GetPivot()

            materialModel:PivotTo(currentPivot:Lerp(targetPivot, alpha))

        end

        if distance < 2 then
            materialModel.Parent = nil
            if self.attracter_conn then
                self.attracter_conn:Disconnect()
                self.attracter_conn = nil
            end
        end
        -- print(force, distance, magnetStrength, materialStrength)
        -- print(force * dir * POWER * dt)

    end)

end

return MagnetController
