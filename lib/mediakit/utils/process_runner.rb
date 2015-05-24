require 'open3'
require 'thread'
require 'timeout'
require 'cool.io'
require 'mediakit/utils/shell_escape'

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
        exit_status = nil
        begin
          stdin, stdout, stderr, wait_thread = Open3.popen3(command)
          stdin.close
          output, error_output, exit_status = if @timeout
                                                wait_with_timeout(stdout, stderr, wait_thread)
                                              else
                                                wait_without_timeout(stdout, stderr, wait_thread)
                                              end
        rescue Errno::ENOENT => e
          raise(CommandNotFoundError, "Can't find command - #{command}, #{e.meessage}")
        end

        [output, error_output, exit_status]
      end

      def wait_without_timeout(stdout, stderr, wait_thread)
        wait_thread.join
        exit_status = (wait_thread.value.exitstatus == 0)
        [stdout.read, stderr.read, exit_status]
      end

      def wait_with_timeout(stdout, stderr, wait_thread)
        begin
          loop = Coolio::Loop.new
          timer, out_watcher, err_watcher = setup_watchers(loop, stdout, stderr)
          loop_thread = Thread.new { loop.run }
          wait_thread.join
          exit_status = (wait_thread.value.exitstatus == 0)
        rescue Timeout::Error => error
          force_kill_process(wait_thread.pid)
          raise(error)
        ensure
          out_watcher.close unless out_watcher && out_watcher.closed?
          err_watcher.close unless err_watcher && err_watcher.closed?
          timer.detach if timer
          loop_thread.join if loop_thread
        end

        [out_watcher.data, err_watcher.data,exit_status]
      end

      def build_command(bin, *args)
        command = build_command_without_options(bin, *args)
        if @nice == 0
          command
        else
          "nice -n #{ShellEscape.escape(@nice)} sh -c \"#{command}\""
        end
      end

      def build_command_without_options(bin, *args)
        escaped_args = ShellEscape.escape(*args)
        "#{bin} #{escaped_args}"
      end

      def setup_watchers(loop, stdout, stderr)
        timer = TimeoutTimer.new(@timeout, Thread.current)
        timer.attach(loop)
        out_watcher = IOWatcher.new(stdout) { timer.update }
        out_watcher.attach(loop)
        err_watcher = IOWatcher.new(stderr) { timer.update }
        err_watcher.attach(loop)

        [timer, out_watcher, err_watcher]
      end

      def force_kill_process(pid)
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
