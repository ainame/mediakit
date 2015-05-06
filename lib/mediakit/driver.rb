module Mediakit
  module Driver
    module Configurable
      attr_accessor(:bin_path)

      def configure(&block)
        yield(self)
      end
    end

    class DriverError < StandardError; end

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
        # TODO cocaineをやめてpopen3を用いた実装を行い、stderrをロギング出来るようにする
        begin
          command_line = Cocaine::CommandLine.new(bin, args, swallow_stderr: true)
          command_line.run
        rescue => e
          raise(DriverError, "#{self.class} catch error with command [$ #{command_line.command}] - #{e.message}, #{e.backtrace.join("\n")}")
        end
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