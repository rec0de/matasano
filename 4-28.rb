require_relative "matasano"

refhash = Matasano.bin2hex(Matasano.sha1('The quick brown fox jumps over the lazy dog'))
puts refhash

if refhash == '2fd4e1c67a2d28fced849ee1bb76e7391b93eb12' then
	puts 'Checks out'
else
	puts 'Error'
end