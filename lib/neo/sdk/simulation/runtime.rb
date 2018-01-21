# frozen_string_literal: true

module Neo
  module SDK
    class Simulation
      # A module meant for mocking and stubbing in your tests
      module Runtime
        @logs = []

        class << self
          attr_reader :logs

          def log(message)
            @logs << message
          end
        end
      end
    end
  end
end
