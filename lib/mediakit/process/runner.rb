require 'open3'
require 'timeout'
require 'cool.io'
require 'logger'
require 'mediakit/process/shell_escape'
require 'mediakit/utils/null_logger'

module Mediakit
  module Process
    class Runner
      class CommandNotFoundError < StandardError;
      end
      class TimeoutError < StandardError;
      end

      DEFAULT_READ_TIMEOUT_INTERVAL = 30

      attr_reader(:logger)

      def initialize(timeout: nil, nice: 0, logger: Logger.new(STDOUT))
        @timeout = timeout
        @nice = nice
        @logger = logger || Mediakit::Utils::NullLogger.new
      end

      # @overload run(command, *args)
      #   @param command [String]
      #   @param args [Array] args as array for safety shellescape
      # @overload run(command, args)
      #   @param command [String] command name
      #   @param args [Array] args as string
      # @return out [String] stdout and stderr of command
      # @return exit_status [Boolean] is succeeded
      def run(bin, *args)
        command = build_command(bin, *args)
        begin
          stdin, stdout, stderr, wait_thread = Open3.popen3(command)
          stdin.close
          exit_status, output, error_output = wait(stdout, stderr, wait_thread)
        rescue Errno::ENOENT => e
          raise(CommandNotFoundError, "Can't find command - #{command}, #{e.meessage}")
        end

        [exit_status, output, error_output]
      end

      def wait(stdout, stderr, wait_thread)
        begin
          setup_watchers(stdout, stderr)
          loop_thread = Thread.new { run_loop }
          wait_thread.join
          exit_status = (wait_thread.value.exitstatus == 0)
        rescue Timeout::Error => error
          force_kill_process(wait_thread.pid)
          raise(error)
        ensure
          teardown_watchers
          loop_thread.join if loop_thread
        end

        [exit_status, @out_watcher.data, @err_watcher.data]
      end

      def build_command(bin, *args)
        command = build_command_without_options(bin, *args)
        if @nice == 0
          command
        else
          "nice -n #{ShellEscape.escape(@nice.to_s)} sh -c \"#{command}\""
        end
      end

      def build_command_without_options(bin, *args)
        escaped_args = ShellEscape.escape(*args)
        "#{bin} #{escaped_args}"
      end

      def setup_watchers(stdout, stderr)
        @timer = @timeout ? TimeoutTimer.new(@timeout, Thread.current) : nil
        @out_watcher = IOWatcher.new(stdout) { |data| @timer.update if @timer; logger.info(data); }
        @err_watcher = IOWatcher.new(stderr) { |data| @timer.update if @timer; logger.info(data); }
        @loop = Coolio::Loop.new
        @out_watcher.attach(@loop)
        @err_watcher.attach(@loop)
        @timer.attach(@loop) if @timer
      end

      def run_loop
        @loop.run
      rescue => e
        # workaround for ambiguous RuntimeError
        logger.warn(e.message)
        logger.warn(e.backtrace.join("\n"))
      end

      def teardown_watchers
        @loop.watchers.each { |w| w.detach  if w.attached? }
        @loop.stop if @loop.has_active_watchers?
      rescue RuntimeError => e
        logger.warn(e.message)
        logger.warn(e.backtrace.join("\n"))
      end

      def force_kill_process(pid)
        ::Process.kill('SIGKILL', pid)
      rescue Errno::ESRCH => e
        logger.warn("fail SIGKILL pid=#{pid} - #{e.message}, #{e.backtrace.join("\n")}")
      end

      class IOWatcher < Coolio::IO
        attr_reader(:io, :data)

        def initialize(io, &block)
          @io = io
          @block = block
          @data = ''
          super
        end

        def on_read(data)
          @block.call(data)
          @data << data
        end

        def on_close
          @block = nil
        end
      end

      class TimeoutTimer < Coolio::TimerWatcher
        DEFAULT_CHECK_INTERVAL = 0.1

        def initialize(duration, current_thread)
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
          @watched_at = Time.now
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
