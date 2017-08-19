require_relative "matasano"

path = '1-6.txt'
ciphertext = File.readlines(path).map{ |x| x.chomp }.join('')
ciphertext = Matasano.b642bin(ciphertext)

estimated_keysize = Matasano.xor_repeat_find_keysize(ciphertext)

puts 'Estimated keysize: ' + estimated_keysize.to_s

recovered_key = Matasano.break_xor_repeat(ciphertext, estimated_keysize)
plaintext = Matasano.xor_repeat(ciphertext, recovered_key)

puts plaintext.inspect
puts 'Recovered key: ' + recovered_key.inspect
