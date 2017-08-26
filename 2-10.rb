require_relative "matasano"

path = '2-10.txt'
ciphertext = File.readlines(path).map{ |x| x.chomp }.join('')
ciphertext = Matasano.b642bin(ciphertext)

key = 'YELLOW SUBMARINE'.b
iv = ([0]*16).pack('c*').b

puts Matasano.aes128_cbc_decrypt(ciphertext, key, iv).inspect