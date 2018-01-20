# frozen_string_literal: true

module Neo
  module SDK
    class Simulation
      # A class meant for mocking stubbing in your tests.
      class Blockchain
        @contracts = {}
        @storages = {}
        @scripts = {}

        class << self
          attr_reader :storages, :scripts, :contracts

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
    end
  end
end
