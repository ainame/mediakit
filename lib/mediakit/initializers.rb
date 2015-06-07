module Mediakit
  module Initializers
    require 'mediakit/initializers/ffmpeg'

    def setup(ffmpeg)
      Mediakit::Initializers::FFmpeg::FormatInitializer.new(ffmpeg).call
      Mediakit::Initializers::FFmpeg::DecoderInitializer.new(ffmpeg).call
      Mediakit::Initializers::FFmpeg::EncoderInitializer.new(ffmpeg).call
      Mediakit::Initializers::FFmpeg::CodecInitializer.new(ffmpeg).call
    end

    module_function(:setup)
  end
end
