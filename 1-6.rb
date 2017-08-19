require "base64"

def hex2bin(hex)
	return [hex].pack('H*')
end

def bin2hex(bin)
	return bin.bytes.map{ |x| x.to_s(16).rjust(2, '0') }.join('')
end

def hamming_dist(a, b)
	# xor strings, then count 1 bits in string representation
	return a.bytes.zip(b.bytes).map{ |x, y| (x^y).to_s(2) }.join('').count('1').to_f
end

def xor_find_key_length(cipher, min = 2, max = 40)
	mindist = Float::INFINITY
	best_guess = nil

	for keysize in min..max do

		if keysize > cipher.length / 2
			break
		end

		block_a = cipher[0...keysize]
		block_b = cipher[keysize...keysize*2]
		block_c = cipher[keysize*2...keysize*3]
		block_d = cipher[keysize*3...keysize*4]

		dist = hamming_dist(block_a, block_b) + hamming_dist(block_b, block_c) + hamming_dist(block_c, block_d) + hamming_dist(block_a, block_c) + hamming_dist(block_a, block_d) + hamming_dist(block_b, block_d)
		dist = dist.to_f / 6

		dist = dist.to_f / keysize

		if dist < mindist
			mindist = dist
			best_guess = keysize
		end
	end

	return best_guess
end

def xor_find_key(cipher, keysize)
	blocks = Array.new(keysize, '')
	key = Array.new
	cipher = cipher.split('')

	i = 0
	for byte in cipher do
		blocks[i] += byte
		i = (i + 1)%keysize
	end

	for block in blocks do
		res = try_sbyte_xor(block)

		key.push(res == false ? '?' : res[1])
	end

	return key.join('')
end

def try_sbyte_xor(cipher)
	cipher = cipher.bytes

	max = - Float::INFINITY
	best_guess = nil
	key_guess = nil

	for i in 0..255 do
		key = [i]*cipher.length

		decrypted = cipher.zip(key).map{ |x, y| x^y }.pack('c*')
		score = textscore(decrypted)

		if score > max
			best_guess = decrypted
			key_guess = [i].pack('c*')
			max = score
		end
	end

	threshold = 0.65

	if max > threshold
		return [best_guess, key_guess]
	else
		return false
	end

end

def textscore(text)
	chars = text.split('')
	englishlike = chars.count{ |x| x.match?(/[a-zA-Z \n]/) }.to_f
	return englishlike.to_f / chars.length
end

def str_xor(a, b)
	return a.bytes.zip(b.bytes).map{ |x, y| x^y }.pack('c*')
end

def crypt_xor(key, data)
	stretched = [key]*(data.length.to_f / key.length).ceil
	stretched = stretched.join('')[0...data.length]
	return str_xor(stretched, data)
end

path = '1-6.txt'
ciphertext = File.readlines(path).map{ |x| x.chomp }.join('')
ciphertext = Base64.strict_decode64(ciphertext)

estimated_keysize = xor_find_key_length(ciphertext)

puts estimated_keysize.to_s

recovered_key = xor_find_key(ciphertext, estimated_keysize)

plaintext = crypt_xor(recovered_key, ciphertext)

puts plaintext.inspect

puts recovered_key.inspect
