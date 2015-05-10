module Mediakit
  class FFmpeg
    module Introspection
      DELIMITER_FOR_CODECS  = "\n -------\n".freeze
      DELIMITER_FOR_FORMATS = "\n --\n".freeze
      DELIMITER_FOR_CODER   = "\n ------\n".freeze

      def codecs
        @codecs ||= run(global_options('codecs')).split(DELIMITER_FOR_CODECS)[1].each_line.to_a
      end

      def formats
        @formats ||= run(global_options('formats')).split(DELIMITER_FOR_FORMATS)[1].each_line.to_a
      end

      def decoders
        @decoders ||= run(global_options('decoders')).split(DELIMITER_FOR_CODER)[1].each_line.to_a
      end

      def encoders
        @encoders ||= run(global_options('encoders')).split(DELIMITER_FOR_CODER)[1].each_line.to_a
      end

      def global_options(flag)
        Options.new(Options::GlobalOption.new(flag => true))
      end
    end
  end
end
