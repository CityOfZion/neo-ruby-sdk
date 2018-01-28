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

        @root = Processor.new @tree, nil, logger || default_logger
        
        magic = source.scan(/^# ([[:alnum:]\-_]+): (.*)/).to_h
        @return_type = magic['return'].to_sym
        @param_types = magic['params'] ? magic['params'].split(', ').map(&:to_sym) : []
      end

      def bytes
        builder = Builder.new
        builder.emit_push @root.depth
        builder.emit :NEWARRAY
        builder.emit :TOALTSTACK
        
        builder.bytes + @root.bytes
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
