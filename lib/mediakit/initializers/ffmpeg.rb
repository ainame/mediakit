require 'active_support/core_ext/string/inflections'

module Mediakit
  module Initializers
    class FFmpeg
      class UnknownTypeError < StandardError
      end

      class Base
        attr_reader :items

        def initialize(command)
          @command = command
        end

        def call
          @command.send(item_type).concat(parse_items)
          @command.send(item_type).freeze
        end

        def item_type
          raise(NotImplementedError)
        end

        def raw_items
          raise(NotImplementedError)
        end

        def create_item(line)
          raise(NotImplementedError)
        end

        def parse_items
          items = []
          raw_items.each do |line|
            chomped_text = line.chomp
            item = create_item(chomped_text)
            items << item if item
          end
          items
        end
      end

      class CodecInitializer < Base
        DELIMITER_FOR_CODECS = "\n -------\n".freeze
        SUPPORT_PATTERN = /(?<support>(?<decode>[D.])(?<encode>[E.])(?<type>[VAS.])(?<intra_frame>[I.])(?<lossy>[L.])(?<lossless>[S.]))/.freeze
        DESCRIPTION_PATTERN = /.*?( \(decoders: (?<decoders>.+?) \)| \(encoders: (?<encoders>.+?) \))*/.freeze
        PATTERN = /\A\s*#{SUPPORT_PATTERN}\s+(?<name>\w+)\s+(?<desc>(#{DESCRIPTION_PATTERN}))\z/.freeze

        def item_type
          'codecs'
        end

        def raw_items
          options = Mediakit::FFmpeg::Options.new(Mediakit::FFmpeg::Options::GlobalOption.new('codecs' => true))
          output, _, _ = @command.run(options, logger: nil)
          return [] if output.nil? || output.empty?
          output.split(DELIMITER_FOR_CODECS)[1].each_line.to_a
        end

        def create_item(line)
          match = line.match(PATTERN)
          if match
            decode = match[:decode] != '.'
            encode = match[:encode] != '.'
            attributes = {
              name: match[:name],
              desc: match[:desc],
              decode: decode,
              encode: encode,
              decoders: match[:decoders] ? match[:decoders].split(' ') : (decode ? [match[:name]] : nil),
              encoders: match[:encoders] ? match[:encoders].split(' ') : (encode ? [match[:name]] : nil),
              intra_frame: match[:intra_frame] != '.',
              lossy: match[:lossy] != '.',
              lossless: match[:lossless] != '.'
            }
            case match[:type]
            when 'V'
              Mediakit::FFmpeg::Codecs::Video::Base.define_subclass(
                "Codec#{attributes[:name].classify}", attributes.merge(type: :video)
              )
            when 'A'
              Mediakit::FFmpeg::Codecs::Audio::Base.define_subclass(
                "Codec#{attributes[:name].classify}", attributes.merge(type: :audio)
              )
            when 'S'
              Mediakit::FFmpeg::Codecs::Subtitle::Base.define_subclass(
                "Codec#{attributes[:name].classify}", attributes.merge(type: :subtitle)
              )
            else
              raise(UnknownTypeError)
            end
          end
        end
      end

      class FormatInitializer < Base
        DELIMITER_FOR_FORMATS = "\n --\n".freeze
        SUPPORT_PATTERN = /(?<support>(?<demuxing>[D.\s])(?<muxing>[E.\s]))/.freeze
        PATTERN = /\A\s*#{SUPPORT_PATTERN}\s+(?<name>\w+)\s+(?<desc>.+)\z/.freeze

        def item_type
          'formats'
        end

        def raw_items
          options = Mediakit::FFmpeg::Options.new(Mediakit::FFmpeg::Options::GlobalOption.new('formats' => true))
          output, _, _ = @command.run(options, logger: nil)
          return [] if output.nil? || output.empty?
          output.split(DELIMITER_FOR_FORMATS)[1].each_line.to_a
        end

        def create_item(line)
          match = line.match(PATTERN)
          if match
            attributes = {
              name: match[:name],
              desc: match[:desc],
              demuxing: match[:demuxing] == 'D',
              muxing: match[:muxing] == 'E'
            }
            Mediakit::FFmpeg::Formats::Base.define_subclass(
              "Format#{attributes[:name].classify}", attributes
            )
          end
        end
      end

      class DecoderInitializer < Base
        DELIMITER_FOR_CODER = "\n ------\n".freeze
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
        SUPPORT_PATTERN =  /(?<support>(?<type>[VAS.])(?<frame_level>[F.])(?<slice_level>[S.])(?<experimental>[X.])(?<horizon_band>[B.])(?<direct_rendering_method>[D.]))/.freeze
        PATTERN =  /\A\s*#{SUPPORT_PATTERN}\s+(?<name>\w+)\s+(?<desc>.+)\z/.freeze

        def item_type
          'decoders'
        end

        def raw_items
          options = Mediakit::FFmpeg::Options.new(Mediakit::FFmpeg::Options::GlobalOption.new('decoders' => true))
          output, _, _ = @command.run(options, logger: nil)
          return [] if output.nil? || output.empty?
          output.split(DELIMITER_FOR_CODER)[1].each_line.to_a
        end

        def create_item(line)
          match =  line.match(PATTERN)
          if match
            attributes = {
              name: match[:name],
              desc: match[:desc],
              frame_level:  match[:frame_level] !=  '.',
              slice_level:  match[:slice_level] !=  '.',
              experimental:  match[:experimental] !=  '.',
              horizon_band:  match[:horizon_band] !=  '.',
              direct_rendering_method:  match[:direct_rendering_method] !=  '.'
            }
            case match[:type]
            when 'V'
              Mediakit::FFmpeg::Decoders::Video::Base.define_subclass(
                "Decoder#{attributes[:name].classify}", attributes.merge(type: :video)
              )
            when 'A'
              Mediakit::FFmpeg::Decoders::Audio::Base.define_subclass(
                "Decoder#{attributes[:name].classify}", attributes.merge(type: :audio)
              )
            when 'S'
              Mediakit::FFmpeg::Decoders::Subtitle::Base.define_subclass(
                "Decoder#{attributes[:name].classify}", attributes.merge(type: :subtitle)
              )
            else
              raise(UnknownTypeError)
            end
          end
        end
      end

      class EncoderInitializer < Base
        DELIMITER_FOR_CODER = "\n ------\n".freeze
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
        SUPPORT_PATTERN =  /(?<support>(?<type>[VAS.])(?<frame_level>[F.])(?<slice_level>[S.])(?<experimental>[X.])(?<horizon_band>[B.])(?<direct_rendering_method>[D.]))/.freeze
        PATTERN =  /\A\s*#{SUPPORT_PATTERN}\s+(?<name>\w+)\s+(?<desc>.+)\z/.freeze

        def item_type
          'encoders'
        end

        def raw_items
          options = Mediakit::FFmpeg::Options.new(Mediakit::FFmpeg::Options::GlobalOption.new('encoders' => true))
          output, _, _ = @command.run(options, logger: nil)
          return [] if output.nil? || output.empty?
          output.split(DELIMITER_FOR_CODER)[1].each_line.to_a
        end

        def create_item(line)
          match =  line.match(PATTERN)
          if match
            attributes = {
              name: match[:name],
              desc: match[:desc],
              frame_level:  match[:frame_level] !=  '.',
              slice_level:  match[:slice_level] !=  '.',
              experimental:  match[:experimental] !=  '.',
              horizon_band:  match[:horizon_band] !=  '.',
              direct_rendering_method:  match[:direct_rendering_method] !=  '.'
            }

            case match[:type]
            when 'V'
              Mediakit::FFmpeg::Encoders::Video::Base.define_subclass(
                "Encoder#{attributes[:name].classify}", attributes.merge(type: :video)
              )
            when 'A'
              Mediakit::FFmpeg::Encoders::Audio::Base.define_subclass(
                "Encoder#{attributes[:name].classify}", attributes.merge(type: :audio)
              )
            when 'S'
              Mediakit::FFmpeg::Encoders::Subtitle::Base.define_subclass(
                "Encoder#{attributes[:name].classify}", attributes.merge(type: :subtitle)
              )
            else
              raise(UnknownTypeError)
            end
          end
        end
      end
    end
  end
end
