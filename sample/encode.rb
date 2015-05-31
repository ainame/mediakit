#!/usr/bin/env ruby

require "bundler/setup"
require "mediakit"
require 'pry'

input_file = ARGV[0]
exit(1) unless input_file

output_file = ARGV[1] || 'out.mov'

def transcode_option(input, output)
  options = Mediakit::FFmpeg::Options.new(
    Mediakit::FFmpeg::Options::GlobalOption.new(
      'y' => true,
      'threads' => 4,
      't' => 10
    ),
    Mediakit::FFmpeg::Options::InputFileOption.new(
      options: nil,
      path:    input,
    ),
    Mediakit::FFmpeg::Options::OutputFileOption.new(
      options: {
        'acodec' => 'mp3',
        'vcodec' => 'libx264',
        #'vf' => 'crop=240:240:0:0',
        'ar' => '44100',
        'ab' => '128k',
      },
      path:    output,
    ),
  )
end

root        = File.expand_path(File.join(File.dirname(__FILE__), '../'))
input_path  = File.expand_path(input_file)
output_path = File.expand_path(File.join(root, 'out.mov'))
ffmpeg      = Mediakit::FFmpeg.create
options     = transcode_option(input_path, output_path)
puts "$ #{ffmpeg.command(options, nice: 10)}"
puts ffmpeg.run(options, nice: 10, timeout: 30)
