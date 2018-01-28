# frozen_string_literal: true

require 'test_helper'

class Neo::SDK::CompilerTest < Minitest::Test
  include TestHelper
  
  AUTO_CONTRACTS = [
    'add',
    'arithmetic',
    'bit_invert',
    # 'bitwise',
    'boolean_and',
    'boolean_or',
    # 'decrement',
    'divide',
    'greater_than_equal',
    'greater_than',
    'less_than_equal',
    'less_than',
    # 'logical_not',
    'modulo',
    'multiply',
    'negate',
    'return_42',
    'return_false',
    'return_true',
    'shift_left',
    'shift_right',
    'subtract'
  ]

  AUTO_CONTRACTS.each do |name|
    define_method "test_#{name}" do
      compile_and_invoke name
    end
  end

  def test_it_finds_return_type
    script = Neo::SDK::Compiler.load 'test/fixtures/source/return_42.rb', Logger.new(IO::NULL)
    assert_equal :Integer, script.return_type
  end

  def test_it_compiles_return_42
    script = Neo::SDK::Compiler.load 'test/fixtures/source/return_42.rb', Logger.new(IO::NULL)
    sim = Neo::SDK::Simulation.new script
    assert_equal 42, sim.invoke
  end
end
