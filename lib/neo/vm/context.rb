# frozen_string_literal: true

module Neo
  module VM
    # An execution context
    class Context
      attr_reader :script, :push_only

      def initialize(script, push_only: false)
        @script = script
        @push_only = push_only
      end

      def instruction_pointer
        @script.position
      end

      def instruction_pointer=(position)
        @script.position = position
      end

      def next_instruction
        script.next_opcode
      end
    end
  end
end
