require 'minitest_helper'
require 'mediakit'

class TestMediakitInitializers < Minitest::Test
  def setup
  end

  def test_initializer
    ffmpeg = Mediakit::FFmpeg.new(Mediakit::Drivers::FFmpeg.new)
    ffmpeg.init

    assert(ffmpeg.codecs.kind_of?(Array))
    assert(ffmpeg.codecs.size > 0)
    assert(ffmpeg.formats.kind_of?(Array))
    assert(ffmpeg.formats.size > 0)
    assert(ffmpeg.encoders.kind_of?(Array))
    assert(ffmpeg.encoders.size > 0)
    assert(ffmpeg.decoders.kind_of?(Array))
    assert(ffmpeg.decoders.size > 0)

    codec = ffmpeg.codecs[0]
    assert { Mediakit::FFmpeg::Codec === codec  }
    assert_raises(NoMethodError) do
      codec.new
    end
  end
end
