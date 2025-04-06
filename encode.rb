load("lib/encoder.rb")
load("lib/wallet.rb")

# KEY wallet is used to encrypt and decrypt the smoke wallets
puts("Please enter key wallet phrase:")
phrase = gets.chomp
key_wallet = Wallet::Wallet.generate_from_phrase(phrase: phrase)

puts("Enter the number of smoke wallets to be generated:")
count = gets.chomp.to_i

puts("Generating smoke wallets....")
puts("---")
count.times do
  real_wallet = Wallet::Wallet.new(size: 256)
  smoke_wallet = Encoder.encode(real_wallet, key_wallet)

  puts("Real Wallet: #{real_wallet.phrase.words.join(" ")}")
  puts("Smoke Wallet: #{smoke_wallet.phrase.words.join(" ")}")
  puts("---")
end
