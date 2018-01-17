# frozen_string_literal: true

module Neo
  # A convenience class for working with data as byte arrays rather than strings or plain arrays
  class ByteArray
    attr_reader :data

    def initialize(data = [])
      @data = +''.encode(Encoding::ASCII_8BIT)
      bytes = data.is_a?(String) ? data.unpack('C*') : data
      bytes.each { |datum| self << datum }
    end

    def bytes
      data.bytes
    end

    def length
      bytes.length
    end

    def [](index)
      data.bytes[index]
    end

    def []=(index, byte)
      data.setbyte index, byte
    end

    def <<(byte)
      data << byte
    end

    def ==(other)
      data == other.data
    end

    def to_string
      data.unpack('A*').first
    end

    def to_hex_string(prefix: false)
      hex = data.unpack('H*').first
      prefix ? '0x' + hex : hex
    end

    def to_uint16
      data.unpack('S').first
    end

    # def to_int
    #   data.unpack('c' * @data.length).first
    # end

    def to_s
      "[#{bytes.map { |b| b.to_s(16).rjust(2, '0') }.join(' ')}]"
    end

    class << self
      def from_string(string)
        new string.unpack('C*')
      end

      def from_hex_string(hex)
        new [hex].pack('H*')
      end
    end
  end
end
