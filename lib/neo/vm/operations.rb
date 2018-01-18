# frozen_string_literal: true

module Neo
  module VM
    # Implementations of specific VM operations
    # rubocop:disable Naming/MethodName, Metrics/ModuleLength
    module Operations
      (0..16).each do |n|
        define_method "PUSH#{n}" do
          evaluation_stack.push n
        end
      end

      (0x01..0x4B).each do |n|
        define_method "PUSHBYTES#{n}" do |bytes|
          evaluation_stack.push bytes
        end
      end

      def PUSHF
        evaluation_stack.push 0
      end

      def PUSHT
        evaluation_stack.push 1
      end

      # def PUSHDATA1
      # end

      # def PUSHDATA2
      # end

      # def PUSHDATA4
      # end

      def PUSHM1
        evaluation_stack.push(-1)
      end

      # Flow control

      def NOP; end

      def JMP(bytes)
        offset = current_context.instruction_pointer + bytes.to_uint16 - 3
        fault! unless offset.between? 0, current_context.script.operations.length
        result = block_given? ? yield : true
        current_context.instruction_pointer = offset if result
      end

      def JMPIF(bytes)
        JMP bytes do
          # TODO: cast to boolean, wrap in stack item class?
          result = evaluation_stack.pop
          result = !result if __callee__ == :JMPIFNOT
          result
        end
      end

      alias JMPIFNOT JMPIF

      # def CALL
      # end

      def RET
        invocation_stack.pop
        halt! if invocation_stack.empty?
      end

      def APPCALL(bytes)
        script_hash = bytes.to_hex_string
        invocation_stack.pop if __callee__ == :TAILCALL
        script = VM::Interop::Blockchain.scripts[script_hash]
        load_script script
      end

      alias TAILCALL APPCALL

      def SYSCALL(bytes)
        invoke bytes.to_string
      end

      # Stack

      # def DUPFROMALTSTACK
      # end

      def TOALTSTACK
        alt_stack.push evaluation_stack.pop
      end

      def FROMALTSTACK
        evaluation_stack.push alt_stack.pop
      end

      # def XDROP
      # end

      def XSWAP
        n = evaluation_stack.pop.to_int
        fault! if n.negative?
        return if n.zero?
        item = evaluation_stack.peek(n)
        evaluation_stack.set(n, evaluation_stack.peek)
        evaluation_stack.set(0, item)
      end

      # def XTUCK
      # end

      # def DEPTH
      # end

      def DROP
        evaluation_stack.pop
      end

      def DUP
        evaluation_stack.push evaluation_stack.peek
      end

      # def NIP
      # end

      # def OVER
      # end

      # def PICK
      # end

      def ROLL
        n = evaluation_stack.pop
        fault! if n.negative?
        evaluation_stack.push evaluation_stack.remove(n) unless n.zero?
      end

      # def ROT
      # end

      # def SWAP
      # end

      # def TUCK
      # end

      # Splice

      # def CAT
      # end

      # def SUBSTR
      # end

      # def LEFT
      # end

      # def RIGHT
      # end

      # def SIZE
      # end

      # Bitwise logic

      # def INVERT
      # end

      # def AND
      # end

      # def OR
      # end

      # def XOR
      # end

      # def EQUAL
      # end

      # Arithmetic
      # def INC
      # end

      # def DEC
      # end

      # def SIGN
      # end

      # def NEGATE
      # end

      # def ABS
      # end

      # def NOT
      # end

      # def NZ
      # end

      def ADD
        b = unwrap_integer evaluation_stack.pop
        a = unwrap_integer evaluation_stack.pop
        evaluation_stack.push a + b
      end

      def SUB
        b = unwrap_integer evaluation_stack.pop
        a = unwrap_integer evaluation_stack.pop
        evaluation_stack.push a - b
      end

      def MUL
        b = unwrap_integer evaluation_stack.pop
        a = unwrap_integer evaluation_stack.pop
        evaluation_stack.push a * b
      end

      def DIV
        b = unwrap_integer evaluation_stack.pop
        a = unwrap_integer evaluation_stack.pop
        evaluation_stack.push a / b
      end

      def MOD
        b = unwrap_integer evaluation_stack.pop
        a = unwrap_integer evaluation_stack.pop
        evaluation_stack.push a % b
      end

      # def SHL
      # end

      # def SHR
      # end

      # def BOOLAND
      # end

      # def BOOLOR
      # end

      # def NUMEQUAL
      # end

      # def NUMNOTEQUAL
      # end

      # def LT
      # end

      # def GT
      # end

      # def LTE
      # end

      # def GTE
      # end

      # def MIN
      # end

      # def MAX
      # end

      # def WITHIN
      # end

      # Crypto

      # def SHA1
      # end

      # def SHA256
      # end

      # def HASH160
      # end

      # def HASH256
      # end

      # def CHECKSIG
      # end

      # def CHECKMULTISIG
      # end

      # Array

      # def ARRAYSIZE
      # end

      # def PACK
      # end

      # def UNPACK
      # end

      def PICKITEM
        index = evaluation_stack.pop
        items = evaluation_stack.pop
        evaluation_stack.push items[index]
      end

      def SETITEM
        # TODO: Doesn't push value back?
        item = evaluation_stack.pop
        index = evaluation_stack.pop
        items = evaluation_stack.pop
        items[index] = item
      end

      def NEWARRAY
        size = evaluation_stack.pop.to_i
        evaluation_stack.push Array.new(size)
      end

      # def NEWSTRUCT
      # end

      # def APPEND
      # end

      # def REVERSE
      # end

      # Exceptions

      # def THROW
      # end

      # def THROWIFNOT
      # end
    end
    # rubocop:enable Naming/MethodName, Metrics/ModuleLength
  end
end
