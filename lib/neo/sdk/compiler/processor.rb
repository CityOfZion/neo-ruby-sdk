# frozen_string_literal: true

module Neo
  module SDK
    class Compiler
      # Process an AST and convert it to bytecode
      class Processor < Parser::AST::Processor
        include Handlers

        attr_reader :logger,
                    :parent,
                    :last_node,
                    :builder,
                    :definitions,
                    :operations

        def initialize(nodes, parent = nil, logger = nil)
          @parent      = parent
          @logger      = logger
          @locals      = []
          @builder     = Builder.new
          @definitions = {}

          process_all Array(nodes)
        end

        def entry_point
          builder = Builder.new
          builder.emit_push depth
          builder.emit :NEWARRAY
          builder.emit :TOALTSTACK
          builder.operations
        end

        def flatten
          @operations = entry_point
          builder.operations.each { |op| @operations << op }
          definitions.values.each(&:flatten)
          definitions.each_value do |definition|
            definition.operations.each do |op|
              if op.name == :CALL
                target = definitions[op.data].operations.first
                op.data = target
              end
              @operations << op
            end
          end
        end

        def depth
          @locals.size + definitions.values.sum(&:depth)
        end

        def process(node)
          @last_node = node
          return unless node.is_a? Parser::AST::Node
          handler = "on_#{node.type}".to_sym
          defined = Handlers.instance_methods.include? handler
          logger.warn "missing handler: #{handler}" unless defined
          super
        end

        def emit(name, param = nil)
          @builder.emit name, param
        end

        def emit_push(data)
          @builder.emit_push data
        end

        def emit_method(name)
          if OPERATORS.key? name
            emit OPERATORS[name]
          else
            emit :CALL, name
          end
        end
      end
    end
  end
end
