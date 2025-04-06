class Transform
    def bn_to_bynary(bn)
        return bn.to_s(2)
    end

    # "AfA" => "\x0A\xFA"
    def hexstring_to_binary(hex_string)
        hex_string = hex_string.size.odd? ? "0#{hex_string}" : hex_string
        return [hex_string].pack("H*")
    end

    def binary_to_hexstring(binary)
        return binary.unpack1("H*")
    end

    def binary_to_bitstring(binary)
        return binary.unpack1("B*")
    end

    def bitstring_to_binary(bitstring)
        return [bitstring].pack("B*")
    end

    def hexstring_to_bitstring(hex_string)
        return binary_to_bitstring(hexstring_to_binary(hex_string))
    end
end