require 'mediakit/generators/base'

module Mediakit
  module Generators
    class Codec < Base
      Item = Struct.new(:name, :desc, :type, :decode, :encode, :decoders, :encoders, :intra_frame, :lossy, :lossless) do |klass|
        def to_s
          name
        end
      end

      SUPPORT_PATTERN = /(?<support>(?<decode>[D.])(?<encode>[E.])(?<type>[VAS.])(?<intra_frame>[I.])(?<lossy>[L.])(?<lossless>[S.]))/.freeze
      DESCRIPTION_PATTERN = /.*?( \(decoders: (?<decoders>.+?) \)| \(encoders: (?<encoders>.+?) \))*/.freeze
      PATTERN = /\A\s*#{SUPPORT_PATTERN}\s+(?<name>\w+)\s+(?<desc>(#{DESCRIPTION_PATTERN}))\z/.freeze

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
          decoders = match[:decoders] ? match[:decoders].split(' ') : [match[:name]]
          encoders = match[:encoders] ? match[:encoders].split(' ') : [match[:name]]
          intra_frame = match[:intra_frame] != '.'
          lossy = match[:lossy] != '.'
          lossless = match[:lossless] != '.'

          Item.new(match[:name], match[:desc], type, decode, encode, decoders, encoders, intra_frame, lossy, lossless)
        end
      end
    end
  end
end
