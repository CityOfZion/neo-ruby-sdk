# frozen_string_literal: true

module Neo
  module VM
    # An execution context
    class Context
      attr_reader :script, :push_only
      attr_accessor :instruction_pointer

      def initialize(script, push_only: false)
        @script = script
        @push_only = push_only
        @instruction_pointer = -1
      end

      def next_instruction
        @instruction_pointer += 1
        if instruction_pointer >= script.length
          SDK::Script::Operation.new :RET
        else
          script.operations[instruction_pointer]
        end
      end
    end
  end
end
