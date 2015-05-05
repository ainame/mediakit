module Mediakit
  module Driver
    module Configurable
      attr_accessor(:bin_path)

      def configure(&block)
        yield(self)
      end
    end

    class Base
      extend Configurable

      def name
        raise NotImplementedError
      end

      def bin
        self.class.bin_path || name
      end

      # execute command and return result
      #
      # @param args [String] arguments for command
      # @return result [Bool] command result
      def run(args = '')
        Cocaine::CommandLine.new(bin, args).run
      end

      # return command to execute
      #
      # @param args [String] arguments for command
      # @return result [String] command to execute
      def dry_run(args = '')
        Cocaine::CommandLine.new(bin, args).command
      end
    end

    class FakeDriver < Base
      attr_reader(:name)

      def initialize(name)
        @name = name
      end
    end

    class FFmpeg < Base
      def name
        'ffmpeg'
      end
    end

    class FFprobe < Base
      def name
        'ffprobe'
      end
    end

    class Sox < Base
      def name
        'sox'
      end
    end
  end
end