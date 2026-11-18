-- Brainrot Big Top: the Rebirth ladder. A player who has climbed far
-- enough trades everything they own for a permanent +50% income, and
-- starts the climb again from the sawdust. Each rung costs four times
-- the last.

local Config = require(game:GetService("ReplicatedStorage").Shared.Config)
local GameState = require(script.Parent.GameState)
local BaseManager = require(script.Parent.BaseManager)
local Remotes = require(script.Parent.Remotes)

local RebirthService = {}

-- What the next rebirth costs at this many rebirths.
function RebirthService.rebirthCost(rebirths)
	return Config.REBIRTH_COST_BASE * math.pow(Config.REBIRTH_COST_GROWTH, rebirths)
end

-- The income multiplier a rebirth count gives.
function RebirthService.rebirthMultiplier(rebirths)
	return 1 + Config.REBIRTH_BONUS * rebirths
end

-- Can this player rebirth right now?
function RebirthService.canRebirth(state)
	if state.rebirths >= Config.REBIRTH_MAX then
		return false, "You are at the top of the ladder."
	end
	local cost = RebirthService.rebirthCost(state.rebirths)
	if state.cash < cost then
		return false, "Rebirth costs $" .. tostring(cost) .. ". You have $" .. tostring(state.cash) .. "."
	end
	return true, ""
end

-- Do it: take the cash, clear the ring, raise the ladder one rung.
function RebirthService.doRebirth(player)
	local state = GameState.getState(player)
	if not state then
		return false, "No state."
	end
	local ok, reason = RebirthService.canRebirth(state)
	if not ok then
		return false, reason
	end
	BaseManager.clearBaseModels(state)
	state.owned = {}
	state.cash = Config.START_CASH
	state.rebirths = state.rebirths + 1
	local mult = RebirthService.rebirthMultiplier(state.rebirths)
	Remotes.ShowBanner:FireAllClients(player.Name .. " reached Rebirth " .. tostring(state.rebirths) .. "! Income x" .. tostring(mult) .. " forever.")
	return true, "Rebirth " .. tostring(state.rebirths) .. "! All money x" .. tostring(mult) .. " now."
end

return RebirthService
