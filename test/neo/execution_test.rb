# frozen_string_literal: true

require 'test_helper'
require 'securerandom'

class Neo::SDK::ExecutionTest < Minitest::Test
  # These contracts are executed with random inputs and test_hello_world
  # against the ruby implementation for correctness.
  AUTO_CONTRACTS = [
    'add',
    'arithmetic',
    'array_operations',
    'bit_invert',
    'bitwise',
    'boolean_and',          # TODO: Doesn't actually test BOOLAND
    'boolean_or',           # TODO: Doesn't actually test BOOLOR
    'control_for',
    'control_if_else_if',
    'control_if_else',
    'control_if',
    'decrement',            # TODO: Doesn't actually test DEC
    'divide',
    'equality',             # TODO: Doesn't actually test EQUAL
    'greater_than_equal',
    'greater_than',
    'increment',            # TODO: Doesn't actually test INC
    'less_than_equal',
    'less_than',
    'logical_not',
    'method_call',
    'modulo',
    'multiply',
    'negate',
    'numeric_equality',
    'numeric_inequality',
    'return_42',
    'return_true',
    'shift_left',
    'shift_right',
    'string_concatenation',
    'string_length',
    'subtract',
    'struct',
    'switch',
    'while'
  ]

  AUTO_CONTRACTS.each do |name|
    define_method("test_#{name}") do
      load_and_invoke name
    end
  end

  def test_hello_world
    context = stub(:script_hash)
    Neo::SDK::Simulation::Storage.stubs(:get_context).returns context
    Neo::SDK::Simulation::Storage.expects(:put).twice.with context, 'Hello', 'World'
    contract = load_and_invoke 'hello_world'
  end

  def test_fibonacci
    load_and_invoke 'fibonacci', 7
  end

  def test_runtime_log
    Neo::SDK::Simulation::Runtime.expects(:log).twice.with('Hello, World.')
    load_and_invoke 'runtime_log'
  end

  def test_storage_get
    Neo::SDK::Simulation::Blockchain.expects(:get_contract).returns stub(storage?: true)
    Neo::SDK::Simulation::Storage.expects(:get_context).returns stub(:script_hash)
    Neo::SDK::Simulation::Storage.expects(:get).returns 'Buzz'

    contract = load_contract 'storage_get', :String
    assert_equal 'Buzz', contract.invoke
  end

  def test_lock
    now = Time.now.to_i
    Neo::SDK::Simulation.stubs(:verify_signature).returns true
    Neo::SDK::Simulation::Blockchain.expects(:get_height).twice.returns 42
    Neo::SDK::Simulation::Blockchain.expects(:get_header).twice.returns stub(timestamp: now + 100)
    load_and_invoke 'lock', now, '1234sig', '1234key'
  end
end
