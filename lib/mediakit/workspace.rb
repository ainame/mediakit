require 'fileutils'
require 'tempfile'

module Mediakit
  class Workspace
    attr_reader(:pool)

    def initialize
      @pool = []
    end

    def create_tempfile(filename)
      tempfile = Tempfile.new([File.basename(filename), File.extname(filename)])
      register_file(tempfile)
      tempfile
    end

    def create_file(path)
      return if File.exists?(path)
      file = File.new(path, 'w+')
      register_file(file)
      file
    end

    def register_file(file)
      @pool = [*pool, file].freeze
    end

    def unregister_file(file)
      targets = @pool.select{|f| f.path == file.path}
      return unless targets && targets.kind_of?(Array)
      @pool = [*(@pool - targets)].freeze
    end

    def clean
      @pool.each do |file|
        begin
          unregister_file(file)
          clean_item(file)
        rescue Errno::ENOEN
          warn("already deleted - #{file.path}")
        end
      end
    end

    def clean_file(file)
      if file.kind_of?(Tempfile)
        file.unlink
        file.close
      elsif file.kind_of?(File)
        file.delete
      end
    end
  end
end