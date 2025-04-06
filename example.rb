load('lib/encoder.rb')
load('lib/wallet.rb')

# main_wallet = Wallet.generate(256)
# key_wallet = Wallet.generate(128)
# encoded_wallet = Encoder.encode(main_wallet, key_wallet)
# decoded_wallet = Encoder.decode(encoded_wallet, key_wallet)
# i = 0
# 10_000.times do
w = Wallet::Wallet.new
k = Wallet::Wallet.new(size: 128)
e = Encoder.encode(w, k)
d = Encoder.decode(e, k)
t = Wallet::Wallet.generate_from_phrase(phrase: d.phrase.words.join(' '))

# if i == 9999 ||
#   w.phrase.words != t.phrase.words ||
#   w.secret.number != t.secret.number
puts("Main Wallet: #{w.phrase.words.join(' ')}")
puts("Main Number: #{w.secret.number}")
puts("Key Wallet: #{k.phrase.words.join(' ')}")
puts("Encoded Wallet: #{e.phrase.words.join(' ')}")
puts("Decoded Wallet: #{d.phrase.words.join(' ')}")
puts("Decoded Number: #{d.secret.number}")
puts("Test Wallet: #{t.phrase.words.join(' ')}")
puts("Test Number: #{t.secret.number}")
# raise "Failed at #{i}"
# end

print('.')

# i += 1
# end
