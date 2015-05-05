module Mediakit
  module Command
    class FFprobe
      class << self
        FFPROBE_COMMAND = 'ffprobe'.freeze

        def execute(args = '')
          Cocaine::CommandLine.new(FFPROBE_COMMAND, args).run
        end

        def get_json(path)
          args = "#{default_show_options} -print_format json #{path} 2> /dev/null"
          execute(args)
        end

        def default_show_options
          [
            '-show_streams',
            '-show_format'
          ]
        end
      end
    end
  end
end