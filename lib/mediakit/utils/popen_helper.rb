require 'shellwords'
require 'open3'

module Mediakit
  module Utils
    module PopenHelper

      class CommandNotFoundError < StandardError;
      end

      # @overload run(command, *args)
      #   @param command [String]
      #   @param args [Array] args as array for safety shellescape
      # @overload run(command, args)
      #   @param command [String] command name
      #   @param args [Array] args as string
      # @return out [String] stdout of command
      # @return err [String] stderr of command
      # @return exit_status [Boolean] is succeeded
      def run(bin, *args)
        command = command(bin, *args)

        out, err, exit_status = nil
        begin
          Open3.popen3(command) do |stdin, stdout, stderr, wait_thr|
            stdin.close
            out         = stdout.read
            err         = stderr.read
            exit_status = (wait_thr.value.exitstatus == 0)
          end
        rescue Errno::ENOENT => e
          raise(CommandNotFoundError, "Can't find command - #{command}, #{e.meessage}")
        end

        [out, err, exit_status]
      end

      module_function(:run)

      def command(bin, *args)
        escaped_args = escape(*args)
        "#{bin} #{escaped_args}"
      end

      module_function(:command)

      def escape(*args)
        case args.size
        when 1
          _escape_with_split(args[0])
        else
          Shellwords.join(args.map { |x| Shellwords.escape(x) })
        end
      end

      module_function(:escape)

      def _escape_with_split(string)
        splits = Shellwords.split(string)
        splits = splits.map { |x| Shellwords.escape(x) }
        splits.join(' ')
      end

      module_function(:_escape_with_split)

    end
  end
end