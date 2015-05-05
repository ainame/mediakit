require 'minitest_helper'
require 'mediakit/driver'

class TestMediakitDriver < Minitest::Test
  def setup
    @driver = Mediakit::Driver::FFmpeg.new
  end

  def teardown
    Mediakit::Driver::FFmpeg.configure do |conf|
      conf.bin_path = nil
    end
  end

  def test_run
    command = @driver.dry_run('-v')
    assert_equal('ffmpeg -v', command)
  end

  def test_configure
    proc = proc do
      Mediakit::Driver::FFmpeg.configure do |conf|
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

    assert_equal('/usr/bin/ffmpeg', Mediakit::Driver::FFmpeg.bin_path)
  end
end