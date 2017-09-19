require_relative "matasano"
require "sinatra"

key = Matasano.genkey()

def unsafe_compare(a, b)
	a = a.bytes
	b = b.bytes

	return false unless a.length == b.length

	a.each_with_index do |elem, i|
		return false unless a[i] == b[i]
		sleep 0.05
	end
	return true
end

get '/hmac' do
	file = params[:file]
	signature = params[:signature]

	if unsafe_compare(Matasano.hex2bin(signature), Matasano.hmac_sha1(file, key)) then
		return 'Okay'
	else
		status 500
		return 'Not okay'
	end

end