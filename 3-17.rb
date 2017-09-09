require_relative "matasano"

@key = Matasano.genkey()

def oracle()
	strings = ["MDAwMDAwTm93IHRoYXQgdGhlIHBhcnR5IGlzIGp1bXBpbmc=", "MDAwMDAxV2l0aCB0aGUgYmFzcyBraWNrZWQgaW4gYW5kIHRoZSBWZWdhJ3MgYXJlIHB1bXBpbic=", "MDAwMDAyUXVpY2sgdG8gdGhlIHBvaW50LCB0byB0aGUgcG9pbnQsIG5vIGZha2luZw==", "MDAwMDAzQ29va2luZyBNQydzIGxpa2UgYSBwb3VuZCBvZiBiYWNvbg==", "MDAwMDA0QnVybmluZyAnZW0sIGlmIHlvdSBhaW4ndCBxdWljayBhbmQgbmltYmxl", "MDAwMDA1SSBnbyBjcmF6eSB3aGVuIEkgaGVhciBhIGN5bWJhbA==", "MDAwMDA2QW5kIGEgaGlnaCBoYXQgd2l0aCBhIHNvdXBlZCB1cCB0ZW1wbw==", "MDAwMDA3SSdtIG9uIGEgcm9sbCwgaXQncyB0aW1lIHRvIGdvIHNvbG8=", "MDAwMDA4b2xsaW4nIGluIG15IGZpdmUgcG9pbnQgb2g=", "MDAwMDA5aXRoIG15IHJhZy10b3AgZG93biBzbyBteSBoYWlyIGNhbiBibG93"]
	iv = Matasano.genkey()
	plaintext = Matasano.padd(Matasano.b642bin(strings.sample), 16) # picks random string from array, converts to binary and applies padding
	ciphertext = Matasano.aes128_cbc_encrypt(plaintext, @key, iv)
	return [ciphertext, iv]
end

def verify(input, iv)
	begin
		plain = Matasano.aes128_cbc_decrypt(input, @key, iv)
		#puts plain.inspect
		plain = Matasano.unpadd(plain)
		
		return true
	rescue
		return false
	end
end


def attack(ciphertext, iv)
	decrypted = ''
	blocks = ciphertext.split('').each_slice(16).map(&:join)
	blocks.each_with_index do |block, index|

		guess_position = -1
		corrupt_iv = Matasano.genkey()
		prevblock = (index != 0) ? blocks[index-1] : iv
		plain_bytes = ''
		raw_bytes = ''

		while guess_position >= -16 do
			for i in (0...256) do
				corrupt_iv[guess_position] = [i].pack('c*')
				if verify(block, corrupt_iv)

					raw_byte = Matasano.xor([i].pack('c*'), [guess_position.abs].pack('c*'))
					raw_bytes = raw_byte + raw_bytes

					plain_bytes = Matasano.xor(raw_byte, prevblock[guess_position]) + plain_bytes

					# Craft corrupted iv with 1 byte longer padding
					value = guess_position.abs + 1
					for i in (guess_position..-1) do
						corrupt_iv[i] = Matasano.xor([value].pack('*c'), raw_bytes[i])
					end

					verify(block, corrupt_iv)
					guess_position -= 1
					break
				end
			end
		end

		decrypted += plain_bytes
	end

	return decrypted
end

data = oracle()
puts attack(data[0], data[1]).inspect