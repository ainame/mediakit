require 'active_support/inflections'

module Mediakit
  class FFmpeg
    module Meta
      class Resolver
        META_TYPES = [:format, :codec, :decoder, :encoder].freeze

        def initialize(ffmpeg)
          @ffmpeg = ffmpeg
        end

        def resolve(type:, name:)
          raise(ArgumentError, "can't accept #{type}") unless META_TYPES.include?(type)
          resolve_class(type, name)
        end

        private

        CLASS_PREFIX = 'Mediakit::FFmpeg::'

        def resolve_class(type, name)
          resolve_const(resolve_class_name(type, name))
        end

        def resolve_const(class_name)
          Mediakit::FFmpeg.const_get(class_name)
        end

        def resolve_class_name(type, name)
          "#{type.classify}#{name.classify}"
        end
      end
    end
  end
end
