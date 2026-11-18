-- Brainrot Big Top: the BrainrotDex. Every act a player has ever owned
-- is stamped in their book, and a finished rarity tier pays a permanent
-- income bonus. The Dex is the game's collection game.

local Catalog = require(game:GetService("ReplicatedStorage").Shared.BrainrotCatalog)
local Config = require(game:GetService("ReplicatedStorage").Shared.Config)
local Remotes = require(script.Parent.Remotes)

local DexService = {}

-- Stamp one character into a player's Dex. Returns true when it was new.
function DexService.markDiscovered(state, characterId)
	if state.dex[characterId] then
		return false
	end
	state.dex[characterId] = true
	local character = Catalog.getCharacter(characterId)
	if character then
		Remotes.ShowToast:FireClient(state.player, "Dex: discovered " .. character.name .. "!")
		Remotes.UpdateDex:FireClient(state.player, DexService.getDexState(state))
	end
	return true
end

-- How many of the twelve acts one player has discovered.
function DexService.discoveredCount(state)
	local count = 0
	for _, character in ipairs(Catalog.CHARACTERS) do
		if state.dex[character.id] then
			count = count + 1
		end
	end
	return count
end

-- Is one rarity tier finished in this player's book?
function DexService.isTierComplete(state, rarity)
	for _, character in ipairs(Catalog.getByRarity(rarity)) do
		if not state.dex[character.id] then
			return false
		end
	end
	return true
end

-- The whole Dex as a table the client can draw: one row per character.
function DexService.getDexState(state)
	local rows = {}
	for _, character in ipairs(Catalog.CHARACTERS) do
		table.insert(rows, {
			id = character.id,
			name = character.name,
			rarity = character.rarity,
			income = character.income,
			blurb = character.blurb,
			discovered = state.dex[character.id] == true,
		})
	end
	return {
		rows = rows,
		discovered = DexService.discoveredCount(state),
		total = #Catalog.CHARACTERS,
		bonus = (require(script.Parent.GameState).dexBonus(state) - 1) * 100,
	}
end

return DexService
