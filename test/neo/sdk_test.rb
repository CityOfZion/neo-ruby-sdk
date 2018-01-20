# frozen_string_literal: true

require 'test_helper'

class Neo::SDKTest < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::Neo::SDK::VERSION
  end

  def test_it_can_dump_a_script
    contract = load_contract 'hello_world'
    refute Neo::SDK::Script::Dump.new(contract.script)
      .operation_details
      .map { |line| line.join(' ') }
      .empty?
  end
end
