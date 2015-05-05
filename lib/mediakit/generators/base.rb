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
        @items.each do |item|
          rendered = render_template(template, item)
          filename = path_to_write(item)
          write(filename, rendered)
        end
      end

      def parse_items(raw_items)
        raw_items.each do |line|
          stripped_text = line.chomp.strip
          item = create_item(stripped_text)
          items << item if item
        end
        items
      end

      def render_template(template, item)
        return unless item
        @item = item
        ERB.new(template).result(binding)
      end

      def template
        @template ||= File.read(File.join(@root, "templates/#{item_role}.rb.erb"))
      end

      def path_to_write(item)
        if item.respond_to?(:type)
          File.join(@root, 'lib/mediakit',item_role.pluralize, item.type.to_s, item_role + '_' + item.name + '.rb')
        else
          File.join(@root, 'lib/mediakit',item_role.pluralize, item_role + '_' + item.name + '.rb')
        end
      end

      def write(filename, body)
        File.open(filename, 'w+') do |f|
          f.write(body)
        end
      end
    end
  end
end