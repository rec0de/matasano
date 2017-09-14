require_relative "matasano"

@key = Matasano.genkey(2)

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

# Possible bug: What happens if extract_number returns a single-byte value?
def mt_stream_crypt(key, msg)
	generator = MT.new
	key = Matasano.bin2dec(key)
	keystream = ''

	generator.init(key)

	(msg.length.to_f/4).ceil.times do
		keystream += Matasano.dec2bin(generator.extract_number())
	end

	keystream = keystream[0...msg.length]
	return Matasano.xor(msg, keystream)
end

def oracle(input)
	return mt_stream_crypt(@key, Matasano.genkey(Random.rand(100)) + input)
end

def token()
	generator = MT.new
	generator.init(Time.now.to_i)
	token = ''

	4.times do
		token += Matasano.dec2bin(generator.extract_number())
	end

	return token
end


def break_mt_stream()
	cipher = oracle('aaaaaaaaaaaaaaaaa')
	lastfullblock = (cipher.length / 4).floor
	keyblock = Matasano.bin2dec(Matasano.xor(cipher[(lastfullblock-1)*4...lastfullblock*4], 'aaaa'))

	generator = MT.new

	(2**16).times do |i|
		generator.init(i)
		(lastfullblock-1).times do
			generator.extract_number()
		end

		if generator.extract_number() == keyblock
			return Matasano.dec2bin(i)
		end
	end

	return false
end

def break_token(token)
	starttime = Time.now.to_i + 120
	endtime = starttime - 60*100
	time = starttime
	ref = Matasano.bin2dec(token[0...4])
	generator = MT.new

	while time > endtime do
		generator.init(time)
		return time if generator.extract_number() == ref
		time -= 1
	end

	return false
end

puts 'Recovered token seed: ' + break_token(token()).to_s

puts 'Key is '+@key.inspect
recovered = break_mt_stream()
if recovered
	puts 'Recovered key: ' + recovered.inspect
else
	puts 'Could not recover 16bit key'
end