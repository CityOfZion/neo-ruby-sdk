# frozen_string_literal: true

module Neo
  module SDK
    class Simulation
      # A class meant for mocking and stubbing in your tests
      class Account
        class << self
          # Get the balance of this asset in the account given the asset ID
          def get_balance(asset_id); end

          # Get the script hash of the contract account
          def get_script_hash; end

          # Get information of the votes that this account has casted
          def get_votes; end

          # Set the voting information of this account
          def set_votes; end
        end
      end
    end
  end
end
