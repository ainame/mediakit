require 'mediakit/command'
require 'erb'

module Mediakit
  module Generators
    class Base
      attr_reader :items

      # @param command [Mediakit::Command::FFmpeg] command object to execute with ffmpeg
      def initialize(root, command)
        @root = root
        @command = command
        @items = []
      end

      def item_role
        raise(NotImplementedError)
      end

      def get_items
        raise(NotImplementedError)
      end

      def create_item(line)
        raise(NotImplementedError)
      end

      def generate
        @items = parse_items(get_raw_items)
        rendered = render_template(template)
        filename = path_to_write
        write(filename, rendered)
      end

      def parse_items(raw_items)
        raw_items.each do |line|
          chomped_text = line.chomp
          item = create_item(chomped_text)
          items << item if item
        end
        items
      end

      def render_template(template)
        return unless @items
        ERB.new(template).result(binding)
      end

      def template
        @template ||= File.read(File.join(@root, "templates/#{item_role}.rb.erb"))
      end

      def path_to_write
        File.join(@root, 'lib/mediakit',item_role.pluralize + '.rb')
      end

      def write(filename, body)
        File.open(filename, 'w+') do |f|
          f.write(body)
        end
      end
    end
  end
end