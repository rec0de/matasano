require_relative "matasano"

@key = Matasano.genkey()

def oracle(prefix)
	append = Matasano.b642bin('Um9sbGluJyBpbiBteSA1LjAKV2l0aCBteSByYWctdG9wIGRvd24gc28gbXkgaGFpciBjYW4gYmxvdwpUaGUgZ2lybGllcyBvbiBzdGFuZGJ5IHdhdmluZyBqdXN0IHRvIHNheSBoaQpEaWQgeW91IHN0b3A/IE5vLCBJIGp1c3QgZHJvdmUgYnkK')
	return Matasano.aes128_ecb_encrypt(Matasano.padd(prefix + append, 16), @key)
end

# Detect block size
prefix = ''
length = oracle(prefix).length

while oracle(prefix).length == length do
	prefix += 'a'
end

length = oracle(prefix).length
blocksize = 0

while oracle(prefix).length == length do
	prefix += 'a'
	blocksize += 1
end

puts 'Cipher blocksize: ' + blocksize.inspect

# Detect ecb mode

input = (['a']*(blocksize*4)).join('')

blocks = oracle(input).split('').each_slice(16).map(&:join)

if blocks.length > blocks.uniq.length
	puts 'ECB detected'
else
	puts 'Could not detect ECB - this wont work'
end

# Recover secret

prefix = (['a']*(blocksize-1)).join('')
known = ''
blocknum = 0
blockcount = (oracle('').length/16).ceil

while prefix[0] == 'a' do

	firstblock = oracle(prefix)[(blocksize*blocknum...blocksize*(blocknum+1))]

	#puts (known).inspect

	foundbyte = ''
	for i in (0...256) do
		guessblock = prefix + known + [i].pack('c*')

		if firstblock == oracle(guessblock)[blocksize*blocknum...blocksize*(blocknum+1)]
			foundbyte = [i].pack('c*')
			known += foundbyte
			break
		end
	end

	prefix = prefix[(0..-2)]
	if prefix == ''
		blocknum += 1
		prefix = (['a']*blocksize).join('')
	end

	if blocknum >= blockcount
		break
	end
end

puts 'Recovered plaintext: '
puts known.inspect