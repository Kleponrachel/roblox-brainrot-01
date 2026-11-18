-- Brainrot Big Top: GameState is the one place player state lives. Every
-- service reads and writes through here, so cash, brainrots, locks and
-- progress can never drift apart between systems.

local Config = require(game:GetService("ReplicatedStorage").Shared.Config)
local Catalog = require(game:GetService("ReplicatedStorage").Shared.BrainrotCatalog)

local GameState = {}
GameState.players = {}

-- A fresh state for a player who just joined.
function GameState.newPlayerState(player)
	return {
		player = player,
		cash = Config.START_CASH,
		rebirths = 0,
		slots = Config.BASE_SLOTS_START,
		owned = {},
		dex = {},
		contracts = {},
		contractProgress = {},
		dailyStreak = 0,
		lastDailyDay = -1,
		lastSeen = os.time(),
		lockedUntil = 0,
		lockCooldownUntil = 0,
		lastSlapAt = 0,
		carrying = nil,
		baseIndex = 0,
		earnedTotal = 0,
		stolenCount = 0,
		boughtCount = 0,
		eventMult = 1,
	}
end

function GameState.getState(player)
	return GameState.players[player.UserId]
end

function GameState.registerPlayer(player)
	local state = GameState.newPlayerState(player)
	GameState.players[player.UserId] = state
	return state
end

function GameState.removePlayer(player)
	GameState.players[player.UserId] = nil
end

-- Add cash. Returns the new balance.
function GameState.addCash(state, amount)
	state.cash = state.cash + amount
	if amount > 0 then
		state.earnedTotal = state.earnedTotal + amount
	end
	return state.cash
end

-- Take cash when the player can afford it. Returns true when it worked.
function GameState.spendCash(state, amount)
	if state.cash < amount then
		return false
	end
	state.cash = state.cash - amount
	return true
end

-- What one brainrot record earns a second, with its mutation applied.
function GameState.brainrotIncome(record)
	local character = Catalog.getCharacter(record.characterId)
	if not character then
		return 0
	end
	return Catalog.incomeOf(character, record.mutation)
end

-- Everything a player earns in one second, before the event multiplier:
-- every owned brainrot, times the rebirth ladder, times the Dex bonus.
function GameState.baseIncomePerSecond(state)
	local perSecond = 0
	for _, record in ipairs(state.owned) do
		perSecond = perSecond + GameState.brainrotIncome(record)
	end
	perSecond = perSecond * (1 + Config.REBIRTH_BONUS * state.rebirths)
	perSecond = perSecond * GameState.dexBonus(state)
	return perSecond
end

-- The full rate, with the running event (Big Top Hour x2) applied.
function GameState.incomePerSecond(state)
	return GameState.baseIncomePerSecond(state) * state.eventMult
end

-- +5% income for every rarity tier fully discovered in the Dex,
-- +25% more when the whole book is complete.
function GameState.dexBonus(state)
	local bonus = 1
	local full = true
	for _, rarity in ipairs(Catalog.RARITY_ORDER) do
		local tierComplete = true
		for _, character in ipairs(Catalog.getByRarity(rarity)) do
			if not state.dex[character.id] then
				tierComplete = false
				full = false
			end
		end
		if tierComplete then
			bonus = bonus + Config.DEX_TIER_BONUS
		end
	end
	if full then
		bonus = bonus + Config.DEX_FULL_BONUS
	end
	return bonus
end

-- Put a brainrot record on the player's base. Returns false when the base
-- is full.
function GameState.ownBrainrot(state, record)
	if #state.owned >= state.slots then
		return false
	end
	table.insert(state.owned, record)
	return true
end

-- Take one owned brainrot off the base by its unique id. Returns it, or nil.
function GameState.removeBrainrot(state, brainrotId)
	for i, record in ipairs(state.owned) do
		if record.uid == brainrotId then
			table.remove(state.owned, i)
			return record
		end
	end
	return nil
end

-- How many owned brainrots of one rarity the player has.
function GameState.countByRarity(state, rarity)
	local count = 0
	for _, record in ipairs(state.owned) do
		local character = Catalog.getCharacter(record.characterId)
		if character and character.rarity == rarity then
			count = count + 1
		end
	end
	return count
end

-- Is the player's base locked against stealing right now?
function GameState.isBaseLocked(state)
	return os.time() < state.lockedUntil
end

return GameState
