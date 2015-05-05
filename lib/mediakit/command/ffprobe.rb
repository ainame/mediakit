module Mediakit
  module Command
    class FFprobe
      attr_reader(:driver)

      def initialize(driver)
        @driver = driver
      end

      def execute(args = '')
        driver.run(args)
      end

      def get_json(path)
        args = "#{default_show_options} -print_format json #{path} 2> /dev/null"
        execute(args)
      end

      def default_show_options
        [
          '-show_streams',
          '-show_format'
        ]
      end
    end
  end
end