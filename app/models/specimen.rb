# == Schema Information
#
# Table name: specimens
#
#  id            :integer          not null, primary key
#  description   :text
#  site_id       :integer
#  quantity      :integer
#  body_length   :float
#  notes         :text
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  taxon_id      :integer
#  id_confidence :string
#  other         :string
#  ref           :string
#  disposition   :string
#  form          :string
#  sex           :string
#
# Indexes
#
#  index_specimens_on_site_id   (site_id)
#  index_specimens_on_taxon_id  (taxon_id)
#

# Column definitions
# disposition, http://rs.tdwg.org/dwc/terms/disposition
# sex, http://rs.tdwg.org/dwc/terms/sex
# form, http://rs.tdwg.org/dwc/terms/lifeStage or form name for polymorphic species
class Specimen < ApplicationRecord
  belongs_to :site
  belongs_to :taxon, optional: true
  has_many :photos, as: :imageable, :dependent => :destroy

  def self.search(q)
    if id_m = /^(?<site>\d*)[-:\/](?<sp>\d*)$/.match(q)
      r = all
      r = r.where("specimens.site_id = ?", id_m['site']) unless id_m['site'].blank?
      r = r.where("specimens.id = ?", id_m['sp']) unless id_m['sp'].blank?
      # Allow special format for ref column
      r = where('specimens.ref like ?', (id_m['site'] || '%') + '-' + (id_m['sp'] || '%')) if r.count == 0
      r
    else
      lk = "%#{q}%"
      # Note that LIKE with no wildcards in the pattern provides a case insensitive = (at least in Sqlite)
      left_outer_joins(:taxon).
        where("specimens.id = ? OR specimens.site_id = ? OR taxa.rank = ? OR 
               specimens.ref LIKE ? OR specimens.description LIKE ? OR 
               specimens.notes LIKE ? OR specimens.disposition LIKE ? OR specimens.form LIKE ? OR specimens.sex LIKE ? OR 
               specimens.other like ? OR
               taxa.scientific_name like ? OR taxa.common_name like ? OR taxa.description like ?",
              q, q, q,
              lk, lk,
              lk, lk, lk, lk,
              lk, lk, lk, lk)
    end
  end

  # Returns description if it is defined, otherwise description of taxon
  def descriptive_text
    description.blank? && taxon ? taxon.descriptive_text : description
  end

  # Returns a string describing how many image of each type exist for this specimen
  def summarise_photos
    s = photos.group(:ptype).count.map do |k, v| ActionController::Base.helpers.pluralize(v, (k.blank? ? 'photo' : k).downcase)
    end.join(', ')
    s.blank? ? '0 photos' : s
  end
  
  def label
    "#{id}#{taxon_id ? (': ' + taxon.scientific_name) : ''}"
  end
  
  def taxon_label
    taxon_id ? taxon.label : ""
  end

  def to_s
    "Specimen #{label}"
  end
end
