require 'mediakit/command'
require 'json'
require 'ostruct'
require 'open-uri'

module Mediakit
  class Medium
    CHUNK_SIZE = 1024 * 1024 * 2 # 2MB

    def initialize(path)
      @path = path
    end

    def data(&block)
      raise('must use block interface for stooping memory error') unless block_given?
      with_file do |file|
        file.binmode
        yield(file.read(CHUNK_SIZE)) unless file.eof?
      end
    end

    def meta
      @meta ||= begin
        raw_json = ffprobe.get_json(@path)
        Meta.new(JSON.parse(raw_json))
      rescue => e
        # TODO:
        warn "can't get meta info from #{@path} - #{e.message}, #{e.backtrace.join("\n")}"
        nil
      end
    end

    # temporary implementation by OpenStruct
    class Meta < OpenStruct
    end

    private
    def ffprobe
      Command::FFprobe.new(Drivers::FFprobe.new)
    end


    def with_file(&block)
      open(@path) do |file|
        yield(file)
      end
    end
  end
end