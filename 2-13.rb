require_relative "matasano"

@key = Matasano.genkey()

def parse(input)
	input = input.split('&')
	output = Hash.new
	input.each do |element| 
		element = element.split('=')
		output[element[0]] = element[1] || nil
	end
	return output
end

def encode(input)
	output = String.new
	input.each do |key, value|
		output += key.to_s.gsub(/[&=]/, '') + '=' + value.to_s.gsub(/[&=]/, '') + '&'
	end
	return output[0...-1]
end

def profile_for(mail)
	profile = Hash.new
	profile['email'] = mail
	profile['uid'] = 10
	profile['role'] = 'user'
	return Matasano.aes128_ecb_encrypt(Matasano.padd(encode(profile), 16), @key)
end 

def has_duplicate_block(input)
	blocks = input.split('').each_slice(16).map(&:join)
	return blocks.length > blocks.uniq.length
end

puts profile_for('cyb@rec0de.net').inspect

# Detect block size
input = ''
length = profile_for(input).length

while profile_for(input).length == length do
	input += 'a'
end

length = profile_for(input).length
blocksize = 0

while profile_for(input).length == length do
	input += 'a'
	blocksize += 1
end

puts 'Cipher blocksize: ' + blocksize.inspect

# Detect ecb mode

input = (['a']*(blocksize*4)).join('')

if has_duplicate_block(profile_for(input))
	puts 'ECB detected'
else
	puts 'Could not detect ECB - this wont work'
end

# Detect how many bytes precede user input

input = (['a']*(blocksize*2-1)).join('')

while has_duplicate_block(profile_for(input)) == false do
	input += 'a'
end

blocks = profile_for(input).split('').each_slice(16).map(&:join)
prevblock = nil

for i in blocks.length.times do
	if(blocks[i] == prevblock)
		break
	end
	prevblock = blocks[i]
end

prevbytes = (blocksize - (input.length - blocksize*2))
prevblocks = i-2

# Construct 'admin' block

mail = (['a']*(blocksize - prevbytes)).join('')+'admin'+([4]*(blocksize-5)).pack('c*')

adminblock = profile_for(mail)[(prevblocks+1)*blocksize...(prevblocks+2)*blocksize]

# Craft email that pushes last 4 bytes into new block
mail = 'a@rec0de'
prev = profile_for(mail)

while prev.length == profile_for(mail).length do
	mail = 'a' + mail
end

mail = mail + '.net';

admindata = profile_for(mail).split('').each_slice(16).map(&:join)
admindata[-1] = adminblock
admindata = admindata.join('')

puts parse(Matasano.aes128_ecb_decrypt(admindata, @key)).inspect
