require 'minitest_helper'

class TestMediakitUtilsProcessRunner < Minitest::Test
  def setup
    @bin = File.join(TestContext.root, 'test/supports/ffmpeg')
    @runner = Mediakit::Utils::ProcessRunner.new(timeout: 0.3)
    STDOUT.sync = true
    STDERR.sync = true
  end

  def teardown
    @runner = nil
  end

  def test_timeout_error
    # error with read timeout
    assert_raises(Timeout::Error) do
      @runner.run(@bin, '--sleep=0.5')
    end

    # no timeout error wtih output
    @runner.run(@bin, '--sleep=0.5 --progress')
  end

  def test_return_values
    out, err, status = @runner.run(@bin, '--sleep=0.1 --progress')
    assert(out)
    assert(out.kind_of?(String))
    assert(err.kind_of?(String))
    assert(status)
  end

  def test_escape
    assert_equal("a\\;b", Mediakit::Utils::ShellEscape.escape("a;b"))
  end
end
