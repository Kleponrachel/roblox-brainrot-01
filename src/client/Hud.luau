-- Brainrot Big Top: the player's screen. The HUD sits over the 3D world
-- and never covers the top-left corner, where Roblox's own menu sits:
-- cash and income across the top, the event banner under it, buttons on
-- the right, the leaderboard at the bottom right, and toasts in the
-- middle of the screen.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Hud = {}
Hud.cashLabel = nil
Hud.incomeLabel = nil
Hud.bannerLabel = nil
Hud.hintLabel = nil
Hud.toastLabel = nil
Hud.leaderboardLabel = nil
Hud.carrying = false

-- Build the whole ScreenGui, once, when the client starts.
function Hud.build()
	local player = Players.LocalPlayer
	local gui = Instance.new("ScreenGui")
	gui.Name = "BrainrotBigTopHud"
	gui.ResetOnSpawn = false
	gui.Parent = player:WaitForChild("PlayerGui")

	local cash = Instance.new("TextLabel")
	cash.Name = "Cash"
	cash.Size = UDim2.new(0, 360, 0, 56)
	cash.Position = UDim2.new(0.5, -180, 0, 8)
	cash.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
	cash.BackgroundTransparency = 0.25
	cash.Text = "$100"
	cash.TextColor3 = Color3.fromRGB(255, 220, 60)
	cash.TextScaled = true
	cash.Font = Enum.Font.GothamBold
	cash.Parent = gui
	Hud.cashLabel = cash

	local income = Instance.new("TextLabel")
	income.Name = "Income"
	income.Size = UDim2.new(0, 360, 0, 30)
	income.Position = UDim2.new(0.5, -180, 0, 66)
	income.BackgroundTransparency = 1
	income.Text = "$0/s"
	income.TextColor3 = Color3.fromRGB(120, 255, 140)
	income.TextScaled = true
	income.Font = Enum.Font.GothamBold
	income.Parent = gui
	Hud.incomeLabel = income

	local banner = Instance.new("TextLabel")
	banner.Name = "EventBanner"
	banner.Size = UDim2.new(0, 520, 0, 40)
	banner.Position = UDim2.new(0.5, -260, 0, 100)
	banner.BackgroundColor3 = Color3.fromRGB(150, 40, 180)
	banner.BackgroundTransparency = 0.2
	banner.Text = ""
	banner.TextColor3 = Color3.fromRGB(255, 255, 255)
	banner.TextScaled = true
	banner.Font = Enum.Font.GothamBold
	banner.Visible = false
	banner.Parent = gui
	Hud.bannerLabel = banner

	local hint = Instance.new("TextLabel")
	hint.Name = "Hint"
	hint.Size = UDim2.new(0, 520, 0, 36)
	hint.Position = UDim2.new(0.5, -260, 1, -120)
	hint.BackgroundTransparency = 1
	hint.Text = "Walk to the parade ring and press E to buy an act!"
	hint.TextColor3 = Color3.fromRGB(255, 255, 255)
	hint.TextStrokeTransparency = 0.2
	hint.TextScaled = true
	hint.Font = Enum.Font.GothamBold
	hint.Parent = gui
	Hud.hintLabel = hint

	local toast = Instance.new("TextLabel")
	toast.Name = "Toast"
	toast.Size = UDim2.new(0, 560, 0, 40)
	toast.Position = UDim2.new(0.5, -280, 0.5, -120)
	toast.BackgroundTransparency = 1
	toast.Text = ""
	toast.TextColor3 = Color3.fromRGB(255, 255, 255)
	toast.TextStrokeTransparency = 0.1
	toast.TextScaled = true
	toast.Font = Enum.Font.GothamBold
	toast.Parent = gui
	Hud.toastLabel = toast

	local board = Instance.new("TextLabel")
	board.Name = "Leaderboard"
	board.Size = UDim2.new(0, 260, 0, 150)
	board.Position = UDim2.new(1, -270, 1, -160)
	board.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
	board.BackgroundTransparency = 0.3
	board.Text = "RICHEST RINGMASTERS"
	board.TextColor3 = Color3.fromRGB(255, 255, 255)
	board.TextScaled = true
	board.Font = Enum.Font.GothamBold
	board.TextYAlignment = Enum.TextYAlignment.Top
	board.Parent = gui
	Hud.leaderboardLabel = board

	Hud.buildButtons(gui)
