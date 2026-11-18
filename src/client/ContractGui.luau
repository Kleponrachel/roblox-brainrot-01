-- Brainrot Big Top: the Contract Board window. Three jobs, each with a
-- progress bar and a Claim button that lights up when the job is done.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ContractGui = {}
ContractGui.frame = nil
ContractGui.open = false

-- Build the window once, hidden, and fill it when the server sends the board.
function ContractGui.build()
	local player = Players.LocalPlayer
	local gui = Instance.new("ScreenGui")
	gui.Name = "ContractBoardGui"
	gui.ResetOnSpawn = false
	gui.Parent = player:WaitForChild("PlayerGui")
	local frame = Instance.new("Frame")
	frame.Name = "ContractWindow"
	frame.Size = UDim2.new(0, 560, 0, 320)
	frame.Position = UDim2.new(0.5, -280, 0.5, -160)
	frame.BackgroundColor3 = Color3.fromRGB(25, 25, 40)
	frame.Visible = false
	frame.Parent = gui
	local title = Instance.new("TextLabel")
	title.Name = "Title"
	title.Size = UDim2.new(1, 0, 0, 44)
	title.BackgroundTransparency = 1
	title.Text = "CONTRACT BOARD"
	title.TextColor3 = Color3.fromRGB(255, 220, 60)
	title.TextScaled = true
	title.Font = Enum.Font.GothamBold
	title.Parent = frame
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
		ContractGui.toggle()
	end)
	ContractGui.frame = frame
end

-- Draw the board from the server's rows.
function ContractGui.showContracts(rows)
	if not ContractGui.frame then
		return
	end
	local old = ContractGui.frame:FindFirstChild("List")
	if old then
		old:Destroy()
	end
	local list = Instance.new("Frame")
	list.Name = "List"
	list.Size = UDim2.new(1, -16, 1, -56)
	list.Position = UDim2.new(0, 8, 0, 48)
	list.BackgroundTransparency = 1
	list.Parent = ContractGui.frame
	for i, row in ipairs(rows) do
		local card = Instance.new("Frame")
		card.Size = UDim2.new(1, 0, 0, 76)
		card.Position = UDim2.new(0, 0, 0, (i - 1) * 84)
		card.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
		card.Parent = list
		local text = Instance.new("TextLabel")
		text.Size = UDim2.new(1, -120, 0, 30)
		text.Position = UDim2.new(0, 8, 0, 6)
		text.BackgroundTransparency = 1
		text.Text = row.text .. "  (" .. tostring(math.min(row.progress, row.target)) .. "/" .. tostring(row.target) .. ")"
		text.TextColor3 = Color3.fromRGB(255, 255, 255)
		text.TextScaled = true
		text.Font = Enum.Font.GothamBold
		text.TextXAlignment = Enum.TextXAlignment.Left
		text.Parent = card
		local reward = Instance.new("TextLabel")
		reward.Size = UDim2.new(1, -120, 0, 24)
		reward.Position = UDim2.new(0, 8, 0, 40)
		reward.BackgroundTransparency = 1
		reward.Text = "Reward: $" .. tostring(row.reward)
		reward.TextColor3 = Color3.fromRGB(120, 255, 140)
		reward.TextScaled = true
		reward.Font = Enum.Font.GothamBold
		reward.TextXAlignment = Enum.TextXAlignment.Left
		reward.Parent = card
		local claim = Instance.new("TextButton")
		claim.Size = UDim2.new(0, 96, 0, 40)
		claim.Position = UDim2.new(1, -104, 0, 18)
		claim.BackgroundColor3 = row.done and Color3.fromRGB(60, 200, 90) or Color3.fromRGB(90, 90, 90)
		claim.Text = row.done and "CLAIM" or "LOCKED"
		claim.TextColor3 = Color3.fromRGB(255, 255, 255)
		claim.TextScaled = true
		claim.Font = Enum.Font.GothamBold
		claim.Parent = card
		claim.MouseButton1Click:Connect(function()
			if row.done then
				ReplicatedStorage.RequestClaimContract:FireServer(row.id)
			end
		end)
	end
end

-- Open the board, or close it when it is open.
function ContractGui.toggle()
	if not ContractGui.frame then
		return
	end
	ContractGui.open = not ContractGui.open
	ContractGui.frame.Visible = ContractGui.open
end

return ContractGui
