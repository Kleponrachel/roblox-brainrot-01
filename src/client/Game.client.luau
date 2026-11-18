-- Brainrot Big Top: the client starts here. It builds the HUD, the Dex
-- and the Contract Board, binds the keys, and listens to the server for
-- cash, banners, toasts and the leaderboard.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Hud = require(script.Parent.Hud)
local DexGui = require(script.Parent.DexGui)
local ContractGui = require(script.Parent.ContractGui)
local Controls = require(script.Parent.Controls)

Hud.build()
DexGui.build()
ContractGui.build()
Controls.bind()

local Remotes = ReplicatedStorage

Remotes.UpdateHud.OnClientEvent:Connect(function(cash, income, rebirths)
	Hud.updateCash(cash, income, rebirths)
end)

Remotes.UpdateDex.OnClientEvent:Connect(function(dexState)
	DexGui.showDex(dexState)
end)

Remotes.UpdateContracts.OnClientEvent:Connect(function(rows)
	ContractGui.showContracts(rows)
end)

Remotes.ShowToast.OnClientEvent:Connect(function(text)
	Hud.showToast(text)
end)

Remotes.ShowBanner.OnClientEvent:Connect(function(text)
	Hud.showBanner(text)
end)

Remotes.ShowOfflineEarnings.OnClientEvent:Connect(function(amount, hours, minutes)
	Hud.showOfflineEarnings(amount, hours, minutes)
end)

Remotes.UpdateLeaderboard.OnClientEvent:Connect(function(top)
	Hud.updateLeaderboard(top)
end)

Hud.setHint("Walk to the parade ring and press E to buy an act!")
