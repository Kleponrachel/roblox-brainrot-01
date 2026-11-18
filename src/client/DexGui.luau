-- Brainrot Big Top: the BrainrotDex window. Twelve cards in a grid, one
-- per act: discovered acts show their name, rarity, income and joke,
-- undiscovered ones show only a question mark. The header shows the
-- completion bonus the book already pays.

local Players = game:GetService("Players")

local DexGui = {}
DexGui.frame = nil
DexGui.open = false

-- Build the window once, hidden, and fill it when the server sends the book.
function DexGui.build()
	local player = Players.LocalPlayer
	local gui = Instance.new("ScreenGui")
	gui.Name = "BrainrotDexGui"
	gui.ResetOnSpawn = false
	gui.Parent = player:WaitForChild("PlayerGui")
	local frame = Instance.new("Frame")
	frame.Name = "DexWindow"
	frame.Size = UDim2.new(0, 640, 0, 480)
	frame.Position = UDim2.new(0.5, -320, 0.5, -240)
	frame.BackgroundColor3 = Color3.fromRGB(25, 25, 40)
	frame.Visible = false
	frame.Parent = gui
	local title = Instance.new("TextLabel")
	title.Name = "Title"
	title.Size = UDim2.new(1, 0, 0, 44)
	title.BackgroundTransparency = 1
	title.Text = "BRAINROT DEX"
	title.TextColor3 = Color3.fromRGB(255, 220, 60)
	title.TextScaled = true
	title.Font = Enum.Font.GothamBold
	title.Parent = frame
	local bonus = Instance.new("TextLabel")
	bonus.Name = "Bonus"
	bonus.Size = UDim2.new(1, 0, 0, 28)
	bonus.Position = UDim2.new(0, 0, 0, 44)
	bonus.BackgroundTransparency = 1
	bonus.Text = ""
	bonus.TextColor3 = Color3.fromRGB(120, 255, 140)
	bonus.TextScaled = true
	bonus.Font = Enum.Font.GothamBold
	bonus.Parent = frame
	local close = Instance.new("TextButton")
	close.Name = "Close"
	close.Size = UDim2.new(0, 80, 0, 36)
	close.Position = UDim2.new(1, -88, 0, 8)
	close.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
	close.Text = "CLOSE"
	close.TextColor3 = Color3.fromRGB(255, 255, 255)
	close.TextScaled = true
	close.Font = Enum.Font.GothamBold
	close.Parent = frame
	close.MouseButton1Click:Connect(function()
		DexGui.toggle()
	end)
	DexGui.frame = frame
end

-- Draw the book from the server's rows.
function DexGui.showDex(dexState)
	if not DexGui.frame then
		return
	end
	local bonus = DexGui.frame:FindFirstChild("Bonus")
	if bonus then
		bonus.Text = "Discovered " .. tostring(dexState.discovered) .. "/" .. tostring(dexState.total) .. "  |  Dex bonus +" .. tostring(dexState.bonus) .. "% income"
	end
	local old = DexGui.frame:FindFirstChild("Grid")
	if old then
		old:Destroy()
	end
	local grid = Instance.new("Frame")
	grid.Name = "Grid"
	grid.Size = UDim2.new(1, -16, 1, -88)
	grid.Position = UDim2.new(0, 8, 0, 80)
	grid.BackgroundTransparency = 1
	grid.Parent = DexGui.frame
	for i, row in ipairs(dexState.rows) do
		local col = (i - 1) % 4
		local line = math.floor((i - 1) / 4)
		local card = Instance.new("Frame")
		card.Size = UDim2.new(0, 148, 0, 120)
		card.Position = UDim2.new(0, col * 156, 0, line * 128)
		card.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
		card.Parent = grid
		local name = Instance.new("TextLabel")
		name.Size = UDim2.new(1, -8, 0, 26)
		name.Position = UDim2.new(0, 4, 0, 4)
		name.BackgroundTransparency = 1
		name.Text = row.discovered and row.name or "???"
		name.TextColor3 = Color3.fromRGB(255, 255, 255)
		name.TextScaled = true
		name.Font = Enum.Font.GothamBold
		name.Parent = card
		local rarity = Instance.new("TextLabel")
		rarity.Size = UDim2.new(1, -8, 0, 22)
		rarity.Position = UDim2.new(0, 4, 0, 32)
		rarity.BackgroundTransparency = 1
		rarity.Text = row.discovered and row.rarity or "???"
		rarity.TextColor3 = Color3.fromRGB(255, 220, 60)
		rarity.TextScaled = true
		rarity.Font = Enum.Font.GothamBold
		rarity.Parent = card
		local income = Instance.new("TextLabel")
		income.Size = UDim2.new(1, -8, 0, 22)
		income.Position = UDim2.new(0, 4, 0, 56)
		income.BackgroundTransparency = 1
		income.Text = row.discovered and ("$" .. tostring(row.income) .. "/s") or ""
		income.TextColor3 = Color3.fromRGB(120, 255, 140)
		income.TextScaled = true
		income.Font = Enum.Font.GothamBold
		income.Parent = card
		local blurb = Instance.new("TextLabel")
		blurb.Size = UDim2.new(1, -8, 0, 34)
		blurb.Position = UDim2.new(0, 4, 0, 80)
		blurb.BackgroundTransparency = 1
		blurb.Text = row.discovered and row.blurb or "Not discovered yet."
		blurb.TextColor3 = Color3.fromRGB(200, 200, 200)
		blurb.TextScaled = true
		blurb.TextWrapped = true
		blurb.Font = Enum.Font.Gotham
		blurb.Parent = card
	end
end

-- Open the book, or close it when it is open.
function DexGui.toggle()
	if not DexGui.frame then
		return
	end
	DexGui.open = not DexGui.open
	DexGui.frame.Visible = DexGui.open
end

return DexGui
