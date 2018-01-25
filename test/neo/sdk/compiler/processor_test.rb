# frozen_string_literal: true

require 'test_helper'

class Neo::SDK::Compiler::ProcessorTest < Minitest::Test

  def test_it_processes_2_plus_2
    ast = Parser::CurrentRuby.parse <<~SRC
      def main
        2 + 2
      end
    SRC
    bytes = Neo::ByteArray.new([0x52, 0x52, 0x93])
    processor = Neo::SDK::Compiler::Processor.new(ast)
    assert_equal bytes, processor.bytes
  end
end
