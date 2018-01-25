# frozen_string_literal: true

module Neo
  module SDK
    class Compiler
      # Handle ruby featurs, emit Neo bytecode
      module Handlers
        def on_begin(node)
          process_all node.children
        end

        def on_def(node)
          name, args_node, body_node = *node
          method = SourceProcessor.new([args_node, body_node], logger)
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

        def on_send(node)
          super
          _receiver, name, *_args = *node
          case name
          when :+ then emit :ADD
          when :- then emit :SUB
          when :* then emit :MUL
          when :% then emit :MOD
          when :== then emit :EQUAL
          else
            emit :CALL, name
          end
        end

        def on_int(node)
          value = node.children.first
          emit_push value
        end
      end
    end
  end
end
