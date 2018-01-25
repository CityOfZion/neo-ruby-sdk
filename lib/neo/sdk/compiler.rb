# frozen_string_literal: true

require 'logger'
require 'parser/current'

module Neo
  module SDK
    # Compile ruby source code into neo Bytecode
    class Compiler
      autoload :Handlers,  'neo/sdk/compiler/handlers'
      autoload :Processor, 'neo/sdk/compiler/processor'

      def initialize(source)
        @ast = Parser::CurrentRuby.parse(source)
        @int = Processor.new(@ast)
      end
    end
  end
end