end

-- The buttons down the right side: Dex, Contracts, Daily, Lock, Rebirth.
function Hud.buildButtons(gui)
	local buttons = {
		{ name = "Dex", text = "DEX", action = "dex" },
		{ name = "Contracts", text = "CONTRACTS", action = "contracts" },
		{ name = "Daily", text = "DAILY", action = "daily" },
		{ name = "Lock", text = "LOCK RING", action = "lock" },
		{ name = "Rebirth", text = "REBIRTH", action = "rebirth" },
		{ name = "Slot", text = "+ SLOT", action = "slot" },
	}
	for i, button in ipairs(buttons) do
		local btn = Instance.new("TextButton")
		btn.Name = button.name
		btn.Size = UDim2.new(0, 140, 0, 40)
		btn.Position = UDim2.new(1, -150, 0, 20 + (i - 1) * 48)
		btn.BackgroundColor3 = Color3.fromRGB(200, 60, 120)
		btn.Text = button.text
		btn.TextColor3 = Color3.fromRGB(255, 255, 255)
		btn.TextScaled = true
		btn.Font = Enum.Font.GothamBold
		btn.Parent = gui
		btn.MouseButton1Click:Connect(function()
			Hud.onButton(button.action)
		end)
	end
end

-- What each button does. Dex and Contracts open their windows; the rest
-- ask the server straight away.
function Hud.onButton(action)
	local remotes = ReplicatedStorage:WaitForChild("RequestLockBase")
	if action == "lock" then
		ReplicatedStorage.RequestLockBase:FireServer()
	elseif action == "rebirth" then
		ReplicatedStorage.RequestRebirth:FireServer()
	elseif action == "slot" then
		ReplicatedStorage.RequestBuySlot:FireServer()
	elseif action == "daily" then
		ReplicatedStorage.RequestClaimDaily:FireServer()
	elseif action == "dex" then
		require(script.Parent.DexGui).toggle()
	elseif action == "contracts" then
		require(script.Parent.ContractGui).toggle()
	end
end

-- Fresh numbers from the server, once a second.
function Hud.updateCash(cash, income, rebirths)
	if Hud.cashLabel then
		Hud.cashLabel.Text = "$" .. tostring(math.floor(cash))
	end
	if Hud.incomeLabel then
		local text = "$" .. tostring(math.floor(income)) .. "/s"
		if rebirths > 0 then
			text = text .. "   Rebirth x" .. tostring(1 + 0.5 * rebirths)
		end
		Hud.incomeLabel.Text = text
	end
end

-- A big banner across the top for a few seconds: an event has begun.
function Hud.showBanner(text)
	if not Hud.bannerLabel then
		return
	end
	Hud.bannerLabel.Text = text
	Hud.bannerLabel.Visible = true
	task.delay(5, function()
		if Hud.bannerLabel then
			Hud.bannerLabel.Visible = false
		end
	end)
end

-- A short message in the middle of the screen.
function Hud.showToast(text)
	if not Hud.toastLabel then
		return
	end
	Hud.toastLabel.Text = text
	task.delay(3, function()
		if Hud.toastLabel and Hud.toastLabel.Text == text then
			Hud.toastLabel.Text = ""
		end
	end)
end

-- The offline earnings popup: what the ring earned while you were away.
function Hud.showOfflineEarnings(amount, hours, minutes)
	Hud.showToast("Welcome back! Your ring earned $" .. tostring(amount) .. " in " .. tostring(hours) .. "h " .. tostring(minutes) .. "m away.")
end

-- The richest five, on the board at the bottom right.
function Hud.updateLeaderboard(top)
	if not Hud.leaderboardLabel then
		return
	end
	local text = "RICHEST RINGMASTERS\n"
	for i, row in ipairs(top) do
		text = text .. tostring(i) .. ". " .. row.name .. "  $" .. tostring(math.floor(row.cash)) .. "\n"
	end
	Hud.leaderboardLabel.Text = text
end

-- The hint line at the bottom: what to do next.
function Hud.setHint(text)
	if Hud.hintLabel then
		Hud.hintLabel.Text = text
	end
end

return Hud
