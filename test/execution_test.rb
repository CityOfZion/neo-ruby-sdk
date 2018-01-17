# frozen_string_literal: true

require 'test_helper'

class Neo::SDK::ExecutionTest < Minitest::Test
  def test_returns_two
    result = load_and_invoke 'return_two', :Integer
    assert_equal 2, result
  end

  def test_returns_true
    result = load_and_invoke 'return_true', :Boolean
    assert_equal true, result
  end

  def test_hello_world
    contract = load_contract 'hello_world'
    contract.invoke
    hash = contract.script_hash
    # TODO: This API Sucks.
    stored_value = Neo::VM::Interop::Blockchain.storages[hash]['Hello']
    assert_equal 'World', stored_value.to_string
  end

  def test_add
    result = load_and_invoke 'add', :Integer, 2, 2
    assert_equal 4, result
  end

  protected

  def load_and_invoke(name, return_type = nil, *parameters)
    contract = load_contract name, return_type
    contract.invoke(*parameters)
  end

  def load_contract(name, return_type = nil)
    Neo::SDK::Contract.load "test/fixtures/binary/#{name}.avm", return_type
  end

  def teardown
    Neo::VM::Interop::Blockchain.storages.clear
  end
end
