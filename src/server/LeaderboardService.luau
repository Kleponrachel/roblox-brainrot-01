-- Brainrot Big Top: the richest-player board. Every half minute the
-- server ranks everyone by cash and posts the top five, on the board by
-- the ticket booth and on every client's HUD.

local GameState = require(script.Parent.GameState)
local Remotes = require(script.Parent.Remotes)

local LeaderboardService = {}

-- The top five players by cash, richest first.
function LeaderboardService.topPlayers()
	local rows = {}
	for _, state in pairs(GameState.players) do
		table.insert(rows, { name = state.player.Name, cash = state.cash })
	end
	table.sort(rows, function(a, b)
		return a.cash > b.cash
	end)
	local top = {}
	for i = 1, math.min(5, #rows) do
		table.insert(top, rows[i])
	end
	return top
end

-- Write the ranking onto the board's SurfaceGui in the world, if the
-- board is there, and send it to every client. The SurfaceGui is built
-- here the first time, so the place file only carries the board itself.
function LeaderboardService.publish()
	local top = LeaderboardService.topPlayers()
	local board = workspace:FindFirstChild("LeaderboardBoard")
	if board then
		local gui = board:FindFirstChild("BoardGui")
		if not gui then
			gui = Instance.new("SurfaceGui")
			gui.Name = "BoardGui"
			gui.Face = Enum.NormalId.Front
			gui.Parent = board
			local label = Instance.new("TextLabel")
			label.Name = "Lines"
			label.Size = UDim2.new(1, 0, 1, 0)
			label.BackgroundTransparency = 1
			label.TextColor3 = Color3.fromRGB(255, 255, 255)
			label.TextScaled = true
			label.Font = Enum.Font.GothamBold
			label.TextYAlignment = Enum.TextYAlignment.Top
			label.Parent = gui
		end
		local label = gui:FindFirstChild("Lines")
		if label then
			local lines = "RICHEST RINGMASTERS\n"
			for i, row in ipairs(top) do
				lines = lines .. tostring(i) .. ". " .. row.name .. "  $" .. tostring(row.cash) .. "\n"
			end
			label.Text = lines
		end
	end
	Remotes.UpdateLeaderboard:FireAllClients(top)
end

-- The board's heartbeat: publish every thirty seconds.
function LeaderboardService.start()
	task.spawn(function()
		while true do
			LeaderboardService.publish()
			task.wait(30)
		end
	end)
end

return LeaderboardService
