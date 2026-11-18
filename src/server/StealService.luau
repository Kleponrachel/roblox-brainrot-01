-- Brainrot Big Top: StealService is the threat that keeps the ring
-- honest. A player grabs a brainrot off another player's ring, carries it
-- home slowly, and the victim can slap them to make them drop it.
-- A locked ring cannot be stolen from at all.

local Config = require(game:GetService("ReplicatedStorage").Shared.Config)
local GameState = require(script.Parent.GameState)
local BaseManager = require(script.Parent.BaseManager)
local Remotes = require(script.Parent.Remotes)

local StealService = {}

-- Pick a brainrot up off a ring. The thief must be close, the ring must
-- be unlocked, and the thief must have empty hands and a free slot.
function StealService.trySteal(thief, victimState, brainrotUid)
	local thiefState = GameState.getState(thief)
	if not thiefState then
		return false, "No state for the thief."
	end
	if thiefState.carrying then
		return false, "Your hands are already full."
	end
	if #thiefState.owned >= thiefState.slots then
		return false, "Your ring is full. Buy a slot first."
	end
	if GameState.isBaseLocked(victimState) then
		return false, "That ring is under the Spotlight Lock."
	end
	local record = GameState.removeBrainrot(victimState, brainrotUid)
	if not record then
		return false, "That act is already gone."
	end
	BaseManager.removeBrainrotModel(record)
	thiefState.carrying = record
	local character = thief.Character
	if character then
		local humanoid = character:FindFirstChildOfClass("Humanoid")
		if humanoid then
			humanoid.WalkSpeed = 16 * Config.STEAL_SLOW
		end
	end
	Remotes.ShowToast:FireClient(thief, "Stolen! Dash home before they slap you.")
	Remotes.ShowToast:FireClient(victimState.player, "Someone stole your act! Slap them!")
	return true, "Stolen."
end

-- Put the carried brainrot down on the thief's own ring.
function StealService.deliverCarried(player)
	local state = GameState.getState(player)
	if not state or not state.carrying then
		return false, "You are not carrying anything."
	end
	local record = state.carrying
	state.carrying = nil
	if not GameState.ownBrainrot(state, record) then
		return false, "Your ring is full."
	end
	BaseManager.placeBrainrot(state, record)
	local character = player.Character
	if character then
		local humanoid = character:FindFirstChildOfClass("Humanoid")
		if humanoid then
			humanoid.WalkSpeed = 16
		end
	end
	state.stolenCount = state.stolenCount + 1
	Remotes.ShowToast:FireClient(player, "Delivered! The act is yours now.")
	return true, "Delivered."
end

-- Drop what is carried, where the thief stands: the brainrot is lost.
function StealService.dropCarried(player)
	local state = GameState.getState(player)
	if not state or not state.carrying then
		return false
	end
	state.carrying = nil
	local character = player.Character
	if character then
		local humanoid = character:FindFirstChildOfClass("Humanoid")
		if humanoid then
			humanoid.WalkSpeed = 16
		end
	end
	Remotes.ShowToast:FireClient(player, "You dropped the act!")
	return true
end

-- Slap: knock a nearby thief down and make them drop what they carry.
-- Five seconds between slaps, eight studs of reach.
function StealService.slap(player)
	local state = GameState.getState(player)
	if not state then
		return false, "No state."
	end
	local now = os.clock()
	if now - state.lastSlapAt < Config.SLAP_COOLDOWN then
		return false, "Your hand is still winding up."
	end
	state.lastSlapAt = now
	local myRoot = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
	if not myRoot then
		return false, "You have no body to slap with."
	end
	local hitAnyone = false
	for _, otherState in pairs(GameState.players) do
		if otherState.player ~= player and otherState.carrying then
			local otherRoot = otherState.player.Character and otherState.player.Character:FindFirstChild("HumanoidRootPart")
			if otherRoot and (otherRoot.Position - myRoot.Position).Magnitude <= Config.SLAP_RANGE then
				StealService.dropCarried(otherState.player)
				Remotes.ShowToast:FireClient(otherState.player, "Slapped! You dropped the act.")
				hitAnyone = true
			end
		end
	end
	if hitAnyone then
		return true, "Slap landed!"
	end
	return false, "Nobody to slap in reach."
end

return StealService
