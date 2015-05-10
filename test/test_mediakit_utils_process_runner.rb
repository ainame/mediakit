require 'minitest_helper'

class TestMediakitUtilsProcessRunner < Minitest::Test
  def setup
    @bin = File.join(TestContext.root, 'test/supports/ffmpeg')
    @runner = Mediakit::Utils::ProcessRunner.new(timeout: 2)
  end

  def teardown
    @runner = nil
  end

  def test_timeout
    assert_raises(Timeout::Error) do
      @runner.run(@bin, '--sleep=3')
    end

    @runner.run(@bin, '--sleep=3 --progress')
  end

  def test_escape
    assert_equal("a\\;b", Mediakit::Utils::ProcessRunner.escape("a;b"))
  end
end
