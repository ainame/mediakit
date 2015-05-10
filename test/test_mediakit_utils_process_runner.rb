require 'minitest_helper'

class TestMediakitUtilsProcessRunner < Minitest::Test
  def test_escape
    assert_equal("a\\;b", Mediakit::Utils::ProcessRunner.escape("a;b"))
  end
end