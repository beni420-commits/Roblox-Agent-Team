--!strict
local TestRunner = require("../../TestRunner")
local RateLimiter = require("../../../src/shared/Util/RateLimiter")

local expect = TestRunner.expect
local suite = TestRunner.suite("shared/Util/RateLimiter")

local function fakeClock()
	local now = 0
	return function(): number
		return now
	end, function(dt: number)
		now += dt
	end
end

TestRunner.it(suite, "Burst wird gewährt, danach gedrosselt", function()
	local clock = fakeClock()
	local limiter = RateLimiter.new({ perSecond = 2, burst = 3, clock = clock })
	expect(limiter.consume("p1")):toBe(true)
	expect(limiter.consume("p1")):toBe(true)
	expect(limiter.consume("p1")):toBe(true)
	expect(limiter.consume("p1")):toBe(false)
end)

TestRunner.it(suite, "Tokens füllen sich mit der Zeit wieder auf (bis Burst)", function()
	local clock, advance = fakeClock()
	local limiter = RateLimiter.new({ perSecond = 2, burst = 3, clock = clock })
	for _ = 1, 3 do
		limiter.consume("p1")
	end
	expect(limiter.consume("p1")):toBe(false)
	advance(0.5)
	expect(limiter.consume("p1")):toBe(true)
	expect(limiter.consume("p1")):toBe(false)
	advance(100)
	local granted = 0
	for _ = 1, 10 do
		if limiter.consume("p1") then
			granted += 1
		end
	end
	expect(granted):toBe(3)
end)

TestRunner.it(suite, "Spam: 1000 Aufrufe in 1 s → höchstens Burst + Rate durch", function()
	local clock, advance = fakeClock()
	local limiter = RateLimiter.new({ perSecond = 10, burst = 20, clock = clock })
	local granted = 0
	for _ = 1, 1000 do
		advance(0.001)
		if limiter.consume("spammer") then
			granted += 1
		end
	end
	expect(granted <= 31):toBeTruthy()
end)

TestRunner.it(suite, "Schlüssel sind getrennt; forget/forgetPrefix setzen zurück", function()
	local clock = fakeClock()
	local limiter = RateLimiter.new({ perSecond = 1, burst = 1, clock = clock })
	expect(limiter.consume("1:A")):toBe(true)
	expect(limiter.consume("2:A")):toBe(true)
	expect(limiter.consume("1:A")):toBe(false)
	limiter.forgetPrefix("1:")
	expect(limiter.consume("1:A")):toBe(true)
	expect(limiter.consume("2:A")):toBe(false)
end)

TestRunner.it(suite, "Rückwärts laufende Uhr erzeugt keine Gratis-Tokens", function()
	local now = 10
	local limiter = RateLimiter.new({
		perSecond = 1,
		burst = 1,
		clock = function()
			return now
		end,
	})
	expect(limiter.consume("k")):toBe(true)
	now = 5
	expect(limiter.consume("k")):toBe(false)
end)

return suite
