require "mediakit/version"

module Mediakit
  require 'mediakit/drivers'
  require 'mediakit/ffmpeg'
  require 'mediakit/ffprobe'
  require 'mediakit/initializers'

  require 'mediakit/railtie' if defined?(Rails)
end
