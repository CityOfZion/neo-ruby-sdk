# frozen_string_literal: true

module Neo
  module SDK
    # Simulated execution environment for contracts to run in.
    class Simulation
      def initialize(source)
        instance_eval source
      end

      def invoke(*parameters)
        main(*parameters)
      end
    end
  end
end
