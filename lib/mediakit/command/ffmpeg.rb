require 'mediakit/command/ffmpeg/argument_builder'

module Mediakit
  module Command
    class FFmpeg
      def initialize(driver)
        @driver = driver
      end

      def execute(args = '')
        @driver.run(args)
      end

      def codecs
        @codecs ||= execute('-codecs').split("\n -------\n")[1].each_line.to_a
      end

      def formats
        @formats ||= execute('-formats').split("\n --\n")[1].each_line.to_a
      end

      def decoders
        @decoders ||= execute('-decoders').split("\n ------\n")[1].each_line.to_a
      end

      def encoders
        @encoders ||= execute('-encoders').split("\n ------\n")[1].each_line.to_a
      end
    end
  end
end