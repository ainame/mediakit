require 'minitest_helper'

class TestMediakit < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::Mediakit::VERSION
  end
end
