require_relative "matasano"
require 'net/http'

# Blocking http requests get reeeeally slow
def try_mac(file, mac)
	url = URI.parse('http://localhost:4567/hmac?file='+file+'&signature='+Matasano.bin2hex(mac))
	req = Net::HTTP::Get.new(url.to_s)
	res = Net::HTTP.start(url.host, url.port) {|http| http.request(req)}
	return res.body
end

avg = 0
time_per_char = 0
mac = ''
thread_count = 5

10.times do
	threads = []
	thread_count.times do |j|
		threads << Thread.new {
			start_time = Time.now()
			try_mac('evil.exe', Matasano.padd(mac + [0].pack('c*'), 20))
			elapsed = (Time.now() - start_time)*1000
			avg += elapsed
		}
	end

	threads.each{|thread| thread.join()}
end

avg = avg / (10*thread_count)

puts 'Average response time: ' + avg.to_s

puts 'Start cracking with '+thread_count.to_s+' threads'
cracktime_start = Time.now()

while mac.length < 20 do
	solution_found = false
	i = 0

	while i < 256 do
		threads = []
		thread_count.times do |j|
			threads << Thread.new {
				start_time = Time.now()
				try_mac('evil.exe', mac + [i+j].pack('c*') + ([0]*(19-mac.length)).pack('c*'))
				elapsed = (Time.now() - start_time)*1000

				if elapsed > (avg*3 + time_per_char*(mac.length + 0.5)) then
					mac += [i+j].pack('c*')
					time_per_char = (elapsed - avg) / mac.length
					solution_found = true
				end
			}
		end

		threads.each{|thread| thread.join()}
		break if solution_found
		i += thread_count
	end

end

puts mac.inspect
puts try_mac('evil.exe', mac)
puts 'Cracking with '+thread_count.to_s+' threads took '+(Time.now.to_i - cracktime_start.to_i).to_s+'s'