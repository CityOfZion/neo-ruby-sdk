require 'test_helper'

class Neo::SDKTest < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::Neo::SDK::VERSION
  end
end
