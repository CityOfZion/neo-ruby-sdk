# frozen_string_literal: true

module Neo
  module SDK
    class Compiler
      # Process an AST and convert it to bytecode
      class Processor < Parser::AST::Processor
        include Handlers

        attr_reader :definitions,
                    :logger,
                    :operations

        def initialize(nodes, logger = nil)
          @logger      = logger || default_logger
          @operations  = []
          @definitions = {}
          @locals      = []

          process_all Array(nodes)
        end

        def bytes
          data = []
          @operations.each do |op|
            data << VM::OpCode.const_get(op.name)
          end
          ByteArray.new(data)
        end

        def default_logger
          logger = Logger.new STDOUT
          colors = { 'WARN' => 31, 'INFO' => 32, 'DEBUG' => 33 }
          logger.formatter = proc do |severity, _datetime, _progname, msg|
            "#{"\e[#{colors[severity]}m#{severity}\e[0m".ljust(9)} #{msg}\n"
          end
          logger
        end

        def process(node)
          if node.is_a? Parser::AST::Node
            handler = "on_#{node.type}".to_sym
            defined = Handlers.instance_methods.include? handler
            logger.warn "missing handler: #{handler}" unless defined
            super
          end
        end

        def emit(name, param = nil)
          @operations << Op.new(name, param)
        end

        def emit_push(value)
          case value
          when 0...16 then emit "PUSH#{value}"
          else raise NotImplementedError, value
          end
        end

        Op = Struct.new(:name, :param) do
          def to_s
            [name, param ? " <#{param}>" : nil].join
          end
        end
      end
    end
  end
end
