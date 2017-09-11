require_relative "matasano"

@key = Matasano.genkey()

path = '3-20.txt'
lines = File.readlines(path)
ciphertexts = []
minlength = Float::INFINITY

lines.each do |line|
	decoded = Matasano.aes128_ctr_crypt(Matasano.b642bin(line.chomp), @key, 0)
	if decoded.length < minlength
		minlength = decoded.length
	end
	ciphertexts.push(decoded)
end

ciphertexts.map!{ |ctext| ctext[0...minlength] }

keystream = Matasano.break_xor_repeat(ciphertexts.join(''), minlength)

ciphertexts.each do |ctext|
	puts Matasano.xor(ctext, keystream).inspect
end

