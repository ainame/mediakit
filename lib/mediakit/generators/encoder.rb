require 'mediakit/generators/base'

module Mediakit
  module Generators
    class Encoder < Base
      Item = Struct.new(:name, :desc, :type, :frame_level, :slice_level, :experimental, :horizon_band, :direct_rendering_method) do |klass|
        def to_s
          name
        end
      end

      # Encoders:
      # V..... = Video
      # A..... = Audio
      # S..... = Subtitle
      # .F.... = Frame-level multithreading
      # ..S... = Slice-level multithreading
      # ...X.. = Codec is experimental
      # ....B. = Supports draw_horiz_band
      # .....D = Supports direct rendering method 1
      # ------
      SUPPORT_PATTERN = /(?<support>(?<type>[VAS.])(?<frame_level>[F.])(?<slice_level>[S.])(?<experimental>[X.])(?<horizon_band>[B.])(?<direct_rendering_method>[D.]))/.freeze
      PATTERN = /\A\s*#{SUPPORT_PATTERN}\s+(?<name>\w+)\s+(?<desc>.+)\z/.freeze

      def item_role
        'encoder'
      end

      def get_raw_items
        @command.encoders
      end

      def create_item(line)
        match = line.match(PATTERN)
        if match
          type = case match[:type]
                       when 'V'
                         :video
                       when 'A'
                         :audio
                       when 'S'
                         :subtitle
                       else
                         'unkown'
                       end
          frame_level = match[:frame_level] != '.'
          slice_level = match[:slice_level] != '.'
          experimental = match[:experimental] != '.'
          horizon_band = match[:horizon_band] != '.'
          direct_rendering_method = match[:direct_rendering_method] != '.'

          Item.new(match[:name], match[:desc], type, frame_level, slice_level, experimental, horizon_band, direct_rendering_method)
        end
      end
    end
  end
end
