require 'mediakit/generators/base'

module Mediakit
  module Generators
    class Codec < Base
      Item = Struct.new(:name, :desc, :type, :decode, :encode, :intra_frame, :lossy, :lossless) do |klass|
        def to_s
          name
        end
      end

      SUPPORT_PATTERN = /(?<support>(?<decode>[D.])(?<encode>[E.])(?<type>[VAS.])(?<intra_frame>[I.])(?<lossy>[L.])(?<lossless>[S.]))/.freeze
      PATTERN = /\A\s*#{SUPPORT_PATTERN}\s+(?<name>\w+)\s+(?<desc>.+)\z/.freeze

      def item_role
        'codec'
      end

      def get_raw_items
        @command.codecs
      end

      def create_item(line)
        match = line.match(PATTERN)
        if match
          type = case match[:type]
                       when "A"
                         :audio
                       when "V"
                         :video
                       when "S"
                         :subtitle
                       else
                         :unknown
                       end
          decode = match[:decode] != '.'
          encode = match[:encode] != '.'
          intra_frame = match[:intra_frame] != '.'
          lossy = match[:lossy] != '.'
          lossless = match[:lossless] != '.'

          Item.new(match[:name], match[:desc], type, decode, encode, intra_frame, lossy, lossless)
        end
      end
    end
  end
end
