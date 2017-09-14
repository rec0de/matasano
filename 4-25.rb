require_relative "matasano"

path = '2-10.txt'
ciphertext = Matasano.b642bin(File.readlines(path).map{ |x| x.chomp }.join(''))

@key = Matasano.genkey()
data = Matasano.aes128_ctr_crypt(Matasano.aes128_cbc_decrypt(ciphertext, 'YELLOW SUBMARINE', ([0]*16).pack('c*')), @key, 0)

def edit(ciphertext, key, offset, newtext)
	keystream = ''
	nonce = 0

	keystream_start = (offset.to_f/16).floor
	keystream_end = ((offset+newtext.length).to_f/16).ceil
	puts 'Start: ' + keystream_end.to_s
	puts 'End: ' + keystream_end.to_s

	for i in (keystream_start...keystream_end) do
		keystream += [nonce].pack('Q*')+[i].pack('Q*')
	end

	keystream = Matasano.aes128_ecb_encrypt(keystream, key)
	plain = Matasano.xor(keystream, ciphertext[keystream_start*16...(keystream_end+1)*16])

	new_plain = plain[0...(offset % 16)] + newtext + plain[((offset % 16) + newtext.length)..-1]
	new_cipher = Matasano.xor(new_plain, keystream)

	return ciphertext[0...keystream_start*16] + new_cipher + ciphertext[keystream_end*16..-1]
end

def recover_plain(ciphertext)
	overwrite = ([0]*ciphertext.length).pack('c*')
	keystream = edit(ciphertext, @key, 0, overwrite)
	return Matasano.xor(ciphertext, keystream)
end

puts recover_plain(data)