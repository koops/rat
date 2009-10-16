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

  def test_round_up
    t = Time.at(1400000000) # Tue May 13 09:53:20 -0700 2014
    Rat.add('echo toad', t, :round_seconds_up => true)
    assert_equal 1400000040, Rat.list.last[:time].to_i
  end

  def test_inner_quotes
    assert_nothing_raised{ Rat.add('echo "ratty"', Time.now + 100, :no_mail => true) }
    assert_nothing_raised{ Rat.add("echo 'ratty'", Time.now + 100, :no_mail => true) }
  end
end
