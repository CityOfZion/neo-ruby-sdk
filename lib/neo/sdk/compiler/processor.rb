# frozen_string_literal: true

module Neo
  module SDK
    class Compiler
      # Process an AST and convert it to bytecode
      class Processor < Parser::AST::Processor
        include Handlers

        attr_reader :definitions,
                    :logger,
                    :parent

        def initialize(nodes, parent = nil, logger = nil)
          @parent      = parent
          @logger      = logger
          @definitions = {}
          @locals      = []
          @builder     = Builder.new

          process_all Array(nodes)
          link_definitions
        end

        def bytes
          @bytes = @builder.bytes
          @definitions.values.each do |definition|
            @bytes += definition.bytes
          end
          @bytes
        end

        def depth
          @locals.size + @definitions.values.sum(&:depth)
        end

        def link_definitions
          @definitions.each do |name, body|
            # TODO: This.
          end
        end

        def process(node)
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
      end
    end
  end
end
