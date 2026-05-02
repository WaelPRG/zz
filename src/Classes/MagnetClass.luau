local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Magnets = require(ReplicatedStorage.Shared.Refrences.Magnets)

local MagnetClass = {}
MagnetClass.__index = MagnetClass


function MagnetClass.new (Player : Player?, Magnet : Magnets.Magnet, callbacks : {() -> ()})

    local self = setmetatable({}, MagnetClass)

    self.Owner = Player
    self.Name = Magnet.Name
    self.Strength = Magnet.Strength
    self.Range = Magnet.Range
    self.MagnetModel = Magnet.Path:Clone()
    self.CallBacks = callbacks
    self.debounce = false
    
    self:CreateModel()
    
    return self
end

function MagnetClass:CreateModel ()
    local char = self.Owner.Character or self.Owner.CharacterAdded:Wait()
    local RightHand : Part? = char:FindFirstChild("RightHand")
    if not RightHand then return end

    local Handle : Part? = self.MagnetModel:FindFirstChild("Handle")

    if not Handle then return end

    local Motor6D = Instance.new("Motor6D")
    Motor6D.Name = "MagnetMotor6D"
    Motor6D.Part0 = RightHand
    Motor6D.Part1 = Handle
    Motor6D.Parent = RightHand
    self.Motor6D = Motor6D
    self.MagnetModel.Parent = char

    self:_GetParams()
    self:Attract()

end

function MagnetClass:Destroy ()
    self.MagnetModel:Destroy()
    self.Motor6D:Destroy()
end

function MagnetClass:Attract ()
    local Cframe : CFrame, _size : Vector3 =  self.MagnetModel:GetBoundingBox()

    local Params = self:_GetParams()

    local OverlapParams = OverlapParams.new()
    OverlapParams.FilterType = Enum.RaycastFilterType.Include
    OverlapParams.FilterDescendantsInstances = Params
    
    local Parts = workspace:GetPartBoundsInRadius(Cframe.Position, self.Range, OverlapParams)
    if #Parts <= 0 then return end
    
    local FilteredParts = self:_FilterParts(Parts)
    if #FilteredParts <= 0 then return end
    
    -- local x = self:_chooseToPull(FilteredParts)
    -- print(x, self.CallBacks.GetMaterial(x))

    local detailedMaterials = {}
    -- check if backpack enoguh تاكد انه مساحة الشنطة كافية
    -- تاكد انه الشنطة مناسبة لنوع المعدن والمغناطيس كذلك
    -- احسب القوة 
    -- اسحب الاقوى فالاقوى وبينهم debounce 
    -- 
    for _, Material in FilteredParts do
        local Material_Detail = self.CallBacks.GetMaterialCallBack(Material)
        if not Material_Detail then continue end
        detailedMaterials[Material] = {
            detail = Material_Detail,
            -- force = self:_Formula(Material_Detail)
        }
    end
    local choosed = self:_chooseStrongest(detailedMaterials)

    self.CallBacks.InsertMaterial (self.Owner, choosed)

    -- at end of the method
    detailedMaterials = {}
    table.clear(detailedMaterials)
end

function MagnetClass:_GetParams ()
    local Params = {}
    local Tagged = CollectionService:GetTagged("Material")
    for _, v in Tagged do
        table.insert(Params, v)    
    end
    return Params
end

function MagnetClass:_FilterParts (Parts : {BasePart})

    local Filtered : {Model?} = {}

    for _, Part in Parts do
        
        local Model = Part:FindFirstAncestorWhichIsA("Model")
        
        if not Model then return end
        
        if table.find(Filtered, Model) then
            -- print(`already in`, Part, Filtered, Model)
            continue
        end

        if Model:HasTag("Material") then
            table.insert(Filtered, Model)
            -- print(Filtered, Part, Model)
        end
        --[[ 
        for _, model in Filtered do
        --     if Part:IsDescendantOf(model) then
        --     end

            
        -- end
        ]]

    end
    return Filtered
end

function MagnetClass:_Formula (any)
    
    local Distance : number = (self.MagnetModel:GetPivot().Position - any.MaterialModel:GetPivot().Position).Magnitude
    
    local materialStrength : number = any.Strength
    local magnetStrength : number = self.Strength

    local Pull = magnetStrength * math.sign(magnetStrength - materialStrength) / math.max((Distance ^ 2), 2)

    local Force = Pull / materialStrength
    -- print(`Distance:{Distance}, materialStrength: {materialStrength}, magnetStrength: {magnetStrength}, Pull: {Pull}, F: {Force}`)
    return Force

end

function MagnetClass:_chooseToPull (FilteredParts)
    local lastChoosed = nil
    local lastForce = -999999
    for _,v in FilteredParts do
        -- debounce
        local Material = self.CallBacks.GetMaterial(v)
        local force = self:_Formula(Material)
        print(Material, force)
        if not lastChoosed then
            lastChoosed = v
            lastForce = force
        else
            if force <= lastForce then
                continue
            end
            lastChoosed = v
            lastForce = force
        end
    end
    return lastChoosed
end        

function MagnetClass:_chooseStrongest (detailedMaterials : {[Model]: {}}) : Model
    local choosed
    local lastForce = -9999999

    for Material : Model, Detail in detailedMaterials do

        local force : number = self:_Formula(Detail.detail)
        if force > lastForce then
            lastForce = force
            choosed = Material
        end
    end
    return choosed
end

return MagnetClass