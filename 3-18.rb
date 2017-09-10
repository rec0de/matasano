require_relative "matasano"

puts Matasano.aes128_ctr_crypt(Matasano.b642bin('L77na/nrFsKvynd6HzOoG7GHTLXsTVu9qvY/2syLXzhPweyyMTJULu/6/kXX0KSvoOLSFQ=='), 'YELLOW SUBMARINE', 0)