# frozen_string_literal: true

module Neo
  module VM
    # Execution Engine
    class Engine
      include Helper
      include Operations

      attr_reader :interop_service,
                  :evaluation_stack,
                  :alt_stack,
                  :invocation_stack

      def initialize
        @halted = false
        @faulted = false
        @interop_service = Interop.new self
        @evaluation_stack = Stack.new
        @alt_stack = Stack.new
        @invocation_stack = Stack.new
      end

      def current_context
        invocation_stack.peek
      end

      def halted?
        @halted
      end

      def faulted?
        @faulted
      end

      def halt!
        @halted = true
      end

      def fault!
        @faulted = true
      end

      def execute
        perform next_instruction while !halted? && !faulted?
      end

      def load_script(script, push_only: false)
        @invocation_stack.push Context.new(script, push_only: push_only)
      end

      private

      def next_instruction
        current_context.next_instruction
      end

      def perform(instruction)
        current_pointer = current_context.instruction_pointer
        send instruction
        print_state current_pointer, instruction if ENV['DEBUG']
        halt! if invocation_stack.empty?
      end

      # :nocov:
      def print_state(pointer, instruction)
        printf "%02d %d %-40.40s %-40.40s %s\n",
               pointer,
               invocation_stack.size,
               instruction,
               evaluation_stack,
               alt_stack
      end
      # :nocov:

      def invoke(method)
        method.tr! '.', '_'
        method.gsub! 'AntShares', 'Neo'
        method.gsub!(/([a-z])([A-Z])/, '\1_\2')
        method.downcase!
        fault! unless @interop_service.send method
      end
    end
  end
end
