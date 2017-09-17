require_relative "matasano"

key = File.readlines("/usr/share/dict/cracklib-small").sample(1)[0].chomp

def sha1_padding(input)
	input = input.b
	ml = input.length * 8
	padding = ''.b << 0x80 # Append '10000000' bits to message
	while (input.length + padding.length)*8 % 512 != 448 do
		padding = padding << 0
	end

	padding += [ml].pack('Q').reverse # append message length converted to 64bit big endian

	return padding.b
end

def keyed_sha1(input, key)
	return Matasano.sha1(key + input)
end

def verify(mac, input, key)
	return Matasano.sha1(key + input) == mac
end

def length_extension(original, append, mac, keylength)
	placeholder = (['a']*keylength).join('')
	reconstructed_padding = sha1_padding(placeholder+original)
	forged_padding = sha1_padding(placeholder+original+reconstructed_padding+append)

	dechash = Matasano.bin2dec(mac)
	h0 = (dechash >> 128) & 0xffffffff
	h1 = (dechash >> 96) & 0xffffffff
	h2 = (dechash >> 64) & 0xffffffff
	h3 = (dechash >> 32) & 0xffffffff
	h4 = dechash & 0xffffffff

	forged_hash = Matasano.sha1(append+forged_padding, h0, h1, h2, h3, h4, true)

	forgery = original + reconstructed_padding + append

	return [forgery, forged_hash]
end

original = 'comment1=cooking%20MCs;userdata=foo;comment2=%20like%20a%20pound%20of%20bacon'
append = ';admin=true'
mac = keyed_sha1(original, key)

puts 'Verifying original mac'
puts verify(mac, original, key).inspect

puts 'Cracking keysize'
keysize = 1
while true do
	forgery = length_extension(original, append, mac, keysize)
	if verify(forgery[1], forgery[0], key) then
		puts 'Keysize: ' + keysize.to_s
		puts 'Forgery: ' + forgery[0].inspect
		puts 'Forged hash: ' + Matasano.bin2hex(forgery[1])
		break
	end
	keysize += 1
end