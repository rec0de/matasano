require_relative "matasano"

string = 'YELLOW SUBMARINE'
blocksize = 20

puts Matasano.padd(string, blocksize).inspect