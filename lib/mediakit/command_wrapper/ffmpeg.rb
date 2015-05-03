module Mediakit
  module CommandWrapper
    class FFmpeg
      class << self
        FFMPEG_COMMAND = 'ffmpeg'.freeze

        def execute(args = '')
          Cocaine::CommandLine.new(FFMPEG_COMMAND, args).run
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
end