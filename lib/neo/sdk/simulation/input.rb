# frozen_string_literal: true

module Neo
  module SDK
    class Simulation
      # A class meant for mocking and stubbing in your tests
      class Input
        class << self
          # Get the hash of the referenced previous transaction
          def get_hash; end

          # The index of the input in the output list of the referenced previous transaction
          def get_index; end
        end
      end
    end
  end
end
