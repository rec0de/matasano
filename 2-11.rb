require_relative "matasano"

def cryptooracle(plain)
	key = Matasano.genkey()
	plain = Matasano.padd(Matasano.genkey(5 + Random.rand(5)) + plain + Matasano.genkey(5 + Random.rand(5)), 16)

	if Random.rand(2) == 1
		return Matasano.aes128_ecb_encrypt(plain, key)
	else
		return Matasano.aes128_cbc_encrypt(plain, key, Matasano.genkey())
	end
end

for i in (1..20) do
	plain = 'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa'
	#puts plain.inspect
	blocks = cryptooracle(plain).split('').each_slice(16).map(&:join)

	if blocks.length > blocks.uniq.length
		puts 'ECB'
	else
		puts 'CBC'
	end
end