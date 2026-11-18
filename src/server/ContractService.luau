-- Brainrot Big Top: the Contract Board. Three jobs hang on the board at
-- a time: buy acts, earn money, steal from rivals, climb the ladder.
-- Finish one and it pays cash; a new job takes its place.

local GameState = require(script.Parent.GameState)
local Remotes = require(script.Parent.Remotes)

local ContractService = {}

-- The pool every contract is drawn from. type is the event that feeds
-- it, target is how much of it, reward is what it pays.
ContractService.POOL = {
	{ id = "buy2common", text = "Buy 2 Common acts", type = "buy", rarity = "Common", target = 2, reward = 500 },
	{ id = "buy1rare", text = "Buy 1 Rare act", type = "buy", rarity = "Rare", target = 1, reward = 1500 },
	{ id = "buy1epic", text = "Buy 1 Epic act", type = "buy", rarity = "Epic", target = 1, reward = 8000 },
	{ id = "earn5000", text = "Earn $5,000 in total", type = "earn", target = 5000, reward = 1000 },
	{ id = "earn50000", text = "Earn $50,000 in total", type = "earn", target = 50000, reward = 8000 },
	{ id = "steal1", text = "Steal 1 act from a rival", type = "steal", target = 1, reward = 2000 },
	{ id = "steal3", text = "Steal 3 acts from rivals", type = "steal", target = 3, reward = 8000 },
	{ id = "rebirth1", text = "Rebirth once", type = "rebirth", target = 1, reward = 10000 },
	{ id = "own5", text = "Own 5 acts at once", type = "own", target = 5, reward = 3000 },
	{ id = "ownrare3", text = "Own 3 Rare acts at once", type = "ownrare", target = 3, reward = 6000 },
}

-- Deal three fresh contracts to a player.
function ContractService.generateContracts(state)
	state.contracts = {}
	state.contractProgress = {}
	local pool = {}
	for _, contract in ipairs(ContractService.POOL) do
		table.insert(pool, contract)
	end
	for i = 1, 3 do
		if #pool == 0 then
			break
		end
		local pick = math.random(1, #pool)
		local contract = pool[pick]
		table.remove(pool, pick)
		table.insert(state.contracts, contract)
		state.contractProgress[contract.id] = 0
	end
	Remotes.UpdateContracts:FireClient(state.player, ContractService.getContractState(state))
end

-- The board as the client draws it: each contract with its progress.
function ContractService.getContractState(state)
	local rows = {}
	for _, contract in ipairs(state.contracts) do
		table.insert(rows, {
			id = contract.id,
			text = contract.text,
			target = contract.target,
			progress = state.contractProgress[contract.id] or 0,
			reward = contract.reward,
			done = (state.contractProgress[contract.id] or 0) >= contract.target,
		})
	end
	return rows
end

-- Feed one event into the board: "buy" with a rarity, "earn" with an
-- amount, "steal", "rebirth", or "own" checked against the live ring.
function ContractService.trackEvent(state, eventType, value)
	local changed = false
	for _, contract in ipairs(state.contracts) do
		local progress = state.contractProgress[contract.id] or 0
		if progress < contract.target then
			if contract.type == "buy" and eventType == "buy" and value == contract.rarity then
				state.contractProgress[contract.id] = progress + 1
				changed = true
			elseif contract.type == "earn" and eventType == "earn" then
				state.contractProgress[contract.id] = progress + value
				changed = true
			elseif contract.type == "steal" and eventType == "steal" then
				state.contractProgress[contract.id] = progress + 1
				changed = true
			elseif contract.type == "rebirth" and eventType == "rebirth" then
				state.contractProgress[contract.id] = progress + 1
				changed = true
			elseif contract.type == "own" and eventType == "own" then
				state.contractProgress[contract.id] = #state.owned
				changed = true
			elseif contract.type == "ownrare" and eventType == "own" then
				state.contractProgress[contract.id] = GameState.countByRarity(state, "Rare")
				changed = true
			end
		end
	end
	if changed then
		Remotes.UpdateContracts:FireClient(state.player, ContractService.getContractState(state))
	end
end

-- Claim a finished contract: pay its reward and deal a new job.
function ContractService.claimContract(player, contractId)
	local state = GameState.getState(player)
	if not state then
		return false, "No state."
	end
	for i, contract in ipairs(state.contracts) do
		if contract.id == contractId then
			local progress = state.contractProgress[contract.id] or 0
			if progress < contract.target then
				return false, "Not finished yet: " .. tostring(progress) .. "/" .. tostring(contract.target) .. "."
			end
			GameState.addCash(state, contract.reward)
			table.remove(state.contracts, i)
			state.contractProgress[contract.id] = nil
			ContractService.dealOneContract(state)
			Remotes.ShowToast:FireClient(player, "Contract done! +$" .. tostring(contract.reward) .. ".")
			return true, "Claimed $" .. tostring(contract.reward) .. "."
		end
	end
	return false, "No such contract."
end

-- Deal one fresh job onto the board, from the pool, not a duplicate.
function ContractService.dealOneContract(state)
	local pool = {}
	for _, contract in ipairs(ContractService.POOL) do
		local taken = false
		for _, active in ipairs(state.contracts) do
			if active.id == contract.id then
				taken = true
			end
		end
		if not taken then
			table.insert(pool, contract)
		end
	end
	if #pool == 0 then
		return
	end
	local contract = pool[math.random(1, #pool)]
	table.insert(state.contracts, contract)
	state.contractProgress[contract.id] = 0
	Remotes.UpdateContracts:FireClient(state.player, ContractService.getContractState(state))
end

return ContractService
