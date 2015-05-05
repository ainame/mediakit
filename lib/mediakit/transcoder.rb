require 'mediakit/command'
require 'mediakit/command/ffmpeg/argument_builder'

module Mediakit
  class Transcoder
    attr_reader(:command, :options, :inputs, :output_path)

    def initialize(command:, options:)
      @command = command
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
      command.execute(args)
      Mediakit::Medium.new(@output_path)
    end

    def args
      builder = Command::FFmpeg::ArgumentBuilder.new
      builder.inputs(inputs.map(&:path))
      builder.options(options)
      builder.output(output_path)
      builder.build
    end
  end
end