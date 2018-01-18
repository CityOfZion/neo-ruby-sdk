# frozen_string_literal: true

module Neo
  module VM
    # Implementations of specific VM operations
    module Operations
      (0..16).each do |n|
        define_method "push#{n}" do
          evaluation_stack.push n
        end
      end

      (0x01..0x4B).each do |n|
        define_method "pushbytes#{n}" do |bytes|
          evaluation_stack.push bytes
        end
      end

      def pushf
        evaluation_stack.push 0
      end

      def pusht
        evaluation_stack.push 1
      end

      # def pushdata1
      # end

      # def pushdata2
      # end

      # def pushdata4
      # end

      def pushm1
        evaluation_stack.push(-1)
      end

      # Flow control

      def nop; end

      def jmp(bytes)
        offset = current_context.instruction_pointer + bytes.to_uint16 - 3
        fault! unless offset.between? 0, current_context.script.operations.length
        result = block_given? ? yield : true
        current_context.instruction_pointer = offset if result
      end

      def jmpif(bytes)
        jmp(bytes) do
          # TODO: cast to boolean, wrap in stack item class?
          result = evaluation_stack.pop
          result = !result if __callee__ == :jpmifnot
          result
        end
      end

      alias jpmifnot jmpif

      # def call
      # end

      def ret
        invocation_stack.pop
        halt! if invocation_stack.empty?
      end

      def appcall(bytes)
        script_hash = bytes.to_hex_string
        invocation_stack.pop if __callee__ == :tailcall
        script = VM::Interop::Blockchain.scripts[script_hash]
        load_script script
      end

      alias tailcall appcall

      def syscall(bytes)
        invoke bytes.to_string
      end

      # Stack

      # def dupfromaltstack
      # end

      def toaltstack
        alt_stack.push evaluation_stack.pop
      end

      def fromaltstack
        evaluation_stack.push alt_stack.pop
      end

      # def xdrop
      # end

      def xswap
        n = evaluation_stack.pop.to_int
        fault! if n.negative?
        return if n.zero?
        item = evaluation_stack.peek(n)
        evaluation_stack.set(n, evaluation_stack.peek)
        evaluation_stack.set(0, item)
      end

      # def xtuck
      # end

      # def depth
      # end

      def drop
        evaluation_stack.pop
      end

      def dup
        evaluation_stack.push evaluation_stack.peek
      end

      # def nip
      # end

      # def over
      # end

      # def pick
      # end

      def roll
        n = evaluation_stack.pop
        fault! if n.negative?
        evaluation_stack.push evaluation_stack.remove(n) unless n.zero?
      end

      # def rot
      # end

      # def swap
      # end

      # def tuck
      # end

      # Splice

      # def cat
      # end

      # def substr
      # end

      # def left
      # end

      # def right
      # end

      # def size
      # end

      # Bitwise logic
      # def invert
      # end

      # def and
      # end

      # def or
      # end

      # def xor
      # end

      # def equal
      # end

      # Arithmetic
      # def inc
      # end

      # def dec
      # end

      # def sign
      # end

      # def negate
      # end

      # def abs
      # end

      # def not
      # end

      # def nz
      # end

      def add
        a = evaluation_stack.pop
        b = evaluation_stack.pop
        evaluation_stack.push a + b
      end

      # def sub
      # end

      # def mul
      # end

      # def div
      # end

      # def mod
      # end

      # def shl
      # end

      # def shr
      # end

      # def booland
      # end

      # def boolor
      # end

      # def numequal
      # end

      # def numnotequal
      # end

      # def lt
      # end

      # def gt
      # end

      # def lte
      # end

      # def gte
      # end

      # def min
      # end

      # def max
      # end

      # def within
      # end

      # Crypto

      # def sha1
      # end

      # def sha256
      # end

      # def hash160
      # end

      # def hash256
      # end

      # def checksig
      # end

      # def checkmultisig
      # end

      # Array
      # def arraysize
      # end

      # def pack
      # end

      # def unpack
      # end

      def pickitem
        index = evaluation_stack.pop
        items = evaluation_stack.pop
        evaluation_stack.push items[index]
      end

      def setitem
        # TODO: Doesn't push value back?
        item = evaluation_stack.pop
        index = evaluation_stack.pop
        items = evaluation_stack.pop
        items[index] = item
      end

      def newarray
        size = evaluation_stack.pop.to_i
        evaluation_stack.push Array.new(size)
      end

      # def newstruct
      # end

      # def append
      # end

      # def reverse
      # end

      # Exceptions

      # def throw
      # end

      # def throwifnot
      # end
    end
  end
end
