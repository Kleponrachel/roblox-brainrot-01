-- Brainrot Big Top: the Spotlight Lock. One button throws a ring of
-- spotlights over a player's ring for a minute, and while it burns no
-- thief can take a thing. Then it needs two minutes to cool down.

local Config = require(game:GetService("ReplicatedStorage").Shared.Config)
local GameState = require(script.Parent.GameState)
local Remotes = require(script.Parent.Remotes)

local BaseLockService = {}

-- Throw the lock over a player's ring.
function BaseLockService.lockBase(player)
	local state = GameState.getState(player)
	if not state then
		return false, "No state."
	end
	local now = os.time()
	if now < state.lockCooldownUntil then
		return false, "Spotlight is cooling down for " .. tostring(state.lockCooldownUntil - now) .. "s."
	end
	if GameState.isBaseLocked(state) then
		return false, "Your ring is already locked."
	end
	state.lockedUntil = now + Config.LOCK_DURATION
	state.lockCooldownUntil = now + Config.LOCK_DURATION + Config.LOCK_COOLDOWN
	Remotes.ShowToast:FireClient(player, "Spotlight Lock on! Your ring is safe for 60 seconds.")
	return true, "Locked."
end

-- How many seconds of lock are left on a ring, or 0.
function BaseLockService.lockRemaining(state)
	local left = state.lockedUntil - os.time()
	if left < 0 then
		return 0
	end
	return left
end

-- How many seconds until the lock can be thrown again, or 0.
function BaseLockService.cooldownRemaining(state)
	local left = state.lockCooldownUntil - os.time()
	if left < 0 then
		return 0
	end
	return left
end

return BaseLockService
