require_relative "matasano"

@key = Matasano.genkey()
@iv = Matasano.genkey()

def oracle(input)
	input.gsub!(/;/, '";"')
	input.gsub!(/=/, '"="')
	data = "comment1=cooking%20MCs;userdata="+input+";comment2=%20like%20a%20pound%20of%20bacon"
	data = Matasano.padd(data, 16)
	return Matasano.aes128_cbc_encrypt(data, @key, @iv)
end

def verify(input)
	plain = Matasano.aes128_cbc_decrypt(input, @key, @iv)
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

# ciphertext block that is xored with insertblock on en- / decryption
xorblock = ciphertext[16...32]

target = Matasano.padd(';admin=true;', 16)

# raw result of decryption before applying xor
raw_decrypt_result = Matasano.xor(insertblock, xorblock)

# block that if xored with target block on decryption produces target data
new_xorblock = Matasano.xor(raw_decrypt_result, target)

crafted_message = ciphertext[0...16] + new_xorblock + ciphertext[32..-1]

verify(crafted_message)