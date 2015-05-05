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
        @codecs ||= execute('-codecs')
      end

      def formats
        @formats ||= execute('-formats')
      end
    end
  end
end