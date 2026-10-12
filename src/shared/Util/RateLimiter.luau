--!strict
-- Token Bucket pro Schlüssel (z. B. Spieler + Remote). Die Uhr wird injiziert,
-- damit Tests deterministisch laufen (Roblox: os.clock).

export type Options = {
	perSecond: number,
	burst: number,
	clock: () -> number,
}

export type RateLimiter = {
	consume: (key: string, cost: number?) -> boolean,
	forget: (key: string) -> (),
	forgetPrefix: (prefix: string) -> (),
}

type Bucket = { tokens: number, last: number }

local RateLimiter = {}

function RateLimiter.new(options: Options): RateLimiter
	assert(options.perSecond > 0 and options.burst >= 1, "invalid rate limit")
	local buckets: { [string]: Bucket } = {}

	local function consume(key: string, cost: number?): boolean
		local amount = cost or 1
		local now = options.clock()
		local bucket = buckets[key]
		if bucket == nil then
			bucket = { tokens = options.burst, last = now }
			buckets[key] = bucket
		end
		local elapsed = math.max(0, now - bucket.last)
		bucket.tokens = math.min(options.burst, bucket.tokens + elapsed * options.perSecond)
		bucket.last = now
		if bucket.tokens >= amount then
			bucket.tokens -= amount
			return true
		end
		return false
	end

	local function forget(key: string)
		buckets[key] = nil
	end

	local function forgetPrefix(prefix: string)
		for key in buckets do
			if string.sub(key, 1, #prefix) == prefix then
				buckets[key] = nil
			end
		end
	end

	return { consume = consume, forget = forget, forgetPrefix = forgetPrefix }
end

return table.freeze(RateLimiter)
