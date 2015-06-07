require 'mediakit/drivers'
require 'mediakit/ffmpeg/options'
require 'mediakit/utils/constant_class_definer'

module Mediakit
  class FFmpeg
    class FFmpegError < StandardError; end

    attr_accessor(:codecs, :formats, :decoders, :encoders)

    def self.create(driver = Mediakit::Drivers::FFmpeg.new)
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

    module Codecs
      class Base
        include Utils::ConstantClassDefiner

        def self.using_attributes
          [:name, :desc, :type, :decode, :encode, :decoders, :encoders, :intra_frame, :lossy, :lossless]
        end
      end

      module Audio
        class Base < Codecs::Base
        end
      end

      module Video
        class Base < Codecs::Base
        end
      end

      module Subtitle
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
      class Base
        include Utils::ConstantClassDefiner

        def self.using_attributes
          [:name, :desc, :type, :frame_level, :slice_level, :experimental, :horizon_band, :direct_rendering_method]
        end
      end

      module Audio
        class Base < Encoders::Base
        end
      end

      module Video
        class Base < Encoders::Base
        end
      end

      module Subtitle
        class Base < Encoders::Base
        end
      end
    end

    module Decoders
      class Base
        include Utils::ConstantClassDefiner

        def self.using_attributes
          [:name, :desc, :type, :frame_level, :slice_level, :experimental, :horizon_band, :direct_rendering_method]
        end
      end

      module Audio
        class Base < Decoders::Base
        end
      end

      module Video
        class Base < Decoders::Base
        end
      end

      module Subtitle
        class Base < Decoders::Base
        end
      end
    end
  end
end
