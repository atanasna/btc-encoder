require "openssl"
require "securerandom"

class Wallet
    attr_reader :secret, :size

    def initialize(bn: nil, size: 256)
        # 1. Generate a random #{size} key
        if bn.nil?
            raise "Number of bits for secret should be one of [128,160,192,224,256]" if not [128, 160, 192, 224, 256].include? size
            bn = OpenSSL::BN.new(SecureRandom.random_bytes(size/8), 2)
        end
        
        private_key_str = bn.to_s(2).rjust(32, "\x00")

        # 2. Create an ASN.1 structure
        asn1 = OpenSSL::ASN1::Sequence([
            OpenSSL::ASN1::Integer(1),
            OpenSSL::ASN1::OctetString(private_key_str),
            OpenSSL::ASN1::ObjectId("prime256v1", 0, :EXPLICIT)
        ])

        # 3. Create the EC key
        @size = bn.to_s(2).unpack("B*").first.size
        @secret = OpenSSL::PKey::EC.new(asn1.to_der)
    end

    def phrase()
        words = File.open("dictionary").read.split("\n")
        phrase_bits = private_key_bits() + phrase_check_bits()

        return phrase_bits
            .scan(/.{11}/)
            .map{|s| s.to_i(2)}
            .map{|i| words[i]}
    end

    #private
    def private_key() 
        return @secret.private_key 
    end

    def private_key_binary()
        return @secret.private_key.to_s(2)
    end
    
    def private_key_bits() 
        return @secret.private_key.to_s(2).unpack("B*").first 
    end
    
    def phrase_check_bits()
        hash = Digest::SHA256.hexdigest(private_key_binary())
        number_of_check_bits = 11 - @size % 11
        
        return [hash].pack("H*").unpack("B*").first[0..number_of_check_bits-1]
    end

    def self.generate(size = 256)
      return Wallet.new(size: size)
    end
end
