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

twister = MT.new

twister.init(1)

10.times do
	puts twister.extract_number().inspect
end