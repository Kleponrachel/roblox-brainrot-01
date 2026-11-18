-- Brainrot Big Top: the parade ring. Brainrots walk a circle around the
-- big top, one after another, and a player who likes the look of one buys
-- it before it walks off. The Giant Claw drops a guaranteed Golden act
-- onto the ring every few minutes.

local Config = require(game:GetService("ReplicatedStorage").Shared.Config)
local Catalog = require(game:GetService("ReplicatedStorage").Shared.BrainrotCatalog)
local BrainrotFactory = require(script.Parent.BrainrotFactory)

local ParadeRing = {}
ParadeRing.active = {}
ParadeRing.luckMult = 1
ParadeRing.spawnTimer = 0

-- Twelve waypoints on a circle around the tent, radius from Config.
function ParadeRing.waypoints()
	local points = {}
	for i = 0, 11 do
		local angle = (i / 12) * math.pi * 2
		table.insert(points, Vector3.new(
			math.cos(angle) * Config.PARADE_RING_RADIUS,
			1,
			math.sin(angle) * Config.PARADE_RING_RADIUS
		))
	end
	return points
end

-- Spawn one parading brainrot: roll its act and its mutation, build its
-- model at the first waypoint, and start it walking.
function ParadeRing.spawnBrainrot(character, mutation)
	character = character or Catalog.rollCharacter()
	mutation = mutation or Catalog.rollMutation(ParadeRing.luckMult)
	local record = BrainrotFactory.newRecord(character, mutation)
	local points = ParadeRing.waypoints()
	local model = BrainrotFactory.buildBrainrot(record, points[1])
	if not model then
		return nil
	end
	model.Parent = workspace
	local prompt = Instance.new("ProximityPrompt")
	prompt.ActionText = "Buy"
	prompt.ObjectText = Catalog.labelFor(character, mutation) .. "  $" .. tostring(character.price)
	prompt.HoldDuration = 0.4
	prompt.MaxActivationDistance = 10
	prompt.Parent = model.PrimaryPart
	table.insert(ParadeRing.active, {
		record = record,
		model = model,
		waypoint = 2,
		age = 0,
	})
	return record
end

-- The Giant Claw's drop: a rare act, always Golden, announced to all.
function ParadeRing.spawnGoldenBrainrot()
	local roll = math.random()
	local character
	if roll < 0.5 then
		character = Catalog.getCharacter("taco")
	elseif roll < 0.85 then
		character = Catalog.getCharacter("quokka")
	else
		character = Catalog.getCharacter("noodler")
	end
	local golden = nil
	for _, mutation in ipairs(Catalog.MUTATIONS) do
		if mutation.name == "Golden" then
			golden = mutation
		end
	end
	return ParadeRing.spawnBrainrot(character, golden)
end

-- Take a parading brainrot off the ring by its unique id, with its record.
function ParadeRing.takeBrainrot(uid)
	for i, entry in ipairs(ParadeRing.active) do
		if entry.record.uid == uid then
			table.remove(ParadeRing.active, i)
			local model = entry.model
			local record = entry.record
			if model then
				model:Destroy()
			end
			return record
		end
	end
	return nil
end

-- The nearest parading brainrot to a position, within a distance.
function ParadeRing.nearestBrainrot(position, maxDistance)
	local best = nil
	local bestDistance = maxDistance
	for _, entry in ipairs(ParadeRing.active) do
		local distance = (entry.model.PrimaryPart.Position - position).Magnitude
		if distance < bestDistance then
			bestDistance = distance
			best = entry
		end
	end
	return best
end

-- Move every parading brainrot one step along the ring, and send home
-- any that walked the whole circle without being bought.
function ParadeRing.update(dt)
	local points = ParadeRing.waypoints()
	for i = #ParadeRing.active, 1, -1 do
		local entry = ParadeRing.active[i]
		entry.age = entry.age + dt
		if entry.age >= Config.PARADE_DESPAWN_TIME then
			entry.model:Destroy()
			table.remove(ParadeRing.active, i)
		else
			local target = points[entry.waypoint]
			local part = entry.model.PrimaryPart
			local toTarget = target - part.Position
			local distance = toTarget.Magnitude
			local step = Config.PARADE_SPEED * dt
			local newPosition = part.Position
			if distance <= step then
				newPosition = target
				entry.waypoint = entry.waypoint + 1
				if entry.waypoint > #points then
					entry.waypoint = 1
				end
			else
				newPosition = part.Position + toTarget.Unit * step
			end
			-- PivotTo moves the whole model (body, head, hat, label) at once.
			entry.model:PivotTo(CFrame.new(newPosition, newPosition + toTarget))
		end
	end
	ParadeRing.spawnTimer = ParadeRing.spawnTimer - dt
	if ParadeRing.spawnTimer <= 0 then
		ParadeRing.spawnTimer = 9
		ParadeRing.spawnBrainrot()
	end
end

-- The parade's heartbeat: one task, forever, ten steps a second.
function ParadeRing.start()
	ParadeRing.spawnBrainrot()
	ParadeRing.spawnBrainrot()
	task.spawn(function()
		while true do
			ParadeRing.update(0.1)
			task.wait(0.1)
		end
	end)
end

return ParadeRing
