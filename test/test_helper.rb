require 'rubygems'
require 'test/unit'

$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'rat'

class Test::Unit::TestCase
  def assert_difference(expression, difference = 1, message = nil, &block)
    b = block.send(:binding)
    before = eval(expression, b)

    yield

    error = "#{expression.inspect} didn't change by #{difference}"
    error = "#{message}.\n#{error}" if message
    assert_equal(before + difference, eval(expression, b), error)
  end
end
