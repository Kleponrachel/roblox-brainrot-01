-- Brainrot Big Top: Daily Rewards. Come back every day and the streak
-- grows: day one pays a little, day seven pays a lot and throws in a
-- free Mythic roll. Miss a day and the streak starts over.

local Config = require(game:GetService("ReplicatedStorage").Shared.Config)
local Catalog = require(game:GetService("ReplicatedStorage").Shared.BrainrotCatalog)
local GameState = require(script.Parent.GameState)
local ParadeRing = require(script.Parent.ParadeRing)
local Remotes = require(script.Parent.Remotes)

local DailyRewardService = {}

-- Today's day number, for streak math (days since the epoch).
function DailyRewardService.todayNumber()
	return math.floor(os.time() / 86400)
end

-- Can this player claim today?
function DailyRewardService.canClaim(state)
	return state.lastDailyDay < DailyRewardService.todayNumber()
end

-- Claim today's reward: grow or restart the streak, pay the cash, and on
-- day seven roll a free Mythic act onto the ring for the player.
function DailyRewardService.claimDaily(player)
	local state = GameState.getState(player)
	if not state then
		return false, "No state."
	end
	local today = DailyRewardService.todayNumber()
	if state.lastDailyDay >= today then
		return false, "Already claimed today. Come back tomorrow."
	end
	if state.lastDailyDay == today - 1 then
		state.dailyStreak = state.dailyStreak + 1
	else
		state.dailyStreak = 1
	end
	if state.dailyStreak > 7 then
		state.dailyStreak = 7
	end
	state.lastDailyDay = today
	local reward = Config.DAILY_REWARDS[state.dailyStreak]
	GameState.addCash(state, reward)
	if state.dailyStreak == 7 then
		ParadeRing.spawnBrainrot(Catalog.getCharacter("noodler"), nil)
		Remotes.ShowToast:FireClient(player, "Day 7! +$" .. tostring(reward) .. " and a Mythic walks the ring!")
	else
		Remotes.ShowToast:FireClient(player, "Daily reward day " .. tostring(state.dailyStreak) .. ": +$" .. tostring(reward) .. "!")
	end
	return true, "Claimed $" .. tostring(reward) .. "."
end

return DailyRewardService
