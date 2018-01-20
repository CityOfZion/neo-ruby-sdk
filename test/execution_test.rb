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
    'switch',
    'while'
  ]

  AUTO_CONTRACTS.each do |name|
    define_method("test_#{name}") do
      load_and_invoke name
    end
  end

  def test_hello_world
    contract = load_contract 'hello_world', :Void
    contract.invoke
    hash = contract.script_hash
    # TODO: This API Sucks.
    stored_value = Neo::VM::Interop::Blockchain.storages[hash]['Hello']
    assert_equal 'World', stored_value.to_string
  end

  def test_fibonacci
    load_and_invoke 'fibonacci', 7
  end

  def test_struct
    contract = load_contract 'struct', :Void
    assert_nil contract.invoke
  end

  protected

  def load_and_invoke(name, *parameters)
    source = load_source(name)
    contract = load_contract name, source[:return]

    if parameters.empty?
      source[:params].each.with_index do |type, n|
        parameters << case type
        when :Boolean then Random.rand >= 0.5
        when :Integer then Random.rand(0xffff)
        when :String  then SecureRandom.base64
        else raise NotImplementedError, type
        end
      end
    end

    sumulation = Neo::SDK::Simulation.new source[:source]
    expected = sumulation.invoke(*parameters)
    result = contract.invoke(*parameters)

    assert_equal expected, result, parameters
  end

  def load_contract(name, return_type = nil)
    Neo::SDK::Contract.load "test/fixtures/binary/#{name}.avm", return_type
  end

  def load_source(name)
    source = IO.read("test/fixtures/source/#{name}.rb")
    magic = source.scan(/^# ([[:alnum:]\-_]+): (.*)/).to_h
    meta = { source: source, return: magic["return"].to_sym }
    meta[:params] = magic["params"] ? magic["params"].split(', ').map(&:to_sym) : []
    meta
  end

  def teardown
    Neo::VM::Interop::Blockchain.storages.clear
  end
end
