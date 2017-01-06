# == Schema Information
#
# Table name: projects
#
#  id          :integer          not null, primary key
#  title       :string
#  description :text
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

class Project < ApplicationRecord
  has_many :sites, :dependent => :restrict_with_exception

  def self.search(q)
    lk = "%#{q}%"
    where("title like ? or description like ?", lk, lk)
  end
  
end
