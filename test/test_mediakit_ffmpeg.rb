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

    assert { Mediakit::FFmpeg::Codec === Mediakit::FFmpeg::AudioCodec::CODEC_MP3 }
    assert { Mediakit::FFmpeg::AudioCodec::CODEC_MP3.name == 'mp3' }
    assert { Mediakit::FFmpeg::AudioCodec::CODEC_MP3.desc.match(/MP3 \(MPEG audio layer 3\)/) }
    assert { Mediakit::FFmpeg::AudioCodec === Mediakit::FFmpeg::AudioCodec::CODEC_MP3 }
    assert { Mediakit::FFmpeg::VideoCodec === Mediakit::FFmpeg::VideoCodec::CODEC_MPEG4 }
    assert { !(Mediakit::FFmpeg::VideoCodec === Mediakit::FFmpeg::AudioCodec::CODEC_MP3) }
    assert { !(Mediakit::FFmpeg::SubtitleCodec === Mediakit::FFmpeg::AudioCodec::CODEC_MP3) }
    assert { !(Mediakit::FFmpeg::Encoder === Mediakit::FFmpeg::AudioCodec::CODEC_MP3) }
  end

  def test_default_global_option
    Mediakit::FFmpeg.default_global_option =
      Mediakit::FFmpeg::Options::GlobalOption.new('y' => true)
    @ffmpeg.run(Mediakit::FFmpeg::Options.new(Mediakit::FFmpeg::Options::GlobalOption.new('version' => true)))
    last_command = @fake_driver.last_command
    assert { last_command == 'ffmpeg -y -version' }
  ensure
    Mediakit::FFmpeg.default_global_option =
      Mediakit::FFmpeg::Options::GlobalOption.new
  end
end
