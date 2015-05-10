$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'mediakit'

require 'minitest/autorun'


class TestContext
  ROOT = File.expand_path(File.join(File.dirname(__FILE__), '../'))

  def self.root
    ROOT
  end
end
