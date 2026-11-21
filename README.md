# Installation

Download the latest release : https://github.com/patafouinerie-arch/roUnit/releases/latest
Import roUnit.rbxm in roblox studio by dragging it into your desired location (I recommend ReplicatedStorage)

# Usage
```luau
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local roUnit = require(ReplicatedStorage.Shared.classes.roUnit)

local testService = {}

function testService.add(a: number, b: number): number
	return a + b
end

function testService:init()
	print(script.Name.." initialized.")
	
	local unitTests = roUnit.new({
		verbose = true;
		timeout = 3;
	})
	
	unitTests:testFunction(testService, "add", {2, 3}) -- Passing test
	unitTests:testFunction(testService, "add", {2, "Error Inducing String"}) -- Failing test
end

return table.freeze(testService)
```
