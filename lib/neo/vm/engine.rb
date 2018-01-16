# frozen_string_literal: true

module Neo
  module VM
    # Execution Engine
    class Engine
      attr_reader :interop_service,
                  :evaluation_stack,
                  :alt_stack,
                  :invocation_stack

      def initialize(script)
        @halted = false
        @faulted = false
        @instruction_pointer = -1
        @interop_service = Interop.new self
        @evaluation_stack = Stack.new
        @alt_stack = Stack.new
        @invocation_stack = Stack.new
        @invocation_stack.push Context.new(script)
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

      private

      def next_instruction
        @instruction_pointer += 1
        current_context.script.operations[@instruction_pointer]
      end

      def perform(instruction)
        op = instruction.name
        return fault! if instruction.nil?
        case op
        when /PUSH(\d+)/
          evaluation_stack.push Regexp.last_match(1).to_i
        when :PUSHF
          evaluation_stack.push 0
        when :PUSHT
          evaluation_stack.push 1
        when /PUSHBYTES\d+/
          evaluation_stack.push instruction.param
        # when :PUSHDATA1
        # when :PUSHDATA2
        # when :PUSHDATA4
        when :PUSHM1
          evaluation_stack.push(-1)
        # Flow control
        when :NOP
          nil
        when :JMP, :JMPIF, :JMPIFNOT
          offset = @instruction_pointer + instruction.param_to_uint16 - 3
          fault! unless offset.between? 0, current_context.script.operations.length
          result = true
          if op != :JMP
            result = evaluation_stack.pop # TODO: cast to boolean, wrap in stack item class?
            result = !result if op == :JMPIFNOT
          end
          @instruction_pointer = offset if result
        # when :CALL
        when :RET
          invocation_stack.pop
          halt! if invocation_stack.empty?
        # when :APPCALL
        when :SYSCALL
          invoke instruction.param
        # when :TAILCALL

        # Stack
        # when :DUPFROMALTSTACK
        when :TOALTSTACK
          alt_stack.push evaluation_stack.pop
        when :FROMALTSTACK
          evaluation_stack.push alt_stack.pop
        # when :XDROP
        when :XSWAP
          n = evaluation_stack.pop.to_int
          fault! if n.negative?
          unless n.zero?
            item = evaluation_stack.peek(n)
            evaluation_stack.set(n, evaluation_stack.peek)
            evaluation_stack.set(0, item)
          end
        # when :XTUCK
        # when :DEPTH
        when :DROP
          evaluation_stack.pop
        when :DUP
          evaluation_stack.push evaluation_stack.peek
        # when :NIP
        # when :OVER
        # when :PICK
        when :ROLL
          n = evaluation_stack.pop
          fault! if n.negative?
          evaluation_stack.push evaluation_stack.remove(n) unless n.zero?
        # when :ROT
        # when :SWAP
        # when :TUCK

        # Splice
        # when :CAT
        # when :SUBSTR
        # when :LEFT
        # when :RIGHT
        # when :SIZE

        # Bitwise logic
        # when :INVERT
        # when :AND
        # when :OR
        # when :XOR
        # when :EQUAL

        # Arithmetic
        # when :INC
        # when :DEC
        # when :SIGN
        # when :NEGATE
        # when :ABS
        # when :NOT
        # when :NZ
        # when :ADD
        # when :SUB
        # when :MUL
        # when :DIV
        # when :MOD
        # when :SHL
        # when :SHR
        # when :BOOLAND
        # when :BOOLOR
        # when :NUMEQUAL
        # when :NUMNOTEQUAL
        # when :LT
        # when :GT
        # when :LTE
        # when :GTE
        # when :MIN
        # when :MAX
        # when :WITHIN

        # Crypto
        # when :SHA1
        # when :SHA256
        # when :HASH160
        # when :HASH256
        # when :CHECKSIG
        # when :CHECKMULTISIG

        # Array
        # when :ARRAYSIZE
        # when :PACK
        # when :UNPACK
        when :PICKITEM
          index = evaluation_stack.pop
          items = evaluation_stack.pop
          evaluation_stack.push items[index]
        when :SETITEM
          # TODO: Doesn't push value back?
          item = evaluation_stack.pop
          index = evaluation_stack.pop
          items = evaluation_stack.pop
          items[index] = item
        when :NEWARRAY
          size = evaluation_stack.pop.to_i
          evaluation_stack.push Array.new(size)
          # when :NEWSTRUCT
          # when :APPEND
          # when :REVERSE

          # Exceptions
          # when :THROW
          # when :THROWIFNOT
        end
        printf "%-40s %-40s %s\n", instruction, evaluation_stack, alt_stack if ENV['DEBUG']
      end

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
