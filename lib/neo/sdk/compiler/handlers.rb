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
          method = Processor.new([args_node, body_node], self, logger)
          method.emit :RET
          @definitions[name] = method
          logger.info "Method `#{name}` defined."
        end

        # TODO: I think this is where I need to handle optional/default args
        def on_args(node)
          node.children.each.with_index do |arg, position|
            name = arg.children.first
            @locals << name
            emit :FROMALTSTACK
            emit :DUP
            emit :TOALTSTACK
            emit_push position
            emit_push 2
            emit :ROLL
            emit :SETITEM
          end
        end

        def on_lvar(node)
          super
          name = node.children.first
          position = @locals.index name

          emit :FROMALTSTACK
          emit :DUP
          emit :TOALTSTACK
          emit_push position
          emit :PICKITEM
        end

        # TODO: Refactor to remove duplication with on_args
        def on_lvasgn(node)
          super
          name = node.children.first
          @locals << name
          emit :FROMALTSTACK
          emit :DUP
          emit :TOALTSTACK
          emit_push @locals.length
          emit_push 2
          emit :ROLL
          emit :SETITEM
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
          super
          emit :BOOLOR
        end

        def on_and(*)
          super
          emit :BOOLAND
        end
      end
    end
  end
end
