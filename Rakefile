require "bundler/gem_tasks"
require 'mediakit'
require 'mediakit/drivers'
require 'mediakit/runners'
require 'mediakit/generators'

namespace :gen do
  def command
    driver = Mediakit::Drivers::FFmpeg.new
    command = Mediakit::Runners::FFmpeg.new(driver)
  end

  def root
    File.dirname(__FILE__)
  end

  [:codec, :format, :decoder, :encoder].each do |type|
    desc "generate #{type} classes"
    task(type) do
      klass = Mediakit::Generators.const_get(type.to_s.tap{|x| x[0]= x[0].upcase })
      gen = klass.new(root, command)
      gen.generate
    end
  end.tap do |this|
    task(all: this)
  end.tap do |this|
    desc 'clean generated files'
    task :clean do
      this.each do |type|
        sh("rm #{File.join(root, 'lib/mediakit', type.to_s + 's', '**/*.rb')}")
      end
    end
  end
end

task(gen: 'gen:all')
