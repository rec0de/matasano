def hex2bin(hex)
	return [hex].pack('H*')
end

def bin2hex(bin)
	return bin.bytes.map{ |x| x.to_s(16).rjust(2, '0') }.join('')
end

def str_xor(a, b)
	return a.bytes.zip(b.bytes).map{ |x, y| x^y }.pack('c*')
end

def crypt_xor(key, data)
	stretched = [key]*(data.length.to_f / key.length).ceil
	stretched = stretched.join('')[0...data.length]
	return str_xor(stretched, data)
end

plain = "Burning \'em, if you ain\'t quick and nimble\nI go crazy when I hear a cymbal"
key = 'ICE'

cipher = bin2hex(crypt_xor(key, plain))

puts cipher
puts cipher == '0b3637272a2b2e63622c2e69692a23693a2a3c6324202d623d63343c2a26226324272765272a282b2f20430a652e2c652a3124333a653e2b2027630c692b20283165286326302e27282f' ? 'Checks out' : 'Error'