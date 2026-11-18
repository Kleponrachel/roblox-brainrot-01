-- Brainrot Big Top: BrainrotFactory builds the 3D body of a brainrot from
-- its catalog entry and mutation. Every act is a small blocky performer:
-- a coloured body, a head, one accessory that says who it is, and a
-- billboard above it with its name, rarity and money a second.

local Catalog = require(game:GetService("ReplicatedStorage").Shared.BrainrotCatalog)

local BrainrotFactory = {}
BrainrotFactory.nextUid = 0

-- A fresh unique id for a brainrot record.
function BrainrotFactory.newUid()
	BrainrotFactory.nextUid = BrainrotFactory.nextUid + 1
	return "br_" .. tostring(os.time()) .. "_" .. tostring(BrainrotFactory.nextUid)
end

-- A plain record for a brainrot: who it is, its mutation, its unique id.
function BrainrotFactory.newRecord(character, mutation)
	return {
		uid = BrainrotFactory.newUid(),
		characterId = character.id,
		mutation = mutation,
	}
end

-- The accessory for one hat kind, parented to the model's body.
function BrainrotFactory.buildAccessory(hat, body, color)
	if hat == "Cone" then
		local cone = Instance.new("WedgePart")
		cone.Name = "Hat"
		cone.Size = Vector3.new(1.2, 1.2, 1.2)
		cone.Color = Color3.fromRGB(255, 210, 40)
		cone.Position = body.Position + Vector3.new(0, 1.6, 0)
		cone.Anchored = true
		cone.CanCollide = false
		cone.Parent = body.Parent
		return cone
	elseif hat == "TopHat" then
		local top = Instance.new("Part")
		top.Name = "Hat"
		top.Shape = Enum.PartType.Cylinder
		top.Size = Vector3.new(1.4, 0.9, 0.9)
		top.Color = Color3.fromRGB(30, 30, 30)
		top.Position = body.Position + Vector3.new(0, 1.7, 0)
		top.Anchored = true
		top.CanCollide = false
		top.Parent = body.Parent
		return top
	elseif hat == "Crown" then
		local crown = Instance.new("Part")
		crown.Name = "Hat"
		crown.Size = Vector3.new(1.4, 0.4, 1.4)
		crown.Color = Color3.fromRGB(255, 210, 40)
		crown.Material = Enum.Material.Neon
		crown.Position = body.Position + Vector3.new(0, 1.6, 0)
		crown.Anchored = true
		crown.CanCollide = false
		crown.Parent = body.Parent
		return crown
	elseif hat == "Sombrero" then
		local brim = Instance.new("Part")
		brim.Name = "Hat"
		brim.Shape = Enum.PartType.Cylinder
		brim.Size = Vector3.new(0.4, 2.2, 2.2)
		brim.Color = Color3.fromRGB(255, 170, 60)
		brim.Position = body.Position + Vector3.new(0, 1.5, 0)
		brim.Anchored = true
		brim.CanCollide = false
		brim.Parent = body.Parent
		return brim
	elseif hat == "Cup" then
		local cup = Instance.new("Part")
		cup.Name = "Hat"
		cup.Shape = Enum.PartType.Cylinder
		cup.Size = Vector3.new(0.9, 0.7, 0.7)
		cup.Color = Color3.fromRGB(240, 230, 210)
		cup.Position = body.Position + Vector3.new(0, 1.7, 0)
		cup.Anchored = true
		cup.CanCollide = false
		cup.Parent = body.Parent
		return cup
	elseif hat == "Bucket" then
		local bucket = Instance.new("Part")
		bucket.Name = "Hat"
		bucket.Shape = Enum.PartType.Cylinder
		bucket.Size = Vector3.new(1, 1.1, 1.1)
		bucket.Color = Color3.fromRGB(255, 90, 90)
		bucket.Position = body.Position + Vector3.new(0, 1.6, 0)
		bucket.Anchored = true
		bucket.CanCollide = false
		bucket.Parent = body.Parent
		return bucket
	end
	-- Ball, Turban, Helmet, Beard, Monocle, Wizard: a bright ball on top.
	local ball = Instance.new("Part")
	ball.Name = "Hat"
	ball.Shape = Enum.PartType.Ball
	ball.Size = Vector3.new(0.9, 0.9, 0.9)
	ball.Color = color
	ball.Position = body.Position + Vector3.new(0, 1.6, 0)
	ball.Anchored = true
	ball.CanCollide = false
	ball.Parent = body.Parent
	return ball
end

-- The name tag every brainrot wears: name, rarity and money a second.
function BrainrotFactory.buildLabel(model, character, mutation)
	local head = model:FindFirstChild("Head")
	if not head then
		return
	end
	local gui = Instance.new("BillboardGui")
	gui.Name = "BrainrotLabel"
	gui.Size = UDim2.new(0, 200, 0, 70)
	gui.StudsOffset = Vector3.new(0, 2.5, 0)
	gui.AlwaysOnTop = true
	gui.Parent = head
	local nameLabel = Instance.new("TextLabel")
	nameLabel.Name = "Name"
	nameLabel.Size = UDim2.new(1, 0, 0.5, 0)
	nameLabel.BackgroundTransparency = 1
	nameLabel.Text = Catalog.labelFor(character, mutation)
	nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	nameLabel.TextStrokeTransparency = 0.2
	nameLabel.TextScaled = true
	nameLabel.Font = Enum.Font.GothamBold
	nameLabel.Parent = gui
	local incomeLabel = Instance.new("TextLabel")
	incomeLabel.Name = "Income"
	incomeLabel.Size = UDim2.new(1, 0, 0.5, 0)
	incomeLabel.Position = UDim2.new(0, 0, 0.5, 0)
	incomeLabel.BackgroundTransparency = 1
	incomeLabel.Text = "$" .. tostring(Catalog.incomeOf(character, mutation)) .. "/s  |  " .. character.rarity
	incomeLabel.TextColor3 = Catalog.rarityColor(character.rarity)
	incomeLabel.TextStrokeTransparency = 0.2
	incomeLabel.TextScaled = true
	incomeLabel.Font = Enum.Font.GothamBold
	incomeLabel.Parent = gui
end

-- Build the whole Model for one brainrot record at a position.
function BrainrotFactory.buildBrainrot(record, position)
	local character = Catalog.getCharacter(record.characterId)
	if not character then
		return nil
	end
	local model = Instance.new("Model")
	model.Name = Catalog.labelFor(character, record.mutation)
	local body = Instance.new("Part")
	body.Name = "Body"
	body.Size = Vector3.new(2, 2, 2)
	body.Color = character.body
	body.Material = Enum.Material.SmoothPlastic
	body.Position = position
	body.Anchored = true
	body.CanCollide = false
	body.Parent = model
	local head = Instance.new("Part")
	head.Name = "Head"
	head.Shape = Enum.PartType.Ball
	head.Size = Vector3.new(1.6, 1.6, 1.6)
	head.Color = Color3.fromRGB(255, 220, 180)
	head.Position = position + Vector3.new(0, 1.8, 0)
	head.Anchored = true
	head.CanCollide = false
	head.Parent = model
	BrainrotFactory.buildAccessory(character.hat, body, character.body)
	-- A mutation tints the body with its own colour and a glow.
	if record.mutation then
		body.Color = record.mutation.color
		body.Material = Enum.Material.Neon
	end
	model.PrimaryPart = body
	BrainrotFactory.buildLabel(model, character, record.mutation)
	local tag = Instance.new("StringValue")
	tag.Name = "BrainrotUid"
	tag.Value = record.uid
	tag.Parent = model
	return model
end

return BrainrotFactory
