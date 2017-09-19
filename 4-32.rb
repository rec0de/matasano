require_relative "matasano"
require 'net/http'

# Blocking http requests get reeeeally slow
def try_mac(file, mac)
	url = URI.parse('http://localhost:4567/hmac?file='+file+'&signature='+Matasano.bin2hex(mac))
	req = Net::HTTP::Get.new(url.to_s)
	res = Net::HTTP.start(url.host, url.port) {|http| http.request(req)}
	return res.body
end

mac = ''
avg = 0
variance = 0
sample = []
sample_size = 15
confidence_interval = 8

sample_size.times do
	start_time = Time.now()
	try_mac('evil.exe', Matasano.padd(mac + [Random.rand(256)].pack('c*'), 20))
	elapsed = (Time.now() - start_time)*1000
	sample.push(elapsed)
end

avg = sample.sum / sample.length
variance = sample.map{|x| (x - avg)**2}.sum / sample.length

puts 'Average response time: ' + avg.to_s
puts 'Variance: ' + variance.to_s

puts 'Start cracking with sample size '+sample_size.to_s
cracktime_start = Time.now()

while mac.length < 20 do
	i = 0

	sample = []
	sample_size.times do
		start_time = Time.now()
		try_mac('evil.exe', mac + [255].pack('c*') + ([0]*(19-mac.length)).pack('c*'))
		elapsed = (Time.now() - start_time)*1000
		sample.push(elapsed)
	end

	avg_invalid = sample.sum / sample.length

	while i < 256 do

		sample = []
		solved = false
		sample_size.times do
			start_time = Time.now()
			try_mac('evil.exe', mac + [i].pack('c*') + ([0]*(19-mac.length)).pack('c*'))
			elapsed = (Time.now() - start_time)*1000
			sample.push(elapsed)
		end

		avg = sample.sum / sample.length
		variance = sample.map{|x| (x - avg)**2}.sum / sample.length

		if (avg > avg_invalid && ((avg - avg_invalid)/Math.sqrt(variance)) > confidence_interval) then
			mac += [i].pack('c*')
			puts 'Found byte: '+[i].pack('c*').inspect
			puts 'Confidence: '+((avg - avg_invalid)/Math.sqrt(variance)).to_s
			solved = true
			break
		end

		i += 1
	end

	if !solved then
		puts 'Backtracking...'
		mac = mac[0...-1]
	end

end

puts mac.inspect
puts try_mac('evil.exe', mac)
puts 'Cracking took '+(Time.now.to_i - cracktime_start.to_i).to_s+'s'