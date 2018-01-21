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
    contract = load_and_invoke 'hello_world'
    stored_value = contract.state.storage[contract.script_hash]['Hello']
    assert_equal 'World', stored_value.to_string
  end

  def test_fibonacci
    load_and_invoke 'fibonacci', 7
  end

  def test_runtime_log
    vm_sim = load_and_invoke 'runtime_log'
    assert vm_sim.state.logs.include? 'Hello, World.'
  end

  def test_storage_get
    contract = load_contract 'storage_get', :String
    # TODO: Stub this?
    context = Neo::SDK::Simulation::StorageContext.new contract.script_hash
    Neo::SDK::Simulation::Storage.put context, 'Fizz', 'Buzz'
    result = contract.invoke
    assert_equal 'Buzz', result
  end
end
