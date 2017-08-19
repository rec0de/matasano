require_relative "matasano"

cipher = Matasano.hex2bin('1b37373331363f78151b7f2b783431333d78397828372d363c78373e783a393b3736')

maxscore = -Float::INFINITY

best_guess = nil

for i in 0..255 do
	
	decrypted = Matasano.xor_sbyte(cipher, i)
	score = Matasano.textscore(decrypted)

	if score > maxscore
		best_guess = decrypted
		maxscore = score
	end
end

puts best_guess