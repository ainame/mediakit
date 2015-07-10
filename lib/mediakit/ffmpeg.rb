require 'mediakit/drivers'
require 'mediakit/ffmpeg/options'
require 'mediakit/utils/constant_factory'

module Mediakit
  class FFmpeg
    class FFmpegError < StandardError;
    end

    class << self
      attr_accessor(:default_global_option)
    end
    self.default_global_option = Options::GlobalOption.new('y' => true)

    attr_reader(:codecs, :formats, :decoders, :encoders)

    def self.create(driver = Mediakit::Drivers::FFmpeg.new)
      @ffmpeg ||= new(driver)
    end

    def initialize(driver)
      @driver                                 = driver
      @codecs, @formats, @decoders, @encoders = [], [], [], []
    end

    def init
      Mediakit::Initializers::FFmpeg.setup(self)
    end

    # execute runners with options object
    #
    # @param [Mediakit::Runners::FFmpeg::Options] options options to create CLI argument
    def run(options, driver_options = {})
      args = options.compose(self.class.default_global_option)
      @driver.run(args, driver_options)
    end

    def command(options, driver_options = {})
      args = options.compose(self.class.default_global_option)
      @driver.command(args, driver_options)
    end

    module BaseTypeMatcher
      def self.included(included_class)
        define_method(:===) do |other|
          return true if included_class::Base >= other
          false
        end

        included_class.send(:module_function, :===)
      end
    end

    class Format
      def self.using_attributes
        [:name, :desc, :demuxing, :muxing]
      end

      include Utils::ConstantFactory
    end

    class Codec
      def self.using_attributes
        [:name, :desc, :type, :decode, :encode, :decoders, :encoders, :intra_frame, :lossy, :lossless]
      end

      include Utils::ConstantFactory
    end

    class AudioCodec < Codec
    end

    class VideoCodec < Codec
    end

    class SubtitleCodec < Codec
    end

    class Encoder
      def self.using_attributes
        [:name, :desc, :type, :frame_level, :slice_level, :experimental, :horizon_band, :direct_rendering_method]
      end

      include Utils::ConstantFactory
    end

    class AudioEncoder < Encoder
    end

    class VideoEncoder < Encoder
    end

    class SubtitleEncoder < Encoder
    end

    class Decoder
      def self.using_attributes
        [:name, :desc, :type, :frame_level, :slice_level, :experimental, :horizon_band, :direct_rendering_method]
      end

      include Utils::ConstantFactory
    end

    class AudioDecoder < Decoder
    end

    class VideoDecoder < Decoder
    end

    class SubtitleDecoder < Decoder
    end
  end
end
