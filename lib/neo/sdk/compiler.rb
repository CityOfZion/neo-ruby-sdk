# frozen_string_literal: true

require 'logger'
require 'parser/current'

module Neo
  module SDK
    # Compile ruby source code into neo Bytecode
    class Compiler
      autoload :Handlers,  'neo/sdk/compiler/handlers'
      autoload :Processor, 'neo/sdk/compiler/processor'

      attr_reader :proc,
                  :tree,
                  :return_type,
                  :param_types

      def initialize(source)
        @tree = Parser::CurrentRuby.parse source
        @proc = Processor.new @tree

        magic = source.scan(/^# ([[:alnum:]\-_]+): (.*)/).to_h
        @return_type = magic['return'].to_sym
        @param_types = magic['params'] ? magic['params'].split(', ').map(&:to_sym) : []
      end

      def bytes
        @proc.bytes
      end

      class << self
        def load(path)
          File.open(path, 'r') do |file|
            source = file.read
            compiler = Compiler.new source
            Script.new compiler.bytes, source, compiler.return_type, compiler.param_types
          end
        end
      end
    end
  end
end
