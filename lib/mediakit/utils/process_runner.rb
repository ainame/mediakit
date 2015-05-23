require 'shellwords'
require 'open3'
require 'thread'
require 'timeout'
require 'cool.io'

module Mediakit
  module Utils
    class ProcessRunner
      class CommandNotFoundError < StandardError;
      end
      class TimeoutError < StandardError;
      end

      def initialize(timeout: nil, nice: 0)
        @timeout = timeout
        @nice = nice
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
        command = build_command(bin, *args)
        pid, exit_status = nil
        out_reader, err_reader = nil
        watch = TimeoutTimer.new(@timeout)
        loop = Coolio::Loop.new
        begin
          stdin, stdout, stderr, wait_thr = Open3.popen3(command)
          stdin.close
          pid = wait_thr.pid
          watch.start(Thread.current)
          out_watcher = IOWatcher.new(stdout) { watch.update }
          out_watcher.attach(loop)
          err_watcher = IOWatcher.new(stderr) { watch.update }
          err_watcher.attach(loop)
          loop.run
          wait_thr.join
          exit_status = (wait_thr.value.exitstatus == 0)
        rescue Errno::ENOENT => e
          raise(CommandNotFoundError, "Can't find command - #{command}, #{e.meessage}")
        rescue Timeout::Error => error
          Process.kill('SIGKILL', pid)
          raise(error)
        ensure
          out_watcher.close if out_watcher
          err_watcher.close if err_watcher
          watch.finish
        end

        [out_watcher.data, err_watcher.data, exit_status]
      end

      def build_command(bin, *args)
        command = build_command_without_options(bin, *args)
        unless @nice == 0
          "nice -n #{@nice} sh -c \"#{command}\""
        else
          command
        end
      end

      def build_command_without_options(bin, *args)
        escaped_args = self.class.escape(*args)
        "#{bin} #{escaped_args}"
      end

      def self.escape(*args)
        case args.size
        when 1
          escape_with_split(args[0])
        else
          Shellwords.join(args.map { |x| Shellwords.escape(x) })
        end
      end

      private

      def self.escape_with_split(string)
        splits = Shellwords.split(string)
        splits = splits.map { |x| Shellwords.escape(x) }
        splits.join(' ')
      end

      class IOWatcher < Coolio::IO
        attr_reader(:data)

        def initialize(io, &block)
          @block = block
          @data = ''
          super
        end

        def on_read(data)
          @data << data
          @block.call(self)
        end
      end

      # watch process progress by io.
      # when wait time exceed duration, then kill process.
      class TimeoutTimer
        attr_reader(:duration)

        def initialize(duration)
          @duration   = duration
          @watched_at = Time.now
          @mutex      = Mutex.new
        end

        def start(current_thread, &block)
          @current_thread = current_thread
          @watch_thread = Thread.new do
            loop do
              if timeout?
                @current_thread.raise(Timeout::Error, "wait timeout error with #{duration} sec.")
              end
              sleep(0.1)
            end
          end
          nil
        end

        def finish
          @watch_thread.kill
        end

        def update
          @mutex.synchronize do
            @watched_at = Time.now
          end
        end

        private

        def timeout?
          (Time.now - @watched_at) > duration
        end
      end
    end
  end
end
