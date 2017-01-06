require 'test_helper'

class ViewAngleTest < ActiveSupport::TestCase
  test "order" do
    check_order(:lateral, :dorsal)
    check_order(:lateral, :anterior)
    check_order(:lateral, :face)
    check_order(:lateral, :lateral_right_side)
    check_order(:lateral, :underside)
    check_order(:lateral, '45, 45')
  end
  
  test "creation" do
    a1 = ViewAngle.new(:lateral)
    assert a1.valid?, "Creation 1 failed"
    assert_equal 0, a1.phi, "1: Wrong phi"
    assert_equal 90, a1.lambda, "1: Wrong lambda"
    assert_equal "Lateral", a1.to_s, "1: Wrong to_s"
    check_roundtrip(a1, "1")

    a2 = ViewAngle.new(0, 90)
    assert a2.valid?, "2: Creation failed"
    assert_equal 0, a2.phi, "2: Wrong phi"
    assert_equal 90, a2.lambda, "2: Wrong lambda"
    assert_equal "Lateral", a2.to_s, "2: Wrong to_s"
    check_roundtrip(a2, "2")

    a3 = ViewAngle.new('dorsal', -5, 90)
    assert a3.valid?, "3: Creation failed"
    assert_equal 85, a3.phi, "3: Wrong phi"
    assert_equal 90, a3.lambda, "3: Wrong lambda"
    assert_equal "85, 90", a3.to_s, "3: Wrong to_s"
    check_roundtrip(a3, "3")

    assert_raises(ArgumentError) { ViewAngle.new("fred") }

    a4 = ViewAngle.new("0, 90")
    assert a4.valid?, "4: Creation failed"
    assert_equal 0, a4.phi, "4: Wrong phi"
    assert_equal 90, a4.lambda, "4: Wrong lambda"
    check_roundtrip(a4, "4")

    a5 = ViewAngle.new("0, -90")
    assert a5.valid?, "5: Creation failed"
    assert_equal 0, a5.phi, "5: Wrong phi"
    assert_equal -90, a5.lambda, "5: Wrong lambda"
    assert_equal 'Lateral right side', a5.to_s, "5: Wrong to_s"
    check_roundtrip(a5, "5")

    a6 = ViewAngle.new(nil)
    assert_not a6.valid?, "6: Creation failed"
  end

  test "hashing" do
    assert_equal ViewAngle.new('lateral'), ViewAngle.new('lateral'), "Equivalent angles aren't equal"
    assert_equal ViewAngle.new('lateral').hash, ViewAngle.new('lateral').hash, "Equivalent angle hashes aren't equal"
    assert ViewAngle.new('lateral').eql?(ViewAngle.new('lateral')), "Equivalent angles aren't eql?"

    by_angle = Hash.new {|h,k| h[k]=0}
    by_angle[ViewAngle.new('lateral')] += 1
    by_angle[ViewAngle.new(0, 90)] += 1
    by_angle[ViewAngle.new('dorsal')] += 1
    assert_equal 2, by_angle[ViewAngle.new('lateral')], 'View angle has keys are failing (lateral)'
    assert_equal 1, by_angle[ViewAngle.new('dorsal')], 'View angle has keys are failing (dorsal)'
    assert_equal 0, by_angle[ViewAngle.new('anterior')], 'View angle has keys are failing (anterior)'
  end

  test "query expansion" do
    p = ViewAngle.expand_query_params(view_angle: 'lateral')
    assert_equal [:view_phi, :view_lambda], p.keys
    exp = {:view_phi => 0, :view_lambda => 90}
    assert_equal exp, p
  end
  
  ################################################################################

  def check_order(a1, a2)
    assert ViewAngle.new(a1) < ViewAngle.new(a2), "Angle #{a1} !< #{a2}"
  end
  
  def check_roundtrip(va, pre)
    rt = ViewAngle.new(va.to_s)
    assert_equal va.valid?, rt.valid?, "#{pre}-roundtrip: Wrong valid"
    assert_equal va.phi, rt.phi, "#{pre}-roundtrip: Wrong phi"
    assert_equal va.lambda, rt.lambda, "#{pre}-roundtrip: Wrong lambda"
  end
end
