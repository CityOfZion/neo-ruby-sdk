# frozen_string_literal: true

module Neo
  module SDK
    class Simulation
      # A class meant for mocking and stubbing in your tests
      class Contract
        def storage?
          true
        end

        # Contract parameter and return types
        module Parameter
          TYPES = {
            Signature: 0x00,
            Boolean: 0x01,
            Integer: 0x02,
            Hash160: 0x03,
            Hash256: 0x04,
            ByteArray: 0x05,
            PublicKey: 0x06,
            String: 0x07,
            Array: 0x10,
            InteropInterface: 0xf0,
            Void: 0xff
          }.freeze

          TYPES.each do |name, code|
            const_set name, code
          end

          def self.[](code)
            TYPES.key code
          end
        end
      end
    end
  end
end
