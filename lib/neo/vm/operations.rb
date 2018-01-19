# frozen_string_literal: true

module Neo
  module VM
    # Implementations of specific VM operations
    # rubocop:disable Naming/MethodName, Metrics/ModuleLength
    module Operations
      (0x0..0xF).each do |n|
        define_method "PUSH#{n}" do
          evaluation_stack.push n
        end
      end

      (0x01..0x4B).each do |length|
        define_method "PUSHBYTES#{length}" do
          evaluation_stack.push current_context.script.read_bytes(length)
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
        length = current_context.script.read_byte
        invoke current_context.script.read_bytes(length).to_string
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
        index = unwrap_integer evaluation_stack.pop
        fault! if index.negative?
        return if index.zero?
        item = evaluation_stack.peek index
        evaluation_stack.set index, evaluation_stack.peek
        evaluation_stack.set 0, item
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
        index = unwrap_integer evaluation_stack.pop
        fault! if index.negative?
        evaluation_stack.push evaluation_stack.remove(index) unless index.zero?
      end

      # def ROT
      # end

      # def SWAP
      # end

      # def TUCK
      # end

      # Splice

      def CAT
        rhs = evaluation_stack.pop
        lhs = evaluation_stack.pop
        evaluation_stack.push(lhs + rhs)
      end

      # def SUBSTR
      # end

      # def LEFT
      # end

      # def RIGHT
      # end

      # def SIZE
      # end

      # Bitwise logic

      def INVERT
        operand = unwrap_integer evaluation_stack.pop
        evaluation_stack.push ~operand
      end

      def AND
        rhs = unwrap_integer evaluation_stack.pop
        lhs = unwrap_integer evaluation_stack.pop
        evaluation_stack.push lhs & rhs
      end

      def OR
        rhs = unwrap_integer evaluation_stack.pop
        lhs = unwrap_integer evaluation_stack.pop
        evaluation_stack.push lhs | rhs
      end

      def XOR
        rhs = unwrap_integer evaluation_stack.pop
        lhs = unwrap_integer evaluation_stack.pop
        evaluation_stack.push lhs ^ rhs
      end

      def EQUAL
        rhs = unwrap_integer evaluation_stack.pop
        lhs = unwrap_integer evaluation_stack.pop
        evaluation_stack.push lhs.eql? rhs
      end

      # Arithmetic

      # NOTE: Ruby does not support ++, and the neon compiler doesn't output this opcode either.
      def INC
        operand = unwrap_integer evaluation_stack.pop
        evaluation_stack.push operand + 1
      end

      # NOTE: Ruby does not support --, and the neon compiler doesn't output this opcode either.
      def DEC
        operand = unwrap_integer evaluation_stack.pop
        evaluation_stack.push operand - 1
      end

      # def SIGN
      # end

      def NEGATE
        operand = unwrap_integer evaluation_stack.pop
        evaluation_stack.push(-operand)
      end

      # def ABS
      # end

      # def NOT
      # end

      # def NZ
      # end

      def ADD
        rhs = unwrap_integer evaluation_stack.pop
        lhs = unwrap_integer evaluation_stack.pop
        evaluation_stack.push lhs + rhs
      end

      def SUB
        rhs = unwrap_integer evaluation_stack.pop
        lhs = unwrap_integer evaluation_stack.pop
        evaluation_stack.push lhs - rhs
      end

      def MUL
        rhs = unwrap_integer evaluation_stack.pop
        lhs = unwrap_integer evaluation_stack.pop
        evaluation_stack.push lhs * rhs
      end

      def DIV
        rhs = unwrap_integer evaluation_stack.pop
        lhs = unwrap_integer evaluation_stack.pop
        evaluation_stack.push lhs / rhs
      end

      def MOD
        rhs = unwrap_integer evaluation_stack.pop
        lhs = unwrap_integer evaluation_stack.pop
        evaluation_stack.push lhs % rhs
      end

      def SHL
        rhs = unwrap_integer evaluation_stack.pop
        lhs = unwrap_integer evaluation_stack.pop
        evaluation_stack.push lhs << rhs
      end

      def SHR
        rhs = unwrap_integer evaluation_stack.pop
        lhs = unwrap_integer evaluation_stack.pop
        evaluation_stack.push lhs >> rhs
      end

      def BOOLAND
        rhs = unwrap_boolean evaluation_stack.pop
        lhs = unwrap_boolean evaluation_stack.pop
        evaluation_stack.push lhs && rhs
      end

      def BOOLOR
        rhs = unwrap_boolean evaluation_stack.pop
        lhs = unwrap_boolean evaluation_stack.pop
        evaluation_stack.push lhs || rhs
      end

      def NUMEQUAL
        rhs = unwrap_integer evaluation_stack.pop
        lhs = unwrap_integer evaluation_stack.pop
        evaluation_stack.push lhs == rhs
      end

      # def NUMNOTEQUAL
      # end

      def LT
        rhs = unwrap_integer evaluation_stack.pop
        lhs = unwrap_integer evaluation_stack.pop
        evaluation_stack.push lhs < rhs
      end

      def GT
        rhs = unwrap_integer evaluation_stack.pop
        lhs = unwrap_integer evaluation_stack.pop
        evaluation_stack.push lhs > rhs
      end

      def LTE
        rhs = unwrap_integer evaluation_stack.pop
        lhs = unwrap_integer evaluation_stack.pop
        evaluation_stack.push lhs <= rhs
      end

      def GTE
        rhs = unwrap_integer evaluation_stack.pop
        lhs = unwrap_integer evaluation_stack.pop
        evaluation_stack.push lhs >= rhs
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
        length = unwrap_integer evaluation_stack.pop
        evaluation_stack.push Array.new(length)
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
