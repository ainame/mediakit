require 'mediakit/runners/ffmpeg/options'
require 'mediakit/drivers'

module Mediakit
  module Runners
    class FFmpeg
      class FFmpegError < StandardError; end

      DELIMITER_FOR_CODECS = "\n -------\n".freeze
      DELIMITER_FOR_FORMATS = "\n --\n".freeze
      DELIMITER_FOR_CODER = "\n ------\n".freeze

      def initialize(driver)
        @driver = driver
      end

      # execute runners with options object
      #
      # @param options [Mediakit::Runners::FFmpeg::Options] options object to create CLI argument
      def run(options)
        args = options.compose
        execute(args)
      end

      def codecs
        @codecs ||= run(global_options('codecs')).split(DELIMITER_FOR_CODECS)[1].each_line.to_a
      end

      def formats
        @formats ||= run(global_options('formats')).split(DELIMITER_FOR_FORMATS)[1].each_line.to_a
      end

      def decoders
        @decoders ||= run(global_options('decoders')).split(DELIMITER_FOR_CODER)[1].each_line.to_a
      end

      def encoders
        @encoders ||= run(global_options('encoders')).split(DELIMITER_FOR_CODER)[1].each_line.to_a
      end

      private

      def execute(args = '')
        begin
          @driver.run(args)
        rescue Drivers::DriverError => e
          raise(FFmpegError, "#catch driver's error - {e.message}, #{e.backtrace.join("\n")}")
        end
      end

      def global_options(flag)
        Mediakit::Runners::FFmpeg::Options.new(
          global_options: Mediakit::Runners::FFmpeg::Options::GlobalOptions.new(
            flag => true,
          ),
        )
      end
    end
  end
end