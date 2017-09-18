class Matasano

	# Data encoding

	def self.hex2bin(hex)
		return [hex].pack('H*')
	end

	def self.bin2hex(bin)
		return bin.bytes.map{ |x| x.to_s(16).rjust(2, '0') }.join('')
	end

	def self.bin2b64(bin)
		require "base64"
		return Base64.strict_encode64(bin)
	end

	def self.b642bin(b64)
		require "base64"
		return Base64.strict_decode64(b64)
	end

	def self.hex2dec(hex)
		return hex.to_i(16)
	end

	def self.dec2hex(dec)
		raise "dec2hex expects integer input. Given: "+dec.inspect unless dec.is_a?(Numeric)
		hex = dec.to_s(16)
		return hex.length % 2 == 0 ? hex : '0' + hex
	end

	def self.bin2dec(bin)
		return self.bin2hex(bin).to_i(16)
	end

	def self.dec2bin(dec)
		raise "dec2bin expects integer input. Given: "+dec.inspect unless dec.is_a?(Numeric)
		return self.hex2bin(self.dec2hex(dec)).b
	end

	def self.padd(string, blocksize)
		string = string.b
		padd_bytes = blocksize - (string.length % blocksize)
		if padd_bytes == 0
			padd_bytes = blocksize
		end
		padding = ([padd_bytes]*padd_bytes).pack('c*')
		return string + padding.b
	end

	def self.unpadd(string)
		string = string.b
		lastbyte = string[-1].bytes[0]
		if string.length >= lastbyte && string[-lastbyte..-1].bytes.join('') == ([lastbyte]*lastbyte).join('')
			return string[0...-lastbyte]
		else
			raise "Invalid Padding"
		end
	end

	# Binary operations

	def self.xor(a, b)
		if a.length < b.length
			b = b[0...a.length]
		elsif a.length > b.length
			a = a[0...b.length]
		end

		return a.bytes.zip(b.bytes).map{ |x, y| x^y }.pack('c*')
	end

	def self.leftrotate_32(int, n=1)
		raise "leftrotate_32 expects numeric input" unless int.is_a?(Numeric)
		return ((int << n) | (int >> 32-n)) & 0xffffffff # AND mask to keep result 32bit
	end

	# Metrics

	def self.letter_frequency(str)
		counts = {}
		total = 0

		str.each_char do |char|
			counts[char] = 0 unless counts.include?(char)
			counts[char] += 1
			total += 1
		end

		counts.transform_values!{ |count| count.to_f / total }

		return counts
	end

	def self.textscore(text)
		chars = text.split('')
		englishlike = chars.count{ |x| /[a-zA-Z ',.!?\/]/.match?(x) }.to_f
		return englishlike / chars.length
	end

	def self.textscore2(sample)
		sample = self.letter_frequency(sample)
		ref = {"I"=>0.010293360782295419, "'"=>0.017498713329902212, "m"=>0.023160061760164694, " "=>0.19634585692228512, "b"=>0.011322696860524962, "a"=>0.058414822439526504, "c"=>0.0195573854863613, "k"=>0.00977869274318065, "n"=>0.05764282038085435, "d"=>0.02907874420998456, "r"=>0.035512094698919194, "i"=>0.048893463715903245, "g"=>0.021873391662377766, "t"=>0.0602161605764282, "h"=>0.03782810087493567, "e"=>0.07848687596500258, "l"=>0.031137416366443644, "A"=>0.003088008234688626, "o"=>0.06304683479155944, "w"=>0.012352032938754504, "f"=>0.008749356664951106, "y"=>0.025476067936181162, "s"=>0.03654143077714874, "W"=>0.001544004117344313, "D"=>0.0012866700977869274, "J"=>0.0002573340195573855, "u"=>0.02213072568193515, "Z"=>0.0002573340195573855, "H"=>0.001544004117344313, "z"=>0.0012866700977869274, "V"=>0.001544004117344313, ","=>0.012352032938754504, "."=>0.0038600102933607824, "T"=>0.0033453422542460112, "j"=>0.0012866700977869274, "p"=>0.011837364899639732, "\n"=>0.0025733401955738548, "M"=>0.000514668039114771, "G"=>0.001544004117344313, "!"=>0.0012866700977869274, "S"=>0.005661348430262481, "v"=>0.005661348430262481, "/"=>0.0012866700977869274, "2"=>0.000514668039114771, "-"=>0.004374678332475553, "Y"=>0.0038600102933607824, "1"=>0.0002573340195573855, "3"=>0.0002573340195573855, "K"=>0.0002573340195573855, "F"=>0.000514668039114771, "x"=>0.000514668039114771, "B"=>0.0012866700977869274, "O"=>0.001544004117344313, "C"=>0.001544004117344313, "P"=>0.001029336078229542, "N"=>0.0007720020586721565, "8"=>0.0002573340195573855, "9"=>0.000514668039114771, "0"=>0.000514668039114771, "E"=>0.000514668039114771, "L"=>0.000514668039114771, "q"=>0.0002573340195573855, "R"=>0.0002573340195573855, "5"=>0.0002573340195573855, "?"=>0.000514668039114771, ":"=>0.0007720020586721565, "U"=>0.0002573340195573855, ";"=>0.0007720020586721565, "\""=>0.0002573340195573855, "\\"=>0.0002573340195573855}

		score = 0
		sample.each do |char, freq|
			score -= ref.include?(char) ? (freq - ref[char])**2 : 0.2
		end

		return score/sample.length
	end

	def self.hamming(a, b)
		# xor strings, then count 1 bits in string representation
		return a.bytes.zip(b.bytes).map{ |x, y| (x^y).to_s(2) }.join('').count('1').to_f
	end

	# Ciphers

	def self.genkey(bytes = 16)
		key = ''
		bytes.times do
			key += [Random.rand(256)].pack('c*').b
		end

		return key
	end

	# Encrypts / Decrypts using single byte xor
	# Input: binary input, integer representation of key byte
	# Output: binary result
	def self.xor_sbyte(input, key)
		input = input.bytes
		key = [key]*input.length
		return input.zip(key).map{ |x, y| x^y }.pack('c*')
	end

	# Encrypts / Decrypts using repeating key xor
	# Input: binary input, binary key
	# Output: binary result
	def self.xor_repeat(input, key)
		# generate keystream of same length as input
		stretched = [key]*(input.length.to_f / key.length).ceil
		stretched = stretched.join('')[0...input.length]
		return self.xor(stretched, input)
	end

	# Encrypts using AES-128 ECB
	# Input: binary plaintext, binary key
	# Output: binary ciphertext
	def self.aes128_ecb_encrypt(plain, key)
		require "openssl"
		cipher = OpenSSL::Cipher::AES128.new(:ECB)
		cipher.encrypt
		cipher.key = key
		cipher.padding = 0
		return cipher.update(plain) + cipher.final
	end

	# Decrypts using AES-128 ECB
	# Input: binary ciphertext, binary key
	# Output: binary plaintext
	def self.aes128_ecb_decrypt(plain, key)
		require "openssl"
		cipher = OpenSSL::Cipher::AES.new(128, :ECB)
		cipher.decrypt
		cipher.key = key
		cipher.padding = 0
		return cipher.update(plain) + cipher.final
	end

	# Encrypts AES-128 CBC
	# Input: binary plaintext, binary key, binary iv
	# Output: binary ciphertext
	def self.aes128_cbc_encrypt(plain, key, iv)
		cipher = ''
		prevblock = iv
		((plain.length/16).to_f.ceil).times do |i|
			plainblock = plain[i*16...(i+1)*16]

			cipherblock = self.aes128_ecb_encrypt(self.xor(prevblock, plainblock), key)

			cipher += cipherblock
			prevblock = cipherblock
		end

		return cipher
	end

	# Decrypts AES-128 CBC
	# Input: binary ciphertext, binary key, binary iv
	# Output: binary plaintext
	def self.aes128_cbc_decrypt(cipher, key, iv)
		plain = ''
		prevblock = iv
		(cipher.length/16).times do |i|
			cipherblock = cipher[i*16...(i+1)*16]
			plain += self.xor(prevblock, self.aes128_ecb_decrypt(cipherblock, key))
			prevblock = cipherblock
		end

		return plain
	end

	# En- / Decrypts AES-128 CTR
	# Input: binary input, binary key, uint64_t nonce
	# Output: binary output
	def self.aes128_ctr_crypt(input, key, nonce)
		keystream = ''
		((input.length.to_f/16).ceil).times do |i|
			keystream += [nonce].pack('Q*')+[i].pack('Q*')
		end
		keystream = self.aes128_ecb_encrypt(keystream, key)
		keystream = keystream[0...input.length]
		return self.xor(input, keystream)
	end

	# Hashes & Checksums

	# Creates SHA1 hash of input, implemented following wikipedia pseudocode
	# Input: binary input
	# Output: binary hash
	def self.sha1(input, h0 = 0x67452301, h1 = 0xEFCDAB89, h2 = 0x98BADCFE, h3 = 0x10325476, h4 = 0xC3D2E1F0, nopadd = false)

		input = input.b

		# skip padding if caller supplies already-padded data
		unless nopadd then
			ml = input.length * 8
			input << 0x80 # Append '10000000' bits to message
			while input.length*8 % 512 != 448 do
				input = input << 0
			end

			input += [ml].pack('Q').reverse # append message length converted to 64bit big endian
		end

		input.unpack('C*').each_slice(512/8) do |chunk|

			words = []
			chunk.each_slice(32/8){|a,b,c,d| words << (((a<<8|b)<<8|c)<<8|d) }

			for i in (16..79) do
				words[i] = self.leftrotate_32(words[i-3] ^ words[i-8] ^ words[i-14] ^ words[i-16], 1)
			end

			a = h0
			b = h1
			c = h2
			d = h3
			e = h4

			for i in (0..79) do
				if i <= 19 then
					f = (b & c) | ((b ^ 0xffffffff) & d) # xor 0xffffffff should equal !b
					k = 0x5A827999
				elsif i <= 39 then
					f = b ^ c ^ d
					k = 0x6ED9EBA1
				elsif i <= 59
					f = (b & c) | (b & d) | (c & d)
					k = 0x8F1BBCDC
				else
					f = b ^ c ^ d
					k = 0xCA62C1D6
				end

				temp = (self.leftrotate_32(a, 5) + f + e + k + words[i]) & 0xffffffff
				e = d
				d = c
				c = self.leftrotate_32(b, 30)
				b = a
				a = temp
			end

			h0 = (h0 + a) & 0xffffffff
			h1 = (h1 + b) & 0xffffffff
			h2 = (h2 + c) & 0xffffffff
			h3 = (h3 + d) & 0xffffffff
			h4 = (h4 + e) & 0xffffffff
		end

		return self.dec2bin((h0 << 128) | (h1 << 96) | (h2 << 64) | (h3 << 32) | h4)
	end

	# Creates HMAC-SHA1 mac of input
	# Input: binary data, binary key
	# Output: binary MAC
	def self.hmac_sha1(data, key)
		blocksize = 64
		if key.length > blocksize then
			key = self.sha1(key)
		end

		if key.length < blocksize then+
			key += ([0]*(blocksize-key.length)).pack('c*')
		end

		o_key_padd = self.xor(key, ([0x5c]*blocksize).pack('c*'))
		i_key_padd = self.xor(key, ([0x36]*blocksize).pack('c*'))

		return self.sha1(o_key_padd + self.sha1(i_key_padd + data))
	end

	# Cipher breaking

	# Attempts to break single byte xor
	# Input: binary ciphertext
	# Output: [plaintext, key] on success, false otherwise
	def self.break_xor_sbyte(cipher, threshold = -0.02)
		max = - Float::INFINITY
		best_guess = nil
		key_guess = nil

		256.times do |i|
			decrypted = self.xor_sbyte(cipher, i)
			score = self.textscore2(decrypted)

			if score > max
				best_guess = decrypted
				key_guess = [i].pack('c*')
				max = score
			end
		end

		if max > threshold
			return [best_guess, key_guess]
		else
			return false
		end
	end

	# Attempts to reconstruct key for repeating key xor of given keysize
	# Input: binary ciphertext, integer keysize
	# Output: binary key with '?' as placeholder for unknown bytes
	def self.break_xor_repeat(cipher, keysize)
		blocks = Array.new(keysize, '')
		key = Array.new
		cipher = cipher.split('')

		# split ciphertext into blocks ('reverse zip')
		i = 0
		for byte in cipher do
			blocks[i] += byte
			i = (i + 1)%keysize
		end

		# solve blocks individually & reconstruct key
		for block in blocks do
			res = self.break_xor_sbyte(block)
			key.push(res == false ? '?' : res[1])
		end

		return key.join('')
	end

	# Attempts to guess keysize used for repeating key xor
	# Input: binary ciphertext, range of keysizes to test (default: 2-40 inclusive)
	# Output: most promising keysize in range
	def self.xor_repeat_find_keysize(cipher, range = (2..40))
		mindist = Float::INFINITY
		best_guess = nil

		for keysize in range do

			# break if keysize is too long for ciphertext
			break if keysize*2 > cipher.length
	
			# if there is not enough ciphertext for 4 blocks, use only 2
			if keysize * 4 > cipher.length
				block_a = cipher[0...keysize]
				block_b = cipher[keysize...keysize*2]

				dist = self.hamming(block_a, block_b).to_f
			# otherwise calculate average hamming distance between the first 4 blocks
			else
				block_a = cipher[0...keysize]
				block_b = cipher[keysize...keysize*2]
				block_c = cipher[keysize*2...keysize*3]
				block_d = cipher[keysize*3...keysize*4]

				dist = self.hamming(block_a, block_b) + self.hamming(block_b, block_c) + self.hamming(block_c, block_d) + self.hamming(block_a, block_c) + self.hamming(block_a, block_d) + self.hamming(block_b, block_d)
				dist = dist.to_f / 6
			end

			# normalize hamming distance to keysize
			dist = dist.to_f / keysize

			if dist < mindist
				mindist = dist
				best_guess = keysize
			end
		end

		return best_guess
	end

end