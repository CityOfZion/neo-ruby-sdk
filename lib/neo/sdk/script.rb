require 'neo/vm/op_code'

module Neo
  module SDK
    class Script
      attr_reader :bytes, :operations

      def initialize(bytes)
        @bytes = bytes
        @operations = []
        @position = -1

        while op = next_instruction
          case op
          when /PUSHBYTES(\d+)/
            @operations << Operation.new(op, read_bytes($1.to_i))
          when :PUSHDATA1
            @operations << Operation.new(op, read_bytes(read_byte))
          when :PUSHDATA2
            @operations << Operation.new(op, read_bytes(2))
          when :PUSHDATA4
          when :JUMPIFNOT
            @operations << Operation.new(op, read_bytes(4))
          when :TAILCALL
            @operations << Operation.new(op, read_bytes(20))
          when :SYSCALL
            @operations << Operation.new(op, read_bytes(read_byte).pack('c*'))
          else
            @operations << Operation.new(op)
          end
        end
      end

      def next_instruction
        if @position <= @bytes.length
          @position += 1
          VM::OpCode[@bytes[@position]]
        end
      end

      def read_byte
        @position += 1
        @bytes[@position]
      end

      def read_bytes(n)
        [].tap do |bytes|
          n.times { bytes << read_byte }
        end
      end

      def hash
        bytes = @bytes.pack('c*')
        sha256 = Digest::SHA256.digest bytes
        rmd160 = Digest::RMD160.hexdigest sha256
        rmd160.scan(/../).reverse.join
      end

      def dump
        @operations.map.with_index do |op, i|
          message = [op.name]
          if op.data
            if op.data.respond_to? :map
              message << "0x#{op.data.compact.map { |n| '%02x' % n }.join}"
            else
              message << op.data
            end
          end
          [i.to_s.rjust(@operations.length.to_s.length, '0'), *message]
        end
      end

      class << self
        def load(path)
          File.open(path, 'rb') do |file|
            Script.new Array(file.each_byte)
          end
        end
      end

      class Operation
        attr_reader :name
        attr_reader :data

        def initialize(name, data = nil)
          @name = name
          @data = data
        end
      end
    end
  end
end
