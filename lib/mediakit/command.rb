require 'cocaine'

module Mediakit
  module Command
    class CommandError < StandardError; end

    require 'mediakit/drivers'
    require 'mediakit/command/ffmpeg'
    require 'mediakit/command/ffmpeg/argument_builder'
    require 'mediakit/command/ffprobe'
    require 'mediakit/command/sox'
  end
end