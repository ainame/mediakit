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

      DEFAULT_READ_TIMEOUT_INTERVAL = 30

      def initialize(timeout: DEFAULT_READ_TIMEOUT_INTERVAL, nice: 0)
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
        loop = Coolio::Loop.new
        begin
          stdin, stdout, stderr, wait_thr = Open3.popen3(command)
          stdin.close
          pid = wait_thr.pid
          timer = TimeoutTimer.new(@timeout, Thread.current)
          timer.attach(loop)
          out_watcher = IOWatcher.new(stdout) { timer.update }
          out_watcher.attach(loop)
          err_watcher = IOWatcher.new(stderr) { timer.update }
          err_watcher.attach(loop)
          loop_thread = Thread.new do
            loop.run
          end
          wait_thr.join
          exit_status = (wait_thr.value.exitstatus == 0)
        rescue Errno::ENOENT => e
          raise(CommandNotFoundError, "Can't find command - #{command}, #{e.meessage}")
        rescue Timeout::Error => error
          safe_kill_process(pid)
          raise(error)
        ensure
          out_watcher.close if out_watcher
          err_watcher.close if err_watcher
          timer.detach if timer
          loop_thread.join
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

      def safe_kill_process(pid)
        Process.kill('SIGKILL', pid)
      rescue Errno::ESRCH
        warn 'already killedd'
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

      class TimeoutTimer < Coolio::TimerWatcher
        DEFAULT_CHECK_INTERVAL = 0.1

        def initialize(duration, current_thread)
          @mutex = Mutex.new
          @duration = duration
          @watched_at = Time.now
          @current_thread = current_thread
          super(DEFAULT_CHECK_INTERVAL, true)
        end

        def on_timer
          if timeout?
            @current_thread.raise(Timeout::Error, "wait timeout error with #{@duration} sec.")
          end
        end

        def update
          @mutex.synchronize do
            @watched_at = Time.now
          end
        end

        private

        def timeout?
          # compare duration into first decimal place by integer
          ((Time.now - @watched_at) * 10).floor >= (@duration * 10).floor
        end
      end
    end
  end
end
