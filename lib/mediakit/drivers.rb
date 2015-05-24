require 'shellwords'
require 'mediakit/utils/process_runner'

module Mediakit
  module Drivers
    class DriverError < StandardError; end
    class FailError < DriverError; end
    class ConfigurationError < DriverError; end

    class Base
      attr_reader(:bin)
      def initialize(bin)
        @bin = bin
      end

      def run(*args)
        raise(NotImplementedError)
      end

      def command(*args)
        raise(NotImplementedError)
      end
    end

    class PopenDriver < Base
      # execute command and return result
      #
      # @overload run(args)
      #   @param [String] args string argument for command
      # @overload run(*args, options)
      #   @param [Array] args arguments for command
      #   @option [Hash] options run options
      # @return [Bool] stdout output
      def run(*args)
        options = (args.last && args.last.kind_of?(Hash)) ? args.pop : {}
        begin
          runner = Mediakit::Utils::ProcessRunner.new(options)
          stdout, stderr, exit_status = runner.run(bin, *args)
          raise(FailError, stderr) unless exit_status
          stdout
        rescue Mediakit::Utils::ProcessRunner::CommandNotFoundError => e
          raise(ConfigurationError, "cant' find bin in #{bin}.")
        end
      end

      # return command to execute
      #
      # @overload run(args)
      #   @param args [String] arguments for command
      # @overload run(*args)
      #   @param args [Array] arguments for command
      # @return [String] command
      def command(*args)
        escaped_args = Mediakit::Utils::ShellEscape.escape(*args)
        "#{bin} #{escaped_args}"
      end
    end

    class FakeDriver < Base
      def run(args = '')
        true
      end

      def command(args = '')
        bin + args
      end
    end

    class AbstractFactory
      class << self
        attr_accessor(:bin_path)

        def configure(&block)
          yield(self)
        end

        def name
          self.to_s.downcase.split('::').last
        end

        def bin
          bin_path || name
        end

        def new(type = :popen)
          case type.to_sym
          when :popen
            PopenDriver.new(bin)
          when :fake
            FakeDriver.new(bin)
          else
            raise(ArgumentError)
          end
        end
      end
    end

    # factory class for ffmpeg driver
    class FFmpeg < AbstractFactory
    end

    # factory class for ffprobe driver
    class FFprobe < AbstractFactory
    end

    # factory class for sox driver
    class Sox < AbstractFactory
    end
  end
end
