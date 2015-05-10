require 'mediakit'

root = File.expand_path(File.join(File.dirname(__FILE__), '../'))
Mediakit::Drivers::FFmpeg.configure do |config|
  config.bin_path = File.join(root, 'test/supports/ffmpeg')
end

driver = Mediakit::Drivers::FFmpeg.new
puts driver.run('-version')
