module Mediakit
  module Railtie < ::Rails::Railtie
    initializer('mediakit.initialize_ffmpeg') do
      ffmpeg = Mediakit::FFmpeg.create
      Mediakit::Initializers.setup(ffmpeg)
    end
  end
end
