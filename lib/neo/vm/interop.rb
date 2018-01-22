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

      def neo_blockchain_get_header
        data = unwrap_byte_array engine.evaluation_stack.pop
        header = nil
        if data.length <= 5
          header = SDK::Simulation::Blockchain.get_header unwrap_integer(data)
        elsif data.length == 32
          header = SDK::Simulation::Blockchain.get_header data
        else return false
        end
        engine.evaluation_stack.push header
        true
      end

      def neo_blockchain_get_height
        engine.evaluation_stack.push SDK::Simulation::Blockchain.get_height
        true
      end

      def neo_header_get_timestamp
        header = engine.evaluation_stack.pop
        return false unless header
        engine.evaluation_stack.push header.timestamp
        true
      end

      def neo_output_get_script_hash
        output = engine.evaluation_stack.pop
        return false if output.nil?
        engine.evaluation_stack.push unwrap_byte_array(output.script_hash)
        true
      end

      def neo_runtime_check_witness
        hash_or_pubkey = unwrap_byte_array engine.evaluation_stack.pop
        result = SDK::Simulation.check_witness engine, hash_or_pubkey
        engine.evaluation_stack.push result
        true
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
        value = engine.evaluation_stack.pop
        key = unwrap_byte_array value
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

      def neo_transaction_get_outputs
        tx = engine.evaluation_stack.pop
        return false unless tx
        engine.evaluation_stack.push tx.outputs
        true
      end

      def neo_transaction_get_references
        tx = engine.evaluation_stack.pop
        return false if tx.nil?
        engine.evaluation_stack.push(tx.inputs.map { |input| tx.references[input] })
      end

      def system_execution_engine_get_calling_script_hash
        engine.evaluation_stack.push engine.calling_context.script_hash
      end

      def system_execution_engine_get_entry_script_hash
        engine.evaluation_stack.push engine.entry_context.script_hash
      end

      def system_execution_engine_get_executing_script_hash
        engine.evaluation_stack.push engine.current_context.script_hash
      end

      def system_execution_engine_get_script_container
        engine.evaluation_stack.push SDK::Simulation::ExecutionEngine.get_script_container
        true
      end
    end
  end
end
