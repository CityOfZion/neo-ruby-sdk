# frozen_string_literal: true

module Neo
  module SDK
    class Simulation
      # A class meant for mocking stubbing in your tests.
      class Blockchain
        @contracts = {}
        @scripts = {}

        class << self
          attr_reader :scripts, :contracts

          def get_contract(script_hash)
            @contracts[script_hash] || Contract.new
          end
        end
      end
    end
  end
end
