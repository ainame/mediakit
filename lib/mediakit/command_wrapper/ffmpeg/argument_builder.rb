module Mediakit
  module CommandWrapper
    class FFmpeg
      class ArgumentBuilder
        def initialize(options)
          @input_paths = []
          @output_path = nil
          @options = nil
        end

        def build
          sprintf("%s %s %s", input_format, options_format, output_format)
        end

        def inputs(paths)
          paths.each do |path|
            input(path)
          end
        end

        def input(path)
          @input_paths << path
          self
        end

        def output(path)
          @output_path = path
          self
        end

        def options(options)
          @options = options
          self
        end

        def input_format
          @input_paths.inject("") { |format, path|  [format, "-i #{path}"].join(" ") }.strip
        end

        def output_format
          @output_path
        end

        # todo
        def options_format
          @options
        end
      end
    end
  end
end