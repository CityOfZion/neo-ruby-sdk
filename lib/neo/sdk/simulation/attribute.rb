# frozen_string_literal: true

module Neo
  module SDK
    class Simulation
      # A class meant for mocking and stubbing in your tests
      class Attribute
        class << self
          # Get extra data outside of the purpose of transaction
          def get_data; end

          # Get purpose of transaction
          def get_usage; end
        end
      end
    end
  end
end
