require_relative 'wallet'

class Encoder
  def self.encode(wallet, key_wallet)
    # puts '--- Main Wallet ---'
    # puts "Phrase: #{wallet.phrase.words.join(' ')}"
    # puts "Secret: #{wallet.secret.binary_string}"
    # puts ''
    # puts '--- Key Wallet ---'
    # puts "Phrase: #{key_wallet.phrase.words.join(' ')}"
    # puts "Secret: #{key_wallet.secret.binary_string}"
    # puts ''

    encoder_secret = Encoder.generate_encoder_secret(wallet, key_wallet)
    # puts "Secret: #{encoder_secret.binary_string}"

    Wallet::Wallet.new(number: wallet.secret.number ^ encoder_secret.number)
  end

  def self.generate_encoder_secret(wallet, key_wallet)
    secret_binary_array = []
    multiplier = wallet.secret.size / key_wallet.secret.size + 1

    multiplier.times do
      secret_binary_array += key_wallet.secret.binary_array
    end

    secret_binary_array = secret_binary_array.first(wallet.secret.size)
    Wallet::Segment.generate_from_binary_array(array: secret_binary_array)
  end

  # def self.encode(wallet, key_wallet)
  #     wallet_secret_binary = wallet.secret.join().to_i(2)
  #     key_wallet_secret_binary = key_wallet.secret.join().to_i(2)
  #
  #     multiplier = wallet.secret.size / key_wallet.secret.size + 1
  #     encoder_secret = []
  #     multiplier.times do
  #         encoder_secret += key_wallet.secret
  #     end
  #
  #     encoder_secret = encoder_secret.first(wallet.secret.size)
  #     encoder_secret_binary = encoder_secret.join().to_i(2)
  #     puts "---"
  #     puts wallet.secret.join()
  #     puts key_wallet.secret.join()
  #
  #     encoded_wallet_secret_binary = wallet_secret_binary ^ encoder_secret_binary
  #     encoded_wallet_secret = encoded_wallet_secret_binary.to_s(2).rjust(wallet.secret.size).split("").map(&:to_i)
  #     wallet = Wallet.new(encoded_wallet_secret)
  #     puts wallet.secret.join()
  #     puts "---"
  #     return wallet
  # end
  #
  def self.decode(encoded_wallet, key_wallet)
    encode(encoded_wallet, key_wallet)
  end
end

# bulb picture purpose fury vacant border window search focus fitness scale census abandon"
# bulb picture purpose fury vacant border window search focus fitness scale census
