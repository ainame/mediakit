#!/usr/bin/env ruby

require "bundler/setup"
require "mediakit"
require 'pry'

ffmpeg = Mediakit::FFmpeg.new(Mediakit::Drivers::FFmpeg.new)
Mediakit::Initializers.setup(ffmpeg)

binding.pry

# ffmpeg.codecs.select {|c| c.name =~ /264/ } ...
