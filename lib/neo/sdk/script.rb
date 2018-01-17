# frozen_string_literal: true

require 'neo/vm/op_code'
require 'digest'

module Neo
  module SDK
    class Script
      attr_reader :bytes, :operations

      def initialize(bytes = [])
        @bytes = bytes
        @operations = []
        @position = -1
        parse
        register
      end

      def hash
        sha256 = ::Digest::SHA256.digest bytes.data
        rmd160 = ::Digest::RMD160.hexdigest sha256
        rmd160.scan(/../).reverse.join
      end

      def dump
        @operations.map.with_index do |op, i|
          message = [op.name]
          message << op.param if op.param
          [i.to_s.rjust(@operations.length.to_s.length, '0'), *message]
        end
      end

      def length
        @operations.length
      end

      private

      def parse
        while (op = next_opcode)
          case op
          when /PUSHBYTES(\d+)/
            @operations << Operation.new(op, read_bytes(Regexp.last_match(1).to_i))
          when :PUSHDATA1, :SYSCALL
            @operations << Operation.new(op, read_bytes(read_byte))
          when :PUSHDATA2, :JMP, :JMPIF, :JUMPIFNOT
            @operations << Operation.new(op, read_bytes(2))
          when :PUSHDATA4
            @operations << Operation.new(op, read_bytes(4))
          when :APPCALL, :TAILCALL
            @operations << Operation.new(op, read_bytes(20))
          else
            @operations << Operation.new(op)
          end
        end
        # rescue StandardError
        # binding.pry
      end

      def next_opcode
        return if @position >= @bytes.length
        @position += 1
        VM::OpCode[@bytes[@position]]
      end

      def read_byte
        @position += 1
        @bytes[@position]
      end

      def read_bytes(n)
        bytes = []
        n.times { bytes << read_byte }
        ByteArray.new(bytes)
      end

      def register
        VM::Interop::Blockchain.scripts[hash] = self
      end

      # Represents an op code and an optional accompanying parameter.
      class Operation
        attr_reader :name
        attr_reader :param

        def to_s
          [name, param].compact.join(': ')
        end

        def initialize(name, param = nil)
          @name = name
          @param = param
        end
      end
    end
  end
end
