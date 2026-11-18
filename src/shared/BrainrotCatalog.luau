-- Brainrot Big Top: the cast. Twelve original circus acts, each with a
-- rarity, a price and the money it earns every second, plus the eight
-- mutations that can bless any of them. Every system in the game reads
-- this one table, so a character's numbers are never typed twice.

local Catalog = {}

Catalog.RARITIES = {
	{ name = "Common", color = Color3.fromRGB(190, 190, 190), order = 1 },
	{ name = "Rare", color = Color3.fromRGB(80, 160, 255), order = 2 },
	{ name = "Epic", color = Color3.fromRGB(170, 90, 255), order = 3 },
	{ name = "Legendary", color = Color3.fromRGB(255, 180, 30), order = 4 },
	{ name = "Mythic", color = Color3.fromRGB(255, 70, 130), order = 5 },
}

Catalog.RARITY_ORDER = { "Common", "Rare", "Epic", "Legendary", "Mythic" }

-- Eight mutations, each with its income multiplier and its roll chance.
-- The chances add to 0.505, so about half of all parading brainrots are
-- plain and half carry one mutation; Confetti Storm triples the luck.
Catalog.MUTATIONS = {
	{ name = "Golden", mult = 2, color = Color3.fromRGB(255, 210, 40), chance = 0.10 },
	{ name = "Silver", mult = 1.5, color = Color3.fromRGB(200, 210, 220), chance = 0.12 },
	{ name = "Diamond", mult = 4, color = Color3.fromRGB(120, 220, 255), chance = 0.05 },
	{ name = "Rainbow", mult = 8, color = Color3.fromRGB(255, 110, 220), chance = 0.02 },
	{ name = "Storm", mult = 3, color = Color3.fromRGB(140, 120, 255), chance = 0.06 },
	{ name = "Lava", mult = 2.5, color = Color3.fromRGB(255, 90, 40), chance = 0.07 },
	{ name = "Frost", mult = 2, color = Color3.fromRGB(170, 235, 255), chance = 0.08 },
	{ name = "Cosmic", mult = 10, color = Color3.fromRGB(255, 60, 255), chance = 0.005 },
}

-- The twelve acts. Price and income climb the ladder; a later act costs
-- roughly twice the one before it and earns roughly twice as much.
-- body is the act's main colour, hat is the accessory BrainrotFactory
-- builds for it, blurb is the joke on its Dex page.
Catalog.CHARACTERS = {
	{ id = "clowny", name = "Clowny McNoodle", rarity = "Common", price = 100, income = 12, body = Color3.fromRGB(255, 90, 90), hat = "Cone", blurb = "Honks every time he gets paid." },
	{ id = "poppy", name = "Poppy Popcorn", rarity = "Common", price = 250, income = 28, body = Color3.fromRGB(255, 220, 120), hat = "Bucket", blurb = "Pops when the crowd goes wild." },
	{ id = "bouncesalot", name = "Sir Bouncesalot", rarity = "Common", price = 600, income = 60, body = Color3.fromRGB(120, 200, 255), hat = "Ball", blurb = "Has never once touched the ground." },
	{ id = "zucchini", name = "Madame Zucchini", rarity = "Rare", price = 1500, income = 140, body = Color3.fromRGB(140, 220, 90), hat = "Turban", blurb = "Saw your wallet coming." },
	{ id = "cannonball", name = "Captain Cannonball", rarity = "Rare", price = 3500, income = 300, body = Color3.fromRGB(90, 90, 110), hat = "Helmet", blurb = "Fired daily. Lands rich." },
	{ id = "banana", name = "The Bearded Banana", rarity = "Rare", price = 7500, income = 600, body = Color3.fromRGB(255, 230, 60), hat = "Beard", blurb = "Peels back the curtain on wealth." },
	{ id = "ringmaster", name = "DJ Ringmaster", rarity = "Epic", price = 18000, income = 1400, body = Color3.fromRGB(200, 60, 200), hat = "TopHat", blurb = "Drops the beat and the rent." },
	{ id = "picklefish", name = "Professor Picklefish", rarity = "Epic", price = 40000, income = 2800, body = Color3.fromRGB(80, 220, 160), hat = "Monocle", blurb = "A doctorate in being briny." },
	{ id = "taco", name = "Tightrope Taco", rarity = "Epic", price = 90000, income = 6000, body = Color3.fromRGB(255, 170, 60), hat = "Sombrero", blurb = "Balances the books. Literally." },
	{ id = "quokka", name = "Queen Quokka the Great", rarity = "Legendary", price = 200000, income = 13000, body = Color3.fromRGB(255, 150, 200), hat = "Crown", blurb = "Smiles. The money smiles back." },
	{ id = "llama", name = "Lord Llama Latte", rarity = "Legendary", price = 450000, income = 26000, body = Color3.fromRGB(220, 200, 170), hat = "Cup", blurb = "Spits success. Frothy success." },
	{ id = "noodler", name = "The Grand Noodler", rarity = "Mythic", price = 1000000, income = 60000, body = Color3.fromRGB(255, 240, 180), hat = "Wizard", blurb = "The noodle that rules them all." },
}

-- Look a character up by id. Returns nil for an unknown id.
function Catalog.getCharacter(id)
	for _, character in ipairs(Catalog.CHARACTERS) do
		if character.id == id then
			return character
		end
	end
	return nil
end

-- Every character of one rarity, in ladder order.
function Catalog.getByRarity(rarity)
	local found = {}
	for _, character in ipairs(Catalog.CHARACTERS) do
		if character.rarity == rarity then
			table.insert(found, character)
		end
	end
	return found
end

-- The colour of a rarity's name, for labels and the Dex.
function Catalog.rarityColor(rarity)
	for _, entry in ipairs(Catalog.RARITIES) do
		if entry.name == rarity then
			return entry.color
		end
	end
	return Color3.fromRGB(255, 255, 255)
end

-- Pick a character to parade. Common acts are the most likely to show up;
-- the Grand Noodler almost never walks the ring on his own.
function Catalog.rollCharacter()
	local roll = math.random()
	if roll < 0.55 then
		local commons = Catalog.getByRarity("Common")
		return commons[math.random(1, #commons)]
	elseif roll < 0.80 then
		local rares = Catalog.getByRarity("Rare")
		return rares[math.random(1, #rares)]
	elseif roll < 0.93 then
		local epics = Catalog.getByRarity("Epic")
		return epics[math.random(1, #epics)]
	elseif roll < 0.99 then
		local legendaries = Catalog.getByRarity("Legendary")
		return legendaries[math.random(1, #legendaries)]
	else
		return Catalog.getCharacter("noodler")
	end
end

-- Roll a mutation for a parading brainrot. luckMult is 1 normally and 3
-- during a Confetti Storm. Returns the mutation table, or nil for plain.
function Catalog.rollMutation(luckMult)
	local roll = math.random()
	local running = 0
	for _, mutation in ipairs(Catalog.MUTATIONS) do
		running = running + mutation.chance * luckMult
		if roll <= running then
			return mutation
		end
	end
	return nil
end

-- What one brainrot earns a second: its base income times its mutation.
function Catalog.incomeOf(character, mutation)
	if mutation then
		return character.income * mutation.mult
	end
	return character.income
end

-- A short label for a brainrot, as shown above its head on the ring.
function Catalog.labelFor(character, mutation)
	if mutation then
		return mutation.name .. " " .. character.name
	end
	return character.name
end

return Catalog
