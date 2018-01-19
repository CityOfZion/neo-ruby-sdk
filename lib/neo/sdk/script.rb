# frozen_string_literal: true

require 'neo/vm/op_code'
require 'digest'

module Neo
  module SDK
    # AVM Script parser
    class Script
      attr_reader :bytes
      attr_accessor :position

      def initialize(bytes = [])
        @bytes = bytes
        @position = 0
        register
      end

      def hash
        sha256 = ::Digest::SHA256.digest bytes.data
        rmd160 = ::Digest::RMD160.hexdigest sha256
        rmd160.scan(/../).reverse.join
      end

      def length
        bytes.length
      end

      def next_opcode
        return :RET if @position >= length
        VM::OpCode[read_byte]
        # print "#{@position}, #{length}"
        # op
      end

      def read_byte
        byte = @bytes[@position]
        @position += 1
        byte
      end

      def read_bytes(n)
        bytes = []
        n.times { bytes << read_byte }
        ByteArray.new(bytes)
      end

      def register
        VM::Interop::Blockchain.scripts[hash] = self
      end

      # Dump a script for debugging purposes
      class Dump
        attr_reader :script

        def initialize(script)
          @script = script
          @operations = []
          parse
        end

        def parse
          while (op = script.next_opcode)
            if respond_to? op
              send op
            else
              @operations << Operation.new(op)
            end
            return if script.position >= script.length
          end
        end

        def operations
          @operations.map.with_index do |op, i|
            message = [op.name]
            message << op.param if op.param
            [i.to_s.rjust(@operations.length.to_s.length, '0'), *message]
          end
        end

        # rubocop:disable Naming/MethodName

        (0x01..0x4B).each do |n|
          name = "PUSHBYTES#{n}".to_sym
          define_method name do
            @operations << Operation.new(name, script.read_bytes(n))
          end
        end

        def PUSHDATA1
          @operations << Operation.new(__callee__, script.read_bytes(read_byte))
        end

        alias SYSCALL PUSHDATA1

        def PUSHDATA2
          @operations << Operation.new(__callee__, script.read_bytes(2))
        end

        alias JMP PUSHDATA2
        alias JMPIF PUSHDATA2
        alias JMPIFNOT PUSHDATA2

        def PUSHDATA4
          @operations << Operation.new(__callee__, script.read_bytes(4))
        end

        def APPCALL
          @operations << Operation.new(__callee__, script.read_bytes(20))
        end

        alias TAILCALL APPCALL

        # rubocop:enable Naming/MethodName

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
end
