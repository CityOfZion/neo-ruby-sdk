# frozen_string_literal: true

module Neo
  module SDK
    class Simulation
      # A class meant for mocking and stubbing in your tests.
      class Blockchain
        class << self
          # Get an account based on the scripthash of the contract
          def get_account; end

          # Get asset based on asset ID
          def get_asset(address); end

          # Find block by block Height or block Hash
          def get_block(block_hash_or_id); end

          # New Get contract content based on contract hash
          def get_contract(script_hash); end

          # Find block header by block height or block hash
          def get_header(block_hash_or_id); end

          # Get the current block height
          def get_height; end

          # Find transaction via transaction ID
          def get_transaction(txid); end

          # Get the public key of the consensus node
          def get_validators; end
        end
      end
    end
  end
end
