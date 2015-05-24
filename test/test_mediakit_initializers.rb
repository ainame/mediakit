require 'minitest_helper'
require 'mediakit'

class TestMediakitInitializers < Minitest::Test
  def setup
  end

  def test_initializer
    ffmpeg = Mediakit::FFmpeg.new(Mediakit::Drivers::FFmpeg.new)
    Mediakit::Initializers::FFmpeg::CodecInitializer.new(ffmpeg).call
    Mediakit::Initializers::FFmpeg::FormatInitializer.new(ffmpeg).call
    Mediakit::Initializers::FFmpeg::DecoderInitializer.new(ffmpeg).call
    Mediakit::Initializers::FFmpeg::EncoderInitializer.new(ffmpeg).call

    assert(ffmpeg.codecs.kind_of?(Array))
    assert(ffmpeg.formats.kind_of?(Array))
    assert(ffmpeg.encoders.kind_of?(Array))
    assert(ffmpeg.decoders.kind_of?(Array))
  end
end
