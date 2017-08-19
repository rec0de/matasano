require_relative "matasano"

input = Matasano.hex2bin('1c0111001f010100061a024b53535009181c')
key = Matasano.hex2bin('686974207468652062756c6c277320657965')

res = Matasano.xor(input, key)

puts res

res = Matasano.bin2hex(res)

puts res

puts res == '746865206b696420646f6e277420706c6179' ? 'Checks out' : 'Error'
