require 'securerandom'
require 'digest'

module Wallet
  class Wallet
    attr_reader :secret, :check, :phrase

    def initialize(number: nil, size: nil)
      @secret = Secret.new(number: number, size: size)
      @check = Check.new(secret: @secret)
      @phrase = Phrase.new(secret: @secret, check: @check)
    end

    def self.generate_from_phrase(phrase:)
      dictionary = File.open('lib/dictionary').read.split("\n")
      words = phrase.split(' ')
      secret_binary_string = ''

      size = 128 if words.size == 12
      size = 160 if words.size == 15
      size = 192 if words.size == 18
      size = 224 if words.size == 21
      size = 256 if words.size == 24

      words.each do |word|
        secret_binary_string += dictionary.index(word).to_s(2).rjust(11, '0')
      end

      secret = Secret.generate_from_binary_string(string: secret_binary_string[0..size - 1])

      new(number: secret.number)
    end
  end

  class Segment
    attr_reader :number, :size

    def initialize(number:, size:)
      raise 'Number should be either an integer or nil' unless number.instance_of? Integer
      raise 'Size should be either an integer or nil' unless size.instance_of? Integer

      @number = number
      @size = size
    end

    def binary_string
      @number.to_s(2).rjust(@size, '0')
    end

    def binary_array
      binary_string.split('').map(&:to_i)
    end

    def self.generate_from_binary_string(string:)
      number = string.to_i(2)
      size = string.size
      new(number: number, size: size)
    end

    def self.generate_from_binary_array(array:)
      generate_from_binary_string(string: array.join(''))
    end
  end

  class Secret < Segment
    def initialize(number: nil, size: nil)
      size ||= 256
      raise 'Number should be either an integer or nil' unless number.instance_of? Integer or number.nil?
      raise 'Size should be an integer' unless size.instance_of? Integer
      raise 'Size should be one of [128,160,192,224,256]' unless [128, 160, 192, 224, 256].include? size

      # 1. Generate a random #{size} key
      bn = number
      bn = SecureRandom.random_number(2**size) if number.nil?

      size = 256 if bn.to_s(2).size <= 256
      size = 224 if bn.to_s(2).size <= 224
      size = 192 if bn.to_s(2).size <= 192
      size = 160 if bn.to_s(2).size <= 160
      size = 128 if bn.to_s(2).size <= 128

      super(number: bn, size: size)
    end
  end

  class Check < Segment
    def initialize(secret:)
      raise 'Secret should be of type Wallet::Secret' unless secret.instance_of? Secret

      check_bits = Check.secret_check_bits(secret: secret)
      segment = Segment.generate_from_binary_array(array: check_bits)
      super(number: segment.number, size: segment.size)
    end

    def self.secret_check_bits(secret:)
      raise 'Secret should be of type Wallet::Secret' unless secret.instance_of? Secret

      binary_secret = [secret.number.to_s(2).rjust(secret.size, '0')].pack('B*')
      hash = Digest::SHA256.hexdigest(binary_secret)
      number_of_check_bits = 11 - secret.size % 11

      hash
        .split('')
        .map { |e| e.to_i(16).to_s(2).rjust(4, '0') }
        .join('')
        .split('')
        .map(&:to_i).first(number_of_check_bits)
    end
  end

  class Phrase
    attr_reader :words

    def initialize(secret:, check:)
      raise 'Secret should be of type Wallet::Secret' unless secret.instance_of? Secret
      raise 'Check should be of type Wallet::Check' unless check.instance_of? Check

      @words = Phrase.generate(secret: secret, check: check)
    end

    def self.generate(secret:, check:)
      raise 'Secret should be of type Wallet::Secret' unless secret.instance_of? Secret
      raise 'Check should be of type Wallet::Check' unless check.instance_of? Check

      dictionary = File.open('lib/dictionary').read.split("\n")
      all_bits = secret.binary_array + check.binary_array

      all_bits
        .each_slice(11).to_a
        .map { |s| s.join('').to_i(2) }
        .map { |i| dictionary[i] }
    end
  end
end
