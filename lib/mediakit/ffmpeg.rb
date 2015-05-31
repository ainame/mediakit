require 'mediakit/drivers'
require 'mediakit/ffmpeg/options'

module Mediakit
  class FFmpeg
    class FFmpegError < StandardError; end

    attr_accessor(:codecs, :formats, :decoders, :encoders)

    def self.create(driver = Medaikit::Drivers::FFmpeg.new)
      @ffmpeg ||= new(driver)
    end

    def initialize(driver)
      @driver = driver
      @codecs, @formats, @decoders, @encoders = [], [], [], []
    end

    # execute runners with options object
    #
    # @param [Mediakit::Runners::FFmpeg::Options] options options to create CLI argument
    def run(options, driver_options = {})
      args = options.compose
      @driver.run(args, driver_options)
    end

    def command(options, driver_options = {})
      args = options.compose
      @driver.command(args, driver_options)
    end

    Codec = Struct.new(:name, :desc, :type, :decode, :encode, :decoders, :encoders, :intra_frame, :lossy, :lossless) do |klass|
      def to_s; name; end
    end

    Format = Struct.new(:name, :desc, :demuxing, :muxing) do |klass|
      def to_s; name; end
    end

    Encoder = Struct.new(:name, :desc, :type, :frame_level, :slice_level, :experimental, :horizon_band, :direct_rendering_method) do |klass|
      def to_s; name; end
    end

    Decoder = Struct.new(:name, :desc, :type, :frame_level, :slice_level, :experimental, :horizon_band, :direct_rendering_method) do |klass|
      def to_s; name; end
    end
  end
end
