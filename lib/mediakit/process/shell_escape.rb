require 'shellwords'

module Mediakit
  module Process
    module ShellEscape
      def escape(*args)
        case args.size
        when 1
          escape_with_split(args[0])
        else
          Shellwords.join(args)
        end
      end
      module_function(:escape)

      private

      def self.escape_with_split(string)
        splits = Shellwords.split(string)
        Shellwords.join(splits)
      end
    end
  end
end
