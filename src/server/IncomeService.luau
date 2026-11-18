-- Brainrot Big Top: IncomeService pays every player their money a second
-- and keeps their HUD honest. It also pays offline earnings: when a
-- player comes back, the time they were away earns at half rate, for at
-- most eight hours.

local Config = require(game:GetService("ReplicatedStorage").Shared.Config)
local GameState = require(script.Parent.GameState)
local BaseManager = require(script.Parent.BaseManager)
local StealService = require(script.Parent.StealService)
local Remotes = require(script.Parent.Remotes)

local IncomeService = {}

-- What a returning player is owed for the hours they were away.
function IncomeService.calculateOfflineEarnings(state, lastSeen)
	local away = os.time() - (lastSeen or os.time())
	local capped = math.min(away, Config.OFFLINE_CAP_HOURS * 3600)
	local perSecond = GameState.baseIncomePerSecond(state)
	return math.floor(perSecond * capped * Config.OFFLINE_RATE), capped
end

-- Pay a returning player their offline earnings and tell their client.
function IncomeService.grantOfflineEarnings(player, state, lastSeen)
	local amount, awaySeconds = IncomeService.calculateOfflineEarnings(state, lastSeen)
	if amount > 0 then
		GameState.addCash(state, amount)
		local hours = math.floor(awaySeconds / 3600)
		local minutes = math.floor((awaySeconds % 3600) / 60)
		Remotes.ShowOfflineEarnings:FireClient(player, amount, hours, minutes)
	end
	return amount
end

-- One tick: every player earns their rate for one second, and any thief
-- standing on their own ring hands their stolen act over at once.
function IncomeService.tick()
	for _, state in pairs(GameState.players) do
		local earned = GameState.incomePerSecond(state)
		if earned > 0 then
			GameState.addCash(state, earned)
		end
		if state.carrying and state.baseIndex > 0 then
			local root = state.player.Character and state.player.Character:FindFirstChild("HumanoidRootPart")
			local plot = BaseManager.PLOTS[state.baseIndex]
			if root and plot and (root.Position - plot.center).Magnitude < 16 then
				StealService.deliverCarried(state.player)
			end
		end
		Remotes.UpdateHud:FireClient(state.player, state.cash, GameState.incomePerSecond(state), state.rebirths)
	end
end

-- The income heartbeat: one tick a second, forever.
function IncomeService.start()
	task.spawn(function()
		while true do
			IncomeService.tick()
			task.wait(1)
		end
	end)
end

return IncomeService
