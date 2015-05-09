require 'minitest_helper'
require 'mediakit/formats'

class TestMediakitFormats < Minitest::Test
  def test_mp4_format
    assert_equal(Mediakit::Formats::FormatMp4.new.name, 'mp4')
  end
end