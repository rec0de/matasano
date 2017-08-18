require "base64"

hex = '49276d206b696c6c696e6720796f757220627261696e206c696b65206120706f69736f6e6f7573206d757368726f6f6d'

binary = [hex].pack('H*')

base64 = Base64.strict_encode64(binary)

puts base64.inspect

# Check validity
puts base64 == 'SSdtIGtpbGxpbmcgeW91ciBicmFpbiBsaWtlIGEgcG9pc29ub3VzIG11c2hyb29t' ? 'Checks out' : 'Error'