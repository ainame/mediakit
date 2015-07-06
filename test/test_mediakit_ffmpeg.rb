require 'minitest_helper'

class TestMediakitFfmpeg < Minitest::Test
  def setup
    @fake_driver = Mediakit::Drivers::FFmpeg.new(:fake)
    @ffmpeg = Mediakit::FFmpeg.new(@fake_driver)
  end

  def teardown
    @fake_driver.reset
  end

  def test_run_with_options
    @fake_driver.output = 'dummy output'
    options = Mediakit::FFmpeg::Options.new(Mediakit::FFmpeg::Options::GlobalOption.new('version' => true))

    @ffmpeg.run(options, nice: 10)
    assert_equal(@fake_driver.last_command, "nice -n 10 sh -c \"ffmpeg -version\"")
    assert_equal(@fake_driver.nice, 10)
    assert_equal(@fake_driver.timeout, nil)

    @fake_driver.reset
    @ffmpeg.run(options, timeout: 30)
    assert_equal(@fake_driver.nice, nil)
    assert_equal(@fake_driver.timeout, 30)

    @fake_driver.reset
    @ffmpeg.run(options)
    assert_nil(@fake_driver.nice)
    assert_nil(@fake_driver.timeout)
  end

  def test_codecs
    ffmpeg = Mediakit::FFmpeg.new(Mediakit::Drivers::FFmpeg.new)
    ffmpeg.init
    assert { Mediakit::FFmpeg::Codecs === Mediakit::FFmpeg::Codecs::Audio::CODEC_MP3 }
    assert { Mediakit::FFmpeg::Codecs::Audio === Mediakit::FFmpeg::Codecs::Audio::CODEC_MP3 }
    assert { Mediakit::FFmpeg::Codecs::Video === Mediakit::FFmpeg::Codecs::Video::CODEC_MPEG4 }
    assert { !(Mediakit::FFmpeg::Codecs::Video === Mediakit::FFmpeg::Codecs::Audio::CODEC_MP3) }
    assert { !(Mediakit::FFmpeg::Codecs::Subtitle === Mediakit::FFmpeg::Codecs::Audio::CODEC_MP3) }
    assert { !(Mediakit::FFmpeg::Encoders === Mediakit::FFmpeg::Codecs::Audio::CODEC_MP3) }
  end
end
