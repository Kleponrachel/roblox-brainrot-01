-- Brainrot Big Top: keyboard controls. E buys the act in front of you,
-- F slaps a thief, L throws the Spotlight Lock over your ring. The keys
-- are bound with ContextActionService, so Roblox's own camera keys never
-- eat them: a handler that waits for gameProcessedEvent would never see
-- the arrow keys, and these bindings do not need it.

local ContextActionService = game:GetService("ContextActionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Controls = {}

-- E: buy the nearest parading act.
local function onBuy(_, state)
	if state == Enum.UserInputState.Begin then
		ReplicatedStorage.RequestBuy:FireServer()
	end
end

-- F: slap a thief in reach.
local function onSlap(_, state)
	if state == Enum.UserInputState.Begin then
		ReplicatedStorage.RequestSlap:FireServer()
	end
end

-- L: lock your ring with the spotlight.
local function onLock(_, state)
	if state == Enum.UserInputState.Begin then
		ReplicatedStorage.RequestLockBase:FireServer()
	end
end

-- Bind the three keys, each with a button a touch player can tap.
function Controls.bind()
	ContextActionService:BindAction("BuyBrainrot", onBuy, true, Enum.KeyCode.E)
	ContextActionService:SetTitle("BuyBrainrot", "BUY")
	ContextActionService:BindAction("SlapThief", onSlap, true, Enum.KeyCode.F)
	ContextActionService:SetTitle("SlapThief", "SLAP")
	ContextActionService:BindAction("LockRing", onLock, true, Enum.KeyCode.L)
	ContextActionService:SetTitle("LockRing", "LOCK")
end

return Controls
