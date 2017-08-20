require_relative "matasano"

path = '1-8.txt'
lines = File.readlines(path)
line_number = 0

# Look for duplicate 16 byte blocks as indicator for ECB encryption
for line in lines do
	blocks = Matasano.hex2bin(line.chomp).split('').each_slice(16).map(&:join)

	if blocks.length > blocks.uniq.length
		puts line_number.to_s + ' ' + line.inspect
	end

	line_number += 1
end