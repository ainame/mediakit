require 'minitest_helper'
require 'mediakit/command/ffmpeg/argument_builder'

class TestMediakitFFmpegArgumentBuilder < Minitest::Test
  def setup
    dummy_options = {}
    @builder = Mediakit::Command::FFmpeg::ArgumentBuilder.new(dummy_options)
  end

  def test_input_formats
    input_format = @builder
      .input('/tmp/input1.mp4')
      .input('/tmp/input2.mp4')
      .input_format
    assert_equal("-i /tmp/input1.mp4 -i /tmp/input2.mp4", input_format)
  end

  def test_output_formats
    output_format = @builder
                     .output('/tmp/output.mp4')
                     .output_format
    assert_equal("/tmp/output.mp4", output_format)
  end

  def test_options_formats
    options_format = @builder.options('-acodec copy').options_format
    assert_equal('-acodec copy', options_format)
  end

  def test_build
    format = @builder
               .input('/tmp/input1.mp4')
               .input('/tmp/input2.mp4')
               .output('/tmp/output.mp4')
               .options('-acodec copy')
               .build
    assert_equal("-i /tmp/input1.mp4 -i /tmp/input2.mp4 -acodec copy /tmp/output.mp4", format)
  end
end