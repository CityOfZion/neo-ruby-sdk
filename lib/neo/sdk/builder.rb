# frozen_string_literal: true

module Neo
  module SDK
    # Script Builder
    class Builder
      attr_reader :bytes

      def initialize
        @bytes = ByteArray.new
      end

      def emit(op_code, param = nil)
        write_byte VM::OpCode.const_get(op_code)
        case param
        when ByteArray
          param.bytes.each do |byte|
            write_byte byte
          end
        end
      end

      def emit_push(data)
        case data
        when -1    then emit :PUSHM1
        when 0..16 then emit "PUSH#{data}"
        end
      end

      def emit_app_call(script_hash, params: [], use_tail_call: false)
        params.each do |param|
          emit_push param
        end
        emit use_tail_call ? :TAILCALL : :APPCALL, ByteArray.from_hex_string(script_hash)
      end

      private

      def write_byte(byte)
        @bytes << byte
      end

      # def write_bytes(bytes)
      #   case bytes
      #   when Array
      #
      #   when Integer
      #     write_bytes [bytes].pack('I')
      #   when String
      #     write_bytes bytes.unpack('C*')
      #   end
      # end
    end
  end
end
