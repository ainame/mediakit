require 'mediakit/generators/base'

module Mediakit
  module Generators
    class Format < Base
      Item = Struct.new(:name, :desc, :demuxing, :muxing) do |klass|
        def to_s
          name
        end
      end

      SUPPORT_PATTERN = /(?<support>(?<demuxing>[D.\s])(?<muxing>[E.\s]))/.freeze
      PATTERN = /\A\s*#{SUPPORT_PATTERN}\s+(?<name>\w+)\s+(?<desc>.+)\z/.freeze

      def item_role
        'format'
      end

      def get_raw_items
        @command.formats
      end

      def create_item(line)
        match = line.match(PATTERN)
        if match
          demuxing = match[:demuxing] == 'D'
          muxing = match[:muxing] == 'E'

          Item.new(match[:name], match[:desc], demuxing, muxing)
        end
      end
    end
  end
end
