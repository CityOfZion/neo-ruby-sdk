# frozen_string_literal: true

require 'logger'
require 'parser/current'

module Neo
  module SDK
    # Compile ruby source code into neo Bytecode
    class Compiler
      autoload :Handlers,  'neo/sdk/compiler/handlers'
      autoload :Processor, 'neo/sdk/compiler/processor'

      attr_reader :root,
                  :tree,
                  :return_type,
                  :param_types,
                  :logger,
                  :builder

      def initialize(source, logger = nil)
        @tree    = Parser::CurrentRuby.parse source
        @builder = Builder.new
        @logger  = logger || default_logger
        @root    = Processor.new @tree, self, @logger

        magic        = source.scan(/^# ([[:alnum:]\-_]+): (.*)/).to_h
        @return_type = magic['return'].to_sym
        @param_types = magic['params'] ? magic['params'].split(', ').map(&:to_sym) : []

        link_method_calls
        resolve_jump_targets
      end

      def link_method_calls
        builder.operations.each do |op|
          next unless op.name == :CALL
          method_name = op.data
          target = op.scope.find_definition(method_name)
          logger.error "No method: #{method_name}"
          op.data = target
        end
      end

      def resolve_jump_targets
        builder.operations.each do |operation|
          target = operation.data
          next unless target.is_a? Operation
          jump_target = target.address - operation.address
          operation.data = ByteArray.from_int16(jump_target)
        end
      end

      def bytes
        ByteArray.new builder.operations.flat_map(&:bytes)
      end

      def length
        @entry_point.length
      end

      def find_local(*)
        nil
      end

      # :nocov:
      def default_logger
        logger = Logger.new STDOUT
        colors = { 'WARN' => 31, 'INFO' => 32, 'DEBUG' => 33 }
        logger.formatter = proc do |severity, _datetime, _progname, msg|
          "#{"\e[#{colors[severity]}m#{severity}\e[0m".ljust(9)} #{msg}\n"
        end
        logger
      end
      # :nocov:

      class << self
        def load(path, logger = nil)
          File.open(path, 'r') do |file|
            source = file.read
            compiler = Compiler.new source, logger
            Script.new compiler.bytes, source, compiler.return_type, compiler.param_types
          end
        end
      end
    end
  end
end
