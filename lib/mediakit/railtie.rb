module Mediakit
  class Railtie < ::Rails::Railtie
    initializer('mediakit.initialize_ffmpeg') do
      Mediakit::FFmpeg.create
    end
  end
end
