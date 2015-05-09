#!/usr/bin/env ruby

require "bundler/setup"
require "mediakit"
require 'pry'

def transcode_option(input, output)
  options = Mediakit::Runners::FFmpeg::Options.new(
    global: Mediakit::Runners::FFmpeg::Options::GlobalOption.new(
      't' => 100,
      'y' => true,
    ),
    inputs: Mediakit::Runners::FFmpeg::Options::InputFileOptionCollection.new(
      Mediakit::Runners::FFmpeg::Options::InputPair.new(
        options: nil,
        path:    input,
      )
    ),
    output: Mediakit::Runners::FFmpeg::Options::OutputFileOption.new(
      options: {
        'vf' => 'crop=320:320:0:0',
        'ar' => '44100',
        'ab' => '128k',
      },
      path:    output,
    ),
  )
end

root        = File.expand_path(File.join(File.dirname(__FILE__), '../'))
input_path  = File.expand_path(File.join(root, 'test/fixtures/sample1.mp4'))
output_path = File.expand_path(File.join(root, 'out.mp4'))
driver      = Mediakit::Drivers::FFmpeg.new
ffmpeg      = Mediakit::Runners::FFmpeg.new(driver)
options     = transcode_option(input_path, output_path)
puts "$ ffmpeg #{options}"
puts ffmpeg.run(options)
