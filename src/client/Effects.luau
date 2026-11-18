-- Brainrot Big Top: Effects is the game's confetti and sparkle. A burst
-- of coloured paper over the ring when a rare act is bought, a golden
-- fountain when a rebirth lands, and floating "+$" text over the ring
-- every time the money ticks.

local Effects = {}

-- A burst of confetti parts above a position, falling and fading away.
function Effects.confettiBurst(position, color)
	for i = 1, 24 do
		local piece = Instance.new("Part")
		piece.Size = Vector3.new(0.4, 0.1, 0.4)
		piece.Color = color or Color3.fromRGB(255, 210, 40)
		piece.Material = Enum.Material.Neon
		piece.Anchored = true
		piece.CanCollide = false
		piece.Position = position + Vector3.new(math.random(-4, 4), math.random(2, 6), math.random(-4, 4))
		piece.Parent = workspace
		task.spawn(function()
			for step = 1, 20 do
				piece.Position = piece.Position + Vector3.new(0, -0.3, 0)
				piece.CFrame = piece.CFrame * CFrame.Angles(0.2, 0.3, 0)
				task.wait(0.05)
			end
			piece:Destroy()
		end)
	end
end

-- Golden confetti over the whole ring, for a rebirth.
function Effects.goldenFountain(position)
	Effects.confettiBurst(position, Color3.fromRGB(255, 210, 40))
	Effects.confettiBurst(position + Vector3.new(6, 0, 0), Color3.fromRGB(255, 110, 220))
	Effects.confettiBurst(position + Vector3.new(-6, 0, 0), Color3.fromRGB(120, 220, 255))
end

-- Floating "+$123" text that rises and fades above a position.
function Effects.floatCash(position, amount)
	local gui = Instance.new("BillboardGui")
	gui.Size = UDim2.new(0, 120, 0, 40)
	gui.StudsOffset = Vector3.new(0, 3, 0)
	gui.AlwaysOnTop = true
	local anchor = Instance.new("Part")
	anchor.Size = Vector3.new(0.2, 0.2, 0.2)
	anchor.Transparency = 1
	anchor.Anchored = true
	anchor.CanCollide = false
	anchor.Position = position
	anchor.Parent = workspace
	gui.Parent = anchor
	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, 0, 1, 0)
	label.BackgroundTransparency = 1
	label.Text = "+$" .. tostring(amount)
	label.TextColor3 = Color3.fromRGB(120, 255, 140)
	label.TextStrokeTransparency = 0.1
	label.TextScaled = true
	label.Font = Enum.Font.GothamBold
	label.Parent = gui
	task.spawn(function()
		for step = 1, 20 do
			anchor.Position = anchor.Position + Vector3.new(0, 0.25, 0)
			task.wait(0.05)
		end
		anchor:Destroy()
	end)
end

return Effects
