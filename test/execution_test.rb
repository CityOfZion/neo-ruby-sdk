# frozen_string_literal: true

require 'test_helper'

class Neo::SDK::ExecutionTest < Minitest::Test
  AUTO_CONTRACTS = [
    'add',
    'arithmetic',
    'bitwise',
    'boolean_and',          # TODO: Doesn't actually test BOOLAND
    'boolean_or',           # TODO: Doesn't actually test BOOLOR
    'control_if',
    'decrement',            # TODO: Doesn't actually test DEC
    'divide',
    'greater_than_equal',
    'greater_than',
    'increment',            # TODO: Doesn't actually test INC
    'less_than_equal',
    'less_than',
    'modulo',
    'multiply',
    'negate',
    'numeric_equality',
    'numeric_inequality',
    'return_42',
    'return_true',
    'shift_left',
    'shift_right',
    'subtract'
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

  protected

  def load_and_invoke(name, *parameters)
    source = load_source(name)
    contract = load_contract name, source[:return]

    if parameters.empty?
      source[:params].each.with_index do |type, n|
        parameters << case type
        when :Boolean
          Random.rand >= 0.5
        when :Integer
          Random.rand(0xffff)
        else
          raise NotImplementedError, type
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
