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
    def run(options)
      args = options.compose
      execute(args)
    end

    def command(options)
      args = options.compose
      @driver.command(args)
    end

    private

    def execute(args = '')
      @driver.run(args)
    end
  end
end
