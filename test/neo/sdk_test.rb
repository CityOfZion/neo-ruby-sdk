# frozen_string_literal: true

require 'test_helper'

class Neo::SDKTest < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::Neo::SDK::VERSION
  end

  def test_it_can_dump_a_script
    Dir["test/fixtures/binary/*.avm"].each do |avm|
      contract = Neo::SDK::Simulation.load avm, :Voice
      refute Neo::SDK::Script::Dump.new(contract.script)
      .operation_details
      .map { |line| line.join(' ') }
      .empty?
    end
  end

  def test_storage_context_inspection
    sc = Neo::SDK::Simulation::StorageContext.new('34ac69af')
    assert_equal '<SC 34ac69af>', sc.inspect
  end
end
