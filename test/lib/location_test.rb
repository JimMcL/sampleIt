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
    l3 = Location.new("33 12 1.1 S 155 43 54.33 E +-15 m")
    assert l3.valid?, "Location creation with one string failed" 
    assert_in_delta l1.latitude, l3.latitude, td, "One string creation latitude value wrong"
    assert_in_delta l1.longitude, l3.longitude, td, "One string creation latitude value wrong"
    assert_in_delta 15, l3.error, td, "One string creation error value wrong"

    # Create an invalid location
    assert_not Location.new(nil).valid?, "Nil arguments creation valid but shouldn't be"
    assert_not Location.new("").valid?, "Blank arguments creation valid but shouldn't be"
    assert_not Location.new(200, 200).valid?, "Invalid position creation valid but shouldn't be"

    l4 = Location.new("33 12 1.1 S, 155 43 54.33 E")
    assert l4.valid?, "Location creation with one string and comma failed"
    assert_in_delta l1.latitude, l4.latitude, td, "One string/comma creation latitude value wrong"
    assert_in_delta l1.longitude, l4.longitude, td, "One string/comma creation longitude value wrong"

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
  
end
