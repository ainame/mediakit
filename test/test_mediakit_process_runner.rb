require 'minitest_helper'
require 'timeout'
require 'stringio'

class TestMediakitProcessRunner < Minitest::Test
  def setup
    @bin = File.join(TestContext.root, 'test/supports/ffmpeg')
    STDOUT.sync = true
    STDERR.sync = true
  end

  def teardown
    @timeout = nil
    @logger = nil
  end

  def runner
    options = {}
    options[:timeout] = @timeout if @timeout
    options[:logger] = @logger || Logger.new(nil)
    Mediakit::Process::Runner.new(options)
  end

  def test_without_timeout_error
    begin
      # no timeout error
      runner.run(@bin, '--sleep=0.1')
      # no timeout error wtih output
      runner.run(@bin, '--sleep=0.1 --progress')
    rescue Timeout::Error => e
      error = e
    ensure
      assert_nil(error)
    end
  end

  def test_timeout_error
    @timeout = 0.5
    # error with read timeout
    assert_raises(Timeout::Error) do
      runner.run(@bin, '--sleep=0.4')
    end

    # no timeout error wtih output
    begin
      runner.run(@bin, '--sleep=0.2 --progress')
    rescue Timeout::Error => e
      error = e
    ensure
      assert_nil(error)
    end

    error = nil
    begin
      runner.run(@bin, '--sleep=0.4 --progress')
    rescue Timeout::Error => e
      error = e
    ensure
      assert_nil(error)
    end
  end

  def test_return_values
    @timeout = 0.5
    out, err, status = runner.run(@bin, '--sleep=0.1 --progress')
    assert(out)
    assert(out.kind_of?(String))
    assert(err.kind_of?(String))
    assert(status)
  end

  def test_escape
    assert_equal("a\\;b", Mediakit::Process::ShellEscape.escape("a;b"))
  end

  def test_logger
    io = StringIO.new
    @logger = Logger.new(io)
    @logger.level = Logger::DEBUG
    out, err, _ = runner.run(@bin, '--sleep=0.1 --progress')
    assert_equal(runner.logger, @logger)
    # assert_equal(out, io.string)
    # assert_equal(err, err)
  end
end
