require_relative "matasano"

@key = Matasano.genkey()
@nonce = Matasano.bin2dec(Matasano.genkey(4))

def oracle(input)
	input.gsub!(/;/, '";"')
	input.gsub!(/=/, '"="')
	data = "comment1=cooking%20MCs;userdata="+input+";comment2=%20like%20a%20pound%20of%20bacon"
	data = Matasano.padd(data, 16)
	return Matasano.aes128_ctr_crypt(data, @key, @nonce)
end

def verify(input)
	plain = Matasano.aes128_ctr_crypt(input, @key, @nonce)
	plain = Matasano.unpadd(plain)
	puts plain.inspect
	if /;admin=true;/.match(plain) != nil
		puts "Admin detected"
		return true
	else
		puts "No Admin"
		return false
	end
end

# Placeholder for target data
insertblock = 'aaaaaaaaaaaaaaaa'
ciphertext = oracle(insertblock)

# keystream block that is xored with insertblock on en- / decryption
keyblock = Matasano.xor(ciphertext[32...48], insertblock)

targetdata = ';admin=true;abcd'
newblock = Matasano.xor(targetdata, keyblock)
new_cipher = ciphertext[0...32] + newblock + ciphertext[48..-1]

verify(new_cipher)