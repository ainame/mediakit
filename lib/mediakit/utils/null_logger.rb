module Mediakit
  module Utils
    class NullLogger
      attr_accessor(:formatter, :level)

      def debug(*); end
      def info(*); end
      def warn(*); end
      def error(*); end
      def fatal(*); end
    end
  end
end
