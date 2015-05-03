require 'cocaine'


module Mediakit
  module CommandWrapper

    def exists_command?(command)
      !!Cocaine::CommandLine.new("which", command).run
    end
    module_function :exists_command?

    require 'mediakit/command_wrapper/ffmpeg'  if self.exists_command?('ffmpeg')
    require 'mediakit/command_wrapper/ffprobe' if self.exists_command?('ffprobe')
    require 'mediakit/command_wrapper/sox'     if self.exists_command?('sox')
  end
end