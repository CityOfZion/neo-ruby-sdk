# frozen_string_literal: true

module Neo
  module SDK
    class Compiler
      # Handle ruby featurs, emit Neo bytecode
      module Handlers
        OPERATORS = {
          :+   => :ADD,
          :-   => :SUB,
          :*   => :MUL,
          :/   => :DIV,
          :%   => :MOD,
          :~   => :INVERT,
          :&   => :AND,
          :|   => :OR,
          :"^" => :XOR,
          :>   => :GT,
          :>=  => :GTE,
          :<   => :LT,
          :<=  => :LTE,
          :<<  => :SHL,
          :>>  => :SHR,
          :-@  => :NEGATE
        }.freeze

        def on_begin(node)
          process_all node.children
        end

        def on_def(node)
          name, args_node, body_node = *node
          method = Processor.new([args_node, body_node], logger)
          method.emit :RET
          @definitions[name] = method
          logger.info "Method `#{name}` defined."
        end

        def on_args(node)
          super
          # TODO: I think this is where I need to handle optional/default args
        end

        def on_arg(node)
          super
          name = node.children.first
          @locals << name
        end

        def on_lvar(node)
          super
          name = node.children.first
          case @locals.index name
          when 1
            emit :SWAP
          end
        end

        # TODO: Implement NUMEQUAL if operands are both numeric
        def on_send(node)
          super
          _receiver, name, *_args = *node
          if OPERATORS.key? name
            emit OPERATORS[name]
          else
            emit :CALL, name
          end
        end

        def on_int(node)
          value = node.children.first
          emit_push value
        end

        def on_false(*)
          emit_push false
        end

        def on_true(*)
          emit_push true
        end

        def on_or(*)
          emit :BOOLOR
        end

        def on_and(*)
          emit :BOOLAND
        end
      end
    end
  end
end
