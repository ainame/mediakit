require 'mediakit/drivers'
require 'mediakit/ffmpeg/options'
require 'mediakit/ffmpeg/introspection'

module Mediakit
  class FFmpeg
    include Introspection
    class FFmpegError < StandardError; end


    def initialize(driver)
      @driver = driver
    end

    # execute runners with options object
    #
    # @param [Mediakit::Runners::FFmpeg::Options] options options to create CLI argument
    def run(options, driver_options = {})
      args = options.compose
      @driver.run(args, driver_options)
    end

    def command(options, driver_options = {})
      args = options.compose
      @driver.command(args, driver_options)
    end
  end
end
