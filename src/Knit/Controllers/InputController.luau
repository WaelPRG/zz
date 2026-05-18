--!strict
local ContextActionService = game:GetService("ContextActionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Signal = require(ReplicatedStorage.Packages.Signal)
local knit = require(ReplicatedStorage.Packages.knit)
local PlayerMouseShared = require(ReplicatedStorage.Shared.PlayerMouseShared)

local HOLD_TIME_THRESHOLD = PlayerMouseShared.HOLD_TIME_THRESHOLD -- seconds
local HOLD_DEBOUNCE_TIME = PlayerMouseShared.HOLD_DEBOUNCE_TIME

local InputService

local InputController = knit.CreateController({
	Name = "InputController",
	Signals = {},
})

function InputController:KnitInit ()

	self.State = "Up"
	self.IsHolding = false
	self.IsDebounce = false
	self.DebounceChanged_Conn = nil
	self.Hold_Threshold_Thread = nil

	-- signals
	self.Signals.Charge = Signal.new()
	self.Signals.DebounceChanged = Signal.new()
	self.Signals.MouseDowned = Signal.new()
	self.Signals.MouseUpped = Signal.new()
	self.Signals.holdingChanged = Signal.new()

	ContextActionService:BindAction("MouseAction", self.MouseAction, true, Enum.UserInputType.MouseButton1)

end

function InputController:KnitStart ()
	InputService = knit.GetService("InputService")
end

function InputController:GetState ()
	return self.State
end

function InputController:isDown ()
	return self.State == "Down"
end

function InputController:isUp ()
	return self.State == "Up"
end

function InputController:isDebounce ()
	return self.IsDebounce
end

function InputController:isHolding ()
	return self.IsHolding
end

function InputController.MouseAction(_actionName: string, inputState: Enum.UserInputState, _inputObject: InputObject)
	-- call server
	if not InputService then
		return
	end
	if inputState == Enum.UserInputState.Begin then
		InputService.RemoteEvent:Fire("MouseAction", "Down")
		InputController:_Down()
	elseif inputState == Enum.UserInputState.End then
		InputService.RemoteEvent:Fire("MouseAction", "Up")
		InputController:_Up()
	else
		warn(`Unexpected State {inputState}`)
	end
	return Enum.ContextActionResult.Pass
end

function InputController:_Down()

	self.State = "Down"
	self.Signals.MouseDowned:Fire()

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

function InputController:_Up()

	self.State = "Up"

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
		self:_Debounce()
		print(`end Holding`)
	end
	self.Signals.MouseUpped:Fire()

end

function InputController:_Charge ()

	self.Signals.Charge:Fire(HOLD_TIME_THRESHOLD)

	self.Hold_Threshold_Thread = task.delay(HOLD_TIME_THRESHOLD, function()
		-- it's hold
		self:_ChangeHolding(true)
		self.Hold_Threshold_Thread = nil
		print(`Start Holding`)
	end)
end

function InputController:_ChangeHolding(value: boolean)
	self.IsHolding = value
	self.Signals.holdingChanged:Fire(value)
end

function InputController:_Debounce()
	
	self:_ChangeDebounceState(true)

	task.delay(HOLD_DEBOUNCE_TIME, function()
		self:_ChangeDebounceState(false)
	end)
end

function InputController:_ChangeDebounceState(value: boolean)
	self.IsDebounce = value
	self.Signals.DebounceChanged:Fire(value)
end

return InputController
