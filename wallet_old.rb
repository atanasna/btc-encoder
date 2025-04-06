require 'digest'

class Wallet
    attr_reader :secret

    def initialize(secret)
        raise "Number of bits for secret should be one of [128,160,192,224,256]" if not [128, 160, 192, 224, 256].include? secret.size 
        
        @secret = secret
    end

    def check_bits()
        secret_in_binary = [@secret.join('')].pack("B*")
        hash = Digest::SHA256.hexdigest(secret_in_binary)
        number_of_check_bits = 11 - @secret.size % 11
        
        return hash
            .split("")
            .map{|e| e.to_i(16).to_s(2).rjust(4,"0") }
            .join("")
            .split("")
            .map(&:to_i).first(number_of_check_bits)
    end

    def phrase()
        words = File.open("dictionary").read.split("\n")
        all_bits = @secret + check_bits()

        return all_bits
            .each_slice(11).to_a
            .map{|s| s.join("").to_i(2)}
            .map{|i| words[i]}
            .join(" ")
    end

    # Class Methods
    def self.generate_from_phrase(phrase)
        words = File.open("dictionary").read.split("\n")
        phrase_bits = phrase.split(" ")
            .map{|w| words.index(w)}
            .map{|i| i.to_s(2).rjust(11,"0")}
            .join("")
            .split("")
            .map(&:to_i)
        number_check_bits = phrase_bits.length%32
        secret = phrase_bits.first(phrase_bits.length - number_check_bits)

        return Wallet.new(secret)
    end

    def self.generate(size = 256)
        secret = []
        size.times do 
            secret.push(rand(0..1)) 
        end
        
        return Wallet.new(secret)
    end

end
        
#bulb picture purpose fury vacant border window search focus fitness scale census abandon"
#bulb picture purpose fury vacant border window search focus fitness scale census
