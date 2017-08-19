require_relative "matasano"

path = '1-7.txt'
ciphertext = File.readlines(path).map{ |x| x.chomp }.join('')
ciphertext = Matasano.b642bin(ciphertext)

key = 'YELLOW SUBMARINE'

plain = Matasano.aes128_ecb_decrypt(ciphertext, key)

puts plain.inspect