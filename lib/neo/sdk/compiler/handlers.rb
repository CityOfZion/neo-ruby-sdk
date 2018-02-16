# frozen_string_literal: true

# rubocop:disable Metrics/ModuleLength
module Neo
  module SDK
    class Compiler
      # Handle ruby featurs, emit Neo bytecode
      module Handlers
        OPERATORS = {
          :+      => :ADD,
          :-      => :SUB,
          :*      => :MUL,
          :/      => :DIV,
          :%      => :MOD,
          :~      => :INVERT,
          :&      => :AND,
          :|      => :OR,
          :"^"    => :XOR,
          :"!"    => :NOT,
          :>      => :GT,
          :>=     => :GTE,
          :<      => :LT,
          :<=     => :LTE,
          :<<     => :SHL,
          :>>     => :SHR,
          :-@     => :NEGATE,
          :"eql?" => :EQUAL
        }.freeze

        def on_begin(node)
          node.children.each { |c| process(c) }
        end

        def on_def(node)
          name, args_node, body_node = *node
          method_body = Processor.new nil, self, logger
          method_entry = method_body.emit :NOP
          method_body.emit :NEWARRAY
          method_body.emit :TOALTSTACK
          method_body.process args_node
          method_body.process body_node
          method_body.emit :RET
          raise NotImplementedError if method_body.depth > 16
          method_entry.update name: "PUSH#{method_body.depth}".to_sym
          definitions[name] = method_entry
          logger.info "Method `#{name}` defined."
        end

        def on_return(node)
          super
          emit :RET
        end

        def on_if(node)
          condition_node, then_node, else_node = *node
          process condition_node

          jump_a = emit :JMPIFNOT, nil
          then_clause = Processor.new then_node, self, logger

          if else_node
            jump_b = emit :JMP, nil
            else_clause = Processor.new else_node, self, logger
            jump_a.update data: else_clause.first
            jump_b.update data: else_clause.last
          else
            jump_a.update data: then_clause.last
          end
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
          position = find_local name

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
          emit_push find_local name
          emit_push 2
          emit :ROLL
          emit :SETITEM
        end

        def on_op_asgn(node)
          receiver, name, *args = *node
          position = find_local receiver.children.first
          emit :FROMALTSTACK
          emit :DUP
          emit :TOALTSTACK
          emit_push position
          emit :PICKITEM
          process_all args
          emit OPERATORS[name] if OPERATORS.key? name
          process receiver
          emit :FROMALTSTACK
          emit :DUP
          emit :TOALTSTACK
          emit_push position
          emit :PICKITEM
        end

        def on_send(node)
          super
          receiver, name, *_args = *node

          case name
          when :==
            emit receiver.type == :int ? :NUMEQUAL : :EQUAL
          when :!=
            if receiver.type == :int
              emit :NUMNOTEQUAL
            else
              emit :EQUAL
              emit :NOT
            end
          else
            emit_method name
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
# rubocop:enable Metrics/ModuleLength
