require_relative "matasano"

path = '1-4.txt'
lines = File.readlines(path)

for line in lines do
	res = Matasano.break_xor_sbyte(Matasano.hex2bin(line.chomp))
	if res
		puts res.inspect
	end
end