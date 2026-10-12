--!strict
-- Meldet das bevorzugte Eingabegerät (Telemetrie-Feld 1) und stellt es anderen Controllern bereit.

local UserInputService = game:GetService("UserInputService")

local Context = require("./Context")

local InputController = {}

function InputController.current(): string
	return UserInputService.PreferredInput.Name
end

function InputController.start(context: Context.Context)
	local function report()
		local name = InputController.current()
		if name == "Touch" or name == "KeyboardAndMouse" or name == "Gamepad" then
			context.fire("ReportPreferredInput", name)
		end
	end
	report()
	UserInputService:GetPropertyChangedSignal("PreferredInput"):Connect(report)
end

return InputController
