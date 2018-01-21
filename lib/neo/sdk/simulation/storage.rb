# frozen_string_literal: true

module Neo
  module SDK
    class Simulation
      # A module meant for mocking and stubbing in your tests
      module Storage
        @storage = {}

        class << self
          attr_reader :storage

          # See Simulation#initalize
          def current_context
            StorageContext.new @__script_hash__
          end

          def put(context, key, value)
            store = @storage[context.script_hash] ||= {}
            store[VM::Helper.unwrap_string(key)] = value
          end

          def get(context, key)
            store = @storage[context.script_hash] ||= {}
            store[VM::Helper.unwrap_string(key)]
          end

          # def delete(context, key)
          # end
        end
      end
    end
  end
end
