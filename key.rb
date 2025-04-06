class BitcoinKey
  def initialize
    @bits
  end

  def to_s
    @key.to_base58
  end

  def to_hash
    { 'private_key' => @key.priv, 'public_key' => @key.pub }
  end

  def generate_from_phrase()
  end

  def self.generate_random(size = 256)
    bits = []
    size.times do 
        bits.push(rand(0..1)) 
    end
    
    return Wallet.new(secret)
  end

end