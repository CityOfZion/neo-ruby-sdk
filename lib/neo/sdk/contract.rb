# frozen_string_literal: true

module Neo
  module SDK
    # Load and execute smart contracts in a simulated environment
    class Contract
      attr_reader :script, :return_type

      def initialize(script, return_type)
        @script = script
        @return_type = return_type
      end

      def invoke(*parameters)
        engine = Neo::VM::Engine.new
        engine.load_script entry_script(parameters)
        engine.execute
        result = engine.evaluation_stack.pop
        cast_return result
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

      def entry_script(parameters)
        builder = Builder.new
        builder.emit_app_call script_hash, params: parameters
        Script.new builder.bytes
      end

      class << self
        def load(path, return_type = :Void)
          File.open(path, 'rb') do |file|
            script = Script.new ByteArray.new(file.read)
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
