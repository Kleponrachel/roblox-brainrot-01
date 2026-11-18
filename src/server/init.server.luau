-- Brainrot Big Top: the server's front door. It starts every service,
-- seats every player who joins, and puts them away when they leave.
-- Nothing else in the game runs before this script does.

local Players = game:GetService("Players")

local GameState = require(script.Parent.GameState)
local SaveService = require(script.Parent.SaveService)
local BaseManager = require(script.Parent.BaseManager)
local ParadeRing = require(script.Parent.ParadeRing)
local IncomeService = require(script.Parent.IncomeService)
local EventService = require(script.Parent.EventService)
local StealService = require(script.Parent.StealService)
local BaseLockService = require(script.Parent.BaseLockService)
local RebirthService = require(script.Parent.RebirthService)
local DexService = require(script.Parent.DexService)
local ContractService = require(script.Parent.ContractService)
local DailyRewardService = require(script.Parent.DailyRewardService)
local LeaderboardService = require(script.Parent.LeaderboardService)
local Catalog = require(game:GetService("ReplicatedStorage").Shared.BrainrotCatalog)
local Remotes = require(script.Parent.Remotes)

-- Seat a player: load their save, pay their offline earnings, give them
-- a ring, deal their contracts, and open their Dex.
local function onPlayerAdded(player)
	local state = GameState.registerPlayer(player)
	local saved = SaveService.loadPlayerData(player.UserId)
	local lastSeen = nil
	if saved then
		SaveService.applySave(state, saved)
		lastSeen = saved.lastSeen
	end
	state.baseIndex = BaseManager.assignBase(player)
	IncomeService.grantOfflineEarnings(player, state, lastSeen)
	ContractService.generateContracts(state)
	Remotes.UpdateDex:FireClient(player, DexService.getDexState(state))
	Remotes.UpdateHud:FireClient(player, state.cash, GameState.incomePerSecond(state), state.rebirths)
	Remotes.ShowToast:FireClient(player, "Welcome to Brainrot Big Top! Buy an act from the parade ring.")
end

-- Put a player away: drop anything they carry, free their ring, save.
local function onPlayerRemoving(player)
	local state = GameState.getState(player)
	if state then
		if state.carrying then
			StealService.dropCarried(player)
		end
		SaveService.savePlayerData(player.UserId, state)
		BaseManager.freeBase(player)
		GameState.removePlayer(player)
	end
end

-- Buy the nearest parading brainrot, when the player can afford it.
Remotes.RequestBuy.OnServerEvent:Connect(function(player)
	local state = GameState.getState(player)
	if not state then
		return
	end
	local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
	if not root then
		return
	end
	local nearest = ParadeRing.nearestBrainrot(root.Position, 12)
	if not nearest then
		Remotes.ShowToast:FireClient(player, "No act in reach. Walk up to the parade ring.")
		return
	end
	local character = Catalog.getCharacter(nearest.record.characterId)
	if not character then
		return
	end
	if #state.owned >= state.slots then
		Remotes.ShowToast:FireClient(player, "Your ring is full. Buy a slot first.")
		return
	end
	if not GameState.spendCash(state, character.price) then
		Remotes.ShowToast:FireClient(player, "You need $" .. tostring(character.price) .. " for " .. character.name .. ".")
		return
	end
	local record = ParadeRing.takeBrainrot(nearest.record.uid)
	if not record then
		GameState.addCash(state, character.price)
		return
	end
	if not GameState.ownBrainrot(state, record) then
		GameState.addCash(state, character.price)
		return
	end
	BaseManager.placeBrainrot(state, record)
	DexService.markDiscovered(state, character.id)
	ContractService.trackEvent(state, "buy", character.rarity)
	ContractService.trackEvent(state, "own", 0)
	state.boughtCount = state.boughtCount + 1
	Remotes.ShowToast:FireClient(player, "Bought " .. Catalog.labelFor(character, record.mutation) .. " for $" .. tostring(character.price) .. "!")
end)

