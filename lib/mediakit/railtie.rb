module Mediakit
  class Railtie < ::Rails::Railtie
    initializer('mediakit.initialize_ffmpeg') do
      ffmpeg = Mediakit::FFmpeg.create
      Mediakit::Initializers::FFmpeg.setup(ffmpeg)
    end
  end
end
