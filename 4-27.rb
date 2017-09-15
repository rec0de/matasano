require_relative "matasano"

@key = Matasano.genkey()
@iv = @key

def oracle()
	data = "comment1=cooking%20MCs;userdata=nothing;comment2=%20like%20a%20pound%20of%20bacon"
	data = Matasano.padd(data, 16)
	return Matasano.aes128_cbc_encrypt(data, @key, @iv)
end

def verify(input)
	plain = Matasano.aes128_cbc_decrypt(input, @key, @iv)
	plain = Matasano.unpadd(plain)

	plain.bytes.each do |byte|
		raise "Non-ASCII safe character: "+plain if byte > 120
	end

	puts 'Okay'
end

cipher = oracle()
blocks = cipher.split('').each_slice(16).map(&:join)
nullblock = ([0]*16).pack('c*').b

begin
	verify(blocks[0]+nullblock+blocks[0]+blocks[-3]+blocks[-2]+blocks[-1])
rescue RuntimeError => e
	plainblocks = e.to_s[26..-1].split('').each_slice(16).map(&:join)
	key = Matasano.xor(plainblocks[0], plainblocks[2])

	puts 'Recovered key/iv: ' + key.inspect
	puts 'Recovered plaintext: ' + Matasano.aes128_cbc_decrypt(oracle(), key, key).inspect
end