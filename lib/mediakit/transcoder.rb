require 'mediakit/command'

module Mediakit
  class Transcoder
    attr_reader :inputs, :output_path, :options

    def initialize(options)
      @options = options
      @inputs = []
      @output_path = nil
    end

    def inputs(media)
      media.each do |medium|
        input(medium)
      end
    end

    def input(medium)
      raise "can't accept other object." unless media.kind_of?(Mediakit::Medium)
      @inputs << medium
      self
    end

    def output(path)
      @output_path = path
      self
    end

    def transcode
      Mediakit::Command::FFmpeg.execute(args)
      Mediakit::Medium.new(@output_path)
    end

    def args

    end
  end
end