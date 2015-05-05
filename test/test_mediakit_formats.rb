require 'minitest_helper'
require 'mediakit/formats'

class TestMediakitFormats < Minitest::Test
  def test_find_foramt
    format_mp4 = Mediakit::Formats.find('mp4')
    assert_equal(Mediakit::Formats::FormatMP4, format_mp4)

    format_3gp = Mediakit::Formats.find('3gp')
    assert_equal(Mediakit::Formats::Format3GP, format_3gp)
  end

  def test_mp4_format
    assert_equal(Mediakit::Formats::FormatMP4.name, 'mp4')
    assert_equal(Mediakit::Formats::FormatMP4.ext, 'mp4')
    assert_includes(Mediakit::Formats::FormatMP4.support_video_codecs, 'h264')
    assert_includes(Mediakit::Formats::FormatMP4.support_audio_codecs, 'aac')
    assert_includes(Mediakit::Formats::FormatMP4.support_audio_codecs, 'mp3')
  end
end