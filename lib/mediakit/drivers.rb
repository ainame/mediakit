module Mediakit
  module Drivers
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

      # execute runners and return result
      #
      # @param args [String] arguments for runners
      # @return result [Bool] runners result
      def run(args = '')
        # TODO cocaineをやめてpopen3を用いた実装を行い、stderrをロギング出来るようにする
        begin
          command_line = Cocaine::CommandLine.new(bin, args)
          command_line.run
        rescue => e
          raise(DriverError, "#{self.class} catch error with runners [$ #{command_line.command}] - #{e.message}, #{e.backtrace.join("\n")}")
        end
      end

      # return runners to execute
      #
      # @param args [String] arguments for runners
      # @return result [String] runners to execute
      def command(args = '')
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