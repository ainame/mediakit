require 'cocaine'


module Mediakit
  module Command

    def exists_command?(command)
      !!Cocaine::CommandLine.new("which", command).run
    end
    module_function :exists_command?

    require 'mediakit/command/ffmpeg'  if self.exists_command?('ffmpeg')
    require 'mediakit/command/ffprobe' if self.exists_command?('ffprobe')
    require 'mediakit/command/sox'     if self.exists_command?('sox')
  end
end