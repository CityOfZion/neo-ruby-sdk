# frozen_string_literal: true

module Neo
  module SDK
    # Load and execute smart contracts in a simulated environment
    class Contract
      attr_reader :script, :engine, :return_type

      def initialize(script, return_type)
        @script = script
        @return_type = return_type
        @engine = Neo::VM::Engine.new(script)
      end

      def invoke(*_parameters)
        @engine.execute
        result = @engine.evaluation_stack.pop
        value = cast_return result

        # Temporary debugging messages.
        if ENV['DEBUG']
          puts
          puts "HALT RETURN: #{value}" if engine.halted?
          puts 'FAULT' if engine.faulted?
          puts "STORAGE: #{VM::Interop::Blockchain.storages}"
        end

        value
      end

      # TODO: What if it's a ByteArray, etc.
      def cast_return(result)
        case return_type
        when :Boolean
          !result.zero?
        when :Integer
          result.to_i
        else
          result
        end
      end

      def script_hash
        script.hash
      end

      class << self
        def load(path, return_type = :Void)
          File.open(path, 'rb') do |file|
            script = Script.new Array(file.each_byte)
            Contract.new(script, return_type)
          end
        end
      end

      # Contract parameter and return types
      module Parameter
        TYPES = {
          Signature: 0x00,
          Boolean: 0x01,
          Integer: 0x02,
          Hash160: 0x03,
          Hash256: 0x04,
          ByteArray: 0x05,
          PublicKey: 0x06,
          String: 0x07,
          Array: 0x10,
          InteropInterface: 0xf0,
          Void: 0xff
        }.freeze

        TYPES.each do |name, code|
          const_set name, code
        end

        def self.[](code)
          TYPES.key code
        end
      end
    end
  end
end
