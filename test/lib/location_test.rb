# -*- coding: utf-8 -*-

require 'test_helper'

class LocationTest < ActiveSupport::TestCase
  test "creation" do
    l1 = Location.new(-33.20030555555556, 155.73175833333335, 0)
    td = 0.0000000000001 # Test delta for float comparisons
    assert l1.valid?, "Location creation with numbers failed"
    assert_in_delta -33.20030555555556, l1.latitude, td, "Wrong latitude"
    assert_in_delta 155.73175833333335, l1.longitude, td, "Wrong longitude"
    l2 = Location.new("33 12 1.1 S", "155 43 54.33 E", 0)
    assert l2.valid?, "Location creation with two strings failed"
    assert_in_delta l1.latitude, l2.latitude, td, "Two string creation latitude value wrong"
    assert_in_delta l1.longitude, l2.longitude, td, "Two string creation longitude value wrong"

    # Single string
    l1.error = 15
    check_valid_location("33 12 1.1 S 155 43 54.33 E +-15 m", l1, td)
    check_valid_location("33 12 1.1S 155 43 54.33E +-15.0m", l1, td)
    check_valid_location("33 12 1.1 S, 155 43 54.33 E +-15 m", l1, td)
    check_valid_location("33 12 1.1S, 155 43 54.33E +-15m", l1, td)
    check_valid_location("33° 12′ 1.1″ S 155° 43′ 54.33″ E +-15 m", l1, td)
    # Decimal minutes
    check_valid_location("33° 12.018333333333544′ S 155° 43.90550000000076′ E +-15 m", l1, td)
    check_valid_location("33° 12.018333333333544′ S, 155° 43.90550000000076′ E +-15 m", l1, td)
    check_valid_location("33 12.018333333333544S 155 43.90550000000076E +-15 m", l1, td)
    check_valid_location("33 12.018333333333544S, 155 43.90550000000076E +-15 m", l1, td)
    check_valid_location("33.20030555555556 S 155.73175833333335 E +-15 m", l1, td)
    check_valid_location("33.20030555555556 S, 155.73175833333335 E +-15 m", l1, td)
    check_valid_location("33.20030555555556S 155.73175833333335E +-15 m", l1, td)
    check_valid_location("33.20030555555556S, 155.73175833333335E +-15 m", l1, td)
    check_valid_location("-33.20030555555556, 155.73175833333335 +-15 m", l1, td)

    expect = Location.new(37.8651, -119.5383)
    check_valid_location("37.8651° N, 119.5383° W", expect, td)

    expect = Location.new(37, -119)
    check_valid_location("37 N, 119 W", expect, td)
    check_valid_location("37N, 119W", expect, td)
    check_valid_location("37.0 N, 119.0 W", expect, td)
    check_valid_location("37 0N, 119 0W", expect, td)
    check_valid_location("37 0 0 N, 119 0 0 W", expect, td)
    check_valid_location("37 0 0N, 119 0 0W", expect, td)

    # Create an invalid location
    assert_not Location.new(nil).valid?, "Nil arguments creation valid but shouldn't be"
    assert_not Location.new("").valid?, "Blank arguments creation valid but shouldn't be"
    assert_not Location.new(200, 200).valid?, "Invalid position creation valid but shouldn't be"

    # Location with decimal lat long string, e.g. from google maps
    l5 = Location.new('-33.798440, 151.135202')
    assert l5.valid?, "Location creation with single string decimal degrees failed"
    assert_in_delta -33.798440, l5.latitude, td, "Single string - wrong latitude"
    assert_in_delta 151.135202, l5.longitude, td, "Single string - wrong longitude"

    # Location with altitude
    l6 = Location.new(-33.798440, 151.135202, 5, 78.6)
    assert l6.valid?, "Location creation with altitude failed"
    assert_in_delta -33.798440, l6.latitude, td, "with altitude - wrong latitude"
    assert_in_delta 151.135202, l6.longitude, td, "with altitude - wrong longitude"
    assert_in_delta 5, l6.error, td, "with altitude - wrong error"
    assert_in_delta 78.6, l6.altitude, td, "with altitude - wrong altitude"

    # Require less precision in round trip string conversion
    td = 0.00001
    # Check that to_s/parse is reversible
    l7 = Location.new(l6.to_s)
    assert l7.valid?, "Location creation with full string failed"
    assert_in_delta l6.latitude, l7.latitude, td, "to_s round trip latitude failed"
    assert_in_delta l6.longitude, l7.longitude, td, "to_s round trip longitude failed"
    assert_in_delta l6.error, l7.error, td, "to_s round trip error failed"
    # Note altitude is not handled by to_s/parse round trip

    # Invalid constructor
    l8 = Location.new("fred")
    assert_not l8.valid?, "Invalid constructor should result in invalid location"
  end

  test "horizontal error" do
    l1 = Location.new(nil)
    l2 = nil
    assert l1.smaller_error?(l2), "Nil error not smaller than nil location"
    l2 = Location.new(nil)
    assert_not l1.smaller_error?(l2), "Nil error is smaller than nil error"

    l1.error = 10
    assert l1.smaller_error?(l2), "Non-nil error not smaller than nil error"
    assert_not l2.smaller_error?(l1), "Nil error not smaller than non-nil error"
    l2.error = 5
    assert_not l1.smaller_error?(l2), "Error 10 smaller than 5"
    assert l2.smaller_error?(l1), "Error 10 smaller than 5"
  end

  ################################################################################

  def check_valid_location(str, expected, td)
    l = Location.new(str)
    assert l.valid?, "Location creation with one string (#{str}) failed (result is not valid)" 
    assert_in_delta expected.latitude, l.latitude, td, "One string creation latitude value wrong (#{str})"
    assert_in_delta expected.longitude, l.longitude, td, "One string creation latitude value wrong (#{str})"
    if expected.error.nil?
      assert_nil l.error, "One string creation error value wrong (#{str})"
    else
      assert_in_delta expected.error, l.error, td, "One string creation error value wrong (#{str})"
    end
    if expected.altitude.nil?
      assert_nil l.altitude, "One string creation altitude value wrong (#{str})"
    else
      assert_in_delta expected.altitude, l.altitude, td, "One string creation altitude value wrong (#{str})"
    end
  end
end
