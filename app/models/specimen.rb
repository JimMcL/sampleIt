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
#
# Indexes
#
#  index_specimens_on_site_id   (site_id)
#  index_specimens_on_taxon_id  (taxon_id)
#

class Specimen < ApplicationRecord
  belongs_to :site
  belongs_to :taxon, optional: true
  has_many :photos, as: :imageable, :dependent => :destroy

  def self.search(q)
    if id_m = /(?<site>\d*)[-:\/](?<sp>\d*)/.match(q)
      r = all
      r = r.where("site_id = ?", id_m['site']) unless id_m['site'].blank?
      r = r.where("id = ?", id_m['sp']) unless id_m['sp'].blank?
      # Allow special format for ref column
      r = where('ref like ?', (id_m['site'] || '%') + '-' + (id_m['sp'] || '%')) if r.count == 0
      r
    else
      lk = "%#{q}%"
      left_outer_joins(:taxon).
        where("specimens.id = ? OR site_id = ? OR lower(taxa.rank) = ? OR specimens.ref = ?
               OR specimens.description LIKE ? OR specimens.notes LIKE ? OR 
               taxa.scientific_name like ? OR taxa.common_name like ? OR taxa.description like ?",
            q, q, q ? q.downcase : nil, q,
            lk, lk,
            lk, lk, lk)
    end
end
  
  def label
    "#{site_id}-#{id}#{taxon_id ? (': ' + taxon.scientific_name) : ''}"
  end
  
  def human_id
    "#{site_id}-#{id}"
  end
  
  def taxon_label
    taxon_id ? taxon.label : ""
  end

  def to_s
    "Specimen #{label}"
  end
end
