def hex2bin(hex)
	return [hex].pack('H*')
end

def textscore(text)
	chars = text.split('')
	englishlike = chars.count{ |x| /[a-zA-Z ',.!?]/.match?(x) }.to_f
	return englishlike / chars.length
end

cipher = hex2bin('1b37373331363f78151b7f2b783431333d78397828372d363c78373e783a393b3736').bytes

maxscore = -Float::INFINITY

best_guess = nil

for i in 0..255 do
	key = [i]*cipher.length

	decrypted = cipher.zip(key).map{ |x, y| x^y }.pack('c*')
	score = textscore(decrypted)

	if score > maxscore
		best_guess = decrypted
		maxscore = score
	end
end

puts best_guess