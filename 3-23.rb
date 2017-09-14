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

	def set_index(index)
		@index = index
	end

	def set_state(state)
		@mt = state
	end

end

def reconstruct_state(output)
	y = output
	y = y ^ (y >> 18)
	y = y ^ (y << 15 & 0xefc60000)

	# Note to self: Visualize this - progressively uncovers more 'plain' bits each time
	y = y ^ (y << 7 & 0x1680)
	y = y ^ (y << 7 & 0xC4000)
	y = y ^ (y << 7 & 0xD200000)
	y = y ^ (y << 7 & 0x90000000)

	y = y ^ (y >> 11 & 0x1FFC00)
	y = y ^ (y >> 11 & 0x3FF)

	return y
end


twister = MT.new
twister.init(Time.now.to_i)
state = []

cloned = MT.new

624.times do |count|
	output = twister.extract_number()
	state.push(reconstruct_state(output))

	if state.length >= 623
		cloned.set_index(count)
		cloned.set_state(state)
		cloned.extract_number()
	end
end

10.times do
	puts 'Predict: ' + cloned.extract_number().to_s
	puts 'Observe: ' + twister.extract_number().to_s
	puts ''
end