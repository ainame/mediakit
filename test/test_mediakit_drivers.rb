require 'minitest_helper'
require 'mediakit/drivers'

class TestMediakitDrivers < Minitest::Test
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
        conf.bin_path = File.join(TestContext.root,'test/supports/ffmpeg')
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

    assert_equal(
      File.join(TestContext.root,'test/supports/ffmpeg'),
      Mediakit::Drivers::FFmpeg.bin_path
    )

    driver = Mediakit::Drivers::FFmpeg.new
    assert(driver.run('-version'))
  end

  def test_create_fake_driver
    fake = Mediakit::Drivers::FFmpeg.new(:fake)
    fake.output = 'this is fake output'
    fake.error_output = 'this is fake error output'
    results = fake.run('--version')

    assert_equal(fake.last_command, 'ffmpeg --version')
    assert_equal(results[0], 'this is fake output')
    assert_equal(results[1], 'this is fake error output')
    assert_equal(results[2], true)
  end
end
