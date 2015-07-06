require 'mediakit/drivers'
require 'mediakit/ffmpeg/options'
require 'mediakit/utils/constant_class_definer'

module Mediakit
  class FFmpeg
    class FFmpegError < StandardError; end

    attr_reader(:codecs, :formats, :decoders, :encoders)

    def self.create(driver = Mediakit::Drivers::FFmpeg.new)
      @ffmpeg ||= new(driver)
    end

    def initialize(driver)
      @driver = driver
      @codecs, @formats, @decoders, @encoders = [], [], [], []
    end

    def init
      Mediakit::Initializers::FFmpeg::CodecInitializer.new(self).call
      Mediakit::Initializers::FFmpeg::FormatInitializer.new(self).call
      Mediakit::Initializers::FFmpeg::DecoderInitializer.new(self).call
      Mediakit::Initializers::FFmpeg::EncoderInitializer.new(self).call
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

    module BaseTypeMatcher
      def self.included(included_class)
        define_method(:===) do |other|
          return true if included_class::Base >= other
          false
        end

        included_class.send(:module_function, :===)
      end
    end

    module Codecs
      def ===(other)
        return true if Audio::Base >= other || Video::Base >= other || Subtitle::Base >= other
        false
      end
      module_function :===

      class Base
        include Utils::ConstantClassDefiner

        def self.using_attributes
          [:name, :desc, :type, :decode, :encode, :decoders, :encoders, :intra_frame, :lossy, :lossless]
        end
      end

      module Audio
        include(BaseTypeMatcher)

        class Base < Codecs::Base
        end
      end

      module Video
        include(BaseTypeMatcher)

        class Base < Codecs::Base
        end
      end

      module Subtitle
        include(BaseTypeMatcher)

        class Base < Codecs::Base
        end
      end
    end

    module Formats
      class Base
        include Utils::ConstantClassDefiner

        def self.using_attributes
          [:name, :desc, :demuxing, :muxing]
        end
      end
    end

    module Encoders
      def ===(other)
        return true if Audio::Base >= other || Video::Base >= other || Subtitle::Base >= other
        false
      end
      module_function :===

      class Base
        include Utils::ConstantClassDefiner

        def self.using_attributes
          [:name, :desc, :type, :frame_level, :slice_level, :experimental, :horizon_band, :direct_rendering_method]
        end
      end

      module Audio
        include(BaseTypeMatcher)
        class Base < Encoders::Base
        end
      end

      module Video
        include(BaseTypeMatcher)
        class Base < Encoders::Base
        end
      end

      module Subtitle
        include(BaseTypeMatcher)
        class Base < Encoders::Base
        end
      end
    end

    module Decoders
      def ===(other)
        return true if Audio::Base >= other || Video::Base >= other || Subtitle::Base >= other
        false
      end
      module_function :===


      class Base
        include Utils::ConstantClassDefiner

        def self.using_attributes
          [:name, :desc, :type, :frame_level, :slice_level, :experimental, :horizon_band, :direct_rendering_method]
        end
      end

      module Audio
        include(BaseTypeMatcher)
        class Base < Decoders::Base
        end
      end

      module Video
        include(BaseTypeMatcher)
        class Base < Decoders::Base
        end
      end

      module Subtitle
        include(BaseTypeMatcher)
        class Base < Decoders::Base
        end
      end
    end
  end
end
