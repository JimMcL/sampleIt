# == Schema Information
#
# Table name: sites
#
#  id               :integer          not null, primary key
#  notes            :text
#  latitude         :float
#  longitude        :float
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  horizontal_error :float
#  altitude         :float
#  temperature      :float
#  weather          :text
#  collector        :text
#  sample_type      :string
#  transect         :string
#  duration         :integer
#  started_at       :datetime
#  description      :text
#

require 'test_helper'

class SiteTest < ActiveSupport::TestCase
  test "location" do
    td = 0.0000000000001 # Test delta for float comparisons
    proj = Project.create(title: 'Title', description: 'Description')
    
    m = Site.first
    assert_not m.location.valid?, "Initial site location should be invalid"
    m.location = Location.new("-33.1, 155.5")
    m.project = proj
    assert m.location.valid?, "After setting location, it should be valid"
    assert_in_delta -33.1, m.latitude, td, "Wrong latitude"
    assert_in_delta 155.5, m.longitude, td, "Wrong longitude"
    m.save!
    m2 = Site.find(m.id)
    assert m2.location.valid?, "After saving, location should be valid"

    # Test assignment from string
    m2 = Site.last
    assert_not m2.location.valid?, "Last site should have invalid location"
    m2.location = "-33.1, 155.5 +-15 m"
    m2.project = proj
    assert m2.location.valid?, "After setting location from string, it should be valid"
    assert_in_delta -33.1, m2.latitude, td, "m2 wrong latitude"
    assert_in_delta 155.5, m2.longitude, td, "m2 wrong longitude"
    assert_in_delta 15, m2.horizontal_error, td, "m2 wrong horizontal error"
  end

  test "duration" do
    s = Site.first
    s.duration = 60
    assert_equal 60, s.duration
    assert_equal "1 minute", s.duration_s
    s.duration_s = "5 minutes"
    assert_equal 5 * 60, s.duration
    s.duration_s = "4 days"
    assert_equal 4 * 24 * 60 * 60, s.duration
  end
end
