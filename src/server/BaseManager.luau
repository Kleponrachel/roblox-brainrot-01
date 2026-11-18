-- Brainrot Big Top: BaseManager hands each player a circus ring of their
-- own, places bought brainrots on its slots, and sells extra slots.
-- The four rings sit in the island's corners, and their positions here
-- match the pads built in default.project.json.

local Config = require(game:GetService("ReplicatedStorage").Shared.Config)
local BrainrotFactory = require(script.Parent.BrainrotFactory)

local BaseManager = {}
BaseManager.bases = {}

-- The four rings: centre, colour, and the six slot offsets around it.
BaseManager.PLOTS = {
	{ center = Vector3.new(60, 0, 60), color = Color3.fromRGB(255, 90, 90) },
	{ center = Vector3.new(-60, 0, 60), color = Color3.fromRGB(80, 160, 255) },
	{ center = Vector3.new(60, 0, -60), color = Color3.fromRGB(255, 210, 40) },
	{ center = Vector3.new(-60, 0, -60), color = Color3.fromRGB(120, 220, 90) },
}

BaseManager.SLOT_OFFSETS = {
	Vector3.new(-6, 0, -6),
	Vector3.new(0, 0, -6),
	Vector3.new(6, 0, -6),
	Vector3.new(-6, 0, 6),
	Vector3.new(0, 0, 6),
	Vector3.new(6, 0, 6),
	Vector3.new(-9, 0, 0),
	Vector3.new(9, 0, 0),
	Vector3.new(0, 0, -9),
	Vector3.new(0, 0, 9),
}

-- Give a player the first free ring. Returns its index, or 0 when full.
function BaseManager.assignBase(player)
	for i, plot in ipairs(BaseManager.PLOTS) do
		if not BaseManager.bases[i] then
			BaseManager.bases[i] = player.UserId
			return i
		end
	end
	return 0
end

-- Hand a ring back when its player leaves.
function BaseManager.freeBase(player)
	for i, userId in pairs(BaseManager.bases) do
		if userId == player.UserId then
			BaseManager.bases[i] = nil
		end
	end
end

-- Where one slot of a ring sits in the world.
function BaseManager.slotPosition(baseIndex, slotIndex)
	local plot = BaseManager.PLOTS[baseIndex]
	if not plot then
		return Vector3.new(0, 1, 0)
	end
	local offset = BaseManager.SLOT_OFFSETS[slotIndex] or Vector3.new(0, 0, 0)
	return plot.center + offset + Vector3.new(0, 1, 0)
end

-- Place a bought brainrot on its owner's ring, on the first free slot.
-- Returns true when it found a slot.
function BaseManager.placeBrainrot(state, record)
	local slotIndex = #state.owned
	if slotIndex > state.slots then
		return false
	end
	local position = BaseManager.slotPosition(state.baseIndex, slotIndex)
	local model = BrainrotFactory.buildBrainrot(record, position)
	if not model then
		return false
	end
	model.Parent = workspace
	record.model = model
	return true
end

-- Remove one brainrot's model from a ring.
function BaseManager.removeBrainrotModel(record)
	if record.model then
		record.model:Destroy()
		record.model = nil
	end
end

-- Remove every brainrot model of a player (used by Rebirth).
function BaseManager.clearBaseModels(state)
	for _, record in ipairs(state.owned) do
		BaseManager.removeBrainrotModel(record)
	end
end

-- What the next slot costs: it doubles each time.
function BaseManager.nextSlotCost(state)
	return Config.SLOT_COST_BASE * math.pow(2, state.slots - Config.BASE_SLOTS_START)
end

-- Buy one more slot, when the player can afford it and the ring has room.
function BaseManager.buySlot(state)
	if state.slots >= Config.BASE_SLOTS_MAX then
		return false, "Your ring is already at its biggest."
	end
	local cost = BaseManager.nextSlotCost(state)
	local GameState = require(script.Parent.GameState)
	if not GameState.spendCash(state, cost) then
		return false, "You need $" .. tostring(cost) .. " for another slot."
	end
	state.slots = state.slots + 1
	return true, "Slot bought. Your ring holds " .. tostring(state.slots) .. " acts now."
end

return BaseManager
