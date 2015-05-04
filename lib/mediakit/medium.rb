require 'mediakit/command_wrapper'
require 'json'
require 'ostruct'
require 'open-uri'

module Mediakit
  class Medium
    def initialize(path_or_url)
      @path_or_url = path_or_url
    end

    def data(&block)
      bin_data = nil
      with_file do |file|
        file.binmode
        if block_given?
          yield(file)
        else
          bin_data = file.read
        end
      end
      bin_data
    end

    def meta
      @meta ||= begin
        raw_json = CommandWrapper::FFprobe.get_json(@path)
        Meta.new(JSON.parse(raw_json))
      end
    end

    # temporary implementation by OpenStruct
    class Meta < OpenStruct
      def initialize(hash)
        @hash = hash
      end
    end

    private

    def with_file(&block)
      open(@path_or_url) do |file|
        yield(file)
      end
    end
  end
end