require 'test/test_helper'

class RatTest < Test::Unit::TestCase
  def test_lifecycle
    job = 0
    assert_difference('Rat.list.size') do
      job = Rat.add('echo ratty', Time.now + 100, :no_mail => true)
    end

    assert job > 0
    assert /echo ratty/, Rat.show(job)
    assert_equal job, Rat.list.last[:job]
    assert Rat.list.last[:time].is_a?(Time)

    assert_difference('Rat.list.size', -1) do
      Rat.remove(job)
    end
  end
end
