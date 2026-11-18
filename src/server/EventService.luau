-- Brainrot Big Top: EventService runs the show. On a timer it throws the
-- events that make the ring dangerous and generous: the Elephant
-- Stampede that chases everyone home, the Big Top Hour that doubles all
-- money, the Confetti Storm that blesses mutations, and the Giant Claw
-- that drops a guaranteed Golden act on the ring.

local Config = require(game:GetService("ReplicatedStorage").Shared.Config)
local GameState = require(script.Parent.GameState)
local ParadeRing = require(script.Parent.ParadeRing)
local Remotes = require(script.Parent.Remotes)

local EventService = {}
EventService.activeEvent = "None"
EventService.stampedeTimer = Config.STAMPEDE_INTERVAL
EventService.bigTopTimer = Config.BIG_TOP_HOUR_INTERVAL
EventService.clawTimer = Config.CLAW_INTERVAL
EventService.confettiTimer = Config.CONFETTI_INTERVAL
EventService.bigTopLeft = 0
EventService.confettiLeft = 0

-- What the HUD shows as the running event, or "None".
function EventService.getActiveEvent()
	return EventService.activeEvent
end

-- The income multiplier the running event gives everyone right now.
function EventService.getEventMult()
	if EventService.activeEvent == "Big Top Hour" then
		return Config.BIG_TOP_HOUR_MULT
	end
	return 1
end

-- Push the running multiplier into every player's state.
function EventService.applyEventMult()
	local mult = EventService.getEventMult()
	for _, state in pairs(GameState.players) do
		state.eventMult = mult
	end
end

-- Warn the island, then send the elephants across the ring. Anyone
-- caught outside their own base drops a tenth of their cash.
function EventService.startStampede()
	EventService.activeEvent = "Stampede"
	Remotes.ShowBanner:FireAllClients("ELEPHANT STAMPEDE! Dash back to your ring!")
	task.wait(Config.STAMPEDE_WARN)
	local elephants = {}
	for i = 1, 3 do
		local elephant = Instance.new("Part")
		elephant.Name = "StampedeElephant"
		elephant.Size = Vector3.new(6, 5, 8)
		elephant.Color = Color3.fromRGB(150, 150, 160)
		elephant.Material = Enum.Material.SmoothPlastic
		elephant.Position = Vector3.new(-90, 3, -30 + i * 30)
		elephant.Anchored = true
		elephant.CanCollide = false
		elephant.Parent = workspace
		table.insert(elephants, elephant)
	end
	for step = 1, 60 do
		for _, elephant in ipairs(elephants) do
			elephant.Position = elephant.Position + Vector3.new(3, 0, 0)
		end
		task.wait(0.1)
	end
	for _, elephant in ipairs(elephants) do
		elephant:Destroy()
	end
	for _, state in pairs(GameState.players) do
		local player = state.player
		local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
		if root then
			local inBase = false
			if state.baseIndex > 0 then
				local plot = require(script.Parent.BaseManager).PLOTS[state.baseIndex]
				if plot and (root.Position - plot.center).Magnitude < 16 then
					inBase = true
				end
			end
			if not inBase then
				local lost = math.floor(state.cash * Config.STAMPEDE_CASH_LOSS)
				state.cash = state.cash - lost
				Remotes.ShowToast:FireClient(player, "Trampled! You dropped $" .. tostring(lost) .. ".")
			end
		end
	end
	EventService.activeEvent = "None"
end

-- One hour of the show, doubled: every brainrot pays twice for a minute.
function EventService.startBigTopHour()
	EventService.activeEvent = "Big Top Hour"
	EventService.bigTopLeft = Config.BIG_TOP_HOUR_DURATION
	EventService.applyEventMult()
	Remotes.ShowBanner:FireAllClients("BIG TOP HOUR! All money x2 for 60 seconds!")
end

-- Confetti in the air: mutations roll three times luckier for a while.
function EventService.startConfettiStorm()
	EventService.activeEvent = "Confetti Storm"
	EventService.confettiLeft = Config.CONFETTI_DURATION
	ParadeRing.luckMult = Config.CONFETTI_LUCK_MULT
	Remotes.ShowBanner:FireAllClients("CONFETTI STORM! Mutation luck x3 for 30 seconds!")
end

-- The Giant Claw descends and drops a Golden act on the ring.
function EventService.dropGoldenBrainrot()
	ParadeRing.spawnGoldenBrainrot()
	Remotes.ShowBanner:FireAllClients("THE GIANT CLAW dropped a Golden act on the ring!")
end

-- The show's clock: one task, forever, counting every event down.
function EventService.start()
	task.spawn(function()
		while true do
			task.wait(1)
			if EventService.bigTopLeft > 0 then
				EventService.bigTopLeft = EventService.bigTopLeft - 1
				if EventService.bigTopLeft <= 0 then
					EventService.activeEvent = "None"
					EventService.applyEventMult()
				end
			end
			if EventService.confettiLeft > 0 then
				EventService.confettiLeft = EventService.confettiLeft - 1
				if EventService.confettiLeft <= 0 then
					ParadeRing.luckMult = 1
					if EventService.activeEvent == "Confetti Storm" then
						EventService.activeEvent = "None"
					end
				end
			end
			EventService.stampedeTimer = EventService.stampedeTimer - 1
			if EventService.stampedeTimer <= 0 then
				EventService.stampedeTimer = Config.STAMPEDE_INTERVAL
				task.spawn(EventService.startStampede)
			end
			EventService.bigTopTimer = EventService.bigTopTimer - 1
			if EventService.bigTopTimer <= 0 then
				EventService.bigTopTimer = Config.BIG_TOP_HOUR_INTERVAL
				EventService.startBigTopHour()
			end
			EventService.clawTimer = EventService.clawTimer - 1
			if EventService.clawTimer <= 0 then
				EventService.clawTimer = Config.CLAW_INTERVAL
				EventService.dropGoldenBrainrot()
			end
			EventService.confettiTimer = EventService.confettiTimer - 1
			if EventService.confettiTimer <= 0 then
				EventService.confettiTimer = Config.CONFETTI_INTERVAL
				EventService.startConfettiStorm()
			end
		end
	end)
end

return EventService
