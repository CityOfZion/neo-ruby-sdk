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
                  :tree

      def initialize(source)
        @tree = Parser::CurrentRuby.parse source
        @proc = Processor.new @tree
      end
    end
  end
end
