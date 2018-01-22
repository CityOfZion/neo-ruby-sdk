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
        # :nocov:
        else raise NotImplementedError, param unless param.nil?
        end
        # :nocov:
      end

      # rubocop:disable Metrics/CyclomaticComplexity
      def emit_push(data)
        case data
        when true      then emit :PUSHT
        when false     then emit :PUSHF
        when -1        then emit :PUSHM1
        when 0..16     then emit "PUSH#{data}"
        when Array     then emit_push_array data
        when ByteArray then emit_push_bytes data
        when Integer   then emit_push_bytes ByteArray.from_integer(data)
        when String    then emit_push_bytes ByteArray.from_string(data.encode('UTF-8'))
        # :nocov:
        else raise NotImplementedError, data
        end
        # :nocov:
      end
      # rubocop:enable Metrics/CyclomaticComplexity

      def emit_app_call(script_hash, params: [], use_tail_call: false)
        params.reverse.each do |param|
          emit_push param
        end
        emit use_tail_call ? :TAILCALL : :APPCALL, ByteArray.from_hex_string(script_hash)
      end

      def emit_push_array(items)
        items.reverse.each do |item|
          emit_push item
        end
        emit_push items.length
        emit :PACK
      end

      def emit_push_bytes(byte_array)
        len = byte_array.length
        case len
        when 1..75 then emit "PUSHBYTES#{len}", byte_array
        # :nocov:
        else raise NotImplementedError, len
        end
        # :nocov:
      end

      private

      def write_byte(byte)
        @bytes << byte
      end
    end
  end
end
