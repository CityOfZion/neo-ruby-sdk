# frozen_string_literal: true

module Neo
  module SDK
    # Simulated execution environment for contracts to run in.
    class Simulation
      autoload :Blockchain,           'neo/sdk/simulation/blockchain'
      autoload :Contract,             'neo/sdk/simulation/contract'
      autoload :Runtime,              'neo/sdk/simulation/runtime'
      autoload :StorageContext,       'neo/sdk/simulation/storage_context'

      attr_reader :script, :return_type

      def initialize(script, return_type = nil)
        @script = script
        @return_type = return_type || :Void
        @context = Context.new

        if script.is_a? Script
          @context.instance_variable_set :@__script_hash__, script_hash
        else
          @context.instance_eval script
        end
      end

      def invoke(*parameters)
        cast_return @context.main(*parameters)
      end

      # TODO: What if it's a ByteArray, etc.
      def cast_return(result)
        case return_type
        when :Boolean then cast_boolean result
        when :Integer then cast_integer result
        when :String  then cast_string  result
        when :Void    then nil
        # :nocov:
        else raise NotImplementedError, "#{result.inspect} (#{return_type})"
        end
        # :nocov:
      end

      def cast_boolean(result)
        case result
        when TrueClass, FalseClass then result
        when Integer then !result.zero?
        # :nocov:
        else raise NotImplementedError, result.class
        end
        # :nocov:
      end

      def cast_integer(result)
        case result
        when Integer then result
        when ByteArray then result.to_integer
        # :nocov:
        else raise NotImplementedError, result.class
        end
        # :nocov:
      end

      def cast_string(result)
        case result
        when String then result
        when ByteArray then result.to_string
        # :nocov:
        else raise NotImplementedError, result.class
        end
        # :nocov:
      end

      def script_hash
        script.hash
      end

      # This is the context our smart contract is exected in.
      # See Simuation#new, main is overriden in ruby script executions
      class Context

        def main(*parameters)
          engine = Neo::VM::Engine.new
          engine.load_script Simulation.entry_script(@__script_hash__, parameters)
          engine.execute
          engine.evaluation_stack.pop
        end
      end

      class << self
        def load(path, return_type = nil)
          File.open(path, 'rb') do |file|
            script = Script.new ByteArray.new(file.read)
            Simulation.new script, return_type
          end
        end

        def entry_script(script_hash, parameters)
          builder = Builder.new
          builder.emit_app_call script_hash, params: parameters
          Script.new builder.bytes
        end

        def reset
          Blockchain.storages.clear
        end
      end
    end
  end
end
