require_relative "matasano"

puts Matasano.unpadd("ICE ICE BABY\x04\x04\x04\x04").inspect

# Throws "Invalid Padding" exception
begin

	puts Matasano.unpadd("ICE ICE BABY\x05\x05\x05\x05").inspect

rescue => exception
	puts "Exception: " + exception.inspect
end