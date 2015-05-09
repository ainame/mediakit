require 'mediakit/command/ffmpeg/options'

module Mediakit
  module Command
    class FFmpeg
      DELIMITER_FOR_CODECS = "\n -------\n".freeze
      DELIMITER_FOR_FORMATS = "\n --\n".freeze
      DELIMITER_FOR_CODER = "\n ------\n".freeze

      def initialize(driver)
        @driver = driver
      end

      def execute(args = '')
        @driver.run(args)
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
    end
  end
end