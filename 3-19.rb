require_relative "matasano"

plaintexts = ["SSBoYXZlIG1ldCB0aGVtIGF0IGNsb3NlIG9mIGRheQ==", "Q29taW5nIHdpdGggdml2aWQgZmFjZXM=", "RnJvbSBjb3VudGVyIG9yIGRlc2sgYW1vbmcgZ3JleQ==", "RWlnaHRlZW50aC1jZW50dXJ5IGhvdXNlcy4=", "SSBoYXZlIHBhc3NlZCB3aXRoIGEgbm9kIG9mIHRoZSBoZWFk", "T3IgcG9saXRlIG1lYW5pbmdsZXNzIHdvcmRzLA==", "T3IgaGF2ZSBsaW5nZXJlZCBhd2hpbGUgYW5kIHNhaWQ=", "UG9saXRlIG1lYW5pbmdsZXNzIHdvcmRzLA==", "QW5kIHRob3VnaHQgYmVmb3JlIEkgaGFkIGRvbmU=", "T2YgYSBtb2NraW5nIHRhbGUgb3IgYSBnaWJl", "VG8gcGxlYXNlIGEgY29tcGFuaW9u", "QXJvdW5kIHRoZSBmaXJlIGF0IHRoZSBjbHViLA==", "QmVpbmcgY2VydGFpbiB0aGF0IHRoZXkgYW5kIEk=", "QnV0IGxpdmVkIHdoZXJlIG1vdGxleSBpcyB3b3JuOg==", "QWxsIGNoYW5nZWQsIGNoYW5nZWQgdXR0ZXJseTo=", "QSB0ZXJyaWJsZSBiZWF1dHkgaXMgYm9ybi4=", "VGhhdCB3b21hbidzIGRheXMgd2VyZSBzcGVudA==", "SW4gaWdub3JhbnQgZ29vZCB3aWxsLA==", "SGVyIG5pZ2h0cyBpbiBhcmd1bWVudA==", "VW50aWwgaGVyIHZvaWNlIGdyZXcgc2hyaWxsLg==", "V2hhdCB2b2ljZSBtb3JlIHN3ZWV0IHRoYW4gaGVycw==", "V2hlbiB5b3VuZyBhbmQgYmVhdXRpZnVsLA==", "U2hlIHJvZGUgdG8gaGFycmllcnM/", "VGhpcyBtYW4gaGFkIGtlcHQgYSBzY2hvb2w=", "QW5kIHJvZGUgb3VyIHdpbmdlZCBob3JzZS4=", "VGhpcyBvdGhlciBoaXMgaGVscGVyIGFuZCBmcmllbmQ=", "V2FzIGNvbWluZyBpbnRvIGhpcyBmb3JjZTs=", "SGUgbWlnaHQgaGF2ZSB3b24gZmFtZSBpbiB0aGUgZW5kLA==", "U28gc2Vuc2l0aXZlIGhpcyBuYXR1cmUgc2VlbWVkLA==", "U28gZGFyaW5nIGFuZCBzd2VldCBoaXMgdGhvdWdodC4=", "VGhpcyBvdGhlciBtYW4gSSBoYWQgZHJlYW1lZA==", "QSBkcnVua2VuLCB2YWluLWdsb3Jpb3VzIGxvdXQu", "SGUgaGFkIGRvbmUgbW9zdCBiaXR0ZXIgd3Jvbmc=", "VG8gc29tZSB3aG8gYXJlIG5lYXIgbXkgaGVhcnQs", "WWV0IEkgbnVtYmVyIGhpbSBpbiB0aGUgc29uZzs=", "SGUsIHRvbywgaGFzIHJlc2lnbmVkIGhpcyBwYXJ0", "SW4gdGhlIGNhc3VhbCBjb21lZHk7", "SGUsIHRvbywgaGFzIGJlZW4gY2hhbmdlZCBpbiBoaXMgdHVybiw=", "VHJhbnNmb3JtZWQgdXR0ZXJseTo=", "QSB0ZXJyaWJsZSBiZWF1dHkgaXMgYm9ybi4="]
ciphertexts = []
@key = Matasano.genkey()

plaintexts.each do |plain|
	ciphertexts.push(Matasano.aes128_ctr_crypt(Matasano.b642bin(plain), @key, 0))
end

guessed_keystream = ([0]*(16*3)).pack('c*')
guess_pos = 0

while true do
	puts 'Cmd:'
	input = gets().chomp

	if input == '<'
		guess_pos -= 1
		puts 'Guess Pos at '+guess_pos.to_s
	elsif input == '>'
		guess_pos += 1
		puts 'Guess Pos at '+guess_pos.to_s
	else
		puts input.inspect
		guessed_keystream[guess_pos] = Matasano.xor(ciphertexts[-3][guess_pos], input) # -3 is longest ciphertext
		ciphertexts.each do |cipher|
			puts Matasano.xor(guessed_keystream, cipher).inspect
		end
	end 
end

=begin
I have met them at close of day
Coming with vivid faces
From counter or desk among grey
Eighteenth-century houses.
I have passed with a nod of the head
Or polite meaningless words,
Or have lingered awhile and said
Polite meaningless words,
And thought before I had done
Of a mocking tale or a gibe
To please a companion
Around the fire at the club,
Being certain that they and I
But lived where motley is worn:
All changed, changed utterly:
A terrible beauty is born.
That woman's days were spent
In ignorant good will,
Her nights in argument
Until her voice grew shrill.
What voice more sweet than hers
When young and beautiful,
She rode to harriers?
This man had kept a school
And rode our winged horse.
This other his helper and friend
Was coming into his force;
He might have won fame in the end,
So sensitive his nature seemed,
So daring and sweet his thought.
This other man I had dreamed
A drunken, vain-glorious lout.
He had done most bitter wrong
To some who are near my heart,
Yet I number him in the song;
He, too, has resigned his part
In the casual comedy;
He, too, has been changed in his turn,
Transformed utterly:
A terrible beauty is born.
=end