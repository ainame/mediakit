module Mediakit
  class Transcoder
    module VideoFilter
      require 'mediakit/transcoder/video_filter/split'
      require 'mediakit/transcoder/video_filter/crop'
      require 'mediakit/transcoder/video_filter/rotate'
      require 'mediakit/transcoder/video_filter/resize'
      require 'mediakit/transcoder/video_filter/padding'
      require 'mediakit/transcoder/video_filter/custom'
    end
  end
end