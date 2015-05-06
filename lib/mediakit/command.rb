require 'cocaine'


module Mediakit
  module Command
    class CommandError < StandardError; end

    require 'mediakit/driver'
    require 'mediakit/command/ffmpeg'
    require 'mediakit/command/ffprobe'
    require 'mediakit/command/sox'
  end
end