# frozen_string_literal: true

module Neo
  module SDK
    class Simulation
      # A class meant for mocking and stubbing in your tests
      class StorageContext
        attr_reader :script_hash

        def initialize(script_hash)
          @script_hash = script_hash
        end

        def to_s
          "<SC #{@script_hash.slice(0, 8)}>"
        end

        alias inspect to_s
      end
    end
  end
end
