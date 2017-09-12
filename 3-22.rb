class MT
	def int32(num)
		return (num & 0xFFFFFFFF)
	end

	def init(seed)
		@index = 624
		@mt = [0] * 624
		@mt[0] = seed
		623.times do |i|
			@mt[i+1] = int32(1812433253 * (@mt[i] ^ @mt[i] >> 30) + (i+1))
		end
	end

	def extract_number()
		if @index >= 624
			twist()
		end

		y = @mt[@index]
		y = y ^ y >> 11
		y = y ^ y << 7 & 0x9d2c5680
		y = y ^ y << 15 & 0xefc60000
		y = y ^ y >> 18

		@index += 1 

		return int32(y)
	end

	def twist()
		624.times do |i|
			y = int32((@mt[i] & 0x80000000) + (@mt[(i+1) % 624] & 0x7fffffff))

			@mt[i] = @mt[(i+397) % 624] ^ y >> 1

			if y % 2 != 0
				@mt[i] = @mt[i] ^ 0x9908b0df
			end
		end
		@index = 0
	end

	def debug()
		puts @mt.inspect
	end
end

def crack_seed(basetime, reference)
	twin = MT.new
	timestamp = basetime

	while true do
		twin.init(timestamp)
		if twin.extract_number() == reference
			return timestamp
		end
		timestamp -= 1
	end
end


puts 'Have some patience'
sleep Random.rand(960) + 40
twister = MT.new
twister.init(Time.now.to_i)
sleep Random.rand(960) + 40
output = twister.extract_number()
basetime = Time.now.to_i
puts 'Observed output: ' + output.to_s
puts 'Start cracking at ' + basetime.to_s
res = crack_seed(basetime, output)
puts 'Found seed: ' + res.to_s