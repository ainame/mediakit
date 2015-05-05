module Mediakit
  module Formats
    @@formats = []
    Format = Struct.new(:name, :ext, :support_video_codecs, :support_audio_codecs, :desc).freeze

    # see http://en.wikipedia.org/wiki/Comparison_of_container_formats
    def define(name, ext, support_video_codecs, support_audio_codecs, desc = '')
      class_name = "Format" + name.upcase
      format = Format.new(name, ext, support_video_codecs, support_audio_codecs, desc).freeze
      @@formats << const_set(class_name, format)
    end
    module_function :define

    def find(name)
      @@formats.select{|format| format.name == name }.first
    end
    module_function :find

    define('mp4', 'mp4', ['mpeg2', 'h263', 'h264'], ['aac', 'mp3'])
    define('3gp', '3gp', ['mpeg2', 'h263', 'h264'], ['aac', 'mp3', 'amr_wb', 'amr_nb'])
  end
end
