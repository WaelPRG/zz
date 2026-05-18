----!strict
local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Signal = require(ReplicatedStorage.Packages.Signal)
local Magnets = require(ReplicatedStorage.Shared.Refrences.Magnets)

local SPEED = 25


local MagnetClass = {}
MagnetClass.__index = MagnetClass

export type Magnet = typeof(setmetatable(
    {} :: {
        Owner : Player,
        Name : string,
        Strength : number,
        Range : number,
        MagnetModel : Model,
        CallBacks : {
            () -> ()
        },
        debounce : boolean,
        attracting_thread : thread?,
        runServiceHeart_conn : RBXScriptConnection?,
        Signals : {
            [string] : typeof(Signal.new()),
            insertMaterial : typeof(Signal.new()),
            attractMaterial : typeof(Signal.new()),
        },
    },
    MagnetClass
))


function MagnetClass.new (Player : Player?, Magnet : Magnets.Magnet, callbacks : {() -> ()}) : Magnet

    local self = setmetatable({}, MagnetClass)

    self.Owner = Player
    self.Name = Magnet.Name
    self.Strength = Magnet.Strength
    self.Range = Magnet.Range
    self.MagnetModel = Magnet.Path:Clone()
    self.CallBacks = callbacks
    self.debounce = false
    self.attracting_thread = nil
    self.runServiceHeart_conn = nil
    self.Signals = {
        insertMaterial = Signal.new(),
        attractMaterial = Signal.new()
    }
    
    self:CreateModel()
    
    return self :: any
end

function MagnetClass:CreateModel ()
    assert(self.Owner, `Owner is not found`)
    local char = self.Owner.Character or self.Owner.CharacterAdded:Wait()
    assert(char, `Character is not found`)

    local RightHand  = char:FindFirstChild("RightHand") :: Part
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

end

function MagnetClass.Destroy (self : Magnet)
    self.MagnetModel:Destroy()
    self.Motor6D:Destroy()

    for _, signal in self.Signals do
        if signal.Destroy then
            print(signal)
            signal:Destroy()    
        end    
    end

end

function MagnetClass:startAttracting ()
    self.attracting_thread = task.spawn(function()
        while true do
            task.wait(2)
            self:_Attract()
        end
    end)
end

function MagnetClass:stopAttracting ()
    if self.attracting_thread then
        task.cancel(self.attracting_thread)
    end
    -- لو في runservice شغال وقفه
end

function MagnetClass:_Attract ()
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
    local choosed = self:_chooseStrongest(detailedMaterials) :: Model
    if not choosed then return end

    -- اول شي جذب فيزيائي وعند النهاية تشتغل هذا الاشارة
    self:_pullModel(detailedMaterials[choosed].detail)

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
        if force <= 0 then continue end

        if force > lastForce then
            lastForce = force
            choosed = Material
        end
    end
    return choosed
end

function MagnetClass._pullModel (self : Magnet, Material)

    if self.runServiceHeart_conn then
        self.runServiceHeart_conn:Disconnect()
        self.runServiceHeart_conn = nil    
    end

    local materialModel : Model = Material.MaterialModel
    assert(materialModel, `is not found`)

    local magnet = self.MagnetModel
    assert(magnet, `is not found`)

   
    local magnetStrength = self.Strength
    assert(magnetStrength, `is not found`)

    local materialStrength = Material.Strength
    assert(materialStrength, `is not found`)

    self.runServiceHeart_conn = RunService.Heartbeat:Connect(function(dt: number)

        local distance = (magnet:GetPivot().Position - materialModel:GetPivot().Position).Magnitude
        local force = (magnetStrength / math.max(3, (distance ^ 2))) / materialStrength
        local alpha = force * dt * SPEED * ((1/materialStrength) / 2)
        
        alpha = math.clamp(alpha, 0, 1)
        
        if alpha > 0 then
            local currentPivot = materialModel:GetPivot()
            local targetPivot = magnet:GetPivot()

            materialModel:PivotTo(currentPivot:Lerp(targetPivot, alpha))

        end

        if distance < 2 then
            self.Signals.insertMaterial:Fire(materialModel)
            if self.runServiceHeart_conn then
                self.runServiceHeart_conn:Disconnect()
                self.runServiceHeart_conn = nil
            end
        end
    end)
end

return MagnetClass