# frozen_string_literal: true

module Neo
  module SDK
    class Compiler
      # Process an AST and convert it to bytecode
      class Processor < Parser::AST::Processor
        include Handlers

        attr_reader :definitions,
                    :locations,
                    :logger,
                    :parent,
                    :last_node,
                    :builder

        def initialize(nodes, parent = nil, logger = nil)
          @parent      = parent
          @logger      = logger
          @definitions = {}
          @locations   = {}
          @locals      = []
          @builder     = Builder.new

          process_all Array(nodes)
        end

        def bytes
          @bytes = builder.bytes
          definitions.each_value do |definition|
            @bytes += definition.bytes
          end
          @bytes
        end

        def link_definitions
          instruction_pointer = parent.length + length
          definitions.each do |name, definition|
            locations[name] = instruction_pointer
            instruction_pointer += definition.length
          end
          definitions.each_value do |definition|
            definition.operations.each do |operation|
              if operation.name == :CALL && operation.data.is_a?(Symbol)
                location = locations[operation.data]
                operation.data = ByteArray.from_int16 location
              end
            end
            definition.link_definitions
          end
        end

        def depth
          @locals.size + definitions.values.sum(&:depth)
        end

        def operations
          builder.operations
        end

        def length
          builder.length
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
