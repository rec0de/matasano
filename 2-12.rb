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
prefixlength = blocksize-1

while prefix[0] == 'a' do

	firstblock = oracle(prefix[0...prefixlength])[(0...blocksize)]
	#puts prefix.inspect
	#puts prefix[0..prefixlength].inspect

	foundbyte = ''
	for i in (0...256) do
		guessblock = prefix + [i].pack('c*')

		#puts guessblock.inspect
		if firstblock == oracle(guessblock)[0...blocksize]
			foundbyte = [i].pack('c*')
			puts 'Found:' + foundbyte.inspect
			break
		end
	end

	prefix = (prefix + foundbyte)[(-prefix.length..-1)]
	prefixlength -= 1
end

prefix = (['a']*(blocksize-1)).join('') + prefix
prefixlength += blocksize-2

firstblock = oracle(prefix[0...prefixlength])[(blocksize...blocksize*2)]
puts prefix.inspect
puts prefix[0..prefixlength].inspect

	foundbyte = ''
	for i in (0...256) do
		guessblock = prefix + [i].pack('c*')

		puts guessblock.inspect
		if firstblock == oracle(guessblock)[blocksize...blocksize*2]
			foundbyte = [i].pack('c*')
			puts 'Found:' + foundbyte.inspect
			break
		end
	end

	prefix = (prefix + foundbyte)[(-prefix.length..-1)]
	prefixlength -= 1