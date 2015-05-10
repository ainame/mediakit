module Mediakit
  class FFprobe
    attr_reader(:driver)

    class FFprobeError < StandardError;
    end

    def initialize(driver)
      @driver = driver
    end

    def execute(args = '')
      driver.run(args)
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
