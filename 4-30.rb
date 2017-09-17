require_relative "matasano"

# modified from https://rosettacode.org/wiki/MD4#Ruby because I'm not implementing _another_ hash function from scratch
# Calculates MD4 message digest of _string_. Returns binary digest.
# For hexadecimal digest, use +*md4(str).unpack('H*')+.
def md4(string, a = 0x67452301, b = 0xefcdab89, c = 0x98badcfe, d = 0x10325476, nopadd = false)
	require 'stringio'

	string = string.b

	# functions
	mask = (1 << 32) - 1
	f = proc {|x, y, z| x & y | x.^(mask) & z}
	g = proc {|x, y, z| x & y | x & z | y & z}
	h = proc {|x, y, z| x ^ y ^ z}
	r = proc {|v, s| (v << s).&(mask) | (v.&(mask) >> (32 - s))}

	unless nopadd then
		bit_len = string.size << 3
		string += "\x80".b

		while (string.size % 64) != 56
			string += "\0".b
		end

		string = string.b + [bit_len & mask, bit_len >> 32].pack("V2")
	end

	if string.size % 64 != 0
		fail "failed to pad to correct length"
	end

	io = StringIO.new(string)
	block = ""

	while io.read(64, block)
		x = block.unpack("V16")

		# Process this block.
		aa, bb, cc, dd = a, b, c, d
		[0, 4, 8, 12].each {|i|
			a = r[a + f[b, c, d] + x[i],  3]
			i += 1
			d = r[d + f[a, b, c] + x[i],  7]
			i += 1
			c = r[c + f[d, a, b] + x[i], 11]
			i += 1
			b = r[b + f[c, d, a] + x[i], 19]
		}
		[0, 1, 2, 3].each {|i|
			a = r[a + g[b, c, d] + x[i] + 0x5a827999,  3]
			i += 4
			d = r[d + g[a, b, c] + x[i] + 0x5a827999,  5]
			i += 4
			c = r[c + g[d, a, b] + x[i] + 0x5a827999,  9]
			i += 4
			b = r[b + g[c, d, a] + x[i] + 0x5a827999, 13]
		}
		[0, 2, 1, 3].each {|i|
			a = r[a + h[b, c, d] + x[i] + 0x6ed9eba1,  3]
			i += 8
			d = r[d + h[a, b, c] + x[i] + 0x6ed9eba1,  9]
			i -= 4
			c = r[c + h[d, a, b] + x[i] + 0x6ed9eba1, 11]
			i += 8
			b = r[b + h[c, d, a] + x[i] + 0x6ed9eba1, 15]
		}
		a = (a + aa) & mask
		b = (b + bb) & mask
		c = (c + cc) & mask
		d = (d + dd) & mask
	end

	return [a, b, c, d].pack("V4")
end

def md4_padding(input)
	input = input.b
	ml = input.length * 8
	padding = ''.b << 0x80 # Append '10000000' bits to message
	while (input.length + padding.length)*8 % 512 != 448 do
		padding = padding << 0
	end

	padding += [ml & 0xffffffff, ml >> 32].pack("V2")

	return padding.b
end

def keyed_md4(input, key)
	return md4(key + input)
end

def verify(mac, input, key)
	return md4(key + input) == mac
end

def length_extension(original, append, mac, keylength)
	placeholder = (['a']*keylength).join('')
	reconstructed_padding = md4_padding(placeholder+original)
	forged_padding = md4_padding(placeholder+original+reconstructed_padding+append)

	h = mac.unpack("V4")

	forged_hash = md4(append+forged_padding, h[0], h[1], h[2], h[3], true)

	forgery = original + reconstructed_padding + append

	return [forgery, forged_hash]
end


key = File.readlines("/usr/share/dict/cracklib-small").sample(1)[0].chomp
original = 'comment1=cooking%20MCs;userdata=foo;comment2=%20like%20a%20pound%20of%20bacon'
append = ';admin=true'
mac = keyed_md4(original, key)

puts 'Verifying original mac'
puts verify(mac, original, key).inspect

puts 'Cracking keysize'
keysize = 1
while true do
	forgery = length_extension(original, append, mac, keysize)
	if verify(forgery[1], forgery[0], key) then
		puts 'Keysize: ' + keysize.to_s
		puts 'Forgery: ' + forgery[0].inspect
		puts 'Forged hash: ' + Matasano.bin2hex(forgery[1])
		break
	end
	keysize += 1
end