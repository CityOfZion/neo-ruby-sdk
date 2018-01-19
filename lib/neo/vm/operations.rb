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
        define_method "PUSHBYTES#{n}" do
          evaluation_stack.push current_context.script.read_bytes(n)
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

      def JMP
        offset = current_context.script.read_bytes(2).to_uint16
        offset = current_context.instruction_pointer + offset - 3
        fault! unless offset.between? 0, current_context.script.length
        result = block_given? ? yield : true
        current_context.instruction_pointer = offset if result
      end

      def JMPIF
        JMP do
          result = unwrap_boolean evaluation_stack.pop
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

      def APPCALL
        script_hash = current_context.script.read_bytes(20).to_hex_string
        invocation_stack.pop if __callee__ == :TAILCALL
        script = VM::Interop::Blockchain.scripts[script_hash]
        load_script script
      end

      alias TAILCALL APPCALL

      def SYSCALL
        n = current_context.script.read_byte
        invoke current_context.script.read_bytes(n).to_string
      end

      # Stack

      def DUPFROMALTSTACK
        evaluation_stack.push alt_stack.peek
      end

      def TOALTSTACK
        alt_stack.push evaluation_stack.pop
      end

      def FROMALTSTACK
        evaluation_stack.push alt_stack.pop
      end

      # def XDROP
      # end

      def XSWAP
        n = unwrap_integer evaluation_stack.pop
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
        n = unwrap_integer evaluation_stack.pop
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

      def AND
        b = unwrap_integer evaluation_stack.pop
        a = unwrap_integer evaluation_stack.pop
        evaluation_stack.push a & b
      end

      def OR
        b = unwrap_integer evaluation_stack.pop
        a = unwrap_integer evaluation_stack.pop
        evaluation_stack.push a | b
      end

      def XOR
        b = unwrap_integer evaluation_stack.pop
        a = unwrap_integer evaluation_stack.pop
        evaluation_stack.push a ^ b
      end

      # def EQUAL
      # end

      # Arithmetic

      # NOTE: Ruby does not support ++, and the neon compiler doesn't output this opcode either.
      def INC
        a = unwrap_integer evaluation_stack.pop
        evaluation_stack.push a + 1
      end

      # NOTE: Ruby does not support --, and the neon compiler doesn't output this opcode either.
      def DEC
        a = unwrap_integer evaluation_stack.pop
        evaluation_stack.push a - 1
      end

      # def SIGN
      # end

      def NEGATE
        a = unwrap_integer evaluation_stack.pop
        evaluation_stack.push(-a)
      end

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

      def SHL
        n = unwrap_integer evaluation_stack.pop
        x = unwrap_integer evaluation_stack.pop
        evaluation_stack.push x << n
      end

      def SHR
        n = unwrap_integer evaluation_stack.pop
        x = unwrap_integer evaluation_stack.pop
        evaluation_stack.push x >> n
      end

      def BOOLAND
        b = unwrap_boolean evaluation_stack.pop
        a = unwrap_boolean evaluation_stack.pop
        evaluation_stack.push a && b
      end

      def BOOLOR
        b = unwrap_boolean evaluation_stack.pop
        a = unwrap_boolean evaluation_stack.pop
        evaluation_stack.push a || b
      end

      def NUMEQUAL
        b = unwrap_integer evaluation_stack.pop
        a = unwrap_integer evaluation_stack.pop
        evaluation_stack.push a == b
      end

      # def NUMNOTEQUAL
      # end

      def LT
        b = unwrap_integer evaluation_stack.pop
        a = unwrap_integer evaluation_stack.pop
        evaluation_stack.push a < b
      end

      def GT
        b = unwrap_integer evaluation_stack.pop
        a = unwrap_integer evaluation_stack.pop
        evaluation_stack.push a > b
      end

      def LTE
        b = unwrap_integer evaluation_stack.pop
        a = unwrap_integer evaluation_stack.pop
        evaluation_stack.push a <= b
      end

      def GTE
        b = unwrap_integer evaluation_stack.pop
        a = unwrap_integer evaluation_stack.pop
        evaluation_stack.push a >= b
      end

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
        index = unwrap_integer evaluation_stack.pop
        items = evaluation_stack.pop
        evaluation_stack.push items[index]
      end

      def SETITEM
        item = evaluation_stack.pop
        index = unwrap_integer evaluation_stack.pop
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
