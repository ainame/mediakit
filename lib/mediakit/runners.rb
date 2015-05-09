require 'cocaine'

module Mediakit
  module Runners
    class CommandError < StandardError; end

    require 'mediakit/drivers'
    require 'mediakit/runners/ffmpeg'
    require 'mediakit/runners/ffprobe'
    require 'mediakit/runners/sox'
  end
end