-- Steal a brainrot off another player's ring.
Remotes.RequestSteal.OnServerEvent:Connect(function(player, ownerUserId, brainrotUid)
	local victimState = GameState.players[ownerUserId]
	if not victimState then
		return
	end
	local ok, message = StealService.trySteal(player, victimState, brainrotUid)
	if ok then
		ContractService.trackEvent(GameState.getState(player), "steal", 0)
	end
	Remotes.ShowToast:FireClient(player, message)
end)

-- Deliver a stolen brainrot onto your own ring.
Remotes.RequestDeliver.OnServerEvent:Connect(function(player)
	StealService.deliverCarried(player)
end)

-- Slap a thief who is too close.
Remotes.RequestSlap.OnServerEvent:Connect(function(player)
	local ok, message = StealService.slap(player)
	Remotes.ShowToast:FireClient(player, message)
end)

-- Throw the Spotlight Lock over your ring.
Remotes.RequestLockBase.OnServerEvent:Connect(function(player)
	local ok, message = BaseLockService.lockBase(player)
	Remotes.ShowToast:FireClient(player, message)
end)

-- Climb one rung of the Rebirth ladder.
Remotes.RequestRebirth.OnServerEvent:Connect(function(player)
	local ok, message = RebirthService.doRebirth(player)
	if ok then
		local state = GameState.getState(player)
		ContractService.trackEvent(state, "rebirth", 0)
	end
	Remotes.ShowToast:FireClient(player, message)
end)

-- Buy one more slot on your ring.
Remotes.RequestBuySlot.OnServerEvent:Connect(function(player)
	local state = GameState.getState(player)
	if not state then
		return
	end
	local ok, message = BaseManager.buySlot(state)
	Remotes.ShowToast:FireClient(player, message)
end)

-- Claim a finished contract.
Remotes.RequestClaimContract.OnServerEvent:Connect(function(player, contractId)
	local ok, message = ContractService.claimContract(player, contractId)
	Remotes.ShowToast:FireClient(player, message)
end)

-- Claim today's daily reward.
Remotes.RequestClaimDaily.OnServerEvent:Connect(function(player)
	local ok, message = DailyRewardService.claimDaily(player)
	Remotes.ShowToast:FireClient(player, message)
end)

-- The big title sign by the spawn pad, so the island says its own name.
local function buildTitleSign()
	local sign = workspace:FindFirstChild("TitleSign")
	if not sign then
		return
	end
	local gui = Instance.new("SurfaceGui")
	gui.Name = "TitleGui"
	gui.Face = Enum.NormalId.Front
	gui.Parent = sign
	local line1 = Instance.new("TextLabel")
	line1.Name = "Line1"
	line1.Size = UDim2.new(1, 0, 0.5, 0)
	line1.BackgroundTransparency = 1
	line1.Text = "BRAINROT"
	line1.TextColor3 = Color3.fromRGB(255, 210, 40)
	line1.TextScaled = true
	line1.Font = Enum.Font.GothamBold
	line1.Parent = gui
	local line2 = Instance.new("TextLabel")
	line2.Name = "Line2"
	line2.Size = UDim2.new(1, 0, 0.5, 0)
	line2.Position = UDim2.new(0, 0, 0.5, 0)
	line2.BackgroundTransparency = 1
	line2.Text = "BIG TOP"
	line2.TextColor3 = Color3.fromRGB(255, 110, 140)
	line2.TextScaled = true
	line2.Font = Enum.Font.GothamBold
	line2.Parent = gui
end

-- Start the show.
buildTitleSign()
SaveService.start()
ParadeRing.start()
IncomeService.start()
EventService.start()
LeaderboardService.start()
Players.PlayerAdded:Connect(onPlayerAdded)
Players.PlayerRemoving:Connect(onPlayerRemoving)
for _, player in ipairs(Players:GetPlayers()) do
	onPlayerAdded(player)
end

game:BindToClose(function()
	SaveService.saveAllPlayers(GameState.players)
end)
