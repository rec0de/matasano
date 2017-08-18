def hex2bin(hex)
	return [hex].pack('H*')
end

def textscore(text)
	chars = text.split('')
	englishlike = chars.count{ |x| x.match?(/[a-zA-Z \n]/) }.to_f
	return englishlike
end

def try_sbyte_xor(cipher)
	cipher = cipher.bytes

	prob = (26*2 + 3).to_f / 256
	max = - Float::INFINITY
	best_guess = nil

	for i in 0..255 do
		key = [i]*cipher.length

		decrypted = cipher.zip(key).map{ |x, y| x^y }.pack('c*')
		score = textscore(decrypted)

		if score > max
			best_guess = decrypted
			max = score
		end
	end

	threshold = (prob * cipher.length) + Math.sqrt(cipher.length * prob * (1 - prob))*9

	if max > threshold
		return best_guess
	else
		return false
	end

end

path = '1-4.txt'
lines = File.readlines(path)

for line in lines do
	res = try_sbyte_xor(hex2bin(line.chomp))
	if res
		puts res.inspect
	end
end