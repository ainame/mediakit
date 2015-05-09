require 'minitest_helper'
require 'mediakit/drivers'

class TestMediakitDriver < Minitest::Test
  def setup
    @driver = Mediakit::Drivers::FFmpeg.new
  end

  def teardown
    Mediakit::Drivers::FFmpeg.configure do |conf|
      conf.bin_path = nil
    end
  end

  def test_run
    command = @driver.command('-v')
    assert_equal('ffmpeg -v', command)
  end

  def test_configure
    proc = proc do
      Mediakit::Drivers::FFmpeg.configure do |conf|
        conf.bin_path = '/usr/bin/ffmpeg'
      end
    end

    error = nil
    begin
      proc.call
    rescue => e
      error = e
    ensure
      assert_nil(error)
    end

    assert_equal('/usr/bin/ffmpeg', Mediakit::Drivers::FFmpeg.bin_path)
  end
end