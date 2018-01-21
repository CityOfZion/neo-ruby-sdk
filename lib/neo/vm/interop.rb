# frozen_string_literal: true

module Neo
  module VM
    # Interop service & state reader
    class Interop
      include Helper
      attr_reader :engine

      def initialize(engine)
        @engine = engine
      end

      def neo_runtime_log
        message = unwrap_string engine.evaluation_stack.pop
        SDK::Simulation::Runtime.log message
        true
      end

      def neo_storage_get_context
        storage_context = SDK::Simulation::Storage.get_context
        engine.evaluation_stack.push storage_context
        true
      end

      def neo_storage_get
        context = engine.evaluation_stack.pop
        contract = SDK::Simulation::Blockchain.get_contract context.script_hash
        return false unless contract.storage?
        key = unwrap_byte_array engine.evaluation_stack.pop
        item = SDK::Simulation::Storage.get context, key
        engine.evaluation_stack.push item || ByteArray.new([0])
        true
      end

      def neo_storage_put
        context = engine.evaluation_stack.pop
        key = unwrap_byte_array engine.evaluation_stack.pop.to_string
        return false if key.length > 1024
        value = unwrap_byte_array engine.evaluation_stack.pop
        SDK::Simulation::Storage.put context, key, value
        true
      end
    end
  end
end
