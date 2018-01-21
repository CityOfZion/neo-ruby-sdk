# frozen_string_literal: true

module Neo
  module SDK
    class Simulation
      # A class meant for mocking and stubbing in your tests
      class Block
        class << self
          # Get the transaction specified in the current block
          def get_transaction; end

          # Get the number of transactions in the current block
          def get_transaction_count; end

          # Get all transactions in the current block
          def get_transactions; end
        end
      end
    end
  end
end
