# frozen_string_literal: true

module Neo
  module SDK
    # Simulated execution environment for contracts to run in.
    class Simulation
      autoload :Blockchain,           'neo/sdk/simulation/blockchain'
      autoload :Contract,             'neo/sdk/simulation/contract'
      autoload :Runtime,              'neo/sdk/simulation/runtime'
      autoload :StorageContext,       'neo/sdk/simulation/storage_context'
      autoload :Storage,              'neo/sdk/simulation/storage'

      include VM::Helper

      attr_reader :script, :return_type, :state

      def initialize(script, return_type = nil)
        @script = script
        @return_type = return_type || :Void
        @context = Context.new
        @state = State.new

        if vm_execution?
          @context.instance_variable_set :@__script_hash__, script_hash
        else
          @context.instance_eval script
        end
      end

      # Not sure how to handle getting the script_hash from
      # the global scope in a way I like yet. However, I don't
      # think we'll have this problem once the compiler is working,
      # making @__script_hash__ a temporary hack.
      def invoke(*parameters)
        Storage.instance_variable_set :@__script_hash__, script_hash

        result = @context.main(*parameters)
        @state.logs = Runtime.logs.dup
        @state.storage = Storage.storage.dup
        Simulation.reset
        cast_return result
      end

      # TODO: What if it's a ByteArray, etc.
      def cast_return(result)
        case return_type
        when :Boolean then unwrap_boolean result
        when :Integer then unwrap_integer result
        when :String  then unwrap_string  result
        when :Void    then nil
        # :nocov:
        else raise NotImplementedError, "#{result.inspect} (#{return_type})"
        end
        # :nocov:
      end

      def script_hash
        vm_execution? ? script.hash : Digest::RMD160.hexdigest(script)
      end

      def vm_execution?
        script.is_a? Script
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

      State = Struct.new :logs, :storage do
        def initialize(logs: [], storage: {})
          super logs, storage
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
          Runtime.logs.clear
          Storage.storage.clear
        end
      end
    end
  end
end
