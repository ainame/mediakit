module Mediakit
  module Command
    class FFprobe
      attr_reader(:driver)

      class FFprobeError < CommandError; end

      def initialize(driver)
        @driver = driver
      end

      def execute(args = '')
        begin
          driver.run(args)
        rescue => e
          raise(FFprobeError, "#{self.class} catch error - #{e.message}, #{e.backtrace.join("\n")}")
        end
      end

      def get_json(path)
        args = "#{default_show_options} -print_format json #{path}"
        execute(args)
      end

      def default_show_options
        [
          '-show_streams',
          '-show_format'
        ].join(' ')
      end
    end
  end
end