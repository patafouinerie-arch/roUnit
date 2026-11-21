export type props = {
	modules: {ModuleScript};
	functions: {[string]: () -> ()};
	verbose: boolean?;
	timeout: number?;
}

local roUnit = {}
roUnit.__index = roUnit

function roUnit.new(props: props)
	local self = setmetatable({}, roUnit)

	self.modules = props.modules or {}
	self.functions = props.functions or {}
	self.verbose = props.verbose or false
	self.timeout = props.timeout or 10

	self.successes = 0
	self.failures = 0
	self.errors = 0
	self.skips = 0

	return self
end

function roUnit:getModuleFunctions(module: ModuleScript)
	if not module:IsA("ModuleScript") then
		return
	end

	local success, result = pcall(function()
		return require(module)
	end)

	if not success then
		warn(`[TestRunner] Failed to require module {module.Name}: {result}`)
		return
	end

	local functions = {}
	for name, func in pairs(result) do
		if typeof(func) == "function" then
			functions[name] = func
		end
	end

	return functions
end

function roUnit:getAllModulesFunctions()
	local functions = {}
	for _, module in ipairs(self.modules) do
		local moduleFunctions = self:getModuleFunctions(module)
		if moduleFunctions then
			for name, func in pairs(moduleFunctions) do
				functions[name] = func
			end
		end
	end

	return functions
end

function roUnit:testFunction(moduleDict, fn: string, args: {any})
	local startTime = os.clock()
	local success, result = pcall(function()
		moduleDict[fn](table.unpack(args))
	end)

	local endTime = os.clock()
	local duration = endTime - startTime

	if success then
		if self.verbose then
			print(`[TestRunner] ✅ function : {fn} passed (took {duration} seconds)`)
		end
		self.successes += 1
	else
		self.failures += 1
		warn(`[TestRunner] ❌ funciton : {fn} failed: {result}`)
	end

	return success, result
end

function roUnit:runAllFunctions()
	local allFunctions = self:getAllModulesFunctions()

	for name, fn in pairs(allFunctions) do
		self:testFunction(fn)
	end

	return self
end

return table.freeze(roUnit)
