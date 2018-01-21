# frozen_string_literal: true

module Neo
  module SDK
    class Simulation
      # A class meant for mocking and stubbing in your tests
      class Contract
        class << self
          #  Publish a smart contract
          def create; end

          #  Destroy a smart contract
          def destroy; end

          # Get the scripthash of the contract
          def get_script; end

          #  Get the storage context of the contract
          def get_storage_context; end

          #  Migrate/Renew a smart contract
          def migrate; end
        end
      end
    end
  end
end
