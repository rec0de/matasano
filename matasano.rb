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
		ref = { "I"=>0.011777695988222304, "'"=>0.02465955097534045, "m"=>0.02318733897681266, " "=>0.20058888479941112, "b"=>0.011409642988590356,
			"a"=>0.05962458594037542, "c"=>0.021347073978652927, "k"=>0.012513801987486198, "n"=>0.05668016194331984, "d"=>0.02576370997423629,
			"r"=>0.027972027972027972, "i"=>0.04784688995215311, "g"=>0.020610967979389033, "t"=>0.061832903938167094, "h"=>0.031284504968715494,
			"e"=>0.06919396393080604, "l"=>0.033860875966139126, "A"=>0.001840264998159735, "o"=>0.06551343393448657, "w"=>0.011409642988590356,
			"f"=>0.008465218991534781, "y"=>0.03165255796834744, "s"=>0.03349282296650718, "W"=>0.001104158998895841, "D"=>0.001840264998159735,
			"J"=>0.000368052999631947, "u"=>0.022819285977180713, "Z"=>0.000368052999631947, "H"=>0.000368052999631947, "z"=>0.001840264998159735,
			"V"=>0.002208317997791682, ","=>0.012145748987854251, "."=>0.002944423997055576, "T"=>0.002208317997791682, "j"=>0.001840264998159735,
			"p"=>0.013986013986013986, "\n"=>0.003312476996687523, "M"=>0.000736105999263894, "G"=>0.002208317997791682, "!"=>0.001840264998159735,
			"S"=>0.006993006993006993, "v"=>0.004048582995951417, "2"=>0.000736105999263894, "-"=>0.005520794994479205, "Y"=>0.005152741994847258,
			"1"=>0.000368052999631947, "3"=>0.000368052999631947, "K"=>0.000368052999631947, "F"=>0.000368052999631947, "x"=>0.000736105999263894,
			"B"=>0.001104158998895841, "O"=>0.001104158998895841, "C"=>0.001840264998159735, "P"=>0.001104158998895841, "N"=>0.001104158998895841,
			"8"=>0.000368052999631947, "9"=>0.000736105999263894, "0"=>0.000736105999263894, "E"=>0.000368052999631947, "L"=>0.000736105999263894,
			"q"=>0.000368052999631947, "R"=>0.000368052999631947, "5"=>0.000368052999631947, "?"=>0.000368052999631947 }

		score = 0
		sample.each do |char, freq|
			score -= ref.include?(char) ? (freq - ref[char])**2 : 1
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