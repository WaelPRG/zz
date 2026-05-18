--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Signal = require(ReplicatedStorage.Packages.Signal)
local PlayerMouseShared = require(ReplicatedStorage.Shared.PlayerMouseShared)

local HOLD_TIME_THRESHOLD = PlayerMouseShared.HOLD_TIME_THRESHOLD
local HOLD_DEBOUNCE_TIME = PlayerMouseShared.HOLD_DEBOUNCE_TIME

local PlayerMouseClass = {}
PlayerMouseClass.__index = PlayerMouseClass

function PlayerMouseClass.new(Player: Player)
	local self = setmetatable({
		Signals = {
			DebounceChanged = Signal.new(),
			HoldingChanged = Signal.new(),
		},
	}, PlayerMouseClass)

	self.owner = Player
	self.State = "Up"
	self.IsHolding = false
	self.IsDebounce = false
	self.DebounceChanged_Conn = nil
	self.Hold_Threshold_Thread = nil :: any -- just for reference, not actually used for type checking

	return self
end

function PlayerMouseClass:ChangeState(newState: "Down" | "Up")
	-- if state is the same it's probably a hacky way but I have to check the logic against double firing and stuff like that
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

function PlayerMouseClass:_Down()
	-- check if debounced
	-- start calc and make sure it doesn't go UP til threshold then it's holding

	if self.IsDebounce == true then
		self.DebounceChanged_Conn = self.Signals.DebounceChanged:Once(function(_State)
			if not self.IsDebounce then
				self:_Charge()
			end
			-- self.DebounceChanged_Conn:Disconnect()
			self.DebounceChanged_Conn = nil
		end)

		return
	end
	self:_Charge()
end

function PlayerMouseClass:_Up()
    
	if self.Hold_Threshold_Thread then
		task.cancel(self.Hold_Threshold_Thread)
		self.Hold_Threshold_Thread = nil
		print(`Hold threshold Canceled`)
	end

	if self.DebounceChanged_Conn then
		self.DebounceChanged_Conn:Disconnect()
		self.DebounceChanged_Conn = nil
		print(`DebounceChanged_Conn before debounce changed cuz he up`)
	end

	if self.IsHolding == true then
		self:_ChangeHolding(false)
		self:_debounce()
		print(`end Holding`)
	end
end

function PlayerMouseClass:_Charge ()
	self.Hold_Threshold_Thread = task.delay(HOLD_TIME_THRESHOLD, function()
		-- it's hold
		self:_ChangeHolding(true)
		self.Hold_Threshold_Thread = nil
		print(`Start Holding`)
	end)
end

function PlayerMouseClass:_ChangeHolding(value: boolean)
	self.IsHolding = value
	self.Signals.HoldingChanged:Fire(value)
end

function PlayerMouseClass:_debounce()
	self.IsDebounce = true
	task.delay(HOLD_DEBOUNCE_TIME, function()
		self.IsDebounce = false
		self.Signals.DebounceChanged:Fire(false)
	end)
end

function PlayerMouseClass:Destroy()
	for _, v in self.Signals do
		v:Destroy()
	end
end

return PlayerMouseClass
