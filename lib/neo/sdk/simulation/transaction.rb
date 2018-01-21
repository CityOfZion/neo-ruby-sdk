# frozen_string_literal: true

module Neo
  module SDK
    class Simulation
      # A class meant for mocking and stubbing in your tests
      class Transaction
        class << self
          # Query all properties of the current transaction
          def get_attributes; end

          # Get Hash for the current transaction
          def get_hash; end

          # Query all transactions for current transactions
          def get_inputs; end

          # Query all transaction output for current transaction
          def get_outputs; end

          # Query the transaction output referenced by all inputs of the current transaction
          def get_references; end

          # Get the current transaction type
          def get_type; end
        end
      end
    end
  end
end
