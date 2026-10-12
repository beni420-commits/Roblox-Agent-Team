--!strict
-- Minimaler, abhängigkeitsfreier Testrunner für reine Logik-Module (läuft im Luau-CLI ohne Roblox).
-- Bewusst keine externe Bibliothek: TestEZ/Jest-Lua bräuchten Owner-Freigabe (Masterprompt §8.5).

export type Expectation = {
	toBe: (self: Expectation, expected: any) -> (),
	toEqual: (self: Expectation, expected: any) -> (),
	toBeNear: (self: Expectation, expected: number, epsilon: number?) -> (),
	toThrow: (self: Expectation) -> (),
	toBeTruthy: (self: Expectation) -> (),
	toBeFalsy: (self: Expectation) -> (),
}

export type Suite = {
	name: string,
	tests: { { name: string, fn: () -> () } },
}

local TestRunner = {}

local function describeValue(value: any): string
	if type(value) == "string" then
		return string.format("%q", value)
	end
	return tostring(value)
end

local function deepEqual(a: any, b: any): boolean
	if a == b then
		return true
	end
	if a ~= a and b ~= b then
		return true -- NaN == NaN für Testzwecke
	end
	if type(a) ~= "table" or type(b) ~= "table" then
		return false
	end
	for key, value in a do
		if not deepEqual(value, b[key]) then
			return false
		end
	end
	for key in b do
		if a[key] == nil then
			return false
		end
	end
	return true
end

function TestRunner.expect(actual: any): Expectation
	local expectation = {}

	function expectation.toBe(_self: Expectation, expected: any)
		if actual ~= expected then
			error(string.format("expected %s to be %s", describeValue(actual), describeValue(expected)), 2)
		end
	end

	function expectation.toEqual(_self: Expectation, expected: any)
		if not deepEqual(actual, expected) then
			error(string.format("expected %s to deep-equal %s", describeValue(actual), describeValue(expected)), 2)
		end
	end

	function expectation.toBeNear(_self: Expectation, expected: number, epsilon: number?)
		local eps = epsilon or 1e-9
		if type(actual) ~= "number" or math.abs(actual - expected) > eps then
			error(
				string.format(
					"expected %s to be within %s of %s",
					describeValue(actual),
					tostring(eps),
					tostring(expected)
				),
				2
			)
		end
	end

	function expectation.toThrow(_self: Expectation)
		local ok = pcall(actual)
		if ok then
			error("expected function to throw", 2)
		end
	end

	function expectation.toBeTruthy(_self: Expectation)
		if not actual then
			error(string.format("expected %s to be truthy", describeValue(actual)), 2)
		end
	end

	function expectation.toBeFalsy(_self: Expectation)
		if actual then
			error(string.format("expected %s to be falsy", describeValue(actual)), 2)
		end
	end

	return (expectation :: any) :: Expectation
end

function TestRunner.suite(name: string): Suite
	return { name = name, tests = {} }
end

function TestRunner.it(suite: Suite, name: string, fn: () -> ())
	table.insert(suite.tests, { name = name, fn = fn })
end

-- Führt alle Suites aus; wirft am Ende einen Fehler (Exit-Code ≠ 0), wenn ein Test fehlschlägt.
function TestRunner.run(suites: { Suite })
	local passed, failed = 0, 0
	for _, suite in suites do
		print(string.format("▶ %s", suite.name))
		for _, test in suite.tests do
			local ok, err = pcall(test.fn)
			if ok then
				passed += 1
				print(string.format("  ✓ %s", test.name))
			else
				failed += 1
				print(string.format("  ✗ %s\n      %s", test.name, tostring(err)))
			end
		end
	end
	print(string.format("\n%d bestanden, %d fehlgeschlagen, %d gesamt", passed, failed, passed + failed))
	if failed > 0 then
		error(string.format("%d Test(s) fehlgeschlagen", failed), 0)
	end
end

return TestRunner
