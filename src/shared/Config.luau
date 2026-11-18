-- Brainrot Big Top: one place for every tuning number of the game.
-- Change a number here and the whole game retunes: prices, timers,
-- multipliers and event cadence all read from this module.

local Config = {}

-- Starting money for a new player.
Config.START_CASH = 100

-- Base slots: how many brainrots a base holds, and what extra slots cost.
Config.BASE_SLOTS_START = 4
Config.BASE_SLOTS_MAX = 10
Config.SLOT_COST_BASE = 500

-- Rebirth ladder: cost grows fast, every rebirth is +50% income forever.
Config.REBIRTH_COST_BASE = 25000
Config.REBIRTH_COST_GROWTH = 4
Config.REBIRTH_BONUS = 0.5
Config.REBIRTH_MAX = 10

-- Spotlight Lock: how long a base stays locked, and its cooldown.
Config.LOCK_DURATION = 60
Config.LOCK_COOLDOWN = 120

-- Slap: cooldown in seconds, and how close a thief must be to be slapped.
Config.SLAP_COOLDOWN = 5
Config.SLAP_RANGE = 8

-- A player carrying a stolen brainrot walks this much slower (multiplier).
Config.STEAL_SLOW = 0.6

-- Offline earnings: paid on join, at half rate, for at most this many hours.
Config.OFFLINE_CAP_HOURS = 8
Config.OFFLINE_RATE = 0.5

-- Events, in seconds between starts.
Config.STAMPEDE_INTERVAL = 240
Config.STAMPEDE_WARN = 10
Config.STAMPEDE_CASH_LOSS = 0.10
Config.BIG_TOP_HOUR_INTERVAL = 600
Config.BIG_TOP_HOUR_DURATION = 60
Config.BIG_TOP_HOUR_MULT = 2
Config.CLAW_INTERVAL = 180
Config.CONFETTI_INTERVAL = 300
Config.CONFETTI_DURATION = 30
Config.CONFETTI_LUCK_MULT = 3

-- The parade ring: how fast brainrots walk it, and how long before one
-- that nobody buys is sent home.
Config.PARADE_SPEED = 6
Config.PARADE_DESPAWN_TIME = 75
Config.PARADE_RING_RADIUS = 40

-- Daily rewards, day 1 to day 7 of a streak (day 7 also grants a free
-- Mythic roll, handled by DailyRewardService).
Config.DAILY_REWARDS = { 500, 1500, 4000, 10000, 25000, 50000, 100000 }

-- Dex completion: +5% income for every rarity tier fully discovered,
-- +25% for the whole book.
Config.DEX_TIER_BONUS = 0.05
Config.DEX_FULL_BONUS = 0.25

return Config
