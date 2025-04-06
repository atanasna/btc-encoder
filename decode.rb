load("lib/encoder.rb")
load("lib/wallet.rb")

# KEY wallet is used to encrypt and decrypt the smoke wallets
puts("Please enter key wallet phrase:")
phrase = gets.chomp
key_wallet = Wallet::Wallet.generate_from_phrase(phrase: phrase)

puts("Please enter smoke wallet phrase:")
phrase = gets.chomp
smoke_wallet = Wallet::Wallet.generate_from_phrase(phrase: phrase)

puts("---")
real_wallet = Encoder.decode(smoke_wallet, key_wallet)
puts("Real Wallet: #{real_wallet.phrase.words.join(" ")}")
puts("---")
