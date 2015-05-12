require 'minitest_helper'

class TestMediakitUtilsProcessRunner < Minitest::Test
  def setup
    @bin = File.join(TestContext.root, 'test/supports/ffmpeg')
    STDOUT.sync = true
    STDERR.sync = true
  end

  def test_timeout_error
    # error with read timeout
    assert_raises(Timeout::Error) do
      runner = Mediakit::Utils::ProcessRunner.new(timeout: 0.3)
      runner.run(@bin, '--sleep=0.5')
    end

    # no timeout error wtih output
    runner = Mediakit::Utils::ProcessRunner.new(timeout: 0.3)
    runner.run(@bin, '--sleep=0.5 --progress')
  end

  def test_return_values
    runner = Mediakit::Utils::ProcessRunner.new(timeout: 0.3)
    out, err, status = runner.run(@bin, '--sleep=0.1 --progress')
    assert(out)
    assert(out.kind_of?(String))
    assert(err.kind_of?(String))
    assert(status == true)
  end

  def test_aaaaaaaaaaaaaaaaaaaa
    system(@bin +  ' --sleep=1.0 --progress')
  end

  def test_escape
    assert_equal("a\\;b", Mediakit::Utils::ProcessRunner.escape("a;b"))
  end
end
