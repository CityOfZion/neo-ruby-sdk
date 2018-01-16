# frozen_string_literal: true

module Neo
  module VM
    # Interop service & state reader
    class Interop
      attr_reader :engine

      def initialize(engine)
        @engine = engine
      end

      def neo_storage_get_context
        storage_context = StorageContext.new engine.current_context.script.hash
        engine.evaluation_stack.push storage_context
        true
      end

      def neo_storage_get
        context = engine.evaluation_stack.pop
        contract = Blockchain.get_contract context.script_hash
        return false if contract.nil?
        return false unless contract.has_storage?
        key = engine.evaluation_stack.pop
        item = Blockchain.get_storage_item context.script_hash, key
        engine.evaluation_stack.push item || 0
        true
      end

      def neo_storage_put
        context = engine.evaluation_stack.pop
        key = engine.evaluation_stack.pop
        return false if key.length > 1024
        value = engine.evaluation_stack.pop
        Blockchain.put_storage_item context.script_hash, key, value
        true
      end

      # TODO: Temporary class for stubbing
      class StorageContext
        attr_reader :script_hash

        def initialize(script_hash)
          @script_hash = script_hash
        end

        def to_s
          "<SC #{@script_hash.slice(0, 8)}>"
        end
      end

      # TODO: Temporary class for stubbing
      class Blockchain
        @contracts = {}
        @storages = {}

        class << self
          attr_reader :storages

          def get_contract(script_hash)
            @contracts[script_hash] || Contract.new
          end

          def get_storage_item(script_hash, key)
            storage = @storages[script_hash] ||= {}
            storage[key]
          end

          def put_storage_item(script_hash, key, value)
            storage = @storages[script_hash] ||= {}
            storage[key] = value
          end
        end
      end

      # TODO: Temporary class for stubbing
      class Contract
        def has_storage?
          true
        end
      end
    end
  end
end
