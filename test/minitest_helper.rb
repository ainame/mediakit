$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'mediakit'
require 'minitest-power_assert'
require 'minitest/autorun'

require 'pry'

class TestContext
  ROOT = File.expand_path(File.join(File.dirname(__FILE__), '../'))

  def self.root
    ROOT
  end
end
