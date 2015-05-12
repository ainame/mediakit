require 'shellwords'
require 'open3'
require 'thread'
require 'timeout'


module Mediakit
  module Utils
    class ProcessRunner
      class CommandNotFoundError < StandardError;
      end
      class TimeoutError < StandardError;
      end

      def initialize(timeout: nil)
        @timeout = timeout
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
        command = self.class.command(bin, *args)

        pid, exit_status = nil
        out_reader, err_reader = nil
        watch = TimeoutWatch.new(@timeout)
        begin
          stdin, stdout, stderr, wait_thr = Open3.popen3(command)
          stdin.close
          pid = wait_thr.pid
          watch.start(Thread.current)
          out_reader = IOReader.new(stdout) { |chunk| watch.update }
          err_reader = IOReader.new(stderr) { |chunk| watch.update }

          puts 'wati_thr.join'
          wait_thr.join
          exit_status = (wait_thr.value.exitstatus == 0)
        rescue Errno::ENOENT => e
          raise(CommandNotFoundError, "Can't find command - #{command}, #{e.meessage}")
        rescue Timeout::Error => error
          puts 'raise timeout'
          Process.kill('SIGKILL', pid)
          raise(error)
        ensure
          puts 'eunsure'
          # exists nil when raised before initialize variables
          out_reader.finish if out_reader
          err_reader.finish if err_reader
          watch.finish
        end

        [out_reader.data, err_reader.data, exit_status]
      end

      def self.command(bin, *args)
        escaped_args = escape(*args)
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

      class IOReader
        attr_reader(:data)

        def initialize(io, &block)
          raise(ArgumentError) unless block_given?
          @io = io
          @io.sync = true
          @data = ''
          @block = block
          start
        end

        def finish
          @thread.join
          @thread.kill
        end

        private
        def start
          @thread = Thread.new { read }
          nil
        end

        def read
          return if @io.closed?
          begin
            while chunk = @io.gets
              puts chunk
              @data << chunk
              @block.call(chunk) if @block
            end
          rescue IOError => e
            warn "[WARN] IOError #{e.message}"
          ensure
            @io.close unless @io.closed?
          end
        end
      end

      # watch process progress by io.
      # when wait time exceed duration, then kill process.
      class TimeoutWatch
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
