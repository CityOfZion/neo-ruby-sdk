# frozen_string_literal: true

module Neo
  module VM
    # Interop service & state reader
    class Interop
      attr_reader :engine

      def initialize(engine)
        @engine = engine
        @logs = []
      end

      # TODO: Print logs at end of run (but not during tests by default)?
      def neo_runtime_log
        message = engine.evaluation_stack.pop.to_string
        @logs << message
        true
      end

      def neo_storage_get_context
        storage_context = SDK::Simulation::StorageContext.new engine.current_context.script.hash
        engine.evaluation_stack.push storage_context
        true
      end

      def neo_storage_get
        context = engine.evaluation_stack.pop
        contract = SDK::Simulation::Blockchain.get_contract context.script_hash
        return false unless contract.storage?
        key = engine.evaluation_stack.pop
        item = SDK::Simulation::Blockchain.get_storage_item context.script_hash, key
        engine.evaluation_stack.push item || 0
        true
      end

      def neo_storage_put
        context = engine.evaluation_stack.pop
        key = engine.evaluation_stack.pop.to_string
        return false if key.length > 1024
        value = engine.evaluation_stack.pop
        SDK::Simulation::Blockchain.put_storage_item context.script_hash, key, value
        true
      end
    end
  end
end
