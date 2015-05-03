require 'cocaine'

module Mediakit
  module Runners
    class CommandError < StandardError; end

    require 'mediakit/runners/ffmpeg'
    require 'mediakit/runners/ffprobe'
  end
end
