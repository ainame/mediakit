require 'mediakit/command/ffmpeg/options'
require 'mediakit/drivers'

module Mediakit
  module Command
    class FFmpeg
      class FFmpegError < StandardError; end

      DELIMITER_FOR_CODECS = "\n -------\n".freeze
      DELIMITER_FOR_FORMATS = "\n --\n".freeze
      DELIMITER_FOR_CODER = "\n ------\n".freeze

      def initialize(driver)
        @driver = driver
      end

      # execute command with options object
      #
      # @param options [Mediakit::Command::FFmpeg::Options] options object to create CLI argument
      def run(options)
        args = options.compose
        execute(args)
      end

      def codecs
        @codecs ||= execute('-codecs').split(DELIMITER_FOR_CODECS)[1].each_line.to_a
      end

      def formats
        @formats ||= execute('-formats').split(DELIMITER_FOR_FORMATS)[1].each_line.to_a
      end

      def decoders
        @decoders ||= execute('-decoders').split(DELIMITER_FOR_CODER)[1].each_line.to_a
      end

      def encoders
        @encoders ||= execute('-encoders').split(DELIMITER_FOR_CODER)[1].each_line.to_a
      end

      private

      def execute(args = '')
        begin
          @driver.run(args)
        rescue Drivers::DriverError => e
          raise(FFmpegError, "#catch driver's error - {e.message}, #{e.backtrace.join("\n")}")
        end
      end
    end
  end
end