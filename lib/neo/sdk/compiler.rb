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
                  :param_types

      def initialize(source, logger = nil)
        @tree = Parser::CurrentRuby.parse source
        @tree = Parser::AST::Node.new(:begin).append @tree unless @tree.type == :begin
        @root = Processor.new @tree, self, logger || default_logger

        magic = source.scan(/^# ([[:alnum:]\-_]+): (.*)/).to_h
        @return_type = magic['return'].to_sym
        @param_types = magic['params'] ? magic['params'].split(', ').map(&:to_sym) : []

        flatten
        link
      end

      def flatten
        @operations = []
        @address = 0
        # TODO: Pull out `main` from root first.
        root.flatten
        root.operations.each do |operation|
          @operations << operation
          operation.address = @address
          @address += operation.length
        end
      end

      def link
        @operations.each do |operation|
          if operation.data.is_a? Builder::Op
            jump_target = operation.data.address - operation.address
            operation.data = ByteArray.from_int16(jump_target)
          end
        end
      end

      def bytes
        ByteArray.new @operations.flat_map(&:bytes)
      end

      def length
        @entry_point.length
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
