require 'active_support/ordered_hash'

module Mediakit
  module Runners
    class FFmpeg
      # presentation of ffmpeg runners option
      #
      # SYNOPSIS
      # ffmpeg [global_options] {[input_file_options] -i input_file} ... {[output_file_options] output_file} ...
      #
      class Options
        attr_reader(:global, :inputs, :output)
        # constructor
        #
        # @param global [Mediakit::Runners::FFmpeg::Options::GlobalOption]
        # @param inputs [Array<Mediakit::Command::FFmpeg::Options::Inputs>] array object Mediakit::Command::FFmpeg::Options::Inputs
        # @param output [Mediakit::Runners::FFmpeg::Options::Output]
        def initialize(global: nil, inputs: nil, output: nil)
          @global = global
          @inputs = inputs
          @output = output
        end

        def compose
          composed_string = ''
          composed_string << "#{global}" if global
          composed_string << " #{inputs}" if inputs && !inputs.empty?
          composed_string << " #{output}" if output
          composed_string
        end

        alias_method :to_s, :compose

        # Base class for Options
        class OrderedHash < ActiveSupport::OrderedHash
          # initializer
          #
          # @param options [Hash] initial option values
          def initialize(options = {})
            options.each { |key, value| raise_if_invalid_arg_error(key, value) }
            self.merge!(options) if options && options.kind_of?(Hash)
          end

          def []=(key, value)
            raise_if_invalid_arg_error(key, value)
            super
          end

          def compose
            self.map { |key, value| struct_option(key, value) }.compact.join(' ')
          end

          def to_s
            compose
          end

          protected

          def raise_if_invalid_arg_error(key, value)
            raise(ArgumentError, "#{self.class} can't accept nil value with key(#{key}).") if value.nil?
          end

          def struct_option(key, value)
            case value
            when TrueClass, FalseClass
              value ? "-#{key}" : nil
            else
              "-#{key} #{value}"
            end
          end
        end

        class GlobalOption < OrderedHash
        end

        class OptionPathPair
          attr_reader(:options, :path)

          def initialize(options:, path:)
            @options = options
            @path    = path
          end

          def compose
            raise(NotImplementedError)
          end

          def to_s
            compose
          end
        end

        class InputFileOption < OptionPathPair
          # @param options [Hash] input options
          # @param path [String] input file path
          def initialize(options:, path:)
            ordered_hash = OrderedHash.new(options)
            super(options: ordered_hash, path: path)
          end

          def compose
            "#{options} -i #{path}"
          end
        end

        class OutputFileOption < OptionPathPair
          # @param options [Hash] output options
          # @param path [String] output file path
          def initialize(options:, path:)
            ordered_hash = OrderedHash.new(options)
            super(options: ordered_hash, path: path)
          end

          def compose
            "#{options} #{path}"
          end
        end

        class InputFileOptionCollection
          attr_reader(:input_file_options)

          # @param *input_file_options [Mediakit::Runners::FFmpeg::InputFileOptions]
          def initialize(*input_file_options)
            @options = input_file_options
          end

          def empty?
            @options.empty?
          end

          def compose
            @options.map(&:compose).join(' ')
          end
          alias_method :to_s, :compose
        end

        # see https://www.ffmpeg.org/ffmpeg.html#Stream-specifiers-1
        class StreamSpecifier
          attr_reader(:stream_index, :stream_type, :program_id, :metadata_tag_key, :metadata_tag_value, :usable)
          STREAM_TYPES = ['v', 'a', 's'].freeze

          def initialize(stream_index: nil, stream_type: nil, program_id: nil, metadata_tag_key: nil, metadata_tag_value: nil, usable: nil)
            raise(ArgumentError, "invalid args stream_type = #{stream_type}") if stream_type && !STREAM_TYPES.include?(stream_type)
            @stream_index       = stream_index
            @stream_type        = stream_type
            @program_id         = program_id
            @metadata_tag_key   = metadata_tag_key
            @metadata_tag_value = metadata_tag_value
            @usable             = usable
          end

          def to_s
            case
            when stream_index?, stream_type?
              stream_specifier
            when program?
              program_specifier
            when meta?
              metadata_specifier
            when usable?
              usable_specifier
            else
              raise(RuntimeError)
            end
          end

          private

          def stream_specifier
            [stream_type, stream_index].compact.join(':')
          end

          def program_specifier
            ["p:#{program_id}", stream_index].compact.join(':')
          end

          def metadata_specifier
            [metadata_tag_key, metadata_tag_value].compact.join(':')
          end

          def usable_specifier
            'u'
          end

          def stream_index?
            !stream_index.nil?
          end

          def stream_type?
            !stream_type.nil?
          end

          def meta?
            !metadata_tag_key.nil?
          end

          def program?
            !program_id.nil?
          end

          def usable?
            !usable.nil?
          end
        end
      end
    end
  end
end
