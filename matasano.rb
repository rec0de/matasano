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

	# Binary operations

	def self.xor(a, b)
		return a.bytes.zip(b.bytes).map{ |x, y| x^y }.pack('c*')
	end

	# Metrics

	def self.textscore(text)
		chars = text.split('')
		englishlike = chars.count{ |x| /[a-zA-Z ',.!?]/.match?(x) }.to_f
		return englishlike / chars.length
	end

	def self.hamming(a, b)
		# xor strings, then count 1 bits in string representation
		return a.bytes.zip(b.bytes).map{ |x, y| (x^y).to_s(2) }.join('').count('1').to_f
	end

	# Ciphers

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

	# Cipher breaking

	# Attempts to break single byte xor
	# Input: binary ciphertext
	# Output: [plaintext, key] on success, false otherwise
	def self.break_xor_sbyte(cipher, threshold = 0.9)
		max = - Float::INFINITY
		best_guess = nil
		key_guess = nil

		for i in 0..255 do
			decrypted = self.xor_sbyte(cipher, i)
			score = self.textscore(decrypted)

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
			if keysize*2 > cipher.length
				break
			# if there is not enough ciphertext for 4 blocks, use only 2
			elsif keysize * 4 > cipher.length
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