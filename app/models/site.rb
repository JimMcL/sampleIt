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
#  project_id       :integer
#  ref              :string
#
# Indexes
#
#  index_sites_on_project_id  (project_id)
#

require 'exif_tags'
require 'time_utils'

# Schema notes:
# horizontal_error units are metres
# altitude units are metres
# duration units are seconds
class Site < ApplicationRecord
  include ActionView::Helpers

  belongs_to :project
  has_many :specimens, :dependent => :restrict_with_exception
  has_many :photos, as: :imageable
  
  def self.search(q)
    lk = "%#{q}%"
    left_outer_joins(:project).
      where("sites.id = ? OR temperature = ? OR transect = ? OR 
              notes LIKE ? OR weather like ? OR collector like ? OR sample_type like ? OR sites.description like ? OR 
              sites.ref like ? OR projects.title like ?",
            q, q, q, lk, lk, lk, lk, lk, lk, lk) 
  end

  def label
    "Site #{id}: #{description}#{started_at ? started_at.strftime(" - %Y-%m-%d") : ''}"
  end

  def location
    Location.new(latitude, longitude, horizontal_error, altitude)
  end
  
  def location=(loc)
    loc = loc || Location.new(nil)
    loc = Location.new(loc) if loc.is_a? String
    write_attribute(:latitude, loc.latitude)
    write_attribute(:longitude, loc.longitude)
    write_attribute(:horizontal_error, loc.error)
    write_attribute(:altitude, loc.altitude)
  end
  
  def location?
    !latitude.blank? && !longitude.blank?
  end

  def duration_s
    if duration
      distance_of_time_in_words(duration)
    end
  end

  def duration_s=(s)
    begin
      self.duration = TimeUtils::parse_duration_to_seconds(s)
    rescue => err
      # Just ignore it
      Rails.logger.debug "Ignoring invalid duration string '#{s}': #{err}"
    end
  end

  def to_s
    "Site #{id}"
  end
end
