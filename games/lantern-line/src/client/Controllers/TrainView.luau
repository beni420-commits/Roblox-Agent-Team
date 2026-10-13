--!strict
-- Sicht des Clients auf den gebauten Zug (Attribute der Wagen-Modelle vom Server).

local TrainView = {}

function TrainView.folder(): Instance?
	return workspace:FindFirstChild("Train")
end

-- Wagen-Index an Welt-x (Übergang zählt zum folgenden Wagen), sonst nil.
function TrainView.carriageAt(x: number): number?
	local train = TrainView.folder()
	if train == nil then
		return nil
	end
	for _, model in train:GetChildren() do
		local origin = model:GetAttribute("OriginX")
		local length = model:GetAttribute("Length")
		local index = model:GetAttribute("Index")
		if type(origin) == "number" and type(length) == "number" and type(index) == "number" then
			if x >= origin - 4 and x <= origin + length then
				return index
			end
		end
	end
	return nil
end

function TrainView.carriageModel(index: number): Model?
	local train = TrainView.folder()
	local model = if train then train:FindFirstChild(string.format("Carriage_%02d", index)) else nil
	return if model and model:IsA("Model") then model else nil
end

function TrainView.origin(index: number): number?
	local model = TrainView.carriageModel(index)
	local origin = if model then model:GetAttribute("OriginX") else nil
	return if type(origin) == "number" then origin else nil
end

return TrainView
