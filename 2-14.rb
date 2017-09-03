require_relative "matasano"

@key = Matasano.genkey()
@prepend = Matasano.genkey(Random.rand(128))

def oracle(input)
	append = Matasano.b642bin('Um9sbGluJyBpbiBteSA1LjAKV2l0aCBteSByYWctdG9wIGRvd24gc28gbXkgaGFpciBjYW4gYmxvdwpUaGUgZ2lybGllcyBvbiBzdGFuZGJ5IHdhdmluZyBqdXN0IHRvIHNheSBoaQpEaWQgeW91IHN0b3A/IE5vLCBJIGp1c3QgZHJvdmUgYnkK')
	return Matasano.aes128_ecb_encrypt(Matasano.padd(@prepend + input + append, 16), @key)
end

def has_duplicate_block(input)
	blocks = input.split('').each_slice(16).map(&:join)
	return blocks.length > blocks.uniq.length
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

if has_duplicate_block(oracle(input))
	puts 'ECB detected'
else
	puts 'Could not detect ECB - this wont work'
end

# Detect length of prepended bytes

input = (['a']*(blocksize*2-1)).join('')

while has_duplicate_block(oracle(input)) == false do
	input += 'a'
end

blocks = oracle(input).split('').each_slice(16).map(&:join)
prevblock = nil

for i in blocks.length.times do
	if(blocks[i] == prevblock)
		break
	end
	prevblock = blocks[i]
end

prevbytes = (blocksize - (input.length - blocksize*2))
prevblocks = i-2

if prevbytes == 16
	prevblocks += 1
	prevbytes = 0
end

# Recover secret

blockfiller = (['x']*(blocksize-prevbytes)).join('')
prefix = (['a']*(blocksize-1)).join('')
known = ''
blocknum = prevblocks + 1
blockcount = (oracle('').length/16).ceil

while blocknum < blockcount do

	firstblock = oracle(blockfiller+prefix)[(blocksize*blocknum...blocksize*(blocknum+1))]

	foundbyte = ''
	for i in (0...256) do
		guessblock = blockfiller + prefix + known + [i].pack('c*')

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

end

puts 'Recovered plaintext: '
puts known.inspect