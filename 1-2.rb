def hex2bin(hex)
	return [hex].pack('H*')
end

def bin2hex(bin)
	return bin.bytes.map{ |x| x.to_s(16).rjust(2, '0') }.join('')
end

def str_xor(a, b)
	return a.bytes.zip(b.bytes).map{ |x, y| x^y }.pack('c*')
end

input = hex2bin('1c0111001f010100061a024b53535009181c')
key = hex2bin('686974207468652062756c6c277320657965')

res = str_xor(input, key)

puts res

res = bin2hex(res)

puts res

puts res == '746865206b696420646f6e277420706c6179' ? 'Checks out' : 'Error'
