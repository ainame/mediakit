module Mediakit
  class Transcoder
    module VideoFilter
      require 'mediakit/transoder/video_filter/split'
      require 'mediakit/transoder/video_filter/crop'
      require 'mediakit/transoder/video_filter/rotate'
      require 'mediakit/transoder/video_filter/resize'
      require 'mediakit/transoder/video_filter/padding'
      require 'mediakit/transoder/video_filter/custom'
    end
  end
end