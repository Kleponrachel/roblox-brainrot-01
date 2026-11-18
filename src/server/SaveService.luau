-- Brainrot Big Top: saving and loading. Player data lives in a DataStore
-- so cash, rebirths, the Dex, contracts and the daily streak survive
-- between sessions, and so offline earnings can be paid on the next join.
-- Every DataStore call is wrapped in pcall: in Studio, or when the
-- service is unavailable, the game keeps running on memory alone.

local DataStoreService = game:GetService("DataStoreService")

local SaveService = {}
SaveService.store = nil

function SaveService.start()
	local ok, store = pcall(function()
		return DataStoreService:GetDataStore("BrainrotBigTop_v1")
	end)
	if ok then
		SaveService.store = store
	end
end

-- The plain table that is written for one player. Models and live objects
-- never go in here, only numbers, strings and small tables.
function SaveService.packState(state)
	local owned = {}
	for _, record in ipairs(state.owned) do
		table.insert(owned, {
			uid = record.uid,
			characterId = record.characterId,
			mutation = record.mutation and record.mutation.name or nil,
		})
	end
	local dex = {}
	for id, _ in pairs(state.dex) do
		table.insert(dex, id)
	end
	return {
		cash = state.cash,
		rebirths = state.rebirths,
		slots = state.slots,
		owned = owned,
		dex = dex,
		dailyStreak = state.dailyStreak,
		lastDailyDay = state.lastDailyDay,
		lastSeen = os.time(),
		earnedTotal = state.earnedTotal,
		stolenCount = state.stolenCount,
		boughtCount = state.boughtCount,
	}
end

-- Read a saved table back into a live state. Unknown fields are ignored,
-- so an old save never breaks a new build.
function SaveService.applySave(state, data)
	if type(data) ~= "table" then
		return
	end
	if type(data.cash) == "number" then
		state.cash = data.cash
	end
	if type(data.rebirths) == "number" then
		state.rebirths = data.rebirths
	end
	if type(data.slots) == "number" then
		state.slots = data.slots
	end
	if type(data.dailyStreak) == "number" then
		state.dailyStreak = data.dailyStreak
	end
	if type(data.lastDailyDay) == "number" then
		state.lastDailyDay = data.lastDailyDay
	end
	if type(data.earnedTotal) == "number" then
		state.earnedTotal = data.earnedTotal
	end
	if type(data.stolenCount) == "number" then
		state.stolenCount = data.stolenCount
	end
	if type(data.boughtCount) == "number" then
		state.boughtCount = data.boughtCount
	end
	if type(data.dex) == "table" then
		for _, id in ipairs(data.dex) do
			state.dex[id] = true
		end
	end
	if type(data.owned) == "table" then
		for _, saved in ipairs(data.owned) do
			local mutation = nil
			if saved.mutation then
				for _, entry in ipairs(require(game:GetService("ReplicatedStorage").Shared.BrainrotCatalog).MUTATIONS) do
					if entry.name == saved.mutation then
						mutation = entry
					end
				end
			end
			table.insert(state.owned, {
				uid = saved.uid,
				characterId = saved.characterId,
				mutation = mutation,
			})
		end
	end
end

-- Load one player's save. Returns the saved table, or nil.
function SaveService.loadPlayerData(userId)
	if not SaveService.store then
		return nil
	end
	local ok, data = pcall(function()
		return SaveService.store:GetAsync("player_" .. tostring(userId))
	end)
	if ok then
		return data
	end
	return nil
end

-- Save one player's state now.
function SaveService.savePlayerData(userId, state)
	if not SaveService.store then
		return false
	end
	local ok = pcall(function()
		SaveService.store:SetAsync("player_" .. tostring(userId), SaveService.packState(state))
	end)
	return ok
end

-- Save every player still in the game (called when the server closes).
function SaveService.saveAllPlayers(players)
	for _, state in pairs(players) do
		SaveService.savePlayerData(state.player.UserId, state)
	end
end

return SaveService
