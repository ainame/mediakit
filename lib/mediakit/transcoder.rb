require 'mediakit/command'

module Mediakit
  class Transcoder
    attr_reader(:ffmpeg, :options, :inputs, :output_path)

    def initialize(ffmpeg:, options:)
      @ffmpeg, @options = @ffmpeg, options
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
      ffmpeg.run(args)
      Mediakit::Medium.new(@output_path)
    end

    private
    def args
      builder = Command::FFmpeg::ArgumentBuilder.new
      builder.inputs(inputs.map(&:path))
      builder.options(build_filters)
      builder.output(output_path)
      builder.build
    end

    # TODO ちゃんと実装
    def build_filters
      filters.map(&:to_s).join
    end
  end
